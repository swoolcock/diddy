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

/*
File: LockedExecutor.java

Originally written by Doug Lea and released into the public domain.
This may be used for any purposes whatsoever without acknowledgment.
Thanks for the assistance and support of Sun Microsystems Labs,
and everyone contributing, testing, and using this code.

History:
Date       Who                What
21Jun1998  dl               Create public version*/
using Spring.Threading;

namespace Spring.Threading
{
	/// <summary> An implementation of Executor that 
	/// invokes the run method of the supplied command within
	/// a synchronization lock and then returns.
	/// </summary>
	public class LockedExecutor : IExecutor
	{
		
		/// <summary>The mutex *</summary>
		protected readonly internal ISync mutex_;
		
		/// <summary> Create a new LockedExecutor that relies on the given mutual
		/// exclusion lock. 
		/// </summary>
		/// <param name="mutex">Any mutual exclusion lock.
		/// Standard usage is to supply an instance of <code>Mutex</code>,
		/// but, for example, a Semaphore initialized to 1 also works.
		/// On the other hand, many other ISync implementations would not
		/// work here, so some care is required to supply a sensible 
		/// synchronization object.
		/// 
		/// </param>
		
		public LockedExecutor(ISync mutex)
		{
			mutex_ = mutex;
		}
		
		/// <summary> Execute the given command directly in the current thread,
		/// within the supplied lock.
		/// </summary>
		public virtual void  Execute(IRunnable command)
		{
			mutex_.Acquire();
			try
			{
				command.Run();
			}
			finally
			{
				mutex_.Release();
			}
		}
        /// <summary>
        /// Execute the given task directly in the current thread,
        /// within the supplied lock.
        /// </summary>
        /// <param name="task">The task to be executed.</param>
        public virtual void Execute(Task task)
        {
            Execute(Spring.Threading.Execution.Executors.CreateRunnable(task));
        }

	}
}