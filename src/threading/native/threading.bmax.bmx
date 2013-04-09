Rem
Copyright (c) 2011 Steve Revill and Shane Woolcock
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
EndRem

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
	EndMethod
	
	Method ExtJoin()
		If Not m_started Then Return
		m_thread.Wait()
	EndMethod
	
	Method ExtRunning:Int()
		Return m_thread.Running()
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

