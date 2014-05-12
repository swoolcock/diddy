namespace Spring.Threading.Execution.ExecutionPolicy
{
	/// <summary> 
	/// A <see cref="Spring.Threading.Execution.IRejectedExecutionHandler"/> for rejected tasks that throws a
	/// <see cref="Spring.Threading.Execution.RejectedExecutionException"/>
	/// </summary>
	public class AbortPolicy : IRejectedExecutionHandler
	{
		/// <summary> 
		/// Always throws <see cref="Spring.Threading.Execution.RejectedExecutionException"/>.
		/// </summary>
		/// <param name="runnable">the <see cref="Spring.Threading.IRunnable"/> task requested to be executed</param>
		/// <param name="executor">the <see cref="Spring.Threading.Execution.ThreadPoolExecutor"/> attempting to execute this task</param>
		/// <exception cref="Spring.Threading.Execution.RejectedExecutionException">Always thrown upon execution.</exception>
        public virtual void RejectedExecution(IRunnable runnable, ThreadPoolExecutor executor)
		{
			throw new RejectedExecutionException("IRunnable: " + runnable + " rejected from execution by ThreadPoolExecutor: " + executor);
		}
	}
}