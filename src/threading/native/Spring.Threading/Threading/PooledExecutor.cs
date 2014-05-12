#region License
/*
* Copyright ?2002-2005 the original author or authors.
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
Originally written by Doug Lea and released into the public domain.
This may be used for any purposes whatsoever without acknowledgment.
Thanks for the assistance and support of Sun Microsystems Labs,
and everyone contributing, testing, and using this code.
*/
using System;
using System.Collections;
using System.Threading;
using Spring.Threading.Execution;

namespace Spring.Threading
{
	
    /// <summary> 
    /// A tunable, extensible thread pool class. The main supported public
    /// method are <see cref="Execute(IRunnable)"/> and
    /// <see cref="Execute(Spring.Threading.Task)"/>, which can be
    /// called instead of directly creating threads to execute commands.
    /// 
    /// <p>
    /// Please be aware that there exists a race condition when you use 
    /// the <see cref="WaitWhenBlocked_"/> policy with a pool size of 1.
    /// This condition will manifest itself if a <see cref="IRunnable"/>
    /// will throw any exception.
    /// </p>
    /// 
    /// <p>
    /// Thread pools can be useful for several, usually intertwined
    /// reasons:</p>
    /// 
    /// <list type="bullet">
    /// <item>
    ///  To bound resource use. A limit can be placed on the maximum
    /// number of simultaneously executing threads.
    /// </item>
    /// <item>
    /// To manage concurrency levels. A targeted number of threads
    /// can be allowed to execute simultaneously.
    /// </item>
    /// <item>
    /// To manage a set of threads performing related tasks.
    /// </item>
    /// <item>
    /// To minimize overhead, by reusing previously constructed
    /// Thread objects rather than creating new ones.  (Note however
    /// that pools are hardly ever cure-alls for performance problems
    /// associated with thread construction, especially on JVMs that
    /// themselves internally pool or recycle threads.)  
    /// </item>
    /// </list>
    /// <p>
    /// These goals introduce a number of policy parameters that are
    /// encapsulated in this class. All of these parameters have defaults
    /// and are tunable, either via get/set methods, or, in cases where
    /// decisions should hold across lifetimes, via methods that can be
    /// easily overridden in subclasses.  The main, most commonly set
    /// parameters can be established in constructors.  Policy choices
    /// across these dimensions can and do interact.  Be careful, and
    /// please read this documentation completely before using!  See also
    /// the usage examples below.
    /// </p>
    /// 
    /// <p>Queueing</p>
    /// 
    /// <p>By default, this pool uses queueless synchronous channels to
    /// to hand off work to threads. This is a safe, conservative policy
    /// that avoids lockups when handling sets of requests that might
    /// have internal dependencies. (In these cases, queuing one task
    /// could lock up another that would be able to continue if the
    /// queued task were to run.)  If you are sure that this cannot
    /// happen, then you can instead supply a queue of some sort (for
    /// example, a BoundedBuffer or LinkedQueue) in the constructor.
    /// This will cause new commands to be queued in cases where all
    /// MaximumPoolSize threads are busy. Queues are sometimes
    /// appropriate when each task is completely independent of others,
    /// so tasks cannot affect each others execution.  For example, in an
    /// http server.</p> 
    /// <p>
    /// When given a choice, this pool always prefers adding a new thread
    /// rather than queueing if there are currently fewer than the
    /// current getMinimumPoolSize threads running, but otherwise always
    /// prefers queuing a request rather than adding a new thread. Thus,
    /// if you use an unbounded buffer, you will never have more than
    /// getMinimumPoolSize threads running. (Since the default
    /// minimumPoolSize is one, you will probably want to explicitly
    /// setMinimumPoolSize.)</p>   
    /// <p>
    /// While queuing can be useful in smoothing out transient bursts of
    /// requests, especially in socket-based services, it is not very
    /// well behaved when commands continue to arrive on average faster
    /// than they can be processed.  Using bounds for both the queue and
    /// the pool size, along with run-when-blocked policy is often a
    /// reasonable response to such possibilities.  
    /// </p>
    /// 
    /// <p>
    /// Queue sizes and maximum pool sizes can often be traded off for
    /// each other. Using large queues and small pools minimizes CPU
    /// usage, OS resources, and context-switching overhead, but can lead
    /// to artifically low throughput. Especially if tasks frequently
    /// block (for example if they are I/O bound), a JVM and underlying
    /// OS may be able to schedule time for more threads than you
    /// otherwise allow. Use of small queues or queueless handoffs
    /// generally requires larger pool sizes, which keeps CPUs busier but
    /// may encounter unacceptable scheduling overhead, which also
    /// decreases throughput.  
    /// </p>
    /// 
    /// <p>Maximum Pool size</p>
    /// 
    /// <p> The maximum number of threads to use, when needed.  The pool
    /// does not by default preallocate threads.  Instead, a thread is
    /// created, if necessary and if there are fewer than the maximum,
    /// only when an <see cref="IExecutor.Execute(IRunnable)"/> or
    /// <see cref="IExecutor.Execute(Spring.Threading.Task)"/> request arrives.
    /// The default value is (for all practical purposes) infinite --
    /// <see cref="Int32.MaxValue"/>, so should be set in the
    /// constructor or the set method unless you are just using the pool
    /// to minimize construction overhead.  Because task handoffs to idle
    /// worker threads require synchronization that in turn relies on 
    /// scheduling policies to ensure progress, it is possible that a new
    /// thread will be created even though an existing worker thread has
    /// just become idle but has not progressed to the point at which it
    /// can accept a new task. 
    /// </p>
    /// 
    /// <p>Minimum Pool size</p>
    /// 
    /// <p>The minimum number of threads to use, when needed (default
    /// 1).  When a new request is received, and fewer than the minimum
    /// number of threads are running, a new thread is always created to
    /// handle the request even if other worker threads are idly waiting
    /// for work. Otherwise, a new thread is created only if there are
    /// fewer than the maximum and the request cannot immediately be
    /// queued.</p>
    /// 
    /// <p>Preallocation</p>
    /// 
    /// <p> You can override lazy thread construction policies via
    /// method <see cref="PooledExecutor.CreateThreads"/>, 
    /// which establishes a given number of warm
    /// threads. Be aware that these preallocated threads will time out
    /// and die (and later be replaced with others if needed) if not used
    /// within the keep-alive time window. If you use preallocation, you
    /// probably want to increase the keepalive time.  The difference
    /// between <see cref="PooledExecutor.MinimumPoolSize"/> and 
    /// <see cref="PooledExecutor.CreateThreads"/> is that
    /// <see cref="PooledExecutor.CreateThreads"/> immediately establishes threads, 
    /// while setting the
    /// minimum pool size waits until requests arrive.  
    /// </p>
    /// 
    /// <p>Keep-alive time</p>
    /// 
    /// <p>If the pool maintained references to a fixed set of threads
    /// in the pool, then it would impede garbage collection of otherwise
    /// idle threads. This would defeat the resource-management aspects
    /// of pools. One solution would be to use weak references.  However,
    /// this would impose costly and difficult synchronization issues.
    /// Instead, threads are simply allowed to terminate and thus be
    /// GCable if they have been idle for the given keep-alive time.  The
    /// value of this parameter represents a trade-off between GCability
    /// and construction time. The default keep-alive value is one minute, which
    /// means that the time needed to construct and then GC a thread is
    /// expended at most once per minute.  
    /// </p>
    /// <p> 
    /// To establish worker threads permanently, use a <em>negative</em>
    /// argument to <see cref="PooledExecutor.KeepAliveTime"/>.  </p>
    ///
    /// <p>Blocked execution policy</p>
    /// 
    /// <p> If the maximum pool size or queue size is bounded, then it
    /// is possible for incoming <c>execute</c> requests to
    /// block. There are four supported policies for handling this
    /// problem, and mechanics (based on the Strategy Object pattern) to
    /// allow others in subclasses: </p>
    /// 
    /// <list type="bullet">
    /// <item>
    /// <term> 
    /// Run (the default)
    /// </term>
    /// <description>
    /// The thread making the <c>execute</c> request
    /// runs the task itself. This policy helps guard against lockup. 
    /// </description> 
    /// </item>
    /// <item>
    /// <term> 
    /// Wait
    /// </term>
    /// <description>
    /// Wait until a thread becomes available.  This
    /// policy should, in general, not be used if the minimum number of
    /// of threads is zero, in which case a thread may never become
    /// available. It will cause a race condition when the pool size is 
    /// 1 (one) and the <see cref="IRunnable"/> throws any exception.
    /// </description> 
    /// </item>
    /// <item>
    /// <term> 
    /// Abort
    /// </term>
    /// <description>
    /// Throw a RuntimeException
    /// </description> 
    /// </item>
    /// <item>
    /// <term> 
    /// Discard 
    /// </term>
    /// <description>
    /// Throw away the current request and return.
    /// </description> 
    /// </item>
    /// <item>
    /// <term> 
    /// DiscardOldest
    /// </term>
    /// <description>
    /// Throw away the oldest request and return.
    /// </description> 
    /// </item>
    /// </list>
    /// 
    /// <p>
    /// Other plausible policies include raising the maximum pool size
    /// after checking with some other objects that this is OK.</p>
    /// 
    /// <p>
    /// These cases can never occur if the maximum pool size is unbounded
    /// or the queue is unbounded.  In these cases you instead face
    /// potential resource exhaustion.)  The execute method does not
    /// throw any checked exceptions in any of these cases since any
    /// errors associated with them must normally be dealt with via
    /// handlers or callbacks. (Although in some cases, these might be
    /// associated with throwing unchecked exceptions.)  You may wish to
    /// add special implementations even if you choose one of the listed
    /// policies. For example, the supplied Discard policy does not
    /// inform the caller of the drop. You could add your own version
    /// that does so.  Since choice of policies is normally a system-wide
    /// decision, selecting a policy affects all calls to
    /// <c>execute</c>.  If for some reason you would instead like
    /// to make per-call decisions, you could add variant versions of the
    /// <c>execute</c> method (for example,
    /// <c>executeIfWouldNotBlock</c>) in subclasses.
    /// </p>
    /// 
    /// <p>Thread construction parameters</p>
    /// 
    /// <p> A settable ThreadFactory establishes each new thread.  By
    /// default, it merely generates a new instance of class Thread, but
    /// can be changed to use a Thread subclass, to set priorities,
    /// ThreadLocals, etc.</p>
    /// 
    /// <p>Interruption policy</p>
    /// 
    /// <p> Worker threads check for interruption after processing each
    /// command, and terminate upon interruption.  Fresh threads will
    /// replace them if needed. Thus, new tasks will not start out in an
    /// interrupted state due to an uncleared interruption in a previous
    /// task. Also, unprocessed commands are never dropped upon
    /// interruption. It would conceptually suffice simply to clear
    /// interruption between tasks, but implementation characteristics of
    /// interruption-based methods are uncertain enough to warrant this
    /// conservative strategy. It is a good idea to be equally
    /// conservative in your code for the tasks running within pools.
    /// </p>
    /// 
    /// <p> Shutdown policy</p>
    /// 
    /// <p> The interruptAll method interrupts, but does not disable the
    /// pool. Two different shutdown methods are supported for use when
    /// you do want to (permanently) stop processing tasks. Method
    /// shutdownAfterProcessingCurrentlyQueuedTasks waits until all
    /// current tasks are finished. The shutDownNow method interrupts
    /// current threads and leaves other queued requests unprocessed.
    /// </p>
    /// 
    /// <p>Handling requests after shutdown</p>
    /// 
    /// <p> When the pool is shutdown, new incoming requests are handled
    /// by the blockedExecutionHandler. By default, the handler is set to
    /// discard new requests, but this can be set with an optional
    /// argument to method
    /// shutdownAfterProcessingCurrentlyQueuedTasks.
    /// </p>
    ///  <p> Also, if you are
    /// using some form of queuing, you may wish to call method drain()
    /// to remove (and return) unprocessed commands from the queue after
    /// shutting down the pool and its clients. If you need to be sure
    /// these commands are processed, you can then run() each of the
    /// commands in the list returned by drain().
    /// </p>
    /// 
    /// <p>Usage examples.</p>
    /// 
    /// Probably the most common use of pools is in statics or singletons
    /// accessible from a number of classes in a package; for example:
    /// 
    /// <code>
    /// class MyPool {
    /// // initialize to use a maximum of 8 threads.
    /// static PooledExecutor pool = new PooledExecutor(8);
    /// }
    /// </code>
    /// Here are some sample variants in initialization:
    /// <list type="number">
    /// <item> Using a bounded buffer of 10 tasks, at least 4 threads (started only
    /// when needed due to incoming requests), but allowing
    /// up to 100 threads if the buffer gets full.
    /// <code>
    /// pool = new PooledExecutor(new BoundedBuffer(10), 100);
    /// pool.MinimumPoolSize = 4;
    /// </code>
    /// </item>
    /// <item> Same as (1), except pre-start 9 threads, allowing them to
    /// die if they are not used for five minutes.
    /// <code>
    /// pool = new PooledExecutor(new BoundedBuffer(10), 100);
    /// pool.MinimumPoolSize = 4;
    /// pool.KeepAliveTime = 1000 * 60 * 5;
    /// pool.CreateThreads(9);
    /// </code>
    /// </item>
    /// <item> Same as (2) except clients abort if both the buffer is full and
    /// all 100 threads are busy:
    /// <code>
    /// pool = new PooledExecutor(new BoundedBuffer(10), 100);
    /// pool.MinimumPoolSize = 4;
    /// pool.KeepAliveTime = 1000 * 60 * 5;
    /// pool.AbortWhenBlocked();
    /// pool.CreateThreads(9);
    /// </code>
    /// </item>
    /// <item> An unbounded queue serviced by exactly 5 threads:
    /// <code>
    /// pool = new PooledExecutor(new LinkedQueue());
    /// pool.KeepAliveTime = -1; // live forever
    /// pool.CreateThreads(5);
    /// </code>
    /// </item>
    /// </list>
    /// 
    /// <p>Usage notes.</p>
    /// 
    /// <p>
    /// Pools do not mesh well with using thread-specific storage
    /// via <see cref="LocalDataStoreSlot"/>.
    /// <see cref="LocalDataStoreSlot"/> relies on the identity of a
    /// thread executing a particular task. Pools use the same thread to
    /// perform different tasks.  </p>
    /// <p>
    /// If you need a policy not handled by the parameters in this class
    /// consider writing a subclass.  </p>
    /// </summary>
	
