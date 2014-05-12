#region License

/*
* Copyright (C)2008-2009 the original author or authors.
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

namespace Spring.Threading
{
    /// <summary>
    /// Class to convert <see cref="Task"/> to <see cref="IRunnable"/>.
    /// </summary>
    /// <author>Kenneth Xu</author>
    public class Runnable : IRunnable
    {
        private readonly Task _task;

        /// <summary>
        /// Construct a new instance of <see cref="Runnable"/> which calls
        /// <paramref name="task"/> delegate with its <see cref="Run"/> method
        /// is invoked.
        /// </summary>
        /// <param name="task">
        /// The delegate to be called when <see cref="Run"/> is invoked.
        /// </param>
        public Runnable(Task task)
        {
            if (task == null) throw new ArgumentNullException("task");
            _task = task;
        }

        #region IRunnable Members

        /// <summary>
        /// The entry point. Invokes the delegate passed to the constructor
        /// <see cref="Runnable(Task)"/>.
        /// </summary>
        public void Run()
        {
            _task();
        }

        #endregion

        /// <summary>
        /// Implicitly converts <see cref="Task"/> delegate to an instance
        /// of <see cref="Runnable"/>.
        /// </summary>
        /// <param name="task">
        /// The delegate to be converted to <see cref="Runnable"/>.
        /// </param>
        /// <returns>
        /// An instance of <see cref="Runnable"/> based on <paramref name="task"/>.
        /// </returns>
        public static implicit operator Runnable(Task task)
        {
            return task == null ? null : new Runnable(task);
        }

        /// <summary>
        /// Implicitly converts <see cref="Runnable"/> to <see cref="Task"/>
        /// delegate.
        /// </summary>
        /// <param name="runnable">
        /// The callable to be converted to <see cref="Task"/>.
        /// </param>
        /// <returns>
        /// The original <see cref="Task"/> delegate used to construct the
        /// <paramref name="runnable"/>.
        /// </returns>
        public static implicit operator Task(Runnable runnable)
        {
            return runnable == null ? null : runnable._task;
        }
    }
}
