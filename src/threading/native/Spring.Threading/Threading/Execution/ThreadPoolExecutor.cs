using System;
using System.Collections.Generic;
using System.Security;
using System.Threading;
using Spring.Threading.AtomicTypes;
using Spring.Threading.Collections;
using Spring.Threading.Collections.Generic;
using Spring.Threading.Execution.ExecutionPolicy;
using Spring.Threading.Future;
using Spring.Threading.Locks;

namespace Spring.Threading.Execution
{
    /// <summary> An <see cref="Spring.Threading.Execution.IExecutorService"/> that executes each submitted task using
    /// one of possibly several pooled threads, normally configured
    /// using <see cref="Spring.Threading.Execution.Executors"/> factory methods.
    /// </summary> 
    /// <remarks>
    /// Thread pools address two different problems: they usually
    /// provide improved performance when executing large numbers of
    /// asynchronous tasks, due to reduced per-task invocation overhead,
    /// and they provide a means of bounding and managing the resources,
    /// including threads, consumed when executing a collection of tasks.
    /// Each <see cref="Spring.Threading.Execution.ThreadPoolExecutor"/> also maintains some basic
    /// statistics, such as the number of completed tasks.
    /// 
    /// <p/>
    /// To be useful across a wide range of contexts, this class
    /// provides many adjustable parameters and extensibility
    /// hooks. However, programmers are urged to use the more convenient
    /// <see cref="Spring.Threading.Execution.Executors"/> factory methods 
    /// <see cref="M:Spring.Threading.Execution.Executors.NewCachedThreadPool"/> ( unbounded thread pool, with
    /// automatic thread reclamation), <see cref="Executors.NewFixedThreadPool(int)"/> or <see cref="Executors.NewFixedThreadPool(int, IThreadFactory )"/>
    /// (fixed size thread pool) and <see cref="M:Spring.Threading.Execution.Executors.NewSingleThreadExecutor"/>
    /// single background thread), that preconfigure settings for the most common usage
    /// scenarios. Otherwise, use the following guide when manually
    /// configuring and tuning this class:
    /// 
    /// <dl>
    ///		<dt>Core and maximum pool sizes</dt>
    /// 	<dd>
    ///         A <see cref="ThreadPoolExecutor"/> will automatically adjust the
    ///         pool size (<see cref="PoolSize"/>)
    ///         according to the bounds set by
    ///         Core Pool Size (<see cref="CorePoolSize"/>) and
    ///         Maximum Pool Size (<see cref="MaximumPoolSize"/>)
    /// 		
    ///			When a new task is submitted in method
    /// 		<see cref="Spring.Threading.Execution.ThreadPoolExecutor.Execute"/>, 
    /// 		and fewer than <see cref="Spring.Threading.Execution.ThreadPoolExecutor.CorePoolSize"/> threads
    /// 		are running, a new thread is created to handle the request, even if
    /// 		other worker threads are idle.  If there are more than
    /// 		<see cref="Spring.Threading.Execution.ThreadPoolExecutor.CorePoolSize"/>
    /// 		but less than <see cref="Spring.Threading.Execution.ThreadPoolExecutor.MaximumPoolSize"/>
    /// 		threads running, a new thread will be created only if the queue is full.  By setting
    /// 		core pool size and maximum pool size the same, you create a fixed-size
    /// 		thread pool. By setting maximum pool size to an essentially unbounded
    /// 		value such as <see cref="System.Int32.MaxValue"/>, you allow the pool to
    /// 		accommodate an arbitrary number of concurrent tasks. Most typically,
    /// 		core and maximum pool sizes are set only upon construction, but they
    /// 		may also be changed dynamically using 
    /// 		<see cref="Spring.Threading.Execution.ThreadPoolExecutor.CorePoolSize"/> and
    /// 		<see cref="Spring.Threading.Execution.ThreadPoolExecutor.MaximumPoolSize"/>.
    /// 	</dd>
    /// 
    ///		<dt>On-demand construction</dt>
    ///		<dd> 
    ///			By default, even core threads are initially created and
    /// 		started only when new tasks arrive, but this can be overridden
    /// 		dynamically using method
    /// 		<see cref="PreStartCoreThread"/> or
    /// 		<see cref="Spring.Threading.Execution.ThreadPoolExecutor.PreStartAllCoreThreads()"/>.
    /// 		You probably want to prestart threads if you construct the
    /// 		pool with a non-empty queue. 
    /// 	</dd>
    /// 
    ///		<dt>Creating new threads</dt>
    /// 	<dd>
    /// 		New threads are created using a <see cref="Spring.Threading.IThreadFactory"/>.
    /// 		If not otherwise specified, a  <see cref="Spring.Threading.Execution.Executors.DefaultThreadFactory"/> is used, 
    /// 		that creates threads to all with the same <see cref="System.Threading.ThreadPriority"/> set to 
    /// 		<see cref="System.Threading.ThreadPriority.Normal"/>
    /// 		priority and non-daemon status. By supplying
    /// 		a different <see cref="Spring.Threading.IThreadFactory"/>, you can alter the thread's name,
    /// 		priority, daemon status, etc. If a <see cref="Spring.Threading.IThreadFactory"/> fails to create
    /// 		a thread when asked by returning null from <see cref="Spring.Threading.IThreadFactory.NewThread(IRunnable)"/>,
    /// 		the executor will continue, but might not be able to execute any tasks. 
    /// 	</dd>
    /// 
    ///		<dt>Keep-alive times</dt>
    /// 	<dd>
    /// 		If the pool currently has more than <see cref="Spring.Threading.Execution.ThreadPoolExecutor.CorePoolSize"/> threads,
    /// 		excess threads will be terminated if they have been idle for more
    /// 		than the <see cref="Spring.Threading.Execution.ThreadPoolExecutor.KeepAliveTime"/>.
    /// 		This provides a means of reducing resource consumption when the pool is not being actively
    /// 		used. If the pool becomes more active later, new threads will be
    /// 		constructed. This parameter can also be changed dynamically using
    /// 		method <see cref="Spring.Threading.Execution.ThreadPoolExecutor.KeepAliveTime"/>. Using a value
    /// 		of <see cref="System.Int32.MaxValue"/> effectively
    /// 		disables idle threads from ever terminating prior to shut down. By
    /// 		default, the keep-alive policy applies only when there are more
    /// 		than <see cref="Spring.Threading.Execution.ThreadPoolExecutor.CorePoolSize"/> Threads. But method {@link
    /// 		<see cref="Spring.Threading.Execution.ThreadPoolExecutor.AllowsCoreThreadsToTimeOut"/> can be used to apply
    /// 		this time-out policy to core threads as well, so long as
    /// 		the <see cref="Spring.Threading.Execution.ThreadPoolExecutor.KeepAliveTime"/> value is non-zero. 
    /// 	</dd>
    /// 
    ///		<dt>Queuing</dt>
    ///		<dd>
    ///			Any <see cref="IBlockingQueue{T}"/> may be used to transfer and hold
    ///			submitted tasks.  The use of this queue interacts with pool sizing:
    /// 
    ///			<ul>
    /// 			<li> 
    /// 				If fewer than <see cref="Spring.Threading.Execution.ThreadPoolExecutor.CorePoolSize"/>
    /// 				threads are running, the Executor always prefers adding a new thread
    /// 				rather than queuing.
    /// 			</li>
    ///				<li> 
    ///					If <see cref="Spring.Threading.Execution.ThreadPoolExecutor.CorePoolSize"/>
    ///					or more threads are running, the Executor always prefers queuing a request rather than adding a new
    ///					thread.
    ///				</li>
    ///				<li> 
    ///					If a request cannot be queued, a new thread is created unless
    ///					this would exceed <see cref="Spring.Threading.Execution.ThreadPoolExecutor.MaximumPoolSize"/>, 
    ///					in which case, the task will be rejected.
    /// 			</li>
    ///			</ul>
    /// 
    ///			There are three general strategies for queuing:
    /// 
    ///			<ol>
    ///				<li> 
    ///					<i> Direct handoffs.</i> A good default choice for a work
    ///					queue is a <see cref="SynchronousQueue{T}"/> 
    ///					that hands off tasks to threads without otherwise holding them. Here, an attempt to queue a task
    /// 				will fail if no threads are immediately available to run it, so a
    /// 				new thread will be constructed. This policy avoids lockups when
    /// 				handling sets of requests that might have internal dependencies.
    /// 				Direct handoffs generally require unbounded 
    /// 				<see cref="Spring.Threading.Execution.ThreadPoolExecutor.MaximumPoolSize"/>
    /// 				to avoid rejection of new submitted tasks. This in turn admits the
    /// 				possibility of unbounded thread growth when commands continue to
    /// 				arrive on average faster than they can be processed.  
    /// 			</li>
    ///				<li>
    ///					<i>Unbounded queues.</i> Using an unbounded queue (for
    ///					example a <see cref="LinkedBlockingQueue{T}"/> without a predefined
    /// 				capacity) will cause new tasks to wait in the queue when all
    /// 				<see cref="Spring.Threading.Execution.ThreadPoolExecutor.CorePoolSize"/>
    /// 				threads are busy. Thus, no more than <see cref="Spring.Threading.Execution.ThreadPoolExecutor.CorePoolSize"/>
    /// 				threads will ever be created. (And the value of the 
    /// 				<see cref="Spring.Threading.Execution.ThreadPoolExecutor.MaximumPoolSize"/>
    /// 				therefore doesn't have any effect.)  This may be appropriate when
    /// 				each task is completely independent of others, so tasks cannot
    /// 				affect each others execution; for example, in a web page server.
    /// 				While this style of queuing can be useful in smoothing out
    /// 				transient bursts of requests, it admits the possibility of
    /// 				unbounded work queue growth when commands continue to arrive on
    /// 				average faster than they can be processed.  
    /// 			</li>
    ///				<li>
    ///					<i>Bounded queues.</i> A bounded queue (for example, an
    ///					<see cref="ArrayBlockingQueue{T}"/>) helps prevent resource exhaustion when
    /// 				used with finite <see cref="Spring.Threading.Execution.ThreadPoolExecutor.MaximumPoolSize"/>, 
    /// 				but can be more difficult to tune and control.  Queue sizes and maximum pool sizes may be traded
    /// 				off for each other: Using large queues and small pools minimizes
    /// 				CPU usage, OS resources, and context-switching overhead, but can
    /// 				lead to artificially low throughput.  If tasks frequently block (for
    /// 				example if they are I/O bound), a system may be able to schedule
    /// 				time for more threads than you otherwise allow. Use of small queues
    /// 				generally requires larger pool sizes, which keeps CPUs busier but
    /// 				may encounter unacceptable scheduling overhead, which also
    /// 				decreases throughput.  
    /// 			</li>
    ///			</ol>
    ///		</dd>
    /// 
    ///		<dt>Rejected tasks</dt>
    ///		<dd> 
    ///			New tasks submitted in method <see cref="Spring.Threading.Execution.ThreadPoolExecutor.Execute"/>
    ///			will be <i>rejected</i> when the Executor has been shut down, and also when the Executor uses finite
    /// 		bounds for both maximum threads and work queue capacity, and is
    /// 		saturated.  In either case, the <see cref="Spring.Threading.Execution.ThreadPoolExecutor.Execute"/> method invokes the
    /// 		<see cref="IRejectedExecutionHandler.RejectedExecution"/> method of its
    /// 		<see cref="IRejectedExecutionHandler"/>.  Four predefined handler policies
    /// 		are provided:
    /// 		
    ///			<ol>
    ///				<li> 
    ///					In the default <see cref="Spring.Threading.Execution.ExecutionPolicy.AbortPolicy"/>, the handler throws a
    ///					runtime <see cref="Spring.Threading.Execution.RejectedExecutionException"/> upon rejection. 
    ///				</li>
    ///				<li> 
    ///					In <see cref="CallerRunsPolicy"/>, the thread that invokes
    ///					<see cref="Spring.Threading.Execution.ThreadPoolExecutor.Execute"/> itself runs the task. This provides a simple
    /// 				feedback control mechanism that will slow down the rate that new tasks are submitted. 
    /// 			</li>
    ///				<li> 
    ///					In <see cref="Spring.Threading.Execution.ExecutionPolicy.DiscardPolicy"/>,
    ///					a task that cannot be executed is simply dropped.
    ///				</li>
    ///				<li>
    ///					In <see cref="Spring.Threading.Execution.ExecutionPolicy.DiscardOldestPolicy"/>, if the executor is not
    ///					shut down, the task at the head of the work queue is dropped, and
    /// 				then execution is retried (which can fail again, causing this to be
    /// 				repeated.) 
    /// 			</li>
    ///			</ol>
    ///			It is possible to define and use other kinds of
    /// 		<see cref="IRejectedExecutionHandler"/> classes. Doing so requires some care
    /// 		especially when policies are designed to work only under particular
    /// 		capacity or queuing policies. 
    ///		</dd>
    /// 
    ///		<dt>Hook methods</dt>
    /// 	<dd>
    /// 		This class provides <i>protected</i> overridable <see cref="Spring.Threading.Execution.ThreadPoolExecutor.beforeExecute(Thread, IRunnable)"/>
    /// 		and <see cref="Spring.Threading.Execution.ThreadPoolExecutor.afterExecute(IRunnable, Exception)"/> methods that are called before and
    ///			after execution of each task.  These can be used to manipulate the
    /// 		execution environment; for example, reinitializing ThreadLocals,
    /// 		gathering statistics, or adding log entries. Additionally, method
    /// 		<see cref="Spring.Threading.Execution.ThreadPoolExecutor.terminated()"/> can be overridden to perform
    /// 		any special processing that needs to be done once the Executor has
    /// 		fully terminated.
    /// 
    ///			<p/>
    ///			If hook or callback methods throw exceptions, internal worker threads may in turn fail and
    ///			abruptly terminate.
    ///		</dd>
    /// 
    ///		<dt>Queue maintenance</dt>
    ///		<dd> 
    ///			Method <see cref="Spring.Threading.Execution.ThreadPoolExecutor.Queue"/> allows access to
    /// 		the work queue for purposes of monitoring and debugging.  Use of
    ///			this method for any other purpose is <em>strongly</em> discouraged. 
    /// 	</dd> a
    /// 
    ///     <dt>Finalization</dt>
    ///     <dd> A pool that is no longer referenced in a program <em>AND</em>
    ///         has no remaining threads will be <see cref="Shutdown"/> automatically. If
    ///         you would like to ensure that unreferenced pools are reclaimed even
    ///         if users forget to call <see cref="Shutdown"/>, then you must arrange
    ///         that unused threads eventually die, by setting appropriate
    ///         keep-alive times, using a lower bound of zero core threads and/or
    ///         setting <see cref="AllowsCoreThreadsToTimeOut"/>.
    ///     </dd>
    /// </dl>
    /// 
    /// <p/>
    /// <b>Extension example</b>. Most extensions of this class
    /// override one or more of the protected hook methods. For example,
    /// here is a subclass that adds a simple pause/resume feature:
    /// 
    /// <code>
    ///		public class PausableThreadPoolExecutor : ThreadPoolExecutor {
    ///			private boolean _isPaused;
    /// 		private ReentrantLock _pauseLock = new ReentrantLock();
    /// 		private ICondition _unpaused = pauseLock.NewCondition();
    /// 
    /// 		public PausableThreadPoolExecutor(...) : base( ... ) { }
    /// 
    /// 		protected override void beforeExecute(Thread t, IRunnable r) {
    /// 				base.beforeExecute(t, r);
    /// 				_pauseLock.Lock();
    /// 				try {
    /// 					while (_isPaused) _unpaused.Await();
    /// 				} catch (ThreadInterruptedException ie) {
    ///						t.Interrupt();
    /// 				} finally {
    ///						_pauseLock.Unlock();
    ///					}
    ///			}
    /// 
    ///			public void Pause() {
    /// 			_pauseLock.Lock();
    /// 			try {
    /// 				_isPaused = true;
    ///				} finally {
    ///					_pauseLock.Unlock();
    ///				}
    ///			}
    /// 
    ///			public void Resume() {
    ///				_pauseLock.Lock();
    ///				try {
    ///					_isPaused = false;
    /// 				_unpaused.SignalAll();
    /// 			} finally {
    /// 				_pauseLock.Unlock();
    /// 			}
    /// 		}
    /// 	}
    /// </code>
    /// </remarks>
    /// <author>Doug Lea</author>
    /// <author>Griffin Caprio (.NET)</author>
    public class ThreadPoolExecutor : AbstractExecutorService, IDisposable
    {
        #region Worker Class

