using System;

namespace Spring.Threading.Locks
{
	/// <summary> 
	/// <see cref="Spring.Threading.Locks.ILock"/> implementations provide more extensive locking
	/// operations than can be obtained using <see lang="lock"/> 
	/// statements.  They allow more flexible structuring, may have
	/// quite different properties, and may support multiple associated
	/// <see cref="Spring.Threading.Locks.ICondition"/> objects.
	/// <p/>
	/// A lock is a tool for controlling access to a shared resource by
	/// multiple threads. Commonly, a lock provides exclusive access to a
	/// shared resource: only one thread at a time can acquire the lock and
	/// all access to the shared resource requires that the lock be
	/// acquired first. However, some locks may allow concurrent access to
	/// a shared resource, such as the read lock of a <see cref="Spring.Threading.Locks.IReadWriteLock"/> 
	/// <p/>
	/// The use of <see lang="lock"/> statement provides
	/// access to the implicit monitor lock associated with every object, but
	/// forces all lock acquisition and release to occur in a block-structured way:
	/// when multiple locks are acquired they must be released in the opposite
	/// order, and all locks must be released in the same lexical scope in which
	/// they were acquired.
	/// <p/>
	/// While the scoping mechanism for <see lang="lock"/> 
	/// statements makes it much easier to program with monitor locks,
	/// and helps avoid many common programming errors involving locks,
	/// there are occasions where you need to work with locks in a more
	/// flexible way. For example, some algorithms for traversing
	/// concurrently accessed data structures require the use of
	/// 'hand-over-hand' or 'chain locking': you
	/// acquire the lock of node A, then node B, then release A and acquire
	/// C, then release B and acquire D and so on.  Implementations of the
	/// <see cref="Spring.Threading.Locks.ILock"/> interface enable the use of such techniques by
	/// allowing a lock to be acquired and released in different scopes,
	/// and allowing multiple locks to be acquired and released in any
	/// order.
	/// <p/>
	/// With this increased flexibility comes additional
	/// responsibility. The absence of block-structured locking removes the
	/// automatic release of locks that occurs with <see lang="lock"/> 
	/// statements. In most cases, the following idiom
	/// should be used:
	/// 
	/// <code>
	/// ILock l = ...;
	/// l.Lock();
	/// try {
	/// // access the resource protected by this lock
	/// } finally {
	///		l.Unlock();
	/// }
	/// </code> 
	///	<p/> 
	/// When locking and unlocking occur in different scopes, care must be
	/// taken to ensure that all code that is executed while the lock is
	/// held is protected by try-finally or try-catch to ensure that the
	/// lock is released when necessary.
	/// 
	/// <p/>
	/// <see cref="Spring.Threading.Locks.ILock"/> implementations provide additional functionality
	/// over the use of <see lang="lock"/> statement by
	/// providing a non-blocking attempt to acquire a lock (<see cref="Spring.Threading.Locks.ILock.TryLock()"/>)
	/// , an attempt to acquire the lock that can be
	/// interrupted <see cref="Spring.Threading.Locks.ILock.LockInterruptibly()"/>}, and an attempt to acquire
	/// the lock that can timeout <see cref="Spring.Threading.Locks.ILock.TryLock(TimeSpan)"/>).
	/// 
	/// <p/>
	/// A <see cref="Spring.Threading.Locks.ILock"/> class can also provide behavior and semantics
	/// that is quite different from that of the implicit monitor lock,
	/// such as guaranteed ordering, non-reentrant usage, or deadlock
	/// detection. If an implementation provides such specialized semantics
	/// then the implementation must document those semantics.
	/// 
	/// <p/>
	/// Note that <see cref="Spring.Threading.Locks.ILock"/> instances are just normal objects and can
	/// themselves be used as the target in a <see lang="lock"/> statement.
	/// Acquiring the monitor lock of a <see cref="Spring.Threading.Locks.ILock"/> instance has no specified relationship
	/// with invoking any of the <see cref="Spring.Threading.Locks.ILock.Lock()"/> methods of that instance.
	/// It is recommended that to avoid confusion you never use <see cref="Spring.Threading.Locks.ILock"/> 
	/// instances in this way, except within their own implementation.
	/// 
	/// <p/>
	/// Except where noted, passing a <see lang="null"/> value for any
	/// parameter will result in a <see cref="System.NullReferenceException"/> being
	/// thrown.
	/// 
	/// <h3>Memory Synchronization</h3>
	/// <p/>All <see cref="Spring.Threading.Locks.ILock"/> implementations <b>must</b> enforce the same
	/// memory synchronization semantics as provided by the built-in monitor
	/// lock. 
	/// <ul>
	/// <li>A successful <see cref="Spring.Threading.Locks.ILock.Lock()"/> operation has the same memory
	/// synchronization effects as a successful <see cref="System.Threading.Monitor.Enter(object)"/> action.</li>
	/// <li>A successful <see cref="Spring.Threading.Locks.ILock.Unlock()"/> operation has the same
	/// memory synchronization effects as a successful <see cref="System.Threading.Monitor.Exit(object)"/>  action.</li>
	/// </ul>
	/// 
	/// Unsuccessful locking and unlocking operations, and reentrant
	/// locking/unlocking operations, do not require any memory
	/// synchronization effects.
	/// 
	/// <h3>Implementation Considerations</h3>
	/// 
	/// <p/> 
	/// The three forms of lock acquisition (interruptible,
	/// non-interruptible, and timed) may differ in their performance
	/// characteristics, ordering guarantees, or other implementation
	/// qualities.  Further, the ability to interrupt the <b>ongoing</b>
	/// acquisition of a lock may not be available in a given <see cref="Spring.Threading.Locks.ILock"/>
	/// class.  Consequently, an implementation is not required to define
	/// exactly the same guarantees or semantics for all three forms of
	/// lock acquisition, nor is it required to support interruption of an
	/// ongoing lock acquisition.  An implementation is required to clearly
	/// document the semantics and guarantees provided by each of the
	/// locking methods. It must also obey the interruption semantics as
	/// defined in this interface, to the extent that interruption of lock
	/// acquisition is supported: which is either totally, or only on
	/// method entry.
	/// 
	/// <p/>
	/// As interruption generally implies cancellation, and checks for
	/// interruption are often infrequent, an implementation can favor responding
	/// to an interrupt over normal method return. This is true even if it can be
	/// shown that the interrupt occurred after another action may have unblocked
	/// the thread. An implementation should document this behavior.
	/// </summary>
	/// <seealso cref="Spring.Threading.Locks.ReentrantLock"/>
	/// <seealso cref="Spring.Threading.Locks.ICondition"/>
	/// <seealso cref="Spring.Threading.Locks.IReadWriteLock"/>
	/// <author>Doug Lea</author>
	/// <author>Griffin Caprio (.NET)</author>
	public interface ILock
	{
		/// <summary> 
		/// Acquires the lock.
		/// <p/>
		/// If the lock is not available then
		/// the current thread becomes disabled for thread scheduling
		/// purposes and lies dormant until the lock has been acquired.
		/// <p/>
		/// <b>Implementation Considerations</b>
		/// <p/>A <see cref="Spring.Threading.Locks.ILock"/> implementation may be able to detect
		/// erroneous use of the lock, such as an invocation that would cause
		/// deadlock, and may throw an (unchecked) exception in such circumstances.
		/// The circumstances and the exception type must be documented by that
		/// <see cref="Spring.Threading.Locks.ILock"/> implementation.
		/// </summary>
		IDisposable Lock();

