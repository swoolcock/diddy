#region License
/*
* Copyright © 2002-2005 the original author or authors.
* 
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
* 
*      http://www.apache.org/licenses/LICENSE-2.0
* 
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/
#endregion

/*
File: FJTaskRunner.java

Originally written by Doug Lea and released into the public domain.
This may be used for any purposes whatsoever without acknowledgment.
Thanks for the assistance and support of Sun Microsystems Labs,
and everyone contributing, testing, and using this code.

History:
Date       Who                What
7Jan1999   dl                 First public release
13Jan1999  dl                 correct a stat counter update; 
ensure inactive status on run termination;
misc minor cleaup
14Jan1999  dl                 Use random starting point in scan;
variable renamings.
18Jan1999  dl                 Runloop allowed to die on task exception;
remove useless timed join
22Jan1999  dl                 Rework scan to allow use of priorities.
6Feb1999   dl                 Documentation updates.
7Mar1999   dl                 Add array-based coInvoke
31Mar1999  dl                 Revise scan to remove need for NullTasks
27Apr1999  dl                 Renamed
23oct1999  dl                 Earlier detect of interrupt in scanWhileIdling
24nov1999  dl                 Now works on JVMs that do not properly
implement read-after-write of 2 volatiles.*/
using System;
using System.Threading;

namespace Spring.Threading.ForkJoin
{
	
