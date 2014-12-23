#Rem
Copyright (c) 2011 Steve Revill and Shane Woolcock
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#End

Strict

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Private Imports
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private
Import containers
Import diddystack
Import globalpool
Import arrays
Import exception

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Private Constants
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private
Const EPSILON:Float = 0.00000000001

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Public Constants
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public
' Common field names, for convenience
Const TWEEN_X:Int = 0
Const TWEEN_Y:Int = TWEEN_X+1
Const TWEEN_XY:Int = TWEEN_Y+1
Const TWEEN_WIDTH:Int = TWEEN_XY+1
Const TWEEN_HEIGHT:Int = TWEEN_WIDTH+1
Const TWEEN_ROTATION:Int = TWEEN_HEIGHT+1
Const TWEEN_SCALE:Int = TWEEN_ROTATION+1
Const TWEEN_SCALE_X:Int = TWEEN_SCALE+1
Const TWEEN_SCALE_Y:Int = TWEEN_SCALE_X+1
Const TWEEN_SCALE_XY:Int = TWEEN_SCALE_Y+1
' If using common field names, custom ones should be defined as TWEEN_CUSTOM+0, TWEEN_CUSTOM+1, etc.
' This leaves room to add more helper field names in the future.
Const TWEEN_CUSTOM:Int = TWEEN_SCALE_XY+1

' Callback triggers
Const CALLBACK_BEGIN:Int = $01
Const CALLBACK_START:Int = $02
Const CALLBACK_END:Int = $04
Const CALLBACK_COMPLETE:Int = $08
Const CALLBACK_BACK_BEGIN:Int = $10
Const CALLBACK_BACK_START:Int = $20
Const CALLBACK_BACK_END:Int = $40
Const CALLBACK_BACK_COMPLETE:Int = $80
Const CALLBACK_ANY_FORWARD:Int = $0f
Const CALLBACK_ANY_BACKWARD:Int = $f0
Const CALLBACK_ANY:Int = $ff

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Public API
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
#Rem
Implement this interface to tell your object how it should tween.
#End
Interface ITweenable
	Method GetValues:Int(tweenType:Int, returnValues:Float[])
	Method SetValues:Void(tweenType:Int, newValues:Float[])
End

Interface TweenCallback
	Method OnEvent:Void(type:Int, source:BaseTween)
End

Class Tween Extends BaseTween
''''''''''''''''''''''''''''''''''''''''''''''''''
' Private Fields
''''''''''''''''''''''''''''''''''''''''''''''''''
Private
	' globals
	Global combinedAttrsLimit:Int = 3
	Global waypointsLimit:Int = 0
	
	' Main
	Field target:ITweenable
	Field type:Int
	Field equation:TweenEquation
	Field path:TweenPath
	Field easeArgs:Float[]

	' General
	Field isFrom:Bool
	Field isRelative:Bool
	Field combinedAttrsCnt:Int
	Field waypointsCnt:Int

	' Values
	Field startValues:Float[] = New Float[combinedAttrsLimit]
	Field targetValues:Float[] = New Float[combinedAttrsLimit]
	Field waypoints:Float[] = New Float[waypointsLimit * combinedAttrsLimit]
	
	' Buffers
	Field tweenBuffer:Float[] = New Float[combinedAttrsLimit]
	Field pathBuffer:Float[] = New Float[(2+waypointsLimit)*combinedAttrsLimit]
	
''''''''''''''''''''''''''''''''''''''''''''''''''
' Public overrides
''''''''''''''''''''''''''''''''''''''''''''''''''
Public
	Method Reset:Void()
		Super.Reset()
		
		target = Null
		type = -1
		equation = Null
		path = Null

		isFrom = False
		isRelative = False
		combinedAttrsCnt = 0
		waypointsCnt = 0

		If tweenBuffer.Length <> combinedAttrsLimit Then
			tweenBuffer = New Float[combinedAttrsLimit]
		End

		If pathBuffer.Length <> (2+waypointsLimit)*combinedAttrsLimit Then
			pathBuffer = New Float[(2+waypointsLimit)*combinedAttrsLimit]
		End
	End
	
	Method Free:Void()
		GlobalPool<Tween>.Free(Self)
	End

''''''''''''''''''''''''''''''''''''''''''''''''''
' Private overrides
''''''''''''''''''''''''''''''''''''''''''''''''''
Private
	Method InitializeOverride:Void()
		If Not target Then Return
		
		target.GetValues(type, startValues)
		For Local i:Int = 0 Until combinedAttrsCnt
			If isRelative Then targetValues[i] += startValues[i]
			
			For Local ii:Int = 0 Until waypointsCnt
				If isRelative Then waypoints[ii*combinedAttrsCnt+i] += startValues[i]
			Next
			
			If isFrom Then
				Local tmp:Float = startValues[i]
				startValues[i] = targetValues[i]
				targetValues[i] = tmp
			End
		Next
	End
	
	Method UpdateOverride:Void(_step:Int, lastStep:Int, isIterationStep:Bool, delta:Float)
		If Not target Or Not equation Then Return
		
		' Case iteration end has been reached
		
		If Not isIterationStep And _step > lastStep Then
			If IsReverse(lastStep) Then target.SetValues(type, startValues) Else target.SetValues(type, targetValues)
			Return
		End
		
		If Not isIterationStep And _step < lastStep Then
			If IsReverse(lastStep) Then target.SetValues(type, targetValues) Else target.SetValues(type, startValues)
			Return
		End
		
		' Case duration equals zero
		
		If duration < EPSILON And delta > -EPSILON Then
			If IsReverse(_step) Then target.SetValues(type, targetValues) Else target.SetValues(type, startValues)
			Return
		End
		
		If duration < EPSILON And delta < EPSILON Then
			If IsReverse(_step) Then target.SetValues(type, startValues) Else target.SetValues(type, targetValues)
			Return
		End
		
		' Normal behaviour
		
		Local time:Float = CurrentTime
		If IsReverse(_step) Then time = duration - time
		Local t:Float = equation.Compute(time/duration)
		
		If waypointsCnt = 0 Or Not path Then
			For Local i:Int = 0 Until combinedAttrsCnt
				tweenBuffer[i] = startValues[i] + t * (targetValues[i] - startValues[i])
			Next
		Else
			For Local i:Int = 0 Until combinedAttrsCnt
				pathBuffer[0] = startValues[i]
				pathBuffer[1+waypointsCnt] = targetValues[i]
				For Local ii:Int = 0 Until waypointsCnt
					pathBuffer[ii+1] = waypoints[ii*combinedAttrsCnt+i]
				Next
				tweenBuffer[i] = path.Compute(t, pathBuffer, waypointsCnt+2)
			Next
		End
		
		target.SetValues(type, tweenBuffer)
	End
	
	Method ForceStartValues:Void()
		If Not target Then Return
		target.SetValues(type, startValues)
	End
	
	Method ForceEndValues:Void()
		If Not target Then Return
		target.SetValues(type, targetValues)
	End
	
	Method ContainsTarget:Bool(target:ITweenable)
		Return Self.target = target
	End
	
	Method ContainsTarget:Bool(target:ITweenable, tweenType:Int)
		Return Self.target = target And Self.type = tweenType
	End
	
''''''''''''''''''''''''''''''''''''''''''''''''''
' General private methods
''''''''''''''''''''''''''''''''''''''''''''''''''
Private
	Method Setup:Void(target:ITweenable, tweenType:Int, duration:Float)
		If duration < 0 Then Throw New IllegalArgumentException("Duration can't be negative")
		Self.target = target
		Self.type = tweenType
		Self.duration = duration
	End

'''''''''''''''''''''''''''''''
' Abstract private methods
'''''''''''''''''''''''''''''''
Private
	
