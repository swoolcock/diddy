using tthread::thread;
using tthread::mutex;
using tthread::condition_variable;

class ExtThread : public Object {
public:
	thread *m_thread;
	int m_started;
	int m_finished;
	
	ExtThread() : m_started(0), m_finished(0) {
	}
	
	~ExtThread() {
		if(m_thread) {
			delete(m_thread);
			m_thread = NULL;
		}
	}
	
	virtual void ExtRun() = 0;
	
	void ExtStart() {
		if(!m_started) {
			m_started = 1;
			m_thread = new thread(ExtThread::ExecuteThread, this);
		}
	}
	
	void ExtCancel() {
		if(!m_started) return;
		//TODO cancel thread
	}
	
	void ExtJoin() {
		if(!m_started) return;
		m_thread->join();
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

