using System;
using System.Collections.Generic;
using System.Threading;
using System.Xml.Serialization;
using Spring.Threading.Locks;

namespace Spring.Threading.Collections.Generic
{
    /// <summary>
    /// A <see cref="IBlockingQueue{T}"/> in which each insert
    /// operation must wait for a corresponding remove operation by another
    /// thread, and vice versa.  A synchronous queue does not have any
    /// internal capacity, not even a capacity of one.  You cannot
    /// <tt>peek</tt> at a synchronous queue because an element is only
    /// present when you try to remove it; you cannot insert an element
    /// (using any method) unless another thread is trying to remove it;
    /// you cannot iterate as there is nothing to iterate.  The
    /// <em>head</em> of the queue is the element that the first queued
    /// inserting thread is trying to add to the queue; if there is no such
    /// queued thread then no element is available for removal and
    /// <tt>poll()</tt> will return <tt>null</tt>.  For purposes of other
    /// <tt>Collection</tt> methods (for example <tt>contains</tt>), a
    /// <tt>SynchronousQueue</tt> acts as an empty collection.  This queue
    /// does not permit <tt>null</tt> elements.
    /// 
    /// <p>Synchronous queues are similar to rendezvous channels used in
    /// CSP and Ada. They are well suited for handoff designs, in which an
    /// object running in one thread must sync up with an object running
    /// in another thread in order to hand it some information, event, or
    /// task.</p>
    /// 
    /// <p> This class supports an optional fairness policy for ordering
    /// waiting producer and consumer threads.  By default, this ordering
    /// is not guaranteed. However, a queue constructed with fairness set
    /// to <tt>true</tt> grants threads access in FIFO order. Fairness
    /// generally decreases throughput but reduces variability and avoids
    /// starvation.</p>
    /// 
    /// <p>This class and its iterator implement all of the
    /// <em>optional</em> methods of the {@link Collection} and {@link
    /// Iterator} interfaces.</p>
    /// </summary>
    /// <author>Doug Lea</author>
    /// <author>Andreas Döhring (.NET)</author>
    public class SynchronousQueue<T> : AbstractBlockingQueue<T>
    {
        /*
          This implementation divides actions into two cases for puts:

          * An arriving producer that does not already have a waiting consumer
            creates a node holding item, and then waits for a consumer to take it.
          * An arriving producer that does already have a waiting consumer fills
            the slot node created by the consumer, and notifies it to continue.

          And symmetrically, two for takes:

          * An arriving consumer that does not already have a waiting producer
            creates an empty slot node, and then waits for a producer to fill it.
          * An arriving consumer that does already have a waiting producer takes
            item from the node created by the producer, and notifies it to continue.

          When a put or take waiting for the actions of its counterpart
          aborts due to interruption or timeout, it marks the node
          it created as "Cancelled", which causes its counterpart to retry
          the entire put or take sequence.

          This requires keeping two simple queues, waitingProducers and
          waitingConsumers. Each of these can be FIFO (preserves fairness)
          or LIFO (improves throughput).
        */

        /** Lock protecting both wait queues */
        private readonly ReentrantLock _qlock;
        /** Queue holding waiting puts */
        private readonly WaitQueue _waitingProducers;
        /** Queue holding waiting takes */
        private readonly WaitQueue _waitingConsumers;

        /// <summary>
        /// Creates a <tt>SynchronousQueue</tt> with nonfair access policy.
        /// </summary>
        public SynchronousQueue()
            : this(false) { }

        /// <summary>
        /// Creates a <tt>SynchronousQueue</tt> with specified fairness policy.
        /// </summary>
        /// <param name="fair">if true, threads contend in FIFO order for access otherwise the order is unspecified.</param>
        public SynchronousQueue(bool fair)
        {
            if (fair)
            {
                _qlock = new ReentrantLock(true);
                _waitingProducers = new FifoWaitQueue();
                _waitingConsumers = new FifoWaitQueue();
            }
            else
            {
                _qlock = new ReentrantLock();
                _waitingProducers = new LifoWaitQueue();
                _waitingConsumers = new LifoWaitQueue();
            }
        }

        /// <summary>
        /// Queue to hold waiting puts/takes; specialized to Fifo/Lifo below.
        /// These queues have all transient fields, but are serializable
        /// in order to recover fairness settings when deserialized.
        /// </summary>
        private abstract class WaitQueue
        { //}implements java.io.Serializable {
            /// <summary>
            /// Creates, adds, and returns node for x
            /// </summary>
            public abstract Node Enqueue(T x);

