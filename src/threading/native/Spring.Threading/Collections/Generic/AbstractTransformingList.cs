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
using System.Collections;
using System.Collections.Generic;
#endregion

namespace Spring.Collections.Generic
{
    /// <summary>
    /// Provide basic functions to construct a new strongly typed list
    /// of type <typeparamref name="TTo"/> from another strongly typed list
    /// of type <typeparamref name="TFrom"/> without copying the elements.
    /// </summary>
    /// <remarks>
    /// <para>
    /// The constructed new list is a shallow copy of the source list.
    /// Changes to any one of the list will be seen by another.
    /// </para>
    /// </remarks>
    /// <typeparam name="TFrom">the element type of the constructed list</typeparam>
    /// <typeparam name="TTo">the element type of the source list</typeparam>
    /// <author>Kenneth Xu</author>
    public abstract class AbstractTransformingList<TFrom, TTo> : AbstractList<TTo>
    {

        /// <summary>
        /// Constructor that takes the <paramref name="source"/> list.
        /// </summary>
        /// <param name="source">the original source list</param>
        protected AbstractTransformingList(IList<TFrom> source)
        {
            if (source==null) throw new ArgumentNullException("source");
            SourceList = source;
        }

        /// <summary>
        /// Gets the number of elements contained in this list.
        /// </summary>
        /// <remarks>
        /// This implementation returns the count of the source list.
        /// </remarks>
        /// <returns>
        /// The number of elements contained in this list.
        /// </returns>
        /// 
        public override int Count
        {
            get { return SourceList.Count; }
        }

        /// <summary>
        /// Gets or sets the element at the specified index.
        /// </summary>
        /// <remarks>
        /// <para>
        /// Getter retrieves the element from the underlaying source list
        /// and then converts to the <typeparamref name="TTo"/> type using
        /// the <see cref="Transform"/> method.
        /// </para>
        /// <para>
        /// Setter reverse converts the <paramref name="value"/> using the
        /// <see cref="Reverse"/> mehtod and then set the converted data to 
        /// the underlaying source list.
        /// </para>
        /// </remarks>
        /// <returns>
        /// The element at the specified index.
        /// </returns>
        /// 
        /// <param name="index">
        /// The zero-based index of the element to get or set.</param>
        /// <exception cref="ArgumentOutOfRangeException">
        /// index is not a valid index in the underlaying source list/>.
        /// </exception>
        /// <exception cref="NotSupportedException">
        /// The property is set and the underlaying source list is read-only 
        /// or the <see cref="Reverse"/> method throws this exception.
        /// </exception>
        public override TTo this[int index]
        {
            get { return Transform(SourceList[index]); }
            set { SourceList[index] = Reverse(value); }
        }

        /// <summary>
        /// Inserts an item to the <see cref="AbstractTransformingList{TFrom, TTo}"/> 
        /// at the specified index.
        /// </summary>
        /// <remarks>
        /// Reverse converts the <paramref name="item"/> to type 
        /// <typeparamref name="TFrom"/> and insert the result data into the 
        /// underlaying source list.
        /// </remarks>
        /// <param name="item">
        /// The object to insert into the list.</param>
        /// <param name="index">
        /// The zero-based index at which item should be inserted.</param>
        /// <exception cref="NotSupportedException">
        /// When the underlaying source list is read-only or the 
        /// <see cref="Reverse"/> method throws this exception.</exception>
        /// <exception cref="ArgumentOutOfRangeException">
        /// index is not a valid index in the underlaying source list"/>.
        /// </exception>
        public override void Insert(int index, TTo item)
        {
            SourceList.Insert(index, Reverse(item));
        }

        /// <summary>
        /// Removes the list item at the specified index.
        /// </summary>
        /// <remarks>
        /// Removes the underlaying source list item at the specified
        /// index.
        /// </remarks>
        /// <param name="index">
        /// The zero-based index of the item to remove.</param>
        /// <exception cref="NotSupportedException">
        /// When the underlaying source list is read-only.</exception>
        /// <exception cref="ArgumentOutOfRangeException">
        /// index is not a valid index in the underlaying source list"/>.
        /// </exception>
        public override void RemoveAt(int index)
        {
            SourceList.RemoveAt(index);
        }

        /// <summary>
        /// Adds an item to this list.
        /// </summary>
        /// <remarks>
        /// Converts the <paramref name="item"/> to <typeparamref name="TFrom"/>
        /// using the <see cref="Reverse"/> method. Then add converted
        /// item into the source list.
        /// </remarks>
        /// <param name="item">
        /// The object to add to the list.
        /// </param>
        /// <exception cref="NotSupportedException">
        /// The underlaying source list is read-only or the <see cref="Reverse"/> 
        /// method throws this exception.
        /// </exception>
        public override void Add(TTo item)
        {
            SourceList.Add(Reverse(item));
        }

        /// <summary>
        /// Removes all items from this list.
        /// </summary>
        /// <remarks>
        /// Remove all item from the underlaying source list.
        /// </remarks>
        /// <exception cref="NotSupportedException">
        /// When the underlaying source list is read-only.
        /// </exception>
        public override void Clear()
        {
            SourceList.Clear();
        }

