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
File: Slot.java

Originally written by Doug Lea and released into the public domain.
This may be used for any purposes whatsoever without acknowledgment.
Thanks for the assistance and support of Sun Microsystems Labs,
and everyone contributing, testing, and using this code.

History:
Date       Who                What
11Jun1998  dl               Create public version
25aug1998  dl               added peek*/
using System;
namespace Spring.Threading
{
	
	/// <summary> A one-slot buffer, using semaphores to control access.
	/// Slots are usually more efficient and controllable than using other
	/// bounded buffers implementations with capacity of 1.
	/// <p>
	/// Among other applications, Slots can be convenient in token-passing
	/// designs: Here. the Slot holds a some object serving as a token,
	/// that can be obtained
	/// and returned by various threads.
	/// </p>
	/// </summary>
	
	public class Slot:SemaphoreControlledChannel
	{
		
		/// <summary> Create a buffer with the given capacity, using
		/// the supplied Semaphore class for semaphores.
		/// </summary>
		
		public Slot(System.Type semaphoreClass):base(1, semaphoreClass)
		{
		}
		
		/// <summary> Create a new Slot using default Semaphore implementations 
		/// 
		/// </summary>
		public Slot():base(1)
		{
		}
		
		/// <summary>The slot *</summary>
		protected internal System.Object item_ = null;
		
		
		/// <summary>Set the item in preparation for a take *</summary>
		protected internal override void  Insert(System.Object x)
		{
			lock (this)
			{
				item_ = x;
			}
		}
		
		/// <summary>Take item known to exist *</summary>
		protected internal override System.Object Extract()
		{
			lock (this)
			{
				System.Object x = item_;
				item_ = null;
				return x;
			}
		}
		
        /// <summary>
        /// <see cref="IChannel.Peek"/>
        /// </summary>
        /// <returns></returns>
		public override System.Object Peek()
		{
			lock (this)
			{
				return item_;
			}
		}
	}
}