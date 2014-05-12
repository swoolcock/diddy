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

using System;
/*
File: SemaphoreControlledChannel.java

Originally written by Doug Lea and released into the public domain.
This may be used for any purposes whatsoever without acknowledgment.
Thanks for the assistance and support of Sun Microsystems Labs,
and everyone contributing, testing, and using this code.

History:
Date       Who                What
16Jun1998  dl               Create public version
5Aug1998  dl               replaced int counters with longs
08dec2001  dl               reflective constructor now uses longs too.*/

namespace Spring.Threading
{
	
    /// <summary> Abstract class for channels that use Semaphores to
    /// control puts and takes.
    /// </summary>
	
    public abstract class SemaphoreControlledChannel : IBoundedChannel
    {
        /// <summary>
        /// guard for put
        /// </summary>
        protected internal readonly Semaphore putGuard_;

        /// <summary>
        /// guard for take
        /// </summary>
        protected internal readonly Semaphore takeGuard_;

        /// <summary>
        /// channel capacity
        /// </summary>
        protected internal int capacity_;
		
        /// <summary> Create a channel with the given capacity and default
        /// semaphore implementation
        /// </summary>
        /// <exception cref="ArgumentException"> if capacity less or equal to zero
        /// 
        /// </exception>		
        public SemaphoreControlledChannel(int capacity)
        {
            if (capacity <= 0)
                throw new System.ArgumentException();
            capacity_ = capacity;
            putGuard_ = new Semaphore(capacity);
            takeGuard_ = new Semaphore(0);
        }
		
		
        /// <summary> Create a channel with the given capacity and 
        /// semaphore implementations instantiated from the supplied class
        /// </summary>
        public SemaphoreControlledChannel(int capacity, System.Type semaphoreClass)
        {
            if (capacity <= 0)
                throw new System.ArgumentException();
            capacity_ = capacity;
            System.Type[] longarg = new System.Type[]{System.Type.GetType("System.Int64")};
            System.Reflection.ConstructorInfo ctor = semaphoreClass.GetConstructor(System.Reflection.BindingFlags.DeclaredOnly, null, longarg, null);
            object [] cap = new object [] {(System.Int64) capacity};
            putGuard_ = (Semaphore) (ctor.Invoke(cap));
            object [] zero = new object []{(System.Int64) 0};
            takeGuard_ = (Semaphore) (ctor.Invoke(zero));
        }

        /// <summary>
        /// <see cref="IBoundedChannel"/>
        /// </summary>
        public virtual int Capacity
        {
            get { return capacity_; }
        }

        /// <summary> Return the number of elements in the buffer.
        /// This is only a snapshot value, that may change
        /// immediately after returning.
        /// </summary>
        public virtual int Size()
        {
            return (int) (takeGuard_.Permits);
        }
		
        /// <summary> Internal mechanics of put.
        /// </summary>
        protected internal abstract void  Insert(System.Object x);
		
        /// <summary> Internal mechanics of take.
        /// </summary>
        protected internal abstract System.Object Extract();
		
        /// <summary>
        /// <see cref="IPuttable.Put"/>
        /// </summary>
        /// <param name="x"></param>
        public virtual void  Put(System.Object x)
        {
            if (x == null)
                throw new System.ArgumentException();
            Utils.FailFastIfInterrupted();
            putGuard_.Acquire();
            try
            {
                Insert(x);
                takeGuard_.Release();
            }
            catch (System.InvalidCastException ex)
            {
                putGuard_.Release();
                throw ex;
            }
        }
		
        /// <summary>
        /// <see cref="IPuttable.Offer"/>
        /// </summary>
        public virtual bool Offer(System.Object x, long msecs)
        {
            if (x == null)
                throw new System.ArgumentException();
            Utils.FailFastIfInterrupted();
            if (!putGuard_.Attempt(msecs))
                return false;
            else
            {
                try
                {
                    Insert(x);
                    takeGuard_.Release();
                    return true;
                }
                catch (System.InvalidCastException ex)
                {
                    putGuard_.Release();
                    throw ex;
                }
            }
        }
		
        /// <summary>
        /// <see cref="ITakable.Take"/>
        /// </summary>
        /// <returns></returns>
        public virtual System.Object Take()
        {
            Utils.FailFastIfInterrupted();
            takeGuard_.Acquire();
            try
            {
                System.Object x = Extract();
                putGuard_.Release();
                return x;
            }
            catch (System.InvalidCastException ex)
            {
                takeGuard_.Release();
                throw ex;
            }
        }
		
        /// <summary>
        /// <see cref="ITakable.Take"/>
        /// </summary>
        /// <param name="msecs"></param>
        /// <returns></returns>
        public virtual System.Object Poll(long msecs)
        {
            Utils.FailFastIfInterrupted();
            if (!takeGuard_.Attempt(msecs))
                return null;
            else
            {
                try
                {
                    System.Object x = Extract();
                    putGuard_.Release();
                    return x;
                }
                catch (System.InvalidCastException ex)
                {
                    takeGuard_.Release();
                    throw ex;
                }
            }
        }
        
        /// <summary>
        /// Abstract, <see cref="IChannel.Peek"/>
        /// </summary>
        public abstract System.Object Peek ();        

    }
}