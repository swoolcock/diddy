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
using System.Collections;
#endregion

namespace Spring.Collections.Generic
{
    /// <summary>
    /// Serve as based class to be inherited by the classes that needs to
    /// implement both the <see cref="IList{T}"/> and the <see cref="IList"/>
    /// interfaces.
    /// </summary>
    /// <typeparam name="T">Element type of the collection</typeparam>
    /// <author>Kenneth Xu</author>
    [Serializable]
    public abstract class AbstractList<T> : AbstractCollection<T>, IList<T>, IList
    {

        #region IList<T> Members

        /// <summary>
        /// Determines the index of a specific item in the <see cref="IList{T}"/>.
        /// This implementation search the list by interating through the 
        /// enumerator returned by the <see cref="AbstractCollection{T}.GetEnumerator()"/> 
        /// method.
        /// </summary>
        /// 
        /// <returns>
        /// The index of item if found in the list; otherwise, -1.
        /// </returns>
        /// 
        /// <param name="item">The object to locate in the <see cref="IList{T}"/>.
        /// </param>
        public virtual int IndexOf(T item)
        {
            int index = 0;
            foreach (T t in this)
            {
                if (t.Equals(item)) return index;
                index++;
            }
            return -1;
        }

        /// <summary>
        /// Inserts an item to the <see cref="IList{T}"/> at the specified index.
        /// This implementation always throw <see cref="NotSupportedException"/>.
        /// </summary>
        /// 
        /// <param name="item">
        /// The object to insert into the <see cref="IList{T}"/>.</param>
        /// <param name="index">
        /// The zero-based index at which item should be inserted.</param>
        /// <exception cref="NotSupportedException">
        /// The <see cref="IList{T}"/> is read-only.</exception>
        /// <exception cref="ArgumentOutOfRangeException">
        /// index is not a valid index in the <see cref="IList{T}"/>.
        /// </exception>
        public virtual void Insert(int index, T item)
        {
            throw new NotSupportedException();
        }

        /// <summary>
        /// Removes the <see cref="IList{T}"/> item at the specified index.
        /// This implementation always throw <see cref="NotSupportedException"/>.
        /// </summary>
        /// 
        /// <param name="index">
        /// The zero-based index of the item to remove.</param>
        /// <exception cref="NotSupportedException">
        /// The <see cref="IList{T}"/> is read-only.</exception>
        /// <exception cref="ArgumentOutOfRangeException">
        /// index is not a valid index in the <see cref="IList{T}"/>.
        /// </exception>
        public virtual void RemoveAt(int index)
        {
            throw new NotSupportedException();
        }

        /// <summary>
        /// Gets or sets the element at the specified index.
        /// </summary>
        /// <remarks>
        /// <para>
        /// The implementation of getter search the list by interating through the 
        /// enumerator returned by the <see cref="AbstractCollection{T}.GetEnumerator"/> method.
        /// </para>
        /// <para>
        /// The setter throws the <see cref="NotSupportedException"/>.
        /// </para>
        /// </remarks>
        /// <returns>
        /// The element at the specified index.
        /// </returns>
        /// 
        /// <param name="index">
        /// The zero-based index of the element to get or set.</param>
        /// <exception cref="ArgumentOutOfRangeException">
        /// index is not a valid index in the <see cref="IList{T}"/>.</exception>
        /// <exception cref="NotSupportedException">The property is set and the 
        /// <see cref="IList{T}"/> is read-only.</exception>
        public virtual T this[int index]
        {
            get
            {
                if (index<0) throw new ArgumentOutOfRangeException(
                    "index", index, "cannot be less then zero.");
                IEnumerator<T> e = GetEnumerator();
                for(int i=0; i<=index; i++)
                {
                    if (!e.MoveNext()) throw new ArgumentOutOfRangeException(
                        "index", index, "list has only " + i + " elements");
                }
                return e.Current;
            }
            set{ throw new NotSupportedException(); }
        }

        #endregion

        #region IList Members

        /// <summary>
        /// Adds an item to the <see cref="T:System.Collections.IList"></see>.
        /// </summary>
        ///
        /// <returns>
        /// The position into which the new element was inserted.
        /// </returns>
        ///
        /// <param name="value">The <see cref="T:System.Object"></see> to add 
        /// to the <see cref="T:System.Collections.IList"></see>. </param>
        /// <exception cref="T:System.NotSupportedException">
        /// The <see cref="T:System.Collections.IList"></see> is read-only.
        /// -or- 
        /// The <see cref="T:System.Collections.IList"></see> has a fixed size. 
        /// </exception>
        /// <filterpriority>2</filterpriority>
        int IList.Add(object value)
        {
            return NonGenericAdd(value);
        }

        ///<summary>
        ///Determines whether the <see cref="T:System.Collections.IList"></see> 
        /// contains a specific value.
        ///</summary>
        ///
        ///<returns>
        ///true if the <see cref="T:System.Object"></see> is found in the 
        /// <see cref="T:System.Collections.IList"></see>; otherwise, false.
        ///</returns>
        ///
        ///<param name="value">
        /// The <see cref="T:System.Object"></see> to locate in the 
        /// <see cref="T:System.Collections.IList"></see>. 
        /// </param>
        /// <filterpriority>2</filterpriority>
        bool IList.Contains(object value)
        {
            return NonGenericContains(value);
        }