    public class PooledExecutor:ThreadFactoryUser, IExecutor
    {
        /// <summary> Return the maximum number of threads to simultaneously execute
        /// New unqueued requests will be handled according to the current
        /// blocking policy once this limit is exceeded.
        /// 
        /// </summary>
        /// <summary> Set the maximum number of threads to use. Decreasing the pool
        /// size will not immediately kill existing threads, but they may
        /// later die when idle.
        /// </summary>
        /// <exception cref="ArgumentException">  if less or equal to zero.
        /// (It is
        /// not considered an error to set the maximum to be less than than
        /// the minimum. However, in this case there are no guarantees
        /// about behavior.)
        /// 
        /// </exception>
        virtual public int MaximumPoolSize
        {
            get
            {
                lock (this)
                {
                    return maximumPoolSize_;
                }
            }
			
            set
            {
                lock (this)
                {
                    if (value <= 0)
                        throw new ArgumentException();
                    maximumPoolSize_ = value;
                }
            }
			
        }
        /// <summary>The minimum number of threads to simultaneously execute.
        /// (Default value is <see cref="DEFAULT_MINIMUMPOOLSIZE"/>).  
        /// If fewer than the mininum number are
        /// running upon reception of a new request, a new thread is started
        /// to handle this request.
        /// </summary>
        virtual public int MinimumPoolSize
        {
            get
            {
                lock (this)
                {
                    return minimumPoolSize_;
                }
            }
			
            set
            {
                lock (this)
                {
                    if (value < 0)
                        throw new ArgumentException();
                    minimumPoolSize_ = value;
                }
            }
			
        }
        /// <summary> Return the current number of active threads in the pool.  This
        /// number is just a snaphot, and may change immediately upon
        /// returning
        /// 
        /// </summary>
        virtual public int PoolSize
        {
            get
            {
                lock (this)
                {
                    return poolSize_;
                }
            }
			
        }
        /// <summary> The number of milliseconds to keep threads alive waiting
        /// for new commands. A negative value means to wait forever. A zero
        /// value means not to wait at all.
        /// </summary>
        virtual public long KeepAliveTime
        {
            get
            {
                lock (this)
                {
                    return keepAliveTime_;
                }
            }
			
            set
            {
                lock (this)
                {
                    keepAliveTime_ = value;
                }
            }
			
        }
        /// <summary> Return true if a shutDown method has succeeded in terminating all
        /// threads.
        /// </summary>
        virtual public bool TerminatedAfterShutdown
        {
            get
            {
                lock (this)
                {
                    return shutdown_ && poolSize_ == 0;
                }
            }
			
        }
        /// <summary> Get a task from the handoff queue, or null if shutting down.
        /// 
        /// </summary>
        virtual protected internal IRunnable Task
        {
            get
            {
                long waitTime;
                lock (this)
                {
                    if (poolSize_ > maximumPoolSize_)
                        // Cause to die if too many threads
                        return null;
                    waitTime = (shutdown_)?0:keepAliveTime_;
                }
                if (waitTime >= 0)
                    return (IRunnable) (handOff_.Poll(waitTime));
                else
                    return (IRunnable) (handOff_.Take());
            }
			
        }
		