	/// <summary> Specialized Thread subclass for running FJTasks.
	/// <p>
	/// Each FJTaskRunner keeps FJTasks in a double-ended queue (DEQ).
	/// Double-ended queues support stack-based operations
	/// push and pop, as well as queue-based operations put and take.
	/// Normally, threads run their own tasks. But they
	/// may also steal tasks from each others DEQs.
	/// </p>
	/// <p>
	/// The algorithms are minor variants of those used
	/// in <A href="http://supertech.lcs.mit.edu/cilk/"> Cilk</A> and
	/// <A href="http://www.cs.utexas.edu/users/hood/"> Hood</A>, and
	/// to a lesser extent 
	/// <A href="http://www.cs.uga.edu/~dkl/filaments/dist.html"> Filaments</A>,
	/// but are adapted to work in Java.
	/// </p>
	/// <p>
	/// The two most important capabilities are:
	/// <ul>
	/// <li> Fork a FJTask:</li>
	/// <pre>
	/// Push task onto DEQ
	/// </pre>
	/// <li> Get a task to run (for example within taskYield)</li>
	/// <pre>
	/// If DEQ is not empty, 
	/// Pop a task and run it.
	/// Else if any other DEQ is not empty, 
	/// Take ("steal") a task from it and run it.
	/// Else if the entry queue for our group is not empty,
	/// Take a task from it and run it.
	/// Else if current thread is otherwise idling
	/// If all threads are idling
	/// Wait for a task to be put on group entry queue
	/// Else
	/// Yield or Sleep for a while, and then retry
	/// </pre>
	/// </ul>
	/// The push, pop, and put are designed to only ever called by the
	/// current thread, and take (steal) is only ever called by
	/// other threads.
	/// All other operations are composites and variants of these,
	/// plus a few miscellaneous bookkeeping methods.
	/// </p>
	/// <p>
	/// Implementations of the underlying representations and operations
	/// are geared for use on JVMs operating on multiple CPUs (although
	/// they should of course work fine on single CPUs as well).
	/// </p>
	/// <p>
	/// A possible snapshot of a FJTaskRunner's DEQ is:
	/// <pre>
	/// 0     1     2     3     4     5     6    ...
	/// +-----+-----+-----+-----+-----+-----+-----+--
	/// |     |  t  |  t  |  t  |  t  |     |     | ...  deq array
	/// +-----+-----+-----+-----+-----+-----+-----+--
	/// ^                       ^
	/// base                    top 
	/// (incremented                     (incremented 
	/// on take,                         on push    
	/// decremented                     decremented
	/// on put)                          on pop)
	/// </pre>
	/// </p>
	/// <p>
	/// FJTasks are held in elements of the DEQ. 
	/// They are maintained in a bounded array that
	/// works similarly to a circular bounded buffer. To ensure
	/// visibility of stolen FJTasks across threads, the array elements
	/// must be <code>volatile</code>. 
	/// Using volatile rather than synchronizing suffices here since
	/// each task accessed by a thread is either one that it
	/// created or one that has never seen before. Thus we cannot
	/// encounter any staleness problems executing run methods,
	/// although FJTask programmers must be still sure to either synch or use
	/// volatile for shared data within their run methods.
	/// </p>
	/// <p>
	/// However, since there is no way
	/// to declare an array of volatiles in Java, the DEQ elements actually
	/// hold VolatileTaskRef objects, each of which in turn holds a
	/// volatile reference to a FJTask. 
	/// Even with the double-indirection overhead of 
	/// volatile refs, using an array for the DEQ works out
	/// better than linking them since fewer shared
	/// memory locations need to be
	/// touched or modified by the threads while using the DEQ.
	/// Further, the double indirection may alleviate cache-line
	/// sharing effects (which cannot otherwise be directly dealt with in Java).
	/// </p>
	/// <p>
	/// The indices for the <code>base</code> and <code>top</code> of the DEQ
	/// are declared as volatile. The main contention point with
	/// multiple FJTaskRunner threads occurs when one thread is trying
	/// to pop its own stack while another is trying to steal from it.
	/// This is handled via a specialization of Dekker's algorithm,
	/// in which the popping thread pre-decrements <code>top</code>,
	/// and then checks it against <code>base</code>. 
	/// To be conservative in the face of JVMs that only partially
	/// honor the specification for volatile, the pop proceeds
	/// without synchronization only if there are apparently enough
	/// items for both a simultaneous pop and take to succeed.
	/// It otherwise enters a 
	/// synchronized lock to check if the DEQ is actually empty,
	/// if so failing. The stealing thread
	/// does almost the opposite, but is set up to be less likely
	/// to win in cases of contention: Steals always run under synchronized
	/// locks in order to avoid conflicts with other ongoing steals.
	/// They pre-increment <code>base</code>, and then check against
	/// <code>top</code>. They back out (resetting the base index 
	/// and failing to steal) if the
	/// DEQ is empty or is about to become empty by an ongoing pop.
	/// </p>
	/// <p>
	/// A push operation can normally run concurrently with a steal.
	/// A push enters a synch lock only if the DEQ appears full so must
	/// either be resized or have indices adjusted due to wrap-around
	/// of the bounded DEQ. The put operation always requires synchronization.
	/// </p>
	/// <p>
	/// When a FJTaskRunner thread has no tasks of its own to run, 
	/// it tries to be a good citizen. 
	/// Threads run at lower priority while scanning for work.
	/// </p>
	/// <p>
	/// If the task is currently waiting
	/// via yield, the thread alternates scans (starting at a randomly 
	/// chosen victim) with Thread.yields. This is
	/// well-behaved so long as the JVM handles Thread.yield in a
	/// sensible fashion. (It need not. Thread.yield is so underspecified
	/// that it is legal for a JVM to treat it as a no-op.) This also
	/// keeps things well-behaved even if we are running on a uniprocessor
	/// JVM using a simple cooperative threading model.
	/// </p>
	/// <p>
	/// If a thread needing work is
	/// is otherwise idle (which occurs only in the main runloop), and
	/// there are no available tasks to steal or poll, it
	/// instead enters into a sleep-based (actually timed wait(msec))
	/// phase in which it progressively sleeps for longer durations
	/// (up to a maximum of FJTaskRunnerGroup.MAX_SLEEP_TIME,
	/// currently 100ms) between scans. 
	/// If all threads in the group
	/// are idling, they further progress to a hard wait phase, suspending
	/// until a new task is entered into the FJTaskRunnerGroup entry queue.
	/// A sleeping FJTaskRunner thread may be awakened by a new
	/// task being put into the group entry queue or by another FJTaskRunner
	/// becoming active, but not merely by some DEQ becoming non-empty.
	/// Thus the MAX_SLEEP_TIME provides a bound for sleep durations
	/// in cases where all but one worker thread start sleeping
	/// even though there will eventually be work produced
	/// by a thread that is taking a long time to place tasks in DEQ.
	/// These sleep mechanics are handled in the FJTaskRunnerGroup class.
	/// </p>
	/// <p>
	/// Composite operations such as taskJoin include heavy
	/// manual inlining of the most time-critical operations
	/// (mainly FJTask.invoke). 
	/// This opens up a few opportunities for further hand-optimizations. 
	/// Until Java compilers get a lot smarter, these tweaks
	/// improve performance significantly enough for task-intensive 
	/// programs to be worth the poorer maintainability and code duplication.
	/// </p>
	/// <p>
	/// Because they are so fragile and performance-sensitive, nearly
	/// all methods are declared as final. However, nearly all fields
	/// and methods are also declared as protected, so it is possible,
	/// with much care, to extend functionality in subclasses. (Normally
	/// you would also need to subclass FJTaskRunnerGroup.)
    /// </p>
    /// <p>
	/// None of the normal java.lang.Thread class methods should ever be called
	/// on FJTaskRunners. For this reason, it might have been nicer to
	/// declare FJTaskRunner as a Runnable to run within a Thread. However,
	/// this would have complicated many minor logistics. And since
	/// no FJTaskRunner methods should normally be called from outside the
	/// FJTask and FJTaskRunnerGroup classes either, this decision doesn't impact
	/// usage.
    /// </p>
    /// <p>
	/// You might think that layering this kind of framework on top of
	/// Java threads, which are already several levels removed from raw CPU
	/// scheduling on most systems, would lead to very poor performance. 
	/// But on the platforms
	/// tested, the performance is quite good.
    /// </p>
	/// </summary>
	/// <seealso cref="FJTask">
	/// </seealso>
	/// <seealso cref="FJTaskRunnerGroup">
	/// </seealso>
	
