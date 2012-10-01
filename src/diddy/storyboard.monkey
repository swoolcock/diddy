' summary: Diddy Storyboarding Module
' This module lets you create a storyboard consisting of sprites and sounds.  Sprites can have
' timed transformations applied to their position, scale, alpha, rotation, and colour.  These
' values can optionally be tweened with an easing function.

Strict

Private
Import mojo
Import functions
Import collections
Import xml
Import format

Public
Import exception

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
	Global mtx:Float[] = New Float[6]
	Field sprites:ArrayList<StoryboardSprite> = New ArrayList<StoryboardSprite>
	Field sounds:ArrayList<StoryboardSound> = New ArrayList<StoryboardSound>
	Field debugMode:Bool = False
	Field name:String
	Field width:Float
	Field height:Float
	Field length:Int
	Field currentTime:Int
	Field playing:Bool = False
	Field playSpeed:Int

Public
	Function LoadXML:Storyboard(filename:String)
		' open the xml file
		Local parser:XMLParser = New XMLParser
		Local doc:XMLDocument = parser.ParseFile("storyboard.xml")
		Local root:XMLElement = doc.Root
		
		' create a new storyboard
		Local sb:Storyboard = New Storyboard
		
		' read the attributes from the root node
		sb.name = root.GetAttribute("name","")
		sb.width = Float(root.GetAttribute("width","640"))
		sb.height = Float(root.GetAttribute("height","480"))
		sb.length = Int(root.GetAttribute("length","0"))
		
		' loop on each child
		For Local node:XMLElement = EachIn root.Children
			' if it's a sprite layer...
			If node.Name = "layer" Then
				' get the layer index
				Local index:Int = Int(node.GetAttribute("index","0"))
				' loop on every sprite in the layer
				For Local spriteNode:XMLElement = EachIn node.Children
					If spriteNode.Name = "sprite" Then
						' create a new sprite and add it
						Local sprite:StoryboardSprite = New StoryboardSprite(spriteNode)
						sprite.layer = index
						sb.sprites.Add(sprite)
					End
				Next
			End
			If node.Name = "sounds" Then
				' loop on children
				For Local soundNode:XMLElement = EachIn node.Children
					If soundNode.Name = "sound" Then
						' create a new sound and add it
						sb.sounds.Add(New StoryboardSound(soundNode))
					End
				Next
			End
		Next
		
		' sort the sprites by layer
		sb.sprites.Sort()
		
		' we're done!
		Return sb
	End
	
	' DebugMode enables the timeline and time counter
	Method DebugMode:Bool() Property Return debugMode End
	Method DebugMode:Void(debugMode:Bool) Property Self.debugMode = debugMode End
	
	' The storyboard's name is mostly for the developer's use
	Method Name:String() Property Return name End
	Method Name:Void(name:String) Property Self.name = name End
	
	' The native width/height of the storyboard, before scaling
	Method Width:Float() Property Return width End
	Method Height:Float() Property Return height End
	
	' The length of the storyboard in milliseconds
	Method Length:Int() Property Return length End
	
	' The current play speed (negative values play in reverse)
	Method PlaySpeed:Int() Property Return playSpeed End
	Method PlaySpeed:Void(playSpeed:Int) Property Self.playSpeed = playSpeed End
	
	' Starts or resumes playback from the current position
	Method Play:Void()
		If Not playing Then
			If playSpeed = 0 Then playSpeed = 1
			playing = True
		End
	End
	
	' Starts or pauses playback (toggle)
	Method PlayPause:Void()
		If playing Then
			Pause()
		Else
			Play()
		End
	End
	
	' Pauses playback
	Method Pause:Void()
		playing = False
	End
	
	' Stops playback, and rewinds to the start
	Method Stop:Void()
		playing = False
		playSpeed = 1
		currentTime = 0
	End

	' Jumps to the specified time	
	Method SeekTo:Void(time:Int)
		currentTime = time
	End
	
	' Adds the specified offset (negative to jump backward)
	Method SeekForward:Void(time:Int)
		currentTime += time
	End
	
	' Updates all the transformations, increasing the current play time based on dt.frametime and the play speed.
	Method Update:Void(updateTime:Bool=True)
		' update the current time based on the millis since the last frame and the play speed, if we should
		If updateTime And playing Then Self.currentTime += dt.frametime * playSpeed
		
		' update the current values for each sprite
		For Local i:Int = 0 Until sprites.Size
			Local sprite:StoryboardSprite = sprites.Get(i)
			sprite.Update(currentTime)
		Next
		
		' update sounds
		For Local i:Int = 0 Until sounds.Size
			Local sound:StoryboardSound = sounds.Get(i)
			sound.Update(currentTime)
		Next
	End
	
	' Renders all the sprites within the specified area, scaling for aspect ratio and setting a scissor.
	Method Render:Void(x:Float=0, y:Float=0, width:Float=-1, height:Float=-1)
		' if width/height not supplied, assume native storyboard width
		If width <= 0 Then width = Self.width
		If height <= 0 Then height = Self.height
		
		' get the aspect ratios
		Local targetAR:Float = width/height
		Local sourceAR:Float = Self.width/Self.height
		
		' fix target width/height based on aspect ratio (letterboxed)
		If targetAR > sourceAR Then
			' bars on left/right
			x += (width-(height*sourceAR))/2
			width = height*sourceAR
		ElseIf targetAR < sourceAR Then
			y += (height-(width/sourceAR))/2
			height = width/sourceAR
		End
		
		' push the old matrix and apply correct translation and scales
		PushMatrix
		Translate x, y
		Scale width/Self.width, height/Self.height
		
		' get the current matrix so we can work out the correct scissor
		GetMatrix(mtx)
		Local sx:Float = mtx[4]
		Local sy:Float = mtx[5]
		Local sw:Float = Self.width*mtx[0]+Self.height*mtx[2]
		Local sh:Float = Self.width*mtx[1]+Self.height*mtx[3]
		
		' set the scissor
		SetScissor(sx, sy, sw, sh)
		
		' render all the sprites
		For Local i:Int = 0 Until sprites.Size
			Local sprite:StoryboardSprite = sprites.Get(i)
			sprite.Render()
		Next
		
		' reset scissor
		SetScissor(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT)
		
		' draw lines if in debug
		If DebugMode Then
			SetAlpha(1)
			SetColor(255,255,255)
			DrawLine(0,0,Self.width,0)
			DrawLine(Self.width,0,Self.width,Self.height)
			DrawLine(0,0,0,Self.height)
			DrawLine(0,Self.height,Self.width,Self.height)
		End
		
		' pop the matrix
		PopMatrix
		
		' draw time and timeline if debug
		If DebugMode Then
			' draw time
			Local millis:Int = currentTime Mod 1000
			Local secs:Int = (currentTime / 1000) Mod 60
			Local mins:Int = (currentTime / 60000)
			SetAlpha(1)
			SetColor(255,255,255)
			DrawText(Format("%02d:%02d:%03d", mins, secs, millis), 0, 0)
			
			' draw timeline bar
			DrawLine 10,SCREEN_HEIGHT-10,10,SCREEN_HEIGHT-30
			DrawLine SCREEN_WIDTH-10,SCREEN_HEIGHT-10,SCREEN_WIDTH-10,SCREEN_HEIGHT-30
			DrawLine 10,SCREEN_HEIGHT-20,SCREEN_WIDTH-10,SCREEN_HEIGHT-20
			
			' draw timeline ticks
			For Local i:Int = 0 Until length Step 5000
				Local x:Int = 10+Int((SCREEN_WIDTH-20)*Float(i)/length)
				Local y:Int = SCREEN_HEIGHT-22
				If i Mod 30000 = 0 Then y -= 2
				If i Mod 60000 = 0 Then y -= 2
				DrawLine(x, y, x, SCREEN_HEIGHT-20)
			Next
			
			' draw current time bar
			Local x:Int = 10+Int((SCREEN_WIDTH-20)*Float(currentTime)/length)
			SetColor 255,0,0
			DrawLine x,SCREEN_HEIGHT-28,x,SCREEN_HEIGHT-12
			SetColor 255,255,255
		End
	End
