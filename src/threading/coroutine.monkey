Strict

' Check the availability of threading for the target
#If TARGET <> "ios" And TARGET <> "stdcpp" And TARGET <> "glfw" And TARGET <> "android" And TARGET <> "bmax" Then
#Error "Threading is not yet supported for target '${TARGET}'."
#End

Import thread

Class Coroutine Extends Thread Abstract
Public
	Const CREATED:Int = 0
	Const YIELDED:Int = 1
	Const RUNNING:Int = 2
	Const DEAD:Int = 3
	
Private
	Field crYieldMutex:Mutex
	Field crYieldCondVar:CondVar
	Field yieldValue:Int
	Field status:Int
	
Public
	Method Status:Int() Property Return Self.status End
	
	Method New()
		status = CREATED
		crYieldMutex = New Mutex
		crYieldCondVar = crYieldMutex.CreateCondVar()
	End
	
	Method Run:Object(arg:Object)
		' block until yield mutex is released
		crYieldMutex.Lock()
		crYieldMutex.Unlock()
		' do the coroutine code!
		yieldValue = Execute(yieldValue)
		' we're done
		status = DEAD
		' notify
		crYieldMutex.Lock()
			crYieldCondVar.Signal()
		crYieldMutex.Unlock()
		' don't care about return value
		Return Null
	End
	
	' SHOULD ONLY BE CALLED WITHIN THE COROUTINE!
	Method Yield:Int(param:Int=0)
		If status <> RUNNING Then
			' big problem!
			Return -1
		End
		crYieldMutex.Lock()
			status = YIELDED
			yieldValue = param
			crYieldCondVar.Signal()
			crYieldCondVar.Wait()
			param = yieldValue
		crYieldMutex.Unlock()
		Return param
	End
	
	' SHOULD ONLY BE CALLED OUTSIDE THE COROUTINE!
	Method Resume:Int(param:Int=0)
		If status <> YIELDED And status <> CREATED Then
			' big problem!
			Return -1
		End
		crYieldMutex.Lock()
			yieldValue = param
			If status = CREATED Then
				status = RUNNING
				Start()
			Else
				status = RUNNING
				crYieldCondVar.Signal()
			End
			crYieldCondVar.Wait()
			param = yieldValue
		crYieldMutex.Unlock()
		Return param
	End
	
	Method Execute:Int(param:Int) Abstract
End
