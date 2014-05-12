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
File: Rendezvous.java

Originally written by Doug Lea and released into the public domain.
This may be used for any purposes whatsoever without acknowledgment.
Thanks for the assistance and support of Sun Microsystems Labs,
and everyone contributing, testing, and using this code.

History:
Date       Who                What
11Jun1998  dl               Create public version
30Jul1998  dl               Minor code simplifications*/
using System;
using System.Threading;

namespace Spring.Threading
{
	
	/// <summary> A rendezvous is a barrier that:
	/// <ul>
	/// <li> Unlike a CyclicBarrier, is not restricted to use 
	/// with fixed-sized groups of threads.
	/// Any number of threads can attempt to enter a rendezvous,
	/// but only the predetermined number of parties enter
	/// and later become released from the rendezvous at any give time.
	/// </li>
	/// <li> Enables each participating thread to exchange information
	/// with others at the rendezvous point. Each entering thread
	/// presents some object on entry to the rendezvous, and
	/// returns some object on release. The object returned is
	/// the result of a RendezvousFunction that is run once per
	/// rendezvous, (it is run by the last-entering thread). By
	/// default, the function applied is a rotation, so each
	/// thread returns the object given by the next (modulo parties)
	/// entering thread. This default function faciliates simple
	/// application of a common use of rendezvous, as exchangers.
	/// </li>
	/// </ul>
	/// <p>
	/// Rendezvous use an all-or-none breakage model
	/// for failed synchronization attempts: If threads
	/// leave a rendezvous point prematurely because of timeout
	/// or interruption, others will also leave abnormally
	/// (via BrokenBarrierException), until
	/// the rendezvous is <code>restart</code>ed. This is usually
	/// the simplest and best strategy for sharing knowledge
	/// about failures among cooperating threads in the most
	/// common usages contexts of Rendezvous.
	/// </p>
	/// <p>
	/// While any positive number (including 1) of parties can
	/// be handled, the most common case is to have two parties.
	/// </p>
	/// <p>
	/// <b>Sample Usage</b>
	/// </p>
	/// <p>
	/// Here are the highlights of a class that uses a Rendezvous to
	/// swap buffers between threads so that the thread filling the
	/// buffer  gets a freshly
	/// emptied one when it needs it, handing off the filled one to
	/// the thread emptying the buffer.
	/// <pre>
	/// class FillAndEmpty {
	/// Rendezvous exchanger = new Rendezvous(2);
	/// Buffer initialEmptyBuffer = ... a made-up type
	/// Buffer initialFullBuffer = ...
	/// 
	/// class FillingLoop implements Runnable {
	/// public void run() {
	/// Buffer currentBuffer = initialEmptyBuffer;
	/// try {
	/// while (currentBuffer != null) {
	/// addToBuffer(currentBuffer);
	/// if (currentBuffer.full()) 
	/// currentBuffer = (Buffer)(exchanger.rendezvous(currentBuffer));
	/// }
	/// }
	/// catch (BrokenBarrierException ex) {
	/// return;
	/// }
	/// catch (InterruptedException ex) {
	/// Thread.currentThread().interrupt();
	/// }
	/// }
	/// }
	/// 
	/// class EmptyingLoop implements Runnable {
	/// public void run() {
	/// Buffer currentBuffer = initialFullBuffer;
	/// try {
	/// while (currentBuffer != null) {
	/// takeFromBuffer(currentBuffer);
	/// if (currentBuffer.empty()) 
	/// currentBuffer = (Buffer)(exchanger.rendezvous(currentBuffer));
	/// }
	/// }
	/// catch (BrokenBarrierException ex) {
	/// return;
	/// }
	/// catch (InterruptedException ex) {
	/// Thread.currentThread().interrupt();
	/// }
	/// }
	/// }
	/// 
	/// void start() {
	/// new Thread(new FillingLoop()).start();
	/// new Thread(new EmptyingLoop()).start();
	/// }
	/// }
	/// </pre>
	/// </p>
	/// </summary>
	
	public class Rendezvous : IBarrier
	{
		
		/// <summary> Interface for functions run at rendezvous points
		/// 
		/// </summary>
		public interface IRendezvousFunction
			{
				/// <summary> Perform some function on the objects presented at
				/// a rendezvous. The objects array holds all presented
				/// items; one per thread. Its length is the number of parties. 
				/// The array is ordered by arrival into the rendezvous.
				/// So, the last element (at objects[objects.length-1])
				/// is guaranteed to have been presented by the thread performing
				/// this function. No identifying information is
				/// otherwise kept about which thread presented which item.
				/// If you need to 
				/// trace origins, you will need to use an item type for rendezvous
				/// that includes identifying information. After return of this
				/// function, other threads are released, and each returns with
				/// the item with the same index as the one it presented.
				/// 
				/// </summary>
				void  RendezvousFunction(System.Object[] objects);
			}
		
