using System.Threading;

namespace Spring.Threading.Execution
{
	/// <summary>
	/// Simplest implementation of <see cref="Spring.Threading.IThreadFactory"/>
	/// </summary>
	public class SimpleThreadFactory : IThreadFactory
	{
		/// <summary>
		/// Default Constructor
		/// </summary>
		public SimpleThreadFactory() {}

		/// <summary> 
		/// Constructs a new <see cref="System.Threading.Thread"/>.  
		/// </summary>
		/// <remarks> 
		/// Implementations may also initialize
		/// priority, name, daemon status, thread state, etc.
		/// </remarks>
		/// <param name="runnable">
		/// a runnable to be executed by new thread instance
		/// </param>
		/// <returns>constructed thread</returns>
		public Thread NewThread( IRunnable runnable )
		{
			return new Thread( new ThreadStart( runnable.Run ) );
		}
	}
}