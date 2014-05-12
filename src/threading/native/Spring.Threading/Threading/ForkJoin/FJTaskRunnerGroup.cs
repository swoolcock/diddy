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
File: FJTaskRunnerGroup.java

Originally written by Doug Lea and released into the public domain.
This may be used for any purposes whatsoever without acknowledgment.
Thanks for the assistance and support of Sun Microsystems Labs,
and everyone contributing, testing, and using this code.

History:
Date       Who                What
7Jan1999   dl                 First public release
12Jan1999  dl                 made getActiveCount public; misc minor cleanup.
14Jan1999  dl                 Added executeTask
20Jan1999  dl                 Allow use of priorities; reformat stats
6Feb1999   dl                 Lazy thread starts
27Apr1999  dl                 Renamed*/
using System;
using System.IO;
using System.Threading;

namespace Spring.Threading.ForkJoin
{
	
	/// <summary> A stripped down analog of a ThreadGroup used for
	/// establishing and managing FJTaskRunner threads.
	/// ThreadRunnerGroups serve as the control boundary separating
	/// the general world of normal threads from the specialized world
	/// of FJTasks. 
	/// <p>
	/// By intent, this class does not subclass java.lang.ThreadGroup, and
	/// does not support most methods found in ThreadGroups, since they
	/// would make no sense for FJTaskRunner threads. In fact, the class
	/// does not deal with ThreadGroups at all. If you want to restrict
	/// a FJTaskRunnerGroup to a particular ThreadGroup, you can create
	/// it from within that ThreadGroup.
    /// </p>
    /// <p>
	/// The main contextual parameter for a FJTaskRunnerGroup is
	/// the group size, established in the constructor. 
	/// Groups must be of a fixed size.
	/// There is no way to dynamically increase or decrease the number
	/// of threads in an existing group.
    /// </p>
    /// <p>
	/// In general, the group size should be equal to the number
	/// of CPUs on the system. (Unfortunately, there is no portable
	/// means of automatically detecting the number of CPUs on a JVM, so there is
	/// no good way to automate defaults.)  In principle, when
	/// FJTasks are used for computation-intensive tasks, having only 
	/// as many threads as CPUs should minimize bookkeeping overhead
	/// and contention, and so maximize throughput. However, because
	/// FJTaskRunners lie atop CLR threads, and in turn operating system
	/// thread support and scheduling policies, 
	/// it is very possible that using more threads
	/// than CPUs will improve overall throughput even though it adds
	/// to overhead. This will always be so if FJTasks are I/O bound.
	/// So it may pay to experiment a bit when tuning on particular platforms.
	/// You can also use <code>setRunPriorities</code> to either
	/// increase or decrease the priorities of active threads, which
	/// may interact with group size choice.
    /// </p>
    /// <p>
	/// In any case, overestimating group sizes never
	/// seriously degrades performance (at least within reasonable bounds). 
	/// You can also use a value
	/// less than the number of CPUs in order to reserve processing
	/// for unrelated threads. 
    /// </p>
    /// <p>
	/// There are two general styles for using a FJTaskRunnerGroup.
	/// You can create one group per entire program execution, for example 
	/// as a static singleton, and use it for all parallel tasks:
    /// <pre>
	/// class Tasks {
	/// static FJTaskRunnerGroup group;
	/// public void initialize(int groupsize) {
	/// group = new FJTaskRunnerGroup(groupSize);
	/// }
	/// // ...
	/// }
	/// </pre>
	/// Alternatively, you can make new groups on the fly and use them only for
	/// particular task sets. This is more flexible,,
	/// and leads to more controllable and deterministic execution patterns,
	/// but it encounters greater overhead on startup. Also, to reclaim
	/// system resources, you should
	/// call <code>FJTaskRunnerGroup.interruptAll</code> when you are done
	/// using one-shot groups. Otherwise, because FJTaskRunners set 
	/// <code>Thread.isDaemon</code>
	/// status, they will not normally be reclaimed until program termination.
    /// </p>
    /// <p>
	/// The main supported methods are <code>execute</code>,
	/// which starts a task processed by FJTaskRunner threads,
	/// and <code>invoke</code>, which starts one and waits for completion.
	/// For example, you might extend the above <code>FJTasks</code>
	/// class to support a task-based computation, say, the
	/// <code>Fib</code> class from the <code>FJTask</code> documentation:
	/// <pre>
	/// class Tasks { // continued
	/// // ...
	/// static int fib(int n) {
	/// try {
	/// Fib f = new Fib(n);
	/// group.invoke(f);
	/// return f.getAnswer();
	/// }
	/// catch (InterruptedException ex) {
	/// throw new Error("Interrupted during computation");
	/// }
	/// }
	/// }
	/// </pre>
    /// </p>
    /// <p>
	/// Method <code>stats()</code> can be used to monitor performance.
	/// Both FJTaskRunnerGroup and FJTaskRunner may be compiled with
	/// the compile-time constant COLLECT_STATS set to false. In this
	/// case, various simple counts reported in stats() are not collected.
	/// On platforms tested,
	/// this leads to such a tiny performance improvement that there is 
	/// very little motivation to bother.
    /// </p>
    /// </summary>
	/// <seealso cref="FJTask">
	/// </seealso>
	/// <seealso cref="FJTaskRunner">
	/// 
	/// </seealso>
	
