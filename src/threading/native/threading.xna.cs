/*
Copyright (c) 2011 Steve Revill and Shane Woolcock
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
using Spring.Threading.Locks;

// empty namespaces to allow it to compile if no classes are imported from that namespace!
namespace Spring.Collections {}
namespace Spring.Collections.Generic {}
namespace Spring.Util {}
namespace Spring.Utility {}
namespace Spring.Threading.Collections {}
namespace Spring.Threading.Execution {}
namespace Spring.Threading.Future {}
namespace Spring.Threading.Collections.Generic {}
namespace Spring.Threading.AtomicTypes {}
namespace Spring.Threading.Execution.ExecutionPolicy {}

abstract class ExtThread : Object {
	bool m_started;
	bool m_finished;
	bool m_cancelled;
	ManualResetEvent resetEvent = new ManualResetEvent(false);
	
	public void ExecuteThread(object stateInfo) {
		m_cancelled = false;
		try {
			ExtRun();
		} catch(Exception e) {
			m_cancelled = true;
		}
		m_finished = true;
		resetEvent.Set();
	}
	
	public void ExtStart() {
		if(m_cancelled || m_finished) return;
		if(!m_started) {
			m_started = true;
			ThreadPool.QueueUserWorkItem(new WaitCallback(this.ExecuteThread));
		}
	}
	
	public void ExtCancel() {
		if(!m_started || m_finished || m_cancelled) return;
		//TODO cancel thread
	}
	
	public void ExtJoin() {
		if(!m_started || m_finished || m_cancelled) return;
		resetEvent.WaitOne();
	}
	
	public int ExtRunning() {
		return (m_started && !m_finished && !m_cancelled) ? 1 : 0;
	}
	
	public abstract void ExtRun();
}

class ExtMutex {
	public ILock m_lock = new ReentrantLock();
	
	public void ExtLock() {
		m_lock.Lock();
	}
	
	public void ExtUnlock() {
		m_lock.Unlock();
	}
	
	public int ExtTryLock() {
		return m_lock.TryLock()?1:0;
	}
}

class ExtCondVar {
	public ICondition m_cond;
	
	public void ExtInit(ExtMutex mutex) {
		m_cond = mutex.m_lock.NewCondition();
	}
	
	public void ExtWait(ExtMutex mutex) {
		m_cond.Await();
	}
	
	public void ExtTimedWait(ExtMutex mutex, float timeout) {
		m_cond.Await(TimeSpan.FromMilliseconds(timeout));
	}
	
	public void ExtSignal() {
		m_cond.Signal();
	}
	
	public void ExtBroadcast() {
		m_cond.SignalAll();
	}
}