            /// <summary>
            /// Removes and returns node, or null if empty.
            /// </summary>
            public abstract Node Dequeue();

            /// <summary>
            /// Removes a cancelled node to avoid garbage retention.
            /// </summary>
            public abstract void Unlink(Node node);

            /// <summary>
            /// Returns true if a cancelled node might be on queue.
            /// </summary>
            public abstract bool ShouldUnlink(Node node);
        }

        /// <summary>
        /// FIFO queue to hold waiting puts/takes.
        /// </summary>
        private class FifoWaitQueue : WaitQueue
        { //}implements java.io.Serializable {
            //private static final long serialVersionUID = -3623113410248163686L;

            [XmlIgnore]
            private Node _head;
            [XmlIgnore]
            private Node _last;

            public override Node Enqueue(T x)
            {
                Node p = new Node(x);
                if (_last == null)
                    _last = _head = p;
                else
                    _last = _last.Next = p;
                return p;
            }

            public override Node Dequeue()
            {
                Node p = _head;
                if (p != null)
                {
                    if ((_head = p.Next) == null)
                        _last = null;
                    p.Next = null;
                }
                return p;
            }

            public override bool ShouldUnlink(Node node)
            {
                return (node == _last || node.Next != null);
            }

            public override void Unlink(Node node)
            {
                Node p = _head;
                Node trail = null;
                while (p != null)
                {
                    if (p == node)
                    {
                        Node next = p.Next;
                        if (trail == null)
                            _head = next;
                        else
                            trail.Next = next;
                        if (_last == node)
                            _last = trail;
                        break;
                    }
                    trail = p;
                    p = p.Next;
                }
            }
        }

        /**
         * LIFO queue to hold waiting puts/takes.
         */
        private class LifoWaitQueue : WaitQueue
        { //}implements java.io.Serializable {
            //private static final long serialVersionUID = -3633113410248163686L;
            [XmlIgnore]
            private Node _head;

            public override Node Enqueue(T x)
            {
                return _head = new Node(x, _head);
            }

            public override Node Dequeue()
            {
                Node p = _head;
                if (p != null)
                {
                    _head = p.Next;
                    p.Next = null;
                }
                return p;
            }

            public override bool ShouldUnlink(Node node)
            {
                // Return false if already dequeued or is bottom node (in which
                // case we might retain at most one garbage node)
                return (node == _head || node.Next != null);
            }

            public override void Unlink(Node node)
            {
                Node p = _head;
                Node trail = null;
                while (p != null)
                {
                    if (p == node)
                    {
                        Node next = p.Next;
                        if (trail == null)
                            _head = next;
                        else
                            trail.Next = next;
                        break;
                    }
                    trail = p;
                    p = p.Next;
                }
            }
        }

        /**
         * Unlinks the given node from consumer queue.  Called by cancelled
         * (timeout, interrupt) waiters to avoid garbage retention in the
         * absence of producers.
         */
        private void UnlinkCancelledConsumer(Node node)
        {
            // Use a form of double-check to avoid unnecessary locking and
            // traversal. The first check outside lock might
            // conservatively report true.
            if (_waitingConsumers.ShouldUnlink(node))
            {
                _qlock.Lock();
                try
                {
                    if (_waitingConsumers.ShouldUnlink(node))
                        _waitingConsumers.Unlink(node);
                }
                finally
                {
                    _qlock.Unlock();
                }
            }
        }

        /**
         * Unlinks the given node from producer queue.  Symmetric
         * to unlinkCancelledConsumer.
         */
        private void UnlinkCancelledProducer(Node node)
        {
            if (_waitingProducers.ShouldUnlink(node))
            {
                _qlock.Lock();
                try
                {
                    if (_waitingProducers.ShouldUnlink(node))
                        _waitingProducers.Unlink(node);
                }
                finally
                {
                    _qlock.Unlock();
                }
            }
        }

        /**
         * Nodes each maintain an item and handle waits and signals for
         * getting and setting it. The class extends
         * AbstractQueuedSynchronizer to manage blocking, using AQS state
         *  0 for waiting, 1 for ack, -1 for cancelled.
         */
        private class Node
        { //}implements java.io.Serializable {
            //private static final long serialVersionUID = -3223113410248163686L;

            /** Synchronization state value representing that node acked */
            private const int Ack = 1;
            /** Synchronization state value representing that node cancelled */
            private const int Cancel = -1;


            private readonly object _lock = new object();

