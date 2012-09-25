Strict

Public
Import exception
Import functions
Import collections

Private
Import mojo

Public
Const TRANSFORM_NONE:Int = 0
Const TRANSFORM_POSITION:Int = 1
Const TRANSFORM_ALPHA:Int = 2
Const TRANSFORM_SCALE:Int = 3
Const TRANSFORM_ROTATION:Int = 4
Const TRANSFORM_COLOR:Int = 5
Const TRANSFORM_COUNT:Int = 6

Const EASE_NONE:Int = 0
Const EASE_IN_DOUBLE:Int = 1
Const EASE_IN:Int = 2
Const EASE_IN_HALF:Int = 3
Const EASE_OUT:Int = 4
Const EASE_OUT_HALF:Int = 5
Const EASE_OUT_DOUBLE:Int = 6
Const EASE_IN_OUT:Int = 7

Const COLORSPACE_RGB:Int = 0
Const COLORSPACE_HSL:Int = 1

Class TransformationGroup
Private
	Global hslArray:Float[] = New Float[3]
	Global rgbArray:Int[] = New Int[3]
	Field transformations:ArrayList<Transformation>[] = New ArrayList<Transformation>[TRANSFORM_COUNT]
	Field currentTransform:Transformation[] = New Transformation[TRANSFORM_COUNT]
	Field lastTime:Int = 0
	
	Field defaultX:Float = 0
	Field defaultY:Float = 0
	Field defaultScaleX:Float = 1
	Field defaultScaleY:Float = 1
	Field defaultRotation:Float = 0
	Field defaultAlpha:Float = 1
	Field defaultRed:Float = 255
	Field defaultGreen:Float = 255
	Field defaultBlue:Float = 255
	Field defaultHue:Float = 0
	Field defaultSaturation:Float = 1
	Field defaultLuminance:Float = 0.5
	
