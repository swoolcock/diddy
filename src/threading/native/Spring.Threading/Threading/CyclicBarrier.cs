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

using System;
using System.Threading;

namespace Spring.Threading
{
    /// <summary> 
    /// A synchronization aid that allows a set of threads to all wait for
    /// each other to reach a common barrier point.  
    /// </summary>
    /// <remarks>
    /// <see cref="Spring.Threading.CyclicBarrier"/> are useful in programs involving a fixed sized party of threads that
    /// must occasionally wait for each other. The barrier is called
    /// <i>cyclic</i> because it can be re-used after the waiting threads
    /// are released.
    /// 
    /// <p/>
    /// A <see cref="Spring.Threading.CyclicBarrier"/> supports an optional <see cref="Spring.Threading.IRunnable"/> command
    /// that is run once per barrier point, after the last thread in the party
    /// arrives, but before any threads are released.
    /// This <i>barrier action</i> is useful
    /// for updating shared-state before any of the parties continue.
    /// 
    /// <p/> 
    /// If the barrier action does not rely on the parties being suspended when
    /// it is executed, then any of the threads in the party could execute that
    /// action when it is released. To facilitate this, each invocation of
    /// <see cref="M:Spring.Threading.CyclicBarrier.Await"/> returns the arrival index of that thread at the barrier.
    /// You can then choose which thread should execute the barrier action, for
    /// example:
    /// <code>
    /// if (barrier.Await() == 0) {
    ///		// log the completion of this iteration
    /// }
    /// </code>
    /// 
    /// <p/>
    /// The <see cref="Spring.Threading.CyclicBarrier"/> uses an all-or-none breakage model
    /// for failed synchronization attempts: If a thread leaves a barrier
    /// point prematurely because of interruption, failure, or timeout, all
    /// other threads waiting at that barrier point will also leave
    /// abnormally via <see cref="Spring.Threading.BrokenBarrierException"/> (or
    /// <see cref="System.Threading.ThreadInterruptedException"/> if they too were interrupted at about
    /// the same time).
    /// </remarks>
    /// <example>
    /// <b>Sample usage:</b> 
    /// Here is an example of using a barrier in a parallel decomposition design:
    /// <code>
    /// public class Solver {
    ///		int N;
    /// 	float[][] data;
    /// 	CyclicBarrier barrier;
    /// 
    /// 	internal class Worker : IRunnable {
    ///			int myRow;
    /// 		Worker(int row) { myRow = row; }
    /// 		public void Run() {
    /// 				while (!IsDone) {
    /// 					processRow(myRow);
    /// 
    ///						try {
    /// 						barrier.Await();
    /// 					} catch (ThreadInterruptedException ex) {
    ///							return;
    ///						} catch (BrokenBarrierException ex) {
    ///							return;
    ///						}
    /// 				}
    ///			}
    ///			private void processRow(int myRow ) {
    ///				// Process row....
    ///			}
    ///			private bool IsDone { get { ..... } }
    ///		}
    ///		internal class DataMerger : IRunnable  {
    ///			public void Run() {
    ///				// Merge Rows.....
    ///			}
    ///		}
    ///		public Solver(float[][] matrix) {
    ///			data = matrix;
    /// 		N = matrix.length;
    /// 		barrier = new CyclicBarrier(N, new DataMerger());
    ///			for (int i = 0; i &lt; N; ++i)
    ///				new Thread(new ThreadStart(new Worker(i).Run)).Start();
    /// 
    ///			WaitUntilDone();
    ///		}
    /// }
    /// </code>
    /// <p/>
    /// Here, each worker thread processes a row of the matrix then waits at the
    /// barrier until all rows have been processed. When all rows are processed
    /// the supplied <see cref="Spring.Threading.IRunnable"/> barrier action is executed and merges the
    /// rows. If the merger determines that a solution has been found then IsDone will return
    /// <see lang="true"/> and each worker will terminate. 
    /// </example>
    /// <seealso cref="Spring.Threading.Helpers.CountDownLatch"/>
    /// <author>Doug Lea</author>
    /// <author>Federico Spinazzi (.Net)</author>
    /// <author>Griffin Caprio (.Net)</author>
    public class CyclicBarrier : IBarrier
    {
        /// <summary>The lock for guarding barrier entry </summary>
        private readonly Object _internalBarrierEntryLock = new Object();

        /// <summary>The number of parties </summary>
        private readonly int _parties;

