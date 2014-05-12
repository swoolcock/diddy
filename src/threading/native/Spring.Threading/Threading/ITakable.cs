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
    /// for channels. A method argument or instance variable
    /// in a consumer object can be declared as only a <see cref="ITakable"/>
    /// rather than a <see cref="IChannel"/>, in which case a compiler
    /// will disallow put operations.
    /// <p>
    /// Full method descriptions appear in the <see cref="IChannel"/> interface.</p>
    /// </summary>
    /// <seealso cref="IChannel">
    /// </seealso>
    /// <seealso cref="IPuttable">
    /// 
    /// </seealso>
	
    public interface ITakable
    {
			
        /// <summary> Return and remove an item from channel, 
        /// possibly waiting indefinitely until
        /// such an item exists.
        /// </summary>
        /// <returns>  some item from the channel. Different implementations
        /// may guarantee various properties (such as FIFO) about that item
        /// </returns>
        /// <exception cref="ThreadInterruptedException"> if the current thread has
        /// been interrupted at a point at which interruption
        /// is detected, in which case state of the channel is unchanged.
        /// </exception>
        Object Take();
			
			
        /// <summary> Return and remove an item from channel only if one is available within
        /// msecs milliseconds. The time bound is interpreted in a coarse
        /// grained, best-effort fashion.
        /// </summary>
        /// <param name="msecs">the number of milliseconds to wait. If less than
        /// or equal to zero, the operation does not perform any timed waits,
        /// but might still require
        /// access to a synchronization lock, which can impose unbounded
        /// delay if there is a lot of contention for the channel.
        /// </param>
        /// <returns> some item, or null if the channel is empty.
        /// </returns>
        /// <exception cref="ThreadInterruptedException"> if the current thread has
        /// been interrupted at a point at which interruption
        /// is detected, in which case state of the channel is unchanged
        /// (i.e., equivalent to a false return).
        /// </exception>			
        Object Poll(long msecs);
    }
}