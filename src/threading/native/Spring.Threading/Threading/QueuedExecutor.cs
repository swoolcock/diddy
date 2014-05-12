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
using System.Threading;

namespace Spring.Threading
{
    /// <summary> 
    /// An implementation of Executor that queues incoming
    /// requests until they can be processed by a single background
    /// thread.
    /// <p>
    /// The thread is not actually started until the first 
    /// <code>execute</code> request is encountered. Also, if the
    /// thread is stopped for any reason (for example, after hitting
    /// an unrecoverable exception in an executing task), one is started 
    /// upon encountering a new request, or if <code>restart()</code> is
    /// invoked.</p>
    /// <p>
    /// Beware that, especially in situations
    /// where command objects themselves invoke execute, queuing can
    /// sometimes lead to lockups, since commands that might allow
    /// other threads to terminate do not run at all when they are in the queue.
    /// </p>
    /// </summary>
    public class QueuedExecutor:ThreadFactoryUser, IExecutor
    {
        /// <summary> Return the thread being used to process commands, or
        /// null if there is no such thread. You can use this
        /// to invoke any special methods on the thread, for
        /// example, to interrupt it.
        /// 
        /// </summary>
        virtual public Thread Thread
        {
            get
            {
                lock (this)
                {
                    return thread_;
                }
            }
			
        }
		
        /// <summary>The thread used to process commands *</summary>
        protected internal Thread thread_;
		
        /// <summary>Special queue element to signal termination *</summary>
        readonly IRunnable endTask_ = new NullRunnable();
		
        /// <summary>true if thread should shut down after processing current task *</summary>
        protected internal volatile bool shutdown_; // latches true;
		
        /// <summary>set thread_ to null to indicate termination *</summary>
        protected internal virtual void  ClearThread()
        {
            lock (this)
            {
                thread_ = null;
            }
        }
		
		
        /// <summary>The queue *</summary>
        protected internal readonly IChannel queue_;
		
		
        /// <summary> The runloop is isolated in its own Runnable class
        /// just so that the main
        /// class need not implement Runnable,  which would
        /// allow others to directly invoke run, which would
        /// never make sense here.
        /// 
        /// </summary>
        protected internal class RunLoop : IRunnable
        {
            /// <summary>
            /// Initializes a new instance of RunLoop connected to the given executor
            /// </summary>
            /// <param name="executor">the executor from which to dequeue the <see cref="IRunnable">s</see></param>
            public RunLoop(QueuedExecutor executor)
            {
                this.executor = executor;
            }

            private QueuedExecutor executor;

            /// <summary>
            /// The enclosing Executor
            /// </summary>
            public QueuedExecutor Executor
            {
                get
                {
                    return executor;
                }
				
            }

            /// <summary>
            /// <see cref="IRunnable.Run"/>
            /// </summary>
            public virtual void  Run()
            {
                try
                {
                    while (!Executor.shutdown_)
                    {
                        IRunnable task = Executor.queue_.Take() as IRunnable;
                        if (task == Executor.endTask_)
                        {
                            task.Run();
                            Executor.shutdown_ = true;
                            break;
                        }                        
                        else if (task != null)
                        {
                            task.Run();
                            task = null;
                        }
                        else
                            break;
                    }
                }
                catch (ThreadInterruptedException)
                {
                }
                    // fallthrough
                finally
                {
                    Executor.ClearThread();
                }
            }
        }
		
        /// <summary>
        /// support for running <see cref="IRunnable">s</see> in background 
        /// </summary>
        protected internal readonly RunLoop runLoop_;
		
		
        /// <summary> Construct a new QueuedExecutor that uses
        /// the supplied Channel as its queue. 
        /// <p>
        /// This class does not support any methods that 
        /// reveal this queue. If you need to access it
        /// independently (for example to invoke any
        /// special status monitoring operations), you
        /// should record a reference to it separately.
        /// </p>
        /// </summary>		
        public QueuedExecutor(IChannel queue)
        {
            queue_ = queue;
            runLoop_ = new RunLoop(this);
        }
		
