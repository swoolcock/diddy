using System;
using System.Collections;
using System.Reflection;
using System.Runtime.Serialization;
using System.Threading;

namespace Spring.Threading.Locks
{
	/// <summary> 
	/// An implementation of <see cref="Spring.Threading.Locks.IReadWriteLock"/> supporting similar
	/// semantics to <see cref="Spring.Threading.Locks.ReentrantLock"/>.
	/// </summary>
	/// <remarks>
	/// This class has the following properties:
	/// 
	/// <ul>
	/// <li><b>Acquisition order</b></li>
	/// <p/>
	/// The order of entry to the
	/// lock need not be in arrival order. If readers are
	/// active and a writer enters the lock then no subsequent readers will
	/// be granted the read lock until after that writer has acquired and
	/// released the write lock.
	/// 
	/// <li><b>Reentrancy</b></li>
	/// <p/>
	/// This lock allows both readers and writers to reacquire read or
	/// write locks in the style of a <see cref="Spring.Threading.Locks.ReentrantLock"/>. Readers are not
	/// allowed until all write locks held by the writing thread have been
	/// released.
	/// <p/>
	/// Additionally, a writer can acquire the read lock - but not vice-versa.
	/// Among other applications, reentrancy can be useful when
	/// write locks are held during calls or callbacks to methods that
	/// perform reads under read locks.
	/// If a reader tries to acquire the write lock it will never succeed.
	/// 
	/// <li><b>Lock downgrading</b></li>
	/// <p/>
	/// Reentrancy also allows downgrading from the write lock to a read lock,
	/// by acquiring the write lock, then the read lock and then releasing the
	/// write lock. However, upgrading from a read lock to the write lock is
	/// <b>not</b> possible.
	/// 
	/// <li><b>Interruption of lock acquisition</b></li>
	/// <p/>The read lock and write lock both support interruption during lock
	/// acquisition.
	/// 
	/// <li><b><see cref="Spring.Threading.Locks.ICondition"/> support</b></li>
	/// <p/>
	/// The write lock provides a <see cref="Spring.Threading.Locks.ICondition"/> implementation that
	/// behaves in the same way, with respect to the write lock, as the
	/// <see cref="Spring.Threading.Locks.ICondition"/> implementation provided by
	/// <see cref="Spring.Threading.Locks.ReentrantLock.NewCondition()"/> does for <see cref="Spring.Threading.Locks.ReentrantLock"/>.
	/// This <see cref="Spring.Threading.Locks.ICondition"/> can, of course, only be used with the write lock.
	/// <p/>
	/// The read lock does not support a <see cref="Spring.Threading.Locks.ICondition"/> and
	/// <see cref="Spring.Threading.Locks.ReaderLock.NewCondition()"/> throws
	/// <see cref="System.InvalidOperationException"/>.
	/// 
	/// <li><b>Instrumentation</b></li>
	/// <p/> 
	/// This class supports methods to determine whether locks
	/// are held or contended. These methods are designed for monitoring
	/// system state, not for synchronization control.
	/// </ul>
	/// 
	/// <p/> 
	/// Serialization of this class behaves in the same way as built-in
	/// locks: a deserialized lock is in the unlocked state, regardless of
	/// its state when serialized.
	/// 
	/// <p/><b>Sample usages</b>
	/// Here is a code sketch showing how to exploit
	/// reentrancy to perform lock downgrading after updating a cache (exception
	/// handling is not shown for simplicity):
	/// <code>
	/// class CachedData {
	///		object data;
	///		volatile bool cacheValid;
	///		ReentrantReadWriteLock rwl = new ReentrantReadWriteLock();
	/// 
	/// 	void processCachedData() {
	/// 		rwl.ReadLock.Lock();
	/// 		if (!cacheValid) {
	/// 			rwl.ReadLock.Unlock();
	/// 			rwl.WriteLock.Lock();
	/// 			if (!cacheValid) {
	/// 				data = ...
	/// 				cacheValid = true;
	/// 			}
	/// 			// downgrade lock
	/// 			rwl.ReadLock.Lock();  // reacquire read without giving up write lock
	/// 			rwl.WriteLock.Unlock(); // unlock write, still hold read
	/// 		}
	/// 
	/// 		use(data);
	/// 		rwl.ReadLock.Unlock();
	/// 	}
	/// }
	/// </code>
	/// 
	/// <see cref="Spring.Threading.Locks.ReentrantReadWriteLock"/>s can be used to improve concurrency in some
	/// uses of some kinds of Collections. This is typically worthwhile
	/// only when the collections are expected to be large, accessed by
	/// more reader threads than writer threads, and entail operations with
	/// overhead that outweighs synchronization overhead. For example, here
	/// is a class using a TreeMap that is expected to be large and
	/// concurrently accessed.
	/// 
	/// <code>
	/// class RWDictionary {
	///		private final IDictionary m = new Hashtable();
	/// 	private final ReentrantReadWriteLock rwl = new ReentrantReadWriteLock();
	/// 	private final Lock r = rwl.ReadLock;
	/// 	private final Lock w = rwl.WriteLock;
	/// 
	/// 	public object Get(string key) {
	/// 		r.Lock(); try { return m[key]; } finally { r.Unlock(); }
	/// 	}
	/// 	public ICollection AllKeys() {
	/// 		r.Lock(); try { return m.Keys; } finally { r.Unlock(); }
	/// 	}
	/// 	public object Put(string key, object value) {
	/// 		w.Lock(); try { return m.Add(key, value); } finally { w.Unlock(); }
	/// 	}
	/// 	public void clear() {
	/// 		w.Lock(); try { m.Clear(); } finally { w.Unlock(); }
	/// 	}
	/// }
	/// </code>
	/// 
	/// 
	/// <h3>Implementation Notes</h3>
	/// 
	/// <p/>
	/// A reentrant write lock intrinsically defines an owner and can
	/// only be released by the thread that acquired it.  In contrast, in
	/// this implementation, the read lock has no concept of ownership, and
	/// there is no requirement that the thread releasing a read lock is
	/// the same as the one that acquired it.  However, this property is
	/// not guaranteed to hold in future implementations of this class.
	/// 
	/// <p/> This lock supports a maximum of 65536 recursive write locks
	/// and 65536 read locks.
	/// </remarks>
	/// <author>Doug Lea</author>
	/// <author>Griffin Caprio(.NET)</author> 
	[Serializable]
	public class ReentrantReadWriteLock : IReadWriteLock, ISerializable
	{
        /// <summary>
        /// Enumeration indicatiing which lock to signal.
        /// </summary>
        public enum Signaller
        {
            /// <summary>
            /// No Lock
            /// </summary>
            NONE = 0,
            /// <summary>
            /// Reader Lock
            /// </summary>
            READER = 1,
            /// <summary>
            /// Writer Lock
            /// </summary>
            WRITER = 2
        }
		[NonSerialized] internal int _activeReaders = 0;
		[NonSerialized] internal Thread _activeWriter = null;
		[NonSerialized] internal int _waitingReaders = 0;
		[NonSerialized] internal int _waitingWriters = 0;
		[NonSerialized] internal int _writeHolds = 0;
		[NonSerialized] internal Hashtable _readers = new Hashtable();

