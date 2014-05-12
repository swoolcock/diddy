#region License

/*
* Copyright (C) 2002-2009 the original author or authors.
* 
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
* 
*      http://www.apache.org/licenses/LICENSE-2.0
* 
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

#endregion

using System;
using System.Collections;
using System.Collections.Generic;
using System.Threading;
using Spring.Threading.Future;

namespace Spring.Threading.Execution
{
    /// <summary> 
    /// Provides default implementations of <see cref="Spring.Threading.Execution.IExecutorService"/>
    /// execution methods. 
    /// </summary>
    /// <remarks> 
    /// This class implements the <see cref="Spring.Threading.Execution.IExecutorService"/> methods using a
    /// <see cref="IRunnableFuture{T}"/> returned by NewTaskFor
    /// , which defaults to the <see cref="FutureTask{T}"/> class provided in this package.  
    /// <p/>
    /// For example, the implementation of <see cref="Spring.Threading.Execution.IExecutorService.Submit(IRunnable)"/> creates an
    /// associated <see cref="IRunnableFuture{T}"/> that is executed and
    /// returned. Subclasses may override the NewTaskFor methods
    /// to return <see cref="IRunnableFuture{T}"/> implementations other than
    /// <see cref="FutureTask{T}"/>.
    /// 
    /// <p/> 
    /// <b>Extension example</b>. 
    /// Here is a sketch of a class
    /// that customizes <see cref="Spring.Threading.Execution.ThreadPoolExecutor"/> to use
    /// a custom Task class instead of the default <see cref="FutureTask{T}"/>:
    /// <code>
    /// public class CustomThreadPoolExecutor : ThreadPoolExecutor {
    ///		class CustomTask : IRunnableFuture {...}
    /// 
    ///		protected IRunnableFuture newTaskFor(ICallable c) {
    ///			return new CustomTask(c);
    /// 	}
    ///		protected IRunnableFuture newTaskFor(IRunnable r) {
    /// 		return new CustomTask(r);
    /// 	}
    /// 	// ... add constructors, etc.
    /// }
    /// </code>
    /// </remarks>
    /// <author>Doug Lea</author>
    /// <author>Griffin Caprio(.NET)</author>
    /// <author>Kenneth Xu</author>
    public abstract class AbstractExecutorService : IExecutorService
    {
        #region Private Static Fields

        private static readonly TimeSpan NoTime = new TimeSpan(0);

        #endregion

        #region Abstract Methods

        /// <summary> 
        /// Initiates an orderly shutdown in which previously submitted
        /// tasks are executed, but no new tasks will be
        /// accepted. Invocation has no additional effect if already shut
        /// down.
        /// </summary>
        public abstract void Shutdown();

        /// <summary> 
        /// Attempts to stop all actively executing tasks, halts the
        /// processing of waiting tasks, and returns a list of the tasks that were
        /// awaiting execution.
        /// </summary>
        /// <remarks> 
        /// There are no guarantees beyond best-effort attempts to stop
        /// processing actively executing tasks.  For example, typical
        /// implementations will cancel via <see cref="System.Threading.Thread.Interrupt()"/>, so if any
        /// tasks mask or fail to respond to interrupts, they may never terminate.
        /// </remarks>
        /// <returns> list of tasks that never commenced execution</returns>
        public abstract IList<IRunnable> ShutdownNow();

        /// <summary> 
        /// Executes the given command at some time in the future.
        /// </summary>
        /// <remarks>
        /// The command may execute in a new thread, in a pooled thread, or in the calling
        /// thread, at the discretion of the <see cref="Spring.Threading.IExecutor"/> implementation.
        /// </remarks>
        /// <param name="runnable">the runnable task</param>
        /// <exception cref="Spring.Threading.Execution.RejectedExecutionException">if the task cannot be accepted for execution.</exception>
        /// <exception cref="System.ArgumentNullException">if the command is null</exception>	
        public abstract void Execute(IRunnable runnable);

        /// <summary> 
        /// Blocks until all tasks have completed execution after a shutdown
        /// request, or the timeout occurs, or the current thread is
        /// interrupted, whichever happens first. 
        /// </summary>
        /// <param name="timeSpan">the time span to wait.
        /// </param>
        /// <returns> <see lang="true"/> if this executor terminated and <see lang="false"/>
        /// if the timeout elapsed before termination
        /// </returns>
        public abstract bool AwaitTermination(TimeSpan timeSpan);

        /// <summary> 
        /// Returns <see lang="true"/> if all tasks have completed following shut down.
        /// </summary>
        /// <remarks>
        /// Note that this will never return <see lang="true"/> unless
        /// either <see cref="Spring.Threading.Execution.IExecutorService.Shutdown()"/> or 
        /// <see cref="Spring.Threading.Execution.IExecutorService.ShutdownNow()"/> was called first.
        /// </remarks>
        /// <returns> <see lang="true"/> if all tasks have completed following shut down
        /// </returns>
        public abstract bool IsTerminated { get; }

        /// <summary> 
        /// Returns <see lang="true"/> if this executor has been shut down.
        /// </summary>
        /// <returns> 
        /// Returns <see lang="true"/> if this executor has been shut down.
        /// </returns>
        public abstract bool IsShutdown { get; }

        #endregion

        #region IExecutor Implementation

        /// <summary> 
        /// Executes the given task at some time in the future.
        /// </summary>
        /// <remarks>
        /// The task may execute in a new thread, in a pooled thread, or in the calling
        /// thread, at the discretion of the <see cref="IExecutor"/> implementation.
        /// </remarks>
        /// <param name="task">The task to be executed.</param>
        /// <exception cref="Spring.Threading.Execution.RejectedExecutionException">
        /// If the task cannot be accepted for execution.
        /// </exception>
        /// <exception cref="System.ArgumentNullException">
        /// If the <paramref name="task"/> is <c>null</c>
        /// </exception>
        public virtual void Execute(Task task)
        {
            Execute(Executors.CreateRunnable(task));
        }

        #endregion

        #region IExecutorService Implementation

        public virtual IFuture<object> Submit(IRunnable runnable)
        {
            return Submit<object>(runnable, null);
        }

        public virtual IFuture<object> Submit(Task task)
        {
            return Submit<object>(task, null);
        }

        /// <summary> 
        /// Submits a delegate <see cref="Call{T}"/> for execution and returns a
        /// <see cref="IFuture{T}"/> representing that <paramref name="call"/>. 
        /// The <see cref="IFuture{T}.GetResult()"/> method will return the 
        /// result of <paramref name="call"/><c>()</c> upon successful completion.
        /// </summary>
        /// <param name="call">The task to submit.</param>
        /// <returns>
        /// An <see cref="IFuture{T}"/> representing pending completion of the
        /// <paramref name="call"/>.
        /// </returns>
        /// <exception cref="RejectedExecutionException">
        /// If the <paramref name="call"/> cannot be accepted for execution.
        /// </exception>
        /// <exception cref="ArgumentNullException">
        /// If the <paramref name="call"/> is <c>null</c>.
        /// </exception>
        public virtual IFuture<T> Submit<T>(Call<T> call)
        {
            if (call == null) throw new ArgumentNullException("call");
            return Submit(NewTaskFor(call));
        }
        
        /// <summary> 
        /// Submits a delegate <see cref="Task"/> for execution and returns a
        /// <see cref="IFuture{T}"/> representing that <paramref name="task"/>. 
        /// The <see cref="IFuture{T}.GetResult()"/> method will return the 
        /// given <paramref name="result"/> upon successful completion.
        /// </summary>
        /// <param name="task">The task to submit.</param>
        /// <param name="result">The result to return.</param>
        /// <returns>
        /// An <see cref="IFuture{T}"/> representing pending completion of the
        /// <paramref name="task"/>.
        /// </returns>
        /// <exception cref="RejectedExecutionException">
        /// If the <paramref name="task"/> cannot be accepted for execution.
        /// </exception>
        /// <exception cref="ArgumentNullException">
        /// If the <paramref name="task"/> is <c>null</c>.
        /// </exception>
        public virtual IFuture<T> Submit<T>(Task task, T result)
        {
            if (task == null) throw new ArgumentNullException("task");
            return Submit(NewTaskFor(task, result));
        }

        /// <summary> 
        /// Submits a <see cref="ICallable{T}"/> for execution and returns a
        /// <see cref="IFuture{T}"/> representing that <paramref name="callable"/>. 
        /// The <see cref="IFuture{T}.GetResult()"/> method will return the 
        /// result of <see cref="ICallable{T}.Call"/> upon successful completion.
        /// </summary>
        /// <param name="callable">The task to submit.</param>
        /// <returns>
        /// An <see cref="IFuture{T}"/> representing pending completion of the
        /// <paramref name="callable"/>.
        /// </returns>
        /// <exception cref="RejectedExecutionException">
        /// If the <paramref name="callable"/> cannot be accepted for execution.
        /// </exception>
        /// <exception cref="ArgumentNullException">
        /// If the <paramref name="callable"/> is <c>null</c>.
        /// </exception>
        public virtual IFuture<T> Submit<T>(ICallable<T> callable)
        {
            if (callable == null) throw new ArgumentNullException("callable");
            return Submit(NewTaskFor(callable));
        }

        /// <summary> 
        /// Submits a <see cref="IRunnable"/> task for execution and returns a
        /// <see cref="IFuture{T}"/> representing that <paramref name="runnable"/>. 
        /// The <see cref="IFuture{T}.GetResult()"/> method will return the 
        /// given <paramref name="result"/> upon successful completion.
        /// </summary>
        /// <param name="runnable">The task to submit.</param>
        /// <param name="result">The result to return.</param>
        /// <returns>
        /// An <see cref="IFuture{T}"/> representing pending completion of the
        /// <paramref name="runnable"/>.
        /// </returns>
        /// <exception cref="RejectedExecutionException">
        /// If the <paramref name="runnable"/> cannot be accepted for execution.
        /// </exception>
        /// <exception cref="ArgumentNullException">
        /// If the <paramref name="runnable"/> is <c>null</c>.
        /// </exception>
        public virtual IFuture<T> Submit<T>(IRunnable runnable, T result)
        {
            if (runnable == null) throw new ArgumentNullException("runnable");
            return Submit(NewTaskFor(runnable, result));
        }

        /// <summary> 
        /// Executes the given <paramref name="tasks"/>, returning the result
        /// of one that has completed successfully (i.e., without throwing
        /// an exception), if any do. 
        /// </summary>
        /// <remarks>
        /// Upon normal or exceptional return, <paramref name="tasks"/> that 
        /// have not completed are cancelled.
        /// The results of this method are undefined if the given
        /// enumerable is modified while this operation is in progress.
        /// </remarks>
        /// <typeparam name="T">
        /// The type of the result to be returned.
        /// </typeparam>
        /// <param name="tasks">
        /// The <see cref="ICollection{T}">collection</see> of 
        /// <see cref="ICallable{T}"/> objects.
        /// </param>
        /// <returns>The result returned by one of the tasks.</returns>
        /// <exception cref="RejectedExecutionException">
        /// If the any of the <paramref name="tasks"/> cannot be accepted for 
        /// execution.
        /// </exception>
        /// <exception cref="System.ArgumentNullException">
        /// If the <paramref name="tasks"/> is <c>null</c>.
        /// </exception>
        public virtual T InvokeAny<T>(IEnumerable<ICallable<T>> tasks)
        {
            ICollection<ICallable<T>> collection = tasks as ICollection<ICallable<T>>;
            int count = collection == null ? 0 : collection.Count;
            return DoInvokeAny(tasks, count, false, NoTime, Call2Future<T>());
        }

        /// <summary> 
        /// Executes the given <paramref name="tasks"/>, returning the result
        /// of one that has completed successfully (i.e., without throwing
        /// an exception), if any do. 
        /// </summary>
        /// <remarks>
        /// Upon normal or exceptional return, <paramref name="tasks"/> that 
        /// have not completed are cancelled.
        /// The results of this method are undefined if the given
        /// enumerable is modified while this operation is in progress.
        /// </remarks>
        /// <typeparam name="T">
        /// The type of the result to be returned.
        /// </typeparam>
        /// <param name="tasks">
        /// The <see cref="ICollection{T}">collection</see> of 
        /// <see cref="Call{T}"/> delegates.
        /// </param>
        /// <returns>The result returned by one of the tasks.</returns>
        /// <exception cref="RejectedExecutionException">
        /// If the any of the <paramref name="tasks"/> cannot be accepted for 
        /// execution.
        /// </exception>
        /// <exception cref="System.ArgumentNullException">
        /// If the <paramref name="tasks"/> is <c>null</c>.
        /// </exception>
        public virtual T InvokeAny<T>(IEnumerable<Call<T>> tasks)
        {
            ICollection<Call<T>> collection = tasks as ICollection<Call<T>>;
            int count = collection == null ? 0 : collection.Count;
            return DoInvokeAny(tasks, count, false, NoTime, Call2Future<T>());
        }

        /// <summary> 
        /// Executes the given <paramref name="tasks"/>, returning the result
        /// of one that has completed successfully (i.e., without throwing
        /// an exception), if any do before the given 
        /// <paramref name="durationToWait"/> elapses.
        /// </summary>
        /// <remarks>
        /// Upon normal or exceptional return, <paramref name="tasks"/> that 
        /// have not completed are cancelled.
        /// The results of this method are undefined if the given
        /// enumerable is modified while this operation is in progress.
        /// </remarks>
        /// <typeparam name="T">
        /// The type of the result to be returned.
        /// </typeparam>
        /// <param name="tasks">
        /// The <see cref="ICollection{T}">collection</see> of 
        /// <see cref="ICallable{T}"/> objects.
        /// </param>
        /// <param name="durationToWait">The time span to wait.</param> 
        /// <returns>The result returned by one of the tasks.</returns>
        /// <exception cref="RejectedExecutionException">
        /// If the any of the <paramref name="tasks"/> cannot be accepted for 
        /// execution.
        /// </exception>
        /// <exception cref="System.ArgumentNullException">
        /// If the <paramref name="tasks"/> is <c>null</c>.
        /// </exception>
        public virtual T InvokeAny<T>(IEnumerable<ICallable<T>> tasks, TimeSpan durationToWait)
        {
            ICollection<ICallable<T>> collection = tasks as ICollection<ICallable<T>>;
            int count = collection == null ? 0 : collection.Count;
            return DoInvokeAny(tasks, count, true, durationToWait, Callable2Future<T>());
        }

        /// <summary> 
        /// Executes the given <paramref name="tasks"/>, returning the result
        /// of one that has completed successfully (i.e., without throwing
        /// an exception), if any do before the given 
        /// <paramref name="durationToWait"/> elapses.
        /// </summary>
        /// <remarks>
        /// Upon normal or exceptional return, <paramref name="tasks"/> that 
        /// have not completed are cancelled.
        /// The results of this method are undefined if the given
        /// enumerable is modified while this operation is in progress.
        /// </remarks>
        /// <typeparam name="T">
        /// The type of the result to be returned.
        /// </typeparam>
        /// <param name="tasks">
        /// The <see cref="ICollection{T}">collection</see> of 
        /// <see cref="Call{T}"/> delegates.
        /// </param>
        /// <param name="durationToWait">The time span to wait.</param> 
        /// <returns>The result returned by one of the tasks.</returns>
        /// <exception cref="RejectedExecutionException">
        /// If the any of the <paramref name="tasks"/> cannot be accepted for 
        /// execution.
        /// </exception>
        /// <exception cref="System.ArgumentNullException">
        /// If the <paramref name="tasks"/> is <c>null</c>.
        /// </exception>
        public virtual T InvokeAny<T>(IEnumerable<Call<T>> tasks, TimeSpan durationToWait)
        {
            ICollection<Call<T>> collection = tasks as ICollection<Call<T>>;
            int count = collection == null ? 0 : collection.Count;
            return DoInvokeAny(tasks, count, true, durationToWait, Call2Future<T>());
        }

        /// <summary> 
        /// Executes the given <paramref name="tasks"/>, returning a 
        /// <see cref="IList{T}">list</see> of <see cref="IFuture{T}"/>s 
        /// holding their status and results when all complete.
        /// </summary>
        /// <remarks>
        /// <para>
        /// <see cref="ICancellable.IsDone"/> is <c>true</c> for each element of 
        /// the returned list.
        /// </para>
        /// <para>
        /// Note: 
        /// A <b>completed</b> task could have
        /// terminated either normally or by throwing an exception.
        /// The results of this method are undefined if the given
        /// enumerable is modified while this operation is in progress.
        /// </para>
        /// </remarks>
        /// <typeparam name="T">
        /// The type of the result to be returned by <see cref="IFuture{T}"/>.
        /// </typeparam>
        /// <param name="tasks">
        /// The <see cref="IEnumerable{T}">enumeration</see> of 
        /// <see cref="ICallable{T}"/> objects.
        /// </param>
        /// <returns>
        /// A list of <see cref="IFuture{T}"/>s representing the tasks, in the 
        /// same sequential order as produced by the iterator for the given 
        /// task list, each of which has completed.
        /// </returns>
        /// <exception cref="RejectedExecutionException">
        /// If the any of the <paramref name="tasks"/> cannot be accepted for 
        /// execution.
        /// </exception>
        /// <exception cref="System.ArgumentNullException">
        /// If the <paramref name="tasks"/> is <c>null</c>.
        /// </exception>
	    public virtual IList<IFuture<T>> InvokeAll<T>(IEnumerable<ICallable<T>> tasks)
        {
            ICollection<ICallable<T>> collection = tasks as ICollection<ICallable<T>>;
            int count = collection == null ? 0 : collection.Count;
            return DoInvokeAll(tasks, count, Callable2Future<T>());
        }

        /// <summary> 
        /// Executes the given <paramref name="tasks"/>, returning a 
        /// <see cref="IList{T}">list</see> of <see cref="IFuture{T}"/>s 
        /// holding their status and results when all complete.
        /// </summary>
        /// <remarks>
        /// <para>
        /// <see cref="ICancellable.IsDone"/> is <c>true</c> for each element of 
        /// the returned list.
        /// </para>
        /// <para>
        /// Note: 
        /// A <b>completed</b> task could have
        /// terminated either normally or by throwing an exception.
        /// The results of this method are undefined if the given
        /// enumerable is modified while this operation is in progress.
        /// </para>
        /// </remarks>
        /// <typeparam name="T">
        /// The type of the result to be returned by <see cref="IFuture{T}"/>.
        /// </typeparam>
        /// <param name="tasks">
        /// The <see cref="IEnumerable{T}">enumeration</see> of 
        /// <see cref="Call{T}"/> delegates.
        /// </param>
        /// <returns>
        /// A list of <see cref="IFuture{T}"/>s representing the tasks, in the 
        /// same sequential order as produced by the iterator for the given 
        /// task list, each of which has completed.
        /// </returns>
        /// <exception cref="RejectedExecutionException">
        /// If the any of the <paramref name="tasks"/> cannot be accepted for 
        /// execution.
        /// </exception>
        /// <exception cref="System.ArgumentNullException">
        /// If the <paramref name="tasks"/> is <c>null</c>.
        /// </exception>
	    public virtual IList<IFuture<T>> InvokeAll<T>(IEnumerable<Call<T>> tasks)
        {
            ICollection<Call<T>> collection = tasks as ICollection<Call<T>>;
            int count = collection == null ? 0 : collection.Count;
            return DoInvokeAll(tasks, count, Call2Future<T>());
        }

        /// <summary> 
        /// Executes the given <paramref name="tasks"/>, returning a 
        /// <see cref="IList{T}">list</see> of <see cref="IFuture{T}"/>s 
        /// holding their status and results when all complete or the
        /// <paramref name="durationToWait"/> expires, whichever happens
        /// first.
        /// </summary>
        /// <remarks>
        /// <para>
        /// <see cref="ICancellable.IsDone"/> is <c>true</c> for each element of 
        /// the returned list.
        /// </para>
        /// <para>
        /// Note: 
        /// A <b>completed</b> task could have
        /// terminated either normally or by throwing an exception.
        /// The results of this method are undefined if the given
        /// enumerable is modified while this operation is in progress.
        /// </para>
        /// </remarks>
        /// <typeparam name="T">
        /// The type of the result to be returned by <see cref="IFuture{T}"/>.
        /// </typeparam>
        /// <param name="tasks">
        /// The <see cref="IEnumerable{T}">enumeration</see> of 
        /// <see cref="ICallable{T}"/> objects.
        /// </param>
        /// <param name="durationToWait">The time span to wait.</param> 
        /// <returns>
        /// A list of <see cref="IFuture{T}"/>s representing the tasks, in the 
        /// same sequential order as produced by the iterator for the given 
        /// task list. If the operation did not time out, each task will
        /// have completed. If it did time out, some of these tasks will
        /// not have completed.
        /// </returns>
        /// <exception cref="RejectedExecutionException">
        /// If the any of the <paramref name="tasks"/> cannot be accepted for 
        /// execution.
        /// </exception>
        /// <exception cref="System.ArgumentNullException">
        /// If the <paramref name="tasks"/> is <c>null</c>.
        /// </exception>
	    public virtual IList<IFuture<T>> InvokeAll<T>(IEnumerable<ICallable<T>> tasks, TimeSpan durationToWait)
        {
            ICollection<ICallable<T>> collection = tasks as ICollection<ICallable<T>>;
            int count = collection == null ? 0 : collection.Count;
            return DoInvokeAll(tasks, count, durationToWait, Callable2Future<T>());
        }

        /// <summary> 
        /// Executes the given <paramref name="tasks"/>, returning a 
        /// <see cref="IList{T}">list</see> of <see cref="IFuture{T}"/>s 
        /// holding their status and results when all complete or the
        /// <paramref name="durationToWait"/> expires, whichever happens
        /// first.
        /// </summary>
        /// <remarks>
        /// <para>
        /// <see cref="ICancellable.IsDone"/> is <c>true</c> for each element of 
        /// the returned list.
        /// </para>
        /// <para>
        /// Note: 
        /// A <b>completed</b> task could have
        /// terminated either normally or by throwing an exception.
        /// The results of this method are undefined if the given
        /// enumerable is modified while this operation is in progress.
        /// </para>
        /// </remarks>
        /// <typeparam name="T">
        /// The type of the result to be returned by <see cref="IFuture{T}"/>.
        /// </typeparam>
        /// <param name="tasks">
        /// The <see cref="IEnumerable{T}">enumeration</see> of 
        /// <see cref="Call{T}"/> delegates.
        /// </param>
        /// <param name="durationToWait">The time span to wait.</param> 
        /// <returns>
        /// A list of <see cref="IFuture{T}"/>s representing the tasks, in the 
        /// same sequential order as produced by the iterator for the given 
        /// task list. If the operation did not time out, each task will
        /// have completed. If it did time out, some of these tasks will
        /// not have completed.
        /// </returns>
        /// <exception cref="RejectedExecutionException">
        /// If the any of the <paramref name="tasks"/> cannot be accepted for 
        /// execution.
        /// </exception>
        /// <exception cref="System.ArgumentNullException">
        /// If the <paramref name="tasks"/> is <c>null</c>.
        /// </exception>
	    public virtual IList<IFuture<T>> InvokeAll<T>(IEnumerable<Call<T>> tasks, TimeSpan durationToWait)
        {
            ICollection<Call<T>> collection = tasks as ICollection<Call<T>>;
            int count = collection == null ? 0 : collection.Count;
            return DoInvokeAll(tasks, count, durationToWait, Call2Future<T>());
        }

        #endregion

        /// <summary> 
        /// Returns a <see cref="IRunnableFuture{T}"/> for the given runnable and default
        /// value.
        /// </summary>
        /// <param name="runnable">the runnable task being wrapped
        /// </param>
        /// <param name="result">the default value for the returned future
        /// </param>
        /// <returns>
        /// A <see cref="IRunnableFuture{T}"/> which, when run, will run the
        /// underlying runnable and which, as a <see cref="IFuture{T}"/>, will yield
        /// the given value as its result and provide for cancellation of
        /// the underlying task.
        /// </returns>
        protected internal virtual IRunnableFuture<T> NewTaskFor<T>(IRunnable runnable, T result)
        {
            return new FutureTask<T>(runnable, result);
        }

        protected internal virtual IRunnableFuture<T> NewTaskFor<T>(Task task, T result)
        {
            return new FutureTask<T>(task, result);
        }

        /// <summary> 
        /// Returns a <see cref="IRunnableFuture{T}"/> for the given 
        /// <paramref name="call"/> delegate.
        /// </summary>
        /// <param name="call">
        /// The <see cref="Call{T}"/> delegate being wrapped.
        /// </param>
        /// <returns>
        /// An <see cref="IRunnableFuture{T}"/> which when run will call the
        /// underlying <paramref name="call"/> delegate and which, as a 
        /// <see cref="IFuture{T}"/>, will yield the result of <c>call</c>as 
        /// its result and provide for cancellation of the underlying task.
        /// </returns>
        protected internal virtual IRunnableFuture<T> NewTaskFor<T>(Call<T> call)
        {
            return new FutureTask<T>(call);
        }

        /// <summary> 
        /// Returns a <see cref="IRunnableFuture{T}"/> for the given 
        /// <paramref name="callable"/> task.
        /// </summary>
        /// <param name="callable">The callable task being wrapped.</param>
        /// <returns>
        /// An <see cref="IRunnableFuture{T}"/> which when run will call the
        /// underlying <paramref name="callable"/> and which, as a 
        /// <see cref="IFuture{T}"/>, will yield the callable's result as its 
        /// result and provide for cancellation of the underlying task.
        /// </returns>
        protected internal virtual IRunnableFuture<T> NewTaskFor<T>(ICallable<T> callable)
        {
            return new FutureTask<T>(callable);
        }

        private Converter<object, IRunnableFuture<T>> Callable2Future<T>()
        {
            return delegate(object callable) { return NewTaskFor((ICallable<T>)callable); };
        }

        private Converter<object, IRunnableFuture<T>> Call2Future<T>()
        {
            return delegate(object call) { return NewTaskFor((Call<T>)call); };
        }

        private IFuture<T> Submit<T>(IRunnableFuture<T> runnableFuture)
        {
            Execute(runnableFuture);
            return runnableFuture;
        }

        private T DoInvokeAny<T>(IEnumerable tasks, int count, bool timed, TimeSpan durationToWait, Converter<object, IRunnableFuture<T>> converter)
        {
            if (tasks == null)
                throw new ArgumentNullException("tasks");
            List<IFuture<T>> futures = count > 0 ? new List<IFuture<T>>(count) : new List<IFuture<T>>();
			ExecutorCompletionService<T> ecs = new ExecutorCompletionService<T>(this);
			TimeSpan duration = durationToWait;

            // For efficiency, especially in executors with limited
            // parallelism, check to see if previously submitted tasks are
            // done before submitting more of them. This interleaving
            // plus the exception mechanics account for messiness of main
            // loop.

            try
            {
                // Record exceptions so that if we fail to obtain any
                // result, we can throw the last exception we got.
                ExecutionException ee = null;
				DateTime lastTime = (timed) ? DateTime.Now : new DateTime(0);
                IEnumerator it = tasks.GetEnumerator();
			    bool hasMoreTasks = it.MoveNext();
                if (!hasMoreTasks)
                    throw new ArgumentException("No tasks passed in.");
                futures.Add(ecs.Submit(converter(it.Current)));
				int active = 1;

                for (;;)
                {
                    IFuture<T> f = ecs.Poll();
                    if (f == null)
                    {
                        if (hasMoreTasks && (hasMoreTasks = it.MoveNext()))
                        {
                            futures.Add(ecs.Submit(converter(it.Current)));
                            ++active;
                        }
                        else if (active == 0)
                            break;
                        else if (timed)
                        {
                            f = ecs.Poll(duration);
                            if (f == null)
                                throw new TimeoutException();
                            //TODO: done't understand what are we doing here. Useless!? -K.X.
                            duration = duration.Subtract(DateTime.Now.Subtract(lastTime));
                            lastTime = DateTime.Now;
                        }
                        else
                            f = ecs.Take();
                    }
                    if (f != null)
                    {
                        --active;
                        try
                        {
                            return f.GetResult();
                        }
                        catch (ThreadInterruptedException)
                        {
                            throw;
                        }
                        catch (ExecutionException eex)
                        {
                            ee = eex;
                        }
                        catch (SystemException rex)
                        {
                            ee = new ExecutionException(rex);
                        }
                    }
                }

                if (ee == null)
                    ee = new ExecutionException();
                throw ee;
            }
            finally
            {
                foreach (IFuture<T> future in futures)
                {
                    future.Cancel(true);
                }
            }
        }

        private List<IFuture<T>> DoInvokeAll<T>(IEnumerable tasks, int count, Converter<object, IRunnableFuture<T>> converter)
        {
            if (tasks == null)
                throw new ArgumentNullException("tasks");
			List<IFuture<T>> futures = count > 0 ?  new List<IFuture<T>>(count) : new List<IFuture<T>>();
            bool done = false;
            try
            {
                foreach (object task in tasks)
                {
                    IRunnableFuture<T> runnableFuture = converter(task);
                    futures.Add(runnableFuture);
                    Execute(runnableFuture);
                }
                foreach (IFuture<T> future in futures)
                {
                    if (!future.IsDone)
                    {
                        try
                        {
                            future.GetResult();
                        }
                        catch (CancellationException)
                        {
                        }
                        catch (ExecutionException)
                        {
                        }
                    }
                }
                done = true;
                return futures;
            }
            finally
            {
                if (!done)
                {
                    foreach (IFuture<T> future in futures)
                    {
                        future.Cancel(true);
                    }
                }
            }
        }

        private List<IFuture<T>> DoInvokeAll<T>(IEnumerable tasks, int count, TimeSpan durationToWait, Converter<object, IRunnableFuture<T>> converter)
        {
            if (tasks == null)
                throw new ArgumentNullException("tasks");
            TimeSpan duration = durationToWait;
            List<IFuture<T>> futures = count > 0 ? new List<IFuture<T>>(count) : new List<IFuture<T>>();
            bool done = false;
            try
            {
                foreach (object task in tasks)
                {
                    futures.Add(converter(task));
                }

                DateTime lastTime = DateTime.Now;

                // Interleave time checks and calls to execute in case
                // executor doesn't have any/much parallelism.
                foreach (IRunnable runnable in futures)
                {
                    Execute(runnable);

                    duration = duration.Subtract(DateTime.Now.Subtract(lastTime));
                    lastTime = DateTime.Now;
                    if (duration.Ticks <= 0)
                        return futures;
                }

                foreach (IFuture<T> future in futures)
                {
                    if (!future.IsDone)
                    {
                        if (duration.Ticks <= 0)
                            return futures;
                        try
                        {
                            future.GetResult(duration);
                        }
                        catch (CancellationException)
                        {
                        }
                        catch (ExecutionException)
                        {
                        }
                        catch (TimeoutException)
                        {
                            return futures;
                        }

                        duration = duration.Subtract(DateTime.Now.Subtract(lastTime));
                        lastTime = DateTime.Now;
                    }
                }
                done = true;
                return futures;
            }
            finally
            {
                if (!done)
                {
                    foreach (IFuture<T> future in futures)
                    {
                        future.Cancel(true);
                    }
                }
            }
        }
    }
}