        /// <summary> The maximum pool size; used if not otherwise specified.  Default
        /// value is essentially infinite (<see cref="Int32.MaxValue"/>)
        /// 
        /// </summary>
        public static readonly int DefaultMaximumPoolSize = Int32.MaxValue;
		
        /// <summary> The minimum pool size; used if not otherwise specified.  Default
        /// value is 1.
        /// 
        /// </summary>
        public const int DEFAULT_MINIMUMPOOLSIZE = 1;
		
        /// <summary> The maximum time to keep worker threads alive waiting for new
        /// tasks; used if not otherwise specified. Default value is one
        /// minute (60000 milliseconds).
        /// 
        /// </summary>
        public const long DEFAULT_KEEPALIVETIME = 60 * 1000;
		
        /// <summary>The maximum number of threads allowed in pool. *</summary>
        protected internal int maximumPoolSize_ = DefaultMaximumPoolSize;
		
        /// <summary>The minumum number of threads to maintain in pool. *</summary>
        protected internal int minimumPoolSize_ = DEFAULT_MINIMUMPOOLSIZE;
		
        /// <summary>Current pool size.  *</summary>
        protected internal int poolSize_ = 0;
		
        /// <summary>The maximum time for an idle thread to wait for new task. *</summary>
        protected internal long keepAliveTime_ = DEFAULT_KEEPALIVETIME;
		
