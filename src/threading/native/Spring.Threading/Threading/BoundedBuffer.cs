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
using System;
using System.Threading;

namespace Spring.Threading
{
	
    /// <summary> Efficient array-based bounded buffer class.
    /// </summary>
	
    public class BoundedBuffer : IBoundedChannel
    {
		/// <summary>
		/// the elements
		/// </summary>
        protected readonly internal object[] array_;
		
        /// <summary>
        /// circular index for take mechanics
        /// </summary>
        protected internal int takePtr_ = 0; 

        /// <summary>
        /// circular index for put mechanics
        /// </summary>
        protected internal int putPtr_ = 0;
		
        /// <summary>
        /// length
        /// </summary>
        protected internal int usedSlots_ = 0; // length

        /// <summary>
        /// capacity - length
        /// </summary>
        protected internal int emptySlots_; // 
		
        /// <summary> Helper monitor to handle puts. 
        /// </summary>
        protected readonly internal object putMonitor_ = new object();
		
        /// <summary> Create a BoundedBuffer with the given capacity.</summary>
        /// <exception cref="ArgumentException"> if capacity less or equal to zero
        /// </exception>
        public BoundedBuffer(int capacity)
        {
            if (capacity <= 0)
                throw new ArgumentException("capacity must greater than zero");
            array_ = new Object[capacity];
            emptySlots_ = capacity;
        }
		
        /// <summary> Create a buffer with the current default capacity
        /// </summary>		
        public BoundedBuffer():this(DefaultChannelCapacity.DefaultCapacity)
        {
        }

        /// <summary>
        /// The current buffer size
        /// </summary>
        public virtual int Size
        {
            get
            {
                lock (this)
                {
                    return usedSlots_;
                }
            }
        }

        /// <summary>
        /// The capacity of this buffer
        /// </summary>
        public virtual int Capacity
        {
            get { return array_.Length; }
        }

        /// <summary>
        /// safely increment empty slots
        /// </summary>
        protected internal virtual void  IncEmptySlots()
        {
            lock (putMonitor_)
            {
                ++emptySlots_;
                Monitor.Pulse(putMonitor_);
            }
        }
		
        /// <summary>
        /// safely increment used slots
        /// </summary>
        protected internal virtual void  IncUsedSlots()
        {
            lock (this)
            {
                ++usedSlots_;
                Monitor.Pulse(this);
            }
        }
		
        /// <summary>
        /// mechanics of put
        /// </summary>
        protected internal void  Insert(Object x)
        {
            --emptySlots_;
            array_[putPtr_] = x;
            if (++putPtr_ >= array_.Length)
                putPtr_ = 0;
        }
		
        /// <summary>
        /// mechanics of take
        /// </summary>
        /// <returns>the next available item in the buffer</returns>
        protected internal Object Extract()
        {
            
            --usedSlots_;
            Object old = array_[takePtr_];
            array_[takePtr_] = null;
            if (++takePtr_ >= array_.Length)
                takePtr_ = 0;
            return old;
        }
		
        /// <summary>
        /// <see cref="IChannel.Peek"/>
        /// </summary>
        public virtual Object Peek()
        {
            lock (this)
            {
                if (usedSlots_ > 0)
                    return array_[takePtr_];
                else
                    return null;
            }
        }
		
		/// <summary>
		/// <see cref="IPuttable.Put"/>
		/// </summary>
        public virtual void  Put(Object x)
        {
            if (x == null)
                throw new ArgumentException();
            Utils.FailFastIfInterrupted();			
            lock (putMonitor_)
            {
                while (emptySlots_ <= 0)
                {
                    try
                    {
                        Monitor.Wait(putMonitor_);
                    }
                    catch (ThreadInterruptedException ex)
                    {
                        Monitor.Pulse(putMonitor_);
                        throw ex;
                    }
                }
                Insert(x);
            }
            IncUsedSlots();
        }
		
        /// <summary>
        /// <see cref="IPuttable.Offer"/>
        /// </summary>
        /// <returns><code>true</code> if the object has been inserted, <code>false</code> otherwise</returns>
        public virtual bool Offer(Object x, long msecs)
        {
            if (x == null)
                throw new ArgumentException("cannot put null object in buffer");
            Utils.FailFastIfInterrupted();			
			
            lock (putMonitor_)
            {
                long start = (msecs <= 0)?0:Utils.CurrentTimeMillis;
                long waitTime = msecs;
                while (emptySlots_ <= 0)
                {
                    if (waitTime <= 0)
                        return false;
                    try
                    {
                        Monitor.Wait(putMonitor_, TimeSpan.FromMilliseconds(waitTime));
                    }
                    catch (ThreadInterruptedException ex)
                    {
                        Monitor.Pulse(putMonitor_);
                        throw ex;
                    }
                    waitTime = msecs - (Utils.CurrentTimeMillis - start);
                }
                Insert(x);
            }
            IncUsedSlots();
            return true;
        }
		
        /// <summary>
        /// <see cref="ITakable.Take"/>
        /// </summary>
        public virtual Object Take()
        {
            Utils.FailFastIfInterrupted();			
            Object old = null;
            lock (this)
            {
                while (usedSlots_ <= 0)
                {
                    try
                    {
                        Monitor.Wait(this);
                    }
                    catch (ThreadInterruptedException ex)
                    {
                        Monitor.Pulse(this);
                        throw ex;
                    }
                }
                old = Extract();
            }
            IncEmptySlots();
            return old;
        }
		
        /// <summary>
        /// <see cref="ITakable.Poll"/>
        /// </summary>
        public virtual Object Poll(long msecs)
        {
            Utils.FailFastIfInterrupted();			
            Object old = null;
            lock (this)
            {
                long start = (msecs <= 0)?0:Utils.CurrentTimeMillis;
                long waitTime = msecs;
				
                while (usedSlots_ <= 0)
                {
                    if (waitTime <= 0)
                        return null;
                    try
                    {
                        Monitor.Wait(this, TimeSpan.FromMilliseconds(waitTime));
                    }
                    catch (ThreadInterruptedException ex)
                    {
                        Monitor.Pulse(this);
                        throw ex;
                    }
                    waitTime = msecs - (Utils.CurrentTimeMillis - start);
                }
                old = Extract();
            }
            IncEmptySlots();
            return old;
        }
    }
}