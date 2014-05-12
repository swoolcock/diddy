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
using System.Collections.Generic;
using System;
#endregion

namespace Spring.Collections.Generic
{
    /// <summary>
    /// Transforms a <see cref="IList{T}">IList(Of TBase)</see>
    /// to a <see cref="IList{T}">IList(Of TSub)</see> by
    /// simply casting the elements when <typeparamref name="TSub"/> is a
    /// derived type of <typeparamref name="TBase"/>.
    /// </summary>
    /// <typeparam name="TSub">The sub type.</typeparam>
    /// <typeparam name="TBase">The base type.</typeparam>
    public class DownCastList<TBase, TSub> : AbstractTransformingList<TBase, TSub>
        where TSub : TBase
    {
        #region Constructors

        /// <summary>
        /// Construct a collection of <typeparamref name="TBase"/> by 
        /// transforming the elemnts from <paramref name="source"/>.
        /// </summary>
        /// <remarks>
        /// The resulting collection is mutable by down casting 
        /// <typeparamref name="TBase"/> to <typeparamref name="TSub"/>
        /// when necessary.
        /// </remarks>
        /// <param name="source">
        /// The source collection of <typeparamref name="TSub"/>.
        /// </param>
        public DownCastList(IList<TBase> source)
            : base(source)
        {
        }

        #endregion

        /// <summary>
        /// Determines whether the <see cref="IList{T}"/> contains a specific 
        /// value. 
        /// </summary>
        /// <returns>
        /// true if item is found in the <see cref="IList{T}"/>; otherwise, false.
        /// </returns>
        /// 
        /// <param name="item">
        /// The object to locate in the <see cref="IList{T}"/>.
        /// </param>
        public override bool Contains(TSub item)
        {
            return SourceList.Contains(item);
        }

        /// <summary>
        /// Removes the first occurrence of a specific object from the <see cref="IList{T}"/>.
        /// </summary>
        /// 
        /// <returns>
        /// true if item was successfully removed from the <see cref="IList{T}"/>; 
        /// otherwise, false. This method also returns false if item is not found in the 
        /// original <see cref="IList{T}"/>.
        /// </returns>
        /// 
        /// <param name="item">The object to remove from the <see cref="IList{T}"/>.</param>
        /// <exception cref="NotSupportedException">
        /// When the <see cref="IList{T}"/> is read-only.
        /// </exception>
        public override bool Remove(TSub item)
        {
            return SourceList.Remove(item);
        }

        /// <summary>
        /// No-op tranformation, simply return the <paramref name="source"/>
        /// as is.
        /// </summary>
        /// <param name="source">
        /// Instace of <typeparamref name="TSub"/> to be upcasted.
        /// </param>
        /// <returns>
        /// The same instance of <paramref name="source"/>.
        /// </returns>
        /// <exception cref="InvalidCastException">
        /// When <paramref name="source"/> is not of type <typeparamref name="TSub"/>.
        /// </exception>
        protected override TSub Transform(TBase source)
        {
            return (TSub)source;
        }

        /// <summary>
        /// Converts object of type <typeparamref name="TBase"/> to
        /// <typeparamref name="TSub"/>.
        /// </summary>
        /// <remarks>
        /// This implementation always return <c>false</c>. Subclasses that
        /// support reversing should override this method.
        /// </remarks>
        /// <param name="target">
        /// Instance of <typeparamref name="TBase"/> to be converted.
        /// </param>
        /// <param name="source">
        /// Converted object of type <typeparamref name="TSub"/>.
        /// </param>
        /// <returns>
        /// <c>true</c> when reserving is supported, otherwise <c>false</c>.
        /// </returns>
        protected override bool TryReverse(TSub target, out TBase source)
        {
            source = target;
            return true;
        }

        /// <summary>
        /// Converts the object of type <typeparamref name="TSub"/> to
        /// object of type <typeparamref name="TBase"/>.
        /// </summary>
        /// <remarks>
        /// This implementaiton simply returns the <paramref name="target"/>.
        /// </remarks>
        /// <param name="target">item passed to this list</param>
        /// <returns>converted item that can be passed to the underlaying source list</returns>
        protected override TBase Reverse(TSub target)
        {
            return target;
        }
    }
}