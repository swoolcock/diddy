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
File: FIFOSemaphore.java

Originally written by Doug Lea and released into the public domain.
This may be used for any purposes whatsoever without acknowledgment.
Thanks for the assistance and support of Sun Microsystems Labs,
and everyone contributing, testing, and using this code.

History:
Date       Who                What
11Jun1998  dl               Create public version*/
using System;
namespace Spring.Threading
{
	
	/// <summary> A First-in/First-out implementation of a Semaphore.
	/// Waiting requests will be satisified in
	/// the order that the processing of those requests got to a certain point.
	/// If this sounds vague it is meant to be. FIFO implies a
	/// logical timestamping at some point in the processing of the
	/// request. To simplify things we don't actually timestamp but
	/// simply store things in a FIFO queue. Thus the order in which
	/// requests enter the queue will be the order in which they come
	/// out.  This order need not have any relationship to the order in
	/// which requests were made, nor the order in which requests
	/// actually return to the caller. These depend on Java thread
	/// scheduling which is not guaranteed to be predictable (although
	/// JVMs tend not to go out of their way to be unfair). 
	/// </summary>
	
	public class FIFOSemaphore:QueuedSemaphore
	{
		
		/// <summary> Create a Semaphore with the given initial number of permits.
		/// Using a seed of one makes the semaphore act as a mutual exclusion lock.
		/// Negative seeds are also allowed, in which case no acquires will proceed
		/// until the number of releases has pushed the number of permits past 0.
		/// 
		/// </summary>
		
		public FIFOSemaphore(long initialPermits):base(new FIFOWaitQueue(), initialPermits)
		{
		}
		
		/// <summary> Simple linked list queue used in FIFOSemaphore.
		/// Methods are not synchronized; they depend on synch of callers
		/// 
		/// </summary>
		internal class FIFOWaitQueue:WaitQueue
		{
			protected internal WaitNode head_ = null;
			protected internal WaitNode tail_ = null;
			
			internal override void Insert(WaitNode w)
			{
				if (tail_ == null)
					head_ = tail_ = w;
				else
				{
					tail_.next = w;
					tail_ = w;
				}
			}
			
			internal override WaitNode Extract()
			{
				if (head_ == null)
					return null;
				else
				{
					WaitNode w = head_;
					head_ = w.next;
					if (head_ == null)
						tail_ = null;
					w.next = null;
					return w;
				}
			}
		}
	}
}