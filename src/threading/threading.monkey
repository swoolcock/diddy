#Rem
Monkey threading module:
	N/A = not applicable (don't need it)
	N/S = not supported (can't do it natively)
	TODO = not yet implemented (can do it, but not yet coded)
	Yes = finished

	Implemented:   MonkeyMax  GLFW  stdcpp  Android  iOS  Flash  HTML5  XNA
	Thread
		.Start()     Yes        Yes   Yes     Yes      Yes  N/S    TODO   TODO
		.Cancel()    Yes        TODO  TODO    N/S      TODO N/S    TODO   TODO
		.Join()      Yes        Yes   Yes     Yes      Yes  N/S    TODO   TODO

	Mutex
		.Lock()      Yes        Yes   Yes     Yes      Yes  N/S    TODO   TODO
		.TryLock()   Yes        Yes   Yes     Yes      Yes  N/S    TODO   TODO
		.Unlock()    Yes        Yes   Yes     Yes      Yes  N/S    TODO   TODO

	CondVar
		.Wait()      Yes        Yes   Yes     Yes      Yes  N/S    TODO   TODO
		.TimedWait() N/S        N/S   N/S     Yes      N/S  N/S    TODO   TODO
		.Signal()    Yes        Yes   Yes     Yes      Yes  N/S    TODO   TODO
		.Broadcast() Yes        Yes   Yes     Yes      Yes  N/S    TODO   TODO

	Note that some features are not available on all targets.  I may try to find a workaround for these.

	MonkeyMax requires a manual call to bmk.exe to add the -h flag.
	C++ targets (GLFW, stdcpp, iOS) require the TinyThread++ header files to be copied to the build directory.
	Flash does not support any kind of multithreading.
	HTML5 supports multithreading using web workers, but I need to read up on them more.
	XNA is not yet implemented because I need to read up on .NET threads.
	Android threads are reentrant, for now.  Be aware of this!
	
	Tested targets:
	MonkeyMax (Windows)
	GLFW (Windows and MacOSX)
	iOS
	Android
#End

Strict

' Check the availability of threading for the target
#If TARGET <> "ios" And TARGET <> "stdcpp" And TARGET <> "glfw" And TARGET <> "android" And TARGET <> "bmax" Then
#Error "Threading is not yet supported for target '${TARGET}'."
#End

' CPP targets should import TinyThread++
' Don't forget to copy the header files into your build directory after the first build
#If LANG="cpp" Then
Import "native/TinyThread++-1.0/source/tinythread.cpp"
Import "native/threading.cpp"
#Else
Import "native/threading.${TARGET}.${LANG}"
#End

Private Extern
Class ExtThread Abstract
Private
	Method ExtRun:Void() Abstract
	
	Method ExtStart:Void() Final
	Method ExtCancel:Void() Final
	Method ExtJoin:Void() Final
End

Class ExtMutex Abstract
Private
	Method ExtLock:Void() Final
	Method ExtUnlock:Void() Final
	Method ExtTryLock:Int() Final
End

Class ExtCondVar Abstract
Private
	Method ExtInit:Void(mutex:ExtMutex) Final
	Method ExtWait:Void(mutex:ExtMutex) Final
	Method ExtTimedWait:Void(mutex:ExtMutex, timeout:Float) Final
	Method ExtSignal:Void() Final
	Method ExtBroadcast:Void() Final
End

Public
Class Thread Extends ExtThread Abstract
Private
	Field threadArg:Object
	Field returnValue:Object

	Method ExtRun:Void()
		returnValue = Run(threadArg)
	End
	
Public
	Method Start:Void(arg:Object=Null) Final
		threadArg = arg
		ExtStart()
	End
	
	Method Start:Void(arg:Float) Final
		threadArg = New FloatObject(arg)
		ExtStart()
	End
	
	Method Start:Void(arg:Int) Final
		threadArg = New IntObject(arg)
		ExtStart()
	End
	
	Method Start:Void(arg:String) Final
		threadArg = New StringObject(arg)
		ExtStart()
	End
	
	Method Start:Void(arg:Bool) Final
		threadArg = New BoolObject(arg)
		ExtStart()
	End
	
	Method Cancel:Void() Final
#If TARGET <> "android" Then
		Error("Thread.Cancel is not supported on target '${TARGET}'.")
#Else
		ExtCancel()
#End
	End
	
	Method Join:Object() Final
		ExtJoin()
		Return returnValue
	End
	
	Method Run:Object(arg:Object) Abstract
End

Class Mutex Extends ExtMutex Final
Public
	Method CreateCondVar:CondVar()
		Return New CondVar(Self)
	End
	
	Method Lock:Void()
		ExtLock()
	End
	
	Method Unlock:Void()
		ExtUnlock()
	End
	
	Method TryLock:Bool()
		Return ExtTryLock() <> 0
	End
End

Class CondVar Extends ExtCondVar Final
Private
	Field mutex:Mutex
	
Public
	Method New()
		Error("CondVars must be created from a Mutex.")
	End
	
	Method New(mutex:Mutex)
		Self.mutex = mutex
		ExtInit(mutex)
	End
	
	Method Wait:Void()
		ExtWait(mutex)
	End
	
	Method TimedWait:Void(timeout:Float)
#If TARGET <> "android" Then
		Error("CondVar.TimedWait is not supported on target '${TARGET}'.")
#Else
		ExtTimedWait(mutex, timeout)
#End
	End
	
	Method Signal:Void()
		ExtSignal()
	End
	
	Method Broadcast:Void()
		ExtBroadcast()
	End
End
