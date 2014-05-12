using Spring.Collections.Generic;

namespace Spring.Threading.Collections.Generic
{
	/// <summary> A <see cref="IConcurrentDictionary{TKey,TValue}"/> supporting <see cref="INavigableDictionary{TKey,TValue}"/>
	/// operations,and recursively so for its navigable sub-maps.
	/// </summary>
	/// <author>Doug Lea</author>
	/// <author>Griffin Caprio (.NET)</author>
	public interface IConcurrentNavigableDictionary<TKey, TValue> : IConcurrentDictionary<TKey, TValue>, INavigableDictionary<TKey, TValue>
	{
// TODO: Implement NavigableDictionary, SortedDictionary & this interface
//**
//     * @throws ClassCastException       {@inheritDoc}
//     * @throws NullPointerException     {@inheritDoc}
//     * @throws IllegalArgumentException {@inheritDoc}
//     */
//    NavigableMap navigableSubMap(Object fromKey, Object toKey);
//
//    /**
//     * @throws ClassCastException       {@inheritDoc}
//     * @throws NullPointerException     {@inheritDoc}
//     * @throws IllegalArgumentException {@inheritDoc}
//     */
//    NavigableMap navigableHeadMap(Object toKey);
//
//    /**
//     * @throws ClassCastException       {@inheritDoc}
//     * @throws NullPointerException     {@inheritDoc}
//     * @throws IllegalArgumentException {@inheritDoc}
//     */
//    NavigableMap navigableTailMap(Object fromKey);
//
//    /**
//     * Equivalent to {@link #navigableSubMap}.
//     *
//     * <p>{@inheritDoc}
//     *
//     * @throws ClassCastException       {@inheritDoc}
//     * @throws NullPointerException     {@inheritDoc}
//     * @throws IllegalArgumentException {@inheritDoc}
//     */
//    SortedMap subMap(Object fromKey, Object toKey);
//
//    /**
//     * Equivalent to {@link #navigableHeadMap}.
//     *
//     * <p>{@inheritDoc}
//     *
//     * @throws ClassCastException       {@inheritDoc}
//     * @throws NullPointerException     {@inheritDoc}
//     * @throws IllegalArgumentException {@inheritDoc}
//     */
//    SortedMap headMap(Object toKey);
//
//    /**
//     * Equivalent to {@link #navigableTailMap}.
//     *
//     * <p>{@inheritDoc}
//     *
//     * @throws ClassCastException       {@inheritDoc}
//     * @throws NullPointerException     {@inheritDoc}
//     * @throws IllegalArgumentException {@inheritDoc}
//     */
//    SortedMap tailMap(Object fromKey);
	}
}