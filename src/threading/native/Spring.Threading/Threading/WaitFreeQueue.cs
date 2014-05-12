#region License
/*
* Copyright © 2002-2005 the original author or authors.
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
File: WaitFreeQueue.java

Originally written by Doug Lea and released into the public domain.
This may be used for any purposes whatsoever without acknowledgment.
Thanks for the assistance and support of Sun Microsystems Labs,
and everyone contributing, testing, and using this code.

History:
Date       Who                What
16Jun1998  dl               Create public version
5Aug1998  dl               replaced int counters with longs
17nov2001  dl               Simplify given Bill Pugh's observation
that counted pointers are unnecessary.*/

namespace Spring.Threading
{
	
	/// <summary> A wait-free linked list based queue implementation.
	/// <p>
	/// 
	/// While this class conforms to the full Channel interface, only the
	/// <code>put</code> and <code>poll</code> methods are useful in most
	/// applications. Because the queue does not support blocking
	/// operations, <code>take</code> relies on spin-loops, which can be
	/// extremely wasteful.  </p>
	/// <p>
	/// This class is adapted from the algorithm described in <a
	/// href="http://www.cs.rochester.edu/u/michael/PODC96.html"> Simple,
	/// Fast, and Practical Non-Blocking and Blocking Concurrent Queue
	/// Algorithms</a> by Maged M. Michael and Michael L. Scott.  This
	/// implementation is not strictly wait-free since it relies on locking
	/// for basic atomicity and visibility requirements.  Locks can impose
	/// unbounded waits, although this should not be a major practical
	/// concern here since each lock is held for the duration of only a few
	/// statements. (However, the overhead of using so many locks can make
	/// it less attractive than other Channel implementations on JVMs where
	/// locking operations are very slow.)
	/// </p>
	/// 
	/// </summary>
	/// <seealso cref="BoundedLinkedQueue">
	/// </seealso>
	/// <seealso cref="LinkedQueue">
	/// </seealso>
	
	public class WaitFreeQueue : IChannel
    {
        /// <summary>
        /// Creates a new <see cref="WaitFreeQueue"/> instance.
        /// </summary>
		public WaitFreeQueue()
		{
            head = new Node(null);
            tail = head;
            tailLock = new System.Object();
        }
		
		/*
		This is a straightforward adaptation of Michael & Scott
		algorithm, with CAS's simulated via per-field locks,
		and without version numbers for pointers since, under
		Java Garbage Collection, you can never see the "wrong"
		node with the same address as the one you think you have.
		*/
		
		/// <summary>List nodes for Queue *</summary>
		protected internal sealed class Node
		{
			internal readonly System.Object value;
			internal volatile Node next;
			
			/// <summary>Make a new node with indicated item, and null link *</summary>
			internal Node(System.Object x)
			{
			    value = x;
			}
			
			/// <summary>Simulate a CAS operation for 'next' field *</summary>
			internal bool CASNext(Node oldNext, Node newNext)
			{
				lock (this)
				{
					if (next == oldNext)
					{
						next = newNext;
						return true;
					}
					else
						return false;
				}
			}
		}
		
		/// <summary>Head of list is always a dummy node *</summary>
		protected internal volatile Node head;
		/// <summary>Pointer to last node on list *</summary>
		protected internal volatile Node tail;
		
		/// <summary>Lock for simulating CAS for tail field  *</summary>
		protected internal readonly System.Object tailLock;
		
		/// <summary>Simulate CAS for head field, using 'this' lock *</summary>
		protected internal virtual bool CASHead(Node oldHead, Node newHead)
		{
			lock (this)
			{
				if (head == oldHead)
				{
					head = newHead;
					return true;
				}
				else
					return false;
			}
		}
		
		/// <summary>Simulate CAS for tail field *</summary>
		protected internal virtual bool CASTail(Node oldTail, Node newTail)
		{
			lock (tailLock)
			{
				if (tail == oldTail)
				{
					tail = newTail;
					return true;
				}
				else
					return false;
			}
		}

		/// <summary>
		/// <see cref="IPuttable.Put"/>
		/// </summary>
		/// <param name="x"></param>
		public virtual void  Put(System.Object x)
		{
			if (x == null)
				throw new System.ArgumentException();
            Utils.FailFastIfInterrupted();
			Node n = new Node(x);
			
			for (; ; )
			{
				Node t = tail;
				// Try to link new node to end of list.
				if (t.CASNext(null, n))
				{
					// Must now change tail field.
					// This CAS might fail, but if so, it will be fixed by others.
					CASTail(t, n);
					return ;
				}
				
				// If cannot link, help out a previous failed attempt to move tail
				CASTail(t, t.next);
			}
		}

		/// <summary>
		/// <see cref="IPuttable.Offer"/>
		/// </summary>
		/// <param name="x"></param>
		/// <param name="msecs"></param>
		/// <returns></returns>
		public virtual bool Offer(System.Object x, long msecs)
		{
		    Put(x);
			return true;
		}
		
		/// <summary>Main dequeue algorithm, called by poll, take. *</summary>
		protected internal virtual System.Object Extract()
		{
			for (; ; )
			{
				Node h = head;
				Node first = h.next;
				
				if (first == null)
					return null;
				
				System.Object result = first.value;
				if (CASHead(h, first))
					return result;
			}
		}
		
        /// <summary>
        /// <see cref="IChannel.Peek"/>
        /// </summary>
        /// <returns></returns>
		public virtual System.Object Peek()
		{
			Node first = head.next;
			
			if (first == null)
				return null;
			
			// Note: This synch unnecessary after JSR-133.
			// It exists only to guarantee visibility of returned object,
			// No other synch is needed, but "old" memory model requires one.
			lock (this)
			{
				return first.value;
			}
		}
		
		/// <summary> Spin until poll returns a non-null value.
		/// You probably don't want to call this method.
		/// A Thread.sleep(0) is performed on each iteration
		/// as a heuristic to reduce contention. If you would
		/// rather use, for example, an exponential backoff, 
		/// you could manually set this up using poll. 
		/// 
		/// </summary>
		public virtual System.Object Take()
		{
            Utils.FailFastIfInterrupted();
			for (; ; )
			{
				System.Object x = Extract();
				if (x != null)
					return x;
				else
					System.Threading.Thread.Sleep(new System.TimeSpan(10000 * 0));
			}
		}
		
		/// <summary> Spin until poll returns a non-null value or time elapses.
		/// if msecs is positive, a Thread.sleep(0) is performed on each iteration
		/// as a heuristic to reduce contention.
		/// 
		/// </summary>
		public virtual System.Object Poll(long msecs)
		{
            Utils.FailFastIfInterrupted();
            if (msecs <= 0)
				return Extract();
			
			
			long startTime = Utils.CurrentTimeMillis;
			for (; ; )
			{
				System.Object x = Extract();
				if (x != null)
					return x;
				else
				{
					if (Utils.CurrentTimeMillis - startTime >= msecs)
						return null;
					else
						System.Threading.Thread.Sleep(new System.TimeSpan(10000 * 0));
				}
			}
		}
	}
}