	public class FJTaskRunnerGroup : IExecutor
	{
	    /// <summary> Set the priority to use while a FJTaskRunner is
		/// polling for new tasks to perform. Default
		/// is currently Thread.MIN_PRIORITY+1. The value
		/// set may not go into effect immediately, but
		/// will be used at least the next time a thread scans for work.
		/// 
		/// </summary>
		virtual public int ScanPriorities
		{
			set
			{
				lock (this)
				{
					for (int i = 0; i < threads.Length; ++i)
					{
						FJTaskRunner t = threads[i];
						t.ScanPriority = value;
						if (!t.active)
						{
							t.Priority = (System.Threading.ThreadPriority) value;
						}
					}
				}
			}
			
		}
		/// <summary> Set the priority to use while a FJTaskRunner is
		/// actively running tasks. Default
		/// is the priority that was in effect by the thread that
		/// constructed this FJTaskRunnerGroup. Setting this value
		/// while threads are running may momentarily result in
		/// them running at this priority even when idly waiting for work.
		/// 
		/// </summary>
		virtual public int RunPriorities
		{
			set
			{
				lock (this)
				{
					for (int i = 0; i < threads.Length; ++i)
					{
						FJTaskRunner t = threads[i];
						t.RunPriority = value;
						if (t.active)
						{
							t.Priority = (System.Threading.ThreadPriority) value;
						}
					}
				}
			}
			
		}
		/// <summary> Return the number of threads that are not idly waiting for work.
		/// Beware that even active threads might not be doing any useful
		/// work, but just spinning waiting for other dependent tasks.
		/// Also, since this is just a snapshot value, some tasks
		/// may be in the process of becoming idle.
		/// 
		/// </summary>
		virtual public int ActiveCount
		{
			get
			{
				lock (this)
				{
					return activeCount_;
				}
			}
			
		}
		/// <summary> Return the array of threads in this group. 
		/// Called only by FJTaskRunner.scan().
		/// 
		/// </summary>
		virtual protected internal FJTaskRunner[] Array
		{
			
			
			get
			{
				return threads;
			}
			
		}
		/// <summary> Set active status of thread t to false.
		/// 
		/// </summary>
		virtual protected internal FJTaskRunner Inactive
		{
			set
			{
				lock (this)
				{
					if (value.active)
					{
						value.active = false;
						--activeCount_;
					}
				}
			}
			
		}
		
		/// <summary>The threads in this group *</summary>
		protected readonly internal FJTaskRunner[] threads;
		
		/// <summary>Group-wide queue for tasks entered via execute() *</summary>
		protected readonly internal LinkedQueue entryQueue;
		
		/// <summary>Number of threads that are not waiting for work *</summary>
		protected internal int activeCount_ = 0;
		
		/// <summary>Number of threads that have been started. Used to avoid
		/// unecessary contention during startup of task sets.
		/// 
		/// </summary>
		protected internal int nstarted = 0;
		
		/// <summary> Compile-time constant. If true, various counts of
		/// runs, waits, etc., are maintained. These are NOT
		/// updated with synchronization, so statistics reports
		/// might not be accurate.
		/// 
		/// </summary>
		
