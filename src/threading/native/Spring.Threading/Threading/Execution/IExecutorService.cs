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
using Spring.Threading.Future;
using System.Collections.Generic;

namespace Spring.Threading.Execution
{
	/// <summary> 
	/// An <see cref="Spring.Threading.IExecutor"/> that provides methods to manage termination and
	/// methods that can produce a <see cref="IFuture{T}"/> for tracking progress of
	/// one or more asynchronous tasks.
	/// </summary>
	/// <remarks>
	/// An <see cref="Spring.Threading.Execution.IExecutorService"/> can be shut down, which will cause it
	/// to stop accepting new tasks.  After being shut down, the executor
	/// will eventually terminate, at which point no tasks are actively
	/// executing, no tasks are awaiting execution, and no new tasks can be
	/// submitted.
	/// 
	/// <p/> 
	/// Method <see cref="Submit{T}(ICallable{T})"/> extends base method 
	/// <see cref="Spring.Threading.IExecutor.Execute(IRunnable)"/> by creating and returning a <see cref="IFuture{T}"/> that
	/// can be used to cancel execution and/or wait for completion.
    /// Methods <see cref="InvokeAny{T}(IEnumerable{ICallable{T}})"/> and <see cref="InvokeAll{T}(IEnumerable{ICallable{T}})"/>
	/// perform the most commonly useful forms of bulk execution, executing a collection of
	/// tasks and then waiting for at least one, or all, to
	/// complete. (Class <see cref="ExecutorCompletionService{T}"/> can be used to
	/// write customized variants of these methods.)
	/// 
	/// <p/>
	/// The <see cref="Spring.Threading.Execution.Executors"/> class provides factory methods for the
	/// executor services provided in this package.
	/// </remarks>
	/// <author>Doug Lea</author>
	/// <author>Griffin Caprio (.NET)</author>
	/// <author>Kenneth Xu</author>
	public interface IExecutorService : IExecutor
	{
		/// <summary> 
		/// Returns <see lang="true"/> if this executor has been shut down.
		/// </summary>
		/// <returns> 
		/// Returns <see lang="true"/> if this executor has been shut down.
		/// </returns>
		bool IsShutdown { get; }

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
		bool IsTerminated { get; }

		/// <summary> 
		/// Initiates an orderly shutdown in which previously submitted
		/// tasks are executed, but no new tasks will be
		/// accepted. Invocation has no additional effect if already shut
		/// down.
		/// </summary>
		void Shutdown();

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
        IList<IRunnable> ShutdownNow();

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
		bool AwaitTermination(TimeSpan timeSpan);

		/// <summary> Submits a Runnable task for execution and returns a Future
        /// representing that task. The Future's <see cref="M:Spring.Threading.Future.IFuture.GetResult"/> method will
		/// return <see lang="null"/> upon successful completion.
		/// </summary>
		/// <param name="runnable">the task to submit
		/// </param>
		/// <returns> a Future representing pending completion of the task
		/// </returns>
		/// <exception cref="Spring.Threading.Execution.RejectedExecutionException">if the task cannot be accepted for execution.</exception>
		/// <exception cref="System.ArgumentNullException">if the command is null</exception>
		IFuture<object> Submit(IRunnable runnable);

        /// <summary> 
        /// Submits a delegate <see cref="Task"/> for execution and returns an
        /// <see cref="IFuture{T}"/> representing that <paramref name="task"/>. The 
        /// <see cref="IFuture{T}.GetResult()"/> method will return <c>null</c>.
        /// </summary>
        /// <param name="task">The task to submit.</param>
        /// <returns>
        /// An <see cref="IFuture{T}"/> representing pending completion of the 
        /// <paramref name="task"/>.
        /// </returns>
        /// <exception cref="RejectedExecutionException">
        /// If the <paramref name="task"/> cannot be accepted for execution.
        /// </exception>
        /// <exception cref="ArgumentNullException">
        /// If the <paramref name="task"/> is <c>null</c>
        /// </exception>
        IFuture<object> Submit(Task task);

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
        IFuture<T> Submit<T>(IRunnable runnable, T result);

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
        IFuture<T> Submit<T>(Task task, T result);

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
        IFuture<T> Submit<T>(ICallable<T> callable);

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
        IFuture<T> Submit<T>(Call<T> call);

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
        IList<IFuture<T>> InvokeAll<T>(IEnumerable<ICallable<T>> tasks);

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
        IList<IFuture<T>> InvokeAll<T>(IEnumerable<Call<T>> tasks);

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
        IList<IFuture<T>> InvokeAll<T>(IEnumerable<ICallable<T>> tasks, TimeSpan durationToWait);

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
        IList<IFuture<T>> InvokeAll<T>(IEnumerable<Call<T>> tasks, TimeSpan durationToWait);

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
        T InvokeAny<T>(IEnumerable<ICallable<T>> tasks);

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
        T InvokeAny<T>(IEnumerable<Call<T>> tasks);

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
        T InvokeAny<T>(IEnumerable<ICallable<T>> tasks, TimeSpan durationToWait);

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
        T InvokeAny<T>(IEnumerable<Call<T>> tasks, TimeSpan durationToWait);
    }
}