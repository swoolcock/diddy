using System;
using System.Collections.Generic;
using System.Reflection;
using System.Runtime.Serialization;
using System.Threading;
using Spring.Collections;
using Spring.Collections.Generic;

namespace Spring.Threading.Collections.Generic {
    /// <summary> 
    /// An optionally-bounded <see cref="IBlockingQueue{T}"/> based on
    /// linked nodes.
    /// </summary>
    /// <remarks>
    /// This queue orders elements FIFO (first-in-first-out).
    /// The <b>head</b> of the queue is that element that has been on the
    /// queue the longest time.
    /// The <b>tail</b> of the queue is that element that has been on the
    /// queue the shortest time. New elements
    /// are inserted at the tail of the queue, and the queue retrieval
    /// operations obtain elements at the head of the queue.
    /// Linked queues typically have higher throughput than array-based queues but
    /// less predictable performance in most concurrent applications.
    /// 
    /// <p/> 
    /// The optional capacity bound constructor argument serves as a
    /// way to prevent excessive queue expansion. The capacity, if unspecified,
    /// is equal to <see cref="System.Int32.MaxValue"/>.  Linked nodes are
    /// dynamically created upon each insertion unless this would bring the
    /// queue above capacity.
    /// </remarks>
    /// <author>Doug Lea</author>
    /// <author>Griffin Caprio (.NET)</author>
    [Serializable]
    public class LinkedBlockingQueue<T> : AbstractBlockingQueue<T>, ISerializable {

        #region inner classes

        [Serializable]
        private class SerializableLock {
        }

        [Serializable]
        internal class Node {
            internal T item;

            internal Node next;

            internal Node(T x) {
                item = x;
            }
        }

        #endregion

        #region private fields

        /// <summary>The capacity bound, or Integer.MAX_VALUE if none </summary>
        private readonly int _capacity;

        /// <summary>Current number of elements </summary>
        private volatile int _activeCount;

        /// <summary>Head of linked list </summary>
        [NonSerialized]
        private Node head;

        /// <summary>Tail of linked list </summary>
        [NonSerialized]
        private Node last;

        /// <summary>Lock held by take, poll, etc </summary>
        private readonly object takeLock;

        /// <summary>Lock held by put, offer, etc </summary>
        private readonly object putLock;

        /// <summary> 
        /// Signals a waiting take. Called only from put/offer (which do not
        /// otherwise ordinarily lock takeLock.)
        /// </summary>
        private void signalNotEmpty() {
            lock(takeLock) {
                Monitor.Pulse(takeLock);
            }
        }

        /// <summary> Signals a waiting put. Called only from take/poll.</summary>
        private void signalNotFull() {
            lock(putLock) {
                Monitor.Pulse(putLock);
            }
        }

        /// <summary> 
        /// Creates a node and links it at end of queue.</summary>
        /// <param name="x">the item to insert</param>
        private void insert(T x) {
            last = last.next = new Node(x);
        }

        /// <summary>Removes a node from head of queue,</summary>
        /// <returns>the node</returns>
        private T extract() {
            Node first = head.next;
            head = first;
            T x = first.item;
            first.item = default(T);
            return x;
        }


        #endregion

        #region ctors

        /// <summary> Creates a <see cref="LinkedBlockingQueue{T}"/> with a capacity of
        /// <see cref="System.Int32.MaxValue"/>.
        /// </summary>
        public LinkedBlockingQueue()
            : this(Int32.MaxValue) {
        }

        /// <summary> Creates a <see cref="LinkedBlockingQueue{T}"/> with the given (fixed) capacity.</summary>
        /// <param name="capacity">the capacity of this queue</param>
        /// <exception cref="System.ArgumentException">if the <paramref name="capacity"/> is not greater than zero.</exception>
        public LinkedBlockingQueue(int capacity) {
            if(capacity <= 0)
                throw new ArgumentException();
            takeLock = new SerializableLock();
            putLock = new SerializableLock();
            _capacity = capacity;
            last = head = new Node(default(T));
        }