'''''''''''''''''''''''''''''''
' General public methods
'''''''''''''''''''''''''''''''
Public
	Method New()
		Reset()
	End
	
	Method Target:Tween(targetValue:Float)
		targetValues[0] = targetValue
		Return Self
	End
	
	Method Target:Tween(targetValue1:Float, targetValue2:Float)
		targetValues[0] = targetValue1
		targetValues[1] = targetValue2
		Return Self
	End
	
	Method Target:Tween(targetValue1:Float, targetValue2:Float, targetValue3:Float)
		targetValues[0] = targetValue1
		targetValues[1] = targetValue2
		targetValues[2] = targetValue3
		Return Self
	End
	
	Method Target:Tween(targetValue1:Float, targetValue2:Float, targetValue3:Float, targetValue4:Float)
		targetValues[0] = targetValue1
		targetValues[1] = targetValue2
		targetValues[2] = targetValue3
		targetValues[3] = targetValue4
		Return Self
	End
	
	Method Target:Tween(targetValues:Float[])
		'FIXME if (targetValues.length > combinedAttrsLimit) throwCombinedAttrsLimitReached();
		Arrays<Float>.Copy(targetValues, 0, Self.targetValues, 0, targetValues.Length)
		Return Self
	End
	
	Method TargetRelative:Tween(targetValue:Float)
		isRelative = True
		If IsInitialized() Then
			targetValues[0] = targetValue + startValues[0]
		Else
			targetValues[0] = targetValue
		End
		Return Self
	End
	
	Method TargetRelative:Tween(targetValue1:Float, targetValue2:Float)
		isRelative = True
		If IsInitialized() Then
			targetValues[0] = targetValue1 + startValues[0]
			targetValues[1] = targetValue2 + startValues[1]
		Else
			targetValues[0] = targetValue1
			targetValues[1] = targetValue2
		End
		Return Self
	End
	
	Method TargetRelative:Tween(targetValue1:Float, targetValue2:Float, targetValue3:Float)
		isRelative = True
		If IsInitialized() Then
			targetValues[0] = targetValue1 + startValues[0]
			targetValues[1] = targetValue2 + startValues[1]
			targetValues[2] = targetValue3 + startValues[2]
		Else
			targetValues[0] = targetValue1
			targetValues[1] = targetValue2
			targetValues[2] = targetValue3
		End
		Return Self
	End
	
	Method TargetRelative:Tween(targetValue1:Float, targetValue2:Float, targetValue3:Float, targetValue4:Float)
		isRelative = True
		If IsInitialized() Then
			targetValues[0] = targetValue1 + startValues[0]
			targetValues[1] = targetValue2 + startValues[1]
			targetValues[2] = targetValue3 + startValues[2]
			targetValues[3] = targetValue4 + startValues[3]
		Else
			targetValues[0] = targetValue1
			targetValues[1] = targetValue2
			targetValues[2] = targetValue3
			targetValues[3] = targetValue4
		End
		Return Self
	End
	
	Method TargetRelative:Tween(targetValues:Float[])
		'FIXME if (targetValues.length > combinedAttrsLimit) throwCombinedAttrsLimitReached();
		If Not IsInitialized() Then
			Arrays<Float>.Copy(targetValues, 0, Self.targetValues, 0, targetValues.Length)
		Else
			For Local i:Int = 0 Until targetValues.Length
				Self.targetValues[i] = targetValues[i] + startValues[i]
			Next
		End

		isRelative = True
		Return Self
	End
	
	Method Waypoint:Tween(targetValue:Float)
		'FIXME if (waypointsCnt == waypointsLimit) throwWaypointsLimitReached();
		waypoints[waypointsCnt] = targetValue
		waypointsCnt += 1
		Return Self
	End
	
	Method Waypoint:Tween(targetValue1:Float, targetValue2:Float)
		'FIXME if (waypointsCnt == waypointsLimit) throwWaypointsLimitReached();
		waypoints[waypointsCnt*2] = targetValue1
		waypoints[waypointsCnt*2+1] = targetValue2
		waypointsCnt += 1
		Return Self
	End
	
	Method Waypoint:Tween(targetValue1:Float, targetValue2:Float, targetValue3:Float)
		'FIXME if (waypointsCnt == waypointsLimit) throwWaypointsLimitReached();
		waypoints[waypointsCnt*3] = targetValue1
		waypoints[waypointsCnt*3+1] = targetValue2
		waypoints[waypointsCnt*3+2] = targetValue3
		waypointsCnt += 1
		Return Self
	End
	
	Method Waypoint:Tween(targetValues:Float[])
		'FIXME if (waypointsCnt == waypointsLimit) throwWaypointsLimitReached();
		Arrays<Float>.Copy(targetValues, 0, waypoints, waypointsCnt*targetValues.Length, targetValues.Length)
		waypointsCnt += 1
		Return Self
	End
	
'''''''''''''''''''''''''''''''
' Properties
'''''''''''''''''''''''''''''''
Public
	Method Ease:Tween(easeEquation:TweenEquation) Property
		Self.equation = easeEquation
		Return Self
	End
	
	Method Path:Tween(path:TweenPath) Property
		Self.path = path
		Return Self
	End
	
	Method Target:ITweenable() Property
		Return target
	End
	
	Method Type:Int() Property
		Return type
	End
	
	Method Ease:TweenEquation() Property
		Return equation
	End
	
	Method TargetValues:Float[]() Property
		Return targetValues
	End
	
	Method CombinedAttributesCount:Int() Property
		Return combinedAttrsCnt
	End

''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Factory methods
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public
	Function TweenTo:Tween(target:ITweenable, tweenType:Int, duration:Float)
		Local tween:Tween = GlobalPool<Tween>.Allocate()
		tween.Setup(target, tweenType, duration)
		'FIXME tween.ease(Quad.INOUT);
		'FIXME tween.path(TweenPaths.catmullRom);
		Return tween
	End
	
	Function TweenFrom:Tween(target:ITweenable, tweenType:Int, duration:Float)
		Local tween:Tween = GlobalPool<Tween>.Allocate()
		tween.Setup(target, tweenType, duration)
		'FIXME tween.ease(Quad.INOUT);
		'FIXME tween.path(TweenPaths.catmullRom);
		tween.isFrom = True
		Return tween
	End
	
	Function Set:Tween(target:ITweenable, tweenType:Int)
		Local tween:Tween = GlobalPool<Tween>.Allocate()
		tween.Setup(target, tweenType, 0)
		'FIXME tween.ease(Quad.INOUT)
		Return tween
	End
	
	Function Call:Tween(callback:TweenCallback)
		Local tween:Tween = GlobalPool<Tween>.Allocate()
		tween.Setup(Null, -1, 0)
		tween.Callback = callback
		tween.CallbackTriggers = CALLBACK_START
		Return tween
	End

	Function Mark:Tween()
		Local tween:Tween = GlobalPool<Tween>.Allocate()
		tween.Setup(Null, -1, 0)
		Return tween
	End
	
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Chained private method overrides
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private
	Method _Build:BaseTween()
		If Not target Then Return Self
		combinedAttrsCnt = target.GetValues(type, tweenBuffer)
		'FIXME if (combinedAttrsCnt > combinedAttrsLimit) throwCombinedAttrsLimitReached();
		Return Self
	End