End

Class StoryboardElement Implements IComparable Abstract
Private
	Global nextId:Int = 0
	Field id:Int
	Field currentTime:Int
	Field name:String
	
Public
	Method Name:String() Property Return name End
	Method Name:Void(name:String) Property Self.name = name End

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
	
	Method Update:Void(currentTime:Int) Abstract
End

Class StoryboardSound Extends StoryboardElement
Private
	Const SOUND_THRESHOLD:Int = 100
	Field soundName:String
	Field sound:GameSound
	Field time:Int
	
Public
	Method New(node:XMLElement)
		soundName = node.GetAttribute("soundName","")
		time = Int(node.GetAttribute("time","0"))
		name = node.GetAttribute("name","")
	End
	
	Method Update:Void(currentTime:Int)
		' if we've gone past this sound, check the delta to make sure it's not huge (to stop spam)
		Local shouldPlay:Bool = currentTime >= time And Self.currentTime < time And currentTime - time < SOUND_THRESHOLD
		Self.currentTime = currentTime
		If shouldPlay Then
			If Not sound Then sound = game.sounds.Find(soundName)
			If Not sound Then Return
			sound.Play()
		End
	End
End

Class StoryboardSprite Extends StoryboardElement
Private
	Field layer:Int
	Field imageName:String
	Field image:GameImage
	
	Field firstX:Float=0, firstY:Float=0
	field firstScaleX:Float=1, firstScaleY:Float=1
	Field firstScale:Float=1, firstRotation:Float=0
	Field firstRed:Float=255, firstGreen:Float=255, firstBlue:Float=255, firstAlpha:Float=1
	
	Field x:Float=0, y:Float=0
	field scaleX:Float=1, scaleY:Float=1
	Field scale:Float=1, rotation:Float=0
	Field red:Float=255, green:Float=255, blue:Float=255, alpha:Float=1
	
	Field transforms:ArrayList<StoryboardSpriteTransform> = New ArrayList<StoryboardSpriteTransform>
	Field currentTransforms:StoryboardSpriteTransform[] = New StoryboardSpriteTransform[TRANSFORM_COUNT]
	Field earliestStart:Int, latestEnd:Int
	Field hasTransform:Bool = False
	
