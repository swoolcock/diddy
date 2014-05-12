using System;
using System.Threading;

namespace Spring.Threading.Locks
{
	[Serializable]
	internal class WriterLock : AbstractSignallerLock, IExclusiveLock
	{
		#region Constructors

		/// <summary>
		/// Constructs a <see cref="Spring.Threading.Locks.WriterLock"/>, using the given <see cref="Spring.Threading.Locks.ReentrantReadWriteLock"/>
		/// </summary>
		/// <param name="reentrantReadWriteLock"><see cref="Spring.Threading.Locks.ReentrantReadWriteLock"/> to use for this lock.</param>
		public WriterLock(ReentrantReadWriteLock reentrantReadWriteLock) : base(reentrantReadWriteLock)
		{
		}

		#endregion

		#region Public Properties

		/// <summary>
		/// Queries if the lock is held by the current thread.
		/// </summary>
		public bool IsHeldByCurrentThread
		{
			get { return ReentrantReadWriteLock.WriterLockedByCurrentThread; }
		}

	    public int HoldCount
	    {
            get { return ReentrantReadWriteLock.WriteHoldCount; }
	    }

	    #endregion

		#region Abstract Implementation Methods
		/// <summary> 
		///	Acquires the write lock unless <see cref="System.Threading.Thread.Interrupt()"/> is called on the current thread
		/// </summary>
		/// <remarks>
		/// Acquires the write lock if neither the read nor write locks
		/// are held by another thread
		/// and returns immediately, setting the write lock hold count to
		/// one.
		/// 
		/// <p/>
		/// If the current thread already holds this lock then the
		/// hold count is incremented by one and the method returns
		/// immediately.
		/// 
		/// <p/>
		/// If the lock is held by another thread then the current
		/// thread becomes disabled for thread scheduling purposes and
		/// lies dormant until one of two things happens:
		/// 
		/// <ul>
		/// <li>The write lock is acquired by the current thread.</li>
		/// <li>Some other thread calls <see cref="System.Threading.Thread.Interrupt()"/> on the current thread.</li>
		/// </ul>
		/// 
		/// <p/>
		/// If the write lock is acquired by the current thread then the
		/// lock hold count is set to one.
		/// 
		/// <p/>
		/// If the current thread:
		/// <ul>
		/// <li>has its interrupted status set on entry to this method</li>
		/// <li><see cref="System.Threading.Thread.Interrupt()"/> is called on the thread while acquiring the write lock.</li>
		/// </ul>
		/// 
		/// then a <see cref="System.Threading.ThreadInterruptedException"/> is thrown and the current
		/// thread's interrupted status is cleared.
		/// 
		/// <p/>
		/// In this implementation, as this method is an explicit
		/// interruption point, preference is given to responding to
		/// the interrupt over normal or reentrant acquisition of the
		/// lock.
		/// 
		/// </remarks>
		/// <exception cref="System.Threading.ThreadInterruptedException">if the current thread is interrupted.</exception>
		public override IDisposable LockInterruptibly()
		{
			ThreadInterruptedException ie = null;
			lock (this)
			{
				if (!ReentrantReadWriteLock.StartWriteFromNewWriter())
				{
					for (;; )
					{
						try
						{
							Monitor.Wait(this);
							if (ReentrantReadWriteLock.StartWriteFromWaitingWriter())
								return this;
						}
						catch (ThreadInterruptedException ex)
						{
							ReentrantReadWriteLock.CancelWaitingWriter();
							Monitor.Pulse(this);
							ie = ex;
							break;
						}
					}
				}
			}
			if (ie != null)
			{
				// Fall through outside synch on interrupt.
				//  On exception, we may need to signal readers.
				//  It is not worth checking here whether it is strictly necessary.
				ReentrantReadWriteLock.SignallerReaderLock.SignalWaiters();
				throw ie;
			}
		    return this;
		}