''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Public wrappers for private chained methods/properties
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public
	Method Build:Tween()
		Return Tween(_Build())
	End
	
	Method AddDelay:Tween(delay:Float)
		Return Tween(_AddDelay(delay))
	End
	
	Method RepeatLoop:Tween(count:Int, delay:Float)
		Return Tween(_RepeatLoop(count, delay))
	End
	
	Method RepeatYoyo:Tween(count:Int, delay:Float)
		Return Tween(_RepeatYoyo(count, delay))
	End
	
	Method Callback:Tween(callback:TweenCallback) Property
		Return Tween(_SetCallback(callback))
	End
	
	Method CallbackTriggers:Tween(flags:Int) Property
		Return Tween(_SetCallbackTriggers(flags))
	End
	
	Method UserData:Tween(data:Object) Property
		Return Tween(_SetUserData(data))
	End
	
	Method Start:Tween()
		Return Tween(_Start())
	End
	
	Method Start:Tween(manager:TweenManager)
		Return Tween(_Start(manager))
	End
End

Class Timeline Extends BaseTween
Public
	Const SEQUENCE:Int = 0
	Const PARALLEL:Int = 1
	
''''''''''''''''''''''''''''''''''''''''''''''''''
' Private Fields
''''''''''''''''''''''''''''''''''''''''''''''''''
Private
	Field children:DiddyStack<BaseTween> = New DiddyStack<BaseTween>
	Field current:Timeline
	Field parent:Timeline
	Field mode:Int
	Field isBuilt:Bool
	
''''''''''''''''''''''''''''''''''''''''''''''''''
' General private methods
''''''''''''''''''''''''''''''''''''''''''''''''''
Private
	Method Setup:Void(mode:Int)
		Self.mode = mode
		Self.current = Self
	End
	
'''''''''''''''''''''''''''''''
' General public methods
'''''''''''''''''''''''''''''''
Public
	Method New()
		Reset()
	End
	
	Method Reset:Void()
		Super.Reset()
		children.Clear()
		current = Null
		parent = Null
		isBuilt = False
	End
	
	Method Kill:Void()
		isKilled = True
	End
	
	Method Free:Void()
		For Local i:Int = 0 Until children.Count()
			Local obj:BaseTween = children.Get(i)
			obj.Free()
		Next
		GlobalPool<Timeline>.Free(Self)
	End
	
	Method Pause:Void()
		isPaused = True
	End
	
	Method Resume:Void()
		isPaused = False
	End
	
	Method Push:Timeline(tween:Tween)
		If isBuilt Then Throw New DiddyException("You can't push anything to a timeline once it is started")
		current.children.Push(tween)
		Return Self
	End
	
	Method Push:Timeline(timeline:Timeline)
		If isBuilt Then Throw New DiddyException("You can't push anything to a timeline once it is started")
		If timeline.current <> timeline Then Throw New DiddyException("You forgot to call a few 'end()' statements in your pushed timeline")
		timeline.parent = current
		current.children.Push(timeline)
		Return Self
	End
	
	Method PushPause:Timeline(time:Float)
		If isBuilt Then Throw New DiddyException("You can't push anything to a timeline once it is started")
		current.children.Push(Tween.Mark().AddDelay(time))
		Return Self
	End
	
	Method BeginSequence:Timeline()
		If isBuilt Then Throw New DiddyException("You can't push anything to a timeline once it is started")
		Local tl:Timeline = GlobalPool<Timeline>.Allocate()
		tl.parent = current
		tl.mode = SEQUENCE
		current.children.Push(tl)
		current = tl
		Return Self
	End
	
	Method BeginParallel:Timeline()
		If isBuilt Then Throw New DiddyException("You can't push anything to a timeline once it is started")
		Local tl:Timeline = GlobalPool<Timeline>.Allocate()
		tl.parent = current
		tl.mode = PARALLEL
		current.children.Push(tl)
		current = tl
		Return Self
	End
	
	Method EndTimeline:Timeline()
		If isBuilt Then Throw New DiddyException("You can't push anything to a timeline once it is started")
		If current = Self Then Throw New DiddyException("Nothing to end...")
		current = current.parent
		Return Self
	End
	
	Method Children:IContainer<BaseTween>()
		If isBuilt Then Return current.children.ReadOnly()
		Return current.children
	End
	
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Public wrappers for private chained methods/properties
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public
	Method Build:Timeline()
		Return Timeline(_Build())
	End
	
	Method AddDelay:Timeline(delay:Float)
		Return Timeline(_AddDelay(delay))
	End
	
	Method RepeatLoop:Timeline(count:Int, delay:Float)
		Return Timeline(_RepeatLoop(count, delay))
	End
	
	Method RepeatYoyo:Timeline(count:Int, delay:Float)
		Return Timeline(_RepeatYoyo(count, delay))
	End
	
	Method Callback:Timeline(callback:TweenCallback) Property
		Return Timeline(_SetCallback(callback))
	End
	
	Method CallbackTriggers:Timeline(flags:Int) Property
		Return Timeline(_SetCallbackTriggers(flags))
	End
	
	Method UserData:Timeline(data:Object) Property
		Return Timeline(_SetUserData(data))
	End
	
	Method Start:Timeline()
		Return Timeline(_Start())
	End
	
	Method Start:Timeline(manager:TweenManager)
		Return Timeline(_Start(manager))
	End

''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Chained private method overrides
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private
	Method _Build:BaseTween()
		If isBuilt Then Return Self
		
		duration = 0
		For Local i:Int = 0 Until children.Count()
			Local obj:BaseTween = children.Get(i)
			If obj.RepeatCount < 0 Then Throw New DiddyException("You can't push an object with infinite repetitions in a timeline")
			obj._Build()
			
			Select mode
				Case SEQUENCE
					Local tDelay:Float = duration
					duration += obj.FullDuration
					obj.delay += tDelay
					
				Case PARALLEL
					duration = Max(duration, obj.FullDuration)
			End
		Next
		
		isBuilt = True
		Return Self
	End
	
	Method _Start:BaseTween()
		Super._Start()
		For Local i:Int = 0 Until children.Count()
			Local obj:BaseTween = children.Get(i)
			obj._Start()
		Next
		Return Self
	End
	
	Method _Start:BaseTween(manager:TweenManager)
		Return Super._Start(manager)
	End
	
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Private overrides
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private
	' NOTE: the java version caches children.size() before loops... performance? safety check?
	Method UpdateOverride:Void(_step:Int, lastStep:Int, isIterationStep:Bool, delta:Float)
		If Not isIterationStep And _step > lastStep Then
			' assert delta >= 0
			Local dt:Float = delta+1
			If IsReverse(lastStep) Then dt = -delta-1
			For Local i:Int = 0 Until children.Count()
				children.Get(i).Update(dt)
			End
			Return
		End
		
		If Not isIterationStep And _step < lastStep Then
			' assert delta <= 0
			Local dt:Float = delta+1
			If IsReverse(lastStep) Then dt = -delta-1
			For Local i:Int = children.Count()-1 To 0 Step -1
				children.Get(i).Update(dt)
			Next
			Return
		End
		
		' assert isIterationStep
		
		If _step > lastStep Then
			If IsReverse(_step) Then
				ForceEndValues()
			Else
				ForceStartValues()
			End
			For Local i:Int = 0 Until children.Count()
				children.Get(i).Update(delta)
			Next
		ElseIf _step < lastStep Then
			If IsReverse(_step) Then
				ForceStartValues()
			Else
				ForceEndValues()
			End
			For Local i:Int = children.Count()-1 To 0 Step -1
				children.Get(i).Update(delta)
			Next
		Else
			Local dt:Float = delta
			If IsReverse(_step) Then dt = -delta
			If delta >= 0 Then
				For Local i:Int = 0 Until children.Count()
					children.Get(i).Update(dt)
				Next
			Else
				For Local i:Int = children.Count()-1 To 0 Step -1
					children.Get(i).Update(dt)
				Next
			End
		End
	End
	
	Method ForceStartValues:Void()
		For Local i:Int = 0 Until children.Count()
			children.Get(i).ForceToStart()
		Next
	End
	
	Method ForceEndValues:Void()
		For Local i:Int = 0 Until children.Count()
			children.Get(i).ForceToEnd(duration)
		Next
	End
	
	Method ContainsTarget:Bool(target:ITweenable)
		For Local i:Int = 0 Until children.Count()
			If children.Get(i).ContainsTarget(target) Then Return True
		Next
		Return False
	End
	
	Method ContainsTarget:Bool(target:ITweenable, tweenType:Int)
		For Local i:Int = 0 Until children.Count()
			If children.Get(i).ContainsTarget(target, tweenType) Then Return True
		Next
		Return False
	End
	
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Factory methods
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public
	Function CreateSequence:Timeline()
		Local tl:Timeline = GlobalPool<Timeline>.Allocate()
		tl.Setup(SEQUENCE)
		Return tl
	End
	
	Function CreateParallel:Timeline()
		Local tl:Timeline = GlobalPool<Timeline>.Allocate()
		tl.Setup(PARALLEL)
		Return tl
	End