		internal ReaderLock _readerLock;
		internal WriterLock _writerLock;

		internal static readonly int ONE = 1;

		[ThreadStatic] internal static readonly NullSignaller Null_Signaller = new NullSignaller();

		#region Constructors

		/// <summary> 
		/// Creates a new <see cref="Spring.Threading.Locks.ReentrantReadWriteLock"/> with
		/// default ordering properties.
		/// </summary>
		public ReentrantReadWriteLock()
		{
			_readerLock = new ReaderLock(this);
			_writerLock = new WriterLock(this);
		}

		/// <summary>
		/// Deserializes a <see cref="Spring.Threading.Locks.ReentrantReadWriteLock"/> instance from the supplied <see cref="System.Runtime.Serialization.SerializationInfo"/>
		/// </summary>
		/// <param name="info">The <see cref="System.Runtime.Serialization.SerializationInfo"/> to pull date from.</param>
		/// <param name="context">The contextual information about the source or destination.</param>
		protected ReentrantReadWriteLock(SerializationInfo info, StreamingContext context)
		{
			Type thisType = this.GetType();
			MemberInfo[] mi = FormatterServices.GetSerializableMembers(thisType, context);
			for (int i = 0; i < mi.Length; i++)
			{
				FieldInfo fi = (FieldInfo) mi[i];
				fi.SetValue(this, info.GetValue(fi.Name, fi.FieldType));
			}
			lock (this)
			{
				_readers = new Hashtable();
			}
		}

