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
File: CountDown.java

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
	
	/// <summary> A CountDown can serve as a simple one-shot barrier. 
	/// A Countdown is initialized
	/// with a given count value. Each release decrements the count.
	/// All acquires block until the count reaches zero. Upon reaching
	/// zero all current acquires are unblocked and all 
	/// subsequent acquires pass without blocking. This is a one-shot
	/// phenomenon -- the count cannot be reset. 
	/// If you need a version that resets the count, consider
	/// using a Barrier.
	/// <p>
	/// <b>Sample usage.</b> Here are a set of classes in which
	/// a group of worker threads use a countdown to
	/// notify a driver when all threads are complete.
	/// <pre>
	/// class Worker implements Runnable { 
	/// private final CountDown done;
	/// Worker(CountDown d) { done = d; }
	/// public void run() {
	/// doWork();
	/// done.release();
	/// }
	/// }
	/// 
	/// class Driver { // ...
	/// void main() {
	/// CountDown done = new CountDown(N);
	/// for (int i = 0; i &lt; N; ++i) 
	/// new Thread(new Worker(done)).start();
	/// doSomethingElse(); 
	/// done.acquire(); // wait for all to finish
	/// } 
	/// }
	/// </pre>
	/// </p>
	/// </summary>
	
	public class CountDown : ISync
	{
        /// <summary>
        /// the initial count
        /// </summary>
		protected readonly internal int initialCount_;
        /// <summary>
        /// the actual count 
        /// </summary>
		protected internal int count_;
		
		/// <summary>Create a new CountDown with given count value *</summary>
		public CountDown(int count)
		{
			count_ = initialCount_ = count;
		}
		

		/// <summary>
		/// <see cref="ISync.Acquire"/>
		/// </summary>
		public virtual void Acquire()
		{
            /*
            This could use double-check, but doesn't out of concern
            for surprising effects on user programs stemming
            from lack of memory barriers with lack of synch.
            */
            Utils.FailFastIfInterrupted();
            lock (this)
			{
				while (count_ > 0)
					System.Threading.Monitor.Wait(this);
			}
		}
		
		/// <summary>
		/// <see cref="ISync.Attempt"/>
		/// </summary>
		public virtual bool Attempt(long msecs)
		{
            Utils.FailFastIfInterrupted();
            lock (this)
			{
				if (count_ <= 0)
					return true;
				else if (msecs <= 0)
					return false;
				else
				{
					long waitTime = msecs;
					long start = Utils.CurrentTimeMillis;
					for (; ; )
					{
						System.Threading.Monitor.Wait(this, TimeSpan.FromMilliseconds(waitTime));
						if (count_ <= 0)
							return true;
						else
						{
							waitTime = msecs - (Utils.CurrentTimeMillis - start);
							if (waitTime <= 0)
								return false;
						}
					}
				}
			}
		}
		
		/// <summary> Decrement the count.
		/// After the initialCount'th release, all current and future
		/// acquires will pass
		/// </summary>
		public virtual void  Release()
		{
			lock (this)
			{
				if (--count_ == 0)
					System.Threading.Monitor.PulseAll(this);
			}
		}

        /// <summary>
        /// Gets the initial count.
        /// </summary>
        /// <value></value>
	    public virtual int InitialCount
	    {
	        get { return initialCount_; }
	    }

        /// <summary>
        /// Gets the current count.
        /// </summary>
        /// <value></value>
	    public virtual int CurrentCount
	    {
	        get
	        {
	            lock (this)
	            {
	                return count_;
	            }
	        }
	    }
	}
}