        /// <summary> Shutdown flag - latches true when a shutdown method is called 
        /// in order to disable queuing/handoffs of new tasks.
        /// 
        /// </summary>
        protected internal bool shutdown_ = false;
		
        /// <summary> The channel used to hand off the command to a thread in the pool.
        /// 
        /// </summary>
        protected internal readonly IChannel handOff_;
		
        /// <summary> The set of active threads, declared as a map from workers to
        /// their threads.  This is needed by the interruptAll method.  It
        /// may also be useful in subclasses that need to perform other
        /// thread management chores.
        /// 
        /// </summary>
        protected internal readonly IDictionary threads_;
		
        /// <summary>The current handler for unserviceable requests. *</summary>
        protected internal IBlockedExecutionHandler blockedExecutionHandler_;
		
        /// <summary> Create a new pool with all default settings
        /// 
        /// </summary>
		
        public PooledExecutor():this(new SynchronousChannel(), DefaultMaximumPoolSize)
        {
        }
		
        /// <summary> Create a new pool with all default settings except
        /// for maximum pool size.
        /// 
        /// </summary>
		
        public PooledExecutor(int maxPoolSize):this(new SynchronousChannel(), maxPoolSize)
        {
        }
		
        /// <summary> Create a new pool that uses the supplied Channel for queuing, and
        /// with all default parameter settings.
        /// 
        /// </summary>
		
