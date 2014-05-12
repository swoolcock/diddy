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
	
    /// <summary> This interface exists to enable stricter type checking
    /// for <see cref="IChannel"/>s. A method argument or instance variable
    /// in a producer object can be declared as only a <see cref="IPuttable"/>
    /// rather than a <see cref="IChannel"/>, in which case the compiler
    /// will disallow take operations.
    /// <p>
    /// Full method descriptions appear in the <see cref="IChannel"/> interface.</p>
    /// </summary>
    /// <seealso cref="IChannel">
    /// </seealso>
    /// <seealso cref="ITakable">
    /// 
    /// </seealso>
	
    public interface IPuttable
    {
        /// <summary> Place item in the channel, possibly waiting indefinitely until
        /// it can be accepted. <see cref="IChannel"/>s implementing the 
        /// <see cref="IBoundedChannel"/>
        /// subinterface are generally guaranteed to block on puts upon
        /// reaching capacity, but other implementations may or may not block.
        /// </summary>
        /// <param name="item">the element to be inserted. Should be non-null.
        /// </param>
        /// <exception cref="ThreadInterruptedException">  if the current thread has
        /// been interrupted at a point at which interruption
        /// is detected, in which case the element is guaranteed not
        /// to be inserted. Otherwise, on normal return, the element is guaranteed
        /// to have been inserted.
        /// 
        /// </exception>
        void  Put(Object item);
			
			
        /// <summary> Place item in channel only if it can be accepted within
        /// msecs milliseconds. The time bound is interpreted in
        /// a coarse-grained, best-effort fashion. 
        /// </summary>
        /// <param name="item">the element to be inserted. Should be non-null.
        /// </param>
        /// <param name="msecs">the number of milliseconds to wait. If less than
        /// or equal to zero, the method does not perform any timed waits,
        /// but might still require
        /// access to a synchronization lock, which can impose unbounded
        /// delay if there is a lot of contention for the channel.
        /// </param>
        /// <returns> true if accepted, else false
        /// </returns>
        /// <exception cref="ThreadInterruptedException"> if the current thread has
        /// been interrupted at a point at which interruption
        /// is detected, in which case the element is guaranteed not
        /// to be inserted (i.e., is equivalent to a false return).
        /// 
        /// </exception>
        bool Offer(Object item, long msecs);
    }
}