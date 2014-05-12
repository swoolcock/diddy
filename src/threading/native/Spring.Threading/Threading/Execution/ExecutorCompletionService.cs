using System;
using Spring.Threading.Collections;
using Spring.Threading.Collections.Generic;
using Spring.Threading.Future;

namespace Spring.Threading.Execution
{
	/// <summary> 
	/// A <see cref="ICompletionService{T}"/> that uses a supplied <see cref="IExecutor"/>
	/// to execute tasks.  
	/// </summary>
	/// <remarks>
	/// <para>
	/// This class arranges that submitted tasks are, upon completion, placed 
	/// on a queue accessible using <see cref="Take()"/>. The class is 
	/// lightweight enough to be suitable for transient use when processing 
	/// groups of tasks.
	/// </para>
	/// <example>
	/// Usage Examples.
	/// <para>
	/// Suppose you have a set of solvers for a certain problem, each 
	/// returning a value of some type <c>Result</c>, and would like to run 
	/// them concurrently, processing the results of each of them that
	/// return a non-null value, in some method <c>Use(Result r)</c>. You
	/// could write this as:
	/// </para>
	/// <code language="c#">
    ///   void Solve(IExecutor e,
    ///              ICollection&lt;ICallable&lt;Result&gt;&gt; solvers)
    ///   {
    ///       ICompletionService&lt;Result&gt; ecs
    ///           = new ExecutorCompletionService&lt;Result&gt;(e);
    ///       foreach (ICallable&lt;Result&gt; s in solvers)
    ///           ecs.Submit(s);
    ///       int n = solvers.size();
    ///       for (int i = 0; i &lt; n; ++i) {
    ///           Result r = ecs.Take().GetResult();
    ///           if (r != null) Use(r);
    ///       }
    ///   }
    /// </code>
    /// <para>
	/// Suppose instead that you would like to use the first non-null result
	/// of the set of tasks, ignoring any that encounter exceptions,
	/// and cancelling all other tasks when the first one is ready:
	/// </para>
	/// <code language="c#">
    ///   void Solve(IExecutor e,
    ///              ICollection&lt;ICallable&lt;Result&gt;&gt; solvers)
    ///   {
    ///       ICompletionService&lt;Result&gt; ecs
    ///           = new ExecutorCompletionService&lt;Result&gt;(e);
    ///       int n = solvers.Count;
    ///       IList&lt;IFuture&lt;Result&gt;&gt; futures
    ///           = new List&lt;IFuture&lt;Result&gt;&gt;(n);
    ///       Result result = null;
    ///       try {
    ///           foreach (ICallable&lt;Result&gt; s in solvers)
    ///               futures.Add(ecs.Submit(s));
    ///           for (int i = 0; i &lt; n; ++i) {
    ///               try {
    ///                   Result r = ecs.Take().GetResult();
    ///                   if (r != null) {
    ///                       result = r;
    ///                       break;
    ///                   }
    ///               } catch (ExecutionException ignore) {}
    ///           }
    ///       }
    ///       finally {
    ///           for (IFuture&lt;Result&gt; f : futures)
    ///               f.Cancel(true);
    ///       }
    ///
    ///       if (result != null)
    ///           Use(result);
    ///   }
    /// </code>
	/// </example>
	/// </remarks>
	/// <author>Doug Lea</author>
	/// <author>Griffin Caprio (.NET)</author>
	/// <author>Kenneth Xu (.NET)</author>
	public class ExecutorCompletionService<T> : ICompletionService<T>
	{
		private readonly IExecutor _executor;
	    private readonly AbstractExecutorService _aes;
		private readonly IBlockingQueue<IFuture<T>> _completionQueue;

        /// <summary>
        /// <see cref="FutureTask{T}"/> extension to enqueue upon completion
        /// </summary>
		private class QueueingFuture : FutureTask<object>
		{
			private readonly ExecutorCompletionService<T> _enclosingInstance;
		    private readonly IFuture<T> _task;

            internal QueueingFuture(ExecutorCompletionService<T> enclosingInstance, IRunnableFuture<T> task)
                : base(task, null)
			{
				_enclosingInstance = enclosingInstance;
                _task = task;
			}

			protected internal override void Done()
			{
				_enclosingInstance._completionQueue.Add(_task);
			}
		}

        private IRunnableFuture<T> NewTaskFor(ICallable<T> task)
        {
            if (_aes == null)
                return new FutureTask<T>(task);
            else
                return _aes.NewTaskFor(task);
        }

        private IRunnableFuture<T> NewTaskFor(IRunnable task, T result)
        {
            if (_aes == null)
                return new FutureTask<T>(task, result);
            else
                return _aes.NewTaskFor(task, result);
        }


