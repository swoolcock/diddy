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

#Rem
Extend this class to tell the Tweening framework how to tween the T class.
#End
#Rem
Class TweenAccessor<T> Abstract
	Method New()
		tweenAccessors.Add(Self)
	End
	
	Method GetValues:Int(target:T, tweenType:Int, returnValues:Float[]) Abstract
	Method SetValues:Void(target:T, tweenType:Int, newValues:Float[]) Abstract
End
#End

Interface TweenCallback
	Method OnEvent:Void(type:Int, source:ITween)
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
	Field target:Object ' FIXME: use generics?
	'TODO Field accessor:TweenAccessor<T>
	Field type:Int
	Field equation:TweenEquation
	Field path:TweenPath

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
	Field accessorBuffer:Float[] = New Float[combinedAttrsLimit]
	Field pathBuffer:Float[] = New Float[(2+waypointsLimit)*combinedAttrsLimit]
	
''''''''''''''''''''''''''''''''''''''''''''''''''
' Public overrides
''''''''''''''''''''''''''''''''''''''''''''''''''
Public
	Method Reset:Void()
		Super.Reset()
		
		target = Null
		'accessor = Null
		type = -1
		equation = Null
		path = Null

		isFrom = False
		isRelative = False
		combinedAttrsCnt = 0
		waypointsCnt = 0

		If accessorBuffer.Length <> combinedAttrsLimit Then
			accessorBuffer = New Float[combinedAttrsLimit]
		End

		If pathBuffer.Length <> (2+waypointsLimit)*combinedAttrsLimit Then
			pathBuffer = New Float[(2+waypointsLimit)*combinedAttrsLimit]
		End
	End

''''''''''''''''''''''''''''''''''''''''''''''''''
' General private methods
''''''''''''''''''''''''''''''''''''''''''''''''''
Private
	Method Setup(target:Object, tweenType:Int, duration:Float) {
		'FIXME if (duration < 0) throw new RuntimeException("Duration can't be negative");

		Self.target = target
		'this.targetClass = target != null ? findTargetClass() : null;
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
	
'''''''''''''''''''''''''''''''
' Properties
'''''''''''''''''''''''''''''''
Public
#Rem
	Method Accessor:TweenAccessor<T>() Property
		' if we already have an accessor assigned, use that
		If accessor Then Return accessor
		
		' bring the accessors out into the temp array
		Local amt:Int = tweenAccessors.Count()
		If tweenAccessorArray.Length < amt Then
			tweenAccessorArray = tweenAccessors.ToArray()
		Else
			amt = tweenAccessors.FillArray(tweenAccessorArray)
		End
		
		' loop on each registered accessor
		For Local i:Int = 0 Until amt
			Local ta:TweenAccessor<T> = TweenAccessor<T>(tweenAccessorArray[i])
			If ta Then
				' we found one, so assign it and return it
				accessor = ta
				Return ta
			End
		Next
		
		' couldn't find one, so return null
		Return Null
	End
	
	Method Accessor:Void(accessor:TweenAccessor<T>) Property
		Self.accessor = accessor
	End
#End

	Method Ease:TweenEquation() Property
		Return equation
	End ' FIXME
	
	Method Ease:Tween(easeEquation:TweenEquation) Property
		Self.equation = easeEquation
		Return Self
	End
	
	Method Target:Tween(targetValue:Float) Property
		targetValues[0] = targetValue
		Return Self
	End
	
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Factory methods
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public
	Function TweenTo:Tween(target:Object, tweenType:Int, duration:Float)
		Local tween:Tween = GlobalPool<Tween>.Allocate()
		tween.Setup(target, tweenType, duration)
		'FIXME tween.ease(Quad.INOUT);
		'FIXME tween.path(TweenPaths.catmullRom);
		Return tween
	End
	
	Function TweenFrom:Tween(target:Object, tweenType:Int, duration:Float)
		Local tween:Tween = GlobalPool<Tween>.Allocate()
		tween.Setup(target, tweenType, duration)
		'FIXME tween.ease(Quad.INOUT);
		'FIXME tween.path(TweenPaths.catmullRom);
		tween.isFrom = True
		Return tween
	End
	
	Function Set:Tween(target:Object, tweenType:Int)
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
	
	Method Repeat:Tween(count:Int, delay:Float)
		Return Tween(_Repeat(count, delay))
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
End

Class BaseTween Implements IPoolable Abstract
''''''''''''''''''''''''''''''''''''''''''''''''''
' Private Fields
''''''''''''''''''''''''''''''''''''''''''''''''''
Private
	' General
	Field currentStep:Int;
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

	' Misc
	Field callback:TweenCallback
	Field callbackTriggers:Int
	Field userData:Object

	' Package access
	Field isAutoRemoveEnabled:Bool
	Field isAutoStartEnabled:Bool
	
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

	Method KillTarget:Void(target:Object)
		If ContainsTarget(target) Then Kill()
	End

	Method KillTarget:Void(target:Object, tweenType:Int)
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
	
	Method _Repeat:BaseTween(count:Int, delay:Float)
		'if (isStarted) throw new RuntimeException("You can't change the repetitions of a tween or timeline once it is started");
		repeatCnt = count
		If delay >= 0 Then repeatDelay = delay Else repeatDelay = 0
		isYoyo = False
		Return Self
	End
	
	Method _RepeatYoyo:BaseTween(count:Int, delay:Float)
		'if (isStarted) throw new RuntimeException("You can't change the repetitions of a tween or timeline once it is started");
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
	Method ContainsTarget:Bool(target:Object) Abstract
	Method ContainsTarget:Bool(target:Object, tweenType:Int) Abstract
	
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
	
	Method UserData:Object() Property
		Return userData
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
End ' End Class BaseTween

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Private Implementation
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private

#Rem
' declared outside TweenAccessor class so that it's not bound to <T>
Global tweenAccessors:DiddyStack<Object> = New DiddyStack<Object>
Global tweenAccessorArray:Object[]
#End





























'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Deprecated Tween class
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
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