		internal const bool CollectStats = true;
		//  static final boolean COLLECT_STATS = false;
		
		// for stats
		
		/// <summary>The time at which this ThreadRunnerGroup was constructed *</summary>
		internal long initTime = 0;
		
		/// <summary>Total number of executes or invokes *</summary>
		internal int entries = 0;
		
		internal static readonly int DefaultScanPriority = (int) System.Threading.ThreadPriority.Lowest + 1;
		
		/// <summary> Create a FJTaskRunnerGroup with the indicated number
		/// of FJTaskRunner threads. Normally, the best size to use is
		/// the number of CPUs on the system. 
		/// <p>
		/// The threads in a FJTaskRunnerGroup are created with their
		/// isDaemon status set, so do not normally need to be
		/// shut down manually upon program termination.
        /// </p>
        /// </summary>
		
		public FJTaskRunnerGroup(int groupSize)
		{
		    entryQueue = new LinkedQueue();	        
            threads = new FJTaskRunner[groupSize];
		    InitializeThreads();
			initTime = Utils.CurrentTimeMillis;
		}
		
		/// <summary> Arrange for execution of the given task
		/// by placing it in a work queue. If the argument
		/// is not of type FJTask, it is embedded in a FJTask via 
		/// <code>FJTask.Wrap</code>.
		/// </summary>
		/// <exception cref="ThreadInterruptedException">  if current Thread is
		/// currently interrupted 
		/// 
		/// </exception>
		
		public virtual void  Execute(IRunnable r)
		{
//			if (r is FJTask)
//			{
//				entryQueue.Put((FJTask) r);
//			}
//			else
//			{
//				entryQueue.Put(new FJTask.Wrap(r, ));
//			}
            entryQueue.Put(r);
		    SignalNewTask();
		}
		
        /// <summary> Arrange for execution of the given task
        /// by placing it in a work queue. If the argument
        /// is not of type FJTask, it is embedded in a FJTask via 
        /// <code>FJTask.Wrap</code>.
        /// </summary>
        /// <exception cref="ThreadInterruptedException">  if current Thread is
        /// currently interrupted 
        /// 
        /// </exception>
        public virtual void Execute(Task task)
        {
            Execute(Spring.Threading.Execution.Executors.CreateRunnable(task));
        }
		
		/// <summary> 
		/// Specialized form of execute called only from within FJTasks
		/// </summary>
		public virtual void ExecuteTask (FJTask t)
		{
			try
			{
				entryQueue.Put(t);
			    SignalNewTask();
			}
			catch (System.Threading.ThreadInterruptedException)
			{
				ThreadClass.Current.Interrupt();
			}
		}
		

        class InvokableCandidateFJTask
        {
            IRunnable r;
            InvokableFJTask invokableFJTask = null;
            FJTaskRunnerGroup group;

            public InvokableCandidateFJTask (IRunnable r, FJTaskRunnerGroup group)
            {
                this.r = r;
                this.group = group;
            }

            public IRunnable Runnable
            {
                get
                {
                    return r;
                }
            }

            public FJTask AsInvokableFJTask (FJTaskRunner runner)
            {
                lock (group)
                {
                    if (invokableFJTask == null)
                    {
                        invokableFJTask = new InvokableFJTask(r, group);
                    }
                    return invokableFJTask;
                }
            }

            public void AwaitTermination ()
            {
                lock (group)
                {
                    while (invokableFJTask == null)
                    {
                        //TODO: ? System.Threading.Monitor.Wait(this);
                        System.Threading.Monitor.Wait(group);
                    }
                }
                invokableFJTask.AwaitTermination();
            }
        }
		
