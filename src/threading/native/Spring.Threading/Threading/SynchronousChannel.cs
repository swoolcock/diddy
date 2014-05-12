#region License
/*
* Copyright ?2002-2005 the original author or authors.
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
/*
Originally written by Doug Lea and released into the public domain.
This may be used for any purposes whatsoever without acknowledgment.
Thanks for the assistance and support of Sun Microsystems Labs,
and everyone contributing, testing, and using this code.
*/
using System;
using System.Threading;

namespace Spring.Threading
{
	
    /// <summary> A rendezvous channel, similar to those used in CSP and Ada.
    /// 
    /// <p>Each put must wait for a take, and vice versa.</p>
    /// 
    /// <p>Synchronous channels
    /// are well suited for handoff designs, in which an object running in
    /// one thread must synch up with an object running in another thread
    /// in order to hand it some information, event, or task. 
    /// </p>  
    /// </summary>  	
    // TODO:
    // <p> If you only need threads to synch up without
    // exchanging information, consider using a <see cref="IBarrier"/>. If you need
    // bidirectional exchanges, consider using a <see cref="Rendezvous"/>.  
    // </p>

    public class SynchronousChannel : IBoundedChannel
    {		
        /*
        This implementation divides actions into two cases for puts:
		
        * An arriving putter that does not already have a waiting taker 
        creates a node holding item, and then waits for a taker to take it.
        * An arriving putter that does already have a waiting taker fills
        the slot node created by the taker, and notifies it to continue.
		
        And symmetrically, two for takes:
		
        * An arriving taker that does not already have a waiting putter
        creates an empty slot node, and then waits for a putter to fill it.
        * An arriving taker that does already have a waiting putter takes
        item from the node created by the putter, and notifies it to continue.
		
        This requires keeping two simple queues: waitingPuts and waitingTakes.
		
        When a put or take waiting for the actions of its counterpart
        aborts due to interruption or timeout, it marks the node
        it created as "Cancelled", which causes its counterpart to retry
        the entire put or take sequence.
        */
		
        /// <summary> Special marker used in queue nodes to indicate that
        /// the thread waiting for a change in the node has timed out
        /// or been interrupted.
        /// 
        /// </summary>
        protected internal static readonly Object Cancelled = new Object();
		
        /// <summary> Simple FIFO queue class to hold waiting puts/takes.
        /// 
        /// </summary>
        protected internal class Queue
        {
            /// <summary>
            /// Queue's head
            /// </summary>
            protected internal LinkedNode head;

            /// <summary>
            /// Queue's end
            /// </summary>
            protected internal LinkedNode last;
			
            /// <summary>
            /// Enqueue
            /// </summary>
            /// <param name="p">node to enqueue</param>
            protected internal virtual void  Enq(LinkedNode p)
            {
                if (last == null)
                    last = head = p;
                else
                    last = last.Next = p;
            }
			
            /// <summary>
            /// Dequeue
            /// </summary>
            /// <returns></returns>
            protected internal virtual LinkedNode Deq()
            {
                LinkedNode p = head;
                if (p != null && (head = p.Next) == null)
                    last = null;
                return p;
            }
        }
		
        /// <summary>
        /// put queue
        /// </summary>
        protected internal readonly Queue waitingPuts = new Queue();

        /// <summary>
        /// take queue
        /// </summary>
        protected internal readonly Queue waitingTakes = new Queue();

        /// <summary>
        /// <see cref="IBoundedChannel.Capacity"/>
        /// </summary>
        public virtual int Capacity
        {
            get { return 0; }
        }

        /// <returns><c>null</c>: synchronous channels do 
        /// not hold contents unless actively taken
        /// </returns>
        public virtual Object Peek()
        {
            return null;
        }
		
		/// <summary>
		/// <see cref="IPuttable.Put"/>
		/// </summary>
        public virtual void  Put(Object x)
        {
            if (x == null)
                throw new ArgumentException();
			
            // This code is conceptually straightforward, but messy
            // because we need to intertwine handling of put-arrives first
            // vs take-arrives first cases.
			
            // Outer loop is to handle retry due to cancelled waiting taker
            for (; ; )
            {
				
                // Get out now if we are interrupted
                Utils.FailFastIfInterrupted();				
                // Exactly one of item or slot will be nonnull at end of
                // synchronized block, depending on whether a put or a take
                // arrived first. 
                LinkedNode slot;
                LinkedNode item = null;
				
                lock (this)
                {
                    // Try to match up with a waiting taker; fill and signal it below
                    slot = waitingTakes.Deq();
					
                    // If no takers yet, create a node and wait below
                    if (slot == null)
                        waitingPuts.Enq(item = new LinkedNode(x));
                }
				
                if (slot != null)
                {
                    // There is a waiting taker.
                    // Fill in the slot created by the taker and signal taker to
                    // continue.
                    lock (slot)
                    {
                        if (slot.Value != Cancelled)
                        {
                            slot.Value = x;
                            Monitor.Pulse(slot);
                            return ;
                        }
                        // else the taker has cancelled, so retry outer loop
                    }
                }
                else
                {
                    // Wait for a taker to arrive and take the item.
                    lock (item)
                    {
                        try
                        {
                            while (item.Value != null)
                                Monitor.Wait(item);
                            return ;
                        }
                        catch (ThreadInterruptedException ie)
                        {
                            // If item was taken, return normally but set interrupt status
                            if (item.Value == null)
                            {
                                Thread.CurrentThread.Interrupt();
                                return ;
                            }
                            else
                            {
                                item.Value = Cancelled;
                                throw ie;
                            }
                        }
                    }
                }
            }
        }
		
