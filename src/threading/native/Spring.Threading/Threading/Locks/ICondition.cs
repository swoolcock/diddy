using System;
using Spring.Threading.Collections.Generic;

namespace Spring.Threading.Locks
{
	/// <summary> <see cref="Spring.Threading.Locks.ICondition"/> factors out the <see cref="System.Threading.Monitor"/>
	/// methods <see cref="System.Threading.Monitor.Wait(object)"/>, <see cref="System.Threading.Monitor.Pulse(object)"/>
	/// and <see cref="System.Threading.Monitor.PulseAll(object)"/> into distinct objects to
	/// give the effect of having multiple wait-sets per object, by
	/// combining them with the use of arbitrary <see cref="Spring.Threading.Locks.ILock"/> implementations.
	/// Where a <see cref="Spring.Threading.Locks.ILock"/> replaces the use of <see lang="lock"/>
	/// statements, a <see cref="Spring.Threading.Locks.ICondition"/> replaces the use of the <see cref="System.Threading.Monitor"/>
	/// methods.
	/// 
	/// <p/>
	/// Conditions (also known as <b>condition queues</b> or
	/// <b>condition variables</b>) provide a means for one thread to
	/// suspend execution (to 'wait') until notified by another
	/// thread that some state condition may now be true.  Because access
	/// to this shared state information occurs in different threads, it
	/// must be protected, so a lock of some form is associated with the
	/// condition. The key property that waiting for a condition provides
	/// is that it <b>atomically</b> releases the associated lock and
	/// suspends the current thread, just like <see cref="System.Threading.Monitor.Wait(object)"/>.
	/// 
	/// <p/>
	/// A <see cref="Spring.Threading.Locks.ICondition"/> instance is intrinsically bound to a lock.
	/// To obtain a <see cref="Spring.Threading.Locks.ICondition"/> instance for a particular <see cref="Spring.Threading.Locks.ILock"/>
	/// instance use its <see cref="Spring.Threading.Locks.ILock.NewCondition()"/> method.
	/// 
	/// <p/>
	/// As an example, suppose we have a bounded buffer which supports
	/// put and take methods.  If a
	/// take is attempted on an empty buffer, then the thread will block
	/// until an item becomes available; if a put is attempted on a
	/// full buffer, then the thread will block until a space becomes available.
	/// We would like to keep waiting put threads and take
	/// threads in separate wait-sets so that we can use the optimization of
	/// only notifying a single thread at a time when items or spaces become
	/// available in the buffer. This can be achieved using two
	/// {@link <see cref="Spring.Threading.Locks.ICondition"/>} instances.
	/// <code>
	/// class BoundedBuffer {
	///		final ILock lock = new ReentrantLock();
	/// 	final ICondition notFull  = lock.NewCondition();
	/// 	final ICondition notEmpty = lock.NewCondition();
	/// 
	/// 	final object[] items = new object[100];
	/// 	int putptr, takeptr, count;
	/// 
	/// 	public void Put(object x) throws InterruptedException {
	///			lock.Lock();
	///			try {
	///				while (count == items.length) {
	///					notFull.Await();
	///					items[putptr] = x;
	///	 				if (++putptr == items.length) putptr = 0;
	///	 				++count;
	///	 				notEmpty.Signal();
	///	 			}
	///			} finally {
	///				lock.Unlock();
	///			}
	///	 }
	///	 
	///	 public object Take() throws InterruptedException {
	///			lock.Lock();
	///	 		try {
	///	 			while (count == 0) {
	///	 				notEmpty.Await();
	///	 				Object x = items[takeptr];
	///	 				if (++takeptr == items.length) takeptr = 0;
	///	 				--count;
	///	 				notFull.Signal();
	///	 			return x;
	///	 		} finally {
	///	 			lock.unlock();
	///	 		}
	///	 	}
	/// }
	/// </code>
	/// 
	/// (The <see cref="ArrayBlockingQueue{T}"/> class provides
	/// this functionality, so there is no reason to implement this
	/// sample usage class.)
	/// 
	/// <p/>
	/// A <see cref="Spring.Threading.Locks.ICondition"/> implementation can provide behavior and semantics
	/// that is different from that of the <see cref="System.Threading.Monitor"/> methods, such as
	/// guaranteed ordering for notifications, or not requiring a lock to be held
	/// when performing notifications.
	/// If an implementation provides such specialized semantics then the
	/// implementation must document those semantics.
	/// 
	/// <p/>
	/// Note that <see cref="Spring.Threading.Locks.ICondition"/> instances are just normal objects and can
	/// themselves be used as the target in a synchronized statement,
	/// and can have <see cref="System.Threading.Monitor.Wait(object)"/> and
	/// <see cref="System.Threading.Monitor.Pulse(object)"/> methods invoked on them.
	/// Acquiring the monitor lock of a <see cref="Spring.Threading.Locks.ICondition"/> instance, or using it as a parameter to
	/// <see cref="System.Threading.Monitor"/> methods, has no specified relationship with acquiring the
	/// <see cref="Spring.Threading.Locks.ILock"/> associated with that <see cref="Spring.Threading.Locks.ICondition"/> or the use of its
	/// <see cref="Spring.Threading.Locks.ICondition.Await()"/> and <see cref="Spring.Threading.Locks.ICondition.Signal()"/> methods.
	/// It is recommended that to avoid confusion you never use <see cref="Spring.Threading.Locks.ICondition"/>
	/// instances in this way, except perhaps within their own implementation.
	/// 
	/// <p/>
	/// Except where noted, passing a <see lang="null"/> value for any parameter
	/// will result in a <see cref="System.NullReferenceException"/> being thrown.
	/// 
	/// <h3>Implementation Considerations</h3>
	/// 
	/// <p/>
	/// When waiting upon a <see cref="Spring.Threading.Locks.ICondition"/>, a '<b>spurious
	/// wakeup</b>'is permitted to occur, in
	/// general, as a concession to the underlying platform semantics.
	/// This has little practical impact on most application programs as a
	/// <see cref="Spring.Threading.Locks.ICondition"/> should always be waited upon in a loop, testing
	/// the state predicate that is being waited for.  An implementation is
	/// free to remove the possibility of spurious wakeups but it is
	/// recommended that applications programmers always assume that they can
	/// occur and so always wait in a loop.
	/// 
	/// <p/>
	/// The three forms of condition waiting
	/// (interruptible, non-interruptible, and timed) may differ in their ease of
	/// implementation on some platforms and in their performance characteristics.
	/// In particular, it may be difficult to provide these features and maintain
	/// specific semantics such as ordering guarantees.
	/// Further, the ability to interrupt the actual suspension of the thread may
	/// not always be feasible to implement on all platforms.
	/// <p/>
	/// Consequently, an implementation is not required to define exactly the
	/// same guarantees or semantics for all three forms of waiting, nor is it
	/// required to support interruption of the actual suspension of the thread.
	/// <p/>
	/// An implementation is required to
	/// clearly document the semantics and guarantees provided by each of the
	/// waiting methods, and when an implementation does support interruption of
	/// thread suspension then it must obey the interruption semantics as defined
	/// in this interface.
	/// <p/>
	/// As interruption generally implies cancellation, and checks for
	/// interruption are often infrequent, an implementation can favor responding
	/// to an interrupt over normal method return. This is true even if it can be
	/// shown that the interrupt occurred after another action may have unblocked
	/// the thread. An implementation should document this behavior.
	/// </summary>
	/// <author>Doug Lea</author>
	/// <author>Griffin Caprio (.NET)</author>
	public interface ICondition
	{
		/// <summary> 
		/// Causes the current thread to wait until it is signalled or
		/// <see cref="System.Threading.Thread.Interrupt()"/> is called.
		/// 
		/// <p/>
		/// The lock associated with this <see cref="Spring.Threading.Locks.ICondition"/> is atomically
		/// released and the current thread becomes disabled for thread scheduling
		/// purposes and lies dormant until <b>one</b> of four things happens:
		/// <ul>
		/// <li>Some other thread invokes the <see cref="Spring.Threading.Locks.ICondition.Signal()"/> method for this
		/// <see cref="Spring.Threading.Locks.ICondition"/> and the current thread happens to be chosen as the
		/// thread to be awakened</li>
		/// <li>Some other thread invokes the <see cref="Spring.Threading.Locks.ICondition.SignalAll()"/>} method for this
		/// <see cref="Spring.Threading.Locks.ICondition"/></li>
		/// <li>Some other thread <see cref="System.Threading.Thread.Interrupt()"/> is called the current
		/// thread, and interruption of thread suspension is supported</li>
		/// <li>A '<b>spurious wakeup</b>' occurs</li>
		/// </ul>
		/// 
		/// <p/>
		/// In all cases, before this method can return the current thread must
		/// re-acquire the lock associated with this condition. When the
		/// thread returns it is <b>guaranteed</b> to hold this lock.
		/// 
		/// <p/>If the current thread:
		/// <ul>
		/// <li>has its interrupted status set on entry to this method</li>
		/// <li><see cref="System.Threading.Thread.Interrupt()"/> is called while waiting
		/// and interruption of thread suspension is supported</li>
		/// </ul>
		/// then <see cref="System.Threading.ThreadInterruptedException"/> is thrown and the current thread's
		/// interrupted status is cleared. It is not specified, in the first
		/// case, whether or not the test for interruption occurs before the lock
		/// is released.
		/// 
		/// <p/><b>Implementation Considerations</b>
		/// 
		/// <p/>
		/// The current thread is assumed to hold the lock associated with this
		/// <see cref="Spring.Threading.Locks.ICondition"/> when this method is called.
		/// It is up to the implementation to determine if this is
		/// the case and if not, how to respond. Typically, an exception will be
		/// thrown (such as <see cref="System.Threading.SynchronizationLockException"/>) and the
		/// implementation must document that fact.
		/// 
		/// <p/>An implementation can favor responding to an interrupt over normal
		/// method return in response to a signal. In that case the implementation
		/// must ensure that the signal is redirected to another waiting thread, if
		/// there is one.
		/// </summary>
		/// <exception cref="System.Threading.ThreadInterruptedException">
		/// if the current threada is interrupted (and interruption of thread suspension is supported.
		/// </exception>
		void Await();

