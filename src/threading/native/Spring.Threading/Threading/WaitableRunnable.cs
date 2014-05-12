//using System;

//#region License
//*
//* Copyright © 2002-2005 the original author or authors.
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
//namespace Spring.Threading
//{
//    /// <summary>
//    /// A runnable object that can be waited.
//    /// Runs the embeeded runnable and release an (optionally given) 
//    /// <see cref="ISync"/> object.
//    /// <p>Its main use is to wait for object executed by 
//    /// an executor using a secondary thread.
//    /// </p>
//    /// </summary>
//    /// <seealso cref="ThreadedExecutor"/>
//    /// <seealso cref="QueuedExecutor"/>
//    public class WaitableRunnable : NullRunnable, IDisposable
//    {
//        private readonly IRunnable _runnable;
//        private readonly ISync _sync;

//        /// <summary>
//        /// Initialize a new instance with the given <see cref="IRunnable"/>
//        /// and a <see cref="Latch"/> as the waitable <see cref="ISync"/>
//        /// </summary>
//        /// <param name="runnable">the embeeded <see cref="IRunnable"/></param>
//        public WaitableRunnable (IRunnable runnable)
//            : this (runnable, new Latch())
//        {
//        }

//        /// <summary>
//        /// Initialize a new instance with the given <see cref="IRunnable"/>
//        /// and <see cref="ISync"/>
//        /// </summary>
//        /// <param name="runnable">the embeeded <see cref="IRunnable"/></param>
//        /// <param name="sync">the synchronizing <see cref="ISync"/></param>
//        public WaitableRunnable (IRunnable runnable, ISync sync)
//        {
//            _sync = sync;
//            _runnable = runnable;
//        }

//        /// <summary>
//        /// Will execute its <see cref="IRunnable"/> and then 
//        /// will release its <see cref="ISync"/>
//        /// <see cref="IRunnable.Run"/>
//        /// </summary>
//        public override void Run ()
//        {
//            _runnable.Run();
//            _sync.Release();
//        }

//        /// <summary>
//        /// Indefinitely waits the execution of the embeeded <see cref="IRunnable"/>
//        /// </summary>
//        public void Wait ()
//        {
//            _sync.Acquire();
//        }

//        /// <summary>
//        /// Waits the execution of the embeeded <see cref="IRunnable"/> for a given amount
//        /// of time
//        /// </summary>
//        /// <param name="msecs">how long to wait in milliseconds</param>
//        public void Wait (long msecs)
//        {
//            _sync.Attempt(msecs);
//        }

//        /// <summary>
//        /// Identical to <see cref="M:Wait"/> but useful with the 
//        /// <c>using</c> semantic.
//        /// </summary>
//        public void Dispose()
//        {
//            Wait();
//        }
//    }
//}