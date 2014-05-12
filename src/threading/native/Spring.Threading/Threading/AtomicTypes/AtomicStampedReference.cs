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

namespace Spring.Threading.AtomicTypes {
    /// <summary>
    /// An <see cref="Spring.Threading.AtomicTypes.AtomicStampedReference{T}"/> maintains an object reference
    /// along with an integer "stamp", that can be updated atomically.
    /// 
    /// <p/>
    /// <b>Note:</b>This implementation maintains stamped
    /// references by creating internal objects representing "boxed"
    /// [reference, integer] pairs.
    /// <p/>
    /// Based on the on the back port of JCP JSR-166.
    /// </summary>
    /// <author>Doug Lea</author>
    /// <author>Griffin Caprio (.NET)</author>
    /// <author>Andreas Doehring (.NET)</author>
    [Serializable]
    public class AtomicStampedReference<T> {
        private readonly AtomicReference<ReferenceIntegerPair<T>> _atomicReference;

        [Serializable]
        private class ReferenceIntegerPair<TI> {
            private readonly TI _reference;
            private readonly int _integer;

            internal ReferenceIntegerPair(TI reference, int integer) {
                _reference = reference;
                _integer = integer;
            }

            public TI Reference {
                get { return _reference; }
            }

            public int Integer {
                get { return _integer; }
            }
        }

        /// <summary> 
        ///	Returns the current value of the reference.
        /// </summary>
        /// <returns> 
        /// The current value of the reference
        /// </returns>
        public T Reference {
            get { return Pair.Reference; }

        }
        
        /// <summary> 
        /// Returns the current value of the stamp.
        /// </summary>
        /// <returns> 
        /// The current value of the stamp
        /// </returns>
        public int Stamp {
            get { return Pair.Integer; }

        }
        
        /// <summary>
        /// Gets the <see cref="ReferenceIntegerPair{T}"/> represented by this instance.
        /// </summary>
        private ReferenceIntegerPair<T> Pair {
            get { return _atomicReference.Reference; }

        }

        /// <summary> 
        /// Creates a new <see cref="Spring.Threading.AtomicTypes.AtomicStampedReference{T}"/> with the given
        /// initial values.
        /// </summary>
        /// <param name="initialRef">
        /// The initial reference
        /// </param>
        /// <param name="initialStamp">
        /// The initial stamp
        /// </param>
        public AtomicStampedReference(T initialRef, int initialStamp) {
            _atomicReference = new AtomicReference<ReferenceIntegerPair<T>>(new ReferenceIntegerPair<T>(initialRef, initialStamp));
        }

        /// <summary> 
        /// Returns the current values of both the reference and the stamp.
        /// Typical usage is:
        /// <code>
        /// int[1] holder;
        /// object reference = v.GetobjectReference(holder);
        /// </code> 
        /// </summary>
        /// <param name="stampHolder">
        /// An array of size of at least one.  On return,
        /// <tt>stampholder[0]</tt> will hold the value of the stamp.
        /// </param>
        /// <returns> 
        /// The current value of the reference
        /// </returns>
        public T GetObjectReference(int[] stampHolder) {
            ReferenceIntegerPair<T> p = Pair;
            stampHolder[0] = p.Integer;
            return p.Reference;
        }
        
        /// <summary> 
        /// Atomically sets the value of both the reference and stamp
        /// to the given update values if the
        /// current reference is equals to the expected reference
        /// and the current stamp is equal to the expected stamp.  Any given
        /// invocation of this operation may fail (return
        /// false) spuriously, but repeated invocation when
        /// the current value holds the expected value and no other thread
        /// is also attempting to set the value will eventually succeed.
        /// </summary>
        /// <param name="expectedReference">
        /// The expected value of the reference
        /// </param>
        /// <param name="newReference">
        /// The new value for the reference
        /// </param>
        /// <param name="expectedStamp">
        /// The expected value of the stamp
        /// </param>
        /// <param name="newStamp">
        /// The new value for the stamp
        /// </param>
        /// <returns> 
        /// True if successful
        /// </returns>
        public virtual bool WeakCompareAndSet(T expectedReference, T newReference, int expectedStamp, int newStamp) {
            ReferenceIntegerPair<T> current = Pair;

            return expectedReference.Equals(current.Reference) && expectedStamp == current.Integer 
                && ((newReference.Equals(current.Reference) && newStamp == current.Integer) || _atomicReference.WeakCompareAndSet(current, new ReferenceIntegerPair<T>(newReference, newStamp)));
        }

        /// <summary> 
        /// Atomically sets the value of both the reference and stamp
        /// to the given update values if the
        /// current reference is equal to the expected reference
        /// and the current stamp is equal to the expected stamp.
        /// </summary>
        /// <param name="expectedReference">
        /// The expected value of the reference
        /// </param>
        /// <param name="newReference">
        /// The new value for the reference
        /// </param>
        /// <param name="expectedStamp">
        /// The expected value of the stamp
        /// </param>
        /// <param name="newStamp">
        /// The new value for the stamp
        /// </param>
        /// <returns> 
        /// True if successful, false otherwise.
        /// </returns>
        public virtual bool CompareAndSet(T expectedReference, T newReference, int expectedStamp, int newStamp) {
            ReferenceIntegerPair<T> current = Pair;
            return expectedReference.Equals(current.Reference) && expectedStamp == current.Integer 
                && ((newReference.Equals(current.Reference) && newStamp == current.Integer) || _atomicReference.WeakCompareAndSet(current, new ReferenceIntegerPair<T>(newReference, newStamp)));
        }

        /// <summary> 
        /// Unconditionally sets the value of both the reference and stamp.
        /// </summary>
        /// <param name="newReference">
        /// The new value for the reference
        /// </param>
        /// <param name="newStamp">
        /// The new value for the stamp
        /// </param>
        public void SetNewAtomicValue(T newReference, int newStamp) {
            ReferenceIntegerPair<T> current = Pair;
            if(!newReference.Equals(current.Reference) || newStamp != current.Integer)
                _atomicReference.Reference = new ReferenceIntegerPair<T>(newReference, newStamp);
        }

        /// <summary> 
        /// Atomically sets the value of the stamp to the given update value
        /// if the current reference is equal to the expected
        /// reference.  Any given invocation of this operation may fail
        /// (return false) spuriously, but repeated invocation
        /// when the current value holds the expected value and no other
        /// thread is also attempting to set the value will eventually
        /// succeed.
        /// </summary>
        /// <param name="expectedReference">
        /// The expected value of the reference
        /// </param>
        /// <param name="newStamp">
        /// The new value for the stamp
        /// </param>
        /// <returns> 
        /// True if successful
        /// </returns>
        public virtual bool AttemptStamp(T expectedReference, int newStamp) {
            ReferenceIntegerPair<T> current = Pair;
            return expectedReference.Equals(current.Reference) 
                && (newStamp == current.Integer || _atomicReference.CompareAndSet(current, new ReferenceIntegerPair<T>(expectedReference, newStamp)));
        }
    }
}