        public PooledExecutor(IChannel channel):this(channel, DefaultMaximumPoolSize)
        {
        }
		
        /// <summary> Create a new pool that uses the supplied Channel for queuing, and
        /// with all default parameter settings except for maximum pool size.
        /// 
        /// </summary>
		
        public PooledExecutor(IChannel channel, int maxPoolSize)
        {
            maximumPoolSize_ = maxPoolSize;
            handOff_ = channel;
            RunWhenBlocked();
            threads_ = new Hashtable();
        }

        /// <summary>The handler for blocked execution *</summary>
        public virtual IBlockedExecutionHandler BlockedExecutionHandler
        {
            get
            {
                lock (this)
                {
                    return blockedExecutionHandler_;
                }
            }
            set
            {
                lock (this)
                {
                    blockedExecutionHandler_ = value;
                }
            }
        }
		
        /// <summary> Create and start a thread to handle a new command.  Call only
        /// when holding lock.
        /// </summary>
        protected internal virtual void  AddThread(IRunnable command)
        {
            Worker worker = new Worker(this, command);
            Thread thread = ThreadFactory.NewThread(worker);
            object tempObject;
            tempObject = thread;
            threads_[worker] = tempObject;
            ++poolSize_;
            thread.Start();
        }
		
        /// <summary> Create and start up to numberOfThreads threads in the pool.
        /// Return the number created. This may be less than the number
        /// requested if creating more would exceed maximum pool size bound.
        /// 
        /// </summary>
        public virtual int CreateThreads(int numberOfThreads)
        {
            int ncreated = 0;
            for (int i = 0; i < numberOfThreads; ++i)
            {
                lock (this)
                {
                    if (poolSize_ < maximumPoolSize_)
                    {
                        AddThread(null);
                        ++ncreated;
                    }
                    else
                        break;
                }
            }
            return ncreated;
        }
		
        /// <summary> Interrupt all threads in the pool, causing them all to
        /// terminate. Assuming that executed tasks do not disable (clear)
        /// interruptions, each thread will terminate after processing its
        /// current task. Threads will terminate sooner if the executed tasks
        /// themselves respond to interrupts.
        /// 
        /// </summary>
        public virtual void  InterruptAll()
        {
            lock (this)
            {
                foreach (Thread t in threads_.Values)
                {
                    t.Interrupt();
                }
            }
        }
		