        /// <summary> Creates a <see cref="LinkedBlockingQueue{T}"/> with a capacity of
        /// <see cref="System.Int32.MaxValue"/>, initially containing the elements o)f the
        /// given collection, added in traversal order of the collection's iterator.
        /// </summary>
        /// <param name="collection">the collection of elements to initially contain</param>
        /// <exception cref="System.ArgumentNullException">if the collection or any of its elements are null.</exception>
        /// <exception cref="System.ArgumentException">if the collection size exceeds the capacity of this queue.</exception>
        public LinkedBlockingQueue(ICollection<T> collection)
            : this(Int32.MaxValue) {
            if(collection == null) {
                throw new ArgumentNullException("collection", "must not be null.");
            }
            if(collection.Count > _capacity) {
                throw new ArgumentException("Collection size exceeds the capacity of this queue.");
            }
            foreach(T currentobject in collection) {
                Add(currentobject);
            }
        }

        /// <summary> Reconstitute this queue instance from a stream (that is,
        /// deserialize it).
        /// </summary>
        /// <param name="info">The <see cref="System.Runtime.Serialization.SerializationInfo"/> to populate with data. </param>
        /// <param name="context">The destination (see <see cref="System.Runtime.Serialization.StreamingContext"/>) for this serialization. </param>
        protected LinkedBlockingQueue(SerializationInfo info, StreamingContext context) {
            MemberInfo[] mi = FormatterServices.GetSerializableMembers(GetType(), context);
            for(int i = 0; i < mi.Length; i++) {
                FieldInfo fi = (FieldInfo)mi[i];
                fi.SetValue(this, info.GetValue(fi.Name, fi.FieldType));
            }
            lock(this) {
                _activeCount = 0;
            }
            last = head = new Node(default(T));

            for(; ; ) {
                T item = (T)info.GetValue("Spring.Threading.Collections.LinkedBlockingQueuedata1", typeof(T));
                Add(item);
            }
        }

        #endregion

        #region ISerializable Members

        /// <summary>
        ///Populates a <see cref="System.Runtime.Serialization.SerializationInfo"/> with the data needed to serialize the target object.
        /// </summary>
        /// <param name="info">The <see cref="System.Runtime.Serialization.SerializationInfo"/> to populate with data. </param>
        /// <param name="context">The destination (see <see cref="System.Runtime.Serialization.StreamingContext"/>) for this serialization. </param>
        public virtual void GetObjectData(SerializationInfo info, StreamingContext context) {
            lock(putLock) {
                lock(takeLock) {

                    MemberInfo[] mi = FormatterServices.GetSerializableMembers(GetType(), context);
                    for(int i = 0; i < mi.Length; i++) {
                        info.AddValue(mi[i].Name, ((FieldInfo)mi[i]).GetValue(this));
                    }

                    for(Node p = head.next; p != null; p = p.next) {
                        info.AddValue("Spring.Threading.Collections.LinkedBlockingQueuedata1", p.item);
                    }

                    info.AddValue("Spring.Threading.Collections.LinkedBlockingQueuedata2", null);
                }
            }
        }


        #endregion

        #region IBlockingQueue<T> Members

        /// <summary> 
        /// Inserts the specified element into this queue, waiting if necessary
        /// for space to become available.
        /// </summary>
        /// <param name="element">the element to add</param>
        /// <exception cref="System.InvalidOperationException">
        /// If the element cannot be added at this time due to capacity restrictions.
        /// </exception>
        /// <exception cref="System.ArgumentNullException">
        /// If the element type of the queue is a reference type and the specified element 
        /// is <see lang="null"/> and this queue does not permit <see lang="null"/> elements.
        /// </exception>
        /// <exception cref="System.ArgumentException">
        /// If some property of the supplied <paramref name="element"/> prevents
        /// it from being added to this queue.
        /// </exception>
        public override void Put(T element) {
            int tempCount;
            lock(putLock) {
                try {
                    while(_activeCount == _capacity)
                        Monitor.Wait(putLock);
                }
                catch(ThreadInterruptedException) {
                    Monitor.Pulse(putLock);
                    throw;
                }
                insert(element);
                lock(this) {
                    tempCount = _activeCount++;
                }
                if(tempCount + 1 < _capacity)
                    Monitor.Pulse(putLock);
            }

            if(tempCount == 0)
                signalNotEmpty();
        }