		/// <summary> The default rendezvous function. Rotates the array
		/// so that each thread returns an item presented by some
		/// other thread (or itself, if parties is 1).
		/// 
		/// </summary>
		public class Rotator : IRendezvousFunction
		{
			/// <summary>Rotate the array *</summary>
			public virtual void  RendezvousFunction(System.Object[] objects)
			{
				int lastIdx = objects.Length - 1;
				System.Object first = objects[0];
				for (int i = 0; i < lastIdx; ++i)
					objects[i] = objects[i + 1];
				objects[lastIdx] = first;
			}
		}
				
        /// <summary>
        /// number of parties that must meet 
        /// </summary>
		protected readonly internal int parties_;
				
        /// <summary>
        /// broken by any thread ?
        /// </summary>
		protected internal bool broken_ = false;
		
		/// <summary> Number of threads that have entered rendezvous
		/// 
		/// </summary>
		protected internal int entries_ = 0;
		
		/// <summary> Number of threads that are permitted to depart rendezvous 
		/// 
		/// </summary>
		protected internal long departures_ = 0;
		
		/// <summary> Incoming threads pile up on entry until last set done.
		/// 
		/// </summary>
		protected readonly internal Semaphore entryGate_;
		
		/// <summary> Temporary holder for items in exchange
		/// 
		/// </summary>
		protected readonly internal System.Object[] slots_;
		
		/// <summary> The function to run at rendezvous point
		/// 
		/// </summary>
		
		protected internal IRendezvousFunction rendezvousFunction_;
		
		/// <summary> Create a Barrier for the indicated number of parties,
		/// and the default Rotator function to run at each barrier point.
		/// </summary>
		/// <exception cref="ArgumentException"> if parties less than or equal to zero.
		/// 
		/// </exception>		
		public Rendezvous(int parties):this(parties, new Rotator())
		{
		}
		
		/// <summary> Create a Barrier for the indicated number of parties.
		/// and the given function to run at each barrier point.
		/// </summary>
		/// <exception cref="ArgumentException">if parties less than or equal to zero.
		/// 
		/// </exception>
		
		public Rendezvous(int parties, IRendezvousFunction function)
		{
			if (parties <= 0)
				throw new System.ArgumentException();
			parties_ = parties;
			rendezvousFunction_ = function;
			entryGate_ = new WaiterPreferenceSemaphore(parties);
			slots_ = new System.Object[parties];
		}
		
		/// <summary> Set the function to call at the point at which all threads reach the
		/// rendezvous. This function is run exactly once, by the thread
		/// that trips the barrier. The function is not run if the barrier is
		/// broken. 
		/// </summary>
		/// <param name="function">the function to run. If null, no function is run.
		/// </param>
		/// <returns> the previous function
		/// 
		/// </returns>				
		public virtual IRendezvousFunction SetRendezvousFunction(IRendezvousFunction function)
		{
			lock (this)
			{
			    IRendezvousFunction old = rendezvousFunction_;
				rendezvousFunction_ = function;
				return old;
			}
		}

        /// <summary>
        /// <see cref="IBarrier.Parties"/>
        /// </summary>
	    public virtual int Parties
	    {
	        get { return parties_; }
	    }

        /// <summary>
        /// <see cref="IBarrier.IsBroken"/>
        /// </summary>
	    public virtual bool IsBroken
	    {
	        get
	        {
	            lock (this)
	            {
	                return broken_;
	            }
	        }
	    }

	    /// <summary> Reset to initial state. Clears both the broken status
		/// and any record of waiting threads, and releases all
		/// currently waiting threads with indeterminate return status.
		/// This method is intended only for use in recovery actions
		/// in which it is somehow known
		/// that no thread could possibly be relying on the
		/// the synchronization properties of this barrier.
		/// 
		/// </summary>		
		public virtual void  Restart()
		{
			// This is not very good, but probably the best that can be done
			for (; ; )
			{
				lock (this)
				{
					if (entries_ != 0)
					{
						System.Threading.Monitor.PulseAll(this);
					}
					else
					{
						broken_ = false;
						return ;
					}
				}
				System.Threading.Thread.Sleep(0);
			}
		}
		
		
		/// <summary> Enter a rendezvous; returning after all other parties arrive.</summary>
		/// <param name="x">the item to present at rendezvous point. 
		/// By default, this item is exchanged with another.
		/// </param>
		/// <returns> an item x given by some thread, and/or processed
		/// by the rendezvousFunction.
		/// </returns>
		/// <exception cref="BrokenBarrierException">
		/// if any other thread
		/// in any previous or current barrier 
		/// since either creation or the last <code>restart</code>
		/// operation left the barrier
		/// prematurely due to interruption or time-out. (If so,
		/// the <code>broken</code> status is also set.) 
		/// Also returns as
		/// broken if the RendezvousFunction encountered a run-time exception.
		/// Threads that are noticed to have been
		/// interrupted <em>after</em> being released are not considered
		/// to have broken the barrier.
		/// In all cases, the interruption
		/// status of the current thread is preserved, so can be tested
		/// by checking <code>Thread.interrupted</code>. 
		/// </exception>
		/// <exception cref="ThreadInterruptedException"> if this thread was interrupted
		/// during the exchange. If so, <code>broken</code> status is also set.
		/// 
		/// </exception>
		
		
		public virtual System.Object RendezVous(System.Object x)
		{
			return doRendezvous(x, false, 0);
		}
		
