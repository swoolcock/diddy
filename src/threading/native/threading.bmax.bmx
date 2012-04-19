Function ExecuteThread:_Object(data:Object)
	Local thread:ExtThread = ExtThread(data)
	thread.ExtRun()
	thread.m_finished = True
	Return Null
EndFunction

Type ExtThread Extends _Object Abstract
	Field m_thread:TThread
	Field m_started:Int = False
	Field m_finished:Int = False
	
	Method ExtRun() Abstract
	
	Method ExtStart()
		If Not m_started Then
			m_started = True
			m_thread = TThread.Create(ExecuteThread, Self)
		EndIf
	EndMethod
	
	Method ExtCancel()
		If Not m_started Then Return
		m_thread.Detach()
	EndMethod
	
	Method ExtJoin()
		If Not m_started Then Return
		m_thread.Wait()
	EndMethod
EndType

Type ExtMutex Extends _Object
	Field m_mutex:TMutex
	
	Method New()
		m_mutex = TMutex.Create()
	EndMethod
	
	Method Delete()
		m_mutex.Close()
	EndMethod
	
	Method ExtLock()
		m_mutex.Lock()
	EndMethod
	
	Method ExtUnlock()
		m_mutex.Unlock()
	EndMethod
	
	Method ExtTryLock:Int()
		Return m_mutex.TryLock()
	EndMethod
EndType

Type ExtCondVar Extends _Object
	Field m_condvar:TCondVar
	
	Method ExtInit(mutex:ExtMutex)
		m_condvar = TCondVar.Create()
	EndMethod
	
	Method Delete()
		m_condvar.Close()
	EndMethod
	
	Method ExtWait(mutex:ExtMutex)
		m_condvar.Wait(mutex.m_mutex)
	EndMethod
	
	Method ExtTimedWait(mutex:ExtMutex, timeout:Float)
		' not supported in max?
	EndMethod
	
	Method ExtSignal()
		m_condvar.Signal()
	EndMethod
	
	Method ExtBroadcast()
		m_condvar.Broadcast()
	EndMethod
EndType