	public class FJTaskRunner: ThreadClass
	{
	    /// <summary>
        /// Creates a new <see cref="FJTaskRunner"/> instance.
        /// </summary>
        /// <param name="thread">backing thread</param>
	    public FJTaskRunner (Thread thread) : base (thread)
	    {}

	    /// <summary> Return the FJTaskRunnerGroup of which this thread is a member
		/// </summary>
		virtual protected internal FJTaskRunnerGroup Group
		{
			get
			{
				return group_;
			}
			
		}
		/// <summary> Set the priority to use while scanning.
		/// We do not bother synchronizing access, since
		/// by the time the value is needed, both this FJTaskRunner 
		/// and its FJTaskRunnerGroup will
		/// necessarily have performed enough synchronization
		/// to avoid staleness problems of any consequence.
		/// 
		/// </summary>
		virtual protected internal int ScanPriority
		{
			set
			{
			    scanPriority_ = value;
			}
			
		}
		/// <summary> Set the priority to use while running tasks.
		/// Same usage and rationale as setScanPriority.
		/// 
		/// </summary>
		virtual protected internal int RunPriority
		{
			set
			{
			    runPriority_ = value;
			}
			
		}
		
		/// <summary>The group of which this FJTaskRunner is a member *</summary>
		protected readonly internal FJTaskRunnerGroup group_;
		
		/// <summary>  
		/// Constructor called only during FJTaskRunnerGroup initialization
		/// </summary>		
		protected internal FJTaskRunner(FJTaskRunnerGroup g)
		{
            deq = VolatileTaskRef.NewArray(INITIAL_CAPACITY);
            barrier = new Object();
		    scanPriority_ = FJTaskRunnerGroup.DefaultScanPriority;
		    group_ = g;
			victimRNG = new Random(this.GetHashCode());
		}
		
		
		/* ------------ DEQ Representation ------------------- */
		
		
		/// <summary> FJTasks are held in an array-based DEQ with INITIAL_CAPACITY
		/// elements. The DEQ is grown if necessary, but default value is
		/// normally much more than sufficient unless  there are
		/// user programming errors or questionable operations generating
		/// large numbers of Tasks without running them.
		/// Capacities must be a power of two. 
		/// 
		/// </summary>
		
