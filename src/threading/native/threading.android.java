import java.util.concurrent.locks.ReentrantLock;
import java.util.concurrent.locks.Condition;
import java.util.concurrent.TimeUnit;

abstract class ExtThread {
	Thread m_thread;
	Runner m_runner;
	boolean m_started;
	boolean m_finished;
	Object[] m_runningSemaphore = new Object[0];
	
	private class Runner implements Runnable {
		public void run() {
			ExtRun();
			synchronized(m_runningSemaphore) {
				m_finished = true;
				m_runningSemaphore.notify();
			}
		}
	}
	
	public void ExtStart() {
		if (!m_started) {
			m_started = true;
			m_runner = new Runner();
			m_thread = new Thread(m_runner);
			m_thread.start();
		}
	}
	
	public void ExtCancel() {
		// can't cancel in java?
	}
	
	public void ExtJoin() {
		synchronized(m_runningSemaphore) {
			try {
				while(!m_finished) {
					m_runningSemaphore.wait(100);
				}
			} catch(InterruptedException ex) {
			}
		}
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
		try {
			m_cond.await();
		} catch(InterruptedException e) {
			throw new RuntimeException(e);
		}
	}
	
	public void ExtTimedWait(ExtMutex mutex, float timeout) {
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
