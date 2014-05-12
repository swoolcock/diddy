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
    /// An <see cref="AtomicMarkableReference{T}"/> maintains an object reference
    /// along with a mark bit, that can be updated atomically.
    /// <p/>
    /// <b>Note:</b>This implementation maintains markable
    /// references by creating internal objects representing "boxed"
    /// [reference, boolean] pairs.
    /// <p/>
    /// Based on the on the back port of JCP JSR-166.
    /// </summary>
    /// <author>Doug Lea</author>
    /// <author>Griffin Caprio (.NET)</author>
    /// <author>Andreas Doehring (.NET)</author>
    [Serializable]
    public class AtomicMarkableReference<T> {
        /// <summary>
        /// Holds the <see cref="Spring.Threading.AtomicTypes.AtomicReference{T}"/> reference
        /// </summary>
        private readonly AtomicReference<ReferenceBooleanPair<T>> _atomicReference;

        [Serializable]
        private class ReferenceBooleanPair<TI> {
            private readonly TI _reference;
            private readonly bool _markBit;

            internal ReferenceBooleanPair(TI reference, bool markBit) {
                _reference = reference;
                _markBit = markBit;
            }

            public TI Reference {
                get { return _reference; }
            }

            public bool MarkBit {
                get { return _markBit; }
            }
        }

        /// <summary> 
        /// Creates a new <see cref="Spring.Threading.AtomicTypes.AtomicMarkableReference{T}"/> with the given
        /// initial values.
        /// </summary>
        /// <param name="initialReference">
        /// the initial reference
        /// </param>
        /// <param name="initialMark">
        /// the initial mark
        /// </param>
        public AtomicMarkableReference(T initialReference, bool initialMark) {
            _atomicReference = new AtomicReference<ReferenceBooleanPair<T>>(new ReferenceBooleanPair<T>(initialReference, initialMark));
        }

        /// <summary>
        /// Returns the <see cref="ReferenceBooleanPair{TI}"/> held but this instance.
        /// </summary>
        private ReferenceBooleanPair<T> Pair {
            get { return _atomicReference.Reference; }

        }

        /// <summary> 
        /// Returns the current value of the reference.
        /// </summary>
        /// <returns> 
        /// The current value of the reference
        /// </returns>
        public object Reference {
            get { return Pair.Reference; }
        }

        /// <summary> 
        /// Returns the current value of the mark.
        /// </summary>
        /// <returns> 
        /// The current value of the mark
        /// </returns>
        public bool IsReferenceMarked {
            get { return Pair.MarkBit; }

        }

        /// <summary> 
        /// Returns the current values of both the reference and the mark.
        /// Typical usage is:
        /// <code>
        /// bool[1] holder;
        /// object reference = v.GetobjectReference(holder);
        /// </code>
        /// </summary>
        /// <param name="markHolder">
        /// An array of size of at least one. On return,
        /// markholder[0] will hold the value of the mark.
        /// </param>
        /// <returns> 
        /// The current value of the reference
        /// </returns>
        public T GetReference(ref bool[] markHolder) {
            ReferenceBooleanPair<T> p = Pair;
            markHolder[0] = p.MarkBit;
            return p.Reference;
        }

        /// <summary> 
        /// Atomically sets the value of both the reference and mark
        /// to the given update values if the
        /// current reference is equal to <paramref name="expectedReference"/> 
        /// and the current mark is equal to the <paramref name="expectedMark"/>.
        /// </summary>
        /// <param name="expectedReference">
        /// The expected value of the reference
        /// </param>
        /// <param name="newReference">
        /// The new value for the reference
        /// </param>
        /// <param name="expectedMark">
        /// The expected value of the mark
        /// </param>
        /// <param name="newMark">
        /// The new value for the mark
        /// </param>
        /// <returns> 
        /// <see lang="true"/> if successful, <see lang="false"/> otherwise
        /// </returns>
        public virtual bool WeakCompareAndSet(T expectedReference, T newReference, bool expectedMark, bool newMark) {
            ReferenceBooleanPair<T> current = Pair;

            return expectedReference.Equals(current.Reference) && expectedMark == current.MarkBit && 
                ((newReference.Equals(current.Reference) && newMark == current.MarkBit) || _atomicReference.CompareAndSet(current, new ReferenceBooleanPair<T>(newReference, newMark)));
        }

        /// <summary> 
        /// Atomically sets the value of both the reference and mark
        /// to the given update values if the
        /// current reference is equal to <paramref name="expectedReference"/> 
        /// and the current mark is equal to the <paramref name="expectedMark"/>.
        /// </summary>
        /// <param name="expectedReference">
        /// The expected value of the reference
        /// </param>
        /// <param name="newReference">
        /// The new value for the reference
        /// </param>
        /// <param name="expectedMark">
        /// The expected value of the mark
        /// </param>
        /// <param name="newMark">
        /// The new value for the mark
        /// </param>
        /// <returns> 
        /// <see lang="true"/> if successful, <see lang="false"/> otherwise
        /// </returns>
        public bool CompareAndSet(T expectedReference, T newReference, bool expectedMark, bool newMark) {
            ReferenceBooleanPair<T> current = Pair;

            return expectedReference.Equals(current.Reference) && expectedMark == current.MarkBit && 
                ((newReference.Equals(current.Reference) && newMark == current.MarkBit) || _atomicReference.CompareAndSet(current, new ReferenceBooleanPair<T>(newReference, newMark)));
        }

        /// <summary> 
        /// Unconditionally sets the value of both the reference and mark.
        /// </summary>
        /// <param name="newReference">the new value for the reference
        /// </param>
        /// <param name="newMark">the new value for the mark
        /// </param>
        public void SetNewAtomicValue(T newReference, bool newMark) {
            ReferenceBooleanPair<T> current = Pair;
            if(!newReference.Equals(current.Reference) || newMark != current.MarkBit)
                _atomicReference.SetNewAtomicValue(new ReferenceBooleanPair<T>(newReference, newMark));
        }

        /// <summary> 
        /// Atomically sets the value of the mark to the given update value
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
        /// <param name="newMark">
        /// The new value for the mark
        /// </param>
        /// <returns> 
        /// <see lang="true"/> if successful, <see lang="false"/> otherwise
        /// </returns>
        public bool AttemptMark(T expectedReference, bool newMark) {
            ReferenceBooleanPair<T> current = Pair;

            return expectedReference.Equals(current.Reference) 
                && (newMark == current.MarkBit || _atomicReference.CompareAndSet(current, new ReferenceBooleanPair<T>(expectedReference, newMark)));
        }
    }
}