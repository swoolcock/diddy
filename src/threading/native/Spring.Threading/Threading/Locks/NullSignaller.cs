namespace Spring.Threading.Locks
{
	/// <summary>
	/// No-Op implementation of <see cref="Spring.Threading.Locks.ISignaller"/>
	/// </summary>
	internal class NullSignaller : ISignaller
	{
		public void SignalWaiters()
		{
			// No-Op
		}
	}
}