		protected internal const int INITIAL_CAPACITY = 4096;
		
		/// <summary> The maximum supported DEQ capacity.
		/// When exceeded, FJTaskRunner operations throw Errors
		/// 
		/// </summary>
		
		protected internal const int MAX_CAPACITY = 1 << 30;
		
		/// <summary> An object holding a single volatile reference to a FJTask.
		/// 
		/// </summary>
		
		protected internal sealed class VolatileTaskRef
		{
			/// <summary>The reference *</summary>
			internal volatile FJTask ref_;
			
			/// <summary>Set the reference *</summary>
			internal void  Put(FJTask r)
			{
			    ref_ = r;
			}
			/// <summary>Return the reference *</summary>
			internal FJTask Get()
			{
				return ref_;
			}
			/// <summary>Return the reference and clear it *</summary>
			internal FJTask Take()
			{
				FJTask r = ref_; ref_ = null; return r;
			}
			
			/// <summary> Initialization utility for constructing arrays. 
			/// Make an array of given capacity and fill it with
			/// VolatileTaskRefs.
			/// 
			/// </summary>
			internal static VolatileTaskRef[] NewArray(int cap)
			{
				VolatileTaskRef[] a = new VolatileTaskRef[cap];
				for (int k = 0; k < cap; k++)
					a[k] = new VolatileTaskRef();
				return a;
			}
		}
		
		/// <summary> 
		/// The DEQ array.
		/// </summary>		
		protected internal VolatileTaskRef[] deq;
		
		/// <summary>Current size of the task DEQ *</summary>
		protected internal virtual int deqSize()
		{
			return deq.Length;
		}
		
		/// <summary> Current top of DEQ. Generally acts just like a stack pointer in an 
		/// array-based stack, except that it circularly wraps around the
		/// array, as in an array-based queue. The value is NOT
		/// always kept within <code>0 ... deq.length</code> though. 
		/// The current top element is always at <code>top &amp; (deq.length-1)</code>.
		/// To avoid integer overflow, top is reset down 
		/// within bounds whenever it is noticed to be out out bounds;
		/// at worst when it is at <code>2 * deq.length</code>.
		/// 
		/// </summary>
		protected internal volatile int top = 0;
		
		
		/// <summary> Current base of DEQ. Acts like a take-pointer in an
		/// array-based bounded queue. Same bounds and usage as top.
		/// 
		/// </summary>
		
		protected internal volatile int base_Renamed = 0;
		
		
		/// <summary> An extra object to synchronize on in order to
		/// achieve a memory barrier.
		/// 
		/// </summary>
		
		protected readonly internal Object barrier;
		
		/* ------------ Other BookKeeping ------------------- */
		
		/// <summary> Record whether current thread may be processing a task
		/// (i.e., has been started and is not in an idle wait).
		/// Accessed, under synch, ONLY by FJTaskRunnerGroup, but the field is
		/// stored here for simplicity.
		/// 
		/// </summary>
		
		protected internal bool active = false;
		
		/// <summary>Random starting point generator for scan() *</summary>
		protected readonly internal Random victimRNG;
		
		
		/// <summary>Priority to use while scanning for work *</summary>
		protected internal int scanPriority_;
		
		/// <summary>Priority to use while running tasks *</summary>
		protected internal int runPriority_;
		
		
		
		internal const bool CollectStats = true;
		// static final boolean COLLECT_STATS = false;
		
		
		// for stat collection
		
		/// <summary>Total number of tasks run *</summary>
		protected internal int runs = 0;
		
		/// <summary>Total number of queues scanned for work *</summary>
		protected internal int scans = 0;
		
		/// <summary>Total number of tasks obtained via scan *</summary>
		protected internal int steals = 0;
		
		
		
		
		/* ------------ DEQ operations ------------------- */
		
		
		/// <summary> Push a task onto DEQ.
		/// Called ONLY by current thread.
		/// 
		/// </summary>
		