        ///<summary>
        ///Determines the index of a specific item in the 
        /// <see cref="T:System.Collections.IList"></see>.
        ///</summary>
        ///
        ///<returns>
        ///The index of value if found in the list; otherwise, -1.
        ///</returns>
        ///
        ///<param name="value">
        /// The <see cref="T:System.Object"></see> to locate in the 
        /// <see cref="T:System.Collections.IList"></see>. 
        /// </param>
        /// <filterpriority>2</filterpriority>
        int IList.IndexOf(object value)
        {
            return NonGenericIndexOf(value);
        }

        ///<summary>
        ///Inserts an item to the <see cref="T:System.Collections.IList"></see> 
        /// at the specified index.
        ///</summary>
        ///
        ///<param name="value">
        /// The <see cref="T:System.Object"></see> to insert into the 
        /// <see cref="T:System.Collections.IList"></see>. 
        /// </param>
        ///<param name="index">
        /// The zero-based index at which value should be inserted. 
        /// </param>
        ///<exception cref="T:System.ArgumentOutOfRangeException">
        /// index is not a valid index in the <see cref="T:System.Collections.IList"></see>. 
        /// </exception>
        ///<exception cref="T:System.NotSupportedException">
        /// The <see cref="T:System.Collections.IList"></see> is read-only.
        /// -or- 
        /// The <see cref="T:System.Collections.IList"></see> has a fixed size. 
        /// </exception>
        ///<exception cref="T:System.NullReferenceException">
        /// value is null reference in the <see cref="T:System.Collections.IList"></see>.
        /// </exception>
        /// <filterpriority>2</filterpriority>
        void IList.Insert(int index, object value)
        {
            NonGenericInsert(index, value);
        }

        ///<summary>
        ///Gets a value indicating whether the 
        /// <see cref="T:System.Collections.IList"></see> 
        /// has a fixed size.
        ///</summary>
        ///<remarks>Calls <see cref="IsFixedSize"/>.</remarks>
        ///<returns>
        ///true if the <see cref="T:System.Collections.IList"></see> 
        /// has a fixed size; otherwise, false.
        ///</returns>
        ///<filterpriority>2</filterpriority>
        bool IList.IsFixedSize
        {
            get
            {
                return IsFixedSize;
            }
        }

        ///<summary>
        ///Removes the first occurrence of a specific object from 
        /// the <see cref="T:System.Collections.IList"></see>.
        ///</summary>
        ///
        ///<param name="value">
        /// The <see cref="T:System.Object"></see> to remove from the 
        /// <see cref="T:System.Collections.IList"></see>. 
        /// </param>
        ///<exception cref="T:System.NotSupportedException">
        /// The <see cref="T:System.Collections.IList"></see> is read-only.
        /// -or- 
        /// The <see cref="T:System.Collections.IList"></see> has a fixed size. 
        /// </exception>
        /// <filterpriority>2</filterpriority>
        void IList.Remove(object value)
        {
            NonGenericRemove(value);
        }

        ///<summary>
        ///Gets or sets the element at the specified index.
        ///</summary>
        ///
        ///<returns>
        ///The element at the specified index.
        ///</returns>
        ///
        ///<param name="index">
        /// The zero-based index of the element to get or set. 
        /// </param>
        ///<exception cref="T:System.ArgumentOutOfRangeException">
        /// index is not a valid index in the <see cref="IList"></see>. 
        /// </exception>
        ///<exception cref="T:System.NotSupportedException">
        /// The property is set and the <see cref="T:System.Collections.IList"></see> 
        /// is read-only. 
        /// </exception>
        /// <filterpriority>2</filterpriority>
        object IList.this[int index]
        {
            get { return NonGenericIndexerGet(index); }
            set { NonGenericIndexerSet(index, value); }
        }

        #endregion

        #region Protected Methods

        /// <summary>
        /// Called by implicit implementation of <see cref="IList.IsFixedSize"/>.
        /// This implementation always return <c>false</c>.
        /// </summary>
        protected virtual bool IsFixedSize
        {
            get
            {
                return false;
            }
        }

        #endregion

        #region Non Generic Implementations - reserved to protect for sub class can override if necessary
		
        private int NonGenericAdd(object value)
        {
            int index = Count;
            Insert(index, (T)value);
            return index;
        }

        private bool NonGenericContains(object value)
        {
            return value is T && Contains((T)value);
        }

        private int NonGenericIndexOf(object value)
        {
            return value is T ? IndexOf((T)value) : -1;
        }

        private void NonGenericInsert(int index, object value)
        {
            Insert(index, (T)value);
        }

        private void NonGenericRemove(object value)
        {
            if (value is T) Remove((T)value);
        }

        private object NonGenericIndexerGet(int index)
        {
            return this[index];
        }

        private void NonGenericIndexerSet(int index, object value)
        {
            this[index] = (T)value;
        }

        #endregion    
    }
}