		/// <summary> Start a task and wait it out. Returns when the task completes.</summary>
		/// <exception cref="ThreadInterruptedException">  if current Thread is
		/// interrupted before completion of the task.
		/// </exception>		
		public virtual void  Invoke(IRunnable r)
		{
			InvokableCandidateFJTask w = new InvokableCandidateFJTask(r, this);
			entryQueue.Put(w);
		    SignalNewTask();
			w.AwaitTermination();
		}
		
		
		/// <summary> Try to shut down all FJTaskRunner threads in this group
		/// by interrupting them all. This method is designed
		/// to be used during cleanup when it is somehow known
		/// that all threads are idle.
		/// FJTaskRunners only
		/// check for interruption when they are not otherwise
		/// processing a task (and its generated subtasks,
		/// if any), so if any threads are active, shutdown may
		/// take a while, and may lead to unpredictable
		/// task processing.
		/// </summary>
		public virtual void  InterruptAll()
		{
			// paranoically interrupt current thread last if in group.
			ThreadClass current = ThreadClass.Current;
			bool stopCurrent = false;
			
			for (int i = 0; i < threads.Length; ++i)
			{
				ThreadClass t = threads[i];
				if (t == current)
					stopCurrent = true;
				else
					t.Interrupt();
			}
			if (stopCurrent)
				current.Interrupt();
		}
		
		
		
		/// <summary>
		/// Return the number of FJTaskRunner threads in this group
		/// </summary>		
		public virtual int Size()
		{
			return threads.Length;
		}
		
		/// <summary> Prints various snapshot statistics to System.out.
		/// <ul>
		/// <li> For each FJTaskRunner thread (labeled as T<em>n</em>, for
		/// <em>n</em> from zero to group size - 1):</li>
		/// <ul>
		/// <li> A star "*" is printed if the thread is currently active;
		/// that is, not sleeping while waiting for work. Because
		/// threads gradually enter sleep modes, an active thread
		/// may in fact be about to sleep (or wake up).</li>
		/// <li> <em>Q Cap</em> The current capacity of its task queue.</li>
		/// <li> <em>Run</em> The total number of tasks that have been run.</li>
		/// <li> <em>New</em> The number of these tasks that were
		/// taken from either the entry queue or from other 
		/// thread queues; that is, the number of tasks run
		/// that were <em>not</em> forked by the thread itself.</li>
		/// <li> <em>Scan</em> The number of times other task</li>
		/// queues or the entry queue were polled for tasks.
		/// </ul>
		/// <li> <em>Execute</em> The total number of tasks entered
		/// (but not necessarily yet run) via execute or invoke.</li>
		/// <li> <em>Time</em> Time in seconds since construction of this
		/// FJTaskRunnerGroup.</li>
		/// <li> <em>Rate</em> The total number of tasks processed
		/// per second across all threads. This
		/// may be useful as a simple throughput indicator
		/// if all processed tasks take approximately the
		/// same time to run.</li>
		/// </ul>
		/// <p>
		/// Cautions: Some statistics are updated and gathered 
		/// without synchronization,
		/// so may not be accurate. However, reported counts may be considered
		/// as lower bounds of actual values. 
		/// Some values may be zero if classes are compiled
		/// with COLLECT_STATS set to false. (FJTaskRunner and FJTaskRunnerGroup
		/// classes can be independently compiled with different values of
		/// COLLECT_STATS.) Also, the counts are maintained as ints so could
		/// overflow in exceptionally long-lived applications.
		/// </p>
		/// <p>
		/// These statistics can be useful when tuning algorithms or diagnosing
		/// problems. For example:
		/// </p>
		/// <ul>
		/// <li> High numbers of scans may mean that there is insufficient
		/// parallelism to keep threads busy. However, high scan rates
		/// are expected if the number
		/// of Executes is also high or there is a lot of global
		/// synchronization in the application, and the system is not otherwise
		/// busy. Threads may scan
		/// for work hundreds of times upon startup, shutdown, and
		/// global synch points of task sets.</li>
		/// <li> Large imbalances in tasks run across different threads might
		/// just reflect contention with unrelated threads on a system
		/// (possibly including JVM threads such as GC), but may also
		/// indicate some systematic bias in how you generate tasks.</li>
		/// <li> Large task queue capacities may mean that too many tasks are being
		/// generated before they can be run. 
		/// Capacities are reported rather than current numbers of tasks
		/// in queues because they are better indicators of the existence
		/// of these kinds of possibly-transient problems.
		/// Queue capacities are
		/// resized on demand from their initial value of 4096 elements,
		/// which is much more than sufficient for the kinds of 
		/// applications that this framework is intended to best support.</li>
		/// </ul>
		/// </summary>
		
