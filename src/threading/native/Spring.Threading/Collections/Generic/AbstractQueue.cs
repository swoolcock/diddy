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

#endregion

namespace Spring.Collections.Generic
{
	/// <summary> 
	/// This class provides skeletal implementations for some of
	/// <see cref="IQueue{T}"/> and all of <see cref="IQueue"/> operations.
	/// </summary>
	/// <remarks>
	/// <para>
	/// The methods <see cref="Add"/>, <see cref="Remove"/>, and
	/// <see cref="Element()"/> are based on the <see cref="Offer"/>,
	/// <see cref="Poll"/>, and <see cref="Peek"/> methods respectively but 
	/// throw exceptions instead of indicating failure via
	/// <see langword="false"/> returns.
	/// </para>
	/// </remarks>
	/// <author>Doug Lea</author>
	/// <author>Griffin Caprio (.NET)</author>
	/// <author>Kenneth Xu</author>
	[Serializable]
	public abstract class AbstractQueue<T> : AbstractCollection<T>, IQueue<T>, IQueue
	{
        /// <summary> 
        /// Adds all of the elements in the supplied <paramref name="collection"/>
        /// to this queue.
        /// </summary>
        /// <remarks>
        /// <para>
        /// Attempts to <see cref="AddRange"/> of a queue to 
        /// itself result in <see cref="ArgumentException"/>. Further, the 
        /// behavior of this operation is undefined if the specified
        /// collection is modified while the operation is in progress.
        /// </para>
        /// <para>
        /// This implementation iterates over the specified collection, and 
        /// adds each element returned by the iterator to this queue, in turn.
        /// An exception encountered while trying to add an element may result 
        /// in only some of the elements having been successfully added when 
        /// the associated exception is thrown.
        /// </para>
        /// </remarks>
        /// <param name="collection">
        /// The collection containing the elements to be added to this queue.
        /// </param>
        /// <exception cref="System.ArgumentNullException">
        /// If the supplied <paramref name="collection"/> is <see langword="null"/>.
        /// </exception>
        /// <exception cref="System.ArgumentException">
        /// If the collection is the current queue.
        /// </exception>
        public virtual bool AddRange(IEnumerable<T> collection)
        {
            if (collection == null)
            {
                throw new ArgumentNullException("collection");
            }
            if (collection == this)
            {
                throw new ArgumentException("Cannot add to itself.");
            }
            bool modified = false;
            foreach (T element in collection)
            {
                Add(element);
                modified = true;
            }
            return modified;
        }


	    /// <summary>
        /// Returns the remaining capacity of this queue.
        /// </summary>
        public abstract int RemainingCapacity { get; }

        #region IQueue<T> Members

	    /// <summary>
	    /// Inserts the specified element into this queue if it is possible to 
	    /// do so immediately without violating capacity restrictions. 
	    /// </summary>
	    /// <remarks>
	    /// When using a capacity-restricted queue, this method is generally 
	    /// preferable to <see cref="Add"/>, which can fail to 
	    /// insert an element only by throwing an exception. 
	    /// </remarks>
	    /// <param name="element">The element to add.</param>
	    /// <returns>
	    /// <c>true</c> if the element was added to this queue. Otherwise 
	    /// <c>false</c>.
	    /// </returns>
	    /// <exception cref="ArgumentNullException">
	    /// If the <paramref name="element"/> is <c>null</c> and the queue 
	    /// implementation doesn't allow <c>null</c>.
	    /// </exception>
	    /// <exception cref="ArgumentException">
	    /// If some property of the supplied <paramref name="element"/> 
	    /// prevents it from being added to this queue. 
	    /// </exception>
	    public abstract bool Offer(T element);

	    /// <summary>
	    /// Retrieves, but does not remove, the head of this queue. 
	    /// </summary>
	    /// <remarks>
	    /// <para>
	    /// This method differs from <see cref="Peek(out T)"/> in that it throws an 
	    /// exception if this queue is empty. 
	    /// </para>
	    /// <para>
        /// this implementation returns the result of <see cref="Peek"/> 
        /// unless the queue is empty.
	    /// </para>
	    /// </remarks>
	    /// <returns>The head of this queue.</returns>
	    /// <exception cref="NoElementsException">
	    /// If this queue is empty.
	    /// </exception>
	    public virtual T Element()
        {
            T element;
            if (Peek(out element))
            {
                return element;
            }
            else
            {
                throw new NoElementsException("Queue is empty.");
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
	    public abstract bool Peek(out T element);

	    /// <summary>
	    /// Retrieves and removes the head of this queue. 
	    /// </summary>
	    /// <returns>The head of this queue</returns>
	    /// <exception cref="NoElementsException">
	    /// If this queue is empty.
	    /// </exception>
	    public virtual T Remove()
        {
            T element;
            if (Poll(out element))
            {
                return element;
            }
            else
            {
                throw new NoElementsException("Queue is empty.");
            }
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
	    public abstract bool Poll(out T element);

        #endregion

        #region ICollection<T> Members

	    /// <summary>
        /// Inserts the specified <paramref name="element"/> into this queue 
        /// if it is possible to do so immediately without violating capacity 
        /// restrictions. Throws an <see cref="InvalidOperationException"/> 
        /// if no space is currently available.
	    /// </summary>
        /// <param name="element">The element to add.</param>
        /// <exception cref="InvalidOperationException">
        /// If the <paramref name="element"/> cannot be added at this time due 
        /// to capacity restrictions. 
        /// </exception>
	    public override void Add(T element)
        {
            if (!Offer(element))
            {
                throw new InvalidOperationException("Queue full.");
            }
        }

	    /// <summary>
	    /// Removes all items from the queue.
	    /// </summary>
	    /// <remarks>
	    /// This implementation repeatedly calls the <see cref="Poll"/> moethod
	    /// until it returns <c>false</c>.
	    /// </remarks>
	    public override void Clear()
        {
            T element;
            while (Poll(out element)) {;}
        }

        #endregion

        #region IQueue Members

        /// <summary>
        /// Add differ from <see cref="IQueue.Offer"/> by throwing exception
        /// When queue is full.
        /// </summary>
        /// <param name="objectToAdd"></param>
        /// <returns></returns>
        bool IQueue.Add(object objectToAdd)
        {
            Add((T) objectToAdd);
            return true;
        }

        object IQueue.Element()
        {
            return Element();
        }

        /// <summary>
        /// Returns <see langword="true"/> if there are no elements in the 
        /// <see cref="IQueue{T}"/>, <see langword="false"/> otherwise.
        /// </summary>
        public virtual bool IsEmpty
        {
            get { return Count==0; }
        }

        /// <summary>
        /// Returns the current capacity of this queue.
        /// </summary>
        public abstract int Capacity { get; }

        bool IQueue.Offer(object objectToAdd)
        {
            return Offer((T) objectToAdd);
        }

        object IQueue.Peek()
        {
            T element;
            return Peek(out element) ? (object)element : null;
        }

        object IQueue.Poll()
        {
            T element;
            return Poll(out element) ? (object)element : null;
        }

        /// <summary>
        /// Remove differ from <see cref="IQueue.Poll"/> by throwing exception
        /// When queue is empty.
        /// </summary>
        /// <returns></returns>
        object IQueue.Remove()
        {
            return Remove();
        }

        #endregion

    }
}