        /// <summary> Interrupt all threads and disable construction of new
        /// threads. Any tasks entered after this point will be discarded. A
        /// shut down pool cannot be restarted.
        /// </summary>
        public virtual void  ShutdownNow()
        {
            ShutdownNow(new DiscardWhenBlocked_());
        }
		
        /// <summary> Interrupt all threads and disable construction of new
        /// threads. Any tasks entered after this point will be handled by
        /// the given BlockedExecutionHandler.  A shut down pool cannot be
        /// restarted.
        /// </summary>
        public virtual void  ShutdownNow(IBlockedExecutionHandler handler)
        {
            lock (this)
            {
                BlockedExecutionHandler = handler;
                shutdown_ = true; // don't allow new tasks
                minimumPoolSize_ = maximumPoolSize_ = 0; // don't make new threads
                InterruptAll(); // interrupt all existing threads
            }
        }
		
        /// <summary> Terminate threads after processing all elements currently in
        /// queue. Any tasks entered after this point will be discarded. A
        /// shut down pool cannot be restarted.
        /// 
        /// </summary>
        public virtual void  ShutdownAfterProcessingCurrentlyQueuedTasks()
        {
            ShutdownAfterProcessingCurrentlyQueuedTasks(new DiscardWhenBlocked_());
        }
		
        /// <summary> Terminate threads after processing all elements currently in
        /// queue. Any tasks entered after this point will be handled by the
        /// given BlockedExecutionHandler.  A shut down pool cannot be
        /// restarted.
        /// 
        /// </summary>
        public virtual void  ShutdownAfterProcessingCurrentlyQueuedTasks(IBlockedExecutionHandler handler)
        {
            lock (this)
            {
                BlockedExecutionHandler = handler;
                shutdown_ = true;
                if (poolSize_ == 0)
                    // disable new thread construction when idle
                    minimumPoolSize_ = maximumPoolSize_ = 0;
            }
        }
		
        /// <summary> Wait for a shutdown pool to fully terminate, or until the timeout
        /// has expired. This method may only be called <em>after</em>
        /// invoking shutdownNow or
        /// shutdownAfterProcessingCurrentlyQueuedTasks.
        /// 
        /// </summary>
        /// <param name="maxWaitTime"> the maximum time in milliseconds to wait
        /// </param>
        /// <returns> <c>true</c> if the pool has terminated within the max wait period
        /// </returns>
        /// <exception cref="InvalidOperationException"> if shutdown has not been requested
        /// </exception>
        /// <exception cref="ThreadInterruptedException"> if the current thread has been interrupted in the course of waiting
        /// </exception>
        public virtual bool AwaitTerminationAfterShutdown(long maxWaitTime)
        {
            lock (this)
            {
                if (!shutdown_)
                    throw new InvalidOperationException();
                if (poolSize_ == 0)
                    return true;
                long waitTime = maxWaitTime;
                if (waitTime <= 0)
                    return false;
                long start =  Utils.CurrentTimeMillis;
                for (; ; )
                {
                    Monitor.Wait(this, TimeSpan.FromMilliseconds(waitTime));
                    if (poolSize_ == 0)
                        return true;
                    waitTime = maxWaitTime - (Utils.CurrentTimeMillis - start);
                    if (waitTime <= 0)
                        return false;
                }
            }
        }
		
        /// <summary> Wait for a shutdown pool to fully terminate.  This method may
        /// only be called <em>after</em> invoking shutdownNow or
        /// shutdownAfterProcessingCurrentlyQueuedTasks.
        /// 
        /// </summary>
        /// <exception cref="InvalidOperationException"> if shutdown has not been requested
        /// </exception>
        /// <exception cref="ThreadInterruptedException"> if the current thread has been interrupted in the course of waiting
        /// </exception>
        public virtual void  AwaitTerminationAfterShutdown()
        {
            lock (this)
            {
                if (!shutdown_)
                    throw new InvalidOperationException();
                while (poolSize_ > 0)
                    Monitor.Wait(this);
            }
        }
		
        /// <summary> Remove all unprocessed tasks from pool queue, and return them in
        /// a <see cref="IList"/>. This method should be used only when there are
        /// not any active clients of the pool. Otherwise you face the
        /// possibility that the method will loop pulling out tasks as
        /// clients are putting them in.  This method can be useful after
        /// shutting down a pool (via shutdownNow) to determine whether there
        /// are any pending tasks that were not processed.  You can then, for
        /// example execute all unprocessed commands via code along the lines
        /// of:
        /// <code>
        /// List tasks = pool.Drain();
        /// foreach (IRunnable r in tasks) 
        ///     r.Run();
        /// </code>
        /// </summary>
        public virtual IList Drain()
        {
            bool wasInterrupted = false;
            ArrayList tasks = new ArrayList(10);
            for (; ; )
            {
                try
                {
                    Object x = handOff_.Poll(0);
                    if (x == null)
                        break;
                    else
                        tasks.Add(x);
                }
                catch (ThreadInterruptedException )
                {
                    wasInterrupted = true; // postpone re-interrupt until drained
                }
            }
            if (wasInterrupted)
                Thread.CurrentThread.Interrupt();
            return tasks;
        }
		