		/// <summary> 
		/// Acquires the lock unless the current thread is
		/// interrupted by a call to <see cref="System.Threading.Thread.Interrupt()"/>.
		/// <p/>
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
		/// then <see cref="System.Threading.ThreadInterruptedException"/> is thrown and the current thread's
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
		/// A <see cref="Spring.Threading.Locks.ILock"/> implementation may be able to detect
		/// erroneous use of the lock, such as an invocation that would
		/// cause deadlock, and may throw an (unchecked) exception in such
		/// circumstances.  The circumstances and the exception type must
		/// be documented by that <see cref="Spring.Threading.Locks.ILock"/> implementation.
		/// </summary>
		/// <seealso cref="System.Threading.Thread.Interrupt()"/>
		/// <exception cref="System.Threading.ThreadInterruptedException">
		/// if the current thread is interrupted while acquiring the lock 
		/// ( and interruption of lock acquisition is supported )
		/// </exception>
		IDisposable LockInterruptibly();

		/// <summary> 
		/// Acquires the lock only if it is free at the time of invocation.
		/// <p/>
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
		/// </summary>
		/// <returns> <see lang="true"/> if the lock was acquired and <see lang="false"/> otherwise.</returns>
		bool TryLock();

		/// <summary> 
		/// Acquires the lock if it is free within the specified <paramref name="timeSpan"/> time and the
		/// current thread has not been interrupted by calling <see cref="System.Threading.Thread.Interrupt()"/>.
		/// 
		/// <p/>
		/// If the lock is available this method returns immediately
		/// with the value <see lang="true"/>.
		/// If the lock is not available then
		/// the current thread becomes disabled for thread scheduling
		/// purposes and lies dormant until one of three things happens:
		/// <ul>
		/// <li>The lock is acquired by the current thread</li>
		/// <li>Some other thread interrupts the current
		/// thread, and interruption of lock acquisition is supported</li>
		/// <li>The specified <see cref="System.TimeSpan"/> elapses</li>
		/// </ul>
		/// <p/>If the lock is acquired then the value <see lang="true"/> is returned.
		/// <p/>If the current thread:
		/// <ul>
		/// <li>has its interrupted status set on entry to this method</li>
		/// <li>is interrupted while acquiring
		/// the lock, and interruption of lock acquisition is supported</li>
		/// </ul>
		/// then <see cref="System.Threading.ThreadInterruptedException"/> is thrown and the current thread's
		/// interrupted status is cleared.
		/// 
		/// <p/>
		/// If the specified <paramref name="timeSpan"/> elapses then the value <see lang="false"/>
		/// is returned.  If the <see cref="System.TimeSpan"/> is less than or equal to zero, the method will not wait at all.
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
		/// A <see cref="Spring.Threading.Locks.ILock"/> implementation may be able to detect
		/// erroneous use of the lock, such as an invocation that would cause
		/// deadlock, and may throw an (unchecked) exception in such circumstances.
		/// The circumstances and the exception type must be documented by that
		/// <see cref="Spring.Threading.Locks.ILock"/> implementation.
		/// </summary>
		/// <param name="timeSpan">the specificed <see cref="System.TimeSpan"/> to wait to aquire lock.</param>
		/// <returns> <see lang="true"/> if the lock was acquired and <see lang="false"/>
		/// if the waiting time elapsed before the lock was acquired.
		/// </returns>
		/// <seealso cref="System.Threading.Thread.Interrupt()"/>
		/// <exception cref="System.Threading.ThreadInterruptedException">
		/// if the current thread is interrupted while aquirign the lock ( and interruption
		/// of lock acquisition is supported).</exception>
		bool TryLock( TimeSpan timeSpan );

