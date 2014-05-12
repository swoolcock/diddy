using System;
using System.Threading;

namespace Spring.Threading.Locks
{
	/// <summary>
	/// Abstract base class for implementations of <see cref="Spring.Threading.Locks.ISignaller"/> and <see cref="Spring.Threading.Locks.ILock"/>
	/// <seealso cref="Spring.Threading.Locks.ReaderLock"/>
	/// <seealso cref="Spring.Threading.Locks.WriterLock"/>
	/// </summary>
	[Serializable]
	internal abstract class AbstractSignallerLock :  ISignaller, ILock, IDisposable
	{	
		private ReentrantReadWriteLock _reentrantReadWriteLock;

		#region Constructors
		protected AbstractSignallerLock(ReentrantReadWriteLock reentrantReadWriteLock)
		{
			_reentrantReadWriteLock = reentrantReadWriteLock;
		}
		#endregion

		#region Abstract Methods

		/// <summary> 
		/// Acquires the lock only if it is free at the time of invocation.
		/// </summary>
		/// <remarks>
		/// Acquires the lock if it is available and returns immediately
		/// with the value <see lang="true"/>. 
		/// If the lock is not available then this method will return
		/// immediately with the value <see lang="false"/>.
		/// <p/>
		/// A typical usage idiom for this method would be:
		/// <code> 
		/// ILock lock = ...;
		/// if (lock.TryLock()) {
		///		try {
		///		// manipulate protected state
		///		} finally {
		///			lock.Unlock();
		///		}
		/// } else {
		///		// perform alternative actions
		/// }
		/// </code>
		/// This usage ensures that the lock is unlocked if it was acquired, and
		/// doesn't try to unlock if the lock was not acquired.
		/// </remarks>
		/// <returns> <see lang="true"/> if the lock was acquired and <see lang="false"/> otherwise.</returns>
		public abstract bool TryLock();

		/// <summary> 
		/// Acquires the lock if it is free within the specified <paramref name="timeSpan"/> time and the
		/// current thread has not been interrupted by calling <see cref="System.Threading.Thread.Interrupt()"/>.
		/// </summary>
		/// <remarks> 
		/// If the lock is available this method returns immediately
		/// with the value <see lang="true"/>.
		/// If the lock is not available then
		/// the current thread becomes disabled for thread scheduling
		/// purposes and lies dormant until one of three things happens:
		/// <ul>
		/// <li>The lock is acquired by the current thread</li>
		/// <li>Some other thread interrupts the current
		/// thread, and interruption of lock acquisition is supported</li>
		/// <li>The specified <see cref="Thread.Interrupt"/> elapses</li>
		/// </ul>
		/// <p/>If the lock is acquired then the value <see lang="true"/> is returned.
		/// <p/>If the current thread:
		/// <ul>
		/// <li>has its interrupted status set on entry to this method</li>
		/// <li>is interrupted while acquiring
		/// the lock, and interruption of lock acquisition is supported</li>
		/// </ul>
		/// then <see cref="TimeSpan"/> is thrown and the current thread's
		/// interrupted status is cleared.
		/// 
		/// <p/>
		/// If the specified <paramref name="timeSpan"/> elapses then the value <see lang="false"/>
		/// is returned.  If the <see cref="ThreadInterruptedException"/> is less than or equal to zero, the method will not wait at all.
		/// 
		/// <p/>
		/// <b>Implementation Considerations</b>
		/// <p/>The ability to interrupt a lock acquisition in some implementations
		/// may not be possible, and if possible may
		/// be an expensive operation.
		/// The programmer should be aware that this may be the case. An
		/// implementation should document when this is the case.
		/// <p/>
		/// An implementation can favor responding to an interrupt over normal
		/// method return, or reporting a timeout.
		/// <p/>
		/// A <see cref="TimeSpan"/> implementation may be able to detect
		/// erroneous use of the lock, such as an invocation that would cause
		/// deadlock, and may throw an (unchecked) exception in such circumstances.
		/// The circumstances and the exception type must be documented by that
		/// <see cref="Spring.Threading.Locks.ILock"/> implementation.
		/// </remarks>
		/// <param name="timeSpan">the specificed <see cref="ILock"/> to wait to aquire lock.</param>
		/// <returns> <see lang="true"/> if the lock was acquired and <see lang="false"/>
		/// if the waiting time elapsed before the lock was acquired.
		/// </returns>
		/// <seealso cref="TimeSpan"/>
		/// <exception cref="System.Threading.ThreadInterruptedException">
		/// if the current thread is interrupted while aquirign the lock ( and interruption
		/// of lock acquisition is supported).</exception>
		public abstract bool TryLock(TimeSpan timeSpan);

