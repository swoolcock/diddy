using System;
using System.Collections.Generic;
using System.Threading;

namespace Spring.Threading.Locks
{
    [Serializable]
    internal class ConditionVariable : ICondition
    {
        protected internal IExclusiveLock _internalExclusiveLock;

        /// <summary> 
        /// Create a new <see cref="ConditionVariable"/> that relies on the given mutual
        /// exclusion lock.
        /// </summary>
        /// <param name="exclusiveLock">
        /// A non-reentrant mutual exclusion lock.
        /// </param>
        internal ConditionVariable(IExclusiveLock exclusiveLock)
        {
            _internalExclusiveLock = exclusiveLock;
        }

        protected internal virtual IExclusiveLock Lock
        {
            get { return _internalExclusiveLock; }
        }

        protected internal virtual int WaitQueueLength
        {
            get { throw new NotSupportedException("Use FAIR version"); }
        }

        protected internal virtual ICollection<Thread> WaitingThreads
        {
            get { throw new NotSupportedException("Use FAIR version"); }
        }

        protected internal virtual bool HasWaiters
        {
            get { throw new NotSupportedException("Use FAIR version"); }
        }

        #region ICondition Members

        public virtual void AwaitUninterruptibly()
        {
            int holdCount = _internalExclusiveLock.HoldCount;
            if (holdCount == 0)
            {
                throw new SynchronizationLockException();
            }
            bool wasInterrupted = false;
            try
            {
                lock (this)
                {
                    for (int i = holdCount; i > 0; i--) _internalExclusiveLock.Unlock();
                    try
                    {
                        Monitor.Wait(this);
                    }
                    catch (ThreadInterruptedException)
                    {
                        wasInterrupted = true;
                        // may have masked the signal and there is no way
                        // to tell; defensively propagate the signal
                        Monitor.Pulse(this);
                    }
                }
            }
            finally
            {
                for (int i = holdCount; i > 0; i--) _internalExclusiveLock.Lock();
                if (wasInterrupted)
                {
                    Thread.CurrentThread.Interrupt();
                }
            }
        }

        public virtual void Await()
        {
            int holdCount = _internalExclusiveLock.HoldCount;
            if (holdCount == 0)
            {
                throw new SynchronizationLockException();
            }
            try
            {
                lock (this)
                {
                    for (int i = holdCount; i > 0; i--) _internalExclusiveLock.Unlock();
                    try
                    {
                        Monitor.Wait(this);
                    }
                    catch (ThreadInterruptedException)
                    {
                        Monitor.Pulse(this);
                        throw;
                    }
                }
            }
            finally
            {
                for (int i = holdCount; i > 0; i--) _internalExclusiveLock.Lock();
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="durationToWait"></param>
        /// <returns>
        /// true if the lock was reacquired before the specified time elapsed; 
        /// false if the lock was reacquired after the specified time elapsed. 
        /// The method does not return until the lock is reacquired.
        /// </returns>
        public virtual bool Await(TimeSpan durationToWait)
        {
            int holdCount = _internalExclusiveLock.HoldCount;
            if (holdCount == 0)
            {
                throw new SynchronizationLockException();
            }
            try
            {
                lock (this)
                {
                    for (int i = holdCount; i > 0; i--) _internalExclusiveLock.Lock();
                    try
                    {
                        return (durationToWait.Ticks > 0) && Monitor.Wait(this, durationToWait);
                    }
                    catch (ThreadInterruptedException)
                    {
                        Monitor.Pulse(this);
                        throw;
                    }
                }
            }
            finally
            {
                for (int i = holdCount; i > 0; i--) _internalExclusiveLock.Lock();
            }
        }

        public virtual bool AwaitUntil(DateTime deadline)
        {
            return Await(deadline - DateTime.Now);
        }

        public virtual void Signal()
        {
            lock (this)
            {
                checkifLockIsHeldByCurrentThread();
                Monitor.Pulse(this);
            }
        }


        public virtual void SignalAll()
        {
            lock (this)
            {
                checkifLockIsHeldByCurrentThread();
                Monitor.PulseAll(this);
            }
        }

        #endregion

        private void checkifLockIsHeldByCurrentThread()
        {
            if (!_internalExclusiveLock.IsHeldByCurrentThread)
            {
                throw new SynchronizationLockException();
            }
        }
    }
}