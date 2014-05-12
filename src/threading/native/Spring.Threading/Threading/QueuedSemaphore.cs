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
File: QueuedSemaphore.java

Originally written by Doug Lea and released into the public domain.
This may be used for any purposes whatsoever without acknowledgment.
Thanks for the assistance and support of Sun Microsystems Labs,
and everyone contributing, testing, and using this code.

History:
Date       Who                What
11Jun1998  dl               Create public version
5Aug1998  dl               replaced int counters with longs
24Aug1999  dl               release(n): screen arguments*/
using System;
using System.Threading;

namespace Spring.Threading
{
    /// <summary> Abstract base class for semaphores relying on queued wait nodes.
    /// </summary>
    public abstract class QueuedSemaphore : Semaphore
    {
        internal virtual WaitQueue.WaitNode Signallee
        {
            get
            {
                lock (this)
                {
                    WaitQueue.WaitNode w = wq_.Extract();
                    if (w == null)
                        ++nPermits; // if none, inc permits for new arrivals
                    return w;
                }
            }

        }

        /// <summary>
        /// The backing wait queue
        /// </summary>
        protected readonly internal WaitQueue wq_;

        internal QueuedSemaphore(WaitQueue q, long initialPermits)
            : base(initialPermits)
        {
            wq_ = q;
        }
        /// <summary>
        /// <see cref="ISync.Acquire"/>
        /// </summary>
        public override void Acquire()
        {
            Utils.FailFastIfInterrupted();
            if (Precheck())
                return;
            WaitQueue.WaitNode w = new WaitQueue.WaitNode();
            w.doWait(this);
        }

        /// <summary>
        /// <see cref="ISync.Attempt"/>
        /// </summary>
        public override bool Attempt(long msecs)
        {
            Utils.FailFastIfInterrupted();
            if (Precheck())
                return true;
            if (msecs <= 0)
                return false;

            WaitQueue.WaitNode w = new WaitQueue.WaitNode();
            return w.doTimedWait(this, msecs);
        }

        /// <summary>
        /// Check to do before a timed wait
        /// </summary>
        /// <returns></returns>
        protected internal virtual bool Precheck()
        {
            lock (this)
            {
                bool pass = (nPermits > 0);
                if (pass)
                    --nPermits;
                return pass;
            }
        }

        /// <summary>
        /// Check to do on a wait node
        /// </summary>
        /// <param name="w"></param>
        /// <returns></returns>
        internal virtual bool Recheck(WaitQueue.WaitNode w)
        {
            lock (this)
            {
                bool pass = (nPermits > 0);
                if (pass)
                    --nPermits;
                else
                    wq_.Insert(w);
                return pass;
            }
        }

        /// <summary>
        /// <see cref="ISync.Release"/>
        /// </summary>
        public override void Release()
        {
            for (; ; )
            {
                WaitQueue.WaitNode w = Signallee;
                if (w == null)
                    return; // no one to signal
                if (w.signal(this))
                    return; // notify if still waiting, else skip
            }
        }

        /// <summary>Release N permits *</summary>
        public override void Release(long n)
        {
            if (n < 0)
                throw new System.ArgumentException("Negative argument");

            for (long i = 0; i < n; ++i)
                Release();
        }

        /// <summary> Base class for internal queue classes for semaphores, etc.
        /// Relies on subclasses to actually implement queue mechanics
        /// 
        /// </summary>

        protected internal abstract class WaitQueue
        {
            /// <summary>
            /// assumed not to block
            /// </summary>
            internal abstract void Insert(WaitNode w);

            /// <summary>
            /// should return null if empty
            /// </summary>
            internal abstract WaitNode Extract();

            internal class WaitNode
            {
                internal bool waiting = true;
                internal WaitNode next = null;

                protected internal virtual bool signal(QueuedSemaphore sem)
                {
                    lock (this)
                    {
                        bool signalled = waiting;
                        if (signalled)
                        {
                            waiting = false;
                            // TODO: ? System.Threading.Monitor.Pulse(this);
                            System.Threading.Monitor.Pulse(sem);
                        }
                        return signalled;
                    }
                }

                protected internal virtual bool doTimedWait(QueuedSemaphore sem, long msecs)
                {
                    lock (this)
                    {
                        if (sem.Recheck(this) || !waiting)
                            return true;
                        else if (msecs <= 0)
                        {
                            waiting = false;
                            return false;
                        }
                        else
                        {
                            long waitTime = msecs;
                            long start = Utils.CurrentTimeMillis;

                            try
                            {
                                for (; ; )
                                {
                                    //TODO: ? System.Threading.Monitor.Wait(this, TimeSpan.FromMilliseconds(waitTime));
                                    System.Threading.Monitor.Wait(sem, TimeSpan.FromMilliseconds(waitTime));
                                    if (!waiting)
                                        // definitely signalled
                                        return true;
                                    else
                                    {
                                        waitTime = msecs - (Utils.CurrentTimeMillis - start);
                                        if (waitTime <= 0)
                                        {
                                            //  timed out
                                            waiting = false;
                                            return false;
                                        }
                                    }
                                }
                            }
                            catch (System.Threading.ThreadInterruptedException ex)
                            {
                                if (waiting)
                                {
                                    // no notification
                                    waiting = false; // invalidate for the signaller
                                    throw ex;
                                }
                                else
                                {
                                    // thread was interrupted after it was notified
                                    Thread.CurrentThread.Interrupt();
                                    return true;
                                }
                            }
                        }
                    }
                }

                protected internal virtual void doWait(QueuedSemaphore sem)
                {
                    lock (this)
                    {
                        if (!sem.Recheck(this))
                        {
                            try
                            {
                                while (waiting)
                                {
                                    //TODO: ? System.Threading.Monitor.Wait(this);
                                    System.Threading.Monitor.Wait(sem);
                                }
                            }
                            catch (System.Threading.ThreadInterruptedException ex)
                            {
                                if (waiting)
                                {
                                    // no notification
                                    waiting = false; // invalidate for the signaller
                                    throw ex;
                                }
                                else
                                {
                                    // thread was interrupted after it was notified
                                    Thread.CurrentThread.Interrupt();
                                    return;
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}