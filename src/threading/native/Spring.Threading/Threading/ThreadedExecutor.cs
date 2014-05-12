#region License
/*
* Copyright ?2002-2005 the original author or authors.
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
using System.Threading;

namespace Spring.Threading
{
	
    /// <summary> 
    /// An implementation of Executor that creates a new
    /// Thread that invokes the run method of the supplied command.
    /// </summary>
    public class ThreadedExecutor:ThreadFactoryUser, IExecutor
    {
		
        /// <summary> 
        /// Execute the given command in a new thread.
        /// </summary>
        public virtual void  Execute(IRunnable runnable)
        {
            lock (this)
            {
                Utils.FailFastIfInterrupted();			
				
                Thread thread = ThreadFactory.NewThread(runnable);
                thread.Start();
            }
        }

        /// <summary>
        /// Execute the given <paramref name="task"/> in a new thread.
        /// </summary>
        /// <param name="task">The task to be executed.</param>
        public virtual void Execute(Task task)
        {
            Execute(Spring.Threading.Execution.Executors.CreateRunnable(task));
        }
    }
}