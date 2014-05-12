/* Copyright � 2002-2004 by Aidant Systems, Inc., and by Jason Smith. */

#region License

/*
 * Copyright � 2002-2005 the original author or authors.
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

namespace Spring.Collections.Generic {
    /// <summary>
    /// <see cref="Spring.Collections.Generic.DictionarySet{T}"/> is an
    /// <see langword="abstract"/> class that supports the creation of new
    /// <see cref="Spring.Collections.Generic.ISet{T}"/> types where the underlying data
    /// store is an <see cref="System.Collections.Generic.IDictionary{T,Tobject}"/> instance.
    /// </summary>
    /// <remarks>
    /// <p>
    /// You can use any object that implements the
    /// <see cref="System.Collections.Generic.IDictionary{T,TObject}"/> interface to hold set
    /// data. You can define your own, or you can use one of the objects
    /// provided in the framework. The type of
    /// <see cref="System.Collections.Generic.IDictionary{T,TObject}"/> you
    /// choose will affect both the performance and the behavior of the
    /// <see cref="Spring.Collections.Generic.ISet{T}"/> using it.
    /// </p>
    /// <p>
    /// This object overrides the <see cref="System.Object.Equals(object)"/> method,
    /// but not the <see cref="System.Object.GetHashCode"/> method, because
    /// the <see cref="Spring.Collections.DictionarySet"/> class is mutable.
    /// Therefore, it is not safe to use as a key value in a dictionary.
    /// </p>
    /// <p>
    /// To make a <see cref="Spring.Collections.Generic.ISet{T}"/> typed based on your
    /// own <see cref="System.Collections.Generic.IDictionary{T,TObject}"/>, simply derive a new
    /// class with a constructor that takes no parameters. Some
    /// <see cref="Spring.Collections.ISet"/> implmentations cannot be defined
    /// with a default constructor. If this is the case for your class, you
    /// will need to override <b>clone</b> as well.
    /// </p>
    /// <p>
    /// It is also standard practice that at least one of your constructors
    /// takes an <see cref="System.Collections.ICollection"/> or an
    /// <see cref="Spring.Collections.Generic.ISet{T}"/> as an argument.
    /// </p>
    /// </remarks>
    /// <seealso cref="Spring.Collections.Generic.ISet{T}"/>
    [Serializable]
    public abstract class DictionarySet<T> : Set<T> {
        private IDictionary<T, object> _internalDictionary;

        private static readonly object PlaceholderObject = new object();

        /// <summary>
        /// Provides the storage for elements in the
        /// <see cref="Spring.Collections.ISet"/>, stored as the key-set
        /// of the <see cref="System.Collections.IDictionary"/> object.  
        /// </summary>
        /// <remarks>
        /// <p>
        /// Set this object in the constructor if you create your own
        /// <see cref="Spring.Collections.ISet"/> class.
        /// </p>
        /// </remarks>
        protected IDictionary<T, object> InternalDictionary {
            get { return _internalDictionary; }
            set { _internalDictionary = value; }
        }

        /// <summary>
        /// The placeholder object used as the value for the
        /// <see cref="System.Collections.IDictionary"/> instance.
        /// </summary>
        /// <remarks>
        /// There is a single instance of this object globally, used for all
        /// <see cref="Spring.Collections.ISet"/>s.
        /// </remarks>
        protected static object Placeholder {
            get { return PlaceholderObject; }
        }

        /// <summary>
        /// Adds the specified element to this set if it is not already present.
        /// </summary>
        /// <param name="element">The object to add to the set.</param>
        /// <returns>
        /// <see langword="true"/> is the object was added,
        /// <see langword="false"/> if the object was already present.
        /// </returns>
        public override bool Add(T element) {
            if(InternalDictionary.ContainsKey(element))
                return false;

            //The object we are adding is just a placeholder.  The thing we are
            //really concerned with is 'o', the key.
            InternalDictionary.Add(element, PlaceholderObject);
            return true;
        }

        /// <summary>
        /// Adds all the elements in the specified collection to the set if
        /// they are not already present.
        /// </summary>
        /// <param name="collection">A collection of objects to add to the set.</param>
        /// <returns>
        /// <see langword="true"/> is the set changed as a result of this
        /// operation.
        /// </returns>
        public override bool AddAll(ICollection<T> collection) {
            bool changed = false;
            foreach(T o in collection) {
                changed |= Add(o);
            }
            return changed;
        }

        /// <summary>
        /// Removes all objects from this set.
        /// </summary>
        public override void Clear() {
            InternalDictionary.Clear();
        }

        /// <summary>
        /// Returns <see langword="true"/> if this set contains the specified
        /// element.
        /// </summary>
        /// <param name="element">The element to look for.</param>
        /// <returns>
        /// <see langword="true"/> if this set contains the specified element.
        /// </returns>
        public override bool Contains(T element) {
            return InternalDictionary.ContainsKey(element);
        }

        /// <summary>
        /// Returns <see langword="true"/> if the set contains all the
        /// elements in the specified collection.
        /// </summary>
        /// <param name="collection">A collection of objects.</param>
        /// <returns>
        /// <see langword="true"/> if the set contains all the elements in the
        /// specified collection; also <see langword="false"/> if the
        /// supplied <paramref name="collection"/> is <see langword="null"/>.
        /// </returns>
        public override bool ContainsAll(ICollection<T> collection) {
            if(collection == null) {
                return false;
            }
            foreach(T o in collection) {
                if(!Contains(o)) {
                    return false;
                }
            }
            return true;
        }

        /// <summary>
        /// Returns <see langword="true"/> if this set contains no elements.
        /// </summary>
        public override bool IsEmpty {
            get { return InternalDictionary.Count == 0; }
        }

        /// <summary>
        /// Removes the specified element from the set.
        /// </summary>
        /// <param name="element">The element to be removed.</param>
        /// <returns>
        /// <see langword="true"/> if the set contained the specified element.
        /// </returns>
        public override bool Remove(T element) {
            bool contained = Contains(element);
            if(contained) {
                InternalDictionary.Remove(element);
            }
            return contained;
        }

        /// <summary>
        /// Remove all the specified elements from this set, if they exist in
        /// this set.
        /// </summary>
        /// <param name="collection">A collection of elements to remove.</param>
        /// <returns>
        /// <see langword="true"/> if the set was modified as a result of this
        /// operation.
        /// </returns>
        public override bool RemoveAll(ICollection<T> collection) {
            bool changed = false;
            foreach(T o in collection) {
                changed |= Remove(o);
            }
            return changed;
        }

        /// <summary>
        /// Retains only the elements in this set that are contained in the
        /// specified collection.
        /// </summary>
        /// <param name="collection">
        /// The collection that defines the set of elements to be retained.
        /// </param>
        /// <returns>
        /// <see langword="true"/> if this set changed as a result of this
        /// operation.
        /// </returns>
        public override bool RetainAll(ICollection<T> collection) {
            //Put data from C into a set so we can use the Contains() method.
            List<T> cSet = new List<T>(collection);

            //We are going to build a set of elements to remove.
            List<T> removeSet = new List<T>();

            foreach(T o in this) {
                //If C does not contain O, then we need to remove O from our
                //set.  We can't do this while iterating through our set, so
                //we put it into RemoveSet for later.
                if(!cSet.Contains(o)) {
                    removeSet.Add(o);
                }
            }
            return RemoveAll(removeSet);
        }

        /// <summary>
        /// Copies the elements in the <see cref="Spring.Collections.ISet"/> to
        /// an array.
        /// </summary>
        /// <remarks>
        /// <p>
        /// The type of array needs to be compatible with the objects in the
        /// <see cref="Spring.Collections.ISet"/>, obviously.
        /// </p>
        /// </remarks>
        /// <param name="array">
        /// An array that will be the target of the copy operation.
        /// </param>
        /// <param name="index">
        /// The zero-based index where copying will start.
        /// </param>
        public override void CopyTo(T[] array, int index) {
            int i = index;
            foreach(T o in this) {
                array.SetValue(o, i++);
            }
        }

        /// <summary>
        /// The number of elements currently contained in this collection.
        /// </summary>
        public override int Count {
            get { return InternalDictionary.Count; }
        }

        /// <summary>
        /// Returns <see langword="true"/> if the
        /// <see cref="Spring.Collections.ISet"/> is synchronized across
        /// threads.
        /// </summary>
        /// <seealso cref="Spring.Collections.Set.IsSynchronized"/>
        public override bool IsSynchronized {
            get { return false; }
        }

        /// <summary>
        /// An object that can be used to synchronize this collection to make
        /// it thread-safe.
        /// </summary>
        /// <value>
        /// An object that can be used to synchronize this collection to make
        /// it thread-safe.
        /// </value>
        /// <seealso cref="Spring.Collections.Set.SyncRoot"/>
        public override object SyncRoot {
            get { return InternalDictionary; }
        }

        /// <summary>
        /// Gets an enumerator for the elements in the
        /// <see cref="Spring.Collections.ISet"/>.
        /// </summary>
        /// <returns>
        /// An <see cref="System.Collections.IEnumerator"/> over the elements
        /// in the <see cref="Spring.Collections.ISet"/>.
        /// </returns>
        public override IEnumerator<T> GetEnumerator() {
            return new DictionarySetEnumerator(InternalDictionary.Keys.GetEnumerator());
        }

        #region Inner Class : DictionarySetEnumerator

        private sealed class DictionarySetEnumerator : IEnumerator<T> {
            #region Constructor (s) / Destructor

            public DictionarySetEnumerator(IEnumerator<T> enumerator) {
                _enumerator = enumerator;
            }

            #endregion

            #region IEnumerator Members

            public void Reset() {
                _enumerator.Reset();
            }

            public T Current {
                get { return _enumerator.Current; }
            }

            public bool MoveNext() {
                return _enumerator.MoveNext();
            }

            #endregion

            private readonly IEnumerator<T> _enumerator;

            #region IDisposable Members

            public void Dispose() {
                // empty by intention
            }

            #endregion

            #region IEnumerator Members

            object System.Collections.IEnumerator.Current {
                get { return _enumerator.Current; }
            }

            #endregion
        }

        #endregion
    }
}