        /// <summary> Cleanup method called upon termination of worker thread.
        /// 
        /// </summary>
        protected internal virtual void  WorkerDone(Worker w)
        {
            lock (this)
            {
                threads_.Remove(w);
                if (--poolSize_ == 0 && shutdown_)
                {
                    maximumPoolSize_ = minimumPoolSize_ = 0; // disable new threads
                    Monitor.PulseAll(this); // notify awaitTerminationAfterShutdown
                }
				
                // Create a replacement if needed
                if (poolSize_ == 0 || poolSize_ < minimumPoolSize_)
                {
                    try
                    {
                        IRunnable r = (IRunnable) (handOff_.Poll(0));
                        if (r != null && !shutdown_)
                            // just consume task if shut down
                            AddThread(r);
                    }
                    catch (ThreadInterruptedException)
                    {
                        return ;
                    }
                }
            }
        }
		
		
        /// <summary> Class defining the basic run loop for pooled threads.
        /// 
        /// </summary>
        protected internal class Worker : IRunnable
        {
            private readonly PooledExecutor pooledExecutor;

            /// <summary>
            /// The first task to execute
            /// </summary>
            protected internal IRunnable firstTask_;
			
            /// <summary>
            /// <see cref="PooledExecutor"/> helper class
            /// </summary>
            /// <param name="executor">pooled executor</param>
            /// <param name="firstTask">the first task to execute</param>
            protected internal Worker(PooledExecutor executor, IRunnable firstTask)
            {
                this.pooledExecutor = executor;
                firstTask_ = firstTask;
            }
			
            /// <summary>
            /// <see cref="IRunnable.Run"/>
            /// </summary>
            public virtual void  Run()
            {
                try
                {
                    IRunnable task = firstTask_;
                    firstTask_ = null; // enable GC
					
                    if (task != null)
                    {
                        task.Run();
                        task = null;
                    }
					
                    while ((task = pooledExecutor.Task) != null)
                    {
                        task.Run();
                        task = null;
                    }
                }

                //TODO: thread interrupted, execution failed, error swallowed!? -K.X.
                catch (ThreadInterruptedException )
                {
                }
                    // fall through
                finally
                {
                    pooledExecutor.WorkerDone(this);
                }
            }
        }
		
        /// <summary> Class for actions to take when execute() blocks. Uses Strategy
        /// pattern to represent different actions. You can add more in
        /// subclasses, and/or create subclasses of these. If so, you will
        /// also want to add or modify the corresponding methods that set the
        /// current blockedExectionHandler_.
        /// 
        /// </summary>
        public interface IBlockedExecutionHandler
        {
            /// <summary> Return true if successfully handled so, execute should
            /// terminate; else return false if execute loop should be retried.
            /// 
            /// </summary>
            bool BlockedAction(IRunnable command);
        }
		
        /// <summary>Class defining Run action. *</summary>
        protected internal class RunWhenBlocked_ : IBlockedExecutionHandler
        {

            /// <summary>
            /// <see cref="IBlockedExecutionHandler.BlockedAction"/>
            /// </summary>
            /// <returns><c>true</c></returns>
            public virtual bool BlockedAction(IRunnable command)
            {
                command.Run();
                return true;
            }
        }
		
        /// <summary> Set the policy for blocked execution to be that the current
        /// thread executes the command if there are no available threads in
        /// the pool.
        /// 
        /// </summary>
        public virtual void  RunWhenBlocked()
        {
            BlockedExecutionHandler = new RunWhenBlocked_();
        }
		
        /// <summary>Class defining Wait action: don't use with a 
        /// pollsize of 1 and <see cref="IRunnable"/>s that can throws
        /// exceptions in ther <see cref="IRunnable.Run"/> method.
        /// </summary>
        protected internal class WaitWhenBlocked_ : IBlockedExecutionHandler
        {
            private PooledExecutor pooledExecutor;

            /// <summary>
            /// Creates new instance tied to the given <see cref="PooledExecutor"/>
            /// </summary>
            protected internal WaitWhenBlocked_(PooledExecutor executor)
            {
                this.pooledExecutor = executor;
            }

