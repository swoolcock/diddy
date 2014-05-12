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
using System.Text;

namespace Spring.Threading.AtomicTypes {
    /// <summary> 
    /// An array of object references in which elements may be updated
    /// atomically. 
    /// <p/>
    /// Based on the on the back port of JCP JSR-166.
    /// </summary>
    /// <author>Doug Lea</author>
    /// <author>Griffin Caprio (.NET)</author>
    /// <author>Andreas Doehring (.NET)</author>
    [Serializable]
    public class AtomicReferenceArray<T> {
        /// <summary>
        /// Holds the object array reference
        /// </summary>
        private readonly T[] _referenceArray;

        /// <summary> 
        /// Creates a new <see cref="Spring.Threading.AtomicTypes.AtomicReferenceArray{T}"/> of <paramref name="length"/>.</summary>
        /// <param name="length">
        /// the length of the array
        /// </param>
        public AtomicReferenceArray(int length) {
            _referenceArray = new T[length];
        }

        /// <summary> 
        /// Creates a new <see cref="Spring.Threading.AtomicTypes.AtomicReferenceArray{T}"/> with the same length as, and
        /// all elements copied from <paramref name="array"/>
        /// </summary>
        /// <param name="array">
        /// The array to copy elements from
        /// </param>
        /// <throws><see cref="ArgumentNullException"/>if array is null</throws>
        public AtomicReferenceArray(T[] array)
            : this(array!= null?array.Length:0) {
            if(array == null)
                throw new ArgumentNullException();
            Array.Copy(array, 0, _referenceArray, 0, array.Length);
        }

        /// <summary> 
        /// Returns the length of the array.
        /// </summary>
        /// <returns> 
        /// The length of the array
        /// </returns>
        public int Length() {
            return _referenceArray.Length;
        }

        /// <summary> 
        /// Indexer for getting and setting the current value at position <paramref name="index"/>.
        /// <p/>
        /// </summary>
        /// <param name="index">
        /// The index to use.
        /// </param>
        public T this[int index] {
            get {
                lock(this) {
                    return _referenceArray[index];
                }
            }
            set {
                lock(this) {
                    _referenceArray[index] = value;
                }
            }
        }

        /// <summary> 
        /// Eventually sets to the given value at the given <paramref name="index"/>
        /// </summary>
        /// <param name="newValue">
        /// the new value
        /// </param>
        /// <param name="index">
        /// the index to set
        /// </param>
        /// TODO: This method doesn't differ from the set() method, which was converted to a property.  For now
        /// the property will be called for this method.
        [Obsolete("This method will be removed.  Please use indexer instead.")]
        public virtual void LazySet(int index, T newValue) {
            this[index] = newValue;
        }


        /// <summary> 
        /// Atomically sets the element at position <paramref name="index"/> to <paramref name="newValue"/> 
        /// and returns the old value.
        /// </summary>
        /// <param name="index">
        /// Ihe index
        /// </param>
        /// <param name="newValue">
        /// The new value
        /// </param>
        public T SetNewAtomicValue(int index, T newValue) {
            lock(this) {
                T old = _referenceArray[index];
                _referenceArray[index] = newValue;
                return old;
            }
        }

        /// <summary> 
        /// Atomically sets the element at <paramref name="index"/> to <paramref name="newValue"/>
        /// if the current value equals the <paramref name="expectedValue"/>.
        /// </summary>
        /// <param name="index">
        /// The index
        /// </param>
        /// <param name="expectedValue">
        /// The expected value
        /// </param>
        /// <param name="newValue">
        /// The new value
        /// </param>
        /// <returns> 
        /// true if successful. False return indicates that
        /// the actual value was not equal to the expected value.
        /// </returns>
        public bool CompareAndSet(int index, T expectedValue, T newValue) {
            lock(this) {
                if(_referenceArray[index].Equals(expectedValue)) {
                    _referenceArray[index] = newValue;
                    return true;
                }
                return false;
            }
        }

        /// <summary> 
        /// Atomically sets the element at <paramref name="index"/> to <paramref name="newValue"/>
        /// if the current value equals the <paramref name="expectedValue"/>.
        /// May fail spuriously.
        /// </summary>
        /// <param name="index">
        /// The index
        /// </param>
        /// <param name="expectedValue">
        /// The expected value
        /// </param>
        /// <param name="newValue">
        /// The new value
        /// </param>
        /// <returns> 
        /// True if successful, false otherwise.
        /// </returns>
        public bool WeakCompareAndSet(int index, T expectedValue, T newValue) {
            lock(this) {
                if(_referenceArray[index].Equals(expectedValue)) {
                    _referenceArray[index] = newValue;
                    return true;
                }
                return false;
            }
        }

        /// <summary> 
        /// Returns the String representation of the current values of array.</summary>
        /// <returns> the String representation of the current values of array.
        /// </returns>
        public override string ToString() {
            if(_referenceArray.Length == 0)
                return "[]";

            StringBuilder buf = new StringBuilder();

            for(int i = 0; i < _referenceArray.Length; i++) {
                if(i == 0)
                    buf.Append('[');
                else
                    buf.Append(", ");

                buf.Append(Convert.ToString(_referenceArray[i]));
            }

            buf.Append("]");
            return buf.ToString();
        }
    }
}