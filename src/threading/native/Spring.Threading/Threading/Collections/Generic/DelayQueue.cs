using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Threading;
using Spring.Collections;
using Spring.Collections.Generic;
using Spring.Threading.Future;

namespace Spring.Threading.Collections.Generic
{
	/// <summary>
	/// An unbounded <see cref="IBlockingQueue{T}"/> of
	/// <see cref="IDelayed"/> elements, in which an element can only be taken
	/// when its delay has expired. 
	/// </summary>
	/// <author>Doug Lea</author>
	/// <author>Griffin Caprio (.NET)</author>
    public class DelayQueue<T> : AbstractBlockingQueue<T> //TODO should we include this? where T : IDelayed
    {
        [NonSerialized]
        private object lockObject = new object();

        private PriorityQueue<T> _queue = new PriorityQueue<T>();

        /// <summary>
        /// Creates a new, empty <see cref="DelayQueue{T}"/>
        /// </summary>
        public DelayQueue() { }

        /// <summary>
        ///Creates a <see cref="DelayQueue{T}"/> initially containing the elements of the
        ///given collection of <see cref="IDelayed"/> instances.
        /// </summary>
        /// <param name="collection">collection of elements to populate queue with.</param>
        /// <exception cref="ArgumentNullException">If the collection is null.</exception>
        /// <exception cref="NullReferenceException">if any of the elements of the collection are null</exception>
        public DelayQueue(System.Collections.Generic.ICollection<T> collection)
        {
            AddRange(collection);
        }

        /// <summary>
        /// Inserts the specified element into this delay queue.
        /// </summary>
        /// <param name="element">element to add</param>
        /// <returns><see lang="true"/></returns>
        /// <exception cref="NullReferenceException">if the specified element is <see lang="null"/></exception>
        public override bool Offer(T element)
        {
            lock (lockObject)
            {
                T first;
                _queue.Offer(element);
                if (!_queue.Peek(out first) || ((IDelayed)element).CompareTo((IDelayed)first) < 0)
                {
                    Monitor.PulseAll(lockObject);
                }
                return true;
            }
        }

        /// <summary>
        ///	Inserts the specified element into this delay queue. As the queue is
        ///	unbounded this method will never block.
        /// </summary>
        /// <param name="element">element to add</param>
        /// <exception cref="NullReferenceException">if the element is <see lang="null"/></exception>
        public override void Put(T element)
        {
            Offer(element);
        }

        /// <summary>
        /// Returns the capacity of this queue. Since this is a unbounded queue, <see cref="int.MaxValue"/> is returned.
        /// </summary>
        public override int Capacity
        {
            get { return Int32.MaxValue; }
        }

        #region IBlockingQueue Members

        /// <summary> 
        /// Inserts the specified element into this queue, waiting up to the
        /// specified wait time if necessary for space to become available.
        /// </summary>
        /// <param name="objectToAdd">the element to add</param>
        /// <param name="duration">how long to wait before giving up</param>
        /// <returns> <see lang="true"/> if successful, or <see lang="false"/> if
        /// the specified waiting time elapses before space is available
        /// </returns>
        /// <exception cref="System.InvalidOperationException">
        /// If the element cannot be added at this time due to capacity restrictions.
        /// </exception>
        /// <exception cref="System.InvalidCastException">
        /// If the class of the supplied <paramref name="objectToAdd"/> prevents it
        /// from being added to this queue.
        /// </exception>
        /// <exception cref="System.ArgumentNullException">
        /// If the specified element is <see lang="null"/> and this queue does not
        /// permit <see lang="null"/> elements.
        /// </exception>
        /// <exception cref="System.ArgumentException">
        /// If some property of the supplied <paramref name="objectToAdd"/> prevents
        /// it from being added to this queue.
        /// </exception>
        public override bool Offer(T objectToAdd, TimeSpan duration)
        {
            return Offer(objectToAdd);
        }

