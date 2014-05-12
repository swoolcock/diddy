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
	/// <summary> 
	/// An <see lang="int"/> value that may be updated atomically.
	/// An <see cref="Spring.Threading.AtomicTypes.AtomicInteger"/> is used in applications such as atomically
	/// incremented counters, and cannot be used as a replacement for an
	/// <see cref="int"/>. 
	/// <p/>
	/// Based on the on the back port of JCP JSR-166.
	/// </summary>
	/// <author>Doug Lea</author>
	/// <author>Griffin Caprio (.NET)</author>
    /// <author>Andreas Doehring (.NET)</author>
	[Serializable]
	public class AtomicInteger
	{
		private volatile int _integerValue;

		/// <summary> 
		/// Creates a new <see cref="Spring.Threading.AtomicTypes.AtomicInteger"/> with a value of <paramref name="initialValue"/>.
		/// </summary>
		/// <param name="initialValue">
		/// The initial value
		/// </param>
		public AtomicInteger(int initialValue)
		{
			_integerValue = initialValue;
		}

		/// <summary> 
		/// Creates a new <see cref="Spring.Threading.AtomicTypes.AtomicInteger"/> with initial value 0.
		/// </summary>
		public AtomicInteger() : this(0)
		{
		}

		/// <summary> 
		/// Gets the current value.
		/// </summary>
		/// <returns>
		/// The current value
		/// </returns>
		public int IntegerValue
		{
			get { return _integerValue; }
			set
			{
				lock (this)
				{
					_integerValue = value;
				}
			}
		}

		/// <summary> 
		/// Atomically increments by one the current value.
		/// </summary>
		/// <returns> 
		/// The previous value
		/// </returns>
		public int ReturnValueAndIncrement()
		{
			lock (this)
			{
				return _integerValue++;
			}

		}

		/// <summary> 
		/// Atomically decrements by one the current value.
		/// </summary>
		/// <returns> 
		/// The previous value
		/// </returns>
		public int ReturnValueAndDecrement()
		{
			lock (this)
			{
				return _integerValue--;
			}
		}

		/// <summary> 
		/// Eventually sets to the given value.
		/// </summary>
		/// <param name="newValue">
		/// The new value
		/// </param>
        //Why obsolete? If I understood correctly, programmer should use this for the low priority 
        //thread access. This can be better implemented to yield access to other thread in some 
        //other platform that support this.
        //[Obsolete("This method will be removed.  Please use AtomicInteger.IntegerValue property instead.")]
		public void LazySet(int newValue)
		{
			IntegerValue = newValue;
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
		public int SetNewAtomicValue(int newValue)
		{
			lock (this)
			{
				int oldValue = _integerValue;
				_integerValue = newValue;
				return oldValue;
			}
		}

		/// <summary> 
		/// Atomically sets the value to <paramref name="newValue"/>
		/// if the current value == <paramref name="expectedValue"/>
		/// </summary>
		/// <param name="expectedValue">
		/// The expected value
		/// </param>
		/// <param name="newValue">
		/// The new value
		/// </param>
		/// <returns> <see lang="true"/> if successful. <see lang="false"/> return indicates that
		/// the actual value was not equal to the expected value.
		/// </returns>
		public bool CompareAndSet(int expectedValue, int newValue)
		{
			lock (this)
			{
				if (_integerValue == expectedValue)
				{
					_integerValue = newValue;
					return true;
				}
                return false;
            }
        }

		/// <summary> 
		/// Atomically sets the value to <paramref name="newValue"/>
		/// if the current value == <paramref name="expectedValue"/>
		/// </summary>
		/// <param name="expectedValue">
		/// The expected value
		/// </param>
		/// <param name="newValue">
		/// The new value
		/// </param>
		/// <returns> <see lang="true"/> if successful. <see lang="false"/> return indicates that
		/// the actual value was not equal to the expected value.
		/// </returns>
		public virtual bool WeakCompareAndSet(int expectedValue, int newValue)
		{
			lock (this)
			{
				if (_integerValue == expectedValue)
				{
					_integerValue = newValue;
					return true;
				}
                return false;
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
		public int AddDeltaAndReturnPreviousValue(int deltaValue)
		{
			lock (this)
			{
				int oldValue = _integerValue;
				_integerValue += deltaValue;
				return oldValue;
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
		public int AddDeltaAndReturnNewValue(int deltaValue)
		{
			lock (this)
			{
				return _integerValue += deltaValue;
			}
		}

		/// <summary> 
		/// Atomically increments the current value by one.
		/// </summary>
		/// <returns> 
		/// The updated value
		/// </returns>
		public int IncrementValueAndReturn()
		{
			lock (this)
			{
				return ++_integerValue;
			}
		}

		/// <summary> 
		/// Atomically decrements by one the current value.
		/// </summary>
		/// <returns> 
		/// The updated value
		/// </returns>
		public int DecrementValueAndReturn()
		{
			lock (this)
			{
				return --_integerValue;
			}
		}

		/// <summary> 
		/// Returns the String representation of the current value.
		/// </summary>
		/// <returns> 
		/// The String representation of the current value.
		/// </returns>
		public override String ToString()
		{
			return IntegerValue.ToString();
		}
	}
}