End

Class BaseTween Implements IPoolable Abstract
''''''''''''''''''''''''''''''''''''''''''''''''''
' Private Fields
''''''''''''''''''''''''''''''''''''''''''''''''''
Private
	' General
	Field currentStep:Int
	Field repeatCnt:Int
	Field isIterationStep:Bool
	Field isYoyo:Bool

	' Timings
	Field delay:Float
	Field duration:Float
	Field repeatDelay:Float
	Field currentTime:Float
	Field deltaTime:Float
	Field isStarted:Bool ' true when the object is started
	Field isInitialized:Bool ' true after the delay
	Field isFinished:Bool ' true when all repetitions are done
	Field isKilled:Bool ' true if kill() was called
	Field isPaused:Bool ' true if pause() was called
	Field isAutoRemoveEnabled:Bool
	Field isAutoStartEnabled:Bool
	
	' Misc
	Field callback:TweenCallback
	Field callbackTriggers:Int
	Field userData:Object
	
''''''''''''''''''''''''''''''''''''''''''''''''''
' General private methods
''''''''''''''''''''''''''''''''''''''''''''''''''
Private
	Method ForceToStart:Void()
		currentTime = -delay
		currentStep = -1
		isIterationStep = False
		If IsReverse(0) Then ForceEndValues() Else ForceStartValues()
	End

	Method ForceToEnd:Void(time:Float)
		currentTime = time - FullDuration
		currentStep = repeatCnt*2 + 1
		isIterationStep = False
		If IsReverse(repeatCnt*2) Then ForceStartValues() Else ForceEndValues()
	End
	
	Method CallCallback:Void(type:Int)
		If callback And (callbackTriggers & type) > 0 Then callback.OnEvent(type, Self)
	End
	
	Method IsReverse:Bool(_step:Int)
		Return isYoyo And Abs(_step Mod 4) = 2
	End

	Method IsValid:Bool(_step:Int)
		Return (_step >= 0 And _step <= repeatCnt*2) Or repeatCnt < 0
	End

	Method KillTarget:Void(target:ITweenable)
		If ContainsTarget(target) Then Kill()
	End

	Method KillTarget:Void(target:ITweenable, tweenType:Int)
		If ContainsTarget(target, tweenType) Then Kill()
	End
	
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Chained private methods, should be wrapped with a public method in subclasses
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private
	Method _Build:BaseTween()
		Return Self
	End
	
	Method _AddDelay:BaseTween(delay:Float)
		Self.delay += delay
		Return Self
	End
	
	Method _RepeatLoop:BaseTween(count:Int, delay:Float)
		If isStarted Then Throw New DiddyException("You can't change the repetitions of a tween or timeline once it is started")
		repeatCnt = count
		If delay >= 0 Then repeatDelay = delay Else repeatDelay = 0
		isYoyo = False
		Return Self
	End
	
	Method _RepeatYoyo:BaseTween(count:Int, delay:Float)
		If isStarted Then Throw New DiddyException("You can't change the repetitions of a tween or timeline once it is started")
		repeatCnt = count
		If delay >= 0 Then repeatDelay = delay Else repeatDelay = 0
		isYoyo = True
		Return Self
	End
	
	Method _SetCallback:BaseTween(callback:TweenCallback)
		Self.callback = callback
		Return Self
	End
	
	Method _SetCallbackTriggers:BaseTween(flags:Int)
		Self.callbackTriggers = flags
		Return Self
	End
	
	Method _SetUserData:BaseTween(data:Object)
		userData = data
		Return Self
	End
	
	Method _Start:BaseTween()
		_Build()
		currentTime = 0
		isStarted = True
		Return Self
	End
	
	Method _Start:BaseTween(manager:TweenManager)
		manager.Add(Self)
		Return Self
	End
	
'''''''''''''''''''''''''''''''
' Abstract private methods
'''''''''''''''''''''''''''''''
Private
	' pure abstract
	Method ForceStartValues:Void() Abstract
	Method ForceEndValues:Void() Abstract
	Method ContainsTarget:Bool(target:ITweenable) Abstract
	Method ContainsTarget:Bool(target:ITweenable, tweenType:Int) Abstract
	
	' empty implementation
	Method InitializeOverride:Void() End
	Method UpdateOverride:Void(_step:Int, lastStep:Int, isIterationStep:Bool, delta:Float) End
	
'''''''''''''''''''''''''''''''
' General public methods
'''''''''''''''''''''''''''''''
Public
	Method Reset:Void()
		currentStep = -2
		repeatCnt = 0
		isIterationStep = False
		isYoyo = False

		delay = 0
		duration = 0
		repeatDelay = 0
		currentTime = 0
		deltaTime = 0
		isStarted = False
		isInitialized = False
		isFinished = False
		isKilled = False
		isPaused = False

		callback = Null
		callbackTriggers = CALLBACK_COMPLETE
		userData = Null

		isAutoRemoveEnabled = True
		isAutoStartEnabled = True
	End
	
	Method Kill:Void()
		isKilled = True
	End
	
	Method Free:Void()
	End
	
	Method Pause:Void()
		isPaused = True
	End
	
	Method Resume:Void()
		isPaused = False
	End
	
'''''''''''''''''''''''''''''''
' Properties
'''''''''''''''''''''''''''''''
Public
	Method Delay:Float() Property
		Return delay
	End
	
	Method Duration:Float() Property
		Return duration
	End
	
	Method RepeatCount:Int() Property
		Return repeatCnt
	End
	
	Method RepeatDelay:Float() Property
		Return repeatDelay
	End
	
	Method FullDuration:Float() Property
		If repeatCnt < 0 Then Return -1
		Return delay + duration + (repeatDelay + duration) * repeatCnt
	End
	
	Method CurrentStep:Int() Property
		Return currentStep
	End
	
	Method CurrentTime:Float() Property
		Return currentTime
	End
	
	Method IsStarted:Bool() Property
		Return isStarted
	End
	
	Method IsInitialized:Bool() Property
		Return isInitialized
	End
	
	Method IsFinished:Bool() Property
		Return isFinished Or isKilled
	End
	
	Method IsYoyo:Bool() Property
		Return isYoyo
	End
	
	Method IsPaused:Bool() Property
		Return isPaused
	End
	
'''''''''''''''''''''''''''''''
' Update engine
'''''''''''''''''''''''''''''''
Public
	Method Update:Void(delta:Float)
		If Not isStarted Or isPaused Or isKilled Then Return
		
		deltaTime = delta
		
		If Not isInitialized Then Initialize()
		
		If isInitialized Then
			TestRelaunch()
			UpdateStep()
			TestCompletion()
		End
		
		currentTime += deltaTime
		deltaTime = 0
	End
	