        /// <summary>
        /// Class Worker mainly maintains interrupt control state for
        /// threads running tasks, along with other minor bookkeeping. This
        /// class opportunistically extends ReentrantLock to simplify
        /// acquiring and releasing a lock surrounding each task execution.
        /// This protects against interrupts that are intended to wake up a
        /// worker thread waiting for a task from instead interrupting a
        /// task being run.
        /// </summary>
        protected internal class Worker : ReentrantLock, IRunnable
        {
            private readonly ThreadPoolExecutor _parentThreadPoolExecutor;

            /// <summary> 
            /// Per thread completed task counter; accumulated
            /// into completedTaskCount upon termination.
            /// </summary>
            protected internal volatile int CompletedTasks;

            /// <summary> 
            /// Initial task to run before entering run loop
            /// </summary>
            protected internal IRunnable FirstTask;

            /// <summary> 
            /// Thread this worker is running in.  Acts as a final field,
            /// but cannot be set until thread is created.
            /// </summary>
            protected internal Thread Thread;

            /// <summary>
            /// Default Constructor
            /// </summary>
            /// <param name="firstTask">Task to run before entering run loop.</param>
            /// <param name="parentThreadPoolExecutor"><see cref="Spring.Threading.Execution.ThreadPoolExecutor"/> that controls this worker</param>
            internal Worker(ThreadPoolExecutor parentThreadPoolExecutor, IRunnable firstTask)
            {
                FirstTask = firstTask;
                _parentThreadPoolExecutor = parentThreadPoolExecutor;
                Thread = parentThreadPoolExecutor.ThreadFactory.NewThread(this);
            }

            #region IRunnable Members

            /// <summary>
            /// Runs the associated task, signalling the <see cref="Spring.Threading.Execution.ThreadPoolExecutor"/> when exiting.
            /// </summary>
            public void Run()
            {
                // TODO: Not ideal.  
                _parentThreadPoolExecutor.runWorker(this);
            }

            #endregion
        }

        #endregion

        #region Private Fields

