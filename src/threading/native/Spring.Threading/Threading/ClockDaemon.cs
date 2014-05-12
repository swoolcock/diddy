//#region License
//*
//* Copyright © 2002-2005 the original author or authors.
//* 
//* Licensed under the Apache License, Version 2.0 (the "License");
//* you may not use this file except in compliance with the License.
//* You may obtain a copy of the License at
//* 
//*      http://www.apache.org/licenses/LICENSE-2.0
//* 
//* Unless required by applicable law or agreed to in writing, software
//* distributed under the License is distributed on an "AS IS" BASIS,
//* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//* See the License for the specific language governing permissions and
//* limitations under the License.
//*/
//#endregion
//*
//File: ClockDaemon.java

//Originally written by Doug Lea and released into the public domain.
//This may be used for any purposes whatsoever without acknowledgment.
//Thanks for the assistance and support of Sun Microsystems Labs,
//and everyone contributing, testing, and using this code.

//History:
//Date       Who                What
//29Aug1998  dl               created initial public version
//17dec1998  dl               null out thread after shutdown*/
//using System;
//using System.Threading;

//namespace Spring.Threading
//{
	
//    /// <summary> A general-purpose time-based daemon, vaguely similar in functionality
//    /// to common system-level utilities such as <code>at</code> 
//    /// (and the associated crond) in Unix.
//    /// Objects of this class maintain a single thread and a task queue
//    /// that may be used to execute Runnable commands in any of three modes --
//    /// absolute (run at a given time), relative (run after a given delay),
//    /// and periodic (cyclically run with a given delay).
//    /// <p>
//    /// All commands are executed by the single background thread. 
//    /// The thread is not actually started until the first 
//    /// request is encountered. Also, if the
//    /// thread is stopped for any reason, one is started upon encountering
//    /// the next request,  or <code>restart()</code> is invoked. 
//    /// </p>
//    /// <p>
//    /// If you would instead like commands run in their own threads, you can
//    /// use as arguments Runnable commands that start their own threads
//    /// (or perhaps wrap within ThreadedExecutors). 
//    /// </p>
//    /// <p>
//    /// You can also use multiple
//    /// daemon objects, each using a different background thread. However,
//    /// one of the reasons for using a time daemon is to pool together
//    /// processing of infrequent tasks using a single background thread.
//    /// </p>
//    /// <p>
//    /// Background threads are created using a ThreadFactory. The
//    /// default factory does <em>not</em>
//    /// automatically <code>setDaemon</code> status.
//    /// </p>
//    /// <p>
//    /// The class uses Java timed waits for scheduling. These can vary
//    /// in precision across platforms, and provide no real-time guarantees
//    /// about meeting deadlines.
//    /// </p>
//    /// </summary>
	
//    public class ClockDaemon:ThreadFactoryUser
//    {
//        /// <summary> Return the thread being used to process commands, or
//        /// null if there is no such thread. You can use this
//        /// to invoke any special methods on the thread, for
//        /// example, to interrupt it.
//        /// </summary>
//        virtual public Thread Thread
//        {
//            get
//            {
//                lock (this)
//                {
//                    return thread_;
//                }
//            }
			
//        }
		
		
//        /// <summary>tasks are maintained in a standard priority queue *</summary>
//        protected internal readonly Heap heap_ = new Heap(DefaultChannelCapacity.DefaultCapacity);
		
//        /// <summary>
//        /// Task holder
//        /// </summary>
//        protected internal class TaskNode : System.IComparable
//        {
//            virtual internal long TimeToRun
//            {
//                get
//                {
//                    lock (this)
//                    {
//                        return timeToRun_;
//                    }
//                }
				
//                set
//                {
//                    lock (this)
//                    {
//                        timeToRun_ = value;
//                    }
//                }
				
//            }
//            internal IRunnable command; // The command to run
//            internal readonly long period; // The cycle period, or -1 if not periodic
//            private long timeToRun_; // The time to run command
			
//            // Cancellation does not immediately remove node, it just
//            // sets up lazy deletion bit, so is thrown away when next 
//            // encountered in run loop
			
