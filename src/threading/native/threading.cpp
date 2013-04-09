/*
Copyright (c) 2011 Steve Revill and Shane Woolcock
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

using tthread::thread;
using tthread::mutex;
using tthread::condition_variable;

class ExtThread : public Object {
public:
	thread *m_thread;
	int m_started;
	int m_finished;
	int m_cancelled;
	
	ExtThread() : m_started(0), m_finished(0), m_cancelled(0) {
	}
	
	~ExtThread() {
		if(m_thread) {
			delete(m_thread);
			m_thread = NULL;
		}
	}
	
	virtual void ExtRun() = 0;
	
	void ExtStart() {
		if(m_cancelled || m_finished) return;
		if(!m_started) {
			m_started = 1;
			m_thread = new thread(ExtThread::ExecuteThread, this);
		}
	}
	
	void ExtCancel() {
		if(!m_started || m_finished || m_cancelled) return;
		//TODO cancel thread
	}
	
	void ExtJoin() {
		if(!m_started || m_finished || m_cancelled) return;
		m_thread->join();
	}
	
	int ExtRunning() {
		return m_started && !m_finished && !m_cancelled ? 1 : 0;
	}
	
	static void ExecuteThread(void *arg) {
		ExtThread *t = (ExtThread *)arg;
		t->ExtRun();
		t->m_finished = 1;
	}
};

class ExtMutex : public Object {
public:
	mutex m_mutex;
	
	ExtMutex() {
	}
	
	void ExtLock() {
		m_mutex.lock();
	}
	
	void ExtUnlock() {
		m_mutex.unlock();
	}
	
	int ExtTryLock() {
		return m_mutex.try_lock()?1:0;
	}
};

class ExtCondVar : public Object {
public:
	condition_variable m_condvar;
	
	ExtCondVar() {
	}
	
	void ExtInit(ExtMutex *mut) {
		// unnecessary
	}
	
	void ExtWait(ExtMutex *mut) {
		m_condvar.wait(mut->m_mutex);
	}
	
	void ExtTimedWait(ExtMutex *mut, float timeout) {
		// not supported in tinythread
	}
	
	void ExtSignal() {
		m_condvar.notify_one();
	}
	
	void ExtBroadcast() {
		m_condvar.notify_all();
	}
};

