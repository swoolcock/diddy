namespace Spring.Threading.Execution.ExecutionPolicy
{
    /// <summary>
    /// A handler for rejected tasks that runs the rejected task
    /// directly in the calling thread of the <see cref="IRunnable.Run"/> method,
    /// unless the executor has been shut down, in which case the task
    /// is discarded.
    /// </summary>
    public class CallerRunsPolicy : IRejectedExecutionHandler
    {
        #region IRejectedExecutionHandler Members

        /// <summary>
        /// Executes task <paramref name="runnable"/> in the caller's thread, unless <paramref name="executor"/> 
        /// has been shut down, in which case the task is discarded.
        ///
        /// <param name="executor">the executor attempting to execute this task</param>
        /// <param name="runnable">the runnable task requested to be executed</param>
        /// </summary>
        public void RejectedExecution(IRunnable runnable, ThreadPoolExecutor executor)
        {
            if (executor.IsShutdown) return;
            runnable.Run();
        }

        #endregion
    }
}