        /// <summary>
        /// The main pool control state, controlState, is an <see cref="AtomicInteger"/> packing
        /// two conceptual fields
        ///   workerCount, indicating the effective number of threads
        ///   runState,    indicating whether running, shutting down etc
        ///
        /// In order to pack them into one int, we limit workerCount to
        /// (2^29)-1 (about 500 million) threads rather than (2^31)-1 (2
        /// billion) otherwise representable. If this is ever an issue in
        /// the future, the variable can be changed to be an <see cref="AtomicLong"/>,
        /// and the shift/mask constants below adjusted. But until the need
        /// arises, this code is a bit faster and simpler using an <see cref="Int32"/>.
        ///
        /// The workerCount is the number of workers that have been
        /// permitted to start and not permitted to stop.  The value may be
        /// transiently different from the actual number of live threads,
        /// for example when a <see cref="IThreadFactory"/> fails to create a thread when
        /// asked, and when exiting threads are still performing
        /// bookkeeping before terminating. The user-visible pool size is
        /// reported as the current size of the workers set.
        ///
        /// The runState provides the main lifecyle control, taking on values:
        ///
        ///   Running:  Accept new tasks and process queued tasks
        ///   SHUTDOWN: Don't accept new tasks, but process queued tasks
        ///   Stop:     Don't accept new tasks, don't process queued tasks,
        ///             and interrupt in-progress tasks
        ///   TIDYING:  All tasks have terminated, workerCount is zero,
        ///             the thread transitioning to state TIDYING
        ///             will run the <see cref="terminated"/> hook method
        ///   TERMINATED: <see cref="terminated"/> has completed
        ///
        /// The numerical order among these values matters, to allow
        /// ordered comparisons. The runState monotonically increases over
        /// time, but need not hit each state. The transitions are:
        ///
        /// Running -> SHUTDOWN
        ///    On invocation of <see cref="Shutdown"/>, perhaps implicitly in ~ThreadPoolExecutor
        /// (Running or SHUTDOWN) -> Stop
        ///    On invocation of <see cref="ShutdownNow"/>
        /// SHUTDOWN -> TIDYING
        ///    When both queue and pool are empty
        /// Stop -> TIDYING
        ///    When pool is empty
        /// TIDYING -> TERMINATED
        ///    When the <see cref="terminated"/> hook method has completed
        ///
        /// Threads waiting in <see cref="AwaitTermination"/> will return when the
        /// state reaches TERMINATED.
        ///
        /// Detecting the transition from SHUTDOWN to TIDYING is less
        /// straightforward than you'd like because the queue may become
        /// empty after non-empty and vice versa during SHUTDOWN state, but
        /// we can only terminate if, after seeing that it is empty, we see
        /// that workerCount is 0 (which sometimes entails a recheck -- see
        /// below).
        /// </summary>
        private readonly AtomicInteger _controlState = new AtomicInteger(ctlOf(RUNNING, 0));
        private const int COUNT_BITS = 29;
        private const int CAPACITY = (1 << COUNT_BITS) - 1;

        /// <summary>
        /// runState is stored in the high-order bits 
        /// </summary>
        private const int RUNNING = -1 << COUNT_BITS;
        private const int SHUTDOWN = 0 << COUNT_BITS;
        private const int STOP = 1 << COUNT_BITS;
        private const int TERMINATED = 3 << COUNT_BITS;
        private const int TIDYING = 2 << COUNT_BITS;

        /// <summary> 
        /// If <see lang="false"/> ( the default), core threads stay alive even when idle.
        /// If <see lang="true"/>, core threads use <see cref="Spring.Threading.Execution.ThreadPoolExecutor.KeepAliveTime"/> 
        /// to time out waiting for work.
        /// </summary>
        private bool _allowCoreThreadToTimeOut;

        /// <summary> 
        /// Set containing all worker threads in pool. Accessed only when holding mainLock.
        /// </summary>
        private readonly IList<Worker> _currentWorkerThreads = new List<Worker>();

        /// <summary> 
        /// Lock held on access to workers set and related bookkeeping.
        /// While we could use a concurrent set of some sort, it turns out
        /// to be generally preferable to use a lock. Among the reasons is
        /// that this serializes interruptIdleWorkers, which avoids
        /// unnecessary interrupt storms, especially during shutdown.
        /// Otherwise exiting threads would concurrently interrupt those
        /// that have not yet interrupted. It also simplifies some of the
        /// associated statistics bookkeeping of largestPoolSize etc. We
        /// also hold mainLock on shutdown and shutdownNow, for the sake of
        /// ensuring workers set is stable while separately checking
        /// permission to interrupt and actually interrupting.
        /// </summary>
        private readonly ReentrantLock _mainLock = new ReentrantLock();

        /// <summary> 
        /// The queue used for holding tasks and handing off to worker
        /// threads.  We do not require that workQueue.poll() returning
        /// null necessarily means that workQueue.isEmpty(), so rely
        /// solely on isEmpty to see if the queue is empty (which we must
        /// do for example when deciding whether to transition from
        /// SHUTDOWN to TIDYING).  This accommodates special-purpose
        /// queues such as DelayQueues for which poll() is allowed to
        /// return null even if it may later return non-null when delays
        /// expire.
        /// </summary>
        private readonly IBlockingQueue<IRunnable> _workQueue;

        /// <summary>
        /// Wait condition to support AwaitTermination
        /// </summary>
        private readonly ICondition termination;

        /// <summary> 
        /// Counter for completed tasks. Updated only on termination of
        /// worker threads.  Accessed only under mainlock
        /// </summary>
        private long _completedTaskCount;

        /// <summary> 
        /// Tracks largest attained pool size. Accessed only under mainLock.
        /// </summary>
        private int _largestPoolSize;

        #region User Control Params

        /// <summary> 
        /// The default <see cref="Spring.Threading.Execution.IRejectedExecutionHandler"/>
        /// </summary>
        private static readonly IRejectedExecutionHandler _defaultRejectedExecutionHandler = new AbortPolicy();

        /// All user control parameters are declared as volatiles so that
        /// ongoing actions are based on freshest values, but without need
        /// for locking, since no internal invariants depend on them
        /// changing synchronously with respect to other actions.
        /// <summary> 
        /// Core pool size is the minimum number of workers to keep alive
        /// (and not allow to time out etc) unless _allowCoreThreadTimeOut
        /// is set, in which case the minimum is zero.
        /// </summary>
        private volatile int _corePoolSize;

        /// <summary> 
        /// Timeout for idle threads waiting for work.
        /// Threads use this timeout when there are more than _corePoolSize
        /// present or if _allowCoreThreadTimeOut. Otherwise they wait
        /// forever for new work.
        /// </summary>
        private TimeSpan _keepAliveTime;

        /// <summary> 
        /// Maximum pool size. Note that the actual maximum is internally
        ///  bounded by CAPACITY.
        /// </summary>
        private volatile int _maximumPoolSize;

        /// <summary> 
        /// <see cref="Spring.Threading.Execution.IRejectedExecutionHandler"/> called when
        /// <see cref="Spring.Threading.Execution.ThreadPoolExecutor"/> is saturated or  
        /// <see cref="Spring.Threading.Execution.ThreadPoolExecutor.Shutdown()"/> in executed.
        /// </summary>
        private volatile IRejectedExecutionHandler _rejectedExecutionHandler;

        /// <summary> 
        /// Factory for new threads. All threads are created using this
        /// factory (via method AddWorker).  All callers must be prepared
        /// for AddWorker to fail, which may reflect a system or user's
        /// policy limiting the number of threads.  Even though it is not
        /// treated as an error, failure to create threads may result in
        /// new tasks being rejected or existing ones remaining stuck in
        /// the queue. On the other hand, no special precautions exist to
        /// handle OutOfMemoryErrors that might be thrown while trying to
        /// create threads, since there is generally no recourse from
        /// within this class.
        /// </summary>
        private volatile IThreadFactory _threadFactory;

        #endregion

        #region Control State Packing & Unpacking Functions
        private static int runStateOf(int c)
        {
            return c & ~CAPACITY;
        }

        private static int workerCountOf(int c)
        {
            return c & CAPACITY;
        }

        private static int ctlOf(int rs, int wc)
        {
            return rs | wc;
        }
        #endregion

        #region Control State Query Methods
        /// <summary>
        /// Bit field accessors that don't require unpacking _controlState.
        /// These depend on the bit layout and on workerCount being never negative.
        /// </summary>
        private static bool runStateLessThan(int c, int s)
        {
            return c < s;
        }

        private static bool runStateAtLeast(int c, int s)
        {
            return c >= s;
        }

        private static bool isRunning(int c)
        {
            return c < SHUTDOWN;
        }
        #endregion

        #endregion

        #region Public Properties

        /// <summary> 
        /// Gets / Sets the time limit for which threads may remain idle before
        /// being terminated.  
        /// </summary>
        /// <remarks>
        /// If there are more than the core number of
        /// threads currently in the pool, after waiting this amount of
        /// time without processing a task, excess threads will be
        /// terminated.
        /// </remarks>
        /// <exception cref="System.ArgumentException">
        /// if <i>value</i> is less than 0 or if <i>value</i> equals 0 and 
        /// <see cref="AllowsCoreThreadsToTimeOut"/> is 
        /// <see lang="true"/>
        /// </exception>
        public TimeSpan KeepAliveTime
        {
            set
            {
                if (value.Ticks < 0)
                {
                    throw new ArgumentException("Keep alive time must be greater than 0.");
                }
                if (value.Ticks == 0 && AllowsCoreThreadsToTimeOut)
                {
                    throw new ArgumentException("Core threads must have nonzero keep alive times");
                }
                TimeSpan delta = value - _keepAliveTime;
                _keepAliveTime = value;
                if (delta.Ticks < 0)
                    interruptIdleWorkers();
            }
            get { return _keepAliveTime; }
        }