		protected internal void  push(FJTask r)
		{
			int t = top;
			
			/*
			This test catches both overflows and index wraps.  It doesn't
			really matter if base value is in the midst of changing in take. 
			As long as deq length is < 2^30, we are guaranteed to catch wrap in
			time since base can only be incremented at most length times
			between pushes (or puts). 
			*/
			
			if (t < (base_Renamed & (deq.Length - 1)) + deq.Length)
			{
				
				deq[t & (deq.Length - 1)].Put(r);
				top = t + 1;
			}
			// isolate slow case to increase chances push is inlined
			else
				slowPush(r); // check overflow and retry
		}
		
		
		/// <summary> Handle slow case for push
		/// 
		/// </summary>
		
		protected internal virtual void  slowPush(FJTask r)
		{
			lock (this)
			{
				checkOverflow();
				push(r); // just recurse -- this one is sure to succeed.
			}
		}
		
		
		/// <summary> Enqueue task at base of DEQ.
		/// Called ONLY by current thread.
		/// This method is currently not called from class FJTask. It could be used
		/// as a faster way to do FJTask.start, but most users would
		/// find the semantics too confusing and unpredictable.
		/// 
		/// </summary>
		
		protected internal void  put(FJTask r)
		{
			lock (this)
			{
				for (; ; )
				{
					int b = base_Renamed - 1;
					if (top < b + deq.Length)
					{
						
						int newBase = b & (deq.Length - 1);
						deq[newBase].Put(r);
						base_Renamed = newBase;
						
						if (b != newBase)
						{
							// Adjust for index underflow
							int newTop = top & (deq.Length - 1);
							if (newTop < newBase)
								newTop += deq.Length;
							top = newTop;
						}
						return ;
					}
					else
					{
						checkOverflow();
						// ... and retry
					}
				}
			}
		}
		
		/// <summary> Return a popped task, or null if DEQ is empty.
		/// Called ONLY by current thread.
		/// <p>
		/// This is not usually called directly but is
		/// instead inlined in callers. This version differs from the
		/// cilk algorithm in that pop does not fully back down and
		/// retry in the case of potential conflict with take. It simply
		/// rechecks under synch lock. This gives a preference
		/// for threads to run their own tasks, which seems to
		/// reduce flailing a bit when there are few tasks to run.
        /// </p>
        /// </summary>
		
		protected internal FJTask pop()
		{
			/* 
			Decrement top, to force a contending take to back down.
			*/
			
			int t = --top;
			
			/*
			To avoid problems with JVMs that do not properly implement
			read-after-write of a pair of volatiles, we conservatively
			grab without lock only if the DEQ appears to have at least two
			elements, thus guaranteeing that both a pop and take will succeed,
			even if the pre-increment in take is not seen by current thread.
			Otherwise we recheck under synch.
			*/
			
			if (base_Renamed + 1 < t)
				return deq[t & (deq.Length - 1)].Take();
			else
				return confirmPop(t);
		}
		
		
		/// <summary> Check under synch lock if DEQ is really empty when doing pop. 
		/// Return task if not empty, else null.
		/// 
		/// </summary>
		
		protected internal FJTask confirmPop(int provisionalTop)
		{
			lock (this)
			{
				if (base_Renamed <= provisionalTop)
					return deq[provisionalTop & (deq.Length - 1)].Take();
				else
				{
					// was empty
					/*
					Reset DEQ indices to zero whenever it is empty.
					This both avoids unnecessary calls to checkOverflow
					in push, and helps keep the DEQ from accumulating garbage
					*/
					
					top = base_Renamed = 0;
					return null;
				}
			}
		}
		
		
		/// <summary> Take a task from the base of the DEQ.
		/// Always called by other threads via scan()
		/// 
		/// </summary>
		
		
		protected internal FJTask take()
		{
			lock (this)
			{
				
				/*
				Increment base in order to suppress a contending pop
				*/
				
				int b = base_Renamed++;
				
				if (b < top)
					return confirmTake(b);
				else
				{
					// back out
					base_Renamed = b;
					return null;
				}
			}
		}
		
		
		/// <summary> double-check a potential take
		/// 
		/// </summary>
		
