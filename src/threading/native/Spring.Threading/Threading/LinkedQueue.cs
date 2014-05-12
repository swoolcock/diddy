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
Originally written by Doug Lea and released into the public domain.
This may be used for any purposes whatsoever without acknowledgment.
Thanks for the assistance and support of Sun Microsystems Labs,
and everyone contributing, testing, and using this code.
*/
using System;
using System.Threading;

namespace Spring.Threading
{
	
	/// <summary> A linked list based channel implementation.
	/// The algorithm avoids contention between puts
	/// and takes when the queue is not empty. 
	/// Normally a put and a take can proceed simultaneously. 
	/// (Although it does not allow multiple concurrent puts or takes.)
	/// This class tends to perform more efficently than
	/// other <see cref="IChannel"/> implementations in producer/consumer
	/// applications.
	/// </summary>
	
	public class LinkedQueue : IChannel
	{
        /// <summary>
        /// Utility method to avoid to call <see cref="Peek"/>
        /// </summary>
        /// <returns><code>true</code> if there are no items in the queue</returns>
        virtual public bool IsEmpty
		{
			get
			{
				lock (head_)
				{
					return head_.Next == null;
				}
			}
			
		}
		
		
		/// <summary> Dummy header node of list. The first actual node, if it exists, is always 
		/// at head_.Next. After each take, the old first node becomes the head.
		/// 
		/// </summary>
		protected internal LinkedNode head_;
		
		/// <summary> Helper monitor for managing access to last node.
		/// 
		/// </summary>
		protected internal readonly Object putLock_ = new object();
		
		/// <summary> The last node of list. Put() appends to list, so modifies last_
		/// 
		/// </summary>
		protected internal LinkedNode last_;
		
		/// <summary> The number of threads waiting for a take.
		/// Notifications are provided in put only if greater than zero.
		/// The bookkeeping is worth it here since in reasonably balanced
		/// usages, the notifications will hardly ever be necessary, so
		/// the call overhead to notify can be eliminated.
		/// 
		/// </summary>
		protected internal int waitingForTake_ = 0;
		
        /// <summary>
        /// creates a new queue with a node not paired to any object
        /// </summary>
		public LinkedQueue()
		{
			head_ = new LinkedNode(null);
			last_ = head_;
		}
		
		/// <summary>Main mechanics for put/offer *</summary>
		protected internal virtual void  insert(Object x)
		{
			lock (putLock_)
			{
				LinkedNode p = new LinkedNode(x);
				lock (last_)
				{
					last_.Next = p;
					last_ = p;
				}
				if (waitingForTake_ > 0)
				    Monitor.Pulse(putLock_);
			}
		}
		
		/// <summary>Main mechanics for take/poll *</summary>
		protected internal virtual Object Extract()
		{
			lock (this)
			{
				lock (head_)
				{
				    Object x = null;
					LinkedNode first = head_.Next;
					if (first != null)
					{
						x = first.Value;
						first.Value = null;
						head_ = first;
					}
					return x;
				}
			}
		}
		
		/// <summary>
		/// <see cref="IPuttable.Put"/>
		/// </summary>
		public virtual void  Put(Object x)
		{
			if (x == null)
				throw new ArgumentException();
            Utils.FailFastIfInterrupted();
			insert(x);
		}
		
        /// <summary>
        /// <see cref="IPuttable.Offer"/>
        /// </summary>
        public virtual bool Offer(Object x, long msecs)
		{
			if (x == null)
				throw new ArgumentException();
            Utils.FailFastIfInterrupted();
            insert(x);
			return true;
		}
		
        /// <summary>
        /// <see cref="ITakable.Take"/>
        /// </summary>
        public virtual Object Take()
		{
            Utils.FailFastIfInterrupted();
            // try to extract. If fail, then enter wait-based retry loop
		    Object x = Extract();
			if (x != null)
				return x;
			else
			{
				lock (putLock_)
				{
					try
					{
						++waitingForTake_;
						for (; ; )
						{
							x = Extract();
							if (x != null)
							{
								--waitingForTake_;
								return x;
							}
							else
							{
							    Monitor.Wait(putLock_);
							}
						}
					}
					catch (ThreadInterruptedException ex)
					{
						--waitingForTake_;
					    Monitor.Pulse(putLock_);
						throw ex;
					}
				}
			}
		}
		
        /// <summary>
        /// <see cref="IChannel.Peek"/>
        /// </summary>
        public virtual Object Peek()
		{
			lock (head_)
			{
				LinkedNode first = head_.Next;
				if (first != null)
					return first.Value;
				else
					return null;
			}
		}
		
        /// <summary>
        /// <see cref="ITakable.Poll"/>
        /// </summary>
		public virtual Object Poll(long msecs)
		{
            Utils.FailFastIfInterrupted();
		    Object x = Extract();
			if (x != null)
				return x;
			else
			{
				lock (putLock_)
				{
					try
					{
						long waitTime = msecs;
						long start = (msecs <= 0)?0:Utils.CurrentTimeMillis;
						++waitingForTake_;
						for (; ; )
						{
							x = Extract();
							if (x != null || waitTime <= 0)
							{
								--waitingForTake_;
								return x;
							}
							else
							{
							    Monitor.Wait(putLock_, TimeSpan.FromMilliseconds(waitTime));
								waitTime = msecs - (Utils.CurrentTimeMillis - start);
							}
						}
					}
					catch (ThreadInterruptedException ex)
					{
						--waitingForTake_;
					    Monitor.Pulse(putLock_);
						throw ex;
					}
				}
			}
		}
	}
}