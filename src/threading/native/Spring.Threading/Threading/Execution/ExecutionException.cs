using System;
using System.Runtime.Serialization;
using Spring.Threading.Future;

namespace Spring.Threading.Execution
{
	/// <summary> 
	/// Exception thrown when attempting to retrieve the result of a task
	/// that aborted by throwing an exception. 
	/// </summary>
	/// <seealso cref="IFuture{T}"/>
	/// <author>Doug Lea</author>
	/// <author>Griffin Caprio (.NET)</author>
	[Serializable]
	public class ExecutionException : ApplicationException
	{
		/// <summary> Constructs a <see cref="Spring.Threading.Execution.ExecutionException"/> with no detail message.</summary>
		public ExecutionException()
		{
		}

		/// <summary> Constructs a <see cref="Spring.Threading.Execution.ExecutionException"/> with the specified detail message.</summary>
		/// <param name="message">the detail message</param>
		public ExecutionException(String message) : base(message)
		{
		}

		/// <summary> Constructs a <see cref="Spring.Threading.Execution.ExecutionException"/> with the specified detail message and cause.</summary>
		/// <param name="message">the detail message</param>
		/// <param name="cause">the cause (which is saved for later retrieval by the</param>
		public ExecutionException(String message, Exception cause) : base(message, cause)
		{
		}

		/// <summary> 
		/// Constructs a <see cref="Spring.Threading.Execution.ExecutionException"/> with the specified cause.
		/// </summary>
		/// <param name="rootCause">The root exception that is being wrapped.</param>
		public ExecutionException(Exception rootCause) : base(String.Empty, rootCause)
		{
		}
		/// <summary>
		/// Creates a new instance of the <see cref="Spring.Threading.Execution.ExecutionException"/> class.
		/// </summary>
		/// <param name="info">
		/// The <see cref="System.Runtime.Serialization.SerializationInfo"/>
		/// that holds the serialized object data about the exception being thrown.
		/// </param>
		/// <param name="context">
		/// The <see cref="System.Runtime.Serialization.StreamingContext"/>
		/// that contains contextual information about the source or destination.
		/// </param>
		protected ExecutionException(
			SerializationInfo info, StreamingContext context)
			: base(info, context)
		{
		}
	}
}