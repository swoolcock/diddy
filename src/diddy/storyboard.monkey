Strict

Public
Import exception

Private
Import mojo
Import functions
Import collections

Const TRANSFORM_POSITION:Int = 0
Const TRANSFORM_ALPHA:Int = 1
Const TRANSFORM_SCALE:Int = 2
Const TRANSFORM_SCALE_VECTOR:Int = 3
Const TRANSFORM_ROTATION:Int = 4
Const TRANSFORM_COLOR:Int = 5
Const TRANSFORM_HANDLE:Int = 6
Const TRANSFORM_SHAKE:Int = 7
Const TRANSFORM_COUNT:Int = 8

Const EASE_NONE:Int = 0
Const EASE_IN_DOUBLE:Int = 1
Const EASE_IN:Int = 2
Const EASE_IN_HALF:Int = 3
Const EASE_OUT:Int = 4
Const EASE_OUT_HALF:Int = 5
Const EASE_OUT_DOUBLE:Int = 6
Const EASE_IN_OUT:Int = 7

Class Storyboard
Private
	Field sprites:ArrayList<StoryboardSprite> = New ArrayList<StoryboardSprite>
	Field sounds:ArrayList<StoryboardSound> = New ArrayList<StoryboardSound>

Public
	Function LoadXML:Storyboard(filename:String)
		Local parser:XMLParser = New XMLParser
		Local doc:XMLDocument = parser.LoadFile("storyboard.xml")
		Local root:XMLElement = doc.Root
		Local sb:Storyboard = New Storyboard
		For Local node:XMLElement = EachIn root.Children
			If node.Name = "layer" Then
				Local index:Int = Int(node.GetAttribute("index","0"))
				For Local spriteNode:XMLElement = EachIn node.Children
					If spriteNode.Name = "sprite" Then
						sb.sprites.Add(StoryboardSprite.CreateFromXML(spriteNode, index))
					End
				Next
			End
		Next
		sb.sprites.Sort()
		Return sb
	End
	
	Method Update:Void(currentTime:Int)
		For Local i:Int = 0 Until sprites
			Local sprite:StoryboardSprite = sprites.Get(i)
			sprite.Update(currentTime)
		Next
		'For Local i:Int = 0 Until sounds
		'	Local sound:StoryboardSound = sounds.Get(i)
		'	sound.Update(currentTime)
		'Next
	End
	
	Method Render:Void()
		For Local i:Int = 0 Until sprites
			Local sprite:StoryboardSprite = sprites.Get(i)
			sprite.Render()
		Next
	End
End

Class StoryboardElement Implements IComparable Abstract
Private
	Global nextId:Int = 0
	Field id:Int
	
Public
	Method New()
		id = nextId
		nextId += 1
	End
	
	Method Compare:Int(other:Object)
		Local o:StoryboardElement = StoryboardElement(other)
		If Not o Then Return -1
		If o = Self Then Return 0
		If id < o.id Then Return -1
		If id > o.id Then Return 1
		Return 0
	End
	
	Method Equals:Bool(other:Object)
		Return Compare(other)=0
	End
End

Class StoryboardSound Extends StoryboardElement
Private
	Field soundName:String
	Field sound:GameSound
	
Public
	Function CreateFromXML:StoryboardSound(node:XMLElement)
		Return Null
	End
	
	Method New(soundName:String)
		Super.New()
		Self.soundName = soundName
	End
End

Class StoryboardSprite Extends StoryboardElement
Private
	Field layer:Int
	Field imageName:String
	Field image:GameImage
	
	Field transforms:ArrayList<StoryboardSpriteTransform> = New ArrayList<StoryboardSpriteTransform>
	Field currentTransforms:StoryboardSpriteTransform[] = New StoryboardSpriteTransform[TRANSFORM_COUNT]
	