        /// <summary> 
        /// Inserts the specified element into this queue, waiting up to the
        /// specified wait time if necessary for space to become available.
        /// </summary>
        /// <param name="element">the element to add</param>
        /// <param name="duration">how long to wait before giving up</param>
        /// <returns> <see lang="true"/> if successful, or <see lang="false"/> if
        /// the specified waiting time elapses before space is available
        /// </returns>
        /// <exception cref="System.InvalidOperationException">
        /// If the element cannot be added at this time due to capacity restrictions.
        /// </exception>
        /// <exception cref="System.InvalidCastException">
        /// If the class of the supplied <paramref name="element"/> prevents it
        /// from being added to this queue.
        /// </exception>
        /// <exception cref="System.ArgumentNullException">
        /// If the element type of the queue is a reference type and the specified element 
        /// is <see lang="null"/> and this queue does not permit <see lang="null"/> elements.
        /// </exception>
        /// <exception cref="System.ArgumentException">
        /// If some property of the supplied <paramref name="element"/> prevents
        /// it from being added to this queue.
        /// </exception>
        public override bool Offer(T element, TimeSpan duration) {
            TimeSpan durationToWait = duration;
            int tempCount;
            lock(putLock) {
                DateTime deadline = DateTime.Now.Add(durationToWait);
                for(; ; ) {
                    if(_activeCount < _capacity) {
                        insert(element);
                        lock(this) {
                            tempCount = _activeCount++;
                        }
                        if(tempCount + 1 < _capacity)
                            Monitor.Pulse(putLock);
                        break;
                    }
                    if(durationToWait.TotalMilliseconds <= 0)
                        return false;
                    try {
                        lock(this) {
                            Monitor.Wait(this, duration);
                        }
                        durationToWait = deadline.Subtract(DateTime.Now);
                    }
                    catch(ThreadInterruptedException) {
                        Monitor.Pulse(putLock);
                        throw;
                    }
                }
            }
            if(tempCount == 0)
                signalNotEmpty();
            return true;
        }

        /// <summary> 
        /// Retrieves and removes the head of this queue, waiting if necessary
        /// until an element becomes available.
        /// </summary>
        /// <returns> the head of this queue</returns>
        public override T Take() {
            T x;
            int tempCount;
            lock(takeLock) {
                try {
                    while(_activeCount == 0)
                        Monitor.Wait(takeLock);
                }
                catch(ThreadInterruptedException) {
                    Monitor.Pulse(takeLock);
                    throw;
                }

                x = extract();
                lock(this) {
                    tempCount = _activeCount--;
                }
                if(tempCount > 1)
                    Monitor.Pulse(takeLock);
            }
            if(tempCount == _capacity)
                signalNotFull();

            return x;
        }

        /// <summary> 
        /// Retrieves and removes the head of this queue, waiting up to the
        /// specified wait time if necessary for an element to become available.
        /// </summary>
        /// <param name="duration">how long to wait before giving up</param>
        /// <param name="element"></param>
        /// <returns> 
        /// the head of this queue, or <see lang="default(T)"/> if the
        /// specified waiting time elapses before an element is available.
        /// </returns>
        public override bool Poll(TimeSpan duration, out T element) {
            T x;
            int c;
            TimeSpan durationToWait = duration;
            lock(takeLock) {
                DateTime deadline = DateTime.Now.Add(duration);
                for(; ; ) {
                    if(_activeCount > 0) {
                        x = extract();
                        lock(this) {
                            c = _activeCount--;
                        }
                        if(c > 1)
                            Monitor.Pulse(takeLock);
                        break;
                    }
                    if(durationToWait.TotalMilliseconds <= 0) {
                        element = default(T);
                        return false;
                    }
                    try {
                        lock(this) {

                            Monitor.Wait(this, duration);
                        }
                        durationToWait = deadline.Subtract(DateTime.Now);
                    }
                    catch(ThreadInterruptedException) {
                        Monitor.Pulse(takeLock);
                        throw;
                    }
                }
            }
            if(c == _capacity)
                signalNotFull();
            element = x;
            return true;
        }

        /// <summary> 
        /// Returns the number of additional elements that this queue can ideally
        /// (in the absence of memory or resource constraints) accept without
        /// blocking. This is always equal to the initial capacity of this queue
        /// minus the current <see cref="LinkedBlockingQueue{T}.Count"/> of this queue.
        /// </summary>
        /// <remarks> 
        /// Note that you <b>cannot</b> always tell if an attempt to insert
        /// an element will succeed by inspecting <see cref="LinkedBlockingQueue{T}.RemainingCapacity"/>
        /// because it may be the case that another thread is about to
        /// insert or remove an element.
        /// </remarks>
        public override int RemainingCapacity {
            get {
                return _capacity - _activeCount;
            }
        }