            /// <summary>
            /// <see cref="IBlockedExecutionHandler.BlockedAction"/>
            /// </summary>
            public virtual bool BlockedAction(IRunnable command)
            {
                lock (pooledExecutor)
                {
                    if (pooledExecutor.shutdown_)
                        return true;
                }
                pooledExecutor.handOff_.Put(command);
                return true;
            }
        }
		
        /// <summary> Set the policy for blocked execution to be to wait until a thread
        /// is available, unless the pool has been shut down, in which case
        /// the action is discarded.
        /// 
        /// </summary>
        public virtual void  WaitWhenBlocked()
        {
            BlockedExecutionHandler = new WaitWhenBlocked_(this);
        }
		
        /// <summary>Class defining Discard action. *</summary>
        protected internal class DiscardWhenBlocked_ : IBlockedExecutionHandler
        {
            /// <summary>
            /// <see cref="IBlockedExecutionHandler.BlockedAction"/>
            /// </summary>
            public virtual bool BlockedAction(IRunnable command)
            {
                return true;
            }
        }
		
        /// <summary> Set the policy for blocked execution to be to return without
        /// executing the request.
        /// 
        /// </summary>
        public virtual void  DiscardWhenBlocked()
        {
            BlockedExecutionHandler = new DiscardWhenBlocked_();
        }
		
		
        /// <summary>Class defining Abort action. *</summary>
        protected internal class AbortWhenBlocked_ : IBlockedExecutionHandler
        {
            /// <summary>
            /// <see cref="IBlockedExecutionHandler.BlockedAction"/>
            /// </summary>
            public virtual bool BlockedAction(IRunnable command)
            {
                throw new InvalidOperationException("Pool is blocked");
            }
        }
		
        /// <summary> Set the policy for blocked execution to be to
        /// throw a RuntimeException.
        /// 
        /// </summary>
        public virtual void  AbortWhenBlocked()
        {
            BlockedExecutionHandler = new AbortWhenBlocked_();
        }
		
		
        /// <summary> Class defining DiscardOldest action.  Under this policy, at most
        /// one old unhandled task is discarded.  If the new task can then be
        /// handed off, it is.  Otherwise, the new task is run in the current
        /// thread (i.e., RunWhenBlocked is used as a backup policy.)
        /// 
        /// </summary>
        protected internal class DiscardOldestWhenBlocked_ : IBlockedExecutionHandler
        {
            private PooledExecutor pooledExecutor;

            /// <summary>
            /// Creates a new instance
            /// </summary>
            protected internal  DiscardOldestWhenBlocked_(PooledExecutor executor)
            {
                this.pooledExecutor = executor;
            }

            /// <summary>
            /// <see cref="IBlockedExecutionHandler.BlockedAction"/>
            /// </summary>
            public virtual bool BlockedAction(IRunnable command)
            {
                pooledExecutor.handOff_.Poll(0);
                if (!pooledExecutor.handOff_.Offer(command, 0))
                    command.Run();
                return true;
            }
        }
		
        /// <summary> Set the policy for blocked execution to be to discard the oldest
        /// unhandled request
        /// 
        /// </summary>
        public virtual void  DiscardOldestWhenBlocked()
        {
            BlockedExecutionHandler = new DiscardOldestWhenBlocked_(this);
        }
		
        /// <summary> Arrange for the given command to be executed by a thread in this
        /// pool.  The method normally returns when the command has been
        /// handed off for (possibly later) execution.
        /// 
        /// </summary>
        public virtual void  Execute(IRunnable command)
        {
            for (; ; )
            {
                lock (this)
                {
                    if (!shutdown_)
                    {
                        int size = poolSize_;
						
                        // Ensure minimum number of threads
                        if (size < minimumPoolSize_)
                        {
                            AddThread(command);
                            return ;
                        }
						
                        // Try to give to existing thread
                        if (handOff_.Offer(command, 0))
                        {
                            return ;
                        }
						
                        // If cannot handoff and still under maximum, create new thread
                        if (size < maximumPoolSize_)
                        {
                            AddThread(command);
                            return ;
                        }
                    }
                }
				
                // Cannot hand off and cannot create -- ask for help
                if (BlockedExecutionHandler.BlockedAction(command))
                {
                    return ;
                }
            }
        }

        /// <summary>
        /// Arrange for the given <paramref name="task"/> to be executed by a 
        /// thread in this pool.  The method normally returns when the task 
        /// has been handed off for (possibly later) execution.
        /// </summary>
        /// <param name="task">The task to be executed.</param>
        public virtual void Execute(Task task)
        {
            Execute(Executors.CreateRunnable(task));
        }

    }
}