        /// <summary> 
        /// Retrieves and removes the head of this queue, waiting if necessary
        /// until an element becomes available and/or expired.
        /// </summary>
        /// <returns> the head of this queue</returns>
        public override T Take()
        {
            lock (lockObject)
            {
                for (; ; )
                {
                    T first;
                    if (!_queue.Peek(out first))
                    {
                        Monitor.Wait(lockObject);
                    }
                    else
                    {
                        TimeSpan delay = ((IDelayed)first).GetRemainingDelay();
                        if (delay.Ticks > 0)
                        {
                            Monitor.Wait(lockObject, delay);
                        }
                        else
                        {
                            T x;
                            bool hasOne = _queue.Poll(out x);
                            Debug.Assert(hasOne);
                            if (_queue.Count != 0)
                            {
                                Monitor.PulseAll(lockObject);
                            }
                            return x;
                        }
                    }
                }
            }
        }

        /// <summary> 
        /// Retrieves and removes the head of this queue
        /// or returns <see lang="null"/> if this queue is empty or if the head has not expired.
        /// </summary>
        /// <returns> 
        /// The head of this queue, or <see lang="null"/> if this queue is empty or if the head has not expired.
        /// </returns>
        public override bool Poll(out T element)
        {
            lock (lockObject)
            {
                T first;
                if (!_queue.Peek(out first) || ((IDelayed)first).GetRemainingDelay().Ticks > 0)
                {
                    element = default(T);
                    return false;
                }
                else
                {
                    T x;
                    bool hasOne = _queue.Poll(out x);
                    Debug.Assert(hasOne);
                    if (_queue.Count != 0)
                    {
                        Monitor.PulseAll(lockObject);
                    }
                    element = x;
                    return true;
                }
            }
        }
        /// <summary>
        /// 
        /// </summary>
        /// <param name="element"></param>
        /// <returns></returns>
        public override bool Peek(out T element)
        {
            lock (lockObject)
            {
                T first;
                if (!_queue.Peek(out first) || ((IDelayed)first).GetRemainingDelay().Ticks > 0)
                {
                    element = default(T);
                    return false;
                }
                else
                {
                    T x;
                    bool hasOne = _queue.Peek(out x);
                    Debug.Assert(hasOne);
                    if (_queue.Count != 0)
                    {
                        Monitor.PulseAll(lockObject);
                    }
                    element = x;
                    return true;
                }
            }
        }
        /// <summary> 
        /// Retrieves and removes the head of this queue, waiting if necessary
        /// until an element with an expired delay is available on this queue,
        /// or the specified wait time expires.
        /// </summary>
        /// <param name="duration">how long to wait before giving up</param>a
        /// <param name="element"></param>
        /// <returns> 
        /// the head of this queue, or <see lang="null"/> if the
        /// specified waiting time elapses before an element is available
        /// </returns>
        public override bool Poll(TimeSpan duration, out T element)
        {
            lock (lockObject)
            {
                DateTime deadline = DateTime.Now.Add(duration);
                for (; ; )
                {
                    T first;
                    if (!_queue.Peek(out first))
                    {
                        if (duration.Ticks <= 0)
                        {
                            element = default(T);
                            return false;
                        }
                        else
                        {
                            Monitor.Wait(lockObject, duration);
                            duration = deadline.Subtract(DateTime.Now);
                        }
                    }
                    else
                    {
                        TimeSpan delay = ((IDelayed)first).GetRemainingDelay();
                        if (delay.Ticks > 0)
                        {
                            if (delay > duration)
                            {
                                delay = duration;
                            }
                            Monitor.Wait(lockObject, delay);
                            duration = deadline.Subtract(DateTime.Now);
                        }
                        else
                        {
                            T x;
                            bool hasOne = _queue.Poll(out x);
                            Debug.Assert(hasOne);
                            if (_queue.Count != 0)
                            {
                                Monitor.PulseAll(lockObject);
                            }
                            element = x;
                            return true;
                        }
                    }
                }
            }
        }

