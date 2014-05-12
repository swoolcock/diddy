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
    /// A long array in which elements may be updated atomically.
    /// <p/>
    /// Based on the on the back port of JCP JSR-166.
    /// </summary>
    /// <author>Doug Lea</author>
    /// <author>Griffin Caprio (.NET)</author>
    /// <author>Andreas Doehring (.NET)</author>
    /// <author>Kenneth Xu (.NET)</author>
    [Serializable]
    public class AtomicLongArray {
        private long[] _longArray;

        /// <summary> 
        /// Creates a new <see cref="Spring.Threading.AtomicTypes.AtomicLongArray"/> of given <paramref name="length"/>.
        /// </summary>
        /// <param name="length">
        /// The length of the array
        /// </param>
        public AtomicLongArray(int length) {
            _longArray = new long[length];
        }

        /// <summary> 
        /// Creates a new <see cref="Spring.Threading.AtomicTypes.AtomicLongArray"/> with the same length as, and
        /// all elements copied from, <paramref name="array"/>.
        /// </summary>
        /// <param name="array">
        /// The array to copy elements from
        /// </param>
        /// <exception cref="ArgumentNullException"> if the array is null</exception>
        public AtomicLongArray(long[] array) {
            if(array == null)
                throw new ArgumentNullException();
            int length = array.Length;
            _longArray = new long[length];
            Array.Copy(array, 0, _longArray, 0, array.Length);
        }

        /// <summary> 
        /// Returns the length of the array.
        /// </summary>
        /// <returns> 
        /// The length of the array
        /// </returns>
        public int Length {
            get { return _longArray.Length; }
        }

        /// <summary> 
        /// Gets / Sets the current value at position index.
        /// </summary>
        /// <param name="index">
        /// The index
        /// </param>
        /// <returns> 
        /// The current value
        /// </returns>
        public long this[int index] {
            get {
                lock(this) {
                    return _longArray[index];
                }
            }
            set { lock(this) _longArray[index] = value; }
        }

        /// <summary> 
        /// Eventually sets the element at position <paramref name="index"/> to the given <paramref name="newValue"/>.
        /// </summary>
        /// <param name="index">
        /// The index
        /// </param>
        /// <param name="newValue">
        /// The new value
        /// </param>
        //Why obsolete? If I understood correctly, programmer should use this for the low priority 
        //thread access. This can be better implemented to yield access to other thread in some 
        //other platform that support this.
        //[Obsolete("This method will be removed.  Please use AtomicLongArray indexer instead.")]
        public void LazySet(int index, long newValue) {
            this[index] = newValue;
        }

        /// <summary> 
        /// Atomically sets the element at <paramref name="index"/> to the <paramref name="newValue"/>
        /// and returns the old value.
        /// </summary>
        /// <param name="index">
        /// The index
        /// </param>
        /// <param name="newValue">
        /// The new value
        /// </param>
        /// <returns> 
        /// The previous value
        /// </returns>
        public long SetNewAtomicValue(int index, long newValue) {
            lock(this) {
                long old = _longArray[index];
                _longArray[index] = newValue;
                return old;
            }
        }

        /// <summary>
        /// Atomically sets the value to <paramref name="newValue"/>
        /// if the current value == <paramref name="expectedValue"/>
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
        /// <returns> true if successful. False return indicates that
        /// the actual value was not equal to the expected value.
        /// </returns>
        public bool CompareAndSet(int index, long expectedValue, long newValue) {
            lock(this) {
                if(_longArray[index] == expectedValue) {
                    _longArray[index] = newValue;
                    return true;
                }
                else {
                    return false;
                }
            }
        }

        /// <summary> 
        /// Atomically sets the value to <paramref name="newValue"/>
        /// if the current value == <paramref name="expectedValue"/>
        /// May fail spuriously.
        /// </summary>
        /// <param name="index">the index
        /// </param>
        /// <param name="expectedValue">
        /// The expected value
        /// </param>
        /// <param name="newValue">
        /// The new value
        /// </param>
        /// <returns> 
        /// True if successful.
        /// </returns>
        public virtual bool WeakCompareAndSet(int index, long expectedValue, long newValue) {
            lock(this) {
                if(_longArray[index] == expectedValue) {
                    _longArray[index] = newValue;
                    return true;
                }
                else {
                    return false;
                }
            }
        }

        /// <summary> 
        /// Atomically increments by one the element at <paramref name="index"/>.
        /// </summary>
        /// <param name="index">
        /// The index
        /// </param>
        /// <returns> 
        /// The previous value
        /// </returns>
        public long ReturnValueAndIncrement(int index) {
            lock(this) {
                return _longArray[index]++;
            }
        }

        /// <summary> 
        /// Atomically decrements by one the element at <paramref name="index"/>.
        /// </summary>
        /// <param name="index">
        /// The index
        /// </param>
        /// <returns> 
        /// The previous value
        /// </returns>
        public long ReturnValueAndDecrement(int index) {
            lock(this) {
                return _longArray[index]--;
            }
        }

        /// <summary> 
        /// Atomically adds the given value to the element at <paramref name="index"/>. 
        /// </summary>
        /// <param name="index">
        /// The index
        /// </param>
        /// <param name="deltaValue">
        /// The value to add
        /// </param>
        /// <returns> 
        /// The previous value
        /// </returns>
        public long AddDeltaAndReturnPreviousValue(int index, long deltaValue) {
            lock(this) {
                long oldValue = _longArray[index];
                _longArray[index] += deltaValue;
                return oldValue;
            }
        }

        /// <summary> 
        /// Atomically increments by one the element at <paramref name="index"/>.
        /// </summary>
        /// <param name="index">
        /// The index
        /// </param>
        /// <returns> 
        /// The updated value
        /// </returns>
        public long IncrementValueAndReturn(int index) {
            lock(this) {
                return ++_longArray[index];
            }
        }

        /// <summary> 
        /// Atomically decrements by one the element at <paramref name="index"/>.
        /// </summary>
        /// <param name="index">
        /// The index
        /// </param>
        /// <returns> 
        /// The updated value
        /// </returns>
        public long DecrementValueAndReturn(int index) {
            lock(this) {
                return --_longArray[index];
            }
        }

        /// <summary> 
        /// Atomically adds <paramref name="deltaValue"/> to the element at <paramref name="index"/>.
        /// </summary>
        /// <param name="index">
        /// The index
        /// </param>
        /// <param name="deltaValue">
        /// The value to add
        /// </param>
        /// <returns> 
        /// The updated value
        /// </returns>
        public long AddDeltaAndReturnNewValue(int index, long deltaValue) {
            lock(this) {
                return _longArray[index] += deltaValue;
            }
        }

        /// <summary> 
        /// Returns the String representation of the current values of array.
        /// </summary>
        /// <returns> 
        /// The String representation of the current values of array.
        /// </returns>
        public override String ToString() {
            if(_longArray.Length == 0)
                return "[]";

            StringBuilder buf = new StringBuilder();
            buf.Append('[');
            buf.Append(_longArray[0]);

            for(int i = 1; i < _longArray.Length; i++) {
                buf.Append(", ");
                buf.Append(_longArray[i]);
            }

            buf.Append("]");
            return buf.ToString();
        }
    }
}