//            private bool cancelled_ = false;
			
//            // Access to cancellation status and and run time needs sync 
//            // since they can be written and read in different threads			
            
//            internal virtual void SetCancelled ()
//            {
//                lock (this)
//                {
//                    cancelled_ = true;
//                }
//            }

//            internal virtual bool Cancelled
//            {
//                get
//                {
//                    lock (this)
//                    {
//                        return cancelled_;
//                    }
//                }
//            }			
			
//            /// <summary>
//            /// Compare tasks with regard to <see cref="TaskNode.TimeToRun"/>
//            /// </summary>
//            /// <param name="other">another task</param>
//            /// <returns>
//            /// A value less, equal or greater than zero if 
//            /// this task <see cref="TaskNode.TimeToRun"/>
//            /// is less than, equal or greater that the oher one.
//            /// </returns>
//            public virtual int CompareTo(System.Object other)
//            {
//                long a = TimeToRun;
//                long b = ((TaskNode) (other)).TimeToRun;
//                return (a < b)?- 1:((a == b)?0:1);
//            }
			
//            internal TaskNode(long w, IRunnable c, long p)
//            {
//                timeToRun_ = w; command = c; period = p;
//            }
			
//            internal TaskNode(long w, IRunnable c):this(w, c, - 1)
//            {
//            }
//        }
		
		
//        /// <summary> Execute the given command at the given time.</summary>
//        /// <param name="date">
//        /// the absolute time to run the command, expressed as a <see cref="DateTime"/>.
//        /// </param>
//        /// <param name="command">
//        /// the command to run at the given time.
//        /// </param>
//        /// <returns>
//        /// an opaque reference that can be used to cancel execution request
//        /// </returns>
//        public virtual System.Object ExecuteAt(System.DateTime date, IRunnable command)
//        {		
//            TaskNode task = new TaskNode(Utils.ToTimeMillis(date), command);
//            heap_.Insert(task);
//            Restart();
//            return task;
//        }
		
//        /// <summary> Excecute the given command after waiting for the given delay.
//        /// <p>
//        /// <b>Sample Usage.</b>
//        /// You can use a <see cref="ClockDaemon"/> to arrange timeout callbacks to break out
//        /// of stuck IO. For example (code sketch):
//        /// <pre>
//        /// class X {   ...
//        /// 
//        /// ClockDaemon timer = ...
//        /// Thread readerThread;
//        /// FileInputStream datafile;
//        /// 
//        /// void startReadThread() {
//        /// datafile = new FileInputStream("data", ...);
//        /// 
//        /// readerThread = new Thread(new Runnable() {
//        /// public void run() {
//        /// for(;;) {
//        /// // try to gracefully exit before blocking
//        /// if (Thread.currentThread().isInterrupted()) {
//        /// quietlyWrapUpAndReturn();
//        /// }
//        /// else {
//        /// try {
//        /// int c = datafile.read();
//        /// if (c == -1) break;
//        /// else process(c);
//        /// }
//        /// catch (IOException ex) {
//        /// cleanup();
//        /// return;
//        /// }
//        /// }
//        /// } };
//        /// 
//        /// readerThread.start();
//        /// 
//        /// // establish callback to cancel after 60 seconds
//        /// timer.executeAfterDelay(60000, new Runnable() {
//        /// readerThread.interrupt();    // try to interrupt thread
//        /// datafile.close(); // force thread to lose its input file 
//        /// });
//        /// } 
//        /// }
//        /// </pre>
//        /// </p>
//        /// </summary>
//        /// <param name="millisecondsToDelay">-- the number of milliseconds
//        /// from now to run the command.
//        /// </param>
//        /// <param name="command">-- the command to run after the delay.
//        /// </param>
//        /// <returns> taskID -- an opaque reference that can be used to cancel execution request
//        /// </returns>
//        public virtual System.Object ExecuteAfterDelay(long millisecondsToDelay, IRunnable command)
//        {
//            long runtime = Utils.CurrentTimeMillis + millisecondsToDelay;
//            TaskNode task = new TaskNode(runtime, command);
//            heap_.Insert(task);
//            Restart();
//            return task;
//        }
		