        /// <summary> 
        /// Returns the number of additional elements that this queue can ideally
        /// (in the absence of memory or resource constraints) accept without
        /// blocking, or <see cref="System.Int32.MaxValue"/> if there is no intrinsic
        /// limit.
        /// 
        /// <p/>
        /// Note that you <b>cannot</b> always tell if an attempt to insert
        /// an element will succeed by inspecting <see cref="IQueue{T}.RemainingCapacity"/>
        /// because it may be the case that another thread is about to
        /// insert or remove an element.
        /// </summary>
        /// <returns> the remaining capacity</returns>
        public override int RemainingCapacity
        {
            get { return Int32.MaxValue; }
        }

        /// <summary> 
        /// Does the real work for all <c>Drain</c> methods. Caller must
        /// guarantee the <paramref name="action"/> is not <c>null</c> and
        /// <paramref name="maxElements"/> is greater then zero (0).
        /// </summary>
        /// <seealso cref="IBlockingQueue{T}.DrainTo(ICollection{T})"/>
        /// <seealso cref="IBlockingQueue{T}.Drain(System.Action{T})"/>
        /// <seealso cref="IBlockingQueue{T}.DrainTo(ICollection{T},int)"/>
        protected override int DoDrainTo(Action<T> action, int maxElements)
        {
            lock (lockObject)
            {
                int n = 0;
                while (n < maxElements)
                {
                    T first;
                    if (!_queue.Peek(out first) || ((IDelayed)first).GetRemainingDelay().Ticks > 0)
                    {
                        break;
                    }
                    T head;
                    _queue.Poll(out head);
                    action(head);
                    ++n;
                }
                if (n > 0)
                {
                    Monitor.PulseAll(lockObject);
                }
                return n;
            }
        }

        #endregion

        #region ICollection Members


        /// <summary>
        /// Returns the current number of elements in this queue.
        /// </summary>
        public override int Count
        {
            get
            {
                lock (lockObject)
                {
                    return _queue.Count;
                }
            }
        }
        /// <summary>
        /// Returns <see lang="true"/> if there are no elements in the <see cref="IQueue"/>, <see lang="false"/> otherwise.
        /// </summary>
        public override bool IsEmpty
        {
            get { return _queue.Count == 0; }
        }
        /// <summary>
        /// 
        /// </summary>
        /// <returns></returns>
	    public override IEnumerator<T> GetEnumerator()
	    {
	        return _queue.GetEnumerator();
	    }

	    /// <summary>
        /// When implemented by a class, copies the elements of the ICollection to an Array, starting at a particular Array index.
        /// </summary>
        /// <param name="targetArray">The one-dimensional Array that is the destination of the elements copied from ICollection. The Array must have zero-based indexing.</param>
        /// <param name="index">The zero-based index in array at which copying begins. </param>
        protected override void CopyTo(Array targetArray, Int32 index)
        {
            if (null == targetArray) throw new ArgumentNullException("targetArray", "destination array is null");
            lock (lockObject)
            {
                int size = _queue.Count;
                if (targetArray.Length < size)
                {
                    targetArray = Array.CreateInstance(targetArray.GetType().GetElementType(), size);
                }
                int k = 0;
                foreach (T currentItem in _queue)
                {
                    targetArray.SetValue(currentItem, k++);
                }
            }
        }

        #endregion

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
        public override void Clear()
        {
            lock (lockObject)
            {
                _queue.Clear();
            }
        }

        /// <summary>
        /// Removes a single instance of the specified element from this
        /// queue, if it is present, whether or not it has expired.
        /// </summary>
        /// <param name="element">element to remove</param>
        /// <returns><see lang="true"/> if element was remove, <see lang="false"/> if not.</returns>
        public override bool Remove(T element) {
            lock (lockObject)
            {
                return _queue.Remove(element);
            }
        }
    }
}