		/// <summary> Wait msecs to complete a rendezvous.</summary>
		/// <param name="x">the item to present at rendezvous point. 
		/// By default, this item is exchanged with another.
		/// </param>
		/// <param name="msecs">The maximum time to wait.
		/// </param>
		/// <returns> an item x given by some thread, and/or processed
		/// by the rendezvousFunction.
		/// </returns>
		/// <exception cref="BrokenBarrierException"> 
		/// if any other thread
		/// in any previous or current barrier 
		/// since either creation or the last <code>restart</code>
		/// operation left the barrier
		/// prematurely due to interruption or time-out. (If so,
		/// the <code>broken</code> status is also set.) 
		/// Also returns as
		/// broken if the RendezvousFunction encountered a run-time exception.
		/// Threads that are noticed to have been
		/// interrupted <em>after</em> being released are not considered
		/// to have broken the barrier.
		/// In all cases, the interruption
		/// status of the current thread is preserved, so can be tested
		/// by checking <code>Thread.interrupted</code>. 
		/// </exception>
		/// <exception cref="ThreadInterruptedException">  if this thread was interrupted
		/// during the exchange. If so, <code>broken</code> status is also set.
		/// </exception>
		/// <exception cref="TimeoutException">  if this thread timed out waiting for
		/// the exchange. If the timeout occured while already in the
		/// exchange, <code>broken</code> status is also set.
		/// 
		/// </exception>
		
		
		public virtual System.Object AttemptRendezVous(System.Object x, long msecs)
		{
			return doRendezvous(x, true, msecs);
		}
		
        /// <summary>
        /// The actual rendezvous logic for the given time
        /// </summary>
		protected internal virtual System.Object doRendezvous(System.Object x, bool timed, long msecs)
		{
			
			// rely on semaphore to throw interrupt on entry
			
			long startTime;
			
			if (timed)
			{
				startTime = Utils.CurrentTimeMillis;
				if (!entryGate_.Attempt(msecs))
				{
					throw new TimeoutException(msecs);
				}
			}
			else
			{
				startTime = 0;
				entryGate_.Acquire();
			}
			
			lock (this)
			{
				
				System.Object y = null;
				
				int index = entries_++;
				slots_[index] = x;
				
				try
				{
					// last one in runs function and releases
					if (entries_ == parties_)
					{
						
						departures_ = entries_;
						System.Threading.Monitor.PulseAll(this);
						
						try
						{
							if (!broken_ && rendezvousFunction_ != null)
								rendezvousFunction_.RendezvousFunction(slots_);
						}
						catch (System.SystemException)
						{
							broken_ = true;
						}
					}
					else
					{
						
						while (!broken_ && departures_ < 1)
						{
							long timeLeft = 0;
							if (timed)
							{
								timeLeft = msecs - (Utils.CurrentTimeMillis - startTime);
								if (timeLeft <= 0)
								{
									broken_ = true;
									departures_ = entries_;
									System.Threading.Monitor.PulseAll(this);
									throw new TimeoutException(msecs);
								}
							}
							
							try
							{
								System.Threading.Monitor.Wait(this, TimeSpan.FromMilliseconds(timeLeft));
							}
							catch (System.Threading.ThreadInterruptedException ex)
							{
								if (broken_ || departures_ > 0)
								{
									// interrupted after release
								    Thread.CurrentThread.Interrupt();
									break;
								}
								else
								{
									broken_ = true;
									departures_ = entries_;
									System.Threading.Monitor.PulseAll(this);
									throw ex;
								}
							}
						}
					}
				}
				finally
				{
					
					y = slots_[index];
					
					// Last one out cleans up and allows next set of threads in
					if (--departures_ <= 0)
					{
						for (int i = 0; i < slots_.Length; ++i)
							slots_[i] = null;
						entryGate_.Release(entries_);
						entries_ = 0;
					}
				}
				
				// continue if no IE/TO throw
				if (broken_)
					throw new BrokenBarrierException(index);
				else
					return y;
			}
		}
	}
}