Private
	Method Initialize:Void()
		If currentTime+deltaTime >= delay Then
			InitializeOverride()
			isInitialized = True
			isIterationStep = True
			currentStep = 0
			deltaTime -= delay-currentTime
			currentTime = 0
			CallCallback(CALLBACK_BEGIN)
			CallCallback(CALLBACK_START)
		End
	End
	
	Method TestRelaunch:Void()
		If Not isIterationStep And repeatCnt >= 0 And currentStep < 0 And currentTime+deltaTime >= 0 Then
			isIterationStep = True
			currentStep = 0
			Local delta:Float = -currentTime
			deltaTime -= delta
			currentTime = 0
			CallCallback(CALLBACK_BEGIN)
			CallCallback(CALLBACK_START)
			UpdateOverride(currentStep, currentStep-1, isIterationStep, delta)
		ElseIf Not isIterationStep And repeatCnt >= 0 And currentStep > repeatCnt*2 And currentTime+deltaTime < 0 Then
			isIterationStep = True
			currentStep = repeatCnt*2
			Local delta:Float = -currentTime
			deltaTime -= delta
			currentTime = duration
			CallCallback(CALLBACK_BACK_BEGIN)
			CallCallback(CALLBACK_BACK_START)
			UpdateOverride(currentStep, currentStep+1, isIterationStep, delta)
		End
	End
	
	Method UpdateStep:Void()
		While IsValid(currentStep)
			If Not isIterationStep And currentTime+deltaTime <= 0 Then
				isIterationStep = True
				currentStep -= 1
				
				Local delta:Float = -currentTime
				deltaTime -= delta
				currentTime = duration
				
				If IsReverse(currentStep) Then ForceStartValues() Else ForceEndValues()
				CallCallback(CALLBACK_BACK_START)
				UpdateOverride(currentStep, currentStep+1, isIterationStep, delta)
			ElseIf Not isIterationStep And currentTime+deltaTime >= repeatDelay Then
				isIterationStep = True
				currentStep += 1
				
				Local delta:Float = repeatDelay-currentTime
				deltaTime -= delta
				currentTime = 0
				
				If IsReverse(currentStep) Then ForceEndValues() Else ForceStartValues()
				CallCallback(CALLBACK_START)
				UpdateOverride(currentStep, currentStep-1, isIterationStep, delta)
			ElseIf isIterationStep And currentTime+deltaTime < 0 Then
				isIterationStep = False
				currentStep -= 1
				
				Local delta:Float = -currentTime
				deltaTime -= delta
				currentTime = 0
				
				UpdateOverride(currentStep, currentStep+1, isIterationStep, delta)
				CallCallback(CALLBACK_BACK_END)
				
				If currentStep < 0 And repeatCnt >= 0 Then
					CallCallback(CALLBACK_BACK_COMPLETE)
				Else
					currentTime = repeatDelay
				End
			ElseIf isIterationStep And currentTime+deltaTime > duration Then
				isIterationStep = False
				currentStep += 1
				
				Local delta:Float = duration-currentTime
				deltaTime -= delta
				currentTime = duration
				
				UpdateOverride(currentStep, currentStep-1, isIterationStep, delta)
				CallCallback(CALLBACK_END)
				
				If currentStep > repeatCnt*2 And repeatCnt >= 0 Then CallCallback(CALLBACK_COMPLETE)
				currentTime = 0
			ElseIf isIterationStep Then
				Local delta:Float = deltaTime
				deltaTime -= delta
				currentTime += delta
				UpdateOverride(currentStep, currentStep, isIterationStep, delta)
				Exit
			Else
				Local delta:Float = deltaTime
				deltaTime -= delta
				currentTime += delta
				Exit
			End
		End
	End
	
	Method TestCompletion:Void()
		isFinished = repeatCnt >= 0 And (currentStep > repeatCnt*2 Or currentStep < 0)
	End
	
End ' End Class BaseTween

Class TweenEquation Abstract
Public
	Global easeNone:TweenEquation = New EaseLinear
	Global easeInQuad:TweenEquation = New EaseInQuad
	Global easeOutQuad:TweenEquation = New EaseOutQuad
	Global easeInOutQuad:TweenEquation = New EaseInOutQuad
	Global easeInCubic:TweenEquation = New EaseInCubic
	Global easeOutCubic:TweenEquation = New EaseOutCubic
	Global easeInOutCubic:TweenEquation = New EaseInOutCubic
	Global easeInQuart:TweenEquation = New EaseInQuart
	Global easeOutQuart:TweenEquation = New EaseOutQuart
	Global easeInOutQuart:TweenEquation = New EaseInOutQuart
	Global easeInQuint:TweenEquation = New EaseInQuint
	Global easeOutQuint:TweenEquation = New EaseOutQuint
	Global easeInOutQuint:TweenEquation = New EaseInOutQuint
	Global easeInCirc:TweenEquation = New EaseInCirc
	Global easeOutCirc:TweenEquation = New EaseOutCirc
	Global easeInOutCirc:TweenEquation = New EaseInOutCirc
	Global easeInSine:TweenEquation = New EaseInSine
	Global easeOutSine:TweenEquation = New EaseOutSine
	Global easeInOutSine:TweenEquation = New EaseInOutSine
	Global easeInExpo:TweenEquation = New EaseInExpo
	Global easeOutExpo:TweenEquation = New EaseOutExpo
	Global easeInOutExpo:TweenEquation = New EaseInOutExpo
	Global easeInBack:TweenEquation = New EaseInBack
	Global easeOutBack:TweenEquation = New EaseOutBack
	Global easeInOutBack:TweenEquation = New EaseInOutBack
	Global easeInBounce:TweenEquation = New EaseInBounce
	Global easeOutBounce:TweenEquation = New EaseOutBounce
	Global easeInOutBounce:TweenEquation = New EaseInOutBounce
	Global easeInElastic:TweenEquation = New EaseInElastic
	Global easeOutElastic:TweenEquation = New EaseOutElastic
	Global easeInOutElastic:TweenEquation = New EaseInOutElastic
	
	Method Compute:Float(t:Float, args:Float[]=[]) Abstract
End

Class EaseLinear Extends TweenEquation
	Method Compute:Float(t:Float, args:Float[]=[])
		Return t
	End
End

Class EaseInQuad Extends TweenEquation
	Method Compute:Float(t:Float, args:Float[]=[])
		Return t*t
	End
End

Class EaseOutQuad Extends TweenEquation
	Method Compute:Float(t:Float, args:Float[]=[])
		t = 1-t
		Return 1-(t*t)
	End
End

Class EaseInOutQuad Extends TweenEquation
	Method Compute:Float(t:Float, args:Float[]=[])
		t *= 2
		If t < 1 Then Return t*t / 2
		t -= 2
		Return 1 - t*t / 2
	End
End

Class EaseInCubic Extends TweenEquation
	Method Compute:Float(t:Float, args:Float[]=[])
		Return t*t*t
	End
End

Class EaseOutCubic Extends TweenEquation
	Method Compute:Float(t:Float, args:Float[]=[])
		t = 1-t
		Return 1-(t*t*t)
	End
End

Class EaseInOutCubic Extends TweenEquation
	Method Compute:Float(t:Float, args:Float[]=[])
		t *= 2
		If t < 1 Then Return t*t*t / 2
		t -= 2
		Return 1 - t*t*t / 2
	End
End

Class EaseInQuart Extends TweenEquation
	Method Compute:Float(t:Float, args:Float[]=[])
		Return t*t*t*t
	End
End

