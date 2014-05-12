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
	
	/// <summary>A standard linked list node used in various queue classes</summary>
	public class LinkedNode
	{
        /// <summary>
        /// The object paired to this node
        /// </summary>
		public Object Value;

        /// <summary>
        /// The next linked node
        /// </summary>
		public LinkedNode Next;

        /// <summary>
        /// Creates a node, with no <see cref="Value"/> and no <see cref="Next"/>
        /// </summary>
        public LinkedNode()
	    {
	    }

	    /// <summary>
        /// Creates a node
        /// </summary>
        /// <param name="x">the object paired to this node</param>
		public LinkedNode(Object x)
		{
		    Value = x;
		}

        /// <summary>
        /// Creates a node
        /// </summary>
        /// <param name="x">the object paired to this node</param>
        /// <param name="n">a node to link to</param>
		public LinkedNode(Object x, LinkedNode n)
		{
		    Value = x; Next = n;
		}
	}
}