Public
	Method Add:Void(type:Int, tr:Transformation)
		If type < 0 Or type >= TRANSFORM_COUNT Then Throw New IllegalArgumentException("Invalid transformation type: "+type)
		If Not transformations[type] Then transformations[type] = New ArrayList<Transformation>
		transformations[type].Add(tr)
		transformations[type].Sort()
		tr.Update(lastTime)
	End
	
	Method Remove:Void(type:Int, tr:Transformation)
		If type < 0 Or type >= TRANSFORM_COUNT Then Throw New IllegalArgumentException("Invalid transformation type: "+type)
		If Not transformations[type] Then Return
		transformations[type].Remove(tr)
	End
	
	Method Clear:Void(type:Int)
		If type < 0 Or type >= TRANSFORM_COUNT Then Throw New IllegalArgumentException("Invalid transformation type: "+type)
		If Not transformations[type] Then Return
		transformations[type].Clear()
	End
	
	Method New(x#=0, y#=0, scaleX#=1, scaleY#=1, rotation#=0, alpha#=1, red#=255, green#=255, blue#=255, hue#=0.0, saturation#=1.0, luminance#=0.5, colorSpace%=COLORSPACE_RGB)
		defaultX = x
		defaultY = y
		defaultScaleX = scaleX
		defaultScaleY = scaleY
		defaultRotation = rotation
		defaultAlpha = alpha
		If colorSpace = COLORSPACE_RGB Then
			RGBtoHSL(red, green, blue, hslArray)
			hue = hslArray[0]
			saturation = hslArray[1]
			luminance = hslArray[2]
		ElseIf colorSpace = COLORSPACE_HSL Then
			HSLtoRGB(hue, saturation, luminance, rgbArray)
			red = rgbArray[0]
			green = rgbArray[1]
			blue = rgbArray[2]
		End
		defaultRed = red
		defaultGreen = green
		defaultBlue = blue
		defaultHue = hue
		defaultSaturation = saturation
		defaultLuminance = luminance
	End
	
	Method Update:Void(currentTime:Int)
		' store time for calls to Add
		lastTime = currentTime
		
		' clear out current transforms
		For Local i:Int = 0 Until currentTransform.Length
			currentTransform[i] = Null
		Next
		
		For Local i:Int = 0 Until transformations.Length
			If transformations[i] Then
				' these should be sorted
				For Local j:Int = 0 Until transformations[i].Size
					Local tr:Transformation = transformations[i].Get(j)
					tr.Update(currentTime)
					If currentTime >= tr.startTime Or Not currentTransform[i] And currentTime >= tr.firstStartTime Then
						currentTransform[i] = tr
					End
				Next
			End
		Next
	End
	
	Method GetCurrentTransformation:Transformation(type:Int)
		If type < 0 Or type >= TRANSFORM_COUNT Then Throw New IllegalArgumentException("Invalid transformation type: "+type)
		Return currentTransform[type]
	End
	
	' convenience methods
	
	Method CurrentScaleX:Float() Property
		Local tr:TransformationVector = TransformationVector(currentTransform[TRANSFORM_SCALE])
		If Not tr Then Return defaultScaleX
		Return tr.CurrentX
	End
	
	Method CurrentScaleY:Float() Property
		Local tr:TransformationVector = TransformationVector(currentTransform[TRANSFORM_SCALE])
		If Not tr Then Return defaultScaleY
		Return tr.CurrentY
	End
	
	Method CurrentAlpha:Float() Property
		Local tr:TransformationValue = TransformationValue(currentTransform[TRANSFORM_ALPHA])
		If Not tr Then Return defaultAlpha
		Return tr.CurrentValue
	End
	
	Method CurrentRed:Float() Property
		Local tr:TransformationColor = TransformationColor(currentTransform[TRANSFORM_COLOR])
		If Not tr Then Return defaultRed
		Return tr.CurrentRed
	End
	
	Method CurrentGreen:Float() Property
		Local tr:TransformationColor = TransformationColor(currentTransform[TRANSFORM_COLOR])
		If Not tr Then Return defaultGreen
		Return tr.CurrentGreen
	End
	
	Method CurrentBlue:Float() Property
		Local tr:TransformationColor = TransformationColor(currentTransform[TRANSFORM_COLOR])
		If Not tr Then Return defaultBlue
		Return tr.CurrentBlue
	End
	
	Method CurrentHue:Float() Property
		Local tr:TransformationColor = TransformationColor(currentTransform[TRANSFORM_COLOR])
		If Not tr Then Return defaultHue
		Return tr.CurrentHue
	End
	
	Method CurrentSaturation:Float() Property
		Local tr:TransformationColor = TransformationColor(currentTransform[TRANSFORM_COLOR])
		If Not tr Then Return defaultSaturation
		Return tr.CurrentSaturation
	End
	
	Method CurrentLuminance:Float() Property
		Local tr:TransformationColor = TransformationColor(currentTransform[TRANSFORM_COLOR])
		If Not tr Then Return defaultLuminance
		Return tr.CurrentLuminance
	End
	
	Method CurrentX:Float() Property
		Local tr:TransformationVector = TransformationVector(currentTransform[TRANSFORM_POSITION])
		If Not tr Then Return defaultX
		Return tr.CurrentX
	End
	
	Method CurrentY:Float() Property
		Local tr:TransformationVector = TransformationVector(currentTransform[TRANSFORM_POSITION])
		If Not tr Then Return defaultY
		Return tr.CurrentY
	End
	
	Method CurrentRotation:Float() Property
		Local tr:TransformationValue = TransformationValue(currentTransform[TRANSFORM_ROTATION])
		If Not tr Then Return defaultRotation
		Return tr.CurrentValue
	End
	
	Method Apply:Void()
		SetColor(CurrentRed, CurrentGreen, CurrentBlue)
		Translate(CurrentX, CurrentY)
		Scale(CurrentScaleX, CurrentScaleY)
		Rotate(CurrentRotation)
		SetAlpha(CurrentAlpha)
	End
End

Class Transformation Implements IComparable Abstract
Private
	Field loop:Bool
	Field loopDelay:Int
	Field easeType:Int
	Field firstStartTime:Int
	Field firstEndTime:Int
	Field startTime:Int
	Field endTime:Int
	Field currentTime:Int
	Field started:Bool
	Field finished:Bool
	Field needsRecalc:Bool = True
	
Public
	Method StartTime:Int() Property Return startTime End
	Method StartTime:Void(startTime:Int) Property Self.startTime = startTime; needsRecalc = True End
	Method EndTime:Int() Property Return endTime End
	Method EndTime:Void(endTime:Int) Property Self.endTime = endTime; needsRecalc = True End
	Method EaseType:Int() Property Return easeType End
	Method EaseType:Void(easeType:Int) Property Self.easeType = easeType End
	Method Loop:Bool() Property Return loop End
	Method Loop:Void(loop:Bool) Property Self.loop = loop End
	Method LoopDelay:Int() Property Return loopDelay End
	Method LoopDelay:Void(loopDelay:Int) Property Self.loopDelay = loopDelay End
	Method Started:Bool() Property Return started End
	Method Finished:Bool() Property Return finished End
	Method Duration:Int() Property Return endTime - startTime End
	
	Method New(startTime:Int, endTime:Int, easeType:Int=EASE_NONE, loop:Bool=False, loopDelay:Int=0)
		Self.startTime = startTime
		Self.endTime = endTime
		Self.firstStartTime = startTime
		Self.firstEndTime = endTime
		Self.easeType = easeType
		Self.loop = loop
		Self.loopDelay = loopDelay
	End
	
	Method Update:Void(currentTime:Int)
		Self.currentTime = currentTime
		If loop And endTime < currentTime Then
			Local duration:Int = endTime - startTime + loopDelay
			Local remainder:Int = currentTime - endTime
			startTime += (remainder / duration + 1) * duration
			endTime += (remainder / duration + 1) * duration
		End
		started = currentTime >= startTime
		finished = started And currentTime >= endTime And Not loop
		Recalc(True)
	End
	
	Method Compare:Int(other:Object)
		If Not Transformation(other) Then Return 1
		If other = Self Then Return 0
		Local o:Transformation = Transformation(other)
		If startTime > o.startTime Then Return 1
		If startTime < o.startTime Then Return -1
		If endTime > o.endTime Then Return 1
		If endTime < o.endTime Then Return -1
		If easeType > o.easeType Then Return 1
		If easeType < o.easeType Then Return -1
		If loop And Not o.loop Then Return 1
		If Not loop And o.loop Then Return -1
		If loopDelay > o.loopDelay Then Return 1
		If loopDelay < o.loopDelay Then Return -1
		If started And Not o.started Then Return 1
		If Not started And o.started Then Return -1
		If finished And Not o.finished Then Return 1
		If Not finished And o.finished Then Return -1
		Return 0
	End
	
	Method Equals:Bool(other:Object)
		Return Compare(other) = 0
	End
	
Private
	Method Recalc:Void(force:Bool=False)
		If Not needsRecalc And Not force Then Return
		needsRecalc = False
		DoRecalc()
	End
	
	Method DoRecalc:Void() Abstract
	
	Method Calculate:Float(startValue:Float, endValue:Float)
		' if we've never started, return the start value
		If currentTime <= firstStartTime Then Return startValue
		
		' if we're at the end or between loops, return the end value
		If currentTime >= endTime Or currentTime < startTime Or startTime = endTime Then Return endValue

		' how far through are we?
		Local progress:Float = Float(currentTime - startTime) / Float(endTime - startTime)
		
		Select easeType
			Case EASE_IN_DOUBLE
				Return Lerp(endValue, startValue, (1-progress)*(1-progress)*(1-progress)*(1-progress))
			Case EASE_IN
				Return Lerp(endValue, startValue, (1-progress)*(1-progress))
			Case EASE_IN_HALF
				Return Lerp(endValue, startValue, Pow(1-progress, 1.5))
			Case EASE_OUT
				Return Lerp(startValue, endValue, progress * progress)
			Case EASE_OUT_HALF
				Return Lerp(startValue, endValue, Pow(progress, 1.5))
			Case EASE_OUT_DOUBLE
				Return Lerp(startValue, endValue, progress*progress*progress*progress)
			Case EASE_IN_OUT
				Return startValue + (-2*(progress*progress*progress) + 3*(progress*progress)) * (endValue - startValue)
			Default
				Return Lerp(startValue, endValue, progress);
		End
	End
	
	Method Lerp:Float(startValue:Float, endValue:Float, progress:Float)
		Return startValue + (endValue-startValue) * progress
	End
End

Class TransformationColor Extends Transformation
Private
	Global hslArray:Float[] = New Float[3]
	Global rgbArray:Int[] = New Int[3]
	Field startH:Float
	Field startS:Float
	Field startL:Float
	Field startR:Int
	Field startG:Int
	Field startB:Int
	Field endH:Float
	Field endS:Float
	Field endL:Float
	Field endR:Int
	Field endG:Int
	Field endB:Int
	Field currentH:Float
	Field currentS:Float
	Field currentL:Float
	Field currentR:Int
	Field currentG:Int
	Field currentB:Int
	
Public
	Method StartRed:Int() Property Return startR End
	Method StartGreen:Int() Property Return startG End
	Method StartBlue:Int() Property Return startB End
	Method EndRed:Int() Property Return endR End
	Method EndGreen:Int() Property Return endG End
	Method EndBlue:Int() Property Return endB End
	Method StartHue:Int() Property Return startH End
	Method StartSaturation:Int() Property Return startS End
	Method StartLuminance:Int() Property Return startL End
	Method EndHue:Int() Property Return endH End
	Method EndSaturation:Int() Property Return endS End
	Method EndLuminance:Int() Property Return endL End
	Method CurrentRed:Int() Property Recalc(); Return currentR End
	Method CurrentGreen:Int() Property Recalc(); Return currentG End
	Method CurrentBlue:Int() Property Recalc(); Return currentB End
	Method CurrentHue:Int() Property Recalc(); Return currentH End
	Method CurrentSaturation:Int() Property Recalc(); Return currentS End
	Method CurrentLuminance:Int() Property Recalc(); Return currentL End
	
	Method New(start1:Float, start2:Float, start3:Float, end1:Float, end2:Float, end3:Float, startTime:Int, endTime:Int, easeType:Int=EASE_NONE, loop:Bool=False, loopDelay:Int=0, colorSpace:Int=COLORSPACE_RGB)
		Super.New(startTime, endTime, easeType, loop, loopDelay)
		If colorSpace = COLORSPACE_RGB Then
			SetStartRGB(Int(start1), Int(start2), Int(start3))
			SetEndRGB(Int(end1), Int(end2), Int(end3))
		ElseIf colorSpace = COLORSPACE_HSL Then
			SetStartHSL(start1, start2, start3)
			SetEndHSL(end1, end2, end3)
		Else
			Throw New IllegalArgumentException("Invalid colorspace: "+colorSpace)
		End
		needsRecalc = True
	End
	
	Method SetStartRGB:Void(startR:Int, startG:Int, startB:Int)
		Self.startR = Max(0,Min(255,startR))
		Self.startG = Max(0,Min(255,startG))
		Self.startB = Max(0,Min(255,startB))
		RecalcStartHSL()
		needsRecalc = True
	End
	
	Method SetEndRGB:Void(endR:Int, endG:Int, endB:Int)
		Self.endR = Max(0,Min(255,endR))
		Self.endG = Max(0,Min(255,endG))
		Self.endB = Max(0,Min(255,endB))
		RecalcEndHSL()
		needsRecalc = True
	End
	
	Method SetStartHSL:Void(startH:Float, startS:Float, startL:Float)
		Self.startH = Max(0.0,Min(1.0,startH))
		Self.startS = Max(0.0,Min(1.0,startS))
		Self.startL = Max(0.0,Min(1.0,startL))
		RecalcStartRGB()
		needsRecalc = True
	End
	
	Method SetEndHSL:Void(endH:Float, endS:Float, endL:Float)
		Self.endH = Max(0.0,Min(1.0,endH))
		Self.endS = Max(0.0,Min(1.0,endS))
		Self.endL = Max(0.0,Min(1.0,endL))
		RecalcEndRGB()
		needsRecalc = True
	End
	
Private
	Method RecalcStartRGB:Void()
		HSLtoRGB(startH, startS, startL, rgbArray)
		Self.startR = rgbArray[0]
		Self.startG = rgbArray[1]
		Self.startB = rgbArray[2]
	End
	
	Method RecalcEndRGB:Void()
		HSLtoRGB(endH, endS, endL, rgbArray)
		Self.endR = rgbArray[0]
		Self.endG = rgbArray[1]
		Self.endB = rgbArray[2]
	End
	
	Method RecalcStartHSL:Void()
		RGBtoHSL(startR, startG, startB, hslArray)
		Self.startH = hslArray[0]
		Self.startS = hslArray[1]
		Self.startL = hslArray[2]
	End
	
	Method RecalcEndHSL:Void()
		RGBtoHSL(endR, endG, endB, hslArray)
		Self.endH = hslArray[0]
		Self.endS = hslArray[1]
		Self.endL = hslArray[2]
	End
	
	Method DoRecalc:Void()
		currentH = Calculate(Self.startH, Self.endH)
		currentS = Calculate(Self.startS, Self.endS)
		currentL = Calculate(Self.startL, Self.endL)
		HSLtoRGB(currentH, currentS, currentL, rgbArray)
		currentR = rgbArray[0]
		currentG = rgbArray[1]
		currentB = rgbArray[2]
	End
End

Class TransformationValue Extends Transformation
Private
	Field startValue:Float
	Field endValue:Float
	Field currentValue:Float
	
Public
	Method CurrentValue:Float() Property Recalc(); Return currentValue End
	Method StartValue:Float() Property Return startValue End
	Method StartValue:Void(startValue:Float) Property Self.startValue = startValue; needsRecalc = True End
	Method EndValue:Float() Property Return endValue End
	Method EndValue:Void(endValue:Float) Property Self.endValue = endValue; needsRecalc = True End
	
	Method New(startValue:Float, endValue:Float, startTime:Int, endTime:Int, easeType:Int=EASE_NONE, loop:Bool=False, loopDelay:Int=0)
		Super.New(startTime, endTime, easeType, loop, loopDelay)
		Self.startValue = startValue
		Self.endValue = endValue
	End
	
Private
	Method DoRecalc:Void()
		currentValue = Calculate(startValue, endValue)
	End
End

Class TransformationVector Extends Transformation
Private
	Field startX:Float
	Field startY:Float
	Field endX:Float
	Field endY:Float
	Field currentX:Float
	Field currentY:Float
	
Public
	Method CurrentX:Float() Property Recalc(); Return currentX End
	Method CurrentY:Float() Property Recalc(); Return currentY End
	Method StartX:Float() Property Return startX End
	Method StartX:Void(startX:Float) Property Self.startX = startX; needsRecalc = True End
	Method StartY:Float() Property Return startY End
	Method StartY:Void(startY:Float) Property Self.startY = startY; needsRecalc = True End
	Method EndX:Float() Property Return endX End
	Method EndX:Void(endX:Float) Property Self.endX = endX; needsRecalc = True End
	Method EndY:Float() Property Return endY End
	Method EndY:Void(endY:Float) Property Self.endY = endY; needsRecalc = True End
	
	Method New(startX:Float, startY:Float, endX:Float, endY:Float, startTime:Int, endTime:Int, easeType:Int=EASE_NONE, loop:Bool=False, loopDelay:Int=0)
		Super.New(startTime, endTime, easeType, loop, loopDelay)
		Self.startX = startX
		Self.startY = startY
		Self.endX = endX
		Self.endY = endY
	End
	
Private
	Method DoRecalc:Void()
		currentX = Calculate(startX, endX)
		currentY = Calculate(startY, endY)
	End
End
