namespace Spring.Threading.Helpers
{
	// TODO: Update XML Comments.
	/// <summary>
	/// 
	/// </summary>
	internal interface IQueuedSync
	{
		/// <summary>
		/// invoked with sync on wait node, (atomically) just before enqueuing
		/// </summary>
		/// <param name="node"></param>
		/// <returns></returns>
		bool Recheck(WaitNode node);
		/// <summary>
		/// invoked with sync on wait node, (atomically) just before signalling
		/// </summary>
		/// <param name="node"></param>
		void TakeOver(WaitNode node);
	}
}