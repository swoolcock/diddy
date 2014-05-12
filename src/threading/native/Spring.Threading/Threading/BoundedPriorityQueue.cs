using System;

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
File: BoundedPriorityQueue.java

Originally written by Doug Lea and released into the public domain.
This may be used for any purposes whatsoever without acknowledgment.
Thanks for the assistance and support of Sun Microsystems Labs,
and everyone contributing, testing, and using this code.

History:
Date       Who                What
16Jun1998  dl               Create public version
25aug1998  dl               added peek
29aug1998  dl               pulled heap mechanics into separate class*/

namespace Spring.Threading
{
	
	/// <summary> A heap-based priority queue, using semaphores for
	/// concurrency control. 
	/// The take operation returns the <em>least</em> element
	/// with respect to the given ordering. (If more than
	/// one element is tied for least value, one of them is
	/// arbitrarily chosen to be returned -- no guarantees
	/// are made for ordering across ties.)
	/// Ordering follows the JDK1.2 collection
	/// conventions: Either the elements must be Comparable, or
	/// a Comparator must be supplied. Comparison failures throw
	/// ClassCastExceptions during insertions and extractions.
	/// The implementation uses a standard array-based heap algorithm,
	/// as described in just about any data structures textbook.
	/// <p>
	/// Put and take operations may throw ClassCastException 
	/// if elements are not Comparable, or
	/// not comparable using the supplied comparator. 
	/// Since not all elements are compared on each operation
	/// it is possible that an exception will not be thrown 
	/// during insertion of non-comparable element, but will later be 
	/// encountered during another insertion or extraction.
	/// </p>
	/// </summary>
	
	public class BoundedPriorityQueue:SemaphoreControlledChannel
	{
        /// <summary>
        /// The backing heap
        /// </summary>
		protected readonly internal Heap heap_;
		
		/// <summary> Create a priority queue with the given capacity and comparator</summary>
		/// <exception cref="ArgumentException">  if capacity less or equal to zero
		/// 
		/// </exception>
		
		public BoundedPriorityQueue(int capacity, System.Collections.IComparer cmp):base(capacity)
		{
			heap_ = new Heap(capacity, cmp);
		}
		
		/// <summary> Create a priority queue with the current default capacity
		/// and the given comparator
		/// 
		/// </summary>
		
		public BoundedPriorityQueue(System.Collections.IComparer comparator):this(DefaultChannelCapacity.DefaultCapacity, comparator)
		{
		}
		
		/// <summary> Create a priority queue with the given capacity,
		/// and relying on natural ordering.
		/// 
		/// </summary>
		
		public BoundedPriorityQueue(int capacity):this(capacity, null)
		{
		}
		
		/// <summary> Create a priority queue with the current default capacity
		/// and relying on natural ordering.
		/// 
		/// </summary>
		
		public BoundedPriorityQueue():this(DefaultChannelCapacity.DefaultCapacity, null)
		{
		}
		
		
		/// <summary> Create a priority queue with the given capacity and comparator, using
		/// the supplied Semaphore class for semaphores.
		/// </summary>
		public BoundedPriorityQueue(int capacity, System.Collections.IComparer cmp, System.Type semaphoreClass):base(capacity, semaphoreClass)
		{
			heap_ = new Heap(capacity, cmp);
		}

        /// <summary> Internal mechanics of put.
        /// </summary>
        /// <remarks>Delegates to heap</remarks>
        protected internal override void  Insert(System.Object x)
		{
			heap_.Insert(x);
		}
        
        /// <summary> Internal mechanics of take.
        /// </summary>
        /// <remarks>Delegates to heap</remarks>
        protected internal override System.Object Extract()
		{
			return heap_.Extract();
		}


        /// <summary>
        /// <see cref="IChannel.Peek"/>
        /// </summary>
        /// <remarks>Delegates to heap</remarks>
        public override System.Object Peek()
		{
			return heap_.Peek();
		}
	}
}