            int _state;

            /** The item being transferred */
            private T _item;
            /** Next node in wait queue */
            private Node _next;

            /** Creates a node with initial item */
            public Node(T x) { _item = x; }

            /** Creates a node with initial item and next */
            public Node(T x, Node n) { _item = x; _next = n; }

            public Node Next { get { return _next; } set { _next = value; } }

            /**
             * Takes item and nulls out field (for sake of GC)
             *
             * PRE: lock owned
             */
            private T Extract()
            {
                T x = _item;
                _item = default(T);
                return x;
            }

            /**
             * Tries to cancel on interrupt; if so rethrowing,
             * else setting interrupt state
             *
             * PRE: lock owned
             */
            private void CheckCancellationOnInterrupt(ThreadInterruptedException ie)
            {
                if (_state == 0)
                {
                    _state = Cancel;
                    Monitor.Pulse(_lock);
                    throw ie;
                }
                Thread.CurrentThread.Interrupt();
            }

            /**
             * Fills in the slot created by the consumer and signal consumer to
             * continue.
             */
            public bool SetItem(T x)
            {
                lock (_lock)
                {
                    if (_state != 0) return false;
                    _item = x;
                    _state = Ack;
                    Monitor.Pulse(_lock);
                    return true;
                }
            }

            /**
             * Removes item from slot created by producer and signal producer
             * to continue.
             */
            public bool GetItem(out T item)
            {
                lock (_lock)
                {
                    if (_state != 0)
                    {
                        item = default(T);
                        return false;
                    }
                    _state = Ack;
                    Monitor.Pulse(_lock);
                    item = Extract();
                    return true;
                }
            }

            /**
             * Waits for a consumer to take item placed by producer.
             */
            public void WaitForTake()
            {
                lock (_lock)
                {
                    try
                    {
                        while (_state == 0)
                            Monitor.Wait(_lock);
                    }
                    catch (ThreadInterruptedException ie)
                    {
                        CheckCancellationOnInterrupt(ie);
                    }
                }
            }

            /**
             * Waits for a producer to put item placed by consumer.
             */
            public T WaitForPut()
            {
                lock (_lock)
                {
                    try
                    {
                        while (_state == 0)
                            Monitor.Wait(_lock);
                    }
                    catch (ThreadInterruptedException ie)
                    {
                        CheckCancellationOnInterrupt(ie);
                    }
                    return Extract();
                }
            }

            private bool Attempt(long nanos)
            {
                if (_state != 0) return true;
                if (nanos <= 0)
                {
                    _state = Cancel;
                    Monitor.Pulse(_lock);
                    return false;
                }
                long deadline = DateTime.Now.Ticks - nanos;
                while (true)
                {
                    //TimeUnit.NANOSECONDS.timedWait(this, nanos);
                    if (_state != 0) return true;
                    nanos = deadline - DateTime.Now.Ticks;
                    if (nanos <= 0)
                    {
                        _state = Cancel;
                        Monitor.Pulse(_lock);
                        return false;
                    }
                }
            }

            /**
             * Waits for a consumer to take item placed by producer or time out.
             */
            public bool WaitForTake(long nanos)
            {
                lock (this)
                {
                    try
                    {
                        if (!Attempt(nanos)) return false;
                    }
                    catch (ThreadInterruptedException ie)
                    {
                        CheckCancellationOnInterrupt(ie);
                    }
                    return true;
                }
            }

            /**
             * Waits for a producer to put item placed by consumer, or time out.
             */
            public bool WaitForPut(long nanos, out T element)
            {
                lock (this)
                {
                    try
                    {
                        if (!Attempt(nanos))
                        {
                            element = default(T);
                            return false;
                        }
                    }
                    catch (ThreadInterruptedException ie)
                    {
                        CheckCancellationOnInterrupt(ie);
                    }
                    element = Extract();
                    return true;
                }
            }
        }

        /// <summary>
        /// Adds the specified element to this queue, waiting if necessary for
        /// another thread to receive it.
        /// </summary>
        /// <param name="e"></param>
        /// <exception cref="ArgumentNullException" />
        /// <exception cref="ThreadInterruptedException" />
        public override void Put(T e)
        {
            if (e == null)
                throw new ArgumentNullException("e");

            ReentrantLock qlock = _qlock;

            for (; ; )
            {
                Node node;
                bool mustWait;
                //if (Thread.Interrupted) throw new InterruptedException();
                qlock.Lock();
                try
                {
                    node = _waitingConsumers.Dequeue();
                    mustWait = (node == null);
                    if (mustWait)
                        node = _waitingProducers.Enqueue(e);
                }
                finally
                {
                    qlock.Unlock();
                }

                if (mustWait)
                {
                    try
                    {
                        node.WaitForTake();
                        return;
                    }
                    catch (ThreadInterruptedException)
                    {
                        UnlinkCancelledProducer(node);
                        throw;
                    }
                }

                if (node.SetItem(e))
                    return;

                // else consumer cancelled, so retry
            }
        }

