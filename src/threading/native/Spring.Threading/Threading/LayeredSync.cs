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
File: LayeredSync.java

Originally written by Doug Lea and released into the public domain.
This may be used for any purposes whatsoever without acknowledgment.
Thanks for the assistance and support of Sun Microsystems Labs,
and everyone contributing, testing, and using this code.

History:
Date       Who                What
1Aug1998  dl               Create public version*/

namespace Spring.Threading
{
	
	/// <summary> A class that can be used to compose Syncs.
	/// A LayeredSync object manages two other Sync objects,
	/// <em>outer</em> and <em>inner</em>. The acquire operation
	/// invokes <em>outer</em>.acquire() followed by <em>inner</em>.acquire(),
	/// but backing out of outer (via release) upon an exception in inner.
	/// The other methods work similarly.
	/// <p>
	/// LayeredSyncs can be used to compose arbitrary chains
	/// by arranging that either of the managed Syncs be another
	/// LayeredSync.
	/// </p>
	/// </summary>
	
	
	public class LayeredSync : ISync
	{
		/// <summary>
		/// The outer sync
		/// </summary>
		protected readonly internal ISync outer_;

        /// <summary>
        /// the inner sync
        /// </summary>
		protected readonly internal ISync inner_;
		
		/// <summary> Create a LayeredSync managing the given outer and inner Sync
		/// objects
		/// </summary>		
		public LayeredSync(ISync outer, ISync inner)
		{
			outer_ = outer;
			inner_ = inner;
		}
		
        /// <summary>
        /// Invokes <c>outer_.Acquire</c> followed by <c>inner_.Acquire</c>,
        /// but backing out of outer (via <c>outer_.Release</c>) upon an 
        /// exception in <c>inner_.Acquire</c>.
        /// </summary>
		public virtual void  Acquire()
		{
			outer_.Acquire();
			try
			{
				inner_.Acquire();
			}
			catch (System.Threading.ThreadInterruptedException ex)
			{
				outer_.Release();
				throw ex;
			}
		}
		
        /// <summary>
        /// Attempt to get outer and then inner sync.
        /// Release outer, if gor, on interruption while
        /// attempting inner 
        /// </summary>
		public virtual bool Attempt(long msecs)
		{
			
			long start = (msecs <= 0)?0:Utils.CurrentTimeMillis;
			long waitTime = msecs;
			
			if (outer_.Attempt(waitTime))
			{
				try
				{
					if (msecs > 0)
					{
						waitTime = msecs - (Utils.CurrentTimeMillis - start);
					}
					if (inner_.Attempt(waitTime))
						return true;
					else
					{
						outer_.Release();
						return false;
					}
				}
				catch (System.Threading.ThreadInterruptedException ex)
				{
					outer_.Release();
					throw ex;
				}
			}
			else
				return false;
		}
		
        /// <summary>
        /// Relese outer and inner
        /// </summary>
		public virtual void  Release()
		{
			inner_.Release();
			outer_.Release();
		}
	}
}