Public
	Method New(node:XMLElement)
		imageName = node.GetAttribute("imageName","")
		name = node.GetAttribute("name","")
		firstX = Float(node.GetAttribute("x","0"))
		firstY = Float(node.GetAttribute("y","0"))
		firstScaleX = Float(node.GetAttribute("scaleX","1"))
		firstScaleY = Float(node.GetAttribute("scaleY","1"))
		firstScale = Float(node.GetAttribute("scale","1"))
		firstRotation = Float(node.GetAttribute("rotation","0"))
		firstRed = Float(node.GetAttribute("red","255"))
		firstGreen = Float(node.GetAttribute("green","255"))
		firstBlue = Float(node.GetAttribute("blue","255"))
		firstAlpha = Float(node.GetAttribute("alpha","1"))
		CreateTransformsFromXML(node)
		transforms.Sort()
		For Local i:Int = 0 Until transforms.Size
			Local tr:StoryboardSpriteTransform = transforms.Get(i)
			If i=0 Or earliestStart > tr.startTime Then earliestStart = tr.startTime
			If i=0 Or latestEnd < tr.endTime Then latestEnd = tr.endTime
		Next
	End
	
	Method CreateTransformsFromXML:Void(node:XMLElement, timeOffset:Int=0)
		For Local childNode:XMLElement = EachIn node.Children
			Local name:String = childNode.Name
			If name = "group" Then
				Local loopCount:Int = Int(childNode.GetAttribute("loopCount","1"))
				Local startTime:Int = Int(childNode.GetAttribute("startTime","0"))
				Local endTime:Int = Int(childNode.GetAttribute("endTime","0"))
				Local myOffset:Int = timeOffset + startTime
				For Local i:Int = 0 Until loopCount
					CreateTransformsFromXML(childNode, myOffset)
					myOffset += endTime - startTime
				Next
			Else
				transforms.Add(StoryboardSpriteTransform.CreateFromXML(childNode, timeOffset))
			End
		Next
	End
	
	Method Layer:Int() Property Return layer End
	
	Method Compare:Int(other:Object)
		Local o:StoryboardSprite = StoryboardSprite(other)
		If Not o Then Return -1
		If o = Self Then Return 0
		If layer < o.layer Then Return -1
		If layer > o.layer Then Return 1
		Return Super.Compare(other)
	End
	
	Method Update:Void(currentTime:Int)
		Self.currentTime = currentTime
		x = firstX; y = firstY
		scaleX = firstScaleX; scaleY = firstScaleY
		scale = firstScale; rotation = firstRotation
		red = firstRed; green = firstGreen; blue = firstBlue; alpha = firstAlpha
		hasTransform = False
		
		If currentTime >= earliestStart And currentTime <= latestEnd Then
			For Local i:Int = 0 Until transforms.Size
				Local tr:StoryboardSpriteTransform = transforms.Get(i)
				If tr.startTime <= currentTime Then
					transforms.Get(i).Update(currentTime)
					transforms.Get(i).Apply(Self)
				End
				If Not hasTransform And currentTime >= tr.startTime And currentTime <= tr.endTime Then hasTransform = True
			Next
		End
	End
	
	Method Render:Void()
		If Not hasTransform Or alpha = 0 Then Return
		If Not image Then image = game.images.Find(imageName)
		If Not image Then
			Print "Couldn't load "+imageName+" for sprite."
			Return
		End
		
		' translation, scale, rotation, handle, other effects
		PushMatrix
		Translate x, y
		Scale scaleX, scaleY
		Scale scale, scale
		Rotate rotation
		SetColor red, green, blue
		SetAlpha alpha
		
		image.Draw(0, 0)
		PopMatrix
	End
