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
File: PrioritySemaphore.java

Originally written by Doug Lea and released into the public domain.
This may be used for any purposes whatsoever without acknowledgment.
Thanks for the assistance and support of Sun Microsystems Labs,
and everyone contributing, testing, and using this code.

History:
Date       Who                What
11Jun1998  dl               Create public version*/
using System.Threading;

namespace Spring.Threading
{
	
	/// <summary> A Semaphore that grants requests to threads with higher
	/// Thread priority rather than lower priority when there is
	/// contention. Ordering of requests with the same priority
	/// is approximately FIFO.
	/// Priorities are based on Thread.getPriority.
	/// Changing the priority of an already-waiting thread does NOT 
	/// change its ordering. This class also does not specially deal with priority
	/// inversion --  when a new high-priority thread enters
	/// while a low-priority thread is currently running, their
	/// priorities are <em>not</em> artificially manipulated.
	/// </summary>
	
	public class PrioritySemaphore:QueuedSemaphore
	{
		
		/// <summary> Create a Semaphore with the given initial number of permits.
		/// Using a seed of one makes the semaphore act as a mutual exclusion lock.
		/// Negative seeds are also allowed, in which case no acquires will proceed
		/// until the number of releases has pushed the number of permits past 0.
		/// 
		/// </summary>
		
		
		public PrioritySemaphore(long initialPermits):base(new PriorityWaitQueue(), initialPermits)
		{
		}
		
        /// <summary>
        /// Class to used back <see cref="PrioritySemaphore"/>
        /// </summary>
		protected internal class PriorityWaitQueue:WaitQueue
		{						
			/// <summary>An array of wait queues, one per priority *</summary>
			internal readonly FIFOSemaphore.FIFOWaitQueue[] cells_ = new FIFOSemaphore.FIFOWaitQueue[(int) System.Threading.ThreadPriority.Highest - (int) System.Threading.ThreadPriority.Lowest + 1];
			
			/// <summary> The index of the highest priority cell that may need to be signalled,
			/// or -1 if none. Used to minimize array traversal.
			/// 
			/// </summary>
			
			protected internal int maxIndex_ = - 1;
			
            /// <summary>
            /// Creates a new <see cref="PriorityWaitQueue"/> instance.
            /// </summary>
			protected internal PriorityWaitQueue()
			{
				for (int i = 0; i < cells_.Length; ++i)
					cells_[i] = new FIFOSemaphore.FIFOWaitQueue();
			}
			
			internal override void Insert(WaitNode w)
			{
				int idx = (System.Int32) Thread.CurrentThread.Priority - (int) System.Threading.ThreadPriority.Lowest;
			    cells_[idx].Insert(w);
				if (idx > maxIndex_)
					maxIndex_ = idx;
			}
			
			internal override WaitNode Extract()
			{
				for (; ; )
				{
					int idx = maxIndex_;
					if (idx < 0)
						return null;
					WaitNode w = cells_[idx].Extract();
					if (w != null)
						return w;
					else
						--maxIndex_;
				}
			}
		}
	}
}