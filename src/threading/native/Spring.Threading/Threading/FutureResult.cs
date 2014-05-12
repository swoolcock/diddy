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

/*
File: FutureResult.java

Originally written by Doug Lea and released into the public domain.
This may be used for any purposes whatsoever without acknowledgment.
Thanks for the assistance and support of Sun Microsystems Labs,
and everyone contributing, testing, and using this code.

History:
Date       Who                What
30Jun1998  dl               Create public version
 */
using System;
using System.Reflection;
using System.Threading;

namespace Spring.Threading
{
    /// <summary>
    /// A  class maintaining a single variable serving as the result
    /// of an operation. The result cannot be accessed until it has been set.
    /// </summary>
    /// <remarks>
    /// <example>Sample Usage 
    /// <code language="c#">
    /// class ImageRenderer { Image render(byte[] raw); }
    /// class App {
    ///   Executor executor = ...
    ///   ImageRenderer renderer = ...
    ///   void display(byte[] rawimage) {
    ///     try {
    ///       FutureResult&lt;Image&gt; futureImage = new FutureResult&lt;Image&gt;();
    ///       Runnable command = futureImage.setter(new delegate {
    ///         return renderer.render(rawImage);
    ///       });
    ///       executor.execute(command);
    ///       drawBorders();             // do other things while executing
    ///       drawCaption();
    ///       drawImage(futureImage.get()); // use future
    ///     }
    ///     catch (InterruptedException ex) { return; }
    ///     catch (InvocationTargetException ex) { cleanup(); return; }
    ///   }
    /// }
    /// </code>
    /// </example>
    /// </remarks>
    /// <seealso cref="IExecutor"/>
    /// <seealso cref="FutureResult"/>
    /// <author>Kenneth Xu (copy from non-generic FutureResult class)</author>
    // TODO: 
    // This is kind of dirty implementation as it is a copy of non-generic
    // FutureResult. Need to figure out a way to reuse the code.
    public class FutureResult<T>
    {
        private class AnonymousClassRunnable : IRunnable
        {
            private readonly Call<T> function;
            private readonly FutureResult<T> enclosingInstance;

            public AnonymousClassRunnable(Call<T> function, FutureResult<T> enclosingInstance)
            {
                this.function = function;
                this.enclosingInstance = enclosingInstance;
            }

            public virtual void Run()
            {
                try
                {
                    enclosingInstance.Value = function();
                }
                catch (Exception ex)
                {
                    enclosingInstance.Exception = ex;
                }
            }
        }
        /// <summary> Return whether the reference or exception have been set.</summary>
        /// <returns> true if has been set. else false
        /// </returns>
        virtual public bool Ready
        {
            get
            {
                lock (this)
                {
                    return ready_;
                }
            }

        }
        /// <summary>The result of the operation *</summary>
        protected internal T value_;

        /// <summary>Status -- true after first set *</summary>
        protected internal bool ready_ = false;

        /// <summary>the exception encountered by operation producing result *</summary>
        protected internal TargetInvocationException exception_ = null;


        /// <summary>
        /// Return a Runnable object that, when run, will set the result value.
        /// </summary>
        /// <param name="function">
        /// A <see cref="Call{T}"/> delegate whose return result will be
        /// held by this <see cref="FutureResult{T}"/>.
        /// </param>
        /// <returns>
        /// An <see cref="IRunnable"/> object that, when run, will call the
        /// function and (eventually) set the result.
        /// </returns>		
        public virtual IRunnable Setter(Call<T> function)
        {
            return new AnonymousClassRunnable(function, this);
        }

        /// <summary>
        /// Return a Runnable object that, when run, will set the result value.
        /// </summary>
        /// <param name="function">
        /// A <see cref="ICallable{T}"/> object whose result will be
        /// held by this <see cref="FutureResult{T}"/>.
        /// </param>
        /// <returns>
        /// An <see cref="IRunnable"/> object that, when run, will call the
        /// function and (eventually) set the result.
        /// </returns>		
        public virtual IRunnable Setter(ICallable<T> function)
        {
            return Setter(function.Call);
        }

        /// <summary>internal utility: either get the value or throw the exception *</summary>
        protected internal virtual T DoGet()
        {
            if (exception_ != null)
            {
                throw exception_;
            }
            else
            {
                return value_;
            }
        }

        /// <summary>
        /// The value of the call.
        /// </summary>
        public virtual T Value
        {
            get
            {
                lock (this)
                {
                    while (!ready_)
                    {
                        Monitor.Wait(this);
                    }
                    return DoGet();
                }
            }
            set
            {
                lock (this)
                {
                    value_ = value;
                    ready_ = true;
                    Monitor.PulseAll(this);
                }
            }
        }


        /// <summary> Wait at most msecs to access the reference.</summary>
        /// <returns> current value
        /// </returns>
        /// <exception cref="TimeoutException">  if not ready after msecs
        /// </exception>
        /// <exception cref="ThreadInterruptedException">  if current thread has been interrupted
        /// </exception>
        /// <exception cref="TargetInvocationException">  if the operation
        /// producing the value encountered an exception.
        /// 
        /// </exception>
        public virtual T TimedGet(long msecs)
        {
            lock (this)
            {
                long startTime = (msecs <= 0) ? 0 : Utils.CurrentTimeMillis;
                long waitTime = msecs;
                if (ready_)
                {
                    return DoGet();
                }
                else if (waitTime <= 0)
                {
                    throw new TimeoutException(msecs);
                }
                else
                {
                    for (; ; )
                    {
                        Monitor.Wait(this, TimeSpan.FromMilliseconds(waitTime));
                        if (ready_)
                        {
                            return DoGet();
                        }
                        else
                        {
                            waitTime = msecs - (Utils.CurrentTimeMillis - startTime);
                            if (waitTime <= 0)
                            {
                                throw new TimeoutException(msecs);
                            }
                        }
                    }
                }
            }
        }

        /// <summary> Sets (or gets) the exception field, also setting ready status.
        /// The exception. It will be reported out wrapped
        /// within an <see cref="TargetInvocationException"/> 
        /// </summary>
        public virtual Exception Exception
        {
            get
            {
                lock (this)
                {
                    return exception_;
                }
            }
            set
            {
                lock (this)
                {
                    exception_ = new TargetInvocationException(value);
                    ready_ = true;
                    Monitor.PulseAll(this);
                }
            }
        }

        /// <summary> Access the reference, even if not ready</summary>
        /// <returns> current value
        /// 
        /// </returns>
        public virtual T Peek()
        {
            lock (this)
            {
                return value_;
            }
        }


        /// <summary> Clear the value and exception and set to not-ready,
        /// allowing this FutureResult to be reused. This is not
        /// particularly recommended and must be done only
        /// when you know that no other object is depending on the
        /// properties of this FutureResult.
        /// 
        /// </summary>
        public virtual void Clear()
        {
            lock (this)
            {
                value_ = default(T);
                exception_ = null;
                ready_ = false;
            }
        }
    }
}
