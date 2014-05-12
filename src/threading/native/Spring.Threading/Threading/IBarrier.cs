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

namespace Spring.Threading
{
    /// <summary> 
    /// Barriers serve
    /// as synchronization points for groups of threads that
    /// must occasionally wait for each other. 
    /// Barriers may support any of several methods that
    /// accomplish this synchronization. This interface
    /// merely expresses their minimal commonalities:    /// 
    /// <ul>
    /// <li> Every barrier is defined for a given number
    /// of <code>parties</code> -- the number of threads
    /// that must meet at the barrier point. (In all current
    /// implementations, this
    /// value is fixed upon construction of the Barrier.)
    /// </li>
    /// <li> A barrier can become <code>broken</code> if
    /// one or more threads leave a barrier point prematurely,
    /// generally due to interruption or timeout. Corresponding
    /// synchronization methods in barriers fail, throwing
    /// BrokenBarrierException for other threads
    /// when barriers are in broken states.
    /// </li>
    /// </ul>
    /// 
    /// </summary>
    public interface IBarrier
    {
        /// <summary> 
        /// Return the number of parties that must meet per barrier
        /// point. The number of parties is always at least 1.
        /// </summary>
        int Parties { get; }


        /// <summary> 
        /// Returns true if the barrier has been compromised
        /// by threads leaving the barrier before a synchronization
        /// point (normally due to interruption or timeout). 
        /// </summary>
        /// <remarks>
        /// Barrier methods in implementation classes
        /// throw <see cref="Spring.Threading.BrokenBarrierException"/> upon detection of breakage.
        /// Implementations may also support some means
        /// to clear this status.
        /// </remarks>
        bool IsBroken { get; }
    }
}