        /**
         * Inserts the specified element into this queue, waiting if necessary
         * up to the specified wait time for another thread to receive it.
         *
         * @return <tt>true</tt> if successful, or <tt>false</tt> if the
         *         specified waiting time elapses before a consumer appears.
         * @throws InterruptedException {@inheritDoc}
         * @throws NullPointerException {@inheritDoc}
         */
        public override bool Offer(T e, TimeSpan timeout)
        {
            if (e == null)
                throw new ArgumentNullException();
            long nanos = DateTime.Now.Ticks;// unit.toNanos(timeout);
            ReentrantLock qlock = _qlock;
            for (; ; )
            {
                Node node;
                bool mustWait;
                //if (Thread.interrupted()) throw new InterruptedException();
                qlock.Lock();
                try
                {
                    node = _waitingConsumers.Dequeue();
                    mustWait = (node == null);
                    if (mustWait)
                        node = _waitingProducers.Enqueue(e);
                }
                finally
                {
                    qlock.Unlock();
                }

                if (mustWait)
                {
                    try
                    {
                        bool x = node.WaitForTake(nanos);
                        if (!x)
                            UnlinkCancelledProducer(node);
                        return x;
                    }
                    catch (ThreadInterruptedException)
                    {
                        UnlinkCancelledProducer(node);
                        throw;
                    }
                }

                if (node.SetItem(e))
                    return true;

                // else consumer cancelled, so retry
            }
        }

        /**
         * Retrieves and removes the head of this queue, waiting if necessary
         * for another thread to insert it.
         *
         * @return the head of this queue
         * @throws InterruptedException {@inheritDoc}
         */
        public override T Take()
        {
            ReentrantLock qlock = _qlock;
            for (; ; )
            {
                Node node;
                bool mustWait;

                //if (Thread.interrupted()) throw new InterruptedException();
                qlock.Lock();
                try
                {
                    node = _waitingProducers.Dequeue();
                    mustWait = (node == null);
                    if (mustWait)
                        node = _waitingConsumers.Enqueue(default(T));
                }
                finally
                {
                    qlock.Unlock();
                }

                if (mustWait)
                {
                    try
                    {
                        Object x = node.WaitForPut();
                        return (T)x;
                    }
                    catch (ThreadInterruptedException)
                    {
                        UnlinkCancelledConsumer(node);
                        throw;
                    }
                }
                else
                {
                    T x;
                    if (node.GetItem(out x))
                        return x;
                    // else cancelled, so retry
                }
            }
        }

        /**
         * Retrieves and removes the head of this queue, waiting
         * if necessary up to the specified wait time, for another thread
         * to insert it.
         *
         * @return the head of this queue, or <tt>null</tt> if the
         *         specified waiting time elapses before an element is present.
         * @throws InterruptedException {@inheritDoc}
         */
        public override bool Poll(TimeSpan timeout, out T element)
        {
            long nanos = timeout.Ticks; // unit.toNanos(timeout);
            ReentrantLock qlock = _qlock;

            for (; ; )
            {
                Node node;
                bool mustWait;

                //if (Thread.interrupted()) throw new InterruptedException();
                qlock.Lock();
                try
                {
                    node = _waitingProducers.Dequeue();
                    mustWait = (node == null);
                    if (mustWait)
                        node = _waitingConsumers.Enqueue(default(T));
                }
                finally
                {
                    qlock.Unlock();
                }

                if (mustWait)
                {
                    try
                    {
                        T x;
                        if (!node.WaitForPut(nanos, out x))
                            UnlinkCancelledConsumer(node);
                        element = x;
                        return true;
                    }
                    catch (ThreadInterruptedException)
                    {
                        UnlinkCancelledConsumer(node);
                        throw;
                    }
                }
                else
                {
                    T x;
                    if (node.GetItem(out x))
                    {
                        element = x;
                        return true;
                    }
                    // else cancelled, so retry
                }
            }
        }



        // Untimed nonblocking versions