		/// <summary> 
		/// Releases the lock.
		/// <p/>
		/// <b>Implementation Considerations</b>
		/// <p/>A <see cref="Spring.Threading.Locks.ILock"/> implementation will usually impose
		/// restrictions on which thread can release a lock (typically only the
		/// holder of the lock can release it) and may throw
		/// an exception if the restriction is violated.
		/// Any restrictions and the exception type must be documented by that <see cref="Spring.Threading.Locks.ILock"/> implementation.
		/// </summary>
		void Unlock();

		/// <summary> 
		/// Returns a new <see cref="Spring.Threading.Locks.ICondition"/> instance that is bound to this
		/// <see cref="Spring.Threading.Locks.ILock"/> instance.
		/// <p/>
		/// Before waiting on the condition the lock must be held by the
		/// current thread.
		/// A call to <see cref="Spring.Threading.Locks.ICondition.Await()"/> will atomically release the lock
		/// before waiting and re-acquire the lock before the wait returns.
		/// <p/>
		/// <b>Implementation Considerations</b>
		/// <p/>
		/// The exact operation of the <see cref="Spring.Threading.Locks.ICondition"/> instance depends on the
		/// <see cref="Spring.Threading.Locks.ILock"/> implementation and must be documented by that
		/// implementation.
		/// </summary>
		/// <returns> A new <see cref="Spring.Threading.Locks.ICondition"/> instance for this 
		/// <see cref="Spring.Threading.Locks.ILock"/> instance.
		/// </returns>
		/// <exception cref="System.InvalidOperationException">
		/// if this <see cref="Spring.Threading.Locks.ILock"/> 
		/// implementation does not support conditions.
		/// </exception>
		ICondition NewCondition();
	}
}