		public virtual void  Stats(TextWriter writer)
		{
			long time = Utils.CurrentTimeMillis - initTime;
			//TODO: WARNING: Narrowing conversions may produce unexpected results in C#. 'ms-help://MS.VSCC.2003/commoner/redir/redirect.htm?keyword="jlca1042"'
			double secs = ((double) time) / 1000.0;
			long totalRuns = 0;
			long totalScans = 0;
			long totalSteals = 0;

		    writer.Write("Thread" + "\tQ Cap" + "\tScans" + "\tNew" + "\tRuns" + "\n");
			
			for (int i = 0; i < threads.Length; ++i)
			{
				FJTaskRunner t = threads[i];
				int truns = t.runs;
				totalRuns += truns;
				
				int tscans = t.scans;
				totalScans += tscans;
				
				int tsteals = t.steals;
				totalSteals += tsteals;
				
				System.String star = (GetActive(t))?"*":" ";
				
				
			    writer.Write("T" + i + star + "\t" + t.deqSize() + "\t" + tscans + "\t" + tsteals + "\t" + truns + "\n");
			}
			
		    writer.Write("Total" + "\t    " + "\t" + totalScans + "\t" + totalSteals + "\t" + totalRuns + "\n");
			
		    writer.Write("Execute: " + entries);
			
		    writer.Write("\tTime: " + secs);
			
			long rps = 0;
			if (secs != 0)
			{
				//TODO: WARNING: Narrowing conversions may produce unexpected results in C#. 'ms-help://MS.VSCC.2003/commoner/redir/redirect.htm?keyword="jlca1042"'
				rps = (long) System.Math.Round((double) (totalRuns) / secs);
			}
			
		    writer.WriteLine("\tRate: " + rps);
		}
		
		
		/* ------------ Methods called only by FJTaskRunners ------------- */
		
		
		/// <summary> Return a task from entry queue, or null if empty.
		/// Called only by FJTaskRunner.scan().
		/// 
		/// </summary>		
		protected internal virtual FJTask PollEntryQueue(FJTaskRunner runner)
		{
			try
			{
                object o = entryQueue.Poll(0);
                if (o is FJTask)
                {
                	return o as FJTask;
                }
                else if (o is InvokableCandidateFJTask)
                {
                    InvokableCandidateFJTask i = o as InvokableCandidateFJTask;
                    return i.AsInvokableFJTask(runner);
                }
                else if (o is IRunnable)
                {
                	return new FJTask.Wrap(o as IRunnable);
                }
                else if (o == null)
                {
                    return null;
                }
                else
                {
                    throw new ArgumentException("unexpected object in queue", o != null ? o.GetType().Name : "null");
                }
			}
			catch (System.Threading.ThreadInterruptedException)
			{
				// ignore interrupts
				ThreadClass.Current.Interrupt();
				return null;
			}
		}
		
		
		/// <summary> Return active status of t.
		/// Per-thread active status can only be accessed and
		/// modified via synchronized method here in the group class.
		/// 
		/// </summary>
		
		protected internal virtual bool GetActive(FJTaskRunner t)
		{
			lock (this)
			{
				return t.active;
			}
		}
		
		
		/// <summary> Set active status of thread t to true, and notify others
		/// that might be waiting for work. 
		/// 
		/// </summary>
		
		protected internal virtual void  SetActive(FJTaskRunner t)
		{
			lock (this)
			{
				if (!t.active)
				{
					t.active = true;
					++activeCount_;
					if (nstarted < threads.Length)
						threads[nstarted++].Start();
					else
						System.Threading.Monitor.PulseAll(this);
				}
			}
		}
		
		/// <summary> The number of times to scan other threads for tasks 
		/// before transitioning to a mode where scans are
		/// interleaved with sleeps (actually timed waits).
		/// Upon transition, sleeps are for duration of
		/// scans / SCANS_PER_SLEEP milliseconds.
		/// <p>
		/// This is not treated as a user-tunable parameter because
		/// good values do not appear to vary much across JVMs or
		/// applications. Its main role is to help avoid some
		/// useless spinning and contention during task startup.
        /// </p>
        /// </summary>
		internal const long ScansPerSleep = 15;
		