        /// <summary>
        /// Returns <see lang="true"/> if this pool allows core threads to time out and
        /// terminate if no tasks arrive within the keepAlive time, being
        /// replaced if needed when new tasks arrive. 
        /// </summary>
        /// <remarks>
        /// When true, the same keep-alive policy applying to non-core threads applies also to
        /// core threads. When false (the default), core threads are never
        /// terminated due to lack of incoming tasks.
        /// </remarks>
        /// <returns> 
        /// Sets the policy governing whether core threads may time out and
        /// terminate if no tasks arrive within the keep-alive time, being
        /// replaced if needed when new tasks arrive. When false, core
        /// threads are never terminated due to lack of incoming
        /// tasks. When true, the same keep-alive policy applying to
        /// non-core threads applies also to core threads. To avoid
        /// continual thread replacement, the keep-alive time must be
        /// greater than zero when setting {@code true}. This method
        /// should in general be called before the pool is actively used.
        /// </returns>
        /// <exception cref="System.ArgumentException">if <see lang="true"/> and keep alive time is less than or equal to 0</exception>
        public bool AllowsCoreThreadsToTimeOut
        {
            get { return _allowCoreThreadToTimeOut; }
            set
            {
                if (value && _keepAliveTime.Ticks <= 0)
                {
                    throw new ArgumentException("Core threads must have nonzero keep alive times");
                }

                if (value == _allowCoreThreadToTimeOut) return;
                _allowCoreThreadToTimeOut = value;
                if (value)
                    interruptIdleWorkers();
            }
        }

        /// <summary> 
        /// Returns <see lang="true"/> if this executor is in the process of terminating
        /// after <see cref="Spring.Threading.Execution.ThreadPoolExecutor.Shutdown()"/> or
        /// <see cref="Spring.Threading.Execution.ThreadPoolExecutor.ShutdownNow()"/> but has not
        /// completely terminated.  
        /// </summary>
        /// <remarks>
        /// This method may be useful for debugging. A return of <see lang="true"/> reported a sufficient
        /// period after shutdown may indicate that submitted tasks have
        /// ignored or suppressed interruption, causing this executor not
        /// to properly terminate.
        /// </remarks>
        /// <returns><see lang="true"/>if terminating but not yet terminated.</returns>
        public bool IsTerminating
        {
            get
            {
                int c = _controlState.Value;
                return !isRunning(c) && runStateLessThan(c, TERMINATED);
            }
        }

        /// <summary>
        /// Gets / Sets the thread factory used to create new threads.
        /// </summary>
        /// <returns>the current thread factory</returns>
        /// <exception cref="System.ArgumentNullException">if the threadfactory is null</exception>
        public IThreadFactory ThreadFactory
        {
            get { return _threadFactory; }

            set
            {
                if (value == null)
                {
                    throw new ArgumentNullException("threadfactory");
                }
                _threadFactory = value;
            }
        }

        /// <summary> 
        /// Gets / Sets the current handler for unexecutable tasks.
        /// </summary>
        /// <returns>the current handler</returns>
        /// <exception cref="System.ArgumentNullException">if the execution handler is null.</exception>
        public IRejectedExecutionHandler RejectedExecutionHandler
        {
            get { return _rejectedExecutionHandler; }

            set
            {
                if (value == null)
                {
                    throw new ArgumentNullException("rejectedExecutionHandler");
                }
                _rejectedExecutionHandler = value;
            }
        }

        /// <summary> 
        /// Returns the task queue used by this executor. Access to the
        /// task queue is intended primarily for debugging and monitoring.
        /// This queue may be in active use.  Retrieving the task queue
        /// does not prevent queued tasks from executing.
        /// </summary>
        /// <returns>the task queue</returns>
        public IBlockingQueue<IRunnable> Queue
        {
            get { return _workQueue; }
        }


        /// <summary> 
        /// Sets the core number of threads.  This overrides any value set
        /// in the constructor.  If the new value is smaller than the
        /// current value, excess existing threads will be terminated when
        /// they next become idle.  If larger, new threads will, if needed,
        /// be started to execute any queued tasks.
        /// </summary>
        public int CorePoolSize
        {
            get { return _corePoolSize; }

            set
            {
                if (value < 0)
                    throw new ArgumentException("CorePoolSize cannot be less than 0");
                int delta = value - _corePoolSize;
                _corePoolSize = value;
                if (workerCountOf(_controlState.Value) > value)
                    interruptIdleWorkers();
                else if (delta > 0)
                {
                    // We don't really know how many new threads are "needed".
                    // As a heuristic, prestart enough new workers (up to new
                    // core size) to handle the current number of tasks in
                    // queue, but stop if queue becomes empty while doing so.
                    decimal k = Math.Min(delta, _workQueue.Count);
                    while (k-- > 0 && addWorker(null, true))
                    {
                        if (_workQueue.Count < 1)
                            break;
                    }
                }
            }
        }

        ///<summary>
        /// Returns the current number of threads in the pool.
        /// </summary>
        public int PoolSize
        {
            get
            {
                ReentrantLock mainLock = _mainLock;
                mainLock.Lock();
                try
                {
                    // Remove rare and surprising possibility of
                    // isTerminated() && getPoolSize() > 0
                    return runStateAtLeast(_controlState.Value, TIDYING) ? 0
                               : _currentWorkerThreads.Count;
                }
                finally
                {
                    mainLock.Unlock();
                }
            }
        }

        /// <summary>
        /// Returns the approximate number of threads that are actively
        /// executing tasks.
        /// </summary>
        public int ActiveCount
        {
            get
            {
                ReentrantLock mainLock = _mainLock;
                mainLock.Lock();
                try
                {
                    int n = 0;
                    foreach (Worker worker in _currentWorkerThreads)
                    {
                        if (worker.IsLocked) ++n;
                    }
                    return n;
                }
                finally
                {
                    mainLock.Unlock();
                }
            }
        }

        /// <summary> 
        /// Gets / Sets the maximum allowed number of threads. 
        /// </summary>
        /// <remarks>
        /// This overrides any
        /// value set in the constructor. If the new value is smaller than
        /// the current value, excess existing threads will be
        /// terminated when they next become idle.
        /// </remarks>
        /// <exception cref="System.ArgumentOutOfRangeException">If value is less than zero or less than 
        /// <see cref="Spring.Threading.Execution.ThreadPoolExecutor.CorePoolSize"/>. 
        /// </exception>
        public int MaximumPoolSize
        {
            get { return _maximumPoolSize; }

            set
            {
                if (value <= 0 || value < _corePoolSize)
                    throw new ArgumentException(String.Format("Maximum pool size cannont be less than 1 and cannot be less than Core Pool Size {0}", _corePoolSize));
                _maximumPoolSize = value;
                if (workerCountOf(_controlState.Value) > value)
                    interruptIdleWorkers();
            }
        }

        /// <summary> 
        /// Returns the largest number of threads that have ever
        /// simultaneously been in the pool.
        /// </summary>
        /// <returns> the number of threads</returns>
        public int LargestPoolSize
        {
            get
            {
                ReentrantLock mainLock = _mainLock;
                mainLock.Lock();
                try
                {
                    return _largestPoolSize;
                }
                finally
                {
                    mainLock.Unlock();
                }
            }
        }

        /// <summary> 
        /// Returns the approximate total number of tasks that have been
        /// scheduled for execution. 
        /// </summary>
        /// <remarks>
        /// Because the states of tasks and
        /// threads may change dynamically during computation, the returned
        /// value is only an approximation
        /// </remarks>
        /// <returns>the number of tasks</returns>
        public long TaskCount
        {
            get
            {
                _mainLock.Lock();
                try
                {
                    long n = _completedTaskCount;
                    foreach (Worker w in _currentWorkerThreads)
                    {
                        n += w.CompletedTasks;
                        if (w.IsLocked)
                            ++n;
                    }
                    return n + _workQueue.Count;
                }
                finally
                {
                    _mainLock.Unlock();
                }
            }
        }

        /// <summary> 
        /// Returns the approximate total number of tasks that have
        /// completed execution. 
        /// </summary>
        /// <remarks>
        /// Because the states of tasks and threads
        /// may change dynamically during computation, the returned value
        /// is only an approximation, but one that does not ever decrease
        /// across successive calls.
        /// </remarks>
        /// <returns>the number of tasks</returns>
        public long CompletedTaskCount
        {
            get
            {
                ReentrantLock mainLock = _mainLock;
                mainLock.Lock();
                try
                {
                    long n = _completedTaskCount;
                    foreach (Worker worker in _currentWorkerThreads)
                    {
                        n += worker.CompletedTasks;
                    }
                    return n;
                }
                finally
                {
                    mainLock.Unlock();
                }
            }
        }

        /// <summary> 
        /// Tries to remove from the work queue all {@link Future}
        /// tasks that have been cancelled. This method can be useful as a
        /// storage reclamation operation, that has no other impact on
        /// functionality. Cancelled tasks are never executed, but may
        /// accumulate in work queues until worker threads can actively
        /// remove them. Invoking this method instead tries to remove them now.
        /// However, this method may fail to remove tasks in
        /// the presence of interference by other threads.
        /// </summary>
        public void Purge()
        {
            IBlockingQueue<IRunnable> q = _workQueue;
            // TODO: What should we do w/ the CME exception?
            //        try
            //        {
            foreach (IRunnable runnable in q)
            {
                if (runnable is ICancellable && ((ICancellable) runnable).IsCancelled)
                    _workQueue.Remove(runnable);
            }
            //        }
            //    } catch (ConcurrentModificationException fallThrough) {
            //	    // Take slow path if we encounter interference during traversal.
            //            // Make copy for traversal and call remove for cancelled entries.
            //	    // The slow path is more likely to be O(N*N).
            //            Object[] arr = q.toArray();
            //            for (int i=0; i<arr.length; i++) {
            //                Object r = arr[i];
            //                if (r instanceof Future && ((Future)r).isCancelled())
            //		    q.remove(r);
            //            }
            //        }

            tryTerminate(); // In case SHUTDOWN and now empty
        }

