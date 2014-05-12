#region License

/*
 * Copyright 2002-2008 the original author or authors.
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

using System;
using System.Collections;
using System.Collections.Generic;
using System.Runtime.Serialization;
using System.Text;
using Spring.Utility;

namespace Spring.Threading.Collections.Generic {
    /// <summary> 
    /// A thread-safe variant of <see cref="System.Collections.ArrayList"/> in which all mutative
    /// operations are implemented by making a fresh copy of the underlying array.
    /// </summary>
    /// <remarks>
    /// <p/> 
    /// This is ordinarily too costly, but may be <b>more</b> efficient
    /// than alternatives when traversal operations vastly outnumber
    /// mutations, and is useful when you cannot or don't want to
    /// synchronize traversals, yet need to preclude interference among
    /// concurrent threads.  The "snapshot" style iterator method uses a
    /// reference to the state of the array at the point that the iterator
    /// was created. This array never changes during the lifetime of the
    /// iterator, so interference is impossible.
    /// <p/>
    /// The iterator will not reflect additions, removals, or changes to
    /// the list since the iterator was created. 
    /// <p/>
    /// All elements are permitted, including null.
    /// </remarks>
    /// <author>Doug Lea</author>
    /// <author>Griffin Caprio (.NET)</author>
    /// <author>Andreas Doehring (.NET)</author>
    [Serializable]
    public class CopyOnWriteArrayList<T> : IList<T>, ICloneable, ISerializable {

        /// <summary>
        /// internal wrapper for <see cref="Array"/> to implement <see cref="IEnumerable{T}.GetEnumerator"/>
        /// </summary>
        private class InternalEnumerator : IEnumerator<T> {

            private readonly T[] _array;
            private int _position;

            public InternalEnumerator(T[] array) {
                _array = array;
                _position = -1;
            }

            #region IEnumerator<T> Members

            public T Current {
                get {
                    if(_position < 0 || _position >= _array.Length)
                        throw new InvalidOperationException();
                    return _array[_position];
                }
            }

            #endregion

            #region IDisposable Members

            public void Dispose() {
                // nothing to dispose
            }

            #endregion

            #region IEnumerator Members

            object IEnumerator.Current {
                get {
                    if(_position < 0 || _position >= _array.Length)
                        throw new InvalidOperationException();
                    return _array[_position];
                }
            }

            public bool MoveNext() {
                return ++_position >= _array.Length ? false : true;
            }

            public void Reset() {
                _position = -1;
            }

            #endregion
        }

        private T[] Array {
            get { return _array; }
            set { _array = value; }
        }

        /// <summary> 
        /// Returns the number of elements in this list.
        /// </summary>
        /// <returns> 
        /// the number of elements in this list
        /// </returns>
        public int Count {
            get { return Array.Length; }
        }

        /// <summary>
        /// Indexer for the underlying <see cref="System.Array"/>
        /// </summary>
        public T this[Int32 index] {
            get { return Array[index]; }
            set {
                lock(this) {
                    T[] elements = Array;
                    int len = elements.Length;
                    T oldValue = elements[index];

                    if(!oldValue.Equals(value)) {
                        T[] newElements = copyOf(elements, len);
                        newElements[index] = value;
                        Array = newElements;
                    }
                }
            }
        }

        /// <summary>
        /// Gets a value indicating whether the <see cref="CopyOnWriteArrayList{T}"/> is read-only.
        /// </summary>
        public bool IsReadOnly {
            get { return false; }
        }

        /// <summary>
        /// Gets a value indicating whether the <see cref="CopyOnWriteArrayList{T}"/> has a fixed size.
        /// </summary>
        public bool IsFixedSize {
            get { return false; }
        }

        /// <summary>
        /// The array, accessed only via <see cref="CopyOnWriteArrayList{T}.Array"/>. 
        /// </summary>
        [NonSerialized]
        private volatile T[] _array;

        /// <summary>
        /// Default Constructor.  Creates an empty list.
        /// </summary>
        public CopyOnWriteArrayList() {
            Array = new T[0];
        }

        /// <summary> 
        /// Creates a list containing the elements of the specified
        /// <pararef name="collection"/>, in the order they are returned by the collection's
        /// iterator.
        /// </summary>
        /// <param name="collection">the collection of initially held elements
        /// </param>
        /// <exception cref="ArgumentNullException">If <paramref name="collection"/> is <see lang="null"/></exception>
        public CopyOnWriteArrayList(ICollection<T> collection) {
            if(null == collection) {
                throw new ArgumentNullException("collection", "Collection cannot be null");
            }
            T[] elements = new T[collection.Count];
            int size = 0;
            foreach(T current in collection) {
                elements[size++] = current;
            }
            Array = elements;
        }

        /// <summary> 
        /// Creates a list holding a copy of the <pararef name="inputArray"/>.
        /// </summary>
        /// <param name="inputArray">
        /// the array (a copy of this array is used as the
        /// internal array)
        /// </param>
        /// <exception cref="ArgumentNullException">if <paramref name="inputArray"/> is null.</exception>
        public CopyOnWriteArrayList(T[] inputArray) {
            if(null == inputArray) {
                throw new ArgumentNullException("inputArray", "Input array cannot be null");
            }
            copyToInternalArray(inputArray, 0, inputArray.Length);
        }

        /// <summary> 
        /// Replaces the internal array with a copy the <pararef name="numberOfElementsToCopy"/> elements
        /// of the <pararef name="inputArray"/>. 
        /// </summary>
        /// <param name="inputArray">The array to copy from.</param>
        /// <param name="startIndex">The index to start copying from.</param>
        /// <param name="numberOfElementsToCopy">the number of elements to copy. This will be the new size of the list.</param>
        private void copyToInternalArray(T[] inputArray, int startIndex, int numberOfElementsToCopy) {
            int limit = startIndex + numberOfElementsToCopy;
            if(limit > inputArray.Length) {
                throw new IndexOutOfRangeException();
            }
            T[] newElements = copyOfRange(inputArray, startIndex, limit, typeof(T[]));
            lock(this) {
                Array = newElements;
            }
        }

        /// <summary> 
        /// Returns <see lang="true"/> if this list contains no elements.
        /// </summary>
        /// <returns> <see lang="true"/> if this list contains no elements
        /// </returns>
        public bool IsEmpty {
            get { return Count == 0; }
        }

        /// <summary>
        /// Test for equality, coping with nulls.
        /// </summary>
        private static bool eq(object o1, Object o2) {
            return (o1 == null ? o2 == null : o1.Equals(o2));
        }

        /// <summary>
        /// static version of indexOf, to allow repeated calls without
        /// needing to re-acquire array each time.
        /// </summary>
        /// <param name="element">element to search for</param>
        /// <param name="arrayToSearch">the array</param>
        /// <param name="startingIndex">first startingIndex to search</param>
        /// <param name="fence">one past last startingIndex to search</param>
        /// <returns> startingIndex of element, or -1 if absent</returns>
        private static int indexOf(T element, T[] arrayToSearch, int startingIndex, int fence) {
            if(element.Equals(default(T))) {
                for(int i = startingIndex; i < fence; i++) {
                    if(arrayToSearch[i].Equals(default(T))) {
                        return i;
                    }
                }
            }
            else {
                for(int i = startingIndex; i < fence; i++) {
                    if(element.Equals(arrayToSearch[i])) {
                        return i;
                    }
                }
            }
            return -1;
        }

        /// <summary> static version of lastIndexOf.</summary>
        /// <param name="element">element to search for
        /// </param>
        /// <param name="elements">the array
        /// </param>
        /// <param name="startingIndex">index to start searching at
        /// </param>
        /// <returns> index of element, or -1 if absent
        /// </returns>
        private static int lastIndexOf(T element, T[] elements, int startingIndex) {
            if(startingIndex < 0 || startingIndex > elements.Length - 1) {
                throw new IndexOutOfRangeException(startingIndex + " is negative or greater than the array.");
            }
            if(element.Equals(default(T))) {
                for(int i = startingIndex; i >= 0; i--) {
                    if(elements[i].Equals(default(T))) {
                        return i;
                    }
                }
            }
            else {
                for(int i = startingIndex; i >= 0; i--) {
                    if(element.Equals(elements[i])) {
                        return i;
                    }
                }
            }
            return -1;
        }

        /// <summary> 
        /// Returns <see lang="true"/> if this list contains the specified element.
        /// </summary>
        /// <param name="element">element to look for.
        /// </param>
        /// <returns> <see lang="true"/> if this list contains the specified element
        /// </returns>
        public bool Contains(T element) {
            T[] elements = Array;
            return indexOf(element, elements, 0, elements.Length) >= 0;
        }

        /// <summary>
        /// Returns the index of the <paramref name="element"/> in the array.
        /// </summary>
        /// <param name="element">element to look for.</param>
        /// <returns></returns>
        public int IndexOf(T element) {
            T[] elements = Array;
            return indexOf(element, elements, 0, elements.Length);
        }

        /// <summary> 
        /// Returns the index of the first occurrence of the specified element in
        /// this list, searching forwards from index, or returns -1 if
        /// the element is not found.
        /// </summary>
        /// <param name="e">element to search for.</param>
        /// <param name="index">index to start searching from.</param>
        /// <returns> the index of the first occurrence of the element in
        /// this list at position index or later in the list;
        /// -1 if the element is not found.
        /// </returns>
        /// <exception cref="IndexOutOfRangeException">if the specified index is negative or greater than the length of the array.</exception>
        public int IndexOf(T e, int index) {
            T[] elements = Array;
            return indexOf(e, elements, index, elements.Length);
        }

        /// <summary>
        /// Returns the index of the last occurrence of the specified element in this list.
        /// </summary>
        /// <param name="element">specified element</param>
        /// <returns>index of <pararef name="element"/></returns>
        public int LastIndexOf(T element) {
            T[] elements = Array;
            return lastIndexOf(element, elements, elements.Length - 1);
        }

        /// <summary> 
        /// Returns the index of the last occurrence of the specified element in
        /// this list, searching backwards from index, or returns -1 if
        /// the element is not found.
        /// </summary>
        /// <param name="element">element to search for</param>
        /// <param name="startingIndex">index to start searching backwards from</param>
        /// <returns> the index of the last occurrence of the element at position
        /// less than or equal to index in this list;
        /// -1 if the element is not found.
        /// </returns>
        /// <exception cref="IndexOutOfRangeException">if the specified index is greater than or equal to the current size of the list.</exception>
        public int LastIndexOf(T element, int startingIndex) {
            T[] elements = Array;
            return lastIndexOf(element, elements, startingIndex);
        }

        /// <summary> 
        /// Returns a shallow copy of this list.  (The elements themselves
        /// are not copied.)
        /// </summary>
        /// <returns> a clone of this list
        /// </returns>
        public object Clone() {
            return MemberwiseClone();
        }

        /// <summary> 
        /// Returns an array containing all of the elements in this list
        /// in proper sequence (from first to last element).
        /// </summary>
        /// <remarks>
        /// The returned array will be "safe" in that no references to it are
        /// maintained by this list.  (In other words, this method must allocate
        /// a new array).  The caller is thus free to modify the returned array.
        /// </remarks>
        /// <returns> an array containing all the elements in this list
        /// </returns>
        public T[] ToArray() {
            T[] elements = Array;
            return copyOf(elements, elements.Length);
        }

        /// <summary> 
        /// Returns an array containing all of the elements in this list in
        /// proper sequence (from first to last element); the runtime type of
        /// the returned array is that of the specified array.  If the list fits
        /// in the specified array, it is returned therein.  Otherwise, a new
        /// array is allocated with the runtime type of the specified array and
        /// the size of this list.
        /// </summary>
        /// <remarks> 
        /// If this list fits in the specified array with room to spare
        /// (i.e., the array has more elements than this list), the element in
        /// the array immediately following the end of the list is set to
        /// null.  (This is useful in determining the length of this
        /// list <i>only</i> if the caller knows that this list does not contain
        /// any null elements.)
        /// 
        /// <p/>Like the <see cref="ToArray()"/> method, this method acts as bridge between
        /// array-based and collection-based APIs.  Further, this method allows
        /// precise control over the runtime type of the output array, and may,
        /// under certain circumstances, be used to save allocation costs.
        /// </remarks>
        /// <param name="destinationArray">the array into which the elements of the list are to
        /// be stored, if it is big enough; otherwise, a new array of the
        /// same runtime type is allocated for this purpose.
        /// </param>
        /// <returns> an array containing all the elements in this list</returns>
        public T[] ToArray(T[] destinationArray) {
            T[] elements = Array;
            int len = elements.Length;
            if(destinationArray.Length < len) {
                return copyOf(elements, len, destinationArray.GetType());
            }
            else {
                System.Array.Copy(elements, 0, destinationArray, 0, len);
                if(destinationArray.Length > len) {
                    destinationArray[len] = default(T);
                }
                return destinationArray;
            }
        }

        /// <summary> 
        ///	Appends the specified element to the end of this list.
        /// </summary>
        /// <param name="item">element to be appended to this list</param>
        /// <returns>Index of the inserted element in the array.</returns>
        public int Add(T item) {
            lock(this) {
                T[] elements = Array;
                int len = elements.Length;
                T[] newElements = copyOf(elements, len + 1);
                newElements[len] = item;
                Array = newElements;
            }

            return Array.Length - 1;
        }

        void ICollection<T>.Add(T item) {
            lock(this) {
                T[] elements = Array;
                int len = elements.Length;
                T[] newElements = copyOf(elements, len + 1);
                newElements[len] = item;
                Array = newElements;
            }
        }

        /// <summary> 
        /// Inserts the specified element at the specified position in this
        /// list. Shifts the element currently at that position (if any) and
        /// any subsequent elements to the right (adds one to their indices).
        /// </summary>
        /// <param name="element">element to insert</param>
        /// <param name="index">position to insert <pararef name="element"/> into.</param>
        /// <exception cref="IndexOutOfRangeException">if the <paramref name="index"/> is negative or bigger than the current size of the array.</exception>
        public void Insert(int index, T element) {
            T[] elements = Array;
            int len = elements.Length;
            if(index > len || index < 0) {
                throw new IndexOutOfRangeException("Index: " + index + ", Size: " + len);
            }
            T[] newElements;
            int numMoved = len - index;
            if(numMoved == 0) {
                newElements = copyOf(elements, len + 1);
            }
            else {
                newElements = new T[len + 1];
                System.Array.Copy(elements, 0, newElements, 0, index);
                System.Array.Copy(elements, index, newElements, index + 1, numMoved);
            }
            newElements[index] = element;
            Array = newElements;
        }

        /// <summary> 
        /// Removes the element at the specified position in this list.
        /// Shifts any subsequent elements to the left (subtracts one from their
        /// indices).  Returns the element that was removed from the list.
        /// </summary>
        /// <param name="index">Index to remove the element at.</param>
        /// <exception cref="IndexOutOfRangeException">if <paramref name="index"/> is negative or outside the bounds of the list.</exception>
        public void RemoveAt(int index) {
            if(index < 0 || index > _array.Length - 1) {
                throw new IndexOutOfRangeException("Index outside of the bouds of the list.");
            }
            lock(this) {
                T[] elements = Array;
                int len = elements.Length;
                int numMoved = len - index - 1;
                if(numMoved == 0) {
                    Array = copyOf(elements, len - 1);
                }
                else {
                    T[] newElements = new T[len - 1];
                    System.Array.Copy(elements, 0, newElements, 0, index);
                    System.Array.Copy(elements, index + 1, newElements, index, numMoved);
                    Array = newElements;
                }
            }
        }

        /// <summary> 
        /// Removes the first occurrence of the specified element from this list,
        /// if it is present.  If this list does not contain the element, it is
        /// unchanged.
        /// </summary>
        /// <param name="element">element to be removed from this list, if present
        /// </param>
        public bool Remove(T element) {
            lock(this) {
                bool elementsRemoved = false;
                T[] elements = Array;
                int len = elements.Length;
                if(len != 0) {
                    int newlen = len - 1;
                    T[] newElements = new T[newlen];

                    for(int i = 0; i < newlen; ++i) {
                        if(eq(element, elements[i])) {
                            for(int k = i + 1; k < len; ++k) {
                                newElements[k - 1] = elements[k];
                            }
                            Array = newElements;
                            elementsRemoved = true;
                        }
                        else {
                            newElements[i] = elements[i];
                        }
                    }

                    // special handling for last cell
                    if(eq(element, elements[newlen])) {
                        Array = newElements;
                        elementsRemoved = true;
                    }
                }
                return elementsRemoved;
            }
        }
        /// <summary>
        /// Append the element if not present.
        /// </summary>
        /// <param name="element">element to be added to this list, if absent
        /// </param>
        /// <returns> true if the element was added
        /// </returns>
        public bool AddIfAbsent(T element) {
            lock(this) {
                // Copy while checking if already present.
                // This wins in the most common case where it is not present
                T[] elements = Array;
                int len = elements.Length;
                T[] newElements = new T[len + 1];
                for(int i = 0; i < len; ++i) {
                    if(eq(element, elements[i])) {
                        return false;
                    }
                    // exit, throwing away copy
                    else {
                        newElements[i] = elements[i];
                    }
                }
                newElements[len] = element;
                Array = newElements;
                return true;
            }
        }

        /// <summary> 
        /// Returns true if this list contains all of the elements of the
        /// specified collection.
        /// </summary>
        /// <param name="collection">collection to be checked for containment in this list
        /// </param>
        /// <returns> true if this list contains all of the elements of the
        /// specified collection
        /// </returns>
        /// <exception cref="ArgumentNullException">If <pararef name="collection"/> is null.</exception>
        public bool ContainsAll(ICollection<T> collection) {
            if(null == collection) throw new ArgumentNullException("collection", "collection cannot be null");
            T[] elements = Array;
            int len = elements.Length;
            foreach(T currentObject in collection) {
                if(indexOf(currentObject, elements, 0, len) < 0) {
                    return false;
                }
            }
            return true;
        }

        /// <summary> 
        /// Removes from this list all of its elements that are contained in
        /// the specified collection. This is a particularly expensive operation
        /// in this class because of the need for an internal temporary array.
        /// </summary>
        /// <param name="collection">collection containing elements to be removed from this list
        /// </param>
        /// <returns> true if this list changed as a result of the call
        /// </returns>
        public bool RemoveAll(ICollection<T> collection) {
            lock(this) {
                T[] elements = Array;
                int len = elements.Length;
                if(len != 0) {
                    // temp array holds those elements we know we want to keep
                    int newlen = 0;
                    T[] temp = new T[len];
                    for(int i = 0; i < len; ++i) {
                        T element = elements[i];
                        if(!collection.Contains(element)) {
                            temp[newlen++] = element;
                        }
                    }
                    if(newlen != len) {
                        Array = copyOfRange(temp, 0, newlen, typeof(T[]));
                        return true;
                    }
                }
                return false;
            }
        }

        /// <summary> Retains only the elements in this list that are contained in the
        /// specified collection.  In other words, removes from this list all of
        /// its elements that are not contained in the specified collection.
        /// 
        /// </summary>
        /// <param name="collection">collection containing elements to be retained in this list
        /// </param>
        /// <returns> true if this list changed as a result of the call
        /// </returns>
        public bool RetainAll(ICollection<T> collection) {
            lock(this) {
                T[] elements = Array;
                int len = elements.Length;
                if(len != 0) {
                    // temp array holds those elements we know we want to keep
                    int newlen = 0;
                    T[] temp = new T[len];
                    for(int i = 0; i < len; ++i) {
                        T element = elements[i];
                        if(collection.Contains(element)) {
                            temp[newlen++] = element;
                        }
                    }
                    if(newlen != len) {
                        Array = copyOfRange(temp, 0, newlen, typeof(object[]));
                        return true;
                    }
                }
                return false;
            }
        }

        /// <summary> Appends all of the elements in the specified collection that
        /// are not already contained in this list, to the end of
        /// this list, in the order that they are returned by the
        /// specified collection's iterator.
        /// 
        /// </summary>
        /// <param name="collection">collection containing elements to be added to this list
        /// </param>
        /// <returns> the number of elements added
        /// </returns>
        public int AddAllAbsent(ICollection<T> collection) {
            if(null == collection) throw new ArgumentNullException("collection", "collection cannot be null");
            int numNew = collection.Count;
            if(numNew == 0) {
                return 0;
            }
            lock(this) {
                T[] elements = Array;
                int len = elements.Length;

                T[] temp = new T[numNew];
                int added = 0;
                //UPGRADE_TODO: Method 'java.util.Iterator.hasNext' was converted to 'System.Collections.IEnumerator.MoveNext' which has a different behavior. "ms-help://MS.VSCC.v80/dv_commoner/local/redirect.htm?index='!DefaultContextWindowIndex'&keyword='jlca1073_javautilIteratorhasNext'"
                for(IEnumerator<T> itr = collection.GetEnumerator(); itr.MoveNext(); ) {
                    //UPGRADE_TODO: Method 'java.util.Iterator.next' was converted to 'System.Collections.IEnumerator.Current' which has a different behavior. "ms-help://MS.VSCC.v80/dv_commoner/local/redirect.htm?index='!DefaultContextWindowIndex'&keyword='jlca1073_javautilIteratornext'"
                    T e = itr.Current;
                    if(indexOf(e, elements, 0, len) < 0 && indexOf(e, temp, 0, added) < 0) {
                        temp[added++] = e;
                    }
                }
                if(added != 0) {
                    T[] newElements = new T[len + added];
                    System.Array.Copy(elements, 0, newElements, 0, len);
                    System.Array.Copy(temp, 0, newElements, len, added);
                    Array = newElements;
                }
                return added;
            }
        }

        /// <summary> Removes all of the elements from this list.
        /// The list will be empty after this call returns.
        /// </summary>
        public void Clear() {
            Array = new T[0];
        }

        /// <summary> 
        /// Appends all of the elements in the specified collection to the end
        /// of this list, in the order that they are returned by the specified
        /// collection's iterator.
        /// </summary>
        /// <param name="collection">collection containing elements to be added to this list
        /// </param>
        /// <returns> true if this list changed as a result of the call
        /// </returns>
        public bool AddAll(ICollection<T> collection) {
            int numNew = collection.Count;
            if(numNew == 0) {
                return false;
            }
            lock(this) {
                T[] elements = Array;
                int len = elements.Length;
                T[] newElements = new T[len + numNew];
                System.Array.Copy(elements, 0, newElements, 0, len);
                foreach(T currentObject in collection) {
                    newElements[len++] = currentObject;
                }
                Array = newElements;
                return true;
            }
        }

        /// <summary> 
        /// Inserts all of the elements in the specified collection into this
        /// list, starting at the specified position.  Shifts the element
        /// currently at that position (if any) and any subsequent elements to
        /// the right (increases their indices).  The new elements will appear
        /// in this list in the order that they are returned by the
        /// specified collection's iterator.
        /// 
        /// </summary>
        /// <param name="index">index at which to insert the first element
        /// from the specified collection
        /// </param>
        /// <param name="collection">collection containing elements to be added to this list
        /// </param>
        /// <returns> true if this list changed as a result of the call
        /// </returns>
        public bool AddAll(int index, ICollection<T> collection) {
            if(null == collection) throw new ArgumentNullException("collection", "collection cannot be null");
            int numNew = collection.Count;
            lock(this) {
                T[] elements = Array;
                int len = elements.Length;
                if(index > len || index < 0) {
                    throw new IndexOutOfRangeException("Index: " + index + ", Size: " + len);
                }
                if(numNew == 0) {
                    return false;
                }
                int numMoved = len - index;
                T[] newElements;
                if(numMoved == 0) {
                    newElements = copyOf(elements, len + numNew);
                }
                else {
                    newElements = new T[len + numNew];
                    System.Array.Copy(elements, 0, newElements, 0, index);
                    System.Array.Copy(elements, index, newElements, index + numNew, numMoved);
                }
                foreach(T currentObject in collection) {
                    newElements[index++] = currentObject;
                }
                Array = newElements;
                return true;
            }
        }

        /// <summary> 
        /// Save the state of the list to a stream (i.e., serialize it).
        /// </summary>
        /// <serialData> The length of the array backing the list is emitted
        /// (int), followed by all of its elements (each an object)
        /// in the proper order.
        /// </serialData>
        /// <param name="s">the stream</param>
        /// <param name="context">the context</param>
        public void GetObjectData(SerializationInfo s, StreamingContext context) {
            // Write out element count, and any hidden stuff
            SerializationUtilities.DefaultWriteObject(s, context, this);

            T[] elements = Array;
            int len = elements.Length;
            // Write out array length
            s.AddValue("Spring.Threading.Collections.CopyOnWriteArrayListdataLength", len);

            // Write out all elements in the proper order.
            for(int i = 0; i < len; i++) {
                s.AddValue("Spring.Threading.Collections.CopyOnWriteArrayListdata" + i, elements[i]);
            }
        }

        /// <summary> Reconstitute the list from a stream (i.e., deserialize it).</summary>
        /// <param name="s">the stream</param>
        /// <param name="context">the context</param>
        protected CopyOnWriteArrayList(SerializationInfo s, StreamingContext context) {
            // Read in size, and any hidden stuff
            SerializationUtilities.DefaultReadObject(s, context, this);

            // Read in array length and allocate array
            int len = s.GetInt32("Spring.Threading.Collections.CopyOnWriteArrayListdataLength");
            T[] elements = new T[len];

            // Read in all elements in the proper order.
            for(int i = 0; i < len; i++) {
                elements[i] = (T)s.GetValue("Spring.Threading.Collections.CopyOnWriteArrayListdata" + i, typeof(T));
            }
            Array = elements;
        }

        /// <summary> Returns a string representation of this list, containing
        /// the String representation of each element.
        /// </summary>
        public override string ToString() {
            T[] elements = Array;
            int maxIndex = elements.Length - 1;
            StringBuilder buf = new StringBuilder();
            buf.Append("[");
            for(int i = 0; i <= maxIndex; i++) {
                buf.Append(Convert.ToString(elements[i]));
                if(i < maxIndex) {
                    buf.Append(", ");
                }
            }
            buf.Append("]");
            return buf.ToString();
        }

        /// <summary> 
        /// Compares the specified object with this list for equality.
        /// Returns true if and only if the specified object is also a {@link
        /// List}, both lists have the same size, and all corresponding pairs
        /// of elements in the two lists are <em>equal</em>.  (Two elements
        /// e1 and e2 are <em>equal</em> if (e1==null ?
        /// e2==null : e1.equals(e2)).)  In other words, two lists are
        /// defined to be equal if they contain the same elements in the same
        /// order.
        /// 
        /// </summary>
        /// <param name="o">the object to be compared for equality with this list
        /// </param>
        /// <returns> true if the specified object is equal to this list
        /// </returns>
        public override bool Equals(object o) {
            if(o == this) {
                return true;
            }
            if(!(o is IList<T>)) {
                return false;
            }

            IList<T> l2 = (IList<T>)(o);
            if(Count != l2.Count) {
                return false;
            }

            IEnumerator e1 = GetEnumerator();
            IEnumerator e2 = l2.GetEnumerator();
            while(e1.MoveNext()) {
                e2.MoveNext();
                if(!eq(e1.Current, e2.Current)) {
                    return false;
                }
            }
            return true;
        }

        /// <summary> 
        /// Returns the hash code value for this list.
        /// </summary>
        /// <returns> the hash code value for this list
        /// </returns>
        public override int GetHashCode() {
            int hashCode = 1;
            T[] elements = Array;
            int len = elements.Length;
            for(int i = 0; i < len; ++i) {
                T obj = elements[i];
                hashCode = 31 * hashCode + (obj.Equals(default(T)) ? 0 : obj.GetHashCode());
            }
            return hashCode;
        }

        /// <summary> 
        /// Returns an iterator over the elements in this list in proper sequence.
        /// </summary>
        /// <returns> an iterator over the elements in this list in proper sequence
        /// </returns>
        public IEnumerator GetEnumerator() {
            return _array.GetEnumerator();
        }

        private static T[] copyOfRange(T[] original, int from, int to, Type newType) {
            int newLength = to - from;
            if(newLength < 0) {
                throw new ArgumentException(from + " > " + to);
            }
            T[] copy = (T[])System.Array.CreateInstance(newType.GetElementType(), newLength);
            System.Array.Copy(original, from, copy, 0, Math.Min(original.Length - from, newLength));
            return copy;
        }

        private static T[] copyOf(T[] original, int newLength, Type newType) {
            T[] copy = (T[])System.Array.CreateInstance(newType.GetElementType(), newLength);
            System.Array.Copy(original, 0, copy, 0, Math.Min(original.Length, newLength));
            return copy;
        }

        private static T[] copyOf(T[] original, int newLength) {
            return copyOf(original, newLength, original.GetType());
        }

        /// <summary>
        /// Copies the elements of the 
        /// <see cref="System.Collections.ICollection"/> to an <see cref="System.Array"/> , 
        /// starting at a particular <paramref name="index"/>.
        /// </summary>
        public void CopyTo(Array array, Int32 index) {
            for(int i = index; i < Count; i++) {
                array.SetValue(this[i], i);
            }
        }

        /// <summary>
        /// Gets and object that can be used to synchronize access to the <see cref="CopyOnWriteArrayList{T}"/> .
        /// </summary>
        public object SyncRoot {
            get { return null; }
        }

        /// <summary>
        /// Gets a value indicating whether access to the 
        /// <see cref="CopyOnWriteArrayList{T}"/> is synchronized (thread-safe).
        /// </summary>
        public Boolean IsSynchronized {
            get { return false; }
        }

        #region IEnumerable<T> Members

        IEnumerator<T> IEnumerable<T>.GetEnumerator() {
            return new InternalEnumerator(_array);
        }

        #endregion

        #region ICollection<T> Members

        /// <summary>
        /// 
        /// </summary>
        /// <param name="array"></param>
        /// <param name="arrayIndex"></param>
        public void CopyTo(T[] array, int arrayIndex) {
            for(int i = arrayIndex; i < Count; i++) {
                array.SetValue(this[i], i);
            }
        }

        #endregion
    }
}