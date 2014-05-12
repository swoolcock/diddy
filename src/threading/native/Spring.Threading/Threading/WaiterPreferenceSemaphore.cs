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
File: WaiterPreferenceSemaphore.java

Originally written by Doug Lea and released into the public domain.
This may be used for any purposes whatsoever without acknowledgment.
Thanks for the assistance and support of Sun Microsystems Labs,
and everyone contributing, testing, and using this code.
se
History:
Date       Who                What
11Jun1998  dl               Create public version
5Aug1998  dl               replaced int counters with longs*/
using System;
namespace Spring.Threading
{
	
	/// <summary> An implementation of counting Semaphores that
	/// enforces enough fairness for applications that
	/// need to avoid indefinite overtaking without
	/// necessarily requiring FIFO ordered access.
	/// Empirically, very little is paid for this property
	/// unless there is a lot of contention among threads
	/// or very unfair JVM scheduling.
	/// The acquire method waits even if there are permits
	/// available but have not yet been claimed by threads that have
	/// been notified but not yet resumed. This makes the semaphore
	/// almost as fair as the underlying Java primitives allow. 
	/// So, if synch lock entry and notify are both fair
	/// so is the semaphore -- almost:  Rewaits stemming
	/// from timeouts in attempt, along with potentials for
	/// interrupted threads to be notified can compromise fairness,
	/// possibly allowing later-arriving threads to pass before
	/// later arriving ones. However, in no case can a newly
	/// entering thread obtain a permit if there are still others waiting.
	/// Also, signalling order need not coincide with
	/// resumption order. Later-arriving threads might get permits
	/// and continue before other resumable threads are actually resumed.
	/// However, all of these potential fairness breaches are
	/// very rare in practice unless the underlying JVM
	/// performs strictly LIFO notifications (which has, sadly enough, 
	/// been known to occur) in which case you need to use
	/// a FIFOSemaphore to maintain a reasonable approximation
	/// of fairness.
	/// <p>[<a href="http://gee.cs.oswego.edu/dl/classes/EDU/oswego/cs/dl/util/concurrent/intro.html"> Introduction to this package. </a>]</p>
	/// 
	/// </summary>
	
	
	public sealed class WaiterPreferenceSemaphore:Semaphore
	{
		
		/// <summary> 
		/// Create a Semaphore with the given initial number of permits.
		/// </summary>
		public WaiterPreferenceSemaphore(long initial):base(initial)
		{
		}
		
		/// <summary>Number of waiting threads *</summary>
		internal long waits_ = 0;
		
        /// <summary>
        /// <see cref="Semaphore.Acquire"/>
        /// </summary>
		public override void Acquire()
		{
            Utils.FailFastIfInterrupted();
			lock (this)
			{
				/*
				Only take if there are more permits than threads waiting
				for permits. This prevents infinite overtaking.
				*/
				if (nPermits > waits_)
				{
					--nPermits;
					return ;
				}
				else
				{
					++waits_;
					try
					{
						for (; ; )
						{
							System.Threading.Monitor.Wait(this);
							if (nPermits > 0)
							{
								--waits_;
								--nPermits;
								return ;
							}
						}
					}
					catch (System.Threading.ThreadInterruptedException ex)
					{
						--waits_;
						System.Threading.Monitor.Pulse(this);
						throw ex;
					}
				}
			}
		}
		
        /// <summary>
        /// <see cref="Semaphore.Attempt"/>
        /// </summary>
        /// <param name="msecs"></param>
        /// <returns></returns>
		public override bool Attempt(long msecs)
		{
			Utils.FailFastIfInterrupted();
			lock (this)
			{
				if (nPermits > waits_)
				{
					--nPermits;
					return true;
				}
				else if (msecs <= 0)
					return false;
				else
				{
					++waits_;
										
					long startTime = Utils.CurrentTimeMillis;
					long waitTime = msecs;
					
					try
					{
						for (; ; )
						{
							System.Threading.Monitor.Wait(this, TimeSpan.FromMilliseconds(waitTime));
							if (nPermits > 0)
							{
								--waits_;
								--nPermits;
								return true;
							}
							else
							{
								// got a time-out or false-alarm notify
								waitTime = msecs - (Utils.CurrentTimeMillis - startTime);
								if (waitTime <= 0)
								{
									--waits_;
									return false;
								}
							}
						}
					}
					catch (System.Threading.ThreadInterruptedException ex)
					{
						--waits_;
						System.Threading.Monitor.Pulse(this);
						throw ex;
					}
				}
			}
		}
		
        /// <summary>
        /// <see cref="ISync.Release"/>
        /// </summary>
		public override void  Release()
		{
			lock (this)
			{
				++nPermits;
				System.Threading.Monitor.Pulse(this);
			}
		}
		
		/// <summary>Release N permits *</summary>
		public override void Release(long n)
		{
			lock (this)
			{
			    nPermits += n;
				for (long i = 0; i < n; ++i)
					System.Threading.Monitor.Pulse(this);
			}
		}
	}
}