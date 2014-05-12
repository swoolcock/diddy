namespace Spring.Collections.Generic
{
	/// <summary>
	/// An interface representing a <see cref="ISet"/>, sorted in ascending order.
	/// </summary>
	/// <author>Griffin Caprio</author>
	public interface ISortedSet<T> : ISet<T>
	{
		/// <summary>
		/// Returns a portion of the list whose elements are less than the limit object parameter.
		/// </summary>
		/// <param name="limit">The end element of the portion to extract.</param>
		/// <returns>The portion of the collection whose elements are less than the limit object parameter.</returns>
		ISortedSet<T> HeadSet( T limit );

		/// <summary>
		/// Returns a portion of the list whose elements are greater that the lowerLimit parameter less than the upperLimit parameter.
		/// </summary>
		/// <param name="lowerLimit">The start element of the portion to extract.</param>
		/// <param name="upperLimit">The end element of the portion to extract.</param>
		/// <returns>The portion of the collection.</returns>
		ISortedSet<T> SubSet( T lowerLimit, T upperLimit );

		/// <summary>
		/// Returns a portion of the list whose elements are greater than the limit object parameter.
		/// </summary>
		/// <param name="limit">The start element of the portion to extract.</param>
		/// <returns>The portion of the collection whose elements are greater than the limit object parameter.</returns>
		ISortedSet<T> TailSet( T limit );
	}
}