        /// <summary> 
        /// Removes all available elements from this queue and adds them
        /// to the given collection.  
        /// </summary>
        /// <remarks>
        /// This operation may be more
        /// efficient than repeatedly polling this queue.  A failure
        /// encountered while attempting to add elements to
        /// collection <paramref name="collection"/> may result in elements being in neither,
        /// either or both collections when the associated exception is
        /// thrown.  Attempts to drain a queue to itself result in
        /// <see cref="System.ArgumentException"/>. Further, the behavior of
        /// this operation is undefined if the specified collection is
        /// modified while the operation is in progress.
        /// </remarks>
        /// <param name="collection">the collection to transfer elements into</param>
        /// <returns> the number of elements transferred</returns>
        /// <exception cref="System.InvalidOperationException">
        /// If the queue cannot be drained at this time.
        /// </exception>
        /// <exception cref="System.InvalidCastException">
        /// If the class of the supplied <paramref name="collection"/> prevents it
        /// from being used for the elemetns from the queue.
        /// </exception>
        /// <exception cref="System.ArgumentNullException">
        /// If the specified collection is <see lang="null"/>.
        /// </exception>
        /// <exception cref="System.ArgumentException">
        /// If <paramref name="collection"/> represents the queue itself.
        /// </exception>
        //TODO: do we really need this? can we leave it to the base class?
        public override int DrainTo(ICollection<T> collection) {
            if(collection == null)
                throw new ArgumentNullException("collection", "Collection cannot be null.");
            if(collection == this)
                throw new ArgumentException("Cannot drain current collection to itself.");
            Node first;
            lock(putLock) {
                lock(takeLock) {
                    first = head.next;
                    head.next = null;

                    last = head;
                    int cold;
                    lock(this) {
                        cold = _activeCount;
                        _activeCount = 0;
                    }
                    if(cold == _capacity)
                        Monitor.PulseAll(putLock);
                }
            }
            int n = 0;
            for(Node p = first; p != null; p = p.next) {
                collection.Add(p.item);
                p.item = default(T);
                ++n;
            }
            return n;
        }

        /// <summary> 
        /// Does the real work for all <c>Drain</c> methods. Caller must
        /// guarantee the <paramref name="action"/> is not <c>null</c> and
        /// <paramref name="maxElements"/> is greater then zero (0).
        /// </summary>
        /// <seealso cref="IBlockingQueue{T}.DrainTo(ICollection{T})"/>
        /// <seealso cref="IBlockingQueue{T}.DrainTo(ICollection{T}, int)"/>
        /// <seealso cref="IBlockingQueue{T}.Drain(System.Action{T})"/>
        /// <seealso cref="IBlockingQueue{T}.DrainTo(ICollection{T},int)"/>
        protected override int DoDrainTo(Action<T> action, int maxElements)
        {
            lock(putLock) {
                lock(takeLock) {
                    int n = 0;
                    Node p = head.next;
                    while(p != null && n < maxElements) {
                        action(p.item);
                        p.item = default(T);
                        p = p.next;
                        ++n;
                    }
                    if(n != 0) {
                        head.next = p;
                        if(p == null)
                            last = head;
                        int cold;
                        lock(this) {
                            cold = _activeCount;
                            _activeCount -= n;
                        }
                        if(cold == _capacity)
                            Monitor.PulseAll(putLock);
                    }
                    return n;
                }
            }
        }

        #endregion

        #region base class overrides

        /// <summary> 
        /// Removes a single instance of the specified element from this queue,
        /// if it is present.  
        /// </summary>
        /// <remarks> 
        ///	If this queue contains one or more such elements.
        /// Returns <see lang="true"/> if this queue contained the specified element
        /// (or equivalently, if this queue changed as a result of the call).
        /// </remarks>
        /// <param name="objectToRemove">element to be removed from this queue, if present</param>
        /// <returns><see lang="true"/> if this queue changed as a result of the call</returns>
        public override bool Remove(T objectToRemove) {
            bool removed = false;
            lock(putLock) {
                lock(takeLock) {
                    Node trail = head;
                    Node p = head.next;
                    while(p != null) {
                        if(objectToRemove.Equals(p.item)) {
                            removed = true;
                            break;
                        }
                        trail = p;
                        p = p.next;
                    }
                    if(removed) {
                        p.item = default(T);
                        trail.next = p.next;
                        if(last == p)
                            last = trail;
                        lock(this) {
                            if(_activeCount-- == _capacity)
                                Monitor.PulseAll(putLock);
                        }
                    }
                }
            }
            return removed;
        }

