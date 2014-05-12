namespace Spring.Threading.Locks
{
    /// <summary>
    /// Interface representing an <b>exclusive</b> <see cref="Spring.Threading.Locks.ILock"/>
    /// </summary>
    internal interface IExclusiveLock : ILock
    {
        /// <summary>
        /// Gets value indicating if this lock is current held by the current thread.
        /// </summary>
        bool IsHeldByCurrentThread { get; }

        int HoldCount { get; }
    }
}