Class EaseOutQuart Extends TweenEquation
	Method Compute:Float(t:Float, args:Float[]=[])
		t = 1-t
		Return 1-(t*t*t*t)
	End
End

Class EaseInOutQuart Extends TweenEquation
	Method Compute:Float(t:Float, args:Float[]=[])
		t *= 2
		If t < 1 Then Return t*t*t*t / 2
		t -= 2
		Return 1 - t*t*t*t / 2
	End
End

Class EaseInQuint Extends TweenEquation
	Method Compute:Float(t:Float, args:Float[]=[])
		Return t*t*t*t*t
	End
End

Class EaseOutQuint Extends TweenEquation
	Method Compute:Float(t:Float, args:Float[]=[])
		t = 1-t
		Return 1-(t*t*t*t*t)
	End
End

Class EaseInOutQuint Extends TweenEquation
	Method Compute:Float(t:Float, args:Float[]=[])
		t *= 2
		If t < 1 Then Return t*t*t*t*t / 2
		t -= 2
		Return 1 - t*t*t*t*t / 2
	End
End

Class EaseInCirc Extends TweenEquation
	Method Compute:Float(t:Float, args:Float[]=[])
		Return 1 - Sqrt(1 - t*t)
	End
End

Class EaseOutCirc Extends TweenEquation
	Method Compute:Float(t:Float, args:Float[]=[])
		t = 1-t
		Return Sqrt(1 - t*t)
	End
End

Class EaseInOutCirc Extends TweenEquation
	Method Compute:Float(t:Float, args:Float[]=[])
		t *= 2
		If t < 1 Then Return (1-Sqrt(1 - t*t)) / 2
		t -= 2
		Return 1 - Sqrt(1 - t*t) / 2
	End
End

Class EaseInSine Extends TweenEquation
	Method Compute:Float(t:Float, args:Float[]=[])
		Return Cos(t*90)
	End
End

Class EaseOutSine Extends TweenEquation
	Method Compute:Float(t:Float, args:Float[]=[])
		Return Sin(t*90)
	End
End

Class EaseInOutSine Extends TweenEquation
	Method Compute:Float(t:Float, args:Float[]=[])
		Return Sin(t*180)
	End
End

Class EaseInExpo Extends TweenEquation
	Method Compute:Float(t:Float, args:Float[]=[])
		If t = 0 Then Return 0
		Return Pow(2, 10*(t-1)) - 0.001
	End
End

Class EaseOutExpo Extends TweenEquation
	Method Compute:Float(t:Float, args:Float[]=[])
		If t = 1 Then Return 1
		Return 1.001 * (-Pow(2, -10 * t) + 1)
	End
End

Class EaseInOutExpo Extends TweenEquation
	Method Compute:Float(t:Float, args:Float[]=[])
		If t = 0 Then Return 0
		If t = 1 Then Return 1
		t *= 2
		If t < 1 Then Return (Pow(2, 10*(t-1)) - 0.001) / 2
		t -= 2
		Return 1 - (Pow(2, 10*(t-1)) - 0.001) / 2
	End
End

Class EaseInBack Extends TweenEquation
	Method Compute:Float(t:Float, args:Float[]=[])
		Local overshoot:Float = 1.70158
		If args.Length >= 1 Then overshoot = args[0]
		Return t*t*((overshoot+1)*t-overshoot)
	End
End

Class EaseOutBack Extends TweenEquation
	Method Compute:Float(t:Float, args:Float[]=[])
		Local overshoot:Float = 1.70158
		If args.Length >= 1 Then overshoot = args[0]
		t -= 1
		Return t*t*((overshoot+1)*t+overshoot) + 1
	End
End

Class EaseInOutBack Extends TweenEquation
	Method Compute:Float(t:Float, args:Float[]=[])
		Local overshoot:Float = 1.70158
		If args.Length >= 1 Then overshoot = args[0]
		overshoot *= 1.525
		t *= 2
		If t < 1 Then Return t*t*((overshoot+1)*t-overshoot) / 2
		t -= 2
		Return (t*t*((overshoot+1)*t+overshoot) + 2) / 2
	End
End

Class EaseInBounce Extends TweenEquation
	Method Compute:Float(t:Float, args:Float[]=[])
		Return 1 - EaseOutBounce.EaseOutMagic(1 - t)
	End
End

Class EaseOutBounce Extends TweenEquation
Private
	' black magic!
	Function EaseOutMagic:Float(t:Float)
		If t < 1 / 2.75 Then
			Return 7.5625 * t * t
		ElseIf t < 2 / 2.75 Then
			t -= 1.5 / 2.75
			Return 7.5625 * t * t + 0.75
		ElseIf t < 2.5 / 2.75 Then
			t -= 2.25 / 2.75
			Return 7.5625 * t * t + 0.9375
		Else
			t -= 2.625 / 2.75
			Return 7.5625 * t * t + 0.984375
		End
	End
	
Public
	Method Compute:Float(t:Float, args:Float[]=[])
		Return EaseOutMagic(t)
	End
End

Class EaseInOutBounce Extends TweenEquation
	Method Compute:Float(t:Float, args:Float[]=[])
		If t = 0 Then Return 0
		If t = 1 Then Return 1
		t *= 2
		If t < 1 Then Return (Pow(2, 10*(t-1)) - 0.001) / 2
		t -= 2
		Return 1 - (Pow(2, 10*(t-1)) - 0.001) / 2
	End
End

Class EaseInElastic Extends TweenEquation
	' [amplitude=1, period=0.3]
	Method Compute:Float(t:Float, args:Float[]=[])
		If t = 0 Then Return 0
		If t = 1 Then Return 1
		Local period:Float = 0.3
		If args.Length >= 2 Then period = args[1]
		Local amplitude:Float = 1
		Local overshoot:Float = period/4
		If args.Length >= 1 And args[0] > 1 Then
			amplitude = args[0]
			overshoot = period / 180 * ASin(1/amplitude)
		End
		t -= 1
		Return -(amplitude * Pow(2, 10*t) * Sin((t-overshoot)*180 / period))
	End
End

Class EaseOutElastic Extends TweenEquation
	' [amplitude=1, period=0.3]
	Method Compute:Float(t:Float, args:Float[]=[])
		If t = 0 Then Return 0
		If t = 1 Then Return 1
		Local period:Float = 0.3
		If args.Length >= 2 Then period = args[1]
		Local amplitude:Float = 1
		Local overshoot:Float = period/4
		If args.Length >= 1 And args[0] > 1 Then
			amplitude = args[0]
			overshoot = period / 180 * ASin(1/amplitude)
		End
		Return amplitude * Pow(2, -10*t) * Sin((t-overshoot)*180 / period) + 1
	End
End

Class EaseInOutElastic Extends TweenEquation
	' [amplitude=1, period=0.3]
	Method Compute:Float(t:Float, args:Float[]=[])
		If t = 0 Then Return 0
		If t = 1 Then Return 1
		' TODO
		Return 0
	End
End

Class TweenPath Abstract
	Global linear:PathLinear = New PathLinear
	Global catmullRom:PathCatmullRom = New PathCatmullRom
	
	Method Compute:Float(t:Float, points:Float[], pointsCnt:Int) Abstract
End

Class PathLinear Extends TweenPath
	Method Compute:Float(t:Float, points:Float[], pointsCnt:Int)
		Local segment:Int = Floor((pointsCnt-1)*t)
		segment = Max(segment, 0)
		segment = Min(segment, pointsCnt-2)
		t = t*(pointsCnt-1) - segment
		Return points[segment] + t * (points[segment+1] - points[segment])
	End
End