        #endregion

        #region Private Methods

        private const bool ONLY_ONE = true;

        /// <summary>
        /// Main worker run loop.  Repeatedly gets tasks from queue and
        /// executes them, while coping with a number of issues:
        ///
        /// 1. We may start out with an initial task, in which case we
        /// don't need to get the first one. Otherwise, as long as pool is
        /// running, we get tasks from getTask. If it returns null then the
        /// worker exits due to changed pool state or configuration
        /// parameters.  Other exits result from exception throws in
        /// external code, in which case completedAbruptly holds, which
        /// usually leads processWorkerExit to replace this thread.
        ///
        /// 2. Before running any task, the lock is acquired to prevent
        /// other pool interrupts while the task is executing, and
        /// clearInterruptsForTaskRun called to ensure that unless pool is
        /// stopping, this thread does not have its interrupt set.
        ///
        /// 3. Each task run is preceded by a call to beforeExecute, which
        /// might throw an exception, in which case we cause thread to die
        /// (breaking loop with completedAbruptly true) without processing
        /// the task.
        ///
        /// 4. Assuming beforeExecute completes normally, we run the task,
        /// gathering any of its thrown exceptions to send to
        /// afterExecute. We separately handle RuntimeException, Error
        /// (both of which the specs guarantee that we trap) and arbitrary
        /// Throwables.  Because we cannot rethrow Throwables within
        /// Runnable.run, we wrap them within Errors on the way out (to the
        /// thread's UncaughtExceptionHandler).  Any thrown exception also
        /// conservatively causes thread to die.
        ///
        /// 5. After task.run completes, we call afterExecute, which may
        /// also throw an exception, which will also cause thread to
        /// die. According to JLS Sec 14.20, this exception is the one that
        /// will be in effect even if task.run throws.
        ///
        /// The net effect of the exception mechanics is that afterExecute
        /// and the thread's UncaughtExceptionHandler have as accurate
        /// information as we can provide about any problems encountered by
        /// user code.
        ///
        /// <param name="worker">the worker to run</param>
        /// </summary>
        protected void runWorker(Worker worker)
        {
            IRunnable task = worker.FirstTask;
            worker.FirstTask = null;
            bool completedAbruptly = true;
            try
            {
                while (task != null || (task = getTask()) != null)
                {
                    worker.Lock();
                    clearInterruptsForTaskRun();
                    try
                    {
                        beforeExecute(worker.Thread, task);
                        Exception thrown = null;
                        try
                        {
                            task.Run();
                        }
                        catch (Exception x)
                        {
                            thrown = x;
                            throw;
                        }
                        finally
                        {
                            afterExecute(task, thrown);
                        }
                    }
                    finally
                    {
                        task = null;
                        worker.CompletedTasks++;
                        worker.Unlock();
                    }
                }
                completedAbruptly = false;
            }
            finally
            {
                processWorkerExit(worker, completedAbruptly);
            }
        }

        /// <summary>
        /// Performs cleanup and bookkeeping for a dying worker. Called
        /// only from worker threads. Unless completedAbruptly is set,
        /// assumes that workerCount has already been adjusted to account
        /// for exit.  This method removes thread from worker set, and
        /// possibly terminates the pool or replaces the worker if either
        /// it exited due to user task exception or if fewer than
        /// corePoolSize workers are running or queue is non-empty but
        /// there are no workers.
        ///
        /// <param name="w">the worker</param>
        /// <param name="completedAbruptly">if the worker died to the user exception</param>
        /// </summary>
        private void processWorkerExit(Worker w, bool completedAbruptly)
        {
            if (completedAbruptly) // If abrupt, then workerCount wasn't adjusted
                decrementWorkerCount();

            _mainLock.Lock();
            try
            {
                _completedTaskCount += w.CompletedTasks;
                _currentWorkerThreads.Remove(w);
            }
            finally
            {
                _mainLock.Unlock();
            }

            tryTerminate();

            int c = _controlState.Value;
            if (!runStateLessThan(c, STOP)) return;
            if (!completedAbruptly)
            {
                int min = _allowCoreThreadToTimeOut ? 0 : _corePoolSize;
                if (min == 0 && _workQueue.Count > 0)
                    min = 1;
                if (workerCountOf(c) >= min)
                    return; // replacement not needed
            }
            addWorker(null, false);
        }

    /// <summary>
     /// Checks if a new worker can be added with respect to current
     /// pool state and the given bound (either core or maximum). If so,
     /// the worker count is adjusted accordingly, and, if possible, a
     /// new worker is created and started running firstTask as its
     /// first task. This method returns false if the pool is stopped or
     /// eligible to shut down. It also returns false if the thread
     /// factory fails to create a thread when asked, which requires a
     /// backout of workerCount, and a recheck for termination, in case
     /// the existence of this worker was holding up termination.
     /// </summary>
     ///
     /// <param name="firstTask"> the task the new thread should run first (or
     /// null if none). Workers are created with an initial first task
     /// (in method <see cref="Execute"/>) to bypass queuing when there are fewer
     /// than <see cref="CorePoolSize"/> threads (in which case we always start one),
     /// or when the queue is full (in which case we must bypass queue).
     /// Initially idle threads are usually created via
     /// <see cref="PreStartCoreThread"/> or to replace other dying workers.
     /// </param>
     /// <param name="core">
     /// if true use <see cref="CorePoolSize"/> as bound, else
     /// <see cref="MaximumPoolSize"/>. (A bool indicator is used here rather than a
     /// value to ensure reads of fresh values after checking other pool
     /// state).</param>
     /// <returns><see lang="true"/> if successful</returns>
        private bool addWorker(IRunnable firstTask, bool core)
        {
            retry:
            for (;;)
            {
                int c = _controlState.Value;
                int rs = runStateOf(c);

                // Check if queue empty only if necessary.
                if (rs >= SHUTDOWN && !(rs == SHUTDOWN & firstTask == null && _workQueue.Count > 0))
                    return false;

                for (;;)
                {
                    int wc = workerCountOf(c);
                    if (wc >= CAPACITY || wc >= (core ? _corePoolSize : _maximumPoolSize))
                        return false;
                    if (compareAndIncrementWorkerCount(c))
                        goto proceed;
                    c = _controlState.Value; // Re-read ctl
                    if (runStateOf(c) != rs)
                        goto retry;
                }
            }
            proceed:

            Worker w = new Worker(this, firstTask);
            Thread t = w.Thread;

            _mainLock.Lock();
            try
            {
                // Recheck while holding lock.
                // Back out on ThreadFactory failure or if
                // shut down before lock acquired.
                int c = _controlState.Value;
                int rs = runStateOf(c);

                if (t == null ||
                    (rs >= SHUTDOWN &&
                     !(rs == SHUTDOWN &&
                       firstTask == null)))
                {
                    decrementWorkerCount();
                    tryTerminate();
                    return false;
                }

                _currentWorkerThreads.Add(w);

                int s = _currentWorkerThreads.Count;
                if (s > _largestPoolSize)
                    _largestPoolSize = s;
            }
            finally
            {
                _mainLock.Unlock();
            }

            t.Start();
            // It is possible (but unlikely) for a thread to have been
            // added to workers, but not yet started, during transition to
            // Stop, which could result in a rare missed interrupt,
            // because Thread.interrupt is not guaranteed to have any effect
            // on a non-yet-started Thread (see Thread#interrupt).
            if (runStateOf(_controlState.Value) == STOP && t.IsAlive)
                t.Interrupt();

            return true;
        }

        /// <summary>
        /// Attempt to CAS-increment the workerCount field of control state.
        /// </summary>
        private bool compareAndIncrementWorkerCount(int expect)
        {
            return _controlState.CompareAndSet(expect, expect + 1);
        }

        /// <summary>
        ///Attempt to CAS-decrement the workerCount field of control state.
        /// </summary>
        private bool compareAndDecrementWorkerCount(int expect)
        {
            return _controlState.CompareAndSet(expect, expect - 1);
        }

        /// <summary>
        /// Decrements the workerCount field of ctl. This is called only on
        /// abrupt termination of a thread (see processWorkerExit). Other
        /// decrements are performed within getTask.
        /// </summary>
        private void decrementWorkerCount()
        {
            do
            {
            } while (! compareAndDecrementWorkerCount(_controlState.Value));
        }


        /// <summary> 
        /// Ensures that unless the pool is stopping, the current thread
        /// does not have its interrupt set. This requires a double-check
        /// of state in case the interrupt was cleared concurrently with a
        /// shutdownNow -- if so, the interrupt is re-enabled.
        /// </summary>
        private void clearInterruptsForTaskRun()
        {
            if (runStateLessThan(_controlState.Value, STOP) &&
                !Thread.CurrentThread.IsAlive &&
                runStateAtLeast(_controlState.Value, STOP))
                Thread.CurrentThread.Interrupt();
        }

        /// <summary> 
        /// State check needed by ScheduledThreadPoolExecutor to
        /// enable running tasks during shutdown.
        /// </summary>
        ///
        /// <param name="shutdownOK"><see lang="true"> if should return true if SHUTDOWN</see></param>
        private bool isRunningOrShutdown(bool shutdownOK)
        {
            int rs = runStateOf(_controlState.Value);
            return rs == RUNNING || (rs == SHUTDOWN && shutdownOK);
        }

