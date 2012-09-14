Strict

' Check the availability of threading for the target
#If TARGET <> "ios" And TARGET <> "stdcpp" And TARGET <> "glfw" And TARGET <> "android" And TARGET <> "bmax" Then
#Error "Threading is not yet supported for target '${TARGET}'."
#End

Import thread

Public
Class Coroutine Abstract
Public
	Const CREATED:Int = 0
	Const YIELDED:Int = 1
	Const RUNNING:Int = 2
	Const DEAD:Int = 3
	
Private
	Field crThread:CoroutineThread
	Field status:Int
	
Public
	Method Status:Int() Property Final Return status End
	
	Method New()
		status = CREATED
		crThread = New CoroutineThread(Self)
	End
	
	Method Yield:Int(param:Int=0) Final
		Return crThread.Yield(param)
	End
	
	Method Resume:Int(param:Int=0) Final
		Return crThread.Resume(param)
	End
	
	Method Run:Int(param:Int) Abstract
End

Private
Class CoroutineThread Extends Thread Final
Private
	Field cr:Coroutine
	Field crYieldMutex:Mutex
	Field crYieldCondVar:CondVar
	Field yieldValue:Int
	
Public
	Method New(cr:Coroutine)
		Self.cr = cr
		crYieldMutex = New Mutex
		crYieldCondVar = crYieldMutex.CreateCondVar()
	End
	
	Method Run:Object(arg:Object)
		' block until yield mutex is released
		crYieldMutex.Lock()
		crYieldMutex.Unlock()
		' do the coroutine code!
		yieldValue = cr.Run(yieldValue)
		' we're done
		cr.status = Coroutine.DEAD
		' notify
		crYieldMutex.Lock()
			crYieldCondVar.Signal()
		crYieldMutex.Unlock()
		' don't care about return value
		Return Null
	End
	
	' SHOULD ONLY BE CALLED WITHIN THE COROUTINE!
	Method Yield:Int(param:Int=0)
		If cr.status <> Coroutine.RUNNING Then
			' big problem!
			Return -1
		End
		crYieldMutex.Lock()
			cr.status = Coroutine.YIELDED
			yieldValue = param
			crYieldCondVar.Signal()
			crYieldCondVar.Wait()
			param = yieldValue
		crYieldMutex.Unlock()
		Return param
	End
	
	' SHOULD ONLY BE CALLED OUTSIDE THE COROUTINE!
	Method Resume:Int(param:Int=0)
		If cr.status <> Coroutine.YIELDED And cr.status <> Coroutine.CREATED Then
			' big problem!
			Return -1
		End
		crYieldMutex.Lock()
			yieldValue = param
			If cr.status = Coroutine.CREATED Then
				cr.status = Coroutine.RUNNING
				Start()
			Else
				cr.status = Coroutine.RUNNING
				crYieldCondVar.Signal()
			End
			crYieldCondVar.Wait()
			param = yieldValue
		crYieldMutex.Unlock()
		Return param
	End
End
