#Rem
Copyright (c) 2011 Steve Revill and Shane Woolcock
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#End

Strict

' Check the availability of threading for the target
#If TARGET <> "ios" And TARGET <> "stdcpp" And TARGET <> "glfw" And TARGET <> "android" And TARGET <> "bmax" And TARGET <> "xna" Then
#Error "Threading is not yet supported for target '${TARGET}'."
#End

' CPP targets should import TinyThread++
' Don't forget to copy the header files into your build directory after the first build
#If LANG="cpp" Then
Import "native/TinyThread++-1.0/source/tinythread.cpp"
Import "native/threading.cpp"

' C# targets use a stripped version of Spring.Threading
#ElseIf LANG="cs" Then
Import "native/threading.${TARGET}.${LANG}"
Import "native/Spring.Threading/Threading/Helpers/FIFOWaitNodeQueue.cs"
Import "native/Spring.Threading/Threading/Helpers/IWaitNodeQueue.cs"
Import "native/Spring.Threading/Threading/Helpers/IQueuedSync.cs"
Import "native/Spring.Threading/Threading/Helpers/WaitNode.cs"
Import "native/Spring.Threading/Threading/Locks/ConditionVariable.cs"
Import "native/Spring.Threading/Threading/Locks/FIFOConditionVariable.cs"
Import "native/Spring.Threading/Threading/Locks/ICondition.cs"
Import "native/Spring.Threading/Threading/Locks/IExclusiveLock.cs"
Import "native/Spring.Threading/Threading/Locks/ILock.cs"
Import "native/Spring.Threading/Threading/Locks/ReentrantLock.cs"

' Other targets use their own implementation
#Else
Import "native/threading.${TARGET}.${LANG}"
#End

Private Extern
Class ExtThread Abstract
Private
	Method ExtRun:Void() Abstract
	Method ExtRunning:Int() Final
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
	
	Method Running:Bool() Final
		Return ExtRunning() <> 0
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