        /// <summary> 
        /// Performs blocking or timed wait for a task, depending on
        /// current configuration settings, or returns null if this worker
        /// must exit because of any of:
        /// 1. There are more than maximumPoolSize workers (due to
        ///    a call to setMaximumPoolSize).
        /// 2. The pool is stopped.
        /// 3. The pool is shutdown and the queue is empty.
        /// 4. This worker timed out waiting for a task, and timed-out
        ///    workers are subject to termination (that is,
        ///    {@code allowCoreThreadTimeOut || workerCount > corePoolSize})
        ///    both before and after the timed wait.
        /// </summary> 
        ///<returns><see cref="IRunnable"/> task or <see lang="null"/>
        /// if the worker must exit, in which case workerCount is decremented
        /// </returns>
        private IRunnable getTask()
        {
            bool timedOut = false; // Did the last poll() time out?

            retry:
            for (;;)
            {
                int c = _controlState.Value;
                int rs = runStateOf(c);

                // Check if queue empty only if necessary.
                if (rs >= SHUTDOWN && (rs >= STOP || _workQueue.Count == 0))
                {
                    decrementWorkerCount();
                    return null;
                }

                bool timed; // Are workers subject to culling?

                for (;;)
                {
                    int wc = workerCountOf(c);
                    timed = _allowCoreThreadToTimeOut || wc > _corePoolSize;

                    if (wc <= _maximumPoolSize && ! (timedOut && timed))
                        break;
                    if (compareAndDecrementWorkerCount(c))
                        return null;
                    c = _controlState.Value; 
                    if (runStateOf(c) != rs)
                        goto retry;
                }

                try
                {
                    IRunnable r;
                    if (timed)
                    {
                        _workQueue.Poll(_keepAliveTime, out r);
                    }
                    else
                    {
                        r = _workQueue.Take();
                    }
                    if (r != null)
                        return r;
                    timedOut = true;
                }
                catch (ThreadInterruptedException)
                {
                    timedOut = false;
                }
            }
        }

        /// <summary> 
        /// Invokes the rejected execution handler for the given command.
        /// </summary>
        private void reject(IRunnable command)
        {
            _rejectedExecutionHandler.RejectedExecution(command, this);
        }

        /// <summary> 
        /// Interrupts all threads that might be waiting for tasks.
        /// </summary>
        private void interruptIdleWorkers()
        {
            interruptIdleWorkers(false);
        }

        /// <summary> 
        /// Interrupts threads that might be waiting for tasks (as
        /// indicated by not being locked) so they can check for
        /// termination or configuration changes. Ignores
        /// SecurityExceptions (in which case some threads may remain
        /// uninterrupted).
        ///
        /// @param onlyOne If true, interrupt at most one worker. This is
        /// called only from tryTerminate when termination is otherwise
        /// enabled but there are still other workers.  In this case, at
        /// most one waiting worker is interrupted to propagate shutdown
        /// signals in case all threads are currently waiting.
        /// Interrupting any arbitrary thread ensures that newly arriving
        /// workers since shutdown began will also eventually exit.
        /// To guarantee eventual termination, it suffices to always
        /// interrupt only one idle worker, but shutdown() interrupts all
        /// idle workers so that redundant workers exit promptly, not
        /// waiting for a straggler task to finish.
        /// </summary>
        private void interruptIdleWorkers(bool onlyOne)
        {
            _mainLock.Lock();
            try
            {
                foreach (Worker workerThread in _currentWorkerThreads)
                {
                    Thread t = workerThread.Thread;
                    if (t.IsAlive && workerThread.TryLock())
                    {
                        try
                        {
                            t.Interrupt();
                        }
                        finally
                        {
                            workerThread.Unlock();
                        }
                    }
                    if (onlyOne)
                        break;
                }
            }
            finally
            {
                _mainLock.Unlock();
            }
        }

        #endregion

        #region Default Constructors

        /// <summary> 
        /// Creates a new <see cref="Spring.Threading.Execution.ThreadPoolExecutor"/> with the given initial
        /// parameters and default thread factory and rejected execution handler.
        /// </summary>
        /// <remarks>>
        /// It may be more convenient to use one of the <see cref="Spring.Threading.Execution.Executors"/> factory
        /// methods instead of this general purpose constructor.
        /// </remarks>
        /// <param name="corePoolSize">the number of threads to keep in the pool, even if they are idle.</param>
        /// <param name="maximumPoolSize">the maximum number of threads to allow in the pool.</param>
        /// <param name="keepAliveTime">
        /// When the number of threads is greater than
        /// <see cref="Spring.Threading.Execution.ThreadPoolExecutor.CorePoolSize"/>, this is the maximum time that excess idle threads
        /// will wait for new tasks before terminating.
        /// </param>
        /// <param name="workQueue">
        /// The queue to use for holding tasks before they
        /// are executed. This queue will hold only the <see cref="Spring.Threading.IRunnable"/>
        /// tasks submitted by the <see cref="Spring.Threading.Execution.ThreadPoolExecutor.Execute(IRunnable)"/> method.
        /// </param>
        /// <exception cref="System.ArgumentOutOfRangeException">
        /// If <paramref name="corePoolSize"/> or <paramref name="keepAliveTime"/> is less than zero, or if <paramref name="maximumPoolSize"/>
        /// is less than or equal to zero, or if <paramref name="corePoolSize"/> is greater than <paramref name="maximumPoolSize"/>
        /// </exception>
        /// <exception cref="System.ArgumentNullException">if <paramref name="workQueue"/> is null</exception>
        /// <throws>  NullPointerException if <tt>workQueue</tt> is null </throws>
        public ThreadPoolExecutor(int corePoolSize, int maximumPoolSize, TimeSpan keepAliveTime, IBlockingQueue<IRunnable> workQueue)
            : this(
                corePoolSize, maximumPoolSize, keepAliveTime, workQueue, Executors.GetDefaultThreadFactory(),
                _defaultRejectedExecutionHandler)
        {
        }

        /// <summary> 
        /// Creates a new <see cref="Spring.Threading.Execution.ThreadPoolExecutor"/> with the given initial
        /// parameters and default <see cref="Spring.Threading.Execution.RejectedExecutionException"/>.
        /// </summary>
        /// <param name="corePoolSize">the number of threads to keep in the pool, even if they are idle.</param>
        /// <param name="maximumPoolSize">the maximum number of threads to allow in the pool.</param>
        /// <param name="keepAliveTime">
        /// When the number of threads is greater than
        /// <see cref="Spring.Threading.Execution.ThreadPoolExecutor.CorePoolSize"/>, this is the maximum time that excess idle threads
        /// will wait for new tasks before terminating.
        /// </param>
        /// <param name="workQueue">
        /// The queue to use for holding tasks before they
        /// are executed. This queue will hold only the <see cref="Spring.Threading.IRunnable"/>
        /// tasks submitted by the <see cref="Spring.Threading.Execution.ThreadPoolExecutor.Execute(IRunnable)"/> method.
        /// </param>
        /// <param name="threadFactory">
        /// <see cref="Spring.Threading.IThreadFactory"/> to use for new thread creation.
        /// </param>
        /// <exception cref="System.ArgumentOutOfRangeException">
        /// If <paramref name="corePoolSize"/> or <paramref name="keepAliveTime"/> is less than zero, or if <paramref name="maximumPoolSize"/>
        /// is less than or equal to zero, or if <paramref name="corePoolSize"/> is greater than <paramref name="maximumPoolSize"/>
        /// </exception>
        /// <exception cref="System.ArgumentNullException">if <paramref name="workQueue"/> or <paramref name="threadFactory"/> is null</exception>
        public ThreadPoolExecutor(int corePoolSize, int maximumPoolSize, TimeSpan keepAliveTime, IBlockingQueue<IRunnable> workQueue,
                                  IThreadFactory threadFactory)
            : this(corePoolSize, maximumPoolSize, keepAliveTime, workQueue, threadFactory, _defaultRejectedExecutionHandler)
        {
        }

        /// <summary> 
        /// Creates a new <see cref="Spring.Threading.Execution.ThreadPoolExecutor"/> with the given initial
        /// parameters and <see cref="Spring.Threading.IThreadFactory"/>.
        /// </summary>
        /// <summary> 
        /// Creates a new <see cref="Spring.Threading.Execution.ThreadPoolExecutor"/> with the given initial
        /// parameters and default <see cref="Spring.Threading.Execution.RejectedExecutionException"/>.
        /// </summary>
        /// <param name="corePoolSize">the number of threads to keep in the pool, even if they are idle.</param>
        /// <param name="maximumPoolSize">the maximum number of threads to allow in the pool.</param>
        /// <param name="keepAliveTime">
        /// When the number of threads is greater than
        /// <see cref="Spring.Threading.Execution.ThreadPoolExecutor.CorePoolSize"/>, this is the maximum time that excess idle threads
        /// will wait for new tasks before terminating.
        /// </param>
        /// <param name="workQueue">
        /// The queue to use for holding tasks before they
        /// are executed. This queue will hold only the <see cref="Spring.Threading.IRunnable"/>
        /// tasks submitted by the <see cref="Spring.Threading.Execution.ThreadPoolExecutor.Execute(IRunnable)"/> method.
        /// </param>
        /// <param name="handler">
        /// The <see cref="Spring.Threading.Execution.IRejectedExecutionHandler"/> to use when execution is blocked
        /// because the thread bounds and queue capacities are reached.
        /// </param>
        /// <exception cref="System.ArgumentOutOfRangeException">
        /// If <paramref name="corePoolSize"/> or <paramref name="keepAliveTime"/> is less than zero, or if <paramref name="maximumPoolSize"/>
        /// is less than or equal to zero, or if <paramref name="corePoolSize"/> is greater than <paramref name="maximumPoolSize"/>
        /// </exception>
        /// <exception cref="System.ArgumentNullException">if <paramref name="workQueue"/> or <paramref name="handler"/> is null</exception>
        public ThreadPoolExecutor(int corePoolSize, int maximumPoolSize, TimeSpan keepAliveTime, IBlockingQueue<IRunnable> workQueue,
                                  IRejectedExecutionHandler handler)
            : this(corePoolSize, maximumPoolSize, keepAliveTime, workQueue, Executors.GetDefaultThreadFactory(), handler)
        {
        }

