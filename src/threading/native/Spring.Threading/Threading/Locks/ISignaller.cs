namespace Spring.Threading.Locks
{
	/// <summary> 
	/// Reader and Writer requests are maintained in two different
	/// wait sets, by two different objects. These objects do not
	/// know whether the wait sets need notification since they
	/// don't know preference rules. So, each supports a
	/// method that can be selected by the main controlling object
	/// to perform the notifications.
	/// </summary>
	internal interface ISignaller
	{
		/// <summary>
		/// Notify waiting objects.
		/// </summary>
		void SignalWaiters();
	}
}