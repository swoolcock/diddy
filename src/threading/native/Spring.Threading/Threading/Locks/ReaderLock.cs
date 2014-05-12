using System;
using System.Threading;

namespace Spring.Threading.Locks
{
	[Serializable]
	internal class ReaderLock : AbstractSignallerLock
	{
		#region Constructors

		/// <summary>
		/// Constructs a <see cref="Spring.Threading.Locks.ReaderLock"/>, using the given <see cref="Spring.Threading.Locks.ReentrantReadWriteLock"/>
		/// </summary>
		/// <param name="reentrantReadWriteLock"><see cref="Spring.Threading.Locks.ReentrantReadWriteLock"/> to use for this lock.</param>
		public ReaderLock(ReentrantReadWriteLock reentrantReadWriteLock) : base(reentrantReadWriteLock)
		{
		}

		#endregion

		/// <summary> Acquires the read lock unless <see cref="System.Threading.Thread.Interrupt()"/> is called on the current thread</summary>
		/// <remarks> 
		/// <p/>
		/// Acquires the read lock if the write lock is not held
		/// by another thread and returns immediately.
		/// 
		/// <p/>
		/// If the write lock is held by another thread then the
		/// current thread becomes disabled for thread scheduling
		/// purposes and lies dormant until one of two things happens:
		/// 
		/// <ul>
		/// <li>The read lock is acquired by the current thread</li>
		/// <li>Some other thread calls <see cref="System.Threading.Thread.Interrupt()"/> on the current thread.</li>
		/// </ul>
		/// 
		/// <p/>If <see cref="System.Threading.Thread.Interrupt()"/> is called on the current thread,
		/// a <see cref="System.Threading.ThreadInterruptedException"/> is thrown
		/// 
		/// <p/>
		/// In this implementation, as this method is an explicit
		/// interruption point, preference is given to responding to
		/// the interrupt over normal or reentrant acquisition of the
		/// lock.
		/// </remarks> 
		/// <exception cref="System.Threading.ThreadInterruptedException">if the current thread is interrupted.</exception>
		public override IDisposable LockInterruptibly()
		{
			ThreadInterruptedException ie = null;
			lock (this)
			{
				if (!ReentrantReadWriteLock.StartReadFromNewReader())
				{
					for (;;) 
					{
						try
						{
							Monitor.Wait(this);
							if (ReentrantReadWriteLock.StartReadFromWaitingReader())
								return this;
						}
						catch (ThreadInterruptedException ex)
						{
							ReentrantReadWriteLock.CancelWaitingReader();
							ie = ex;
							break;
						}
					}
				}
			}
			if (ie != null)
			{
				ReentrantReadWriteLock.SignallerWriterLock.SignalWaiters();
				throw ie;
			}
		    return this;
		}

		/// <summary> Attempts to release this lock.</summary>	
		/// <remarks> 
		/// <p/> If the number of readers is now zero then the lock
		/// is made available for write lock attempts.
		/// </remarks>
		public override void Unlock()
		{
			switch (ReentrantReadWriteLock.EndRead())
		    {
		        case ReentrantReadWriteLock.Signaller.READER:
		            ReentrantReadWriteLock.SignallerReaderLock.SignalWaiters();
		            break;
		        case ReentrantReadWriteLock.Signaller.WRITER:
		            ReentrantReadWriteLock.SignallerWriterLock.SignalWaiters();
		            break;
		        default:
		            break;
		    }
		}


		/// <summary> 
		/// Acquires the read lock only if the write lock is not held by
		/// another thread at the time of invocation.
		/// </summary>
		/// <remarks>
		/// <p/>
		/// Acquires the read lock if the write lock is not held by
		/// another thread and returns immediately with the value
		/// <see lang="true"/>. Even when this lock has been set to use a
		/// fair ordering policy, a call to <see cref="Spring.Threading.Locks.ReaderLock.TryLock()"/>
		/// <b>will</b> immediately acquire the read lock if it is
		/// available, whether or not other threads are currently
		/// waiting for the read lock.  This "barging" behavior
		/// can be useful in certain circumstances, even though it
		/// breaks fairness. If you want to honor the fairness setting
		/// for this lock, then use <see cref="Spring.Threading.Locks.ReaderLock.TryLock(TimeSpan)"/>
		/// which is almost equivalent (it also detects interruption).
		/// 
		/// <p/>
		/// If the write lock is held by another thread then
		/// this method will return immediately with the value
		/// <see lang="false"/>.
		/// </remarks>
		/// <returns> <see lang="true"/> if the read lock was acquired, <see lang="false"/> otherwise.</returns>
		public override bool TryLock()
		{
			return ReentrantReadWriteLock.StartRead();
		}

