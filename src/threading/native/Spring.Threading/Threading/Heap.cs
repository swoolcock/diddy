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
File: Heap.java

Originally written by Doug Lea and released into the public domain.
This may be used for any purposes whatsoever without acknowledgment.
Thanks for the assistance and support of Sun Microsystems Labs,
and everyone contributing, testing, and using this code.

History:
Date       Who                What
29Aug1998  dl               Refactored from BoundedPriorityQueue
08dec2001  dl               Null out slots of removed items
03feb2002  dl               Also null out in clear*/
using System;
namespace Spring.Threading
{
	
	/// <summary> A heap-based priority queue, without any concurrency control
	/// (i.e., no blocking on empty/full states).
	/// This class provides the data structure mechanics for BoundedPriorityQueue.
	/// <p>
	/// The class currently uses a standard array-based heap, as described
	/// in, for example, Sedgewick's Algorithms text. All methods
	/// are fully synchronized. In the future,
	/// it may instead use structures permitting finer-grained locking.
	/// </p>
	/// </summary>
	
	public class Heap
	{
        /// <summary>
        /// the tree nodes, packed into an array
        /// </summary>
		protected internal System.Object[] nodes_; 
        /// <summary>
        /// number of used slots
        /// </summary>
		protected internal int count_ = 0; 
        /// <summary>
        /// comparer for ordering
        /// </summary>
		protected readonly internal System.Collections.IComparer cmp_; 
		
		/// <summary> Create a Heap with the given initial capacity and comparator</summary>
		/// <exception cref="ArgumentException "> if capacity less or equal to zero
		/// 
		/// </exception>
		
		public Heap(int capacity, System.Collections.IComparer cmp)
		{
			if (capacity <= 0)
				throw new System.ArgumentOutOfRangeException("capacity", capacity, "Only positive values");
			nodes_ = new System.Object[capacity];
			cmp_ = cmp;
		}
		
		/// <summary> Create a Heap with the given capacity,
		/// and relying on natural ordering.
		/// 
		/// </summary>
		
		public Heap(int capacity):this(capacity, null)
		{
		}
		
		
		/// <summary>perform element comaprisons using comparator or natural ordering *</summary>
		protected internal virtual int Compare(System.Object a, System.Object b)
		{
			if (cmp_ == null)
				return ((System.IComparable) a).CompareTo(b);
			else
				return cmp_.Compare(a, b);
		}
		
		
		/// <summary>
		/// index of heap parent
		/// </summary>
		protected internal int Parent(int k)
		{
			return (k - 1) / 2;
		}

        /// <summary>
        /// index of left child 
        /// </summary>
		protected internal int Left(int k)
		{
			return 2 * k + 1;
		}

        /// <summary>
        /// index of right child 
        /// </summary>
		protected internal int Right(int k)
		{
			return 2 * (k + 1);
		}
		
		/// <summary> insert an element, resize if necessary
		/// 
		/// </summary>
		public virtual void  Insert(System.Object x)
		{
			lock (this)
			{
				if (count_ >= nodes_.Length)
				{
					int newcap = 3 * nodes_.Length / 2 + 1;
					System.Object[] newnodes = new System.Object[newcap];
					Array.Copy(nodes_, 0, newnodes, 0, nodes_.Length);
					nodes_ = newnodes;
				}
				
				int k = count_;
				++count_;
				while (k > 0)
				{
					int par = Parent(k);
					if (Compare(x, nodes_[par]) < 0)
					{
						nodes_[k] = nodes_[par];
						k = par;
					}
					else
						break;
				}
				nodes_[k] = x;
			}
		}
		
		
		/// <summary> Return and remove least element, or null if empty
		/// 
		/// </summary>
		
		public virtual System.Object Extract()
		{
			lock (this)
			{
				if (count_ < 1)
					return null;
				
				int k = 0; // take element at root;
				System.Object least = nodes_[k];
				--count_;
				System.Object x = nodes_[count_];
				nodes_[count_] = null;
				for (; ; )
				{
					int l = Left(k);
					if (l >= count_)
						break;
					else
					{
						int r = Right(k);
						int child = (r >= count_ || Compare(nodes_[l], nodes_[r]) < 0)?l:r;
						if (Compare(x, nodes_[child]) > 0)
						{
							nodes_[k] = nodes_[child];
							k = child;
						}
						else
							break;
					}
				}
				nodes_[k] = x;
				return least;
			}
		}
		
		/// <summary>Return least element without removing it, or null if empty *</summary>
		public virtual System.Object Peek()
		{
			lock (this)
			{
				if (count_ > 0)
					return nodes_[0];
				else
					return null;
			}
		}
		
		/// <summary>Return number of elements *</summary>
		public virtual int Size()
		{
			lock (this)
			{
				return count_;
			}
		}
		
		/// <summary>remove all elements *</summary>
		public virtual void  Clear()
		{
			lock (this)
			{
				for (int i = 0; i < count_; ++i)
					nodes_[i] = null;
				count_ = 0;
			}
		}
	}
}