        /// <summary> Construct a new QueuedExecutor that uses
        /// a <see cref="BoundedLinkedQueue"/> with the current
        /// <see cref="DefaultChannelCapacity"/> as its queue.
        /// 
        /// </summary>		
        public QueuedExecutor():this(new BoundedLinkedQueue())
        {
        }

        /// <summary> Construct a new QueuedExecutor that uses
        /// the given <see cref="IRunnable"/> to be used to shut down 
        /// the executor thread. 
        /// </summary>
        /// <param name="endTask"></param>
        public QueuedExecutor(IRunnable endTask)
            : this()
        {
            endTask_ = endTask;
        }

        /// <summary> Start (or restart) the background thread to process commands. It has
        /// no effect if a thread is already running. This
        /// method can be invoked if the background thread crashed
        /// due to an unrecoverable exception.
        /// 
        /// </summary>
		
        public virtual void  Restart()
        {
            lock (this)
            {
                if (thread_ == null && !shutdown_)
                {
                    thread_ = threadFactory_.NewThread(runLoop_);
                    thread_.Start();
                }
            }
        }
		
		
        /// <summary> Arrange for execution of the command in the
        /// background thread by adding it to the queue. 
        /// The method may block if the channel's put
        /// operation blocks.
        /// <p>
        /// If the background thread
        /// does not exist, it is created and started.
        /// </p>
        /// </summary>
        public virtual void  Execute(IRunnable runnable)
        {
            Restart();
            queue_.Put(runnable);
        }

        /// <summary>
        /// <para>
        /// Arrange for execution of the <paramref name="task"/> in the
        /// background thread by adding it to the queue.  The method may 
        /// block if the channel's put operation blocks.
        /// </para>
        /// <para>
        /// If the background thread does not exist, it is created and started.
        /// </para>
        /// </summary>
        /// <param name="task">The task to be executed.</param>
        public virtual void Execute(Task task)
        {
            Execute(Spring.Threading.Execution.Executors.CreateRunnable(task));
        }
		
        /// <summary> Terminate background thread after it processes all
        /// elements currently in queue. Any tasks entered after this point will
        /// not be processed. A shut down thread cannot be restarted.
        /// This method may block if the task queue is finite and full.
        /// Also, this method 
        /// does not in general apply (and may lead to comparator-based
        /// exceptions) if the task queue is a priority queue.
        /// 
        /// </summary>
        public virtual void  ShutdownAfterProcessingCurrentlyQueuedTasks()
        {
            lock (this)
            {
                if (!shutdown_)
                {
                    try
                    {
                        queue_.Put(endTask_);
                    }
                    catch (ThreadInterruptedException)
                    {
                        Thread.CurrentThread.Interrupt();
                    }
                }
            }
        }
		
		
        /// <summary> Terminate background thread after it processes the 
        /// current task, removing other queued tasks and leaving them unprocessed.
        /// A shut down thread cannot be restarted.
        /// 
        /// </summary>
        public virtual void  ShutdownAfterProcessingCurrentTask()
        {
            lock (this)
            {
                shutdown_ = true;
                try
                {
                    while (queue_.Poll(0) != null)
                        ; // drain
                    queue_.Put(endTask_);
                }
                catch (ThreadInterruptedException)
                {
                    Thread.CurrentThread.Interrupt();
                }
            }
        }
		
		
        /// <summary> Terminate background thread even if it is currently processing
        /// a task. <p>This method uses Thread.Interrupt, so relies on tasks
        /// themselves responding appropriately to interruption.</p>
        /// <p>If the current tasks does not terminate on interruption, then the 
        /// thread will not terminate until processing current task.</p>
        /// A shut down thread cannot be restarted.
        /// 
        /// </summary>
        public virtual void ShutdownNow()
        {
            lock (this)
            {
                shutdown_ = true;
                Thread t = thread_;
                if (t != null)
                    t.Interrupt();
                ShutdownAfterProcessingCurrentTask();
            }
        }
    }
}