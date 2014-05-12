//#region License
//*
//* Copyright ?2002-2005 the original author or authors.
//* 
//* Licensed under the Apache License, Version 2.0 (the "License");
//* you may not use this file except in compliance with the License.
//* You may obtain a copy of the License at
//* 
//*      http://www.apache.org/licenses/LICENSE-2.0
//* 
//* Unless required by applicable law or agreed to in writing, software
//* distributed under the License is distributed on an "AS IS" BASIS,
//* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//* See the License for the specific language governing permissions and
//* limitations under the License.
//*/
//#endregion

//*
//TimedCallable.java

//Originally written by Joseph Bowbeer and released into the public domain.
//This may be used for any purposes whatsoever without acknowledgment.

//Originally part of jozart.swingutils.
//Adapted by Doug Lea for util.concurrent.

//History:
//Date       Who                What
//11dec1999   dl                Adapted for util.concurrent

//*/
//using System;
//using System.Threading;

//namespace Spring.Threading {

//    /// <summary> TimedCallable runs a Callable function for a given length of time.
//    /// The function is run in its own thread. If the function completes
//    /// in time, its result is returned; otherwise the thread is interrupted
//    /// and an InterruptedException is thrown.
//    /// <p>
//    /// Note: TimedCallable will always return within the given time limit
//    /// (modulo timer inaccuracies), but whether or not the worker thread
//    /// stops in a timely fashion depends on the interrupt handling in the
//    /// Callable function's implementation. 
//    /// </p>
//    /// </summary>
//    /// <author>   Joseph Bowbeer
//    /// </author>
//    /// <version>  1.0
//    /// </version>

//    public class TimedCallable<T> : ThreadFactoryUser, ICallable<T> {

//        private readonly ICallable<T> function;
//        private readonly long millis;

//        /// <summary>
//        /// Creates a new <see cref="TimedCallable"/> instance.
//        /// </summary>
//        /// <param name="function">what to call</param>
//        /// <param name="millis">how much wait</param>
//        public TimedCallable(ICallable<T> function, long millis) {
//            this.function = function;
//            this.millis = millis;
//        }


//        /// <summary>
//        /// <see cref="ICallable{T}.Call"/>
//        /// </summary>
//        /// <returns></returns>
//        public virtual T Call() {

//            FutureResult result = new FutureResult();

//            Thread thread = ThreadFactory.NewThread(result.Setter(function));

//            thread.Start();

//            try {
//                return result.TimedGet(millis);
//            }
//            catch(System.Threading.ThreadInterruptedException ex) {
//                /* Stop thread if we were interrupted or timed-out
//                while waiting for the result. */
//                thread.Interrupt();
//                throw ex;
//            }
//        }
//    }
//}