        /// <summary>
        /// Inserts the specified element into this queue, if another thread is
        /// waiting to receive it.
        /// </summary>
        /// <param name="element">the element to add</param>
        /// <returns><tt>true</tt> if the element was added to this queue, else <tt>false</tt></returns>
        /// <exception cref="ArgumentNullException" />
        public override bool Offer(T element)
        {
            if (element == null)
                throw new ArgumentNullException("element");
            ReentrantLock qlock = _qlock;

            for (; ; )
            {
                Node node;
                qlock.Lock();
                try
                {
                    node = _waitingConsumers.Dequeue();
                }
                finally
                {
                    qlock.Unlock();
                }
                if (node == null)
                    return false;

                else if (node.SetItem(element))
                    return true;
                // else retry
            }
        }

        /**
         * Retrieves and removes the head of this queue, if another thread
         * is currently making an element available.
         *
         * @return the head of this queue, or <tt>null</tt> if no
         *         element is available.
         */
        public override bool Poll(out T element)
        {
            ReentrantLock qlock = _qlock;
            for (; ; )
            {
                Node node;
                qlock.Lock();
                try
                {
                    node = _waitingProducers.Dequeue();
                }
                finally
                {
                    qlock.Unlock();
                }
                if (node == null)
                {
                    element = default(T);
                    return false;
                }

                else
                {
                    T x;
                    if (node.GetItem(out x))
                    {
                        element = x;
                        return true;
                    }
                    // else retry
                }
            }
        }

        /// <summary>
        /// Always returns <c>true</c>.
        /// A <see cref="SynchronousQueue{T}"/> has no internal capacity.
        /// </summary>
        public override bool IsEmpty
        {
            get { return true; }
        }

        /// <summary>
        /// Always returns zero.
        /// A <see cref="SynchronousQueue{T}"/> has no internal capacity.
        /// </summary>
        public override int Count
        {
            get { return 0; }
        }

        /// <summary>
        /// Always returns zero.
        /// A <see cref="SynchronousQueue{T}"/> has no internal capacity.
        /// </summary>
        public override int RemainingCapacity
        {
            get { return 0; }
        }

        /**
         * Always returns <tt>false</tt>.
         * A <tt>SynchronousQueue</tt> has no internal capacity.
         *
         * @param o object to be checked for containment in this queue
         * @return <tt>false</tt>
         */
        public override bool Contains(T item)
        {
            return false;
        }

        /**
         * Always returns <tt>false</tt>.
         * A <tt>SynchronousQueue</tt> has no internal capacity.
         *
         * @param o the element to remove
         * @return <tt>false</tt>
         */
        public override bool Remove(T item)
        {
            return false;
        }
        /**
         * Always returns <tt>null</tt>.
         * A <tt>SynchronousQueue</tt> does not return elements
         * unless actively waited on.
         *
         * @return <tt>null</tt>
         */
        public override bool Peek(out T element)
        {
            element = default(T);
            return false;
        }

        private class EmptyIterator : IEnumerator<T>
        {

            #region IEnumerator<T> Members

            public T Current
            {
                get { throw new InvalidOperationException(); }
            }

            #endregion

            #region IDisposable Members

            public void Dispose()
            {
            }

            #endregion

            #region IEnumerator Members

            object System.Collections.IEnumerator.Current
            {
                get { throw new InvalidOperationException(); }
            }

            public bool MoveNext()
            {
                return false;
            }

            public void Reset()
            {
            }

            #endregion
        }

        /**
         * Returns an empty iterator in which <tt>hasNext</tt> always returns
         * <tt>false</tt>.
         *
         * @return an empty iterator
         */
        public override IEnumerator<T> GetEnumerator()
        {
            return new EmptyIterator();
        }

        /**
         * Sets the zeroeth element of the specified array to <tt>null</tt>
         * (if the array has non-zero length) and returns it.
         *
         * @param a the array
         * @return the specified array
         * @throws NullPointerException if the specified array is null
         */
        public override void CopyTo(T[] array, int index)
        {
            if (array.Length > 0)
                array[0] = default(T);
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
            int n = 0;
            T element;
            while (n < maxElements && Poll(out element))
            {
                action(element);
                ++n;
            }
            return n;
        }

        /// <summary>
        /// 
        /// </summary>
        protected override bool IsSynchronized
        {
            get { return true; }
        }
        /// <summary>
        /// 
        /// </summary>
        public override int Capacity
        {
            get { return 0; }
        }
    }
}