        /// <summary> 
        /// Inserts the specified element into this queue if it is possible to do
        /// so immediately without violating capacity restrictions.
        /// </summary>
        /// <remarks>
        /// <p>
        /// When using a capacity-restricted queue, this method is generally
        /// preferable to <see cref="Spring.Collections.IQueue.Add(object)"/>,
        /// which can fail to insert an element only by throwing an exception.
        /// </p>
        /// </remarks>
        /// <param name="element">
        /// The element to add.
        /// </param>
        /// <returns>
        /// <see lang="true"/> if the element was added to this queue.
        /// </returns>
        /// <exception cref="System.InvalidOperationException">
        /// If the element cannot be added at this time due to capacity restrictions.
        /// </exception>
        /// <exception cref="System.ArgumentNullException">
        /// If the element type of the queue is a reference type and the specified element 
        /// is <see lang="null"/> and this queue does not permit <see lang="null"/> elements.
        /// </exception>
        /// <exception cref="System.ArgumentException">
        /// If some property of the supplied <paramref name="element"/> prevents
        /// it from being added to this queue.
        /// </exception>
        public override bool Offer(T element) {
            if(_activeCount == _capacity)
                return false;
            int tempCount = -1;
            lock(putLock) {
                if(_activeCount < _capacity) {
                    insert(element);
                    lock(this) {
                        tempCount = _activeCount++;
                    }
                    if(tempCount + 1 < _capacity)
                        Monitor.Pulse(putLock);
                }
            }
            if(tempCount == 0)
                signalNotEmpty();
            return tempCount >= 0;
        }

        /// <summary>
        /// Retrieves, but does not remove, the head of this queue into out
        /// parameter <paramref name="element"/>.
        /// </summary>
        /// <param name="element">
        /// The head of this queue. <c>default(T)</c> if queue is empty.
        /// </param>
        /// <returns>
        /// <c>false</c> is the queue is empty. Otherwise <c>true</c>.
        /// </returns>
        public override bool Peek(out T element) {
            if(_activeCount == 0) {
                element = default(T);
                return false;
            }
            lock(takeLock) {
                Node first = head.next;
                element = first.item;
                return true;
            }
        }

        /// <summary>
        /// Retrieves and removes the head of this queue into out parameter
        /// <paramref name="element"/>. 
        /// </summary>
        /// <param name="element">
        /// Set to the head of this queue. <c>default(T)</c> if queue is empty.
        /// </param>
        /// <returns>
        /// <c>false</c> if the queue is empty. Otherwise <c>true</c>.
        /// </returns>
        public override bool Poll(out T element) {
            if(_activeCount == 0) {
                element = default(T);
                return false;
            }

            T x = default(T);
            int c = -1;
            lock(takeLock) {
                if(_activeCount > 0) {
                    x = extract();
                    lock(this) {
                        c = _activeCount--;
                    }
                    if(c > 1)
                        Monitor.Pulse(takeLock);
                }
            }
            if(c == _capacity) {
                signalNotFull();
            }
            element = x;
            return true;
        }

        /// <summary>
        /// Returns <see lang="true"/> if there are no elements in the <see cref="IQueue{T}"/>, <see lang="false"/> otherwise.
        /// </summary>
        public override bool IsEmpty {
            get { return _activeCount == 0; }
        }

        /// <summary>
        /// Gets the capacity of this queue.
        /// </summary>
        public override int Capacity {
            get { return _capacity; }
        }