		/// <summary> The maximum time (in msecs) to sleep when a thread is idle,
		/// yet others are not, so may eventually generate work that
		/// the current thread can steal. This value reflects the maximum time
		/// that a thread may sleep when it possibly should not, because there
		/// are other active threads that might generate work. In practice,
		/// designs in which some threads become stalled because others
		/// are running yet not generating tasks are not likely to work
		/// well in this framework anyway, so the exact value does not matter
		/// too much. However, keeping it in the sub-second range does
		/// help smooth out startup and shutdown effects.
		/// 
		/// </summary>
		
		internal const long MaxSleepTime = 100;
		
		/// <summary> Set active status of thread t to false, and
		/// then wait until: (a) there is a task in the entry 
		/// queue, or (b) other threads are active, or (c) the current
		/// thread is interrupted. Upon return, it
		/// is not certain that there will be work available.
		/// The thread must itself check. 
		/// <p>
		/// The main underlying reason
		/// for these mechanics is that threads do not
		/// signal each other when they add elements to their queues.
		/// (This would add to task overhead, reduce locality.
		/// and increase contention.)
		/// So we must rely on a tamed form of polling. However, tasks
		/// inserted into the entry queue do result in signals, so
		/// tasks can wait on these if all of them are otherwise idle.
        /// </p>
        /// </summary>
		
		protected internal virtual void  CheckActive(FJTaskRunner t, long scans)
		{
			lock (this)
			{
				
				Inactive = t;
				
				try
				{
					// if nothing available, do a hard wait
					if (activeCount_ == 0 && entryQueue.Peek() == null)
					{
						System.Threading.Monitor.Wait(this);
					}
					else
					{
						// If there is possibly some work,
						// sleep for a while before rechecking 
						
						long msecs = scans / ScansPerSleep;
						if (msecs > MaxSleepTime)
							msecs = MaxSleepTime;
						int nsecs = (msecs == 0)?1:0; // forces shortest possible sleep
						System.Threading.Monitor.Wait(this, TimeSpan.FromMilliseconds(msecs + (nsecs / 1000)));
					}
				}
				catch (System.Threading.ThreadInterruptedException)
				{
					System.Threading.Monitor.Pulse(this); // avoid lost notifies on interrupts
					ThreadClass.Current.Interrupt();
				}
			}
		}
		
		/* ------------ Utility methods  ------------- */
		
		/// <summary> Start or wake up any threads waiting for work
		/// 
		/// </summary>
		
		protected internal virtual void  SignalNewTask()
		{
			lock (this)
			{
				if (CollectStats)
					++entries;
				if (nstarted < threads.Length)
					threads[nstarted++].Start();
				else
					System.Threading.Monitor.Pulse(this);
			}
		}
		
		/// <summary> Create all FJTaskRunner threads in this group.
		/// 
		/// </summary>
		
		protected internal virtual void  InitializeThreads()
		{
			for (int i = 0; i < threads.Length; ++i)
			{
			    threads[i] = FJTaskRunner.New(this);
			}
		}
		
		
		
		
		/// <summary> 
		/// Wrap wait/notify mechanics around a task so that
		/// invoke() can wait it out 
		/// </summary>
		protected internal sealed class InvokableFJTask:FJTask
		{
			readonly internal IRunnable wrapped;
		    private readonly FJTaskRunnerGroup group;
		    internal bool terminated = false;
			

            /// <summary>
            /// Creates a new <see cref="InvokableFJTask"/> instance.
            /// </summary>
            internal InvokableFJTask(IRunnable r, FJTaskRunnerGroup group)
			{
				wrapped = r;
			    this.group = group;
			}
			
            /// <summary>
            /// <see cref="IRunnable"/>
            /// </summary>
			public override void  Run()
			{
				try
				{
					if (wrapped is FJTask)
					{
					    FJTask.Invoke((FJTask) (wrapped));
					}
					else
					{
					    wrapped.Run();
					}
				}
				finally
				{
				    SetTerminated();
				}
			}
			
			internal void  SetTerminated()
			{
				lock (group)
				{
					terminated = true;
					//TODO: ? System.Threading.Monitor.PulseAll(this);
					System.Threading.Monitor.PulseAll(group);
				}
			}
			
			internal void  AwaitTermination()
			{
				lock (group)
				{
					while (!terminated)
						//TODO: ? System.Threading.Monitor.Wait(this);
						System.Threading.Monitor.Wait(group);
				}
			}
		}
	}
}