		protected internal virtual FJTask confirmTake(int oldBase)
		{
			
			/*
			Use a second (guaranteed uncontended) synch
			to serve as a barrier in case JVM does not
			properly process read-after-write of 2 volatiles
			*/
			
			lock (barrier)
			{
				if (oldBase < top)
				{
					/*
					We cannot call deq[oldBase].take here because of possible races when
					nulling out versus concurrent push operations.  Resulting
					accumulated garbage is swept out periodically in
					checkOverflow, or more typically, just by keeping indices
					zero-based when found to be empty in pop, which keeps active
					region small and constantly overwritten. 
					*/
					
					return deq[oldBase & (deq.Length - 1)].Get();
				}
				else
				{
					base_Renamed = oldBase;
					return null;
				}
			}
		}
		
		
		/// <summary> Adjust top and base, and grow DEQ if necessary.
		/// Called only while DEQ synch lock being held.
		/// We don't expect this to be called very often. In most
		/// programs using FJTasks, it is never called.
		/// 
		/// </summary>
		
		protected internal virtual void  checkOverflow()
		{
			int t = top;
			int b = base_Renamed;
			
			if (t - b < deq.Length - 1)
			{
				// check if just need an index reset
				
				int newBase = b & (deq.Length - 1);
				int newTop = top & (deq.Length - 1);
				if (newTop < newBase)
					newTop += deq.Length;
				top = newTop;
				base_Renamed = newBase;
				
				/* 
				Null out refs to stolen tasks. 
				This is the only time we can safely do it.
				*/
				
				int i = newBase;
				while (i != newTop && deq[i].ref_ != null)
				{
					deq[i].ref_ = null;
					i = (i - 1) & (deq.Length - 1);
				}
			}
			else
			{
				// grow by doubling array
				
				int newTop = t - b;
				int oldcap = deq.Length;
				int newcap = oldcap * 2;
				
				if (newcap >= MAX_CAPACITY)
					throw new ApplicationException("FJTask queue maximum capacity exceeded");
				
				VolatileTaskRef[] newdeq = new VolatileTaskRef[newcap];
				
				// copy in bottom half of new deq with refs from old deq
				for (int j = 0; j < oldcap; ++j)
					newdeq[j] = deq[b++ & (oldcap - 1)];
				
				// fill top half of new deq with new refs
				for (int j = oldcap; j < newcap; ++j)
					newdeq[j] = new VolatileTaskRef();
				
				deq = newdeq;
				base_Renamed = 0;
				top = newTop;
			}
		}
		
		
		/* ------------ Scheduling  ------------------- */
		
		
		/// <summary> Do all but the pop() part of yield or join, by
		/// traversing all DEQs in our group looking for a task to
		/// steal. If none, it checks the entry queue. 
		/// <p>
		/// Since there are no good, portable alternatives,
		/// we rely here on a mixture of Thread.yield and priorities
		/// to reduce wasted spinning, even though these are
		/// not well defined. We are hoping here that the JVM
		/// does something sensible.
        /// </p>
        /// </summary>
		/// <param name="waitingFor">if non-null, the current task being joined
		/// 
		/// </param>
		
		protected internal virtual void  scan(FJTask waitingFor)
		{
			
			FJTask task = null;
			
			// to delay lowering priority until first failure to steal
			bool lowered = false;
			
			/*
			Circularly traverse from a random start index. 
			
			This differs slightly from cilk version that uses a random index
			for each attempted steal.
			Exhaustive scanning might impede analytic tractablity of 
			the scheduling policy, but makes it much easier to deal with
			startup and shutdown.
			*/
			
			FJTaskRunner[] ts = group_.Array;
			int idx = victimRNG.Next(ts.Length);
			
			for (int i = 0; i < ts.Length; ++i)
			{
				
				FJTaskRunner t = ts[idx];
				if (++idx >= ts.Length)
					idx = 0; // circularly traverse
				
				if (t != null && t != this)
				{
					
					if (waitingFor != null && waitingFor.Done)
					{
						break;
					}
					else
					{
						if (CollectStats)
							++scans;
						task = t.take();
						if (task != null)
						{
							if (CollectStats)
								++steals;
							break;
						}
						else
						{
							if (Interrupted)
							{
								break;
							}
							else if (!lowered)
							{
								// if this is first fail, lower priority
								lowered = true;
								Priority = (ThreadPriority) scanPriority_;
							}
							else
							{
								// otherwise we are at low priority; just yield
							    Thread.Sleep(0);
							}
						}
					}
				}
			}
			
			if (task == null)
			{
				if (CollectStats)
					++scans;
				task = group_.PollEntryQueue(this);
				if (CollectStats)
					if (task != null)
						++steals;
			}
			
			if (lowered)
			{
				Priority = (ThreadPriority) runPriority_;
			}
			
			if (task != null && !task.Done)
			{
				if (CollectStats)
					++runs;
				task.Run();
				task.SetDone();
			}
		}
		