        /// <summary>
        /// When implemented by a class, copies the elements of the ICollection to an Array, starting at a particular Array index.
        /// </summary>
        /// <param name="targetArray">The one-dimensional Array that is the destination of the elements copied from ICollection. The Array must have zero-based indexing.</param>
        /// <param name="index">The zero-based index in array at which copying begins. </param>
        public override void CopyTo(T[] targetArray, Int32 index) {
            lock(putLock) {
                lock(takeLock) {
                    int size = _activeCount;
                    if(targetArray.Length < size)
                        targetArray = new T[size];

                    int k = 0;
                    for(Node p = head.next; p != null; p = p.next)
                        targetArray.SetValue(p.item, k++);
                }
            }
        }

        /// <summary>
        /// Gets the count of the queue. 
        /// </summary>
        public override int Count {
            get { return _activeCount; }
        }

        /// <summary>
        ///When implemented by a class, gets an object that can be used to synchronize access to the ICollection.  For this implementation,
        ///always return null, indicating the array is already synchronized.
        /// </summary>
        protected override object SyncRoot {
            get { return null; }
        }

        /// <summary>
        /// When implemented by a class, gets a value indicating whether access to the ICollection is synchronized (thread-safe).
        /// </summary>
        protected override bool IsSynchronized {
            get { return true; }
        }

        /// <summary>
        /// test whether the queue contains <paramref name="item"/> 
        /// </summary>
        /// <param name="item">the item whose containement should be checked</param>
        /// <returns><c>true</c> if item is in the queue, <c>false</c> otherwise</returns>
        public override bool Contains(T item) {
            throw new NotImplementedException();
        }

        #endregion

        /// <summary> 
        /// Returns an array containing all of the elements in this queue, in
        /// proper sequence.
        /// </summary>
        /// <remarks> 
        /// The returned array will be "safe" in that no references to it are
        /// maintained by this queue.  (In other words, this method must allocate
        /// a new array).  The caller is thus free to modify the returned array.
        /// 
        /// <p/>
        /// This method acts as bridge between array-based and collection-based
        /// APIs.
        /// </remarks>
        /// <returns> an array containing all of the elements in this queue</returns>
        public virtual T[] ToArray() {
            lock(putLock) {
                lock(takeLock) {
                    int size = _activeCount;
                    T[] a = new T[size];
                    int k = 0;
                    for(Node p = head.next; p != null; p = p.next)
                        a[k++] = p.item;
                    return a;
                }
            }
        }

        /// <summary>
        /// Returns an array containing all of the elements in this queue, in
        /// proper sequence; the runtime type of the returned array is that of
        /// the specified array.  If the queue fits in the specified array, it
        /// is returned therein.  Otherwise, a new array is allocated with the
        /// runtime type of the specified array and the size of this queue.
        ///	</summary>	 
        /// <remarks>
        /// If this queue fits in the specified array with room to spare
        /// (i.e., the array has more elements than this queue), the element in
        /// the array immediately following the end of the queue is set to
        /// <see lang="null"/>.
        /// <p/>
        /// Like the <see cref="LinkedBlockingQueue{T}.ToArray()"/>  method, this method acts as bridge between
        /// array-based and collection-based APIs.  Further, this method allows
        /// precise control over the runtime type of the output array, and may,
        /// under certain circumstances, be used to save allocation costs.
        /// <p/>
        /// Suppose <i>x</i> is a queue known to contain only strings.
        /// The following code can be used to dump the queue into a newly
        /// allocated array of <see lang="string"/>s:
        /// 
        /// <code>
        ///		string[] y = x.ToArray(new string[0]);
        ///	</code>
        ///	<p/>	
        /// Note that <i>toArray(new object[0])</i> is identical in function to
        /// <see cref="LinkedBlockingQueue{T}.ToArray()"/>.
        /// 
        /// </remarks>
        /// <param name="targetArray">
        /// the array into which the elements of the queue are to
        /// be stored, if it is big enough; otherwise, a new array of the
        /// same runtime type is allocated for this purpose
        /// </param>
        /// <returns> an array containing all of the elements in this queue</returns>
        /// <exception cref="System.ArgumentNullException">
        /// If the supplied <paramref name="targetArray"/> is
        /// <see lang="null"/> and this queue does not permit <see lang="null"/>
        /// elements.
        /// </exception>
        public virtual T[] ToArray(T[] targetArray) {
            lock(putLock) {
                lock(takeLock) {
                    int size = _activeCount;
                    if(targetArray.Length < size)
                        targetArray = new T[size];

                    int k = 0;
                    for(Node p = head.next; p != null; p = p.next)
                        targetArray[k++] = p.item;
                    return targetArray;
                }
            }
        }

