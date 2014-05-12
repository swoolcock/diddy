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
#endregion

namespace Spring.Collections.Generic
{
    /// <summary>
    /// Class to provide a new strong typed list of type 
    /// <typeparamref name="TTo"/> from anothe strong typed list
    /// of type <typeparamref name="TFrom"/> without copying the elements.
    /// </summary>
    /// <remarks>
    /// <para>
    /// The constructed new list is a shadow copy of the source list.
    /// Changes to any one of the list will be seen by another.
    /// </para>
    /// </remarks>
    /// <typeparam name="TFrom">the element type of the new list</typeparam>
    /// <typeparam name="TTo">the element type of the source list</typeparam>
    /// <author>Kenneth Xu</author>
    public class TransformingList<TFrom, TTo> : AbstractTransformingList<TFrom, TTo>
    {
        /// <summary>
        /// Construct a new list of type <typeparamref name="TTo"/> based on
        /// <paramref name="source"/> list.
        /// </summary>
        /// <param name="source">the source list</param>
        /// <param name="transformer">
        /// Transformer that converts type <typeparamref name="TFrom"/> to 
        /// <typeparamref name="TTo"/>
        /// </param>
        /// <exception cref="ArgumentNullException">
        /// When parameter <paramref name="transformer"/> is <see langword="null"/>.
        /// </exception>
        public TransformingList(IList<TFrom> source, Converter<TFrom, TTo> transformer) 
            : this(source, transformer, null)
        {
        }

        /// <summary>
        /// Construct a new list of type <typeparamref name="TTo"/> based on
        /// <paramref name="source"/> list.
        /// </summary>
        /// <param name="source">the source list</param>
        /// <param name="transformer">
        /// Converts type <typeparamref name="TFrom"/> to <typeparamref name="TTo"/>
        /// </param>
        /// <param name="reverser">
        /// Converts type <typeparamref name="TTo"/> to <typeparamref name="TFrom"/>
        /// </param>
        /// <exception cref="ArgumentNullException">
        /// When parameter <paramref name="transformer"/> is <see langword="null"/>.
        /// </exception>
        public TransformingList(IList<TFrom> source, Converter<TFrom, TTo> transformer, Converter<TTo, TFrom> reverser)
            : base(source)
        {
            if (transformer == null) throw new ArgumentNullException("transformer");
            _transformer = transformer;
            _reverser = reverser;
        }

        /// <summary>
        /// Try converts object of type <typeparamref name="TTo"/> to
        /// <typeparamref name="TFrom"/>.
        /// </summary>
        /// <remarks>
        /// This implementation return <c>false</c> if and only if the
        /// reverser is given during the instance construction.
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
        protected override bool TryReverse(TTo target, out TFrom source)
        {
            if (_reverser==null)
            {
                return base.TryReverse(target, out source);
            }
            else
            {
                source = _reverser(target);
                return true;
            }
        }

        /// <summary>
        /// Converts the object of type <typeparamref name="TFrom"/> to
        /// object of type <typeparamref name="TTo"/> using the transformer
        /// provided to the constructor.
        /// </summary>
        /// <param name="source">item that is from the underlaying source list</param>
        /// <returns>converted item that can be returned by this list</returns>
        protected override TTo Transform(TFrom source)
        {
            return _transformer(source);
        }

        #region Private Instance Fields
        private Converter<TFrom, TTo> _transformer;
        private Converter<TTo, TFrom> _reverser;
        #endregion

    }

}