		/// <summary>
		/// Causes the current thread to wait until it is signalled.
		/// <p/>
		/// The lock associated with this condition is atomically
		/// released and the current thread becomes disabled for thread scheduling
		/// purposes and lies dormant until <b>one</b> of three things happens:
		/// <ul>
		/// <li>Some other thread invokes the <see cref="Spring.Threading.Locks.ICondition.Signal()"/> method for this
		/// <see cref="Spring.Threading.Locks.ICondition"/> and the current thread happens to be chosen as the
		/// thread to be awakened</li>
		/// <li>Some other thread invokes the <see cref="Spring.Threading.Locks.ICondition.SignalAll()"/>} method for this
		/// <see cref="Spring.Threading.Locks.ICondition"/></li>
		/// <li>A '<b>spurious wakeup</b>' occurs</li>
		/// </ul>
		/// 
		/// <p/>In all cases, before this method can return the current thread must
		/// re-acquire the lock associated with this condition. When the
		/// thread returns it is <b>guaranteed</b> to hold this lock.
		/// 
		/// <p/>If the current thread's interrupted status is set when it enters
		/// this method, or <see cref="System.Threading.Thread.Interrupt()"/> is called
		/// while waiting, it will continue to wait until signalled. When it finally
		/// returns from this method its interrupted status will still
		/// be set.
		/// 
		/// <p/><b>Implementation Considerations</b>
		/// <p/>The current thread is assumed to hold the lock associated with this
		/// <see cref="Spring.Threading.Locks.ICondition"/> when this method is called.
		/// It is up to the implementation to determine if this is
		/// the case and if not, how to respond. Typically, an exception will be
		/// thrown (such as <see cref="System.Threading.SynchronizationLockException"/>) and the
		/// implementation must document that fact.
		/// </summary>
		void AwaitUninterruptibly();