Class PathCatmullRom Extends TweenPath
Public
	Method Compute:Float(t:Float, points:Float[], pointsCnt:Int)
		Local segment:Int = Floor((pointsCnt-1)*t)
		segment = Max(segment, 0)
		segment = Min(segment, pointsCnt-2)
		t = t*(pointsCnt-1) - segment

		If segment = 0 Then
			Return CatmullRomSpline(points[0], points[0], points[1], points[2], t)
		End

		If segment = pointsCnt-2 Then
			Return CatmullRomSpline(points[pointsCnt-3], points[pointsCnt-2], points[pointsCnt-1], points[pointsCnt-1], t)
		End

		Return CatmullRomSpline(points[segment-1], points[segment], points[segment+1], points[segment+2], t)
	End
	
Private
	Method CatmullRomSpline:Float(a:Float, b:Float, c:Float, d:Float, t:Float)
		Local t1:Float = (c - a) * 0.5
		Local t2:Float = (d - b) * 0.5

		Local h1:Float = 2 * t * t * t - 3 * t * t + 1
		Local h2:Float = -2 * t * t * t + 3 * t * t
		Local h3:Float = t * t * t - 2 * t * t + t
		Local h4:Float = t * t * t - t * t

		Return b * h1 + c * h2 + t1 * h3 + t2 * h4
	End
End

Class TweenManager
Private
	Field objects:DiddyStack<BaseTween> = New DiddyStack<BaseTween>
	Field isPaused:Bool = False
	
Public
	Global DefaultManager:TweenManager = New TweenManager
	
	Method Add:TweenManager(object:BaseTween)
		If Not objects.Contains(object) Then objects.Push(object)
		If object.isAutoStartEnabled Then object._Start()
		Return Self
	End
	
	Method ContainsTarget:Bool(target:ITweenable)
		For Local i:Int = 0 Until objects.Count()
			If objects.Get(i).ContainsTarget(target) Then Return True
		Next
		Return False
	End
	
	Method ContainsTarget:Bool(target:ITweenable, tweenType:Int)
		For Local i:Int = 0 Until objects.Count()
			If objects.Get(i).ContainsTarget(target, tweenType) Then Return True
		Next
		Return False
	End
	
	Method KillAll:Void()
		For Local i:Int = 0 Until objects.Count()
			objects.Get(i).Kill()
		Next
	End
	
	Method KillTarget:Void(target:ITweenable)
		For Local i:Int = 0 Until objects.Count()
			objects.Get(i).KillTarget(target)
		Next
	End
	
	Method KillTarget:Void(target:ITweenable, tweenType:Int)
		For Local i:Int = 0 Until objects.Count()
			objects.Get(i).KillTarget(target, tweenType)
		Next
	End
	
	Method Pause:Void()
		isPaused = True
	End
	
	Method Resume:Void()
		isPaused = False
	End
	
	Method Update:Void(delta:Float)
		For Local i:Int = objects.Count()-1 To 0 Step -1
			Local obj:BaseTween = objects.Get(i)
			If obj.IsFinished And obj.isAutoRemoveEnabled Then
				objects.Remove(i)
				obj.Free()
			End
		Next
		
		If Not isPaused Then
			If delta >= 0 Then
				For Local i:Int = 0 Until objects.Count()
					objects.Get(i).Update(delta)
				Next
			Else
				For Local i:Int = objects.Count()-1 To 0 Step -1
					objects.Get(i).Update(delta)
				Next
			End
		End
	End
	
	Method Count:Int()
		Return objects.Count()
	End
End

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Private Implementation
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''


























