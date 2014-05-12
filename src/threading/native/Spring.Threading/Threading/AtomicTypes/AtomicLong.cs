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

namespace Spring.Threading.AtomicTypes
{
	/// <summary> A <see lang="long"/> value that may be updated atomically.  See the
	/// An <see cref="Spring.Threading.AtomicTypes.AtomicLong"/> is used in applications such as atomically
	/// incremented sequence numbers, and cannot be used as a replacement
	/// for a <see cref="long"/>. 
	/// <p/>
	/// <b>Note:</b> the volatile keyword cannot be used with a <see lang="Int64"/>, so reading and writing
	/// of the long value for this class is accomplished using <see lang="lock"/>s explicitly.
	/// <p/>
	/// Based on the on the back port of JCP JSR-166.
	/// </summary>
	/// <author>Doug Lea</author>
	/// <author>Griffin Caprio (.NET)</author>
    /// <author>Andreas Doehring (.NET)</author>
    /// <author>Kenneth Xu (.NET)</author>
	[Serializable]
	public class AtomicLong
	{
		private long _longValue;

		/// <summary> 
		/// Creates a new <see cref="Spring.Threading.AtomicTypes.AtomicLong"/> with the given initial value.
		/// </summary>
		/// <param name="initialValue">
		/// The initial value
		/// </param>
		public AtomicLong(long initialValue)
		{
			_longValue = initialValue;
		}

		/// <summary> 
		/// Creates a new <see cref="Spring.Threading.AtomicTypes.AtomicLong"/> with initial value 0.
		/// </summary>
		public AtomicLong() : this(0)
		{
		}

	    /// <summary> 
	    /// Atomically increments by one the current value.
	    /// </summary>
	    /// <returns> the previous value
	    /// </returns>
	    public long ReturnValueAndIncrement()
	    {
	        lock (this)
	        {
	            return _longValue++;
	        }
	    }

	    /// <summary> 
	    /// Atomically decrements by one the current value.
	    /// </summary>
	    /// <returns> 
	    /// The previous value
	    /// </returns>
	    public long ReturnValueAndDecrement()
	    {
	        lock (this)
	        {
	            return _longValue--;
	        }
	    }

	    /// <summary> 
		/// Gets / Sets the current value.
		/// <p/>
		/// <b>Note:</b> the get and set of this property occurs within a lock.
		/// </summary>
		/// <returns> 
		/// The current value
		/// </returns>
		public long LongValue
		{
			get { lock(this) return _longValue; }
			set
			{
				lock (this)
				{
					_longValue = value;
				}
			}
		}
		/// <summary> 
		/// Eventually sets to the given value.
		/// </summary>
		/// <param name="newValue">
		/// The new value
		/// </param>
		public void LazySet(long newValue)
		{
			LongValue = newValue;
		}
		/// <summary> 
		/// Atomically sets value to <paramref name="newValue"/> and returns the old value.
		/// </summary>
		/// <param name="newValue">
		/// The new value
		/// </param>
		/// <returns> 
		/// The previous value
		/// </returns>
		public long SetNewAtomicValue(long newValue)
		{
			lock (this)
			{
				long old = _longValue;
				_longValue = newValue;
				return old;
			}
		}
		/// <summary> 
		/// Atomically sets the value to <paramref name="newValue"/>
		/// if the current value == <paramref name="expectedValue"/>.
		/// </summary>
		/// <param name="expectedValue">
		/// The expected value
		/// </param>
		/// <param name="newValue">
		/// The new value
		/// </param>
		/// <returns> true if successful. False return indicates that
		/// the actual value was not equal to the expected value.
		/// </returns>
		public bool CompareAndSet(long expectedValue, long newValue)
		{
			lock (this)
			{
				if (_longValue == expectedValue)
				{
					_longValue = newValue;
					return true;
				}
				else
				{
					return false;
				}
			}
		}

		/// <summary> 
		/// Atomically sets the value to <paramref name="newValue"/>
		/// if the current value == <paramref name="expectedValue"/>.
		/// May fail spuriously.
		/// </summary>
		/// <param name="expectedValue">
		/// The expected value
		/// </param>
		/// <param name="newValue">
		/// The new value
		/// </param>
		/// <returns> 
		/// True if successful.
		/// </returns>
		public virtual bool WeakCompareAndSet(long expectedValue, long newValue)
		{
			lock (this)
			{
				if (_longValue == expectedValue)
				{
					_longValue = newValue;
					return true;
				}
				else
				{
					return false;
				}
			}
		}
		/// <summary> 
		/// Atomically adds <paramref name="deltaValue"/> to the current value.
		/// </summary>
		/// <param name="deltaValue">
		/// The value to add
		/// </param>
		/// <returns> 
		/// The previous value
		/// </returns>
		public long AddDeltaAndReturnPreviousValue(long deltaValue)
		{
			lock (this)
			{
				long old = _longValue;
				_longValue += deltaValue;
				return old;
			}
		}
		/// <summary> 
		/// Atomically increments by one the current value.
		/// </summary>
		/// <returns> 
		/// The updated value
		/// </returns>
		public long IncrementValueAndReturn()
		{
			lock (this)
			{
				return ++_longValue;
			}
		}

		/// <summary> 
		/// Atomically decrements by one the current value.
		/// </summary>
		/// <returns> 
		/// The updated value
		/// </returns>
		public long DecrementValueAndReturn()
		{
			lock (this)
			{
				return --_longValue;
			}
		}
		/// <summary> 
		/// Atomically adds <paramref name="deltaValue"/> to the current value.
		/// </summary>
		/// <param name="deltaValue">
		/// The value to add
		/// </param>
		/// <returns> 
		/// The updated value
		/// </returns>
		public long AddDeltaAndReturnNewValue(long deltaValue)
		{
			lock (this)
			{
				return _longValue += deltaValue;
			}
		}
		/// <summary> 
		/// Returns the String representation of the current value.
		/// </summary>
		/// <returns> 
		/// The String representation of the current value.
		/// </returns>
        public override string ToString() 
		{
			return LongValue.ToString();
		}
	}
}