		/// <summary> Same as scan, but called when current thread is idling.
		/// It repeatedly scans other threads for tasks,
		/// sleeping while none are available. 
		/// <p>
		/// This differs from scan mainly in that
		/// since there is no reason to return to recheck any
		/// condition, we iterate until a task is found, backing
		/// off via sleeps if necessary.
        /// </p>
        /// 
		/// </summary>
		
		protected internal virtual void  scanWhileIdling()
		{
			FJTask task = null;
			
			bool lowered = false;
			long iters = 0;
			
			FJTaskRunner[] ts = group_.Array;
			int idx = victimRNG.Next(ts.Length);
			
			do 
			{
				for (int i = 0; i < ts.Length; ++i)
				{
					
					FJTaskRunner t = ts[idx];
					if (++idx >= ts.Length)
						idx = 0; // circularly traverse
					
					if (t != null && t != this)
					{
						if (CollectStats)
							++scans;
						
						task = t.take();
						if (task != null)
						{
							if (CollectStats)
								++steals;
							if (lowered)
							{
								Priority = (ThreadPriority) runPriority_;
							}
						    group_.SetActive(this);
							break;
						}
					}
				}
				
				if (task == null)
				{
					if (Interrupted)
						return ;
					
					if (CollectStats)
						++scans;
					task = group_.PollEntryQueue(this);
					
					if (task != null)
					{
						if (CollectStats)
							++steals;
						if (lowered)
						{
							Priority = (ThreadPriority) runPriority_;
						}
					    group_.SetActive(this);
					}
					else
					{
						++iters;
						//  Check here for yield vs sleep to avoid entering group synch lock
						if (iters >=  FJTaskRunnerGroup.ScansPerSleep)
						{
						    group_.CheckActive(this, iters);
							if (Interrupted)
								return ;
						}
						else if (!lowered)
						{
							lowered = true;
							Priority = (ThreadPriority) scanPriority_;
						}
						else
						{
						    Thread.Sleep(0);
						}
					}
				}
			}
			while (task == null);
			
			
			if (!task.Done)
			{
				if (CollectStats)
					++runs;
				task.Run();
				task.SetDone();
			}
		}
		
		/* ------------  composite operations ------------------- */
		
		
		/// <summary> Main runloop
		/// 
		/// </summary>
		
		private void DoStart ()
		{
			try
			{
				while (!Interrupted)
				{
					
					FJTask task = pop();
					if (task != null)
					{
						if (!task.Done)
						{
							// inline FJTask.invoke
							if (CollectStats)
								++runs;
							task.Run();
							task.SetDone();
						}
					}
					else
						scanWhileIdling();
				}
			}
			finally
			{
			    group_.Inactive = this;
			}
		}
		
		/// <summary> Execute a task in this thread. Generally called when current task
		/// cannot otherwise continue.
		/// 
		/// </summary>
		
		
		protected internal void  taskYield()
		{
			FJTask task = pop();
			if (task != null)
			{
				if (!task.Done)
				{
					if (CollectStats)
						++runs;
					task.Run();
					task.SetDone();
				}
			}
			else
				scan(null);
		}
		
		
		/// <summary> Process tasks until w is done.
		/// Equivalent to <code>while(!w.isDone()) taskYield(); </code>
		/// 
		/// </summary>
		
