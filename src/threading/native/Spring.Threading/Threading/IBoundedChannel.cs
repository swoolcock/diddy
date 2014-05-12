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
namespace Spring.Threading
{
	
	/// <summary> A channel that is known to have a capacity, signifying
	/// that <see cref="IPuttable.Put"/> operations may block when the
	/// capacity is reached. Various implementations may have
	/// intrinsically hard-wired capacities, capacities that are fixed upon
	/// construction, or dynamically adjustable capacities.
	/// </summary>
	/// <seealso cref="DefaultChannelCapacity">
	/// 
	/// </seealso>
	
	public interface IBoundedChannel : IChannel
		{
			/// <summary> Return the maximum number of elements that can be held.</summary>
			/// <returns> the capacity of this channel.
			/// 
			/// </returns>
			int Capacity { get; }
		}
}