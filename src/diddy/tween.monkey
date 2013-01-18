Strict

Class Tween
	Const TWEEN_TYPE_LINEAR%  = 0
	Const TWEEN_TYPE_SINE%    = 1
	Const TWEEN_TYPE_BOUNCE%  = 2
	Const TWEEN_NEXT_REPEAT%  = 0 ' Repeats the current tween
	Const TWEEN_NEXT_CHAIN%   = 1 ' Moves to the next tween in the chain if it exists, wrapping to the first
	Const TWEEN_NEXT_STOP%    = 2 ' Stops the tween (doesn't repeat or move to the next in the chain)
	Const TWEEN_NEXT_DIE%     = 3 ' Kills the tween entirely
	Const MAX_TWEENS:Int = 200
  
	Global tweens:Tween[MAX_TWEENS]
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
			tweens[i] = New Tween(i)
		Next
	End

	Function FindEmpty:Int()
		Local i%=lastFreeTween
		Repeat
			If tweens[i] = Null Then tweens[i] = New Tween
			If Not tweens[i].active Then
				Return i
			End
			i += 1
			If i >= MAX_TWEENS Then i = 0
		Until i = lastFreeTween
		Return -1
	End
  
	Function CreateSine:Tween(tweenLength:Int, waveOffset#=0, wavePhase#=0, waveAmplitude#=1, waveLength#=1)
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

	Function CreateCosine:Tween(tweenLength:Int, waveOffset#=0, wavePhase#=0, waveAmplitude#=1, waveLength#=1)
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

	Function CreateLinear:Tween(tweenLength:Int, linearStart#, linearEnd#, linearInitial#)
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

	Function CreateBounce:Tween(tweenLength:Int, bounceStart#, bounceEnd#, bounceInitial#)
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
	
	Method AddChain:Void(newTween:Tween)
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
		Local t:Tween = tweens[index]
		Local at:Tween = t
		
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
		Local t:Tween = tweens[index]
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