		protected internal void  taskJoin(FJTask w)
		{
			
			while (!w.Done)
			{
				
				FJTask task = pop();
				if (task != null)
				{
					if (!task.Done)
					{
						if (CollectStats)
							++runs;
						task.Run();
						task.SetDone();
						if (task == w)
							return ; // fast exit if we just ran w
					}
				}
				else
					scan(w);
			}
		}
		
		/// <summary> A specialized expansion of
		/// <code> w.fork(); invoke(v); w.join(); </code>
		/// 
		/// </summary>
		
		
		protected internal void  coInvoke(FJTask w, FJTask v)
		{
			
			// inline  push
			
			int t = top;
			if (t < (base_Renamed & (deq.Length - 1)) + deq.Length)
			{
				
				deq[t & (deq.Length - 1)].Put(w);
				top = t + 1;
				
				// inline  invoke
				
				if (!v.Done)
				{
					if (CollectStats)
						++runs;
					v.Run();
					v.SetDone();
				}
				
				// inline  taskJoin
				
				while (!w.Done)
				{
					FJTask task = pop();
					if (task != null)
					{
						if (!task.Done)
						{
							if (CollectStats)
								++runs;
							task.Run();
							task.SetDone();
							if (task == w)
								return ; // fast exit if we just ran w
						}
					}
					else
						scan(w);
				}
			}
			// handle non-inlinable cases
			else
				slowCoInvoke(w, v);
		}
		
		
		/// <summary> Backup to handle noninlinable cases of coInvoke
		/// 
		/// </summary>
		
		protected internal virtual void  slowCoInvoke(FJTask w, FJTask v)
		{
			push(w); // let push deal with overflow
			FJTask.Invoke(v);
			taskJoin(w);
		}
		
		
		/// <summary> Array-based version of coInvoke
		/// 
		/// </summary>
		
		protected internal void  coInvoke(FJTask[] tasks)
		{
			int nforks = tasks.Length - 1;
			
			// inline bulk push of all but one task
			
			int t = top;
			
			if (nforks >= 0 && t + nforks < (base_Renamed & (deq.Length - 1)) + deq.Length)
			{
				for (int i = 0; i < nforks; ++i)
				{
					deq[t++ & (deq.Length - 1)].Put(tasks[i]);
					top = t;
				}
				
				// inline invoke of one task
				FJTask v = tasks[nforks];
				if (!v.Done)
				{
					if (CollectStats)
						++runs;
					v.Run();
					v.SetDone();
				}
				
				// inline  taskJoins
				
				for (int i = 0; i < nforks; ++i)
				{
					FJTask w = tasks[i];
					while (!w.Done)
					{
						
						FJTask task = pop();
						if (task != null)
						{
							if (!task.Done)
							{
								if (CollectStats)
									++runs;
								task.Run();
								task.SetDone();
							}
						}
						else
							scan(w);
					}
				}
			}
			// handle non-inlinable cases
			else
				slowCoInvoke(tasks);
		}
		
		/// <summary> Backup to handle atypical or noninlinable cases of coInvoke
		/// 
		/// </summary>
		
		protected internal virtual void  slowCoInvoke(FJTask[] tasks)
		{
			for (int i = 0; i < tasks.Length; ++i)
				push(tasks[i]);
			for (int i = 0; i < tasks.Length; ++i)
				taskJoin(tasks[i]);
		}

        /// <summary>
        /// Create a new <see cref="FJTaskRunner"/>, setting its thread
        /// as needed
        /// </summary>
	    public static FJTaskRunner New (FJTaskRunnerGroup runnerGroup)
	    {
            FJTaskRunner runner = new FJTaskRunner(runnerGroup);
            Thread t = new Thread(new ThreadStart(runner.DoStart));
            t.Name = "FJTaskRunner thread #" + t.GetHashCode();
            runner.SetThread(t);
            return runner;
        }

	    /// <summary>
	    /// sets the backing thread and priority
	    /// <seealso cref="ThreadClass"/>
	    /// </summary>
	    protected override void SetThread (Thread t)
	    {
	        base.SetThread (t);
	        runPriority_ = (Int32) Priority;
        }
    }
}