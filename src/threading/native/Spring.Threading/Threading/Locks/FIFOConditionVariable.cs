using System;
using System.Collections.Generic;
using System.Threading;
using Spring.Threading.Helpers;

namespace Spring.Threading.Locks
{
	/// <summary>
	/// 
	/// </summary>
	/// <author>Doug Lea</author>
	/// <author>Griffin Caprio (.NET)</author>
	/// <author>Kenneth Xu</author>
	[Serializable]
	internal class FIFOConditionVariable : ConditionVariable
	{
        private static readonly IQueuedSync _sync = new Sync();

        private readonly IWaitNodeQueue _wq = new FIFOWaitNodeQueue();

		private class Sync : IQueuedSync
		{
			public bool Recheck(WaitNode node)
			{
				return false;
			}

			public void TakeOver(WaitNode node)
			{
			}
		}

		protected internal override int WaitQueueLength
		{
			get
			{
                AssertOwnership();
                return _wq.Count;
			}

		}

		protected internal override ICollection<Thread> WaitingThreads
		{
			get
			{
                AssertOwnership();
                return _wq.WaitingThreads;
			}

		}

		internal FIFOConditionVariable(IExclusiveLock exclusiveLock) : base(exclusiveLock)
		{
		}

        public override void AwaitUninterruptibly()
        {
            DoWait(delegate(WaitNode n) { n.DoWaitUninterruptibly(_sync); });
        }

	    public override void Await()
		{
            DoWait(delegate(WaitNode n) { n.DoWait(_sync); });
		}

		public override bool Await(TimeSpan timespan)
		{
			bool success = false;
            DoWait(delegate(WaitNode n) { success = n.DoTimedWait(_sync, timespan); });
            return success;
		}

		public override bool AwaitUntil(DateTime deadline)
		{
			return Await(deadline.Subtract(DateTime.Now));
		}

		public override void Signal()
		{
            AssertOwnership();
            for (; ; )
			{
				WaitNode w = _wq.Dequeue();
                if (w == null) return;  // no one to signal
                if (w.Signal(_sync)) return; // notify if still waiting, else skip
			}
		}

		public override void SignalAll()
		{
            AssertOwnership();
            for (; ; )
			{
				WaitNode w = _wq.Dequeue();
                if (w == null) return;  // no more to signal
				w.Signal(_sync);
			}
		}

	    protected internal override bool HasWaiters
	    {
	        get
	        {
	            AssertOwnership();
	            return _wq.HasNodes;
	        }
	    }

        private void DoWait(Action<WaitNode> action)
        {
            int holdCount = Lock.HoldCount;
            if (holdCount == 0)
            {
                throw new SynchronizationLockException();
            }
            WaitNode n = new WaitNode();
            _wq.Enqueue(n);
            for (int i = holdCount; i > 0; i--) Lock.Unlock();
            try
            {
                action(n);
            }
            finally
            {
                for (int i = holdCount; i > 0; i--) Lock.Lock();
            }
        }

        private void AssertOwnership()
        {
            if (!Lock.IsHeldByCurrentThread)
            {
                throw new SynchronizationLockException();
            }
        }
	}
}