        /// <summary>
        /// The <see cref="Spring.Threading.IRunnable"/> to run when tripped
        /// </summary>
        private readonly IRunnable _barrierCommand;

        /// <summary>The current generation </summary>
        private Generation _generation;

        /// <summary> 
        /// Number of parties still waiting. Counts down from <see cref="Spring.Threading.CyclicBarrier.Parties"/> to 0
        /// on each generation.  It is reset to <see cref="Spring.Threading.CyclicBarrier.Parties"/> on each new
        /// generation or when broken.
        /// </summary>
        private int _waitingPartiesCount;

        /// <summary> 
        /// Each use of the barrier is represented as a generation instance.
        /// </summary>
        /// <remarks>
        /// The generation changes whenever the barrier is tripped, or
        /// is reset. There can be many generations associated with threads
        /// using the barrier - due to the non-deterministic way the lock
        /// may be allocated to waiting threads - but only one of these
        /// can be active at a time and all the rest are either broken or tripped.
        /// There need not be an active generation if there has been a break
        /// but no subsequent reset.
        /// </remarks>
        private class Generation
        {
            internal bool isBroken;
            internal bool isTripped;
        }

        /// <summary> 
        /// Return the number of parties that must meet per barrier
        /// point. The number of parties is always at least 1.
        /// </summary>
        public int Parties
        {
            get { return _parties; }

        }

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
        public bool IsBroken
        {
            get
            {
                lock (_internalBarrierEntryLock)
                {
                    return _generation.isBroken;
                }
            }

        }

        /// <summary> 
        /// Returns the number of parties currently waiting at the barrier.
        /// This method is primarily useful for debugging and assertions.
        /// </summary>
        /// <returns> the number of parties currently blocked in <see cref="M:Spring.Threading.CyclicBarrier.Await"/>.</returns>
        public virtual int NumberOfWaitingParties
        {
            get
            {
                lock (_internalBarrierEntryLock)
                {
                    return _parties - _waitingPartiesCount;
                }
            }

        }

        /// <summary> 
        /// Updates state on barrier trip and wakes up everyone.
        /// Called only while holding lock.
        /// </summary>
        private void nextGeneration()
        {
            _generation.isTripped = true;
            Monitor.PulseAll(_internalBarrierEntryLock);
            _waitingPartiesCount = _parties;
            _generation = new Generation();
        }

        /// <summary> 
        /// Sets current barrier generation as broken and wakes up everyone.
        /// Called only while holding lock.
        /// </summary>
        private void breakBarrier()
        {
            _generation.isBroken = true;
            _waitingPartiesCount = _parties;
            Monitor.PulseAll(_internalBarrierEntryLock);
        }

        /// <summary> Main barrier code, covering the various policies.</summary>
        private int doWait(bool timed, TimeSpan duration)
        {
            lock (_internalBarrierEntryLock)
            {
                Generation currentGeneration = _generation;

                if (currentGeneration.isBroken)
                    throw new BrokenBarrierException();

                int index = --_waitingPartiesCount;
                if (index == 0)
                {
                    bool ranAction = false;
                    try
                    {
                        IRunnable command = _barrierCommand;
                        if (command != null)
                            command.Run();
                        ranAction = true;
                        nextGeneration();
                        return 0;
                    }
                    finally
                    {
                        if (!ranAction)
                            breakBarrier();
                    }
                }

                // loop until tripped, broken, interrupted, or timed out
                TimeSpan durationToWait = duration;
                DateTime deadline = timed ? DateTime.Now.Add(duration) : DateTime.MaxValue;
                for (;;)
                {
                    try
                    {
                        if (!timed)
                            Monitor.Wait(_internalBarrierEntryLock);
                        else if (durationToWait.Ticks > 0)
                            Monitor.Wait(_internalBarrierEntryLock, durationToWait);
                    }
                    catch (ThreadInterruptedException)
                    {
                        breakBarrier();
                        throw;
                    }

                    if (currentGeneration.isBroken)
                        throw new BrokenBarrierException();

                    if (currentGeneration.isTripped)
                        return index;

                    if (timed && duration.Ticks <= 0)
                    {
                        breakBarrier();
                        throw new TimeoutException();
                    }
                    durationToWait = deadline.Subtract(DateTime.Now);
                }
            }
        }