		/// <summary> 
		/// Creates an <see cref="ExecutorCompletionService{T}"/> using the supplied
		/// executor for base task execution and a
		/// <see cref="LinkedBlockingQueue{T}"/> as a completion queue.
		/// </summary>
		/// <param name="executor">the executor to use</param>
		/// <exception cref="System.ArgumentNullException">
		/// if the executor is null
		/// </exception>
		public ExecutorCompletionService(IExecutor executor) 
            : this( executor, new LinkedBlockingQueue<IFuture<T>>())
		{
		}

		/// <summary> 
		/// Creates an <see cref="ExecutorCompletionService{T}"/> using the supplied
		/// executor for base task execution and the supplied queue as its
		/// completion queue.
		/// </summary>
		/// <param name="executor">the executor to use</param>
		/// <param name="completionQueue">the queue to use as the completion queue
		/// normally one dedicated for use by this service
		/// </param>
		/// <exception cref="System.ArgumentNullException">
		/// if the executor is null
		/// </exception>
		public ExecutorCompletionService(IExecutor executor, IBlockingQueue<IFuture<T>> completionQueue)
		{
			if (executor == null)
				throw new ArgumentNullException("executor", "Executor cannot be null.");
			if (completionQueue == null)
				throw new ArgumentNullException("completionQueue", "Completion Queue cannot be null.");
			_executor = executor;
            _aes = executor as AbstractExecutorService;
			_completionQueue = completionQueue;
		}

		/// <summary> 
		///	Submits a value-returning task for execution and returns a <see cref="IFuture{T}"/>
		/// representing the pending results of the task. Upon completion,
		/// this task may be taken or polled.
		/// </summary>
		/// <param name="task">the task to submit</param>
		/// <returns> a <see cref="IFuture{T}"/> representing pending completion of the task</returns>
		/// <exception cref="Spring.Threading.Execution.RejectedExecutionException">if the task cannot be accepted for execution.</exception>
		/// <exception cref="System.ArgumentNullException">if the command is null</exception>
		public virtual IFuture<T> Submit(ICallable<T> task)
		{
			if (task == null)
				throw new ArgumentNullException("task", "Task cannot be null.");
            return DoSubmit(NewTaskFor(task));
		}

		/// <summary> 
		/// Submits a <see cref="Spring.Threading.IRunnable"/> task for execution 
		/// and returns a <see cref="IFuture{T}"/>
		/// representing that task.  Upon completion, this task may be taken or polled.
		/// </summary>
		/// <param name="task">the task to submit</param>
		/// <param name="result">the result to return upon successful completion</param>
		/// <returns> a <see cref="IFuture{T}"/> representing pending completion of the task,
		/// and whose <see cref="IFuture{T}.GetResult()"/> method will return the given result value
		/// upon completion
		/// </returns>
		/// <exception cref="Spring.Threading.Execution.RejectedExecutionException">if the task cannot be accepted for execution.</exception>
		/// <exception cref="System.ArgumentNullException">if the command is null</exception>
		public virtual IFuture<T> Submit(IRunnable task, T result)
		{
			if (task == null)
				throw new ArgumentNullException("task", "Task cannot be null.");
            return DoSubmit(NewTaskFor(task, result));
		}

        public virtual IFuture<T> Submit(IRunnableFuture<T> runnableFuture)
        {
            if (runnableFuture == null)
                throw new ArgumentNullException("runnableFuture");
            return DoSubmit(runnableFuture);
        }

        private IFuture<T> DoSubmit(IRunnableFuture<T> runnableFuture)
        {
            _executor.Execute(new QueueingFuture(this, runnableFuture));
            return runnableFuture;
        }

		/// <summary> 
		/// Retrieves and removes the <see cref="IFuture{T}"/> representing the next
		/// completed task, waiting if none are yet present.
		/// </summary>
		/// <returns> the <see cref="IFuture{T}"/> representing the next completed task
		/// </returns>
		public virtual IFuture<T> Take()
		{
			return _completionQueue.Take();
		}

		/// <summary> 
		/// Retrieves and removes the <see cref="IFuture{T}"/> representing the next
		/// completed task or <see lang="null"/> if none are present.
		/// </summary>
		/// <returns> the <see cref="IFuture{T}"/> representing the next completed task, or
		/// <see lang="null"/> if none are present.
		/// </returns>
		public virtual IFuture<T> Poll()
		{
		    IFuture<T> next;
            return _completionQueue.Poll(out next) ? null : next;
		}

		/// <summary> 
		/// Retrieves and removes the <see cref="IFuture{T}"/> representing the next
		/// completed task, waiting, if necessary, up to the specified duration
		/// if none are yet present.
		/// </summary>
		/// <param name="durationToWait">duration to wait if no completed task is present yet.</param>
		/// <returns> 
		/// the <see cref="IFuture{T}"/> representing the next completed task or
		/// <see lang="null"/> if the specified waiting time elapses before one
		/// is present.
		/// </returns>
		public virtual IFuture<T> Poll(TimeSpan durationToWait)
		{
		    IFuture<T> next;
		    return _completionQueue.Poll(durationToWait, out next) ? null : next;
		}
	}
}