        /// <summary> Creates a new <see cref="Spring.Threading.Execution.ThreadPoolExecutor"/> with the given initial
        /// parameters.
        /// 
        /// </summary>
        /// <param name="corePoolSize">the number of threads to keep in the pool, even if they are idle.</param>
        /// <param name="maximumPoolSize">the maximum number of threads to allow in the pool.</param>
        /// <param name="keepAliveTime">
        /// When the number of threads is greater than
        /// <see cref="Spring.Threading.Execution.ThreadPoolExecutor.CorePoolSize"/>, this is the maximum time that excess idle threads
        /// will wait for new tasks before terminating.
        /// </param>
        /// <param name="workQueue">
        /// The queue to use for holding tasks before they
        /// are executed. This queue will hold only the <see cref="Spring.Threading.IRunnable"/>
        /// tasks submitted by the <see cref="Spring.Threading.Execution.ThreadPoolExecutor.Execute(IRunnable)"/> method.
        /// </param>
        /// <param name="threadFactory">
        /// <see cref="Spring.Threading.IThreadFactory"/> to use for new thread creation.
        /// </param>
        /// <param name="handler">
        /// The <see cref="Spring.Threading.Execution.IRejectedExecutionHandler"/> to use when execution is blocked
        /// because the thread bounds and queue capacities are reached.
        /// </param>
        /// <exception cref="System.ArgumentOutOfRangeException">
        /// If <paramref name="corePoolSize"/> or <paramref name="keepAliveTime"/> is less than zero, or if <paramref name="maximumPoolSize"/>
        /// is less than or equal to zero, or if <paramref name="corePoolSize"/> is greater than <paramref name="maximumPoolSize"/>
        /// </exception>
        /// <exception cref="System.ArgumentNullException">if <paramref name="workQueue"/>, <paramref name="handler"/>, or <paramref name="threadFactory"/> is null</exception>
        public ThreadPoolExecutor(int corePoolSize, int maximumPoolSize, TimeSpan keepAliveTime, IBlockingQueue<IRunnable> workQueue,
                                  IThreadFactory threadFactory, IRejectedExecutionHandler handler)
        {
            if (corePoolSize < 0)
            {
                throw new ArgumentException("core pool size must be greater than or equal to zero: " + corePoolSize);
            }
            if (maximumPoolSize <= 0)
            {
                throw new ArgumentException("maximum pool size cannot be less than or equal to zero: " + maximumPoolSize);
            }
            if (maximumPoolSize < corePoolSize)
            {
                throw new ArgumentException("maximum pool size, " + maximumPoolSize + " cannot be less than core pool size, " +
                                            corePoolSize + ".");
            }
            if (keepAliveTime.Ticks < 0)
            {
                throw new ArgumentException("keep alive time must be greater than or equal to zero.");
            }
            if (workQueue == null)
            {
                throw new ArgumentNullException("workQueue");
            }
            if (threadFactory == null)
            {
                throw new ArgumentNullException("threadFactory");
            }
            if (handler == null)
            {
                throw new ArgumentNullException("handler");
            }
            _corePoolSize = corePoolSize;
            _maximumPoolSize = maximumPoolSize;
            _workQueue = workQueue;
            _keepAliveTime = keepAliveTime;
            _threadFactory = threadFactory;
            _rejectedExecutionHandler = handler;
            termination = _mainLock.NewCondition();
        }

        #endregion

        #region AbstractExecutorService Implementations

        /// <summary> 
        /// Returns <see lang="true"/> if this executor has been shut down.
        /// </summary>
        /// <returns> 
        /// Returns <see lang="true"/> if this executor has been shut down.
        /// </returns>
        public override bool IsShutdown
        {
            get { return !isRunning(_controlState.Value); }
        }

        /// <summary> 
        /// Returns <see lang="true"/> if all tasks have completed following shut down.
        /// </summary>
        /// <remarks>
        /// Note that this will never return <see lang="true"/> unless
        /// either <see cref="Spring.Threading.Execution.IExecutorService.Shutdown()"/> or 
        /// <see cref="Spring.Threading.Execution.IExecutorService.ShutdownNow()"/> was called first.
        /// </remarks>
        /// <returns> <see lang="true"/> if all tasks have completed following shut down</returns>
        public override bool IsTerminated
        {
            get { return runStateAtLeast(_controlState.Value, TERMINATED); }
        }

        /// <summary> 
        /// Executes the given task sometime in the future.  The task
        /// may execute in a new thread or in an existing pooled thread.
        /// </summary>
        /// <remarks>
        /// If the task cannot be submitted for execution, either because this
        /// executor has been shutdown or because its capacity has been reached,
        /// the task is handled by the current <see cref="Spring.Threading.Execution.IRejectedExecutionHandler"/>
        /// for this <see cref="Spring.Threading.Execution.ThreadPoolExecutor"/>.
        /// </remarks>
        /// <param name="command">the task to execute</param>
        /// <exception cref="Spring.Threading.Execution.RejectedExecutionException">
        /// if the task cannot be accepted. 
        /// </exception>
        /// <exception cref="System.ArgumentNullException">if <paramref name="command"/> is <see lang="null"/></exception>
        public override void Execute(IRunnable command)
        {
            if (command == null)
            {
                throw new ArgumentNullException("command");
            }
            /*
             * Proceed in 3 steps:
             *
             * 1. If fewer than corePoolSize threads are running, try to
             * start a new thread with the given command as its first
             * task.  The call to addWorker atomically checks runState and
             * workerCount, and so prevents false alarms that would add
             * threads when it shouldn't, by returning false.
             *
             * 2. If a task can be successfully queued, then we still need
             * to double-check whether we should have added a thread
             * (because existing ones died since last checking) or that
             * the pool shut down since entry into this method. So we
             * recheck state and if necessary roll back the enqueuing if
             * stopped, or start a new thread if there are none.
             *
             * 3. If we cannot queue task, then we try to add a new
             * thread.  If it fails, we know we are shut down or saturated
             * and so reject the task.
             */
            int c = _controlState.Value;
            if (workerCountOf(c) < _corePoolSize)
            {
                if (addWorker(command, true))
                    return;
                c = _controlState.Value;
            }
            if (isRunning(c) && _workQueue.Offer(command))
            {
                int recheck = _controlState.Value;
                if (!isRunning(recheck) && Remove(command))
                    reject(command);
                else if (workerCountOf(recheck) == 0)
                    addWorker(null, false);
            }
            else if (!addWorker(command, false))
                reject(command);
        }

        /// <summary>
        /// Removes this task from the executor's internal queue if it is
        /// present, thus causing it not to be run if it has not already
        /// started.
        ///
        /// <p/> This method may be useful as one part of a cancellation
        /// scheme.  It may fail to remove tasks that have been converted
        /// into other forms before being placed on the internal queue. For
        /// example, a task entered using {@code submit} might be
        /// converted into a form that maintains {@code Future} status.
        /// However, in such cases, method {@link #purge} may be used to
        /// remove those Futures that have been cancelled.
        ///
        /// </summary>
        /// @param task the task to remove
        /// @return true if the task was removed
        public bool Remove(IRunnable task)
        {
            bool removed = _workQueue.Remove(task);
            tryTerminate(); // In case SHUTDOWN and now empty
            return removed;
        }

        /// <summary>
        /// Transitions control state to given target or leaves if alone if
        /// already at least the given target.
        /// </summary>
        /// <param name="targetState">the desired state, either SHUTDOWN or Stop ( but 
        /// not TIDYING or TERMINATED -- use TryTerminate for that )</param>
        private void advanceRunState(int targetState)
        {
            for (;;)
            {
                int state = _controlState.Value;
                if (runStateAtLeast(state, targetState) ||
                    _controlState.CompareAndSet(state, ctlOf(targetState, workerCountOf(state))))
                    break;
            }
        }

        /// <summary> 
        ///Performs any further cleanup following run state transition on
        /// invocation of shutdown.  A no-op here, but used by
        /// ScheduledThreadPoolExecutor to cancel delayed tasks.
        /// </summary>
        protected void onShutdown()
        {
        }