'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Deprecated Tween class
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public
Class TweenDep
	Const TWEEN_TYPE_LINEAR%  = 0
	Const TWEEN_TYPE_SINE%    = 1
	Const TWEEN_TYPE_BOUNCE%  = 2
	Const TWEEN_NEXT_REPEAT%  = 0 ' Repeats the current tween
	Const TWEEN_NEXT_CHAIN%   = 1 ' Moves to the next tween in the chain if it exists, wrapping to the first
	Const TWEEN_NEXT_STOP%    = 2 ' Stops the tween (doesn't repeat or move to the next in the chain)
	Const TWEEN_NEXT_DIE%     = 3 ' Kills the tween entirely
	Const MAX_TWEENS:Int = 200
  
	Global tweens:TweenDep[MAX_TWEENS]
	Global lastFreeTween:Int = 0
	Global minIndex:Int = -1
	Global maxIndex:Int = -1
	Global tweenCount:Int = 0
  
	Field active:Bool = False
	Field type:Int
	Field nextType:Int = TWEEN_NEXT_REPEAT
	Field thisIndex:Int
	
	Field value:Float
	Field currentTicks:Int
	Field length:Int
	
	' linear
	Field linearStart:Float
	Field linearEnd:Float
	Field linearInitial:Float
	
	' bounce
	Field bounceStart:Float
	Field bounceEnd:Float
	Field bounceInitial:Float
	
	' sine/cosine
	Field waveOffset:Float
	Field wavePhase:Float
	Field waveLength:Float
	Field waveAmplitude:Float
	
	' chain
	Field chainFirst:Int = -1
	Field chainLast:Int = -1
	Field chainNext:Int = -1
	Field chainPrevious:Int = -1
	Field chainActive:Int = -1

	Function CacheTweens:Void()
		For Local i:Int = 0 Until MAX_TWEENS
			tweens[i] = New TweenDep(i)
		Next
	End

	Function FindEmpty:Int()
		Local i%=lastFreeTween
		Repeat
			If tweens[i] = Null Then tweens[i] = New TweenDep
			If Not tweens[i].active Then
				Return i
			End
			i += 1
			If i >= MAX_TWEENS Then i = 0
		Until i = lastFreeTween
		Return -1
	End
  
	Function CreateSine:TweenDep(tweenLength:Int, waveOffset#=0, wavePhase#=0, waveAmplitude#=1, waveLength#=1)
		' find a free tween slot and die if we couldn't
		Local idx:Int = FindEmpty()
		If idx < 0 Then Return Null
		
		' update the min/max bounds, and count
		If maxIndex < 0 Or idx > maxIndex Then maxIndex = idx
		If minIndex < 0 Or idx < minIndex Then minIndex = idx
		tweenCount += 1
		
		tweens[idx].active = True
		tweens[idx].type = TWEEN_TYPE_SINE
		tweens[idx].nextType = TWEEN_NEXT_REPEAT
		tweens[idx].length = tweenLength
		tweens[idx].waveOffset = waveOffset
		tweens[idx].wavePhase = wavePhase
		tweens[idx].waveAmplitude = waveAmplitude
		tweens[idx].waveLength = waveLength
		tweens[idx].value = waveOffset + Sin(wavePhase*360)*waveAmplitude
		tweens[idx].chainFirst = -1
		tweens[idx].chainLast = -1
		tweens[idx].chainPrevious = -1
		tweens[idx].chainNext = -1
		tweens[idx].chainActive = -1
		
		Return tweens[idx]
	End

	Function CreateCosine:TweenDep(tweenLength:Int, waveOffset#=0, wavePhase#=0, waveAmplitude#=1, waveLength#=1)
		' find a free tween slot and die if we couldn't
		Local idx:Int = FindEmpty()
		If idx < 0 Then Return Null
		
		' update the min/max bounds, and count
		If maxIndex < 0 Or idx > maxIndex Then maxIndex = idx
		If minIndex < 0 Or idx < minIndex Then minIndex = idx
		tweenCount += 1
		
		' cosine is sine with a phase of 0.5
		wavePhase += 0.5
		While wavePhase >= 1
			wavePhase -= 1
		End
		
		tweens[idx].active = True
		tweens[idx].type = TWEEN_TYPE_SINE
		tweens[idx].nextType = TWEEN_NEXT_REPEAT
		tweens[idx].length = tweenLength
		tweens[idx].waveOffset = waveOffset
		tweens[idx].wavePhase = wavePhase
		tweens[idx].waveAmplitude = waveAmplitude
		tweens[idx].waveLength = waveLength
		tweens[idx].value = waveOffset + Sin(wavePhase*360)*waveAmplitude
		tweens[idx].chainFirst = -1
		tweens[idx].chainLast = -1
		tweens[idx].chainPrevious = -1
		tweens[idx].chainNext = -1
		tweens[idx].chainActive = -1
		
		Return tweens[idx]
	End

	Function CreateLinear:TweenDep(tweenLength:Int, linearStart#, linearEnd#, linearInitial#)
		' find a free tween slot and die if we couldn't
		Local idx:Int = FindEmpty()
		If idx < 0 Then Return Null
		
		' update the min/max bounds, and count
		If maxIndex < 0 Or idx > maxIndex Then maxIndex = idx
		If minIndex < 0 Or idx < minIndex Then minIndex = idx
		tweenCount += 1
		
		tweens[idx].active = True
		tweens[idx].type = TWEEN_TYPE_LINEAR
		tweens[idx].nextType = TWEEN_NEXT_REPEAT
		tweens[idx].length = tweenLength
		tweens[idx].linearStart = linearStart
		tweens[idx].linearEnd = linearEnd
		tweens[idx].linearInitial = linearInitial
		tweens[idx].value = linearInitial
		tweens[idx].chainFirst = -1
		tweens[idx].chainLast = -1
		tweens[idx].chainPrevious = -1
		tweens[idx].chainNext = -1
		tweens[idx].chainActive = -1
		
		Return tweens[idx]
	End

	Function CreateBounce:TweenDep(tweenLength:Int, bounceStart#, bounceEnd#, bounceInitial#)
		' find a free tween slot and die if we couldn't
		Local idx:Int = FindEmpty()
		If idx < 0 Then Return Null
		
		' update the min/max bounds, and count
		If maxIndex < 0 Or idx > maxIndex Then maxIndex = idx
		If minIndex < 0 Or idx < minIndex Then minIndex = idx
		tweenCount += 1
		
		tweens[idx].active = True
		tweens[idx].type = TWEEN_TYPE_BOUNCE
		tweens[idx].nextType = TWEEN_NEXT_REPEAT
		tweens[idx].length = tweenLength
		tweens[idx].bounceStart = bounceStart
		tweens[idx].bounceEnd = bounceEnd
		tweens[idx].bounceInitial = bounceInitial
		tweens[idx].value = bounceInitial
		tweens[idx].chainFirst = -1
		tweens[idx].chainLast = -1
		tweens[idx].chainPrevious = -1
		tweens[idx].chainNext = -1
		tweens[idx].chainActive = -1
		
		Return tweens[idx]
	End
	
	Method AddChain:Void(newTween:TweenDep)
		AddChain(newTween.thisIndex)
	End
	
	Method AddChain:Void(newIndex:Int)
		' start a new chain if we must
		If chainLast < 0 Then
			chainFirst = thisIndex
			chainLast = thisIndex
			chainActive = thisIndex
		End
		' update the next types
		tweens[chainLast].nextType = TWEEN_NEXT_CHAIN
		tweens[newIndex].nextType = TWEEN_NEXT_CHAIN
		' update the chainNext of chainLast to be the new one
		tweens[chainLast].chainNext = newIndex
		' update the chainPrevious of the new tween to be our old chainLast
		tweens[newIndex].chainPrevious = chainLast
		tweens[newIndex].chainFirst = chainFirst
		tweens[newIndex].chainLast = newIndex
		' update the chainLast of all tweens in the chain
		Local i:Int = chainFirst
		While True
			tweens[i].chainLast = newIndex
			If tweens[i].chainNext = newIndex Then Exit
			i = tweens[i].chainNext
		End
	End
	
	Function DestroyTween:Void(tweenIndex:Int)
		' set active false, and continue through the chain
		Local i:Int = tweenIndex
		If tweens[i].chainFirst >= 0 Then i = tweens[i].chainFirst
		Repeat
			tweenCount -= 1
			tweens[i].active = False
			i = tweens[i].chainNext
		Until i < 0 Or Not tweens[i].active
		lastFreeTween = tweenIndex
	End
	
	Function UpdateAll:Void(delta:Int)
		'For Local i:Int = minIndex To maxIndex FIXME: use min/max bounds
		For Local i:Int = 0 Until MAX_TWEENS
			If tweens[i].active And tweens[i].chainFirst < 0 Or tweens[i].chainFirst = i Then
				UpdateTween(i, delta)
			End
		End
	End
	
	Function UpdateTween:Void(index:Int, delta:Int)
		Local t:TweenDep = tweens[index]
		Local at:TweenDep = t
		
		' if this is not the first tween in a chain, die
		If t.chainFirst >= 0 And t.chainFirst <> index Then Return
		
		' jump to the active tween in the chain
		If t.chainFirst >= 0 Then at = tweens[t.chainActive]
		
		' while we still have some delta left
		Local deltaRemaining:Int = delta
		While at.currentTicks + deltaRemaining > at.length
			deltaRemaining -= at.length - at.currentTicks
			If at.nextType = TWEEN_NEXT_CHAIN Then
				If at.chainLast = at.thisIndex Then
					at = tweens[at.chainFirst]
				Else
					at = tweens[at.chainNext]
				End
				Local i:Int = at.chainFirst
				Repeat
					tweens[i].chainActive = at.thisIndex
					i = tweens[i].chainNext
				Until i < 0
				at.currentTicks = 0
			ElseIf at.nextType = TWEEN_NEXT_REPEAT Then
				at.currentTicks = 0
			ElseIf at.nextType = TWEEN_NEXT_STOP Then
				at.currentTicks = at.length
			ElseIf at.nextType = TWEEN_NEXT_DIE Then
				DestroyTween(t.thisIndex)
				Return
			End
		End
		at.currentTicks += deltaRemaining
		t.value = CalcValue(at.thisIndex)
	End
	
	Function CalcValue:Float(index:Int)
		Local progress:Float, value:Float
		Local t:TweenDep = tweens[index]
		Select t.type
			Case TWEEN_TYPE_LINEAR
				progress = Float(t.currentTicks)/Float(t.length)
				If t.linearEnd > t.linearStart Then ' if we're moving forward
					value = t.linearInitial + (t.linearEnd - t.linearStart) * progress
				ElseIf t.linearEnd < t.linearStart Then 'if we're moving backward
					value = t.linearInitial - (t.linearStart - t.linearEnd) * progress
				Else
					value = t.linearInitial
				End
				
			Case TWEEN_TYPE_SINE
				progress = Float(t.currentTicks)/Float(t.length*t.waveLength) + t.wavePhase
				While progress >= 1
					progress -= 1
				End
				While progress < 0
					progress += 1
				End
				value = t.waveOffset + Sin(progress*360) * t.waveAmplitude

			Case TWEEN_TYPE_BOUNCE
				progress = 2*Float(t.currentTicks)/Float(t.length)
				If progress >= 1 Then progress = 2-progress
				If t.bounceEnd > t.bounceStart Then ' if we're moving forward
					value = t.bounceInitial + (t.bounceEnd - t.bounceStart) * progress
				ElseIf t.bounceEnd < t.bounceStart Then ' if we're moving backward
					value = t.bounceInitial - (t.bounceStart - t.bounceEnd) * progress
				Else
					value = t.bounceInitial
				End
		End
		Return value
	End
	
	Method New(thisIndex:Int)
		Self.thisIndex = thisIndex
	End
End




