/*
 * Written by Doug Lea with assistance from members of JCP JSR-166
 * Expert Group and released to the public domain, as explained at
 * http://creativecommons.org/licenses/publicdomain
 */

#region License

/*
 * Copyright (C) 2002-2008 the original author or authors.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#endregion

#region Imports
using System;
using System.Collections.Generic;
using System.Reflection;
using System.Runtime.Serialization;
using System.Threading;
using Spring.Collections.Generic;
using Spring.Threading.Locks;
#endregion

namespace Spring.Threading.Collections.Generic {

    /// <summary>
    /// An unbounded {@linkplain BlockingQueue blocking queue} that uses
    /// the same ordering rules as class {@link PriorityQueue} and supplies
    /// blocking retrieval operations.  While this queue is logically
    /// unbounded, attempted additions may fail due to resource exhaustion
    /// (causing <tt>OutOfMemoryError</tt>). This class does not permit
    /// <tt>null</tt> elements.  A priority queue relying on {@linkplain
    /// Comparable natural ordering} also does not permit insertion of
    /// non-comparable objects (doing so results in
    /// <tt>ClassCastException</tt>).
    /// 
    /// <p>This class and its iterator implement all of the
    /// <em>optional</em> methods of the {@link Collection} and {@link
    /// Iterator} interfaces.  The Iterator provided in method {@link
    /// #iterator()} is <em>not</em> guaranteed to traverse the elements of
    /// the PriorityBlockingQueue in any particular order. If you need
    /// ordered traversal, consider using
    /// <tt>Arrays.sort(pq.toArray())</tt>.  Also, method <tt>drainTo</tt>
    /// can be used to <em>remove</em> some or all elements in priority
    /// order and place them in another collection.</p>
    /// 
    /// <p>Operations on this class make no guarantees about the ordering
    /// of elements with equal priority. If you need to enforce an
    /// ordering, you can define custom classes or comparators that use a
    /// secondary key to break ties in primary priority values.  For
    /// example, here is a class that applies first-in-first-out
    /// tie-breaking to comparable elements. To use it, you would insert a
    /// <tt>new FIFOEntry(anEntry)</tt> instead of a plain entry object.</p>
    /// 
    /// <pre>
    /// class FIFOEntry implements Comparable {
    ///   final static AtomicLong seq = new AtomicLong();
    ///   final long seqNum;
    ///   final Object entry;
    ///   public FIFOEntry(Object entry) {
    ///     seqNum = seq.getAndIncrement();
    ///     this.entry = entry;
    ///   }
    ///   public Object getEntry() { return entry; }
    ///   public int compareTo(FIFOEntr other) {
    ///     int res = entry.compareTo(other.entry);
    ///     if (res == 0 &amp;&amp; other.entry != this.entry)
    ///       res = (seqNum &lt; other.seqNum ? -1 : 1);
    ///     return res;
    ///   }
    /// }</pre>
    /// </summary>
    /// <author>Doug Lea</author>
    /// <author>Andreas Döhring (.NET)</author>
    [Serializable]
    public class PriorityBlockingQueue<T> : AbstractBlockingQueue<T>, ISerializable  { //}, java.io.Serializable {

        private readonly PriorityQueue<T> _innerQueue;
        private readonly ReentrantLock _lock = new ReentrantLock(true);
        private readonly ICondition notEmpty;

        /// <summary>
        /// Creates a <tt>PriorityBlockingQueue</tt> with the default
        /// initial capacity (11) that orders its elements according to
        /// their {@linkplain Comparable natural ordering}.
        /// </summary>
        public PriorityBlockingQueue() {
            _innerQueue = new PriorityQueue<T>();
            notEmpty = _lock.NewCondition();
        }

        /// <summary>
        /// Creates a <tt>PriorityBlockingQueue</tt> with the specified
        /// initial capacity that orders its elements according to their
        /// {@linkplain Comparable natural ordering}.
        /// </summary>
        /// <param name="initialCapacity">the initial capacity for this priority queue</param>
        /// <exception cref="ArgumentException">if <tt>initialCapacity</tt> is less than 1</exception>
        public PriorityBlockingQueue(int initialCapacity) {
            _innerQueue = new PriorityQueue<T>(initialCapacity, null);
            notEmpty = _lock.NewCondition();
        }

        /// <summary>
        /// Creates a <tt>PriorityBlockingQueue</tt> with the specified initial
        /// capacity that orders its elements according to the specified
        /// comparator.
        /// </summary>
        /// <param name="initialCapacity">the initial capacity for this priority queue</param>
        /// <param name="comparator">comparator the comparator that will be used to order this priority queue.  
        /// If {@code null}, the {@linkplain Comparable natural ordering} of the elements will be used.</param>
        /// <exception cref="ArgumentException">if <tt>initialCapacity</tt> is less than 1</exception>
        public PriorityBlockingQueue(int initialCapacity, IComparer<T> comparator) {
            _innerQueue = new PriorityQueue<T>(initialCapacity, comparator);
            notEmpty = _lock.NewCondition();
        }

        /// <summary>
        /// Creates the inner <see cref="PriorityQueue{T}"/> from the specified collection
        /// </summary>
        /// <param name="collection">the collection whose elements are to be placed into this priority queue</param>
        public PriorityBlockingQueue(ICollection<T> collection) {
            _innerQueue = new PriorityQueue<T>(collection);
            notEmpty = _lock.NewCondition();
        }

        /// <summary> 
        /// Reconstitute the <see cref="Spring.Collections.PriorityQueue"/> instance from a stream (that is,
        /// deserialize it).
        /// </summary>
        /// <param name="serializationInfo">the stream</param>
        /// <param name="context">the context</param>
        protected PriorityBlockingQueue(SerializationInfo serializationInfo, StreamingContext context) {
            Type[] ctorArgumentTypes = new Type[] {typeof (SerializationInfo), typeof (StreamingContext)};
            
            ConstructorInfo ctorInfo = typeof(PriorityQueue<T>).GetConstructor(BindingFlags.Instance|BindingFlags.NonPublic,null,ctorArgumentTypes,null);
            
            object[] ctorParameters = new object[]{serializationInfo,context};
            
            _innerQueue = (PriorityQueue<T>)ctorInfo.Invoke(ctorParameters);
        }


        /// <summary>
        /// Inserts the specified element into this priority queue. Only calls <see cref="Offer(T)"/>
        /// </summary>
        /// <param name="element">the element to add</param>
        public override void Add(T element) {
            Offer(element);
        }

        /// <summary>
        /// Inserts the specified element into this priority queue.
        /// </summary>
        /// <param name="element">the element to add</param>
        /// <returns><tt>true</tt> (as specified by {@link Queue#Offer})</returns>
        /// <exception cref="System.InvalidCastException">
        /// if the specified element cannot be compared
        /// with elements currently in the priority queue according
        /// to the priority queue's ordering.
        /// </exception>
        /// <exception cref="System.InvalidOperationException">
        /// If the element cannot be added at this time due to capacity restrictions.
        /// </exception>
        /// <exception cref="System.ArgumentNullException">
        /// If the supplied <paramref name="element"/> is
        /// <see lang="null"/> and this queue does not permit <see lang="null"/>
        /// elements.
        /// </exception>
        /// <exception cref="System.ArgumentException">
        /// If some property of the supplied <paramref name="element"/> prevents
        /// it from being added to this queue.
        /// </exception>
        public override bool Offer(T element) {
            ReentrantLock rl = _lock;
            rl.Lock();
            try {
                bool ok = _innerQueue.Offer(element);
                if(!ok)
                    throw new InvalidOperationException("Offer returns false but must return true");
                notEmpty.Signal();
                return true;
            }
            finally {
                rl.Unlock();
            }
        }

        /// <summary>
        /// Inserts the specified element into this priority queue. As the queue is
        /// unbounded this method will never block. Only calls <see cref="Offer(T)"/>
        /// </summary>
        /// <param name="element">the element to add</param>
        public override void Put(T element) {
            Offer(element); // never need to block
        }

        /// <summary>
        /// Inserts the specified element into this priority queue. As the queue is
        /// unbounded this method will never block. Only calls <see cref="Offer(T)"/>
        /// </summary>
        /// <param name="element">the element to add</param>
        /// <param name="timeout">This parameter is ignored as the method never blocks</param>
        /// <returns></returns>
        public override bool Offer(T element, TimeSpan timeout) {
            return Offer(element); // never need to block
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
            ReentrantLock rl = _lock;
            rl.Lock();
            try {
                return _innerQueue.Poll(out element);
            }
            finally {
                rl.Unlock();
            }
        }

        /// <summary> 
        /// Retrieves and removes the head of this queue, waiting if necessary
        /// until an element becomes available.
        /// </summary>
        /// <returns> the head of this queue</returns>
        public override T Take() {
            ReentrantLock rl = _lock;
            rl.LockInterruptibly();
            try {
                try {
                    while(_innerQueue.Count == 0)
                        notEmpty.Await();
                }
                catch(ThreadInterruptedException) {
                    notEmpty.Signal(); // propagate to non-interrupted thread
                    throw;
                }
                T element;
                if(!_innerQueue.Poll(out element))
                    throw new InvalidOperationException("Poll returns unexpected false");
                return element;
            }
            finally {
                rl.Unlock();
            }
        }

        /// <summary> 
        /// Retrieves and removes the head of this queue, waiting up to the
        /// specified wait time if necessary for an element to become available.
        /// </summary>
        /// <param name="timeout">how long to wait before giving up</param>
        /// <param name="element"></param>
        /// <returns> 
        /// the head of this queue, or <see lang="default(T)"/> if the
        /// specified waiting time elapses before an element is available.
        /// </returns>
        public override bool Poll(TimeSpan timeout, out T element) {
            ReentrantLock rl = _lock;
            rl.LockInterruptibly();
            try {
                DateTime deadline = DateTime.Now + timeout;
                for(; ; ) {
                    if(_innerQueue.Poll(out element))
                        return true;
                    if(timeout.TotalMilliseconds <= 0)
                        return false;
                    try {
                        notEmpty.Await(timeout);
                        timeout = deadline - DateTime.Now;
                    }
                    catch(ThreadInterruptedException) {
                        notEmpty.Signal(); // propagate to non-interrupted thread
                        throw;
                    }
                }
            }
            finally {
                rl.Unlock();
            }
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
            ReentrantLock rl = _lock;
            rl.Lock();
            try {
                return _innerQueue.Peek(out element);
            }
            finally {
                rl.Unlock();
            }
        }

        /// <summary>
        /// Returns the comparator used to order the elements in this queue,
        /// or <tt>null</tt> if this queue uses the {@linkplain Comparable
        /// natural ordering} of its elements.
        /// </summary>
        public IComparer<T> Comparator {
            get { return _innerQueue.Comparator(); }
        }

        /// <summary>
        /// get the Count of the queue
        /// </summary>
        public override int Count {
            get {
                ReentrantLock rl = _lock;
                rl.Lock();
                try {
                    return _innerQueue.Count;
                }
                finally {
                    rl.Unlock();
                }
            }
        }

        /// <summary>
        /// get the capacity of the queue
        /// </summary>
        public override int Capacity {
            get {
                ReentrantLock rl = _lock;
                rl.Lock();
                try {
                    return _innerQueue.Capacity;
                }
                finally {
                    rl.Unlock();
                }
            }
        }

        /// <summary>
        /// Always returns <tt>Integer.MAX_VALUE</tt> because
        /// a <tt>PriorityBlockingQueue</tt> is not capacity constrained.
        /// </summary>
        public override int RemainingCapacity {
            get { return Int32.MaxValue; }
        }

        /// <summary>
        /// Removes a single instance of the specified element from this queue,
        /// if it is present.  More formally, removes an element {@code e} such
        /// that {@code o.equals(e)}, if this queue contains one or more such
        /// elements.  Returns {@code true} if and only if this queue contained
        /// the specified element (or equivalently, if this queue changed as a
        /// result of the call).
        /// </summary>
        /// <param name="element">element to be removed from this queue, if present</param>
        /// <returns><tt>true</tt> if this queue changed as a result of the call</returns>
        public override bool Remove(T element) {
            ReentrantLock rl = _lock;
            rl.Lock();
            try {
                return _innerQueue.Remove(element);
            }
            finally {
                rl.Unlock();
            }
        }

        /// <summary>
        /// Returns {@code true} if this queue contains the specified element.
        /// More formally, returns {@code true} if and only if this queue contains
        /// at least one element {@code e} such that {@code o.equals(e)}.
        /// </summary>
        /// <param name="element">element to be checked for containment in this queue</param>
        /// <returns><tt>true</tt> if this queue contains the specified element</returns>
        public override bool Contains(T element) {
            ReentrantLock rl = _lock;
            rl.Lock();
            try {
                return _innerQueue.Contains(element);
            }
            finally {
                rl.Unlock();
            }
        }

        /// <summary>
        /// Returns an array containing all of the elements in this queue.
        /// The returned array elements are in no particular order.
        /// 
        /// <p>The returned array will be "safe" in that no references to it are
        /// maintained by this queue.  (In other words, this method must allocate
        /// a new array).  The caller is thus free to modify the returned array.</p>
        /// 
        /// <p>This method acts as bridge between array-based and collection-based
        /// APIs.</p>
        /// </summary>
        /// <returns>an array containing all of the elements in this queue</returns>
        public T[] ToArray() {
            ReentrantLock rl = _lock;
            rl.Lock();
            try {
                T[] a = new T[_innerQueue.Count];
                int k = 0;
                foreach(T item in _innerQueue)
                    a[k++] = item;
                return a;

            }
            finally {
                rl.Unlock();
            }
        }

        /// <summary>
        /// get the string representation of the queue
        /// </summary>
        /// <returns>the string representation of the queue</returns>
        public override string ToString() {
            ReentrantLock rl = _lock;
            rl.Lock();
            try {
                return _innerQueue.ToString();
            }
            finally {
                rl.Unlock();
            }
        }

        /**
         * @throws UnsupportedOperationException {@inheritDoc}
         * @throws ClassCastException            {@inheritDoc}
         * @throws NullPointerException          {@inheritDoc}
         * @throws IllegalArgumentException      {@inheritDoc}
         */
        //TODO: do we really need this? can we leave it to base class?
        public override int DrainTo(ICollection<T> collection) {
            if(collection == null)
                throw new ArgumentNullException("collection", "must not be null");
            if(collection == this)
                throw new ArgumentException("cannot DrainTo this");
            ReentrantLock rl = _lock;
            rl.Lock();
            try {
                int n = 0;
                T element;
                while(_innerQueue.Poll(out element)) {
                    collection.Add(element);
                    ++n;
                }
                return n;
            }
            finally {
                rl.Unlock();
            }
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
            ReentrantLock rl = _lock;
            rl.Lock();
            try {
                int n = 0;
                T element;
                while(n < maxElements && _innerQueue.Poll(out element)) {
                    action(element);
                    ++n;
                }
                return n;
            }
            finally {
                rl.Unlock();
            }
        }

        /// <summary>
        /// Atomically removes all of the elements from this queue.
        /// The queue will be empty after this call returns.
        /// </summary>
        public override void Clear() {
            ReentrantLock rl = _lock;
            rl.Lock();
            try {
                _innerQueue.Clear();
            }
            finally {
                rl.Unlock();
            }
        }

        /// <summary>
        /// Returns an array containing all of the elements in this queue; the
        /// runtime type of the returned array is that of the specified array.
        /// The returned array elements are in no particular order.
        /// If the queue fits in the specified array, it is returned therein.
        /// Otherwise, a new array is allocated with the runtime type of the
        /// specified array and the size of this queue.
        /// 
        /// <p>If this queue fits in the specified array with room to spare
        /// (i.e., the array has more elements than this queue), the element in
        /// the array immediately following the end of the queue is set to
        /// <tt>null</tt>.</p>
        /// 
        /// <p>Like the {@link #toArray()} method, this method acts as bridge between
        /// array-based and collection-based APIs.  Further, this method allows
        /// precise control over the runtime type of the output array, and may,
        /// under certain circumstances, be used to save allocation costs.</p>
        /// 
        /// <p>Suppose <tt>x</tt> is a queue known to contain only strings.
        /// The following code can be used to dump the queue into a newly
        /// allocated array of <tt>String</tt>:</p>
        /// 
        /// <pre>
        ///     String[] y = x.toArray(new String[0]);</pre>
        /// 
        /// Note that <tt>toArray(new Object[0])</tt> is identical in function to
        /// <tt>toArray()</tt>.
        /// </summary>
        /// <param name="target">the array into which the elements of the queue are to
        /// be stored, if it is big enough; otherwise, a new array of the
        /// same runtime type is allocated for this purpose</param>
        /// <exception cref="ArgumentNullException">if <paramref name="target"/> is null</exception>
        public T[] ToArray(T[] target) {
            if(target == null)
                throw new ArgumentNullException("target must not be null");
            ReentrantLock rl = _lock;
            rl.Lock();
            try {
                int targetSize = target.Length;
                int sourceSize = Count;
                if(targetSize < sourceSize)
                    target = new T[sourceSize];

                int k = 0;
                foreach(T item in _innerQueue)
                    target[k++] = item;
                for(; targetSize < sourceSize; targetSize++)
                    target[targetSize] = default(T);

                return target;
            }
            finally {
                rl.Unlock();
            }
        }

        /**
         * Returns an iterator over the elements in this queue. The
         * iterator does not return the elements in any particular order.
         * The returned <tt>Iterator</tt> is a "weakly consistent"
         * iterator that will never throw {@link
         * java.util.ConcurrentModificationException}, and guarantees to traverse
         * elements as they existed upon construction of the iterator, and
         * may (but is not guaranteed to) reflect any modifications
         * subsequent to construction.
         *
         * @return an iterator over the elements in this queue
         */
        public override IEnumerator<T> GetEnumerator() {
            return new InnerEnumerator(ToArray());
        }

        /**
         * Snapshot iterator that works off copy of underlying q array.
         */
        private class InnerEnumerator : IEnumerator<T> {
            private readonly T[] _array;         // Array of all elements
            private int _cursor = -1;   // index of next element to return;

            public InnerEnumerator(T[] array) {
                _array = array;
            }

            #region IEnumerator<T> Members

            public T Current {
                get { return InternalCurrent; }
            }

            #endregion

            #region IDisposable Members

            public void Dispose() {
                // NOOP
            }

            #endregion

            #region IEnumerator Members

            object System.Collections.IEnumerator.Current {
                get { return InternalCurrent; }
            }

            public bool MoveNext() {
                return ++_cursor < _array.Length ? true : false;
            }

            public void Reset() {
                _cursor = -1;
            }

            #endregion

            private T InternalCurrent {
                get {
                    if(_cursor < 0)
                        throw new InvalidOperationException("access before start of queue");
                    return _array[_cursor];
                }
            }
        }

        /*
         * Saves the state to a stream (that is, serializes it).  This
         * merely wraps default serialization within lock.  The
         * serialization strategy for items is left to underlying
         * Queue. Note that locking is not needed on deserialization, so
         * readObject is not defined, just relying on default.
         */
        //private void writeObject(java.io.ObjectOutputStream s)
        //    throws java.io.IOException {
        //    lock.lock();
        //    try {
        //        s.defaultWriteObject();
        //    } finally {
        //        lock.unlock();
        //    }
        //}


        #region ISerializable Members

        /// <summary>
        /// get the datat of the inner queue during serialization process
        /// </summary>
        /// <param name="info">the serialization info</param>
        /// <param name="context">the serialization context</param>
        public void GetObjectData(SerializationInfo info, StreamingContext context) {
           _innerQueue.GetObjectData(info, context);
        }

        #endregion
    }
}