        /// <summary> 
        /// Transitions to TERMINATED state if either (SHUTDOWN and pool
        /// and queue empty) or (Stop and pool empty).  If otherwise
        /// eligible to terminate but workerCount is nonzero, interrupts an
        /// idle worker to ensure that shutdown signals propagate. This
        /// method must be called following any action that might make
        /// termination possible -- reducing worker count or removing tasks
        /// from the queue during shutdown. The method is non-private to
        /// allow access from ScheduledThreadPoolExecutor.
        /// </summary>
        private void tryTerminate()
        {
            for (;;)
            {
                int c = _controlState.Value;
                if (isRunning(c) ||
                    runStateAtLeast(c, TIDYING) ||
                    (runStateOf(c) == SHUTDOWN && _workQueue.Count > 0))
                    return;
                if (workerCountOf(c) != 0)
                {
                    // Eligible to terminate
                    interruptIdleWorkers(ONLY_ONE);
                    return;
                }

                _mainLock.Lock();
                try
                {
                    if (_controlState.CompareAndSet(c, ctlOf(TIDYING, 0)))
                    {
                        try
                        {
                            terminated();
                        }
                        finally
                        {
                            _controlState.Exchange((ctlOf(TERMINATED, 0)));
                            termination.SignalAll();
                        }
                        return;
                    }
                }
                finally
                {
                    _mainLock.Unlock();
                }
            }
        }

        /// <summary> 
        /// Initiates an orderly shutdown in which previously submitted
        /// tasks are executed, but no new tasks will be
        /// accepted. Invocation has no additional effect if already shut
        /// down.
        /// </summary>
        public override void Shutdown()
        {
            _mainLock.Lock();
            try
            {
                advanceRunState(SHUTDOWN);
                interruptIdleWorkers();
                onShutdown(); // hook for ScheduledThreadPoolExecutor
            }
            finally
            {
                _mainLock.Unlock();
            }
            tryTerminate();
        }

        /// <summary> 
        /// Attempts to stop all actively executing tasks, halts the
        /// processing of waiting tasks, and returns a list of the tasks
        /// that were awaiting execution. These tasks are drained (removed)
        /// from the task queue upon return from this method.
        ///
        /// <p/>There are no guarantees beyond best-effort attempts to stop
        /// processing actively executing tasks.  This implementation
        /// cancels tasks via {@link Thread#interrupt}, so any task that
        /// fails to respond to interrupts may never terminate.
        ///
        /// </summary> 
        public override IList<IRunnable> ShutdownNow()
        {
            IList<IRunnable> tasks;
            _mainLock.Lock();
            try
            {
                advanceRunState(STOP);
                interruptWorkers();
                tasks = drainQueue();
            }
            finally
            {
                _mainLock.Unlock();
            }
            tryTerminate();
            return tasks;
        }


        /// <summary> 
        /// Interrupts all threads, even if active. Ignores SecurityExceptions
        /// (in which case some threads may remain uninterrupted).
        /// </summary> 
        private void interruptWorkers()
        {
            _mainLock.Lock();
            try
            {
                foreach (Worker worker in _currentWorkerThreads)
                {
                    try
                    {
                        worker.Thread.Interrupt();
                    }
                    catch (SecurityException)
                    {
                    }
                }
            }
            finally
            {
                _mainLock.Unlock();
            }
        }

        /// <summary> 
        /// Drains the task queue into a new list, normally using
        /// drainTo. But if the queue is a DelayQueue or any other kind of
        /// queue for which poll or drainTo may fail to remove some
        /// elements, it deletes them one by one.
        /// </summary> 
        private IList<IRunnable> drainQueue()
        {
            IBlockingQueue<IRunnable> q = _workQueue;
            IList<IRunnable> taskList = new List<IRunnable>();
            q.DrainTo(taskList);
            if (q.Count > 0)
            {
                foreach (IRunnable runnable in q)
                {
                    if (q.Remove(runnable))
                        taskList.Add(runnable);
                }
            }
            return taskList;
        }

        /// <summary> 
        /// Blocks until all tasks have completed execution after a shutdown
        /// request, or the timeout occurs, or the current thread is
        /// interrupted, whichever happens first. 
        /// </summary>
        /// <param name="duration">the time span to wait.
        /// </param>
        /// <returns> <see lang="true"/> if this executor terminated and <see lang="false"/>
        /// if the timeout elapsed before termination
        /// </returns>
        public override bool AwaitTermination(TimeSpan duration)
        {
            TimeSpan durationToWait = duration;
            DateTime deadline = DateTime.Now.Add(durationToWait);
            ReentrantLock mainLock = _mainLock;
            mainLock.Lock();
            try
            {
                if (runStateAtLeast(_controlState.Value, TERMINATED))
                {
                    return true;
                }
                while (durationToWait.Ticks > 0)
                {
                    termination.Await(durationToWait);
                    if (runStateAtLeast(_controlState.Value, TERMINATED))
                    {
                        return true;
                    }
                    durationToWait = deadline.Subtract(DateTime.Now);
                }
                return false;
            }
            finally
            {
                mainLock.Unlock();
            }
        }

        #endregion

        #region Public Methods

        /// <summary> 
        /// Starts a core thread, causing it to idly wait for work. This
        /// overrides the default policy of starting core threads only when
        /// new tasks are executed. This method will return {@code false}
        /// if all core threads have already been started.
        ///
        /// @return {@code true} if a thread was started
        /// </summary>
        public bool PreStartCoreThread()
        {
            return workerCountOf(_controlState.Value) < _corePoolSize &&
                   addWorker(null, true);
        }

        /// <summary> 
        /// Starts all core threads, causing them to idly wait for work. 
        /// </summary>
        /// <remarks>
        /// This overrides the default policy of starting core threads only when
        /// new tasks are executed.
        /// </remarks>
        /// <returns>the number of threads started.</returns>
        public int PreStartAllCoreThreads()
        {
            int n = 0;
            while (addWorker(null, true))
                ++n;
            return n;
        }

        #endregion

        #region Overriddable Methods

        /// <summary> 
        /// Method invoked prior to executing the given <see cref="Spring.Threading.IRunnable"/> in the
        /// given thread.  
        /// </summary>
        /// <remarks>
        /// This method is invoked by <paramref name="thread"/> that
        /// will execute <paramref name="runnable"/>, and may be used to re-initialize
        /// ThreadLocals, or to perform logging. This implementation does
        /// nothing, but may be customized in subclasses. <b>Note:</b> To properly
        /// nest multiple overridings, subclasses should generally invoke
        /// <i>base.beforeExecute</i> at the end of this method.
        /// </remarks>
        /// <param name="thread">the thread that will run <paramref name="runnable"/>.</param>
        /// <param name="runnable">the task that will be executed.</param>
        protected internal virtual void beforeExecute(Thread thread, IRunnable runnable)
        {
        }

        /// <summary>
        /// Method invoked upon completion of execution of the given Runnable.
        /// This method is invoked by the thread that executed the task. If
        /// non-null, the Throwable is the uncaught {@code RuntimeException}
        /// or {@code Error} that caused execution to terminate abruptly.
        ///
        /// <p/>This implementation does nothing, but may be customized in
        /// subclasses. Note: To properly nest multiple overridings, subclasses
        /// should generally invoke {@code super.afterExecute} at the
        /// beginning of this method.
        ///
        /// <p/><b>Note:</b> When actions are enclosed in tasks (such as
        /// {@link FutureTask}) either explicitly or via methods such as
        /// {@code submit}, these task objects catch and maintain
        /// computational exceptions, and so they do not cause abrupt
        /// termination, and the internal exceptions are <em>not</em>
        /// passed to this method. If you would like to trap both kinds of
        /// failures in this method, you can further probe for such cases,
        /// as in this sample subclass that prints either the direct cause
        /// or the underlying exception if a task has been aborted:
        ///
        ///  <pre> {@code
        /// class ExtendedExecutor extends ThreadPoolExecutor {
        ///   // ...
        ///   protected void afterExecute(Runnable r, Throwable t) {
        ///     super.afterExecute(r, t);
        ///     if (t == null &amp;&amp; r instanceof Future) {
        ///       try {
        ///         Object result = ((Future) r).get();
        ///       } catch (CancellationException ce) {
        ///           t = ce;
        ///       } catch (ExecutionException ee) {
        ///           t = ee.getCause();
        ///       } catch (InterruptedException ie) {
        ///           Thread.currentThread().interrupt(); // ignore/reset
        ///       }
        ///     }
        ///     if (t != null)
        ///       System.out.println(t);
        ///   }
        /// }}</pre>
        /// </summary>
        /// @param r the runnable that has completed
        /// @param t the exception that caused termination, or null if
        /// execution completed normally
        protected internal virtual void afterExecute(IRunnable runnable, Exception exception)
        {
        }

        /// <summary> 
        /// Method invoked when the <see cref="Spring.Threading.IExecutor"/> has terminated.  
        /// Default implementation does nothing. 
        /// <p/>
        /// <b>Note:</b> To properly nest multiple
        /// overridings, subclasses should generally invoke
        /// <i>base.terminated</i> within this method.
        /// </summary>
        protected internal virtual void terminated()
        {
        }

        #endregion

        #region IDisposable Members

        /// <summary>
        /// Shutsdown and disposes of this <see cref="Spring.Threading.Execution.ThreadPoolExecutor"/>.
        /// </summary>
        public void Dispose()
        {
            Dispose(true);
            GC.SuppressFinalize(this);
        }

        #endregion

        /// <summary>
        /// Helper method to dispose of this <see cref="Spring.Threading.Execution.ThreadPoolExecutor"/>
        /// </summary>
        /// <param name="disposing"><see lang="true"/> if being called from <see cref="Spring.Threading.Execution.ThreadPoolExecutor.Dispose()"/>,
        /// <see lang="false"/> if being called from finalizer.</param>
        protected virtual void Dispose(bool disposing)
        {
            if (disposing)
            {
                Shutdown();
            }
        }

        #region Finalizer

        /// <summary>
        /// Finalizer
        /// </summary>
        ~ThreadPoolExecutor()
        {
            Dispose(false);
        }

        #endregion
    }
}