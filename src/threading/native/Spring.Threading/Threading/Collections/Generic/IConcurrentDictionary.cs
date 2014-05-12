
using System;
using System.Collections.Generic;

namespace Spring.Threading.Collections.Generic
{
    /// <summary>
    /// A <see cref="IDictionary{TKey,TValue}"/> providing additional atomic
    /// <see cref="PutIfAbsent"/>, <see cref="Remove"/>, <see cref="Replace(TKey,TValue)"/> and <see cref="Replace(TKey,TValue,TValue)"/> methods.
    ///
    /// <p>
    /// Memory consistency effects: As with other concurrent
    /// collections, actions in a thread prior to placing an object into a
    /// <see cref="IConcurrentDictionary{TKey,TValue}"/> as a key or value
    /// <i>happen-before</i>
    /// actions subsequent to the access or removal of that object from
    /// the <see cref="IConcurrentDictionary{TKey,TValue}"/> in another thread.
    /// </p>
    ///
    /// </summary>
    /// <author>Doug Lea</author>
    /// <author>Griffin Caprio (.NET)</author>
    public interface IConcurrentDictionary<TKey, TValue> : IDictionary<TKey, TValue>
    {
        ///<summary>
        /// If the specified <paramref name="key"/> is not already associated
        /// with a value, associate it with the given <paramref name="value"/>.
        /// This is equivalent to
        /// <pre>
        ///   if (!dictionary.containsKey(key))
        ///       return dictionary.put(key, value);
        ///   else
        ///       return dictionary.get(key);
        /// </pre>
        /// except that the action is performed atomically.
        ///</summary>
        ///<param name="key">key with which the specified value is to be associated</param>
        ///<param name="value">value to be associated with the specified key</param>
        ///<returns>the previous value associated with the specified key, or <see lang="null"/> if there was no mapping for the key. (A <see lang="null"/> return can also indicate that the dictionary previously associated <see lang="null"/> with the key, if the implementation supports null values.)</returns>
        /// <exception cref="InvalidOperationException">if the put operation is not supported by this dictionary</exception>
        /// <exception cref="NullReferenceException">if the specific key or value is null ( and this dictionary does not support null keys or values )</exception>
        /// <exception cref="ArgumentException">if some property of the specific key or value prevents if from being stored in this dictionary.</exception>
        TValue PutIfAbsent(TKey key, TValue value);

        ///<summary>
        /// Removes the entry for <paramref name="key"/> only if currently mapped to <paramref name="value"/>.
        /// This is equivalent to
        /// <pre>
        ///   if (dictionary.containsKey(key) &amp;&amp; dictionary.get(key).equals(value)) {
        ///       dictionary.remove(key);
        ///       return true;
        ///   } else return false;
        /// </pre>
        /// except that the action is performed atomically.
        ///</summary>
        ///<param name="key">key with which the specified value is to be associated</param>
        ///<param name="value">value expected to be associated with the specified key</param>
        ///<returns><see lang="true"/> if the value was removed, <see lang="false"/> otherwise.</returns>
        /// <exception cref="InvalidOperationException">if the put operation is not supported by this dictionary</exception>
        /// <exception cref="NullReferenceException">if the specific key or value is null ( and this dictionary does not support null keys or values )</exception>
        /// <exception cref="ArgumentException">if some property of the specific key or value prevents if from being stored in this dictionary.</exception>
        bool Remove(TKey key, TValue value);

        ///<summary>
        /// Replaces the entry for <paramref name="key"/> only if currently mapped to <paramref name="oldValue"/>.
        /// This is equivalent to
        /// <pre>
        ///   if (dictionary.containsKey(key) &amp;&amp; dictionary.get(key).equals(oldValue)) {
        ///       dictionary.put(key, newValue);
        ///       return true;
        ///   } else return false;</pre>
        /// except that the action is performed atomically.
        ///</summary>
        ///<param name="key">key with which the specified value is associated</param>
        ///<param name="oldValue">value expected to be associated with the specified key</param>
        ///<param name="newValue">value to be associated with the specified key</param>
        ///<returns><see lang="true"/> if the value was replaced, <see lang="false"/> otherwise.</returns>
        /// <exception cref="InvalidOperationException">if the put operation is not supported by this dictionary</exception>
        /// <exception cref="NullReferenceException">if the specific key or value is null ( and this dictionary does not support null keys or values )</exception>
        /// <exception cref="ArgumentException">if some property of the specific key or value prevents if from being stored in this dictionary.</exception>
        bool Replace(TKey key, TValue oldValue, TValue newValue);

        ///<summary>
        /// Replaces the entry for  <paramref name="key"/> only if currently mapped to a value.
        /// This is equivalent to
        /// <pre>
        ///   if (dictionary.containsKey(key)) {
        ///       return dictionary.put(key, value);
        ///   } else return null;
        /// </pre>
        /// except that the action is performed atomically.
        ///</summary>
        ///<param name="key">key with which the specified value is associated</param>
        ///<param name="value">value to be associated with the specified key</param>
        ///<returns>the previous value associated with the specified key, or <see lang="null"/> if there was no mapping for the key. (A <see lang="null"/> return can also indicate that the dictionary previously associated <see lang="null"/> with the key, if the implementation supports null values.)</returns>
        /// <exception cref="InvalidOperationException">if the put operation is not supported by this dictionary</exception>
        /// <exception cref="NullReferenceException">if the specific key or value is null ( and this dictionary does not support null keys or values )</exception>
        /// <exception cref="ArgumentException">if some property of the specific key or value prevents if from being stored in this dictionary.</exception>
        TValue Replace(TKey key, TValue value);
    }
}