		#endregion

		#region Properties

		/// <summary>Returns <see lang="true"/> if this lock has fairness set true. This implementation always returns <see lang="false"/></summary>
		/// <returns><see lang="false"/> if this lock has fairness set false.</returns>
		public bool IsFair
		{
			get { return false; }
		}

		/// <summary> 
		/// Returns the <see cref="System.Threading.Thread"/> that currently owns the write lock, or
		/// <see lang="null"/> if not owned. Note that the owner may be
		/// momentarily <see lang="null"/> even if there are threads trying to
		/// acquire the lock but have not yet done so.  This method is
		/// designed to facilitate construction of subclasses that provide
		/// more extensive lock monitoring facilities.
		/// </summary>
		/// <returns> the owner, or <see lang="null"/> if not owned.
		/// </returns>
		protected internal Thread Owner
		{
			get
			{
				lock (this)
				{
					return _activeWriter;
				}
			}

		}

		/// <summary> 
		/// Queries the number of read locks held for this lock. This
		/// method is designed for use in monitoring system state, not for
		/// synchronization control.
		/// </summary>
		/// <returns>the number of read locks held.</returns>
		public int ReadLockCount
		{
			get
			{
				lock (this)
				{
					return _activeReaders;
				}
			}

		}

		/// <summary> 
		/// Queries if the write lock is held by any thread. This method is
		/// designed for use in monitoring system state, not for
		/// synchronization control.
		/// </summary>
		/// <returns> <see lang="true"/> if any thread holds the write lock and
		/// <see lang="false"/> otherwise.
		/// </returns>
		public bool IsWriteLockHeld
		{
			get
			{
				lock (this)
				{
					return _activeWriter != null;
				}
			}

		}

		/// <summary> 
		/// Queries if the write lock is held by the current thread.</summary>
		/// <returns> <see lang="true"/> if the current thread holds the write lock and
		/// <see lang="false"/> otherwise.
		/// </returns>
		public bool WriterLockedByCurrentThread
		{
			get
			{
				lock (this)
				{
					return _activeWriter == Thread.CurrentThread;
				}
			}

		}

		/// <summary> 
		/// Queries the number of reentrant write holds on this lock by the
		/// current thread. A writer thread has a hold on a lock for
		/// each lock action that is not matched by an unlock action.
		/// </summary>
		/// <returns> the number of holds on the write lock by the current thread,
		/// or zero if the write lock is not held by the current thread.
		/// </returns>
		public int WriteHoldCount
		{
			get
			{
				lock (this)
				{
					return _writeHolds;
				}
			}

		}

		/// <summary> 
		/// Returns an estimate of the number of threads waiting to acquire
		/// either the read or write lock.  The value is only an estimate
		/// because the number of threads may change dynamically while this
		/// method traverses internal data structures.  This method is
		/// designed for use in monitoring of the system state, not for
		/// synchronization control.
		/// </summary>
		/// <returns>the estimated number of threads waiting for this lock</returns>
		public int QueueLength
		{
			get
			{
				lock (this)
				{
					return _waitingWriters + _waitingReaders;
				}
			}
		}

