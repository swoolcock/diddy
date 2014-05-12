namespace Spring.Threading.Execution.ExecutionPolicy
{
    /// <summary> 
    /// A <see cref="Spring.Threading.Execution.IRejectedExecutionHandler"/> for rejected tasks that discards the oldest unhandled
    /// request and then retries <see cref="Spring.Threading.IExecutor.Execute(IRunnable)"/>, unless the executor
    /// is shut down, in which case the task is discarded.
    /// </summary>
    public class DiscardOldestPolicy : IRejectedExecutionHandler
    {
        #region IRejectedExecutionHandler Members

        /// <summary> 
        /// Obtains and ignores the next task that the <paramref name="executor"/>
        /// would otherwise execute, if one is immediately available,
        /// and then retries execution of task <paramref name="runnable"/>, unless the <paramref name="executor"/>
        /// is shut down, in which case task <paramref name="runnable"/> is instead discarded.
        /// </summary>
        /// <param name="runnable">the <see cref="Spring.Threading.IRunnable"/> task requested to be executed</param>
        /// <param name="executor">the <see cref="Spring.Threading.Execution.ThreadPoolExecutor"/> attempting to execute this task</param>
        public virtual void RejectedExecution(IRunnable runnable, ThreadPoolExecutor executor)
        {
            if (executor.IsShutdown) return;
            IRunnable head;
            executor.Queue.Poll(out head);
            executor.Execute(runnable);
        }

        #endregion
    }
}