        /// <summary>
        /// Determines whether this list contains a specific <paramref name="item"/>.
        /// </summary>
        /// <remarks>
        /// <para>
        /// This implementation <see cref="TryReverse">try to reverse</see>
        /// the item to source element type using <see cref="Reverse"/> and call the
        /// <see cref="ICollection{T}.Contains"/> method on the underlaying source list;
        /// Otherwise, calls the <see cref="ICollection{TTo}.Contains"/> method of
        /// base class.
        /// </para>
        /// </remarks>
        /// <returns>
        /// true if item is found in this list; otherwise, false.
        /// </returns>
        /// <param name="item">
        /// The object to locate in this list.
        /// </param>
        public override bool Contains(TTo item)
        {
            TFrom source;
            return (TryReverse(item, out source)) ? 
                SourceList.Contains(source) : base.Contains(item);
        }

        /// <summary>
        /// Removes the first occurrence of a specific object from the <see cref="ICollection{T}"/>.
        /// </summary>
        /// 
        /// <returns>
        /// true if item was successfully removed from the <see cref="ICollection{T}"/>; 
        /// otherwise, false. This method also returns false if item is not found in the 
        /// original <see cref="ICollection{T}"/>.
        /// </returns>
        /// 
        /// <param name="item">The object to remove from the <see cref="ICollection{T}"/>.</param>
        /// <exception cref="NotSupportedException">
        /// When the <see cref="ICollection{T}"/> is read-only.
        /// </exception>
        public override bool Remove(TTo item)
        {
            TFrom result;
            if (TryReverse(item, out result)) return SourceList.Remove(result);

            foreach (TFrom sourceItem in SourceList)
            {
                if (Transform(sourceItem).Equals(item)) return SourceList.Remove(sourceItem);
            }
            return false;
        }

        /// <summary>
        /// Gets a value indicating whether the <see cref="ICollection{T}"/> is read-only.
        /// </summary>
        /// 
        /// <returns>
        /// true if the <see cref="ICollection{T}"/> is read-only; otherwise, false.
        /// </returns>
        /// 
        public override bool IsReadOnly
        {
            get { return SourceList.IsReadOnly; }
        }

        /// <summary>
        /// Returns an enumerator that iterates through the list.
        /// </summary>
        /// <returns>
        /// A <see cref="IEnumerator{T}"/> that can be used to iterate 
        /// through the list.
        /// </returns>
        /// <filterpriority>1</filterpriority>
        public override IEnumerator<TTo> GetEnumerator()
        {
            return new TransformingEnumerator<TFrom, TTo>(SourceList.GetEnumerator(), Transform);
        }

        #region ICollection Members

        ///<summary>
        ///Gets a value indicating whether access to the <see cref="T:System.Collections.ICollection"></see> is synchronized (thread safe).
        ///</summary>
        ///<remarks>This implementaiton always return <see langword="false"/>.</remarks>
        ///<returns>
        ///true if access to the <see cref="T:System.Collections.ICollection"></see> is synchronized (thread safe); otherwise, false.
        ///</returns>
        ///<filterpriority>2</filterpriority>
        protected override bool IsSynchronized
        {
            get
            {
                IList list = SourceList as IList;
                return list != null && list.IsSynchronized;
            }
        }

        ///<summary>
        ///Gets an object that can be used to synchronize access to the <see cref="T:System.Collections.ICollection"></see>.
        ///</summary>
        ///<remarks>This implementation returns <see langword="null"/>.</remarks>
        ///<returns>
        ///An object that can be used to synchronize access to the <see cref="T:System.Collections.ICollection"></see>.
        ///</returns>
        ///<filterpriority>2</filterpriority>
        protected override object SyncRoot
        {
            get
            {
                IList list = SourceList as IList;
                return list != null ? list.SyncRoot : null;
            }
        }

        #endregion


        /// <summary>
        /// Converts the object of type <typeparamref name="TTo"/> to
        /// object of type <typeparamref name="TFrom"/>.
        /// </summary>
        /// <remarks>
        /// This implementaiton calls <see cref="TryReverse"/> and throws 
        /// <see cref="NotSupportedException"/> if <c>TryReverse</c> returns
        /// <c>false</c>.
        /// Subclass that supports reverse convertion should override this
        /// method of <see cref="TryReverse"/> to provide correct 
        /// implementation.
        /// </remarks>
        /// <param name="target">item passed to this list</param>
        /// <returns>
        /// Converted item that can be passed to the underlaying source list.
        /// </returns>
        /// <exception cref="NotSupportedException">
        /// When <c>TryReverse(target, out source)</c> returns false.
        /// </exception>
        protected virtual TFrom Reverse(TTo target)
        {
            TFrom result;
            if (TryReverse(target, out result)) return result;
            else throw new NotSupportedException();
        }

        /// <summary>
        /// Try converts object of type <typeparamref name="TTo"/> to
        /// <typeparamref name="TFrom"/>.
        /// </summary>
        /// <remarks>
        /// This implementation always return <c>false</c>. Subclasses that
        /// support reversing should override this method.
        /// </remarks>
        /// <param name="target">
        /// Instance of <typeparamref name="TTo"/> to be converted.
        /// </param>
        /// <param name="source">
        /// Converted object of type <typeparamref name="TFrom"/>.
        /// </param>
        /// <returns>
        /// <c>true</c> when reserving is supported, otherwise <c>false</c>.
        /// </returns>
        protected virtual bool TryReverse(TTo target, out TFrom source)
        {
            source = default(TFrom);
            return false;
        }

        /// <summary>
        /// Converts the object of type <typeparamref name="TFrom"/> to
        /// object of type <typeparamref name="TTo"/>.
        /// </summary>
        /// <param name="source">item that is from the underlaying source list</param>
        /// <returns>converted item that can be returned by this list</returns>
        protected abstract TTo Transform(TFrom source);

        /// <summary>
        /// The underlaying source list.
        /// </summary>
        protected readonly IList<TFrom> SourceList;

    }
}