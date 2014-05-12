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
    /// <see cref="TransformingEnumerator{TSource,TTarget}"/> transforms the elements
    /// from the source instance of <see cref="IEnumerator{T}"/> using a given transformer.
    /// </summary>
    /// <typeparam name="TTarget">
    /// Type of the data element after the transformed
    /// </typeparam>
    /// <typeparam name="TSource">
    /// Type of the data element of the orignal enumerator
    /// </typeparam>
    /// <seealso cref="Converter{TInput,TOutput}"/>
    /// <author>Kenneth Xu</author>
    public class TransformingEnumerator<TSource, TTarget> : AbstractEnumerator<TTarget>
    {
        private readonly IEnumerator<TSource> e;
        private readonly Converter<TSource, TTarget> t;

        /// <summary>
        /// The only constructor of <c>TransformingEnumerator</c>
        /// </summary>
        /// <param name="source">
        /// The source enumerator of which the elements will be transformed
        /// </param>
        /// <param name="transformer">
        /// The transformer to transform the elements.
        /// </param>
        /// <exception cref="ArgumentNullException">
        /// when parameter <paramref name="source"/> or <paramref name="transformer"/> 
        /// is null.
        /// </exception>
        public TransformingEnumerator(IEnumerator<TSource> source, 
            Converter<TSource, TTarget> transformer)
        {
            if (source == null) throw new ArgumentNullException("source");
            if (transformer == null) throw new ArgumentNullException("transformer");
            e = source;
            t = transformer;
        }
        


        #region IDisposable Members

        ///<summary>
        ///Disposes the enumerator causes the source enumerator to be disposed 
        /// as well.
        ///</summary>
        ///<filterpriority>2</filterpriority>
        public override void Dispose()
        {
            e.Dispose();
        }

        #endregion

        #region IEnumerator Members

        ///<summary>
        ///Sets the enumerator to its initial position, which is before the 
        /// first element in the collection.
        ///</summary>
        ///
        ///<exception cref="T:System.InvalidOperationException">
        /// The collection was modified after the enumerator was created. 
        /// </exception>
        /// <filterpriority>2</filterpriority>
        public override void Reset()
        {
            e.Reset();
        }

        #endregion

        #region IEnumerator<TTarget> Members

        ///<summary>
        ///Advances the enumerator to the next element of the collection.
        ///</summary>
        ///
        ///<returns>
        ///true if the enumerator was successfully advanced to the next 
        /// element; false if the enumerator has passed the end of the 
        /// collection.
        ///</returns>
        ///
        ///<exception cref="T:System.InvalidOperationException">
        /// The collection was modified after the enumerator was created. 
        /// </exception>
        /// <filterpriority>2</filterpriority>
        protected override bool GoNext()
        {
            return e.MoveNext();
        }

        ///<summary>
        ///Gets the element in the collection at the current position of the 
        /// enumerator.
        ///</summary>
        ///
        ///<returns>
        ///The element in the collection at the current position of the 
        /// enumerator.
        ///</returns>
        ///
        protected override TTarget FetchCurrent()
        {
            return t(e.Current);
        }

        #endregion
    }


    /// <summary>
    /// <see cref="TransformingEnumerator{TTarget}"/> transforms the elements
    /// from a source instance of <see cref="IEnumerator"/> using a given transformer.
    /// </summary>
    /// <typeparam name="TTarget">
    /// Type of the data element after the transformed
    /// </typeparam>
    /// <seealso cref="Converter{TInput,TOutput}"/>
    /// <author>Kenneth Xu</author>
    public class TransformingEnumerator<TTarget> : AbstractEnumerator<TTarget>
    {
        private readonly IEnumerator e;
        private readonly Converter<object, TTarget> t;

        /// <summary>
        /// The only constructor of <c>TransformingEnumerator</c>
        /// </summary>
        /// <param name="source">
        /// The source enumerator of which the elements will be transformed
        /// </param>
        /// <param name="transformer">
        /// The transformer to transform the elements.
        /// </param>
        /// <exception cref="ArgumentNullException">
        /// when parameter <paramref name="source"/> or <paramref name="transformer"/> 
        /// is null.
        /// </exception>
        public TransformingEnumerator(IEnumerator source,
            Converter<object, TTarget> transformer)
        {
            if (source == null) throw new ArgumentNullException("source");
            if (transformer == null) throw new ArgumentNullException("transformer");
            e = source;
            t = transformer;
        }

        #region IDisposable Members

        ///<summary>
        ///Disposes the enumerator causes the source enumerator to be disposed
        /// if it implements the <see cref="IDisposable"/>. Otherwise, nothing
        /// is done.
        ///</summary>
        ///<filterpriority>2</filterpriority>
        public override void Dispose()
        {
            IDisposable d = e as IDisposable;
            if (d!=null) d.Dispose();
        }

        #endregion

        #region IEnumerator Members


        ///<summary>
        ///Sets the enumerator to its initial position, which is before 
        /// the first element in the collection.
        ///</summary>
        ///
        ///<exception cref="T:System.InvalidOperationException">
        /// The collection was modified after the enumerator was created. 
        /// </exception>
        /// <filterpriority>2</filterpriority>
        public override void Reset()
        {
            e.Reset();
        }

        #endregion

        #region Protected Methods

        ///<summary>
        ///Gets the element in the collection at the current position of the 
        /// enumerator.
        ///</summary>
        ///
        ///<returns>
        ///The element in the collection at the current position of the 
        /// enumerator.
        ///</returns>
        ///
        protected override TTarget FetchCurrent()
        {
            return t(e.Current);
        }

        ///<summary>
        ///Advances the enumerator to the next element of the collection.
        ///</summary>
        ///
        ///<returns>
        ///true if the enumerator was successfully advanced to the next 
        /// element; false if the enumerator has passed the end of the 
        /// collection.
        ///</returns>
        ///
        ///<exception cref="T:System.InvalidOperationException">
        /// The collection was modified after the enumerator was created. 
        /// </exception>
        /// <filterpriority>2</filterpriority>
        protected override bool GoNext()
        {
            return e.MoveNext();
        }

        #endregion
    }
}