Public
	Function CreateFromXML:StoryboardSprite(node:XMLElement, layer:Int)
		Local imageName:String = node.GetAttribute("imageName","")
		Local sprite:StoryboardSprite = New StoryboardSprite(imageName, layer)
		CreateTransformsFromXML(sprite, node)
		Return sprite
	End
	
	Function CreateTransformsFromXML:Void(sprite:StoryboardSprite, node:XMLElement, timeOffset:Int=0)
		For Local childNode:XMLElement = EachIn node.Children
			Local name:String = childNode.Name
			If name = "group" Then
				Local loopCount:Int = Int(childNode.GetAttribute("loopCount","1"))
				Local startTime:Int = Int(childNode.GetAttribute("startTime","0"))
				Local endTime:Int = Int(childNode.GetAttribute("endTime","0"))
				Local myOffset:Int = timeOffset + startTime
				For Local i:Int = 0 Until loopCount
					CreateTransformsFromXML(sprite, childNode, myOffset)
					myOffset += endTime - startTime
				Next
			Else
				sprite.transforms.Add(StoryboardSpriteTransform.CreateFromXML(childNode, timeOffset))
			End
		Next
	End
	
	Method New(imageName:String, layer:Int)
		Super.New()
		Self.imageName = imageName
		Self.layer = layer
	End
	
	Method Compare:Int(other:Object)
		Local o:StoryboardSprite = StoryboardSprite(other)
		If Not o Then Return -1
		If o = Self Then Return 0
		If layer < o.layer Then Return -1
		If layer > o.layer Then Return 1
		Return Super.Compare(other)
	End
	
	Method Update:Void(currentTime:Int)
		For Local i:Int = 0 Until transforms.Size
			transforms.Get(i).Update(currentTime)
		Next
		For Local i:Int = 0 Until currentTransforms.Length
			currentTransforms[i] = GetActiveTransform(i, currentTime)
		Next
	End
	
	Method Render:Void()
		If Not image Then image = game.images.Find(imageName)
		If Not image Then Return
		PushMatrix
		' translation, scale, rotation, handle, other effects
		If currentTransforms[TRANSFORM_POSITION] Then currentTransforms[TRANSFORM_POSITION].Apply()
		If currentTransforms[TRANSFORM_SCALE_VECTOR] Then currentTransforms[TRANSFORM_SCALE_VECTOR].Apply()
		If currentTransforms[TRANSFORM_SCALE] Then currentTransforms[TRANSFORM_SCALE].Apply()
		If currentTransforms[TRANSFORM_ROTATION] Then currentTransforms[TRANSFORM_ROTATION].Apply()
		If currentTransforms[TRANSFORM_HANDLE] Then currentTransforms[TRANSFORM_HANDLE].Apply()
		If currentTransforms[TRANSFORM_SHAKE] Then currentTransforms[TRANSFORM_SHAKE].Apply()
		If currentTransforms[TRANSFORM_COLOR] Then currentTransforms[TRANSFORM_COLOR].Apply()
		image.Draw(0, 0)
		PopMatrix
	End
	
	Method GetActiveTransform:StoryboardSpriteTransform(findType:Int, atTime:Int)
		' by default, we haven't found anything
		Local active:StoryboardSpriteTransform = Null
		' loop on all children
		For Local i:Int = 0 Until transforms.Size
			Local tr:StoryboardSpriteTransform = transforms.Get(i)
			If tr.transformType = findType Then
				' if we're past the start time for this transform
				If atTime >= tr.startTime Then
					active = child
				Else
					' we've gone past the current time, so break out
					Exit
				End
			End
		Next
		' return what we have
		Return active
	End
End

Class StoryboardSpriteTransform Implements IComparable
Private
	Global hslArray:Float[] = New Float[3]
	Global rgbArray:Int[] = New Int[3]
	
	Field transformType:Int = TRANSFORM_NONE
	
	Field currentTime:Int
	Field startTime:Int
	Field endTime:Int
	Field easeType:Int
	
	Field startValues:Float[]
	Field endValues:Float[]
	Field currentValues:Float[]
	