		/// <summary> 
		/// Attempts to release this lock.
		/// </summary>
		/// <remarks>
		/// If the current thread is the holder of this lock then
		/// the hold count is decremented. If the hold count is now
		/// zero, the lock is released.  If the current thread is
		/// not the holder of this lock then <see cref="System.Threading.SynchronizationLockException"/>
		/// is thrown.
		/// </remarks>
		/// <exception cref="System.Threading.SynchronizationLockException">if the current thread is not the holder of this lock.</exception>
		public override void Unlock()
		{
		    if (! IsHeldByCurrentThread)
		    {
		        throw new SynchronizationLockException("Current thread does not hold this lock.");
		    }
		    switch (ReentrantReadWriteLock.EndWrite())
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
		/// Acquires the write lock only if it is not held by another thread
		/// at the time of invocation.
		/// </summary>
		/// <remarks>
		/// Acquires the write lock if neither the read nor write lock
		/// are held by another thread
		/// and returns immediately with the value <see lang="true"/>,
		/// setting the write lock hold count to one. Even when this lock has
		/// been set to use a fair ordering policy, a call to
		/// <see cref="Spring.Threading.Locks.WriterLock.TryLock()"/>
		/// <b>will</b> immediately acquire the
		/// lock if it is available, whether or not other threads are
		/// currently waiting for the write lock.  This "barging"
		/// behavior can be useful in certain circumstances, even
		/// though it breaks fairness. If you want to honor the
		/// fairness setting for this lock, then use <see cref="Spring.Threading.Locks.ILock.TryLock(TimeSpan)"/> 
		/// which is almost equivalent (it also detects interruption).
		/// 
		/// <p/> 
		/// If the current thread already holds this lock then the
		/// hold count is incremented by one and the method returns
		/// <see lang="true"/>.
		/// 
		/// <p/>
		/// If the lock is held by another thread then this method
		/// will return immediately with the value <see lang="false"/>.
		/// 
		/// </remarks>
		/// <returns> <see lang="true"/> if the lock was free and was acquired
		/// by the current thread, or the write lock was already held
		/// by the current thread; and <see lang="false"/> otherwise.
		/// </returns>
		public override bool TryLock()
		{
			return ReentrantReadWriteLock.StartWrite();
		}

		/// <summary> 
		/// Acquires the write lock if it is not held by another thread
		/// within the given waiting time and <see cref="System.Threading.Thread.Interrupt()"/> has not been called on the current thread
		/// </summary>
		/// <remarks>
		/// Acquires the write lock if neither the read nor write lock
		/// are held by another thread
		/// and returns immediately with the value <see lang="true"/>,
		/// setting the write lock hold count to one. If this lock has been
		/// set to use a fair ordering policy then an available lock
		/// <b>will not</b> be acquired if any other threads are
		/// waiting for the write lock. This is in contrast to the <see cref="Spring.Threading.Locks.WriterLock.TryLock()"/>
		/// If you want a timed <see cref="Spring.Threading.Locks.WriterLock.TryLock()"/>
		/// that does permit barging on a fair lock, then combine the
		/// timed and un-timed forms together:
		/// 
		/// <code>
		/// if (lock.TryLock() || lock.tryLock(timeSpan) ) { ... }
		/// </code>
		/// 
		/// <p/>
		/// If the current thread already holds this lock then the
		/// hold count is incremented by one and the method returns
		/// <see lang="true"/>.
		/// 
		/// <p/>
		/// If the lock is held by another thread then the current
		/// thread becomes disabled for thread scheduling purposes and
		/// lies dormant until one of three things happens:
		/// 
		/// <ul>
		/// <li>The write lock is acquired by the current thread</li>
		/// <li>Some other thread calls <see cref="System.Threading.Thread.Interrupt()"/>
		/// on the current thread</li>
		/// <li>The specified <see cref="System.TimeSpan"/> elapses</li>
		/// </ul>
		/// 
		/// <p/>
		/// If the write lock is acquired then the value <see lang="true"/> is
		/// returned and the write lock hold count is set to one.
		/// 
		/// <p/>
		/// If the current thread has <see cref="System.Threading.Thread.Interrupt()"/> called on it while acquiring
		/// the write lock, then a <see cref="System.Threading.ThreadInterruptedException"/> is thrown.
		/// 
		/// <p/>
		/// If the specified <see cref="System.TimeSpan"/> elapses then the value
		/// <see lang="false"/> is returned.  If the time is less than or
		/// equal to zero, the method will not wait at all.
		/// 
		/// <p/>
		/// In this implementation, as this method is an explicit
		/// interruption point, preference is given to responding to
		/// the interrupt over normal or reentrant acquisition of the
		/// lock, and over reporting the elapse of the waiting time.
		/// 
		/// </remarks>
		/// <param name="durationToWait">the time to wait for the write lock</param>
		/// <returns> <see lang="true"/> if the lock was free and was acquired
		/// by the current thread, or the write lock was already held by the
		/// current thread; and <see lang="false"/> if the waiting time
		/// elapsed before the lock could be acquired.
		/// </returns>
		/// 
		/// <exception cref="System.Threading.ThreadInterruptedException">if the current thread is interrupted.</exception>
		public override bool TryLock(TimeSpan durationToWait)
		{
			ThreadInterruptedException ie = null;
			lock (this)
			{
				if (durationToWait.TotalMilliseconds <= 0)
					return ReentrantReadWriteLock.StartWrite();
				else if (ReentrantReadWriteLock.StartWriteFromNewWriter())
					return true;
				else
				{
					DateTime deadline = DateTime.Now.Add(durationToWait);
					for (;; )
					{
						try
						{
							Monitor.Wait(this, durationToWait);
						}
						catch (ThreadInterruptedException ex)
						{
							ReentrantReadWriteLock.CancelWaitingWriter();
							Monitor.Pulse(this);
							ie = ex;
							break;
						}
						if (ReentrantReadWriteLock.StartWriteFromWaitingWriter())
							return true;
						else
						{
							if (deadline.Subtract(DateTime.Now).TotalMilliseconds <= 0)
							{
								ReentrantReadWriteLock.CancelWaitingWriter();
								Monitor.Pulse(this);
								break;
							}
						}
					}
				}
			}

			ReentrantReadWriteLock.SignallerReaderLock.SignalWaiters();
			if (ie != null)
				throw ie;
			else
				return false;
		}

		/// <summary> 
		/// Returns a <see cref="Spring.Threading.Locks.ICondition"/> instance for use with this
		/// <see cref="Spring.Threading.Locks.WriterLock"/> instance.
		/// </summary>
		/// <remarks>
		/// The returned <see cref="Spring.Threading.Locks.ICondition"/> instance supports the same
		/// usages as do the <see cref="System.Threading.Monitor"/> methods (<see cref="System.Threading.Monitor.Wait(object)"/>,
		/// <see cref="System.Threading.Monitor.Pulse(object)"/>, and <see cref="System.Threading.Monitor.PulseAll"/>)
		/// when used with the built-in monitor lock.
		/// 
		/// <ul>
		/// 
		/// <li>
		/// If this write lock is not held when any <see cref="Spring.Threading.Locks.ICondition"/>
		/// method is called then a <see cref="System.Threading.SynchronizationLockException"/> is thrown.  
		/// (Read locks are held independently of write locks, so are not checked or
		/// affected. However it is essentially always an error to
		/// invoke a condition waiting method when the current thread
		/// has also acquired read locks, since other threads that
		/// could unblock it will not be able to acquire the write
		/// lock.)
		/// </li>
		/// 
		/// <li>
		/// When any of the <see cref="Spring.Threading.Locks.ICondition"/> await
		/// methods are called the write lock is released and, before
		/// they return, the write lock is reacquired and the lock hold
		/// count restored to what it was when the method was called.
		/// </li> 
		/// 
		/// <li>
		/// If <see cref="System.Threading.Thread.Interrupt()"/> is called on the thread while
		/// waiting then the wait will terminate, a <see cref="System.Threading.ThreadInterruptedException"/>
		/// will be thrown.
		/// </li> 
		/// 
		/// <li> Waiting threads are signalled in FIFO order.</li>
		/// 
		/// <li>The ordering of lock reacquisition for threads returning
		/// from waiting methods is the same as for threads initially
		/// acquiring the lock, which is in the default case not specified,
		/// but for <b>fair</b> locks favors those threads that have been
		/// waiting the longest.
		/// </li> 
		/// </ul>
		/// </remarks>
		/// <returns> A new <see cref="Spring.Threading.Locks.ICondition"/> for this instance.</returns>
		public override ICondition NewCondition()
		{
			return new ConditionVariable(this);
		}
		#endregion

		/// <summary> 
		/// Returns a string identifying this lock, as well as its lock
		/// state.  The state, in brackets includes either the string
		/// "Unlocked" or the string "Locked by:"
		/// followed by the value of <see cref="System.Threading.Thread.Name"/> for the owning thread.
		/// </summary>
		/// <returns> a string identifying this lock, including its lock state.</returns>
		public override String ToString()
		{
			Thread owningThread = ReentrantReadWriteLock.Owner;
			return base.ToString() + ((owningThread == null) ? "[Unlocked]" : "[Locked by thread " + owningThread.Name + "]");
		}
	}

}