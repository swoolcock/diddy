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

namespace Spring.Threading
{
	
	/// <summary> A utility class to set the default capacity of
	/// <see cref="IBoundedChannel"></see>
	/// implementations that otherwise require a capacity argument
	/// </summary>
	/// <seealso cref="IBoundedChannel"/>
	/// <remarks>Not intended to be used outside <c>Spring.NET</c></remarks>
	internal class DefaultChannelCapacity
	{
		
		/// <summary>The initial value of the default capacity is 1024 *</summary>
		public const int InitialDefaultCapacity = 1024;
		
		/// <summary>the current default capacity *</summary>
		private static int defaultCapacity_ = InitialDefaultCapacity;

        /// <summary> The default capacity used in 
        /// default (no-argument) constructor for BoundedChannels
        /// that otherwise require a capacity argument.
        /// </summary>
        /// <exception cref="ArgumentException"> if capacity less or equal to zero
        /// </exception>
        public static int DefaultCapacity
        {
            get
            {
                lock (typeof(DefaultChannelCapacity))
                {
                    return defaultCapacity_;    
                }			
            }
            set
            {
                if (value <= 0)
                    throw new ArgumentException();
                lock (typeof(DefaultChannelCapacity))
                {
                    defaultCapacity_ = value;    
                }			                
            }
        }		
	}
}