End

Class StoryboardSpriteTransform Implements IComparable
Private
	Global hslArray:Float[] = New Float[3]
	Global rgbArray:Int[] = New Int[3]
	
	Field transformType:Int = 0
	
	Field currentTime:Int
	Field startTime:Int
	Field endTime:Int
	Field easeType:Int
	
	Field hasValues:Bool = True
	
	Field startValues:Float[]
	Field endValues:Float[]
	Field currentValues:Float[]
	
Public
	Function CreateFromXML:StoryboardSpriteTransform(node:XMLElement, timeOffset:Int=0)
		Local name:String = node.Name
		Local startTime:Int = Int(node.GetAttribute("startTime","0"))
		Local endTime:Int = Int(node.GetAttribute("endTime",""+startTime))
		startTime += timeOffset
		endTime += timeOffset
		
		Local easeStr:String = node.GetAttribute("ease","")
		Local easeType:Int = EASE_NONE
		Select easeStr.ToLower()
			Case "in", ""+EASE_IN
				easeType = EASE_IN
			Case "inhalf", ""+EASE_IN_HALF
				easeType = EASE_IN_HALF
			Case "indouble", ""+EASE_IN_DOUBLE
				easeType = EASE_IN_DOUBLE
			Case "out", ""+EASE_OUT
				easeType = EASE_OUT
			Case "outhalf", ""+EASE_OUT_HALF
				easeType = EASE_OUT_HALF
			Case "outdouble", ""+EASE_OUT_DOUBLE
				easeType = EASE_OUT_DOUBLE
			Case "inout", ""+EASE_IN_OUT
				easeType = EASE_IN_OUT
			Default
				easeType = EASE_NONE
		End
		
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
			Local rv:StoryboardSpriteTransform = CreatePosition(startTime, endTime, easeType, startX, startY, endX, endY)
			rv.hasValues = node.HasAttribute("startX") And node.HasAttribute("endX") And node.HasAttribute("startY") And node.HasAttribute("endY")
			Return rv
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
		Return Null
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
		startHue = Max(0.0, Min(1.0, startHue))
		startSaturation = Max(0.0, Min(1.0, startSaturation))
		startLuminance = Max(0.0, Min(1.0, startLuminance))
		endHue = Max(0.0, Min(1.0, endHue))
		endSaturation = Max(0.0, Min(1.0, endSaturation))
		endLuminance = Max(0.0, Min(1.0, endLuminance))
		Return New StoryboardSpriteTransform(TRANSFORM_COLOR, startTime, endTime, easeType, startHue, endHue, startSaturation, endSaturation, startLuminance, endLuminance)
	End
	
	Method New(transformType:Int, startTime:Int, endTime:Int, easeType:Int,
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
			Case TRANSFORM_ALPHA, TRANSFORM_SCALE, TRANSFORM_ROTATION
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
	
	Method Apply:Void(sprite:StoryboardSprite)
		If Not hasValues Then Return
		Select transformType
			Case TRANSFORM_ALPHA
				sprite.alpha = currentValues[0]
			Case TRANSFORM_SCALE
				sprite.scale = currentValues[0]
			Case TRANSFORM_ROTATION
				sprite.rotation = currentValues[0]
			Case TRANSFORM_POSITION
				sprite.x = currentValues[0]
				sprite.y = currentValues[1]
			Case TRANSFORM_SCALE_VECTOR
				sprite.scaleX = currentValues[0]
				sprite.scaleY = currentValues[1]
			Case TRANSFORM_COLOR
				HSLtoRGB(currentValues[0], currentValues[1], currentValues[2], rgbArray)
				sprite.red = rgbArray[0]
				sprite.green = rgbArray[1]
				sprite.blue = rgbArray[2]
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
		If elementCount >= 1 Then
			startValues[0] = startValue1
			endValues[0] = endValue1
		End
		If elementCount >= 2 Then
			startValues[1] = startValue2
			endValues[1] = endValue2
		End
		If elementCount >= 3 Then
			startValues[2] = startValue3
			endValues[2] = endValue3
		End
		If elementCount >= 4 Then
			startValues[3] = startValue4
			endValues[3] = endValue4
		End
		If elementCount >= 5 Then
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
	
	Function Lerp:Float(startValue:Float, endValue:Float, progress:Float)
		Return startValue + (endValue-startValue) * progress
	End
End