//        /// <summary> Execute the given command every <c>period</c> milliseconds.
//        /// If <c>startNow</c> is true, execution begins immediately,
//        /// otherwise, it begins after the first <c>period</c> delay.
//        /// <p>
//        /// <b>Sample Usage</b>. Here is one way
//        /// to update Swing components acting as progress indicators for
//        /// long-running actions.
//        /// <code>
//        /// class X {
//        ///     Label statusLabel = ...;
//        /// 
//        ///     int percentComplete = 0;
//        ///     int  getPercentComplete() { lock(this) { return percentComplete; } }
//        ///     void setPercentComplete(int p) { lock(this) { percentComplete = p; } }
//        /// 
//        ///     ClockDaemon cd = ...;
//        /// 
//        ///     void startWorking() {
//        ///         Runnable showPct = new Runnable() {
//        ///             public void run() {
//        ///                 SwingUtilities.invokeLater(new Runnable() {
//        ///                     public void run() {
//        ///                         statusLabel.setText(getPercentComplete() + "%");
//        ///                     } 
//        ///             } 
//        ///         }
//        ///     };
//        /// 
//        ///     final Object updater = cd.executePeriodically(500, showPct, true);
//        /// 
//        ///     Runnable action = new Runnable() {
//        ///         public void run() {
//        ///             for (int i = 0; i &lt; 100; ++i) {
//        ///                 work();
//        ///                 setPercentComplete(i);
//        ///             }
//        ///             cd.cancel(updater);
//        ///         }
//        ///     };
//        /// 
//        ///     new Thread(action).start();
//        ///     }
//        /// }  
//        /// </code>
//        /// </p>
//        /// </summary>
//        /// <param name="period">-- the period, in milliseconds. Periods are
//        /// measured from start-of-task to the next start-of-task. It is
//        /// generally a bad idea to use a period that is shorter than 
//        /// the expected task duration.
//        /// </param>
//        /// <param name="command">-- the command to run at each cycle
//        /// </param>
//        /// <param name="startNow">-- true if the cycle should start with execution
//        /// of the task now. Otherwise, the cycle starts with a delay of
//        /// <code>period</code> milliseconds.
//        /// </param>
//        /// <exception cref="ArgumentOutOfRangeException"> if period less than or equal to zero.
//        /// </exception>
//        /// <returns> taskID -- an opaque reference that can be used to cancel execution request
//        /// 
//        /// </returns>
//        public virtual System.Object ExecutePeriodically(long period, IRunnable command, bool startNow)
//        {
			
//            if (period <= 0)
//                throw new System.ArgumentOutOfRangeException("perdiod", period, "must be positive");
			
//            long firstTime = Utils.CurrentTimeMillis;
//            if (!startNow)
//                firstTime += period;
			
//            TaskNode task = new TaskNode(firstTime, command, period);
//            heap_.Insert(task);
//            Restart();
//            return task;
//        }
		
//        /// <summary> Cancel a scheduled task that has not yet been run. 
//        /// The task will be cancelled
//        /// upon the <em>next</em> opportunity to run it. This has no effect if
//        /// this is a one-shot task that has already executed.
//        /// Also, if an execution is in progress, it will complete normally.
//        /// (It may however be interrupted via getThread().interrupt()).
//        /// But if it is a periodic task, future iterations are cancelled. 
//        /// </summary>
//        /// <param name="taskID">a task reference returned by one of
//        /// the execute commands
//        /// </param>
//        public static void  Cancel(System.Object taskID)
//        {
//            ((TaskNode) taskID).SetCancelled();
//        }
		
		
//        /// <summary>The thread used to process commands *</summary>
//        protected internal Thread thread_;
		
//        /// <summary>set thread_ to null to indicate termination *</summary>
//        protected internal virtual void  ClearThread()
//        {
//            lock (this)
//            {
//                thread_ = null;
//            }
//        }
		
