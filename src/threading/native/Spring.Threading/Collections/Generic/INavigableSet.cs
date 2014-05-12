#region License

/*
 * Copyright © 2002-2005 the original author or authors.
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

using System.Collections;

#endregion

namespace Spring.Collections.Generic
{
	/// <summary> 
	/// An extension of the <see cref="ISet"/> interface that provides a number of
	/// navigation methods reporting closest matches for given search targets.
	/// </summary>
	/// <remarks>
	/// <p>
	/// Methods <see cref="INavigableSet{T}.Lower(T)"/>, 
	/// <see cref="INavigableSet{T}.Floor(T)"/>,
	/// <see cref="INavigableSet{T}.Ceiling(T)"/>,
	/// and <see cref="INavigableSet{T}.Higher(T)"/>
	/// return elements respectively less than, less than or equal,
	/// greater than or equal, and greater than a given element, returning
	/// <see lang="null"/> if there is no such element.
	/// </p>
	/// <p>
	/// A <see cref="INavigableSet{T}"/> may be viewed and traversed
	/// in either ascending or descending order. The
	/// <see cref="System.Collections.IEnumerable.GetEnumerator()"/>
	/// method returns an ascending
	/// <see cref="System.Collections.IEnumerator"/> and
	/// the additional method
	/// <see cref="INavigableSet{T}.GetDescendingEnumerator()"/>
	/// returns a descending <see cref="System.Collections.IEnumerator"/>.
	/// The performance of ascending traversals is likely to be faster
	/// than descending traversals.  This interface additionally defines the
	/// methods <see cref="INavigableSet{T}.PollFirst"/> and
	/// <see cref="INavigableSet{T}.PollLast"/> that return and
	/// remove the lowest and highest element, if one exists, else returning
	/// <see lang="null"/>. Methods <see cref="INavigableSet{T}.NavigableSubSet"/>
	/// <see cref="INavigableSet{T}.NavigableHeadSet"/>, and
	/// <see cref="INavigableSet{T}.NavigableTailSet"/> differ from
	/// the similarly named <see cref="Spring.Collections.SortedSet"/> methods only
	/// in that the returned <see cref="ISet"/> references are guaranteed to obey the
	/// <see cref="INavigableSet{T}"/> interface.
	/// </p>
	/// <p>
	/// The return values of navigation methods may be ambiguous in implementations
	/// that permit <see lang="null"/> elements. However, even in this case the
	/// result can be disambiguated by checking the return value of the
	/// <see cref="ISet{T}.Contains(T)"/> (via <c>Contains(null)</c>).
	/// To avoid such issues, implementations of this interface are encouraged to
	/// <em>not</em> permit the insertion of <see lang="null"/> elements.
	/// </p>
	/// </remarks>
	/// <author>Griffin Caprio</author>
	/// <version>$Id: INavigableSet.cs,v 1.2 2006/10/02 02:36:07 gcaprio Exp $</version>
	public interface INavigableSet<T> : ISet<T>
	{
		/// <summary>
		/// Returns the greatest element in this set strictly less than the
		/// supplied <paramref name="element"/>, or <see lang="null"/> if there
		/// is no such element.
		/// </summary>
		/// <param name="element">The value to match.</param>
		/// <returns>
		/// The greatest element less than <paramref name="element"/>, or
		/// <see lang="null"/> if there is no such element.
		/// </returns>
		T Lower( T element );

		/// <summary>
		/// Returns the greatest element in this set less than or equal to
		/// the supplied <paramref name="element"/>, or <see lang="null"/> if there
		/// is no such element.
		/// </summary>
		/// <param name="element">The value to match.</param>
		/// <returns>
		/// The greatest element less than or equal to <paramref name="element"/>,
		/// or <see lang="null"/> if there is no such element.
		/// </returns>
		T Floor( T element );

		/// <summary>
		/// Returns the least element in this set greater than or equal to
		/// the supplied <paramref name="element"/>, or <see lang="null"/> if there
		/// is no such element.
		/// </summary>
		/// <param name="element">The value to match.</param>
		/// <returns>
		/// The least element greater than or equal to <paramref name="element"/>,
		/// or <see lang="null"/> if there is no such element.
		/// </returns>
		T Ceiling( T element );

		/// <summary>
		/// Returns the least element in this set strictly greater than the
		/// supplied <paramref name="element"/>, or <see lang="null"/> if there
		/// is no such element.
		/// </summary>
		/// <param name="element">The value to match.</param>
		/// <returns>
		/// The least element greater than <paramref name="element"/>,
		/// or <see lang="null"/> if there is no such element.
		/// </returns>
		T Higher( T element );

		/// <summary>
		/// Retrieves and removes the first (lowest) element.
		/// </summary>
		/// <returns>
		/// The first element, or <see lang="null"/> if this set is empty.
		/// </returns>
		T PollFirst();

		/// <summary>
		/// Retrieves and removes the last (highest) element.
		/// </summary>
		/// <returns>
		/// The last element, or <see lang="null"/> if this set is empty.
		/// </returns>
		T PollLast();

		/// <summary>
		/// Returns an <see cref="System.Collections.IEnumerator"/> over the elements
		/// in this set, in descending order.
		/// </summary>
		/// <returns>
		/// An <see cref="System.Collections.IEnumerator"/> over the elements in this
		/// set, in descending order.
		/// </returns>
		IEnumerator GetDescendingEnumerator();

		/// <summary>
		/// Returns a view of the portion of this set whose elements range
		/// from <paramref name="fromElement"/>, inclusive, to <paramref name="toElement"/>,
		/// exclusive.
		/// </summary>
		/// <remarks>
		/// <p>
		/// If <paramref name="fromElement"/> and <paramref name="toElement"/> are
		/// equal, the returned set is empty. The returned set is backed by this set,
		/// so changes in the returned set are reflected in this set, and vice-versa.
		/// The returned set supports all optional set operations that this set
		/// supports.
		/// </p>
		/// <p>
		/// The returned set must throw an <see cref="System.ArgumentException"/> 
		/// on an attempt to insert an element outside its range.
		/// </p>
		/// </remarks>
		/// <param name="fromElement">
		/// The low endpoint (inclusive) of the returned set.
		/// </param>
		/// <param name="toElement">
		/// The high endpoint (exclusive) of the returned set.
		/// </param>
		/// <returns>
		/// A view of the portion of this set whose elements range from
		/// <paramref name="fromElement"/>, inclusive, to
		/// <paramref name="toElement"/>, exclusive
		/// </returns>
		INavigableSet<T> NavigableSubSet( T fromElement, T toElement );

		/// <summary>
		/// Returns a view of the portion of this set whose elements are
		/// strictly less than <paramref name="toElement"/>. 
		/// </summary>
		/// <remarks>
		/// <p>
		/// The returned set is backed by this set, so changes in the returned
		/// set are reflected in this set, and vice-versa. The returned set
		/// supports all optional set operations that this set supports.
		/// </p>
		/// <p>
		/// The returned set must throw an <see cref="System.ArgumentException"/>
		/// on an attempt to insert an element outside its range.
		/// </p>
		/// </remarks>
		/// <param name="toElement">high endpoint (exclusive) of the returned set
		/// </param>
		/// <returns>
		/// A view of the portion of this set whose elements are strictly less than
		/// <paramref name="toElement"/>.
		/// </returns>
		INavigableSet<T> NavigableHeadSet( T toElement );

		/// <summary>
		/// Returns a view of the portion of this set whose elements are
		/// greater than or equal to <paramref name="fromElement"/>.
		/// </summary>
		/// <remarks>
		/// <p>
		/// The returned set is backed by this set, so changes in the returned set
		/// are reflected in this set, and vice-versa. The returned set supports all
		/// optional set operations that this set supports.
		/// </p>
		/// <p>
		/// The returned set will throw an <see cref="System.ArgumentException"/>
		/// on an attempt to insert an element outside its range.
		/// </p>
		/// </remarks>
		/// <param name="fromElement">
		/// The low endpoint (inclusive) of the returned set.
		/// </param>
		/// <returns>
		/// A view of the portion of this set whose elements are greater
		/// than or equal to <paramref name="fromElement"/>.
		/// </returns>
		INavigableSet<T> NavigableTailSet( T fromElement );

		/// <summary>
		/// Returns a portion of the list whose elements are less than the
		/// supplied <paramref name="limit"/>.
		/// </summary>
		/// <param name="limit">
		/// The end element of the portion to extract.
		/// </param>
		/// <returns>
		/// The portion of the collection whose elements are less than the
		/// supplied <paramref name="limit"/>.
		/// </returns>
		INavigableSet<T> HeadSet( T limit );

		/// <summary>
		/// Returns a portion of the list whose elements are greater than the
		/// supplied <paramref name="lowerLimit"/> parameter and less than the
		/// supplied <paramref name="upperLimit"/> parameter.
		/// </summary>
		/// <param name="upperLimit">
		/// The start element of the portion to extract.</param>
		/// <param name="lowerLimit">
		/// The end element of the portion to extract.
		/// </param>
		/// <returns>The relevant portion of the collection.</returns>
		INavigableSet<T> SubSet( T lowerLimit, T upperLimit );

		/// <summary>
		/// Returns a portion of the list whose elements are greater than the
		/// supplied <paramref name="limit"/>.
		/// </summary>
		/// <param name="limit">
		/// The start element of the portion to extract.
		/// </param>
		/// <returns>
		/// The portion of the collection whose elements are greater than the
		/// supplied <paramref name="limit"/>.
		/// </returns>
		INavigableSet<T> TailSet( T limit );
	}
}