        /// <summary>
        /// <see cref="ITakable.Take"/>
        /// </summary>
        public virtual Object Take()
        {
            // Entirely symmetric to put()
			
            for (; ; )
            {
                Utils.FailFastIfInterrupted();				
                LinkedNode item;
                LinkedNode slot = null;
				
                lock (this)
                {
                    item = waitingPuts.Deq();
                    if (item == null)
                        waitingTakes.Enq(slot = new LinkedNode());
                }
				
                if (item != null)
                {
                    lock (item)
                    {
                        Object x = item.Value;
                        if (x != Cancelled)
                        {
                            item.Value = null;
                            item.Next = null;
                            Monitor.Pulse(item);
                            return x;
                        }
                    }
                }
                else
                {
                    lock (slot)
                    {
                        try
                        {
                            for (; ; )
                            {
                                Object x = slot.Value;
                                if (x != null)
                                {
                                    slot.Value = null;
                                    slot.Next = null;
                                    return x;
                                }
                                else
                                    Monitor.Wait(slot);
                            }
                        }
                        catch (ThreadInterruptedException ie)
                        {
                            Object x = slot.Value;
                            if (x != null)
                            {
                                slot.Value = null;
                                slot.Next = null;
                                Thread.CurrentThread.Interrupt();
                                return x;
                            }
                            else
                            {
                                slot.Value = Cancelled;
                                throw ie;
                            }
                        }
                    }
                }
            }
        }
		
        /*
        Offer and poll are just like put and take, except even messier.
        */
		
		
        /// <summary>
        /// <see cref="IPuttable.Offer"/>
        /// </summary>
        public virtual bool Offer(Object x, long msecs)
        {
            if (x == null)
                throw new ArgumentException();
            long waitTime = msecs;
            long startTime = 0; // lazily initialize below if needed
			
            for (; ; )
            {
                Utils.FailFastIfInterrupted();				
                LinkedNode slot;
                LinkedNode item = null;
				
                lock (this)
                {
                    slot = waitingTakes.Deq();
                    if (slot == null)
                    {
                        if (waitTime <= 0)
                            return false;
                        else
                            waitingPuts.Enq(item = new LinkedNode(x));
                    }
                }
				
                if (slot != null)
                {
                    lock (slot)
                    {
                        if (slot.Value != Cancelled)
                        {
                            slot.Value = x;
                            Monitor.Pulse(slot);
                            return true;
                        }
                    }
                }
				
                long now = Utils.CurrentTimeMillis;
                if (startTime == 0)
                    startTime = now;
                else
                    waitTime = msecs - (now - startTime);
				
                if (item != null)
                {
                    lock (item)
                    {
                        try
                        {
                            for (; ; )
                            {
                                if (item.Value == null)
                                    return true;
                                if (waitTime <= 0)
                                {
                                    item.Value = Cancelled;
                                    return false;
                                }
                                Monitor.Wait(item, TimeSpan.FromMilliseconds(waitTime));
                                waitTime = msecs - (Utils.CurrentTimeMillis - startTime);
                            }
                        }
                        catch (ThreadInterruptedException ie)
                        {
                            if (item.Value == null)
                            {
                                Thread.CurrentThread.Interrupt();
                                return true;
                            }
                            else
                            {
                                item.Value = Cancelled;
                                throw ie;
                            }
                        }
                    }
                }
            }
        }
		
        /// <summary>
        /// <see cref="ITakable.Poll"/>
        /// </summary>
        public virtual Object Poll(long msecs)
        {
            long waitTime = msecs;
            long startTime = 0;
			
            for (; ; )
            {
                Utils.FailFastIfInterrupted();
                LinkedNode item;
                LinkedNode slot = null;
				
                lock (this)
                {
                    item = waitingPuts.Deq();
                    if (item == null)
                    {
                        if (waitTime <= 0)
                            return null;
                        else
                            waitingTakes.Enq(slot = new LinkedNode());
                    }
                }
				
                if (item != null)
                {
                    lock (item)
                    {
                        Object x = item.Value;
                        if (x != Cancelled)
                        {
                            item.Value = null;
                            item.Next = null;
                            Monitor.Pulse(item);
                            return x;
                        }
                    }
                }
				
                long now = Utils.CurrentTimeMillis;
                if (startTime == 0)
                    startTime = now;
                else
                    waitTime = msecs - (now - startTime);
				
                if (slot != null)
                {
                    lock (slot)
                    {
                        try
                        {
                            for (; ; )
                            {
                                Object x = slot.Value;
                                if (x != null)
                                {
                                    slot.Value = null;
                                    slot.Next = null;
                                    return x;
                                }
                                if (waitTime <= 0)
                                {
                                    slot.Value = Cancelled;
                                    return null;
                                }
                                Monitor.Wait(slot, TimeSpan.FromMilliseconds(waitTime));
                                waitTime = msecs - (Utils.CurrentTimeMillis - startTime);
                            }
                        }
                        catch (ThreadInterruptedException ie)
                        {
                            Object x = slot.Value;
                            if (x != null)
                            {
                                slot.Value = null;
                                slot.Next = null;
                                Thread.CurrentThread.Interrupt();
                                return x;
                            }
                            else
                            {
                                slot.Value = Cancelled;
                                throw ie;
                            }
                        }
                    }
                }
            }
        }
    }
}