//        /// <summary> Start (or restart) a thread to process commands, or wake
//        /// up an existing thread if one is already running. This
//        /// method can be invoked if the background thread crashed
//        /// due to an unrecoverable exception in an executed command.
//        /// </summary>
//        public virtual void  Restart()
//        {
//            lock (this)
//            {
//                if (thread_ == null)
//                {
//                    thread_ = threadFactory_.NewThread(runLoop_);
//                    thread_.Start();
//                }
//                else
//                    System.Threading.Monitor.Pulse(this);
//            }
//        }
		
		
//        /// <summary> Cancel all tasks and interrupt the background thread executing
//        /// the current task, if any.
//        /// A new background thread will be started if new execution
//        /// requests are encountered. If the currently executing task
//        /// does not repsond to interrupts, the current thread may persist, even
//        /// if a new thread is started via restart().
//        /// 
//        /// </summary>
//        public virtual void  ShutDown()
//        {
//            lock (this)
//            {
//                heap_.Clear();
//                if (thread_ != null)
//                    thread_.Interrupt();
//                thread_ = null;
//            }
//        }
		
//        /// <summary>Return the next task to execute, or null if thread is interrupted *</summary>
//        protected internal virtual TaskNode NextTask()
//        {
//            lock (this)
//            {
				
//                // Note: This code assumes that there is only one run loop thread
				
//                try
//                {
//                    while (true)
//                    {
//                        Utils.FailFastIfInterrupted();
						
//                        // Using peek simplifies dealing with spurious wakeups
						
//                        TaskNode task = (TaskNode) (heap_.Peek());
						
//                        if (task == null)
//                        {
//                            System.Threading.Monitor.Wait(this);
//                        }
//                        else
//                        {
//                            long now = Utils.CurrentTimeMillis;
//                            long when = task.TimeToRun;
							
//                            if (when > now)
//                            {
//                                // false alarm wakeup
//                                System.Threading.Monitor.Wait(this, TimeSpan.FromMilliseconds(when - now));
//                            }
//                            else
//                            {
//                                task = (TaskNode) (heap_.Extract());
								
//                                if (!task.Cancelled)
//                                {
//                                    // Skip if cancelled by
									
//                                    if (task.period > 0)
//                                    {
//                                        // If periodic, requeue 
//                                        task.TimeToRun = now + task.period;
//                                        heap_.Insert(task);
//                                    }
									
//                                    return task;
//                                }
//                            }
//                        }
//                    }
//                }
//                catch (System.Threading.ThreadInterruptedException)
//                {
//                } // fall through
				
//                return null; // on interrupt
//            }
//        }
		
//        /// <summary> The runloop is isolated in its own Runnable class
//        /// just so that the main 
//        /// class need not implement Runnable,  which would
//        /// allow others to directly invoke run, which is not supported.
//        /// 
//        /// </summary>
		
//        protected internal class RunLoop : IRunnable
//        {

//            /// <summary>
//            /// Creates a new <see cref="RunLoop"/> instance.
//            /// </summary>
//            /// <param name="clockDaemon">Clock daemon.</param>
//            public RunLoop(ClockDaemon clockDaemon)
//            {
//                this.clockDaemon = clockDaemon;
//            }
//            private ClockDaemon clockDaemon;

//            /// <summary>
//            /// the clock deamon owning this run loop
//            /// </summary>
//            public ClockDaemon ClockDaemon
//            {
//                get
//                {
//                    return clockDaemon;
//                }
				
//            }


//            /// <summary>
//            /// <see cref="IRunnable.Run"/>
//            /// </summary>
//            public virtual void  Run()
//            {
//                try
//                {
//                    for (; ; )
//                    {
//                        TaskNode task = ClockDaemon.NextTask();
//                        if (task != null)
//                            task.command.Run();
//                        else
//                            break;
//                    }
//                }
//                finally
//                {
//                    ClockDaemon.ClearThread();
//                }
//            }
//        }
		
//        /// <summary>
//        /// The backing run loop
//        /// </summary>
//        protected readonly internal RunLoop runLoop_;
		
//        /// <summary> Create a new ClockDaemon 
//        /// 
//        /// </summary>
		
//        public ClockDaemon()
//        {
//            runLoop_ = new RunLoop(this);
//        }
//    }
//}