
using System.Collections.Generic;
using System.Threading;

namespace Spring.Threading.Helpers
{
	/// <summary> 
	/// Interface for internal queue classes for semaphores, etc.
	/// Relies on implementations to actually implement queue mechanics.
	/// </summary>	
	/// <author>Dawid Kurzyniec</author>
	/// <author>Griffin Caprio (.NET)</author>
	/// <changes>
	/// <ol>
	/// <li>Renamed Length to Count</li>
	/// <li>Renamed Insert to Enqueue</li>
	/// <li>Renamed Extract to Dequeue</li>
	/// <li>Renamed IWaitQueue to IWaitNodeQueue</li>
	/// </ol>
	/// </changes>
	// TODO: Update XML Comments.
	internal interface IWaitNodeQueue
	{
		/// <summary>
		/// 
		/// </summary>
		int Count { get; }

		/// <summary>
		/// 
		/// </summary>
		ICollection<Thread> WaitingThreads { get; }

		/// <summary>
		/// 
		/// </summary>
		/// <param name="w"></param>
		void Enqueue(WaitNode w); // assumed not to block
		/// <summary>
		///		
		/// </summary>
		/// <returns></returns>
		WaitNode Dequeue(); // should return null if empty
		/// <summary>
		/// 
		/// </summary>
		bool HasNodes { get; }

		/// <summary>
		/// 
		/// </summary>
		/// <param name="thread"></param>
		/// <returns></returns>
		bool IsWaiting(Thread thread);
	}
}