		/// <summary>
		/// Gets the write lock associated with this <see cref="Spring.Threading.Locks.ReentrantReadWriteLock"/> instance.
		/// </summary>
		public ILock WriterLock
		{
			get { return _writerLock; }
		}

		/// <summary>
		/// Gets the read lock associated with this <see cref="Spring.Threading.Locks.ReentrantReadWriteLock"/> instance.
		/// </summary>
		public ILock ReaderLock
		{
			get { return _readerLock; }
		}

		/// <summary>
		/// Gets the ReaderLock signaller for this <see cref="Spring.Threading.Locks.ReentrantReadWriteLock"/> instance. 
		/// </summary>
		internal ISignaller SignallerReaderLock
		{
			get { return _readerLock; }
		}

		/// <summary>
		/// Gets the WriterLock signaller for this <see cref="Spring.Threading.Locks.ReentrantReadWriteLock"/> instance. 
		/// </summary>
		internal ISignaller SignallerWriterLock
		{
			get { return _writerLock; }
		}

		#endregion	

		#region Public Methods

		/// <summary> 
		/// Returns a string identifying this lock, as well as its lock state.
		/// The state, in brackets, includes the string "Write locks ="
		/// followed by the number of reentrantly held write locks, and the
		/// string "Read locks =" followed by the number of held
		/// read locks.
		/// </summary>
		/// <returns> a string identifying this lock, as well as its lock state.
		/// </returns>
		public override String ToString()
		{
			return base.ToString() + "[Write locks = " + WriteHoldCount + ", Read locks = " + ReadLockCount + "]";
		}

		/// <summary>
		/// Populates a <see cref="System.Runtime.Serialization.SerializationInfo"/> with the data needed to serialize the target object. 
		/// </summary>
		/// <param name="info">The <see cref="System.Runtime.Serialization.SerializationInfo"/> to populate with data.</param>
		/// <param name="context">The destination (see <see cref="System.Runtime.Serialization.StreamingContext"/>) for this serialization. </param>
		public void GetObjectData(SerializationInfo info, StreamingContext context)
		{
			Type thisType = this.GetType();
			MemberInfo[] mi = FormatterServices.GetSerializableMembers(thisType, context);
			for (int i = 0; i < mi.Length; i++)
			{
				info.AddValue(mi[i].Name, ((FieldInfo) mi[i]).GetValue(this));
			}
		}

		#endregion

		#region Internal Lock Management Methods

		/// <summary>
		/// Attemptes to aquire a new read lock for the current thread. If the read lock was not aquired, the number of readers waiting for a 
		/// read lock is incremented. 
		/// </summary>
		/// <returns><see lang="true"/> if a read lock was aquired, <see lang="false"/> otherwise.</returns>
		internal bool StartReadFromNewReader()
		{
			lock (this)
			{
				bool pass = StartRead();
				if (!pass)
					++_waitingReaders;
				return pass;
			}
		}

		/// <summary>
		/// Attemps to aquire a new write lock for the current thread.  If the write lock was not aquired, the number of writers waiting for a 
		/// write lock is incremented.
		/// </summary>
		/// <returns><see lang="true"/> if the write lock was aquired, <see lang="false"/> otherwise.</returns>
		internal bool StartWriteFromNewWriter()
		{
			lock (this)
			{
				bool pass = StartWrite();
				if (!pass)
					++_waitingWriters;
				return pass;
			}
		}

		/// <summary>
		/// Attemps to aquire a new read lock from the current threads waiting readers.  If the read lock was aquired, the number of waiting readers
		/// is decremented.
		/// </summary>
		/// <returns><see lang="true"/> if the read lock was aquired, <see lang="false"/> otherwise.</returns>
		internal bool StartReadFromWaitingReader()
		{
			lock (this)
			{
				bool pass = StartRead();
				if (pass)
					--_waitingReaders;
				return pass;
			}
		}

