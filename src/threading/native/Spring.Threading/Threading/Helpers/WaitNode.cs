using System;
using System.Threading;

namespace Spring.Threading.Helpers
{
	/// <summary>
	/// 
	/// </summary>
	internal class WaitNode
	{
		internal Thread _owner;
		internal bool _waiting = true;
		internal WaitNode _nextWaitNode;
		/// <summary>
		/// 
		/// </summary>
		public WaitNode()
		{
			_owner = Thread.CurrentThread;
		}
		/// <summary>
		/// 
		/// </summary>
		internal virtual Thread Owner
		{
			get { return _owner; }

		}
		internal virtual bool IsWaiting
		{
			get
			{
				return _waiting;
			}
		}

		internal virtual WaitNode NextWaitNode
		{
			get { return _nextWaitNode; }
			set { _nextWaitNode = value; }
		}

		/// <summary>
		/// 
		/// </summary>
		/// <param name="sync"></param>
		/// <returns></returns>
		public virtual bool Signal(IQueuedSync sync)
		{
			lock (this)
			{
				bool signalled = _waiting;
				if (signalled)
				{
					_waiting = false;
					Monitor.Pulse(this);
					sync.TakeOver(this);
				}
				return signalled;
			}
		}
		/// <summary>
		/// 
		/// </summary>
		/// <param name="sync"></param>
		/// <param name="duration"></param>
		/// <returns></returns>
		public virtual bool DoTimedWait( IQueuedSync sync, TimeSpan duration)
		{
			lock (this)
			{
				if (sync.Recheck(this) || !_waiting)
				{
					return true;
				}
				else if (duration.Ticks <= 0)
				{
					_waiting = false;
					return false;
				}
				else
				{
					DateTime deadline = DateTime.Now.Add(duration);
					try
					{
						for (;; )
						{
							Monitor.Wait(this, duration);
							if (!_waiting)
								return true;
							else
							{
							    duration = deadline.Subtract(DateTime.Now);
								if (duration.Ticks <= 0)
								{
									_waiting = false;
									return false;
								}
							}
						}
					}
					catch (ThreadInterruptedException ex)
					{
						if (_waiting)
						{
							_waiting = false; // invalidate for the signaller
							throw ex;
						}
						else
						{
							Thread.CurrentThread.Interrupt();
							return true;
						}
					}
				}
			}
		}

		/// <summary>
		/// 
		/// </summary>
		/// <param name="sync"></param>
		public virtual void DoWait(IQueuedSync sync)
		{
			lock (this)
			{
				if (!sync.Recheck(this))
				{
					try
					{
						while (_waiting)
							Monitor.Wait(this);
					}
					catch (ThreadInterruptedException ex)
					{
						if (_waiting)
						{
							// no notification
							_waiting = false; // invalidate for the signaller
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

		/// <summary>
		/// 
		/// </summary>
		/// <param name="sync"></param>
		public virtual void DoWaitUninterruptibly(IQueuedSync sync)
		{
			lock (this)
			{
				if (!sync.Recheck(this))
				{
					bool wasInterrupted = false;
					while (_waiting)
					{
						try
						{
							Monitor.Wait(this);
						}
						catch (ThreadInterruptedException)
						{
							
							wasInterrupted = true;
						}
					}
					if (wasInterrupted)
					{
						Thread.CurrentThread.Interrupt();
					}
				}
			}
		}
	}
}
