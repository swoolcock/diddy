#region License
/*
* Copyright © 2002-2005 the original author or authors.
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
    /// Base class for Executors and related classes that rely on thread factories.
    /// Generally intended to be used as a mixin-style abstract class, but
    /// can also be used stand-alone.
    /// </summary>
	
    public class ThreadFactoryUser
    {		
        /// <summary>
        /// the <see cref="IThreadFactory"/> used by this instance
        /// </summary>
        protected internal IThreadFactory threadFactory_ = new DefaultThreadFactory();
		
        /// <summary>
        /// The thread factory that intantiates standard <see cref="Thread"/>
        /// objects
        /// </summary>
        protected internal class DefaultThreadFactory : IThreadFactory
        {
            /// <summary>
            /// A sort of factory method that creates intances of 
            /// <see cref="Thread"/> that will run the given runnable object
            /// </summary>
            /// <param name="runnable">the runnable object to start</param>
            /// <returns>new Thread(new ThreadStart(runnable.Run))</returns>
            public virtual Thread NewThread(IRunnable runnable)
            {
                return new Thread(new ThreadStart(runnable.Run));
            }
        }
		
        /// <summary> The factory for creating new threads.
        /// By default, new threads are created without any special priority,
        /// threadgroup, or status parameters.
        /// You can use a different factory
        /// to change the kind of Thread class used or its construction
        /// parameters.
        /// </summary>		
        public virtual IThreadFactory ThreadFactory
        {
            set
            {
                lock (this)
                {
                    threadFactory_ = value;
                }
            }
            get
            {
                lock (this)
                {
                    return threadFactory_;
                }
            }
        }
    }
}