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
File: Mutex.java

Originally written by Doug Lea and released into the public domain.
This may be used for any purposes whatsoever without acknowledgment.
Thanks for the assistance and support of Sun Microsystems Labs,
and everyone contributing, testing, and using this code.

History:
Date       Who                What
11Jun1998  dl               Create public version*/
using System;

namespace Spring.Threading
{
	
	/// <summary> A simple non-reentrant mutual exclusion lock.
	/// The lock is free upon construction. Each acquire gets the
	/// lock, and each release frees it. Releasing a lock that
	/// is already free has no effect. 
	/// <p>
	/// This implementation makes no attempt to provide any fairness
	/// or ordering guarantees. If you need them, consider using one of
	/// the Semaphore implementations as a locking mechanism.
	/// </p>
	/// <p>
	/// <b>Sample usage</b>
	/// </p>
	/// <p>
	/// Mutex can be useful in constructions that cannot be
	/// expressed using java synchronized blocks because the
	/// acquire/release pairs do not occur in the same method or
	/// code block. For example, you can use them for hand-over-hand
	/// locking across the nodes of a linked list. This allows
	/// extremely fine-grained locking,  and so increases 
	/// potential concurrency, at the cost of additional complexity and
	/// overhead that would normally make this worthwhile only in cases of
	/// extreme contention.
	/// <pre>
	/// class Node { 
	/// Object item; 
	/// Node next; 
	/// Mutex lock = new Mutex(); // each node keeps its own lock
	/// 
	/// Node(Object x, Node n) { item = x; next = n; }
	/// }
	/// 
	/// class List {
	/// protected Node head; // pointer to first node of list
	/// 
	/// // Use plain java synchronization to protect head field.
	/// //  (We could instead use a Mutex here too but there is no
	/// //  reason to do so.)
	/// protected synchronized Node getHead() { return head; }
	/// 
	/// boolean search(Object x) throws InterruptedException {
	/// Node p = getHead();
	/// if (p == null) return false;
	/// 
	/// //  (This could be made more compact, but for clarity of illustration,
	/// //  all of the cases that can arise are handled separately.)
	/// 
	/// p.lock.acquire();              // Prime loop by acquiring first lock.
	/// //    (If the acquire fails due to
	/// //    interrupt, the method will throw
	/// //    InterruptedException now,
	/// //    so there is no need for any
	/// //    further cleanup.)
	/// for (;;) {
	/// if (x.equals(p.item)) {
	/// p.lock.release();          // release current before return
	/// return true;
	/// }
	/// else {
	/// Node nextp = p.next;
	/// if (nextp == null) {
	/// p.lock.release();       // release final lock that was held
	/// return false;
	/// }
	/// else {
	/// try {
	/// nextp.lock.acquire(); // get next lock before releasing current
	/// }
	/// catch (InterruptedException ex) {
	/// p.lock.release();    // also release current if acquire fails
	/// throw ex;
	/// }
	/// p.lock.release();      // release old lock now that new one held
	/// p = nextp;
	/// }
	/// }
	/// }
	/// }
	/// 
	/// synchronized void add(Object x) { // simple prepend
	/// // The use of `synchronized'  here protects only head field.
	/// // The method does not need to wait out other traversers 
	/// // who have already made it past head.
	/// 
	/// head = new Node(x, head);
	/// }
	/// 
	/// // ...  other similar traversal and update methods ...
	/// }
	/// </pre>
	/// </p>
	/// </summary>
	/// <remarks>There already exists a <see cref="System.Threading.Mutex"/>, 
	/// and you probably want to use that; note however that this class can be used as an
	/// <see cref="ISync"/>
	/// </remarks>
	/// <seealso cref="Semaphore">
	/// </seealso>
	public class Mutex : ISync
	{
		
		/// <summary>The lock status *</summary>
		protected internal bool inuse_ = false;
		
        /// <summary>
        /// <see cref="ISync.Acquire"/>
        /// </summary>
		public virtual void Acquire()
		{
            Utils.FailFastIfInterrupted();
            lock (this)
			{
				try
				{
					while (inuse_)
						System.Threading.Monitor.Wait(this);
					inuse_ = true;
				}
				catch (System.Threading.ThreadInterruptedException ex)
				{
					System.Threading.Monitor.Pulse(this);
					throw ex;
				}
			}
		}
		
        /// <summary>
        /// <see cref="ISync.Release"/>
        /// </summary>
		public virtual void Release()
		{
			lock (this)
			{
				inuse_ = false;
				System.Threading.Monitor.Pulse(this);
			}
		}
		
		/// <summary>
		/// <see cref="ISync.Attempt"/>
		/// </summary>
		public virtual bool Attempt(long msecs)
		{
            Utils.FailFastIfInterrupted();
            lock (this)
			{
				if (!inuse_)
				{
					inuse_ = true;
					return true;
				}
				else if (msecs <= 0)
					return false;
				else
				{
					long waitTime = msecs;
					long start = Utils.CurrentTimeMillis;
					try
					{
						for (; ; )
						{
							System.Threading.Monitor.Wait(this, TimeSpan.FromMilliseconds(waitTime));
							if (!inuse_)
							{
								inuse_ = true;
								return true;
							}
							else
							{
								waitTime = msecs - (Utils.CurrentTimeMillis - start);
								if (waitTime <= 0)
									return false;
							}
						}
					}
					catch (System.Threading.ThreadInterruptedException ex)
					{
						System.Threading.Monitor.Pulse(this);
						throw ex;
					}
				}
			}
		}
	}
}