		/// <summary>
		/// Attempes to aquire a new write lock for the current thread.  If the write lock was aquired, the number of waiting writers for a write lock
		/// is decremented.
		/// </summary>
		/// <returns><see lang="true"/> if the write lock was aquired, <see lang="false"/> otherwise.</returns>
		internal bool StartWriteFromWaitingWriter()
		{
			lock (this)
			{
				bool pass = StartWrite();
				if (pass)
					--_waitingWriters;
				return pass;
			}
		}

		/// <summary>
		/// Cancels a reader waiting for a read lock.
		/// </summary>
		internal void CancelWaitingReader()
		{
			lock (this)
			{
				--_waitingReaders;
			}
		}

		/// <summary>
		/// Cancels a writer waiting for a write lock.
		/// </summary>
		internal void CancelWaitingWriter()
		{
			lock (this)
			{
				--_waitingWriters;
			}
		}

		/// <summary>
		/// Determines if new read locks from the current thread are able to be aquired.
		/// </summary>
		/// <remarks>
		/// The criteria to determine if new read locks from the current thread are able to be aquired are as follows:
		/// <ul>
		///	<li>
		/// If there is no active writer and there are no waiting writers	
		///	</li> 
		///	<li>
		/// If the active writer is the current thrad.	
		///	</li>
		/// </ul>
		/// <p/>
		/// If either of the above condidtions is true, readers are allowed.  Otherwise, no readers are allowed.
		/// </remarks>
		internal bool AllowReader
		{
			get { return (_activeWriter == null && _waitingWriters == 0) || _activeWriter == Thread.CurrentThread; }
		}

		/// <summary>
		/// Determines if new write locks from the current thread can be aquried.
		/// </summary>
		/// <remarks>
		/// The criteria to determine if new write locks from the current thread are able to be aquired are as follows:
		/// <ul>
		/// <li>
		/// The number of active readers is 0. 
		/// </li>
		/// <li>
		/// There is only one total reader and it is the current thread. 
		/// </li>
		/// </ul>
		/// If either of the above condiditions is true, writers are allowed.  Otherwise, no writers are allowed.
		/// </remarks>
		internal bool AllowWriter
		{
			get { return _activeReaders == 0 || (_readers.Count == 1 && _readers[Thread.CurrentThread] != null); }
		}

		/// <summary>
		///	Attempts to start a new read lock for the current Thread.  
		///	</summary>
		///	<remarks>
		///	If the current thread already has a read lock, the number of active readers is simply incremented, as well as the number of readers for that 
		///	thread.
		///	<p/>
		///	If the current thread does <b>not</b> have a read lock, and readers are allowed, the number of active readers is incremented, as well as the 
		///	number of readers for that thread.
		///	<p/>
		///	If the current thread does not have a read lock, and new read locks are <b>not</b> allowed, false is returned and a new read lock is <b>not</b>
		///	aquired.   
		/// </remarks>
		/// <returns><see lang="trur"/> if a read lock was aquired, <see lang="false"/> otherwise.</returns>
		internal bool StartRead()
		{
			lock (this)
			{
				Thread currentThread = Thread.CurrentThread;
				object currentReaderCountForThread = _readers[currentThread];
				if (currentReaderCountForThread != null)
				{
					_readers[currentThread] = (int) (currentReaderCountForThread) + 1;
					++_activeReaders;
					return true;
				}
				else if (AllowReader)
				{
					_readers[currentThread] = ONE;
					++_activeReaders;
					return true;
				}
				else
					return false;
			}
		}

