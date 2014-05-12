namespace Spring.Threading.Execution.ExecutionPolicy
{
	/// <summary> 
	/// A <see cref="Spring.Threading.Execution.IRejectedExecutionHandler"/> for rejected tasks that silently discards the
	/// rejected task.
	/// </summary>
	public class DiscardPolicy : IRejectedExecutionHandler
	{
		/// <summary> 
		/// Silently discards the <see cref="Spring.Threading.IRunnable"/>
		/// </summary>
		/// <param name="runnable">the <see cref="Spring.Threading.IRunnable"/> task requested to be executed</param>
		/// <param name="executor">the <see cref="Spring.Threading.Execution.ThreadPoolExecutor"/> attempting to execute this task</param>
        public virtual void RejectedExecution(IRunnable runnable, ThreadPoolExecutor executor)
		{
		}
	}

}