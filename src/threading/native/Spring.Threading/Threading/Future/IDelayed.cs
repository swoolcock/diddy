#region License
/*
* Copyright (C) 2002-2009 the original author or authors.
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

namespace Spring.Threading.Future
{
	/// <summary> 
	/// A mix-in style interface for marking objects that should be
	/// acted upon after a given delay.
	/// </summary>
	/// <remarks> 
	/// <p/>
	/// An implementation of this interface must define a
	/// <see cref="System.IComparable.CompareTo(object)"/> method that provides an ordering consistent with
	/// its <see cref="Spring.Threading.Future.IDelayed.GetRemainingDelay()"/> method.
	/// </remarks>
	/// <author>Doug Lea</author>
	/// <author>Griffin Caprio (.NET)</author>
	/// <changes>
	/// <ol>
	/// <li>Changed GetDelay return type from long to TimeSpan, and remove parameter.</li>
	/// </ol>
	/// </changes>
	public interface IDelayed : IComparable<IDelayed>, IComparable
	{
		/// <summary> 
		/// Returns the remaining delay associated with this object
		/// </summary>
		/// <returns>the remaining delay; zero or negative values indicate
		/// that the delay has already elapsed
		/// </returns>
		TimeSpan GetRemainingDelay();
	}
}