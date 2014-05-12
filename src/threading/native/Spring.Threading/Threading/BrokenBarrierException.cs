using System;
using System.Runtime.Serialization;

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

namespace Spring.Threading
{
	/// <summary> 
	/// Thrown by <see cref="Spring.Threading.IBarrier"/> upon interruption of participant threads
	/// </summary>
	[Serializable]
	public class BrokenBarrierException : ApplicationException
	{
		private readonly int _index;

		/// <summary>
		/// Creates a new <see cref="Spring.Threading.BrokenBarrierException"/> instance.
		/// </summary>
		public BrokenBarrierException()
		{
		}

		/// <summary> 
		/// The index that barrier would have returned upon normal return;
		/// </summary>
		public int Index
		{
			get { return _index; }
		}

		/// <summary> 
		/// Constructs a <see cref="Spring.Threading.BrokenBarrierException"/> with given index
		/// </summary>
		/// <param name="index">Index that the barrier would have returned upon normal return.</param>
		public BrokenBarrierException(int index)
		{
			_index = index;
		}

		/// <summary> 
		/// Constructs a <see cref="Spring.Threading.BrokenBarrierException"/> with the specified index and detail message.
		/// </summary>
		/// <param name="message">Message for the exception.</param>
		/// <param name="index">Index that the barrier would have returned upon normal return.</param>
		public BrokenBarrierException(int index, string message) : base(message)
		{
			_index = index;
		}

		/// <summary>
		/// Creates a new <see cref="Spring.Threading.BrokenBarrierException"/> instance.
		/// </summary>
		/// <param name="message">Message for the exception.</param>
		public BrokenBarrierException(string message) : base(message)
		{
		}

		/// <summary>
		/// Creates a new <see cref="Spring.Threading.BrokenBarrierException"/> instance.
		/// </summary>
		/// <param name="message">Message for the exception.</param>
		/// <param name="innerException">inner exception</param>
		public BrokenBarrierException(string message, Exception innerException) : base(message, innerException)
		{
		}

		/// <summary>
		/// Creates a new <see cref="BrokenBarrierException"/> instance.
		/// </summary>
		/// <remarks>
		/// This constructor is used by serialization/deserialization
		/// code, so it should not be used directly
		/// </remarks>
		/// <param name="info">
		/// The <see cref="System.Runtime.Serialization.SerializationInfo"/>
		/// that holds the serialized object data about the exception being thrown.
		/// </param>
		/// <param name="context">
		/// The <see cref="System.Runtime.Serialization.StreamingContext"/>
		/// that contains contextual information about the source or destination.
		/// </param>
		protected BrokenBarrierException(SerializationInfo info, StreamingContext context)
			: base(info, context)
		{
			_index = info.GetInt32("index");
		}

		/// <summary>
		/// Override of GetObjectData to allow for private serialization
		/// </summary>
		/// <param name="info">serialization info</param>
		/// <param name="context">streaming context</param>
		public override void GetObjectData(SerializationInfo info, StreamingContext context)
		{
			info.AddValue("index", _index);
			base.GetObjectData(info, context);
		}
	}
}