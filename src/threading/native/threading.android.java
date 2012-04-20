import java.util.concurrent.locks.ReentrantLock;
import java.util.concurrent.locks.Condition;
import java.util.concurrent.TimeUnit;

abstract class ExtThread {
	Thread m_thread;
	Runner m_runner;
	boolean m_started;
	volatile boolean m_finished;
	boolean m_cancelled;
	Object[] m_runningSemaphore = new Object[0];
	
	private class Runner implements Runnable {
		public void run() {
			m_cancelled = false;
			try {
				ExtRun();
			} catch(RuntimeException e) {
				m_cancelled = true;
			}
			synchronized(m_runningSemaphore) {
				m_finished = true;
				m_runningSemaphore.notifyAll();
			}
		}
	}
	
	public void ExtStart() {
		if(m_cancelled || m_finished) return;
		if (!m_started) {
			m_started = true;
			m_runner = new Runner();
			m_thread = new Thread(m_runner);
			m_thread.start();
		}
	}
	
	public void ExtCancel() {
		if(!m_started || m_cancelled || m_finished) return;
		try {
			m_thread.interrupt();
		} catch(SecurityException e) {
		}
	}
	
	public void ExtJoin() {
		if(!m_started || m_cancelled || m_finished) return;
		synchronized(m_runningSemaphore) {
			while(!m_finished && !m_cancelled) {
				try {
					m_runningSemaphore.wait(100);
				} catch(InterruptedException e) {
					throw new RuntimeException(e);
				}
			}
		}
	}
	
	public int ExtRunning() {
		return m_started && !m_finished && !m_cancelled ? 1 : 0;
	}
	
	public abstract void ExtRun();
}

class ExtMutex {
	ReentrantLock m_lock = new ReentrantLock();
	
	public void ExtLock() {
		m_lock.lock();
	}
	
	public void ExtUnlock() {
		m_lock.unlock();
	}
	
	public int ExtTryLock() {
		return m_lock.tryLock()?1:0;
	}
}

class ExtCondVar {
	Condition m_cond;
	
	public void ExtInit(ExtMutex mutex) {
		m_cond = mutex.m_lock.newCondition();
	}
	
	public void ExtWait(ExtMutex mutex) {
		if(Thread.currentThread().isInterrupted()) {
			throw new RuntimeException(new InterruptedException());
		}
		try {
			m_cond.await();
		} catch(InterruptedException e) {
			throw new RuntimeException(e);
		}
	}
	
	public void ExtTimedWait(ExtMutex mutex, float timeout) {
		if(Thread.currentThread().isInterrupted()) {
			throw new RuntimeException(new InterruptedException());
		}
		try {
			m_cond.await((long)timeout, TimeUnit.MILLISECONDS);
		} catch(InterruptedException e) {
			throw new RuntimeException(e);
		}
	}
	
	public void ExtSignal() {
		m_cond.signal();
	}
	
	public void ExtBroadcast() {
		m_cond.signalAll();
	}
}
