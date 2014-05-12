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
	
	/// <summary> A bounded variant of 
	/// LinkedQueue 
	/// class. 
	/// <p>This class may be
	/// preferable to 
	/// <see cref="BoundedBuffer"/>
	/// because it allows a bit more
	/// concurency among puts and takes,  because it does not
	/// pre-allocate fixed storage for elements, and allows 
	/// capacity to be dynamically reset.
	/// On the other hand, since it allocates a node object
	/// on each put, it can be slow on systems with slow
	/// allocation and GC.</p>
	/// <p>Also, it may be preferable to 
	/// <see cref="LinkedQueue"/> when you need to limit
	/// the capacity to prevent resource exhaustion. This protection
	/// normally does not hurt much performance-wise: when the
	/// queue is not empty or full, most puts and
	/// takes are still usually able to execute concurrently.</p>
	/// </summary>
	/// <seealso cref="LinkedQueue"/>
	/// <seealso cref="BoundedBuffer"/>
	public class BoundedLinkedQueue : IBoundedChannel
	{
		/// <summary> Reset the capacity of this queue.
		/// If the new capacity is less than the old capacity,
		/// existing elements are NOT removed, but
		/// incoming puts will not proceed until the number of elements
		/// is less than the new capacity.
		/// </summary>
		/// <exception cref="ArgumentException"> if capacity less or equal to zero
		/// 
		/// </exception>
		virtual public int Capacity
		{
            get
            {
                lock (this)
                {
                    return capacity_;
                }                
            }
			set
			{
				if (value <= 0)
					throw new ArgumentException();
				lock (putGuard_)
				{
					lock (this)
					{
						takeSidePutPermits_ += (value - capacity_);
						capacity_ = value;
						
						// Force immediate reconcilation.
					    ReconcilePutPermits();
					    Monitor.PulseAll(this);
					}
				}
			}
			
		}

        /// <summary>
        /// Utility method to avoid to call <see cref="Peek"/>
        /// </summary>
        /// <returns><c>true</c> if there are no items in the queue</returns>
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
		
		/*
		* It might be a bit nicer if this were declared as
		* a subclass of LinkedQueue, or a sibling class of
		* a common abstract class. It shares much of the
		* basic design and bookkeeping fields. But too 
		* many details differ to make this worth doing.
		*/
		
		
		
		/// <summary> Dummy header node of list. The first actual node, if it exists, is always 
		/// at head_.next. After each take, the old first node becomes the head.
		/// 
		/// </summary>
		protected internal LinkedNode head_;
		
		/// <summary> The last node of list. Put() appends to list, so modifies last_
		/// 
		/// </summary>
		protected internal LinkedNode last_;
		
		
		/// <summary> Helper monitor. Ensures that only one put at a time executes.
		/// 
		/// </summary>
		
        protected readonly internal Object putGuard_ = new Object();
		
		/// <summary> Helper monitor. Protects and provides wait queue for takes
		/// 
		/// </summary>
		
		protected readonly internal Object takeGuard_ = new Object();
		
		
		/// <summary>Number of elements allowed *</summary>
		protected internal int capacity_;
		
		
		/// <summary> One side of a split permit count. 
		/// <p>The counts represent permits to do a put. (The queue is full when zero).
		/// Invariant: putSidePutPermits_ + takeSidePutPermits_ = capacity_ - length.
		/// (The length is never separately recorded, so this cannot be
		/// checked explicitly.)</p>
		/// <p>To minimize contention between puts and takes, the
		/// put side uses up all of its permits before transfering them from
		/// the take side.</p>
		/// <p>The take side just increments the count upon each take.
		/// Thus, most puts and take can run independently of each other unless
		/// the queue is empty or full.</p>
		/// Initial value is queue capacity.
		/// 
		/// </summary>
		
		protected internal int putSidePutPermits_;
		
		/// <summary>Number of takes since last reconcile *</summary>
		protected internal int takeSidePutPermits_ = 0;
		
		
		/// <summary> Create a queue with the given capacity</summary>
		/// <exception cref="ArgumentException"> if capacity less or equal to zero
		/// 
		/// </exception>
		public BoundedLinkedQueue(int capacity)
		{
			if (capacity <= 0)
				throw new ArgumentException();
			capacity_ = capacity;
			putSidePutPermits_ = capacity;
			head_ = new LinkedNode(null);
			last_ = head_;
		}
		
		/// <summary> Create a queue with the current default capacity
		/// 
		/// </summary>
		
		public BoundedLinkedQueue():this(DefaultChannelCapacity.DefaultCapacity)
		{
		}
		
		/// <summary> Move put permits from take side to put side; 
		/// return the number of put side permits that are available.
		/// Call only under synch on puGuard_ AND this.
		/// 
		/// </summary>
		protected internal int ReconcilePutPermits()
		{
			putSidePutPermits_ += takeSidePutPermits_;
			takeSidePutPermits_ = 0;
			return putSidePutPermits_;
		}

        /// <summary> Return the number of elements in the queue.
        /// This is only a snapshot value, that may be in the midst 
        /// of changing. The returned value will be unreliable in the presence of
        /// active puts and takes, and should only be used as a heuristic
        /// estimate, for example for resource monitoring purposes.
        /// 
        /// </summary>
        public virtual int Size
	    {
	        get
	        {
	            lock (this)
	            {
	                /*
				This should ideally synch on putGuard_, but
				doing so would cause it to block waiting for an in-progress
				put, which might be stuck. So we instead use whatever
				value of putSidePutPermits_ that we happen to read.
				*/
	                return capacity_ - (takeSidePutPermits_ + putSidePutPermits_);
	            }
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
						++takeSidePutPermits_;
					    Monitor.Pulse(this);
					}
					return x;
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
        /// <see cref="ITakable.Take"/>
        /// </summary>
        public virtual Object Take()
		{
		    Utils.FailFastIfInterrupted();
		    Object x = Extract();
			if (x != null)
				return x;
			else
			{
				lock (takeGuard_)
				{
					try
					{
						for (; ; )
						{
							x = Extract();
							if (x != null)
							{
								return x;
							}
							else
							{
							    Monitor.Wait(takeGuard_);
							}
						}
					}
					catch (ThreadInterruptedException ex)
					{
					    Monitor.Pulse(takeGuard_);
						throw ex;
					}
				}
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
				lock (takeGuard_)
				{
					try
					{
						long waitTime = msecs;
						long start = (msecs <= 0) ? 0 : Utils.CurrentTimeMillis;
						for (; ; )
						{
							x = Extract();
							if (x != null || waitTime <= 0)
							{
								return x;
							}
							else
							{
							    Monitor.Wait(takeGuard_, TimeSpan.FromMilliseconds(waitTime));
								waitTime = msecs - (Utils.CurrentTimeMillis - start);
							}
						}
					}
					catch (ThreadInterruptedException ex)
					{
					    Monitor.Pulse(takeGuard_);
						throw ex;
					}
				}
			}
		}
		
		/// <summary>Notify a waiting take if needed *</summary>
		protected internal void  AllowTake()
		{
			lock (takeGuard_)
			{
			    Monitor.Pulse(takeGuard_);
			}
		}
		
		
		/// <summary> Create and insert a node.
		/// Call only under synch on putGuard_
		/// 
		/// </summary>
		protected internal virtual void  Insert(Object x)
		{
			--putSidePutPermits_;
			LinkedNode p = new LinkedNode(x);
			lock (last_)
			{
				last_.Next = p;
				last_ = p;
			}
		}
		
		
		/* 
		put and offer(ms) differ only in policy before insert/allowTake
		*/
		
        /// <summary>
        /// <see cref="IPuttable.Put"/>
        /// </summary>
        public virtual void  Put(Object x)
		{
			if (x == null)
				throw new ArgumentException();
            Utils.FailFastIfInterrupted();
			
			lock (putGuard_)
			{
				
				if (putSidePutPermits_ <= 0)
				{
					// wait for permit. 
					lock (this)
					{
						if (ReconcilePutPermits() <= 0)
						{
							try
							{
								for (; ; )
								{
								    Monitor.Wait(this);
									if (ReconcilePutPermits() > 0)
									{
										break;
									}
								}
							}
							catch (ThreadInterruptedException ex)
							{
							    Monitor.Pulse(this);
								throw ex;
							}
						}
					}
				}
			    Insert(x);
			}
			// call outside of lock to loosen put/take coupling
            AllowTake();
		}
		
        /// <summary>
        /// <see cref="IPuttable.Offer"/>
        /// </summary>
        public virtual bool Offer(Object x, long msecs)
		{
			if (x == null)
				throw new ArgumentException();
            Utils.FailFastIfInterrupted();
			
			lock (putGuard_)
			{
				
				if (putSidePutPermits_ <= 0)
				{
					lock (this)
					{
						if (ReconcilePutPermits() <= 0)
						{
							if (msecs <= 0)
								return false;
							else
							{
								try
								{
									long waitTime = msecs;
									long start = Utils.CurrentTimeMillis;
									
									for (; ; )
									{
									    Monitor.Wait(this, TimeSpan.FromMilliseconds(waitTime));
										if (ReconcilePutPermits() > 0)
										{
											break;
										}
										else
										{
											waitTime = msecs - (Utils.CurrentTimeMillis - start);
											if (waitTime <= 0)
											{
												return false;
											}
										}
									}
								}
								catch (ThreadInterruptedException ex)
								{
								    Monitor.Pulse(this);
									throw ex;
								}
							}
						}
					}
				}
				
			    Insert(x);
			}
			
            AllowTake();
			return true;
		}
	}
}