Public
	Function CreateFromXML:StoryboardSpriteTransform(node:XMLElement, timeOffset:Int=0)
		Local name:String = node.Name
		Local startTime:Int = Int(node.GetAttribute("startTime","0"))+timeOffset
		Local endTime:Int = Int(node.GetAttribute("endTime","0"))+timeOffset
		Local easeType:Int = Int(node.GetAttribute("easeType","0"))
		If name = "scale" Then
			Local startScale:Float = Float(node.GetAttribute("startScale","1"))
			Local endScale:Float = Float(node.GetAttribute("endScale","1"))
			Return CreateScale(startTime, endTime, easeType, startScale, endScale)
		ElseIf name = "scaleVector" Then
			Local startScaleX:Float = Float(node.GetAttribute("startScaleX","1"))
			Local endScaleX:Float = Float(node.GetAttribute("endScaleX","1"))
			Local startScaleY:Float = Float(node.GetAttribute("startScaleY","1"))
			Local endScaleY:Float = Float(node.GetAttribute("endScaleY","1"))
			Return CreateScaleVector(startTime, endTime, easeType, startScaleX, startScaleY, endScaleX, endScaleY)
		ElseIf name = "alpha" Then
			Local startAlpha:Float = Float(node.GetAttribute("startAlpha","1"))
			Local endAlpha:Float = Float(node.GetAttribute("endAlpha","1"))
			Return CreateAlpha(startTime, endTime, easeType, startAlpha, endAlpha)
		ElseIf name = "rotation" Then
			Local startRotation:Float = Float(node.GetAttribute("startRotation","0"))
			Local endRotation:Float = Float(node.GetAttribute("endRotation","0"))
			Return CreateRotation(startTime, endTime, easeType, startRotation, endRotation)
		ElseIf name = "position" Then
			Local startX:Float = Float(node.GetAttribute("startX","0"))
			Local endX:Float = Float(node.GetAttribute("endX","0"))
			Local startY:Float = Float(node.GetAttribute("startY","0"))
			Local endY:Float = Float(node.GetAttribute("endY","0"))
			Return CreatePosition(startTime, endTime, easeType, startX, startY, endX, endY)
		ElseIf name = "handle" Then
			Local startX:Float = Float(node.GetAttribute("startX","0"))
			Local endX:Float = Float(node.GetAttribute("endX","0"))
			Local startY:Float = Float(node.GetAttribute("startY","0"))
			Local endY:Float = Float(node.GetAttribute("endY","0"))
			Return CreateHandle(startTime, endTime, easeType, startX, startY, endX, endY)
		ElseIf name = "color" Then
			If node.HasAttribute("startRed") Or node.HasAttribute("startGreen") Or node.HasAttribute("startBlue") Then
				Local startRed:Float = Float(node.GetAttribute("startRed","255"))
				Local endRed:Float = Float(node.GetAttribute("endRed","255"))
				Local startGreen:Float = Float(node.GetAttribute("startGreen","255"))
				Local endGreen:Float = Float(node.GetAttribute("endGreen","255"))
				Local startBlue:Float = Float(node.GetAttribute("startBlue","255"))
				Local endBlue:Float = Float(node.GetAttribute("endBlue","255"))
				Return CreateColorRGB(startTime, endTime, easeType, startRed, startGreen, startBlue, endRed, endGreen, endBlue)
			Else
				Local startHue:Float = Float(node.GetAttribute("startHue","0"))
				Local endHue:Float = Float(node.GetAttribute("endHue","0"))
				Local startSaturation:Float = Float(node.GetAttribute("startSaturation","1"))
				Local endSaturation:Float = Float(node.GetAttribute("endSaturation","1"))
				Local startLuminance:Float = Float(node.GetAttribute("startLuminance","1"))
				Local endLuminance:Float = Float(node.GetAttribute("endLuminance","1"))
				Return CreateColorHSL(startTime, endTime, easeType, startHue, startSaturation, startLuminance, endHue, endSaturation, endLuminance)
			End
		End
	End
	
	Function CreateScale:StoryboardSpriteTransform(startTime%, endTime%, easeType%, startScale#, endScale#)
		Return New StoryboardSpriteTransform(TRANSFORM_SCALE, startTime, endTime, easeType, startScale, endScale)
	End
	
	Function CreateScaleVector:StoryboardSpriteTransform(startTime%, endTime%, easeType%, startScaleX#, startScaleY#, endScaleX#, endScaleY#)
		Return New StoryboardSpriteTransform(TRANSFORM_SCALE_VECTOR, startTime, endTime, easeType, startScaleX, endScaleX, startScaleY, endScaleY)
	End
	
	Function CreateAlpha:StoryboardSpriteTransform(startTime%, endTime%, easeType%, startAlpha#, endAlpha#)
		startAlpha = Max(0.0,Min(1.0,startAlpha))
		endAlpha = Max(0.0,Min(1.0,endAlpha))
		Return New StoryboardSpriteTransform(TRANSFORM_ALPHA, startTime, endTime, easeType, startAlpha, endAlpha)
	End
	
	Function CreateRotation:StoryboardSpriteTransform(startTime%, endTime%, easeType%, startRotation#, endRotation#)
		Return New StoryboardSpriteTransform(TRANSFORM_ROTATION, startTime, endTime, easeType, startRotation, endRotation)
	End
	
	Function CreatePosition:StoryboardSpriteTransform(startTime%, endTime%, easeType%, startX#, startY#, endX#, endY#)
		Return New StoryboardSpriteTransform(TRANSFORM_POSITION, startTime, endTime, easeType, startX, endX, startY, endY)
	End
	
	Function CreateHandle:StoryboardSpriteTransform(startTime%, endTime%, easeType%, startX#, startY#, endX#, endY#)
		Return New StoryboardSpriteTransform(TRANSFORM_HANDLE, startTime, endTime, easeType, startX, endX, startY, endY)
	End
	
	Function CreateColorRGB:StoryboardSpriteTransform(startTime%, endTime%, easeType%, startRed#, startGreen#, startBlue#, endRed#, endGreen#, endBlue#)
		startRed = Max(0.0,Min(255.0,startRed))
		startGreen = Max(0.0,Min(255.0,startGreen))
		startBlue = Max(0.0,Min(255.0,startBlue))
		endRed = Max(0.0,Min(255.0,endRed))
		endGreen = Max(0.0,Min(255.0,endGreen))
		endBlue = Max(0.0,Min(255.0,endBlue))
		RGBtoHSL(startRed, startGreen, startBlue, hslArray)
		Local startHue:Float = hslArray[0], startSaturation:Float = hslArray[1], startLuminance:Float = hslArray[2]
		RGBtoHSL(endRed, endGreen, endBlue, hslArray)
		Local endHue:Float = hslArray[0], endSaturation:Float = hslArray[1], endLuminance:Float = hslArray[2]
		Return CreateColorHSL(startTime, endTime, easeType, startHue, startSaturation, startLuminance, endHue, endSaturation, endLuminance)
	End
	
	Function CreateColorHSL:StoryboardSpriteTransform(startTime%, endTime%, easeType%, startHue#, startSaturation#, startLuminance#, endHue#, endSaturation#, endLuminance#)
		startHue = Max(0.0,Min(1.0,startHue))
		startSaturation = Max(0.0,Min(1.0,startGreen))
		startLuminance = Max(0.0,Min(1.0,startBlue))
		endHue = Max(0.0,Min(1.0,endHue))
		endSaturation = Max(0.0,Min(1.0,endGreen))
		endLuminance = Max(0.0,Min(1.0,endBlue))
		Return New StoryboardSpriteTransform(TRANSFORM_COLOR, startTime, endTime, easeType, startHue, endHue, startSaturation, endSaturation, startLuminance, endLuminance)
	End
	
	Method New(transformType:Int, startTime:Int, endTime:Int, easeType:Int
							startValue1:Float=0, endValue1:Float=0,
							startValue2:Float=0, endValue2:Float=0,
							startValue3:Float=0, endValue3:Float=0,
							startValue4:Float=0, endValue4:Float=0,
							startValue5:Float=0, endValue5:Float=0)
		Self.transformType = transformType
		Self.startTime = startTime
		Self.endTime = endTime
		Self.easeType = easeType
		Select transformType
			Case TRANSFORM_ALPHA, Case TRANSFORM_SCALE, Case TRANSFORM_ROTATION
				Init(1, startValue1, endValue1)
			Case TRANSFORM_POSITION, TRANSFORM_SCALE_VECTOR, TRANSFORM_HANDLE
				Init(2, startValue1, endValue1, startValue2, endValue2)
			Case TRANSFORM_COLOR
				Init(3, startValue1, endValue1, startValue2, endValue2, startValue3, endValue3)
		End
	End
	
	Method Update:Void(currentTime:Int)
		Self.currentTime = currentTime
		For Local i:Int = 0 Until startValues.Length
			currentValues[i] = Calculate(startValues[i], endValues[i])
		Next
	End
	
	Method Apply:Void(sprite:StoryboardSprite=Null)
		Select type
			Case TRANSFORM_ALPHA
				SetAlpha(currentValues[0])
			Case TRANSFORM_SCALE
				Scale(currentValues[0], currentValues[0])
			Case TRANSFORM_ROTATION
				Rotate(currentValues[0])
			Case TRANSFORM_POSITION, TRANSFORM_HANDLE
				Translate(currentValues[0], currentValues[1])
			Case TRANSFORM_SCALE_VECTOR
				Scale(currentValues[0], currentValues[1])
			Case TRANSFORM_COLOR
				HSLtoRGB(currentValues[0], currentValues[1], currentValues[2], rgbArray)
				SetColor(rgbArray[0], rgbArray[1], rgbArray[2])
			Case TRANSFORM_HANDLE
				If sprite And sprite.image And sprite.image.image Then
					sprite.image.image.SetHandle(currentValues[0], currentValues[1])
				End
		End
	End

	Method Compare:Int(other:Object)
		Local o:StoryboardSpriteTransform = StoryboardSpriteTransform(other)
		If Not o Then Return -1
		If o = Self Then Return 0
		If startTime > o.startTime Then Return 1
		If startTime < o.startTime Then Return -1
		If endTime > o.endTime Then Return 1
		If endTime < o.endTime Then Return -1
		If transformType > o.transformType Then Return 1
		If transformType < o.transformType Then Return -1
		Return 0
	End
	
	Method Equals:Bool(other:Object)
		Return Compare(other)=0
	End
	
Private
	Method Init:Void(elementCount:Int,
							startValue1:Float=0, endValue1:Float=0,
							startValue2:Float=0, endValue2:Float=0,
							startValue3:Float=0, endValue3:Float=0,
							startValue4:Float=0, endValue4:Float=0,
							startValue5:Float=0, endValue5:Float=0)
		startValues = New Float[elementCount]
		endValues = New Float[elementCount]
		currentValues = New Float[elementCount]
		If elementCount <= 1 Then
			startValues[0] = startValue1
			endValues[0] = endValue1
		End
		If elementCount <= 2 Then
			startValues[1] = startValue2
			endValues[1] = endValue2
		End
		If elementCount <= 3 Then
			startValues[2] = startValue3
			endValues[2] = endValue3
		End
		If elementCount <= 4 Then
			startValues[3] = startValue4
			endValues[3] = endValue4
		End
		If elementCount <= 5 Then
			startValues[4] = startValue5
			endValues[4] = endValue5
		End
	End
	
	Method Calculate:Float(startValue:Float, endValue:Float)
		' shortcut for start/end (also accounts for the case when startTime==endTime)
		' we check endTime first because if startTime==endTime==currentTime, we want to use endValue
		If currentTime >= endTime Then Return endValue
		If currentTime <= startTime Then Return startValue
		
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