        /// <summary>
        /// Returns a string representation of this colleciton.
        /// </summary>
        /// <returns>String representation of the elements of this collection.</returns>
        public override string ToString() {
            lock(putLock) {
                lock(takeLock) {
                    // TODO: ask Mark whether this method should take IEnumarable
                    //return StringUtils.CollectionToCommaDelimitedString(this);

                    return null;
                }
            }
        }

        /// <summary> 
        /// Removes all of the elements from this queue.
        /// </summary>
        /// <remarks>
        /// <p>
        /// The queue will be empty after this call returns.
        /// </p>
        /// <p>
        /// This implementation repeatedly invokes
        /// <see cref="Spring.Collections.AbstractQueue.Poll()"/> until it
        /// returns <see lang="null"/>.
        /// </p>
        /// </remarks>
        public override void Clear() {
            lock(putLock) {
                lock(takeLock) {
                    head.next = null;

                    last = head;
                    int c;
                    lock(this) {
                        c = _activeCount;
                        _activeCount = 0;
                    }
                    if(c == _capacity)
                        Monitor.PulseAll(putLock);
                }
            }
        }

        #region IEnumerable Members

        /// <summary>
        /// Returns an enumerator that can iterate through a collection.
        /// </summary>
        /// <returns>An IEnumerator that can be used to iterate through the collection.</returns>
        public override IEnumerator<T> GetEnumerator() {
            return new LinkedBlockingQueueEnumerator(this);
        }


        /// <summary>
        /// Internal enumerator class
        /// </summary>
        public class LinkedBlockingQueueEnumerator : IEnumerator<T> {
            private readonly LinkedBlockingQueue<T> _enclosingInstance;
            private Node _currentNode;
            private readonly int _countAtStart;
            private T _currentElement;

            /// <summary>
            /// Gets the current element in the collection.
            /// </summary>
            public virtual T Current {
                get {
                    return InternalCurrent;
                }
            }

            /// <summary>
            /// Gets the current element in the collection.
            /// </summary>
            private T InternalCurrent {
                get {
                    lock(Enclosing_Instance.putLock) {
                        lock(Enclosing_Instance.takeLock) {
                            if(_currentNode == null)
                                throw new NoElementsException();
                            return _currentElement;
                        }
                    }
                }

            }

            /// <summary>
            ///  
            /// </summary>
            public LinkedBlockingQueue<T> Enclosing_Instance {
                get { return _enclosingInstance; }

            }

            internal LinkedBlockingQueueEnumerator(LinkedBlockingQueue<T> enclosingInstance) {
                _enclosingInstance = enclosingInstance;
                lock(Enclosing_Instance.putLock) {
                    lock(Enclosing_Instance.takeLock) {
                        CurrentNode = Enclosing_Instance.head;
                        _countAtStart = Enclosing_Instance.Count;
                    }
                }
            }

            /// <summary>
            /// Sets the enumerator to its initial position, which is before the first element in the collection.
            /// </summary>
            public virtual void Reset() {
                lock(Enclosing_Instance.putLock) {
                    lock(Enclosing_Instance.takeLock) {
                        if(_countAtStart != Enclosing_Instance.Count)
                            throw new InvalidOperationException("queue has changed during enumeration");

                        CurrentNode = Enclosing_Instance.head;
                    }
                }
            }

            /// <summary>
            /// Advances the enumerator to the next element of the collection.
            /// </summary>
            /// <returns></returns>
            public virtual bool MoveNext() {
                if(_countAtStart != Enclosing_Instance.Count)
                    throw new InvalidOperationException("queue has changed during enumeration");
                
                Node nextNode = _currentNode.next;
                CurrentNode = nextNode;
                return nextNode != null;
            }

            private Node CurrentNode {
                set {
                    _currentNode = value;
                    if(_currentNode != null)
                        _currentElement = _currentNode.item;
                }
            }

            #region IDisposable Members

            /// <summary>
            /// TODO implement and document
            /// </summary>
            public void Dispose() {
            }

            #endregion

            #region IEnumerator Members

            object System.Collections.IEnumerator.Current {
                get {
                    return InternalCurrent;
                }
            }

            #endregion
        }

        #endregion
    }
}