		/// <summary> 
		/// Acquires the read lock if the write lock is not held by
		/// another thread within the given waiting time and <see cref="System.Threading.Thread.Interrupt()"/> 
		/// has not been called on  the current thread.
		/// </summary> 
		/// <remarks>
		/// <p/>
		/// Acquires the read lock if the write lock is not held by
		/// another thread and returns immediately with the value
		/// <see lang="true"/>. If this lock has been set to use a fair
		/// ordering policy then an available lock <b>will not</b> be
		/// acquired if any other threads are waiting for the
		/// lock. This is in contrast to the <see cref="Spring.Threading.Locks.ReaderLock.TryLock()"/>
		/// method. If you want a timed <see cref="Spring.Threading.Locks.ReaderLock.TryLock()"/> that does
		/// permit barging on a fair lock then combine the timed and un-timed forms together:
		/// 
		/// <code>
		/// if (lock.TryLock() || lock.TryLock(timespan) ) { ... }
		/// </code>
		/// 
		/// <p/>
		/// If the write lock is held by another thread then the
		/// current thread becomes disabled for thread scheduling
		/// purposes and lies dormant until one of three things happens:
		/// 
		/// <ul>
		/// 
		/// <li>The read lock is acquired by the current thread</li>
		/// <li>Some other thread calls <see cref="System.Threading.Thread.Interrupt()"/> on the current thread</li>
		/// <li>The <paramref name="durationToWait"/> elapses</li>
		/// </ul>
		/// 
		/// <p/>If the read lock is acquired then the value <see lang="true"/> is
		/// returned.
		/// 
		/// <p/>
		/// If another thread calls <see cref="System.Threading.Thread.Interrupt()"/> on the current thread
		/// then an <see cref="System.Threading.ThreadInterruptedException"/> is thrown
		/// 
		/// <p/>
		/// If the specified waiting time elapses then the value
		/// <see lang="false"/> is returned.  If the time is less than or
		/// equal to zero, the method will not wait at all.
		/// 
		/// <p/>
		/// In this implementation, as this method is an explicit
		/// interruption point, preference is given to responding to
		/// the interrupt over normal or reentrant acquisition of the
		/// lock, and over reporting the elapse of the waiting time.
		/// </remarks>
		/// <param name="durationToWait">the <see cref="System.TimeSpan"/> to wait for the read lock</param>
		/// <returns> <see lang="true"/> if the read lock was acquired, <see lang="false"/> otherwise.</returns>
		/// <exception cref="System.Threading.ThreadInterruptedException">if the current thread is interrupted.</exception>
		public override bool TryLock(TimeSpan durationToWait)
		{
			ThreadInterruptedException ie = null;
			TimeSpan duration = durationToWait;
			lock (this)
			{
				if (duration.TotalMilliseconds <= 0)
					return ReentrantReadWriteLock.StartRead();
				else if (ReentrantReadWriteLock.StartReadFromNewReader())
					return true;
				else
				{
					DateTime deadline = DateTime.Now.Add(duration);
					for (;;)
					{
						try
						{
							Monitor.Wait(this, durationToWait);
						}
						catch (ThreadInterruptedException ex)
						{
							ReentrantReadWriteLock.CancelWaitingReader();
							ie = ex;
							break;
						}
						if (ReentrantReadWriteLock.StartReadFromWaitingReader())
							return true;
						else
						{
							if (deadline.Subtract(DateTime.Now).TotalMilliseconds <= 0)
							{
								ReentrantReadWriteLock.CancelWaitingReader();
								break;
							}
						}
					}
				}
			}
			ReentrantReadWriteLock.SignallerWriterLock.SignalWaiters();
			if (ie != null) 
			{
				throw ie;
			}
			else 
			{
				return false; 
			}
		}

		/// <summary> 
		/// Throws <see cref="System.NotSupportedException"/> because read locks do not support conditions.
		/// </summary>
		/// <exception cref="System.NotSupportedException">Read locks do not support conditions.</exception>
		public override ICondition NewCondition()
		{
			throw new NotSupportedException();
		}

		/// <summary> 
		/// Returns a string identifying this lock, as well as its lock state.
		/// </summary>
		/// <remarks>
		/// The state, in brackets, includes the String
		/// "Read locks =" followed by the number of read locks held
		/// </remarks>
		/// <returns> a string identifying this lock, as well as its lock state.
		/// </returns>
		public override String ToString()
		{
			int readLockCount = ReentrantReadWriteLock.ReadLockCount;
			return base.ToString() + "[Read locks = " + readLockCount + "]";
		}
	}
}