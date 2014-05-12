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
Originally written by Doug Lea and released into the public domain.
This may be used for any purposes whatsoever without acknowledgment.
Thanks for the assistance and support of Sun Microsystems Labs,
and everyone contributing, testing, and using this code.
*/

namespace Spring.Threading
{
	
    /// <summary> 
    /// An implementation of <see cref="IExecutor"/> that 
    /// invokes the run method of the supplied command and then returns.
    /// </summary>
    public class DirectExecutor : IExecutor
    {
        /// <summary> Execute the given command directly in the current thread.
        /// 
        /// </summary>
        public virtual void Execute(IRunnable runnable)
        {
            Utils.FailFastIfInterrupted();			
            runnable.Run();
        }

        /// <summary>
        /// Execute the given task directly in the current thread.
        /// </summary>
        /// <param name="task">
        /// The task to be executed.
        /// </param>
        public virtual void Execute(Task task)
        {
            Utils.FailFastIfInterrupted();
            task();
        }
    }
}