        /// <summary> 
        /// Creates a new <see cref="Spring.Threading.CyclicBarrier.Parties"/> that will trip when the
        /// given number of <paramref name="parties"/> (threads) are waiting upon it, and which
        /// will execute the given barrier action when the barrier is tripped,
        /// performed by the last thread entering the barrier.
        /// </summary>
        /// <param name="parties">the number of threads that must invoke <see cref="M:Spring.Threading.CyclicBarrier.Await"/>
        /// before the barrier is tripped.
        /// </param>
        /// <param name="barrierAction">the <see cref="Spring.Threading.IRunnable"/> to execute when the barrier is
        /// tripped, or <see lang="null"/>  if there is no action.
        /// </param>
        /// <exception cref="System.ArgumentException">if <paramref name="parties"/> is less than 1.</exception>
        /// <exception cref="ArgumentNullException">if <paramref name="barrierAction"/> is null.</exception>
        public CyclicBarrier(int parties, IRunnable barrierAction)
        {
            if (parties <= 0)
            {
                throw new ArgumentException();
            }
            _parties = parties;
            _waitingPartiesCount = parties;
            _barrierCommand = barrierAction;
            _generation = new Generation();
        }

        /// <summary> 
        /// Creates a new <see cref="Spring.Threading.CyclicBarrier.Parties"/> that will trip when the
        /// given number of <paramref name="parties"/> (threads) are waiting upon it, and
        /// does not perform a predefined action when the barrier is tripped.
        /// </summary>
        /// <param name="parties">the number of threads that must invoke <see cref="M:Spring.Threading.CyclicBarrier.Await"/>
        /// before the barrier is tripped.
        /// </param>
        /// <exception cref="System.ArgumentException">if <paramref name="parties"/> is less than 1.</exception>
        public CyclicBarrier(int parties) : this(parties, null)
        {
        }

        /// <summary> 
        /// Waits until all <see cref="Spring.Threading.CyclicBarrier.Parties"/>  have invoked <see cref="M:Spring.Threading.CyclicBarrier.Await"/>
        /// on this barrier.
        /// </summary>
        /// <remarks> 
        /// If the current thread is not the last to arrive then it is
        /// disabled for thread scheduling purposes and lies dormant until
        /// one of following things happens:
        /// <ul>
        /// <li>The last thread arrives</li>
        /// <li>Some other thread calls <see cref="System.Threading.Thread.Interrupt()"/> on the current
        /// thread</li>
        /// <li>Some other thread calls <see cref="System.Threading.Thread.Interrupt()"/> one of the
        /// other waiting threads</li>
        /// <li>Some other thread times out while waiting for barrier</li>
        /// <li>Some other thread invokes <see cref="Spring.Threading.CyclicBarrier.Reset()"/> on this barrier.</li>
        /// </ul>
        /// <p/>
        /// If some other thread calls <see cref="System.Threading.Thread.Interrupt()"/> on this thread, 
        /// a <see cref="System.Threading.ThreadInterruptedException"/> will be thrown.
        /// 
        /// <p/>
        /// If the barrier is <see cref="Spring.Threading.CyclicBarrier.IsBroken"/> while any thread is waiting, or if
        /// the barrier <see cref="Spring.Threading.CyclicBarrier.IsBroken"/> when <see cref="M:Spring.Threading.CyclicBarrier.Await"/> is invoked,
        /// or while any thread is waiting, then a <see cref="Spring.Threading.BrokenBarrierException"/> is thrown.
        /// 
        /// <p/>
        /// If any thread is interrupted while waiting, then all other waiting threads will throw
        /// <see cref="Spring.Threading.BrokenBarrierException"/> and the barrier is placed in the broken
        /// state.
        /// 
        /// <p/>
        /// If the current thread is the last thread to arrive, and a
        /// non-null barrier action was supplied in the constructor, then the
        /// current thread runs the action before allowing the other threads to
        /// continue. If an exception occurs during the barrier action then that exception
        /// will be propagated in the current thread and the barrier is placed in
        /// the broken state.
        /// </remarks>
        /// <returns>the arrival index of the current thread, where an index of <see cref="Spring.Threading.CyclicBarrier.Parties"/> - 1
        /// indicates the first to arrive and zero indicates the last to arrive.
        /// </returns>
        /// <exception cref="System.Threading.ThreadInterruptedException">if the current thread was interrupted.</exception>
        /// <exception cref="Spring.Threading.BrokenBarrierException">if another thread as interrupted or timed out while the current
        /// thread was waiting, or the barrier was reset, or the barrier was broken when <see cref="M:Spring.Threading.CyclicBarrier.Await"/> was called, or
        /// the barrier action ( if present ) failed due to an exception.</exception>
        public virtual int Await()
        {
            try
            {
                return doWait(false, new TimeSpan(0));
            }
            catch (ThreadInterruptedException)
            {
                breakBarrier();
                throw;
            }
        }

