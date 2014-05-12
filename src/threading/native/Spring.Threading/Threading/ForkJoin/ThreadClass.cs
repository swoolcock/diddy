using System;
using System.Collections;
using System.Threading;

namespace Spring.Threading.ForkJoin
{
    /// <summary>
    /// <see cref="Thread"/> wrapper for <see cref="FJTask"/> stuff
    /// </summary>
    public class ThreadClass
    {
        private static readonly IDictionary registry = Hashtable.Synchronized (new Hashtable ());

        /// <summary>
        /// The backing thread
        /// </summary>
        protected Thread thread;


        /// <summary>
        /// Creates a new <see cref="ThreadClass"/> instance.
        /// </summary>
        protected ThreadClass ()
        {}

        /// <summary>
        /// Creates a new <see cref="ThreadClass"/> instance.
        /// </summary>
        /// <param name="thread">Thread.</param>
        public ThreadClass (Thread thread)
        {
            SetThread (thread);
        }


        /// <summary>
        /// sets the backing thread
        /// </summary>
        protected virtual void SetThread (Thread t)
        {
            lock (typeof (ThreadClass))
            {
                if (registry.Contains (t))
                {
                    throw new ArgumentException ("this thread is already associated to a different ThreadClass");
                }

                registry [t] = this;
                thread = t;
                IsBackground = true;
            }
        }


        /// <summary>
        /// Gets a value indicating whether this <see cref="ThreadClass"/> is interrupted.
        /// </summary>
        /// <value>
        /// 	<c>true</c> if interrupted; otherwise, <c>false</c>.
        /// </value>
        public bool Interrupted
        {
            get { return Utils.ThreadInterrupted; }
        }

        /// <summary>
        /// Gets or sets the priority.
        /// </summary>
        /// <value></value>
        public ThreadPriority Priority
        {
            get { return thread.Priority; }
            set { thread.Priority = value; }
        }
        /// <summary>
        /// Gets a value indicating whether this instance is alive.
        /// </summary>
        /// <value>
        /// 	<c>true</c> if this instance is alive; otherwise, <c>false</c>.
        /// </value>
        public bool IsAlive
        {
            get { return thread.IsAlive; }
        }
        /// <summary>
        /// Gets a value indicating whether this instance is thread pool thread.
        /// </summary>
        /// <value>
        /// 	<c>true</c> if this instance is thread pool thread; otherwise, <c>false</c>.
        /// </value>
        public bool IsThreadPoolThread
        {
            get { return thread.IsThreadPoolThread; }
        }
        /// <summary>
        /// Gets or sets a value indicating whether this instance is background.
        /// </summary>
        /// <value>
        /// 	<c>true</c> if this instance is background; otherwise, <c>false</c>.
        /// </value>
        public bool IsBackground
        {
            get { return thread.IsBackground; }
            set { thread.IsBackground = value; }
        }

        /// <summary>
        /// Starts this instance.
        /// </summary>
        public virtual void Start ()
        {
            thread.Start ();
        }

        /// <summary>
        /// Interrupts this instance.
        /// </summary>
        public void Interrupt ()
        {
            thread.Interrupt ();
        }

        /// <summary>
        /// Joins this instance.
        /// </summary>
        public void Join ()
        {
            thread.Join ();
        }

        /// <summary>
        /// Joins the specified milliseconds timeout.
        /// </summary>
        /// <param name="millisecondsTimeout">Milliseconds timeout.</param>
        /// <returns></returns>
        public bool Join (int millisecondsTimeout)
        {
            return thread.Join (millisecondsTimeout);
        }

        /// <summary>
        /// Joins the specified timeout.
        /// </summary>
        /// <param name="timeout">Timeout.</param>
        /// <returns></returns>
        public bool Join (TimeSpan timeout)
        {
            return thread.Join (timeout);
        }

        /// <summary>
        /// Gets the current Thread.
        /// </summary>
        /// <value></value>
        public static ThreadClass Current
        {
            get
            {
                lock (typeof (ThreadClass))
                {
                    if (!registry.Contains (Thread.CurrentThread))
                    {
                        throw new ArgumentException (
                            String.Format("this thread (#{0}) is not associated to a ThreadClass", Thread.CurrentThread.GetHashCode()));
                    }

                    return registry [Thread.CurrentThread] as ThreadClass;
                }
            }
        }
    }
}