		/// <summary>
		///	Attempts to start a new write lock for the current Thread.  
		///	</summary>
		///	<remarks>
		///	If the current thread is already the active writer, the number of writer holds is simply incremented.  Otherwise, if there are no current
		///	write holds and writers are allowed, the current thread becomes the active writer. 
		/// </remarks>
		/// <returns><see lang="trur"/> if a write lock was aquired, <see lang="false"/> otherwise.</returns>
		internal bool StartWrite()
		{
			lock (this)
			{
				if (_activeWriter == Thread.CurrentThread)
				{
					++_writeHolds;
					return true;
				}
				else if (_writeHolds == 0)
				{
					if (AllowWriter)
					{
						_activeWriter = Thread.CurrentThread;
						_writeHolds = 1;
						return true;
					}
					else
					{
						return false;
					}
				}
				else
				{
					return false;
				}
			}
		}

		/// <summary>
		/// Ends a read lock for the current thread. 
		/// </summary>
		/// <returns><see cref="Spring.Threading.Locks.WriterLock"/> for this instance if there are no more readers for the current thread, there are no
		/// more active readers for the read lock, and there are waiter writers.  Otherwise, a a No-Op instance of 
		/// <see cref="Spring.Threading.Locks.ISignaller"/> is returned.
		/// <p/>
		/// <b>Note:</b> This deviates from the Java implementation by returning a No-Op instance of <see cref="Spring.Threading.Locks.ISignaller"/> instead
		/// of null to avoid having null checks scattered around.  This is an example of the Null Object pattern.
		/// </returns>
		/// <exception cref="System.Threading.ThreadStateException">
		/// Thrown if there are no current readers for the lock from the current thread.
		/// </exception>
		internal Signaller EndRead()
		{
			lock (this)
			{
				Thread currentThread = Thread.CurrentThread;
				object currentReaderCountForThread = _readers[currentThread];
				if (currentReaderCountForThread == null)
				{
					throw new ThreadStateException("No current readers for the lock from thread " + currentThread.Name + ".");
				}
				--_activeReaders;
				if ((int) currentReaderCountForThread != ONE)
				{
					int decrementedReaderCountForThread = (int) currentReaderCountForThread - 1;
					if (decrementedReaderCountForThread == 1)
					{
						_readers[currentThread] = ONE;
					}
					else
					{
						_readers[currentThread] = decrementedReaderCountForThread;
					}
					return Signaller.NONE;
				}
				else
				{
					_readers.Remove(currentThread);

					if (_writeHolds > 0)
						return Signaller.NONE;
					else if (_activeReaders == 0 && _waitingWriters > 0)
						return Signaller.WRITER;
					else
						return Signaller.NONE;
				}
			}
		}

		/// <summary>
		/// Ends a write lock from the current lock.
		/// </summary>
		/// <returns>
		/// <see cref="Spring.Threading.Locks.ReaderLock"/> for this instance if there are more write holds, waiting readers, and readers are allowed.  
		/// If there are more write holds, no waiting readers or readers are not allowed, and waiting writers, then the 
		/// <see cref="Spring.Threading.Locks.WriterLock"/> for this instance is returned.  Other wise a No-Op instance of 
		/// <see cref="Spring.Threading.Locks.ISignaller"/> is returned.
		/// <p/>
		/// <b>Note:</b> This deviates from the Java implementation by returning a No-Op instance of <see cref="Spring.Threading.Locks.ISignaller"/> instead
		/// of null to avoid having null checks scattered around.  This is an example of the Null Object pattern.
		/// </returns>
		/// <exception cref="System.Threading.SynchronizationLockException">
		/// Thrown if the current thread is not currently the active writer.
		/// </exception>
		internal Signaller EndWrite()
		{
            lock (this)
            {
                if (_activeWriter != Thread.CurrentThread)
                {
                    throw new SynchronizationLockException();
                }
                --_writeHolds;
                if (_writeHolds > 0)
                {
                    return Signaller.NONE;
                }
                else
                {
                    _activeWriter = null;
                    if (_waitingReaders > 0 && AllowReader)
                    {

                        return Signaller.READER;
                    }
                    else if (_waitingWriters > 0)
                    {

                        return Signaller.WRITER;
                    }
                    else
                    {
                        return Signaller.NONE;
                    }
                }
            }
		}

		#endregion
	}
}