        /// <summary> 
        /// Waits until all <see cref="Spring.Threading.CyclicBarrier.Parties"/>  have invoked <see cref="M:Spring.Threading.CyclicBarrier.Await"/>
        /// on this barrier.
        /// </summary>
        /// <remarks> 
        /// If the current thread is not the last to arrive then it is
        /// disabled for thread scheduling purposes and lies dormant until
        /// one of following things happens:
        /// <ul>
        /// <li>The last thread arrives</li>
        /// <li>The specified timeout elapses</li>
        /// <li>Some other thread calls <see cref="System.Threading.Thread.Interrupt()"/> on the current
        /// thread</li>
        /// <li>Some other thread calls <see cref="System.Threading.Thread.Interrupt()"/> one of the
        /// other waiting threads</li>
        /// <li>Some other thread times out while waiting for barrier</li>
        /// <li>Some other thread invokes <see cref="Spring.Threading.CyclicBarrier.Reset()"/> on this barrier.</li>
        /// </ul>
        /// <p/>
        /// If some other thread calls <see cref="System.Threading.Thread.Interrupt()"/> on this thread, 
        /// a <see cref="System.Threading.ThreadInterruptedException"/> will be thrown.
        /// 
        /// <p/>
        /// If the specified <parmref name="durationToWait"/> elapses then a <see cref="Spring.Threading.TimeoutException"/>
        /// is thrown. If the time is less than or equal to zero, the
        /// method will not wait at all.
        /// <p/>
        /// If the barrier is <see cref="Spring.Threading.CyclicBarrier.IsBroken"/> while any thread is waiting, or if
        /// the barrier <see cref="Spring.Threading.CyclicBarrier.IsBroken"/> when <see cref="M:Spring.Threading.CyclicBarrier.Await"/> is invoked,
        /// or while any thread is waiting, then a <see cref="Spring.Threading.BrokenBarrierException"/> is thrown.
        /// 
        /// <p/>
        /// If any thread is interrupted while waiting, then all other waiting threads will throw
        /// <see cref="Spring.Threading.BrokenBarrierException"/> and the barrier is placed in the broken
        /// state.
        /// 
        /// <p/>
        /// If the current thread is the last thread to arrive, and a
        /// non-null barrier action was supplied in the constructor, then the
        /// current thread runs the action before allowing the other threads to
        /// continue. If an exception occurs during the barrier action then that exception
        /// will be propagated in the current thread and the barrier is placed in
        /// the broken state.
        /// </remarks>
        /// <returns>the arrival index of the current thread, where an index of <see cref="Spring.Threading.CyclicBarrier.Parties"/> - 1
        /// indicates the first to arrive and zero indicates the last to arrive.
        /// </returns>
        /// <exception cref="System.Threading.ThreadInterruptedException">if the current thread was interrupted.</exception>
        /// <exception cref="Spring.Threading.BrokenBarrierException">if another thread as interrupted or timed out while the current
        /// thread was waiting, or the barrier was reset, or the barrier was broken when <see cref="M:Spring.Threading.CyclicBarrier.Await"/> was called, or
        /// the barrier action ( if present ) failed due to an exception.</exception>
        public int Await(TimeSpan durationToWait)
        {
            try
            {
                return doWait(false, durationToWait);
            }
            catch (ThreadInterruptedException)
            {
                breakBarrier();
                throw;
            }
        }

        /// <summary> 
        /// Resets the barrier to its initial state.  
        /// </summary>
        /// <remarks>
        /// If any parties are currently waiting at the barrier, they will return with a
        /// <see cref="Spring.Threading.BrokenBarrierException"/>. Note that resets <i>after</i>
        /// a breakage has occurred for other reasons can be complicated to
        /// carry out; threads need to re-synchronize in some other way,
        /// and choose one to perform the reset.  It may be preferable to
        /// instead create a new barrier for subsequent use.
        /// </remarks>
        public void Reset()
        {
            lock (_internalBarrierEntryLock)
            {
                breakBarrier();
                nextGeneration();
            }
        }
    }
}