		/// <summary> 
		/// Causes the current thread to wait until it is signalled or interrupted,
		/// or the specified waiting time elapses.
		/// </summary>
		/// <param name="timeSpan">the maximum time to wait
		/// </param>
		/// <returns> <see lang="false"/> if the waiting time detectably elapsed
		/// before return from the method, else <see lang="true"/>.
		/// </returns>
		/// <exception cref="System.Threading.ThreadInterruptedException">
		/// if the current thread is interrupted ( and interruption of thread suspension is supported.
		/// </exception>
		bool Await(TimeSpan timeSpan);

		/// <summary> Causes the current thread to wait until it is signalled or interrupted,
		/// or the specified deadline elapses.
		/// 
		/// <p/>The lock associated with this condition is atomically
		/// released and the current thread becomes disabled for thread scheduling
		/// purposes and lies dormant until <b>one</b> of five things happens:
		/// <ul>
		/// <li>Some other thread invokes the <see cref="Spring.Threading.Locks.ICondition.Signal()"/> method for this
		/// <see cref="Spring.Threading.Locks.ICondition"/> and the current thread happens to be chosen as the
		/// thread to be awakened</li>
		/// <li>Some other thread invokes the <see cref="Spring.Threading.Locks.ICondition.SignalAll()"/>} method for this
		/// <see cref="Spring.Threading.Locks.ICondition"/></li>
		/// <li>Some other thread <see cref="System.Threading.Thread.Interrupt()"/> is called the current
		/// thread, and interruption of thread suspension is supported</li>
		/// <li>The specified deadline elapses</li>	
		/// <li>A '<b>spurious wakeup</b>' occurs.</li>
		/// </ul>
		/// 
		/// <p/>In all cases, before this method can return the current thread must
		/// re-acquire the lock associated with this condition. When the
		/// thread returns it is <b>guaranteed</b> to hold this lock.
		/// 
		/// 
		/// <p/>If the current thread:
		/// <ul>
		/// <li>has its interrupted status set on entry to this method</li>
		/// <li><see cref="System.Threading.Thread.Interrupt()"/> is called while waiting
		/// and interruption of thread suspension is supported</li>
		/// </ul>
		/// then <see cref="System.Threading.ThreadInterruptedException"/> is thrown and the current thread's
		/// interrupted status is cleared. It is not specified, in the first
		/// case, whether or not the test for interruption occurs before the lock
		/// is released.
		/// 
		/// 
		/// <p/>
		/// The return value indicates whether the deadline has elapsed,
		/// which can be used as follows:
		/// <code>
		///		bool aMethod(DateTime deadline) {
		///			bool stillWaiting = true;
		///			while (!conditionBeingWaitedFor) {
		/// 				if (stillWaiting)
		/// 						stillWaiting = theCondition.AwaitUntil(deadline);
		/// 				else
		/// 						return false;
		/// 				}
		/// 		// ...
		/// 		}
		/// 	}
		/// </code>
		/// 
		/// <p/><b>Implementation Considerations</b>
		/// <p/>
		/// The current thread is assumed to hold the lock associated with this
		/// <see cref="Spring.Threading.Locks.ICondition"/> when this method is called.
		/// It is up to the implementation to determine if this is
		/// the case and if not, how to respond. Typically, an exception will be
		/// thrown (such as <see cref="System.Threading.SynchronizationLockException"/>) and the
		/// implementation must document that fact.
		/// 
		/// <p/>
		/// An implementation can favor responding to an interrupt over normal
		/// method return in response to a signal, or over indicating the passing
		/// of the specified deadline. In either case the implementation
		/// must ensure that the signal is redirected to another waiting thread, if
		/// there is one.
		/// </summary>
		/// <param name="deadline">the absolute time to wait</param>
		/// <returns> 
		/// <see lang="false"/> if the deadline has elapsed upon return, else <see lang="true"/>.
		/// </returns>
		/// <exception cref="System.Threading.ThreadInterruptedException">
		/// if the current thread is interrupted ( and interruption of thread suspension is supported.
		/// </exception>
		bool AwaitUntil(DateTime deadline);

		/// <summary> 
		/// Wakes up one waiting thread.
		/// <p/>
		/// If any threads are waiting on this condition then one
		/// is selected for waking up. That thread must then re-acquire the
		/// lock before returning from await.
		/// </summary>
		void Signal();

		/// <summary> 
		/// Wakes up all waiting threads.
		/// <p/>
		/// If any threads are waiting on this condition then they are
		/// all woken up. Each thread must re-acquire the lock before it can
		/// return from await.
		/// </summary>
		void SignalAll();
	}
}