		/// <summary> 
		/// Releases the lock.
		/// </summary>
		/// <remarks>
		/// <b>Implementation Considerations</b>
		/// <p/>A <see cref="Spring.Threading.Locks.ILock"/> implementation will usually impose
		/// restrictions on which thread can release a lock (typically only the
		/// holder of the lock can release it) and may throw
		/// an exception if the restriction is violated.
		/// Any restrictions and the exception type must be documented by that <see cref="Spring.Threading.Locks.ILock"/> implementation.
		/// </remarks>
		public abstract void Unlock();

		/// <summary> 
		/// Returns a new <see cref="ILock"/> instance that is bound to this
		/// <see cref="ICondition"/> instance.
		/// </summary>
		/// <remarks>
		/// Before waiting on the condition the lock must be held by the
		/// current thread.
		/// A call to <see cref="ILock"/> will atomically release the lock
		/// before waiting and re-acquire the lock before the wait returns.
		/// <p/>
		/// <b>Implementation Considerations</b>
		/// <p/>
		/// The exact operation of the <see cref="InvalidOperationException"/> instance depends on the
		/// <see cref="Spring.Threading.Locks.ILock"/> implementation and must be documented by that
		/// implementation.
		/// </remarks>
		/// <returns> A new <see cref="Spring.Threading.Locks.ICondition"/> instance for this 
		/// <see cref="Spring.Threading.Locks.ILock"/> instance.
		/// </returns>
		/// <exception cref="ICondition.Await()">
		/// if this <see cref="ICondition"/> 
		/// implementation does not support conditions.
		/// </exception>
		public abstract ICondition NewCondition();

		/// <summary> 
		/// Acquires the lock unless the current thread is
		/// interrupted by a call to <see cref="ILock"/>.
		/// </summary>
		/// <remarks>
		/// Acquires the lock if it is available and returns immediately.
		/// <p/>
		/// If the lock is not available then
		/// the current thread becomes disabled for thread scheduling
		/// purposes and lies dormant until one of two things happens:
		/// <ul>
		/// <li>The lock is acquired by the current thread</li>
		/// <li>Some other thread interrupts the current
		/// thread by calling <see cref="System.Threading.Thread.Interrupt()"/>, and interruption of lock acquisition is supported.</li>
		/// </ul>
		/// <p/>
		/// If the current thread:
		/// <ul>
		/// <li>has its interrupted status set on entry to this method</li>
		/// <li>is interrupted while acquiring the lock, and interruption of lock acquisition is supported</li>
		/// </ul>
		/// then <see cref="Thread.Interrupt"/> is thrown and the current thread's
		/// interrupted status is cleared.
		/// 
		/// <p/>
		/// <b>Implementation Considerations</b>
		/// 
		/// <p/>
		/// The ability to interrupt a lock acquisition in some
		/// implementations may not be possible, and if possible may be an
		/// expensive operation.  The programmer should be aware that this
		/// may be the case. An implementation should document when this is
		/// the case.
		/// 
		/// <p/>
		/// An implementation can favor responding to an interrupt over
		/// normal method return.
		/// 
		/// <p/>
		/// A <see cref="ThreadInterruptedException"/> implementation may be able to detect
		/// erroneous use of the lock, such as an invocation that would
		/// cause deadlock, and may throw an (unchecked) exception in such
		/// circumstances.  The circumstances and the exception type must
		/// be documented by that <see cref="Thread.Interrupt"/> implementation.
		/// </remarks>
		/// <seealso cref="ThreadInterruptedException"/>
		/// <exception cref="ILock">
		/// if the current thread is interrupted while acquiring the lock 
		/// ( and interruption of lock acquisition is supported )
		/// </exception>
		public abstract IDisposable LockInterruptibly();
		#endregion

		#region Propertues
		/// <summary>
		/// Gets the <see cref="Spring.Threading.Locks.ReentrantReadWriteLock"/> associated with this lock.
		/// </summary>
		public ReentrantReadWriteLock ReentrantReadWriteLock
		{
			get { return _reentrantReadWriteLock; }

		}
		#endregion
		
		#region Public Methods	
		/// <summary> 
		/// Acquires the read lock.
		/// </summary>
		/// <remarks>
		/// Acquires the read lock if the write lock is not held by
		/// another thread and returns immediately.
		/// 
		/// <p/>
		/// If the write lock is held by another thread then
		/// the current thread becomes disabled for thread scheduling
		/// purposes and lies dormant until the read lock has been acquired.
		/// </remarks>
		public virtual IDisposable Lock()
		{
			bool wasInterrupted = false;
			while (true)
			{
				try
				{
					LockInterruptibly();
					if (wasInterrupted)
					{
						Thread.CurrentThread.Interrupt();
					}
					return this;
				}
				catch (ThreadInterruptedException)
				{
					wasInterrupted = true;
				}
			}
		}

		
		/// <summary>
		/// Notify waiting objects.
		/// </summary>
		public  void SignalWaiters()
		{
			lock (this)
			{
				Monitor.PulseAll(this);
			}
		}
		#endregion

        #region IDisposable Members

        public void Dispose()
        {
            Unlock();
        }

        #endregion
    }
}
