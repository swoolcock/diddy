using System;
using Spring.Threading.Future;

namespace Spring.Threading.Execution
{
	
		/// <summary> 
		/// A service that decouples the production of new asynchronous tasks
		/// from the consumption of the results of completed tasks.  
		/// </summary>
		/// <remarks> 
		/// Producers
		/// submit tasks for execution. Consumers take
		/// completed tasks and process their results in the order they
		/// complete.  A <see cref="ICompletionService{T}"/> can for example be used to
		/// manage asynchronous IO, in which tasks that perform reads are
		/// submitted in one part of a program or system, and then acted upon
		/// in a different part of the program when the reads complete,
		/// possibly in a different order than they were requested.
		/// <p/>
		/// 
		/// Typically, a <see cref="ICompletionService{T}"/> relies on a separate 
		/// <see cref="IExecutor"/> to actually execute the tasks, in which case the
		/// <see cref="ICompletionService{T}"/> only manages an internal completion
		/// queue. The {@link ExecutorCompletionService} class provides an
		/// <seealso cref="ExecutorCompletionService{T}"/>
		/// </remarks>
		public interface ICompletionService<T>
		{
			/// <summary> 
			///	Submits a value-returning task for execution and returns a <see cref="IFuture{T}"/>
			/// representing the pending results of the task. Upon completion,
			/// this task may be taken or polled.
			/// </summary>
			/// <param name="task">the task to submit</param>
			/// <returns> a <see cref="IFuture{T}"/> representing pending completion of the task</returns>
			/// <exception cref="RejectedExecutionException">if the task cannot be accepted for execution.</exception>
			/// <exception cref="System.ArgumentNullException">if the command is null</exception>
			IFuture<T> Submit(ICallable<T> task);
		
		
			/// <summary> 
			/// Submits a <see cref="IRunnable"/> task for execution 
			/// and returns a <see cref="IFuture{T}"/>
			/// representing that task.  Upon completion, this task may be taken or polled.
			/// </summary>
			/// <param name="task">the task to submit</param>
			/// <param name="result">the result to return upon successful completion</param>
			/// <returns> a <see cref="IFuture{T}"/> representing pending completion of the task,
			/// and whose <see cref="IFuture{T}.GetResult()"/> method will return the given result value
			/// upon completion
			/// </returns>
			/// <exception cref="RejectedExecutionException">if the task cannot be accepted for execution.</exception>
			/// <exception cref="System.ArgumentNullException">if the command is null</exception>
			IFuture<T> Submit(IRunnable task, T result);
		
			/// <summary> 
			/// Retrieves and removes the <see cref="IFuture{T}"/> representing the next
			/// completed task, waiting if none are yet present.
			/// </summary>
			/// <returns> the <see cref="IFuture{T}"/> representing the next completed task
			/// </returns>
			IFuture<T> Take();
		
			/// <summary> 
			/// Retrieves and removes the <see cref="IFuture{T}"/> representing the next
			/// completed task or <see lang="null"/> if none are present.
			/// </summary>
			/// <returns> the <see cref="IFuture{T}"/> representing the next completed task, or
			/// <see lang="null"/> if none are present.
			/// </returns>
			IFuture<T> Poll();
		
			/// <summary> 
			/// Retrieves and removes the <see cref="IFuture{T}"/> representing the next
			/// completed task, waiting, if necessary, up to the specified duration
			/// if none are yet present.
			/// </summary>
			/// <param name="duration">duration to wait if no completed task is present yet.</param>
			/// <returns> 
			/// the <see cref="IFuture{T}"/> representing the next completed task or
			/// <see lang="null"/> if the specified waiting time elapses before one
			/// is present.
			/// </returns>
			IFuture<T> Poll(TimeSpan duration);
		}
}
