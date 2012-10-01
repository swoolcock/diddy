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
	Field effects:ArrayList<StoryboardEffect> = New ArrayList<StoryboardEffect>
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
			' sprites node
			If node.Name = "sprites" Then
				' layers
				For Local layerNode:XMLElement = EachIn node.Children
					' if it's not layer, there's something wrong!
					If layerNode.Name = "layer" Then
						' get the layer index
						Local index:Int = Int(node.GetAttribute("index","0"))
						' loop on every sprite in the layer
						For Local spriteNode:XMLElement = EachIn layerNode.Children
							If spriteNode.Name = "sprite" Then
								' create a new sprite and add it
								Local sprite:StoryboardSprite = New StoryboardSprite(spriteNode)
								sprite.layer = index
								sb.sprites.Add(sprite)
							End
						Next
					End
				Next
			' sounds node
			ElseIf node.Name = "sounds" Then
				' loop on children
				For Local soundNode:XMLElement = EachIn node.Children
					If soundNode.Name = "sound" Then
						' create a new sound and add it
						sb.sounds.Add(New StoryboardSound(soundNode))
					End
				Next
			' effects node
			ElseIf node.Name = "effects" Then
				' loop on children
				For Local effectNode:XMLElement = EachIn node.Children
					If effectNode.Name = "flash" Then
						sb.effects.Add(New StoryboardFlash(effectNode))
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
		
		' update effects
		For Local i:Int = 0 Until effects.Size
			Local effect:StoryboardEffect = effects.Get(i)
			effect.Update(currentTime)
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
			sprite.Render(0, 0, width, height)
		Next
		
		' render effects
		For Local i:Int = 0 Until effects.Size
			Local effect:StoryboardEffect = effects.Get(i)
			effect.Render(0, 0, width, height)
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
	Method Render:Void(x:Float=0, y:Float=0, width:Float=-1, height:Float=-1) Abstract
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
	
	Method Render:Void(x:Float=0, y:Float=0, width:Float=-1, height:Float=-1)
		' can't render a sound.... yet ;)
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
				transforms.Add(New StoryboardSpriteTransform(childNode, timeOffset))
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
	
	Method Render:Void(x:Float=0, y:Float=0, width:Float=-1, height:Float=-1)
		If Not hasTransform Or alpha = 0 Then Return
		If Not image Then image = game.images.Find(imageName)
		If Not image Then
			Print "Couldn't load "+imageName+" for sprite."
			Return
		End
		
		' translation, scale, rotation, handle, other effects
		PushMatrix
		Translate Self.x, Self.y
		Scale scaleX, scaleY
		Scale scale, scale
		Rotate rotation
		SetColor red, green, blue
		SetAlpha alpha
		
		image.Draw(0, 0)
		PopMatrix
	End
End

Class StoryboardCalculation Implements IComparable Abstract
Private
	Field currentTime:Int
	Field startTime:Int
	Field endTime:Int
	Field easeType:Int
	
	Field startValues:Float[]
	Field endValues:Float[]
	Field currentValues:Float[]

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
	
Public
	Method New(node:XMLElement, timeOffset:Int=0)
		startTime = Int(node.GetAttribute("startTime","0"))
		endTime = Int(node.GetAttribute("endTime",""+startTime))
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
	End
	
	Method Compare:Int(other:Object)
		Local o:StoryboardSpriteTransform = StoryboardSpriteTransform(other)
		If Not o Then Return -1
		If o = Self Then Return 0
		If startTime > o.startTime Then Return 1
		If startTime < o.startTime Then Return -1
		If endTime > o.endTime Then Return 1
		If endTime < o.endTime Then Return -1
		Return 0
	End
	
	Method Equals:Bool(other:Object)
		Return Compare(other)=0
	End
	
	Method Update:Void(currentTime:Int)
		Self.currentTime = currentTime
		For Local i:Int = 0 Until startValues.Length
			currentValues[i] = Calculate(startValues[i], endValues[i])
		Next
	End
	
	Method Apply:Void(obj:Object) Abstract
End

Class StoryboardSpriteTransform Extends StoryboardCalculation
Private
	Field transformType:Int = 0
	Field hasValues:Bool = True
	
Public
	Method New(node:XMLElement, timeOffset:Int=0)
		Super.New(node, timeOffset)
		Local name:String = node.Name
		
		If name = "scale" Then
			Self.transformType = TRANSFORM_SCALE
			Local startScale:Float = Float(node.GetAttribute("startScale","1"))
			Local endScale:Float = Float(node.GetAttribute("endScale","1"))
			Init(1, startScale, endScale)
		ElseIf name = "scaleVector" Then
			Self.transformType = TRANSFORM_SCALE_VECTOR
			Local startScaleX:Float = Float(node.GetAttribute("startScaleX","1"))
			Local endScaleX:Float = Float(node.GetAttribute("endScaleX","1"))
			Local startScaleY:Float = Float(node.GetAttribute("startScaleY","1"))
			Local endScaleY:Float = Float(node.GetAttribute("endScaleY","1"))
			Init(2, startScaleX, endScaleX, startScaleY, endScaleY)
		ElseIf name = "alpha" Then
			Self.transformType = TRANSFORM_ALPHA
			Local startAlpha:Float = Clamp(Float(node.GetAttribute("startAlpha","1")))
			Local endAlpha:Float = Clamp(Float(node.GetAttribute("endAlpha","1")))
			Init(1, startAlpha, endAlpha)
		ElseIf name = "rotation" Then
			Self.transformType = TRANSFORM_ROTATION
			Local startRotation:Float = Float(node.GetAttribute("startRotation","0"))
			Local endRotation:Float = Float(node.GetAttribute("endRotation","0"))
			Init(1, startRotation, endRotation)
		ElseIf name = "position" Then
			Self.transformType = TRANSFORM_POSITION
			Local startX:Float = Float(node.GetAttribute("startX","0"))
			Local endX:Float = Float(node.GetAttribute("endX","0"))
			Local startY:Float = Float(node.GetAttribute("startY","0"))
			Local endY:Float = Float(node.GetAttribute("endY","0"))
			Init(2, startX, endX, startY, endY)
			hasValues = node.HasAttribute("startX") And node.HasAttribute("endX") And node.HasAttribute("startY") And node.HasAttribute("endY")
		ElseIf name = "handle" Then
			Self.transformType = TRANSFORM_HANDLE
			Local startX:Float = Float(node.GetAttribute("startX","0"))
			Local endX:Float = Float(node.GetAttribute("endX","0"))
			Local startY:Float = Float(node.GetAttribute("startY","0"))
			Local endY:Float = Float(node.GetAttribute("endY","0"))
			Init(2, startX, endX, startY, endY)
		ElseIf name = "color" Then
			Local startHue:Float, startSaturation:Float, startLuminance:Float
			Local endHue:Float, endSaturation:Float, endLuminance:Float
			If node.HasAttribute("startRed") Or node.HasAttribute("startGreen") Or node.HasAttribute("startBlue") Then
				Self.transformType = TRANSFORM_COLOR
				Local startRed:Float = Clamp(Float(node.GetAttribute("startRed","255")),0,255)
				Local endRed:Float = Clamp(Float(node.GetAttribute("endRed","255")),0,255)
				Local startGreen:Float = Clamp(Float(node.GetAttribute("startGreen","255")),0,255)
				Local endGreen:Float = Clamp(Float(node.GetAttribute("endGreen","255")),0,255)
				Local startBlue:Float = Clamp(Float(node.GetAttribute("startBlue","255")),0,255)
				Local endBlue:Float = Clamp(Float(node.GetAttribute("endBlue","255")),0,255)
				RGBtoHSL(startRed, startGreen, startBlue, hslArray)
				startHue = hslArray[0]; startSaturation = hslArray[1]; startLuminance = hslArray[2]
				RGBtoHSL(endRed, endGreen, endBlue, hslArray)
				endHue = hslArray[0]; endSaturation = hslArray[1]; endLuminance = hslArray[2]
			Else
				Self.transformType = TRANSFORM_COLOR
				Local startHue:Float = Clamp(Float(node.GetAttribute("startHue","0")))
				Local endHue:Float = Clamp(Float(node.GetAttribute("endHue","0")))
				Local startSaturation:Float = Clamp(Float(node.GetAttribute("startSaturation","1")))
				Local endSaturation:Float = Clamp(Float(node.GetAttribute("endSaturation","1")))
				Local startLuminance:Float = Clamp(Float(node.GetAttribute("startLuminance","1")))
				Local endLuminance:Float = Clamp(Float(node.GetAttribute("endLuminance","1")))
			End
			Init(3, startHue, endHue, startSaturation, endSaturation, startLuminance, endLuminance)
		End
	End
	
	Method Apply:Void(obj:Object)
		Local sprite:StoryboardSprite = StoryboardSprite(obj)
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
		Local rv:Int = Super.Compare(other)
		If rv <> 0 Then Return rv
		If transformType > o.transformType Then Return 1
		If transformType < o.transformType Then Return -1
		Return 0
	End
End

Class StoryboardEffect Abstract
Public
	Method Update:Void(currentTime:Int) Abstract
	Method Render:Void(x:Float, y:Float, width:Float, height:Float) Abstract
End

Class StoryboardFlash Extends StoryboardEffect
Private
	Field leadIn:Int ' typically short, ~50ms
	Field leadOut:Int ' typically long, ~300ms
	Field time:Int ' the time of peak alpha
	Field alpha:Float ' the peak alpha
	Field red:Int
	Field green:Int
	Field blue:Int
	
	Field currentAlpha:Float

Public
	Method New(node:XMLElement, timeOffset:Int=0)
		time = Int(node.GetAttribute("time","0"))
		leadIn = Int(node.GetAttribute("leadIn","0"))
		leadOut = Int(node.GetAttribute("leadOut","0"))
		alpha = Clamp(Float(node.GetAttribute("alpha","1")))
		If node.HasAttribute("hue") Or node.HasAttribute("saturation") Or node.HasAttribute("luminance") Then
			Local hue:Float = Clamp(Float(node.GetAttribute("hue","0")))
			Local saturation:Float = Clamp(Float(node.GetAttribute("saturation","0")))
			Local luminance:Float = Clamp(Float(node.GetAttribute("luminance","0")))
			HSLtoRGB(hue, saturation, luminance, rgbArray)
			red = rgbArray[0]; green = rgbArray[1]; blue = rgbArray[2]
		Else
			red = Clamp(Float(node.GetAttribute("red","255")),0,255)
			green = Clamp(Float(node.GetAttribute("green","255")),0,255)
			blue = Clamp(Float(node.GetAttribute("blue","255")),0,255)
		End
	End
	
	Method Update:Void(currentTime:Int)
		Local leadInTime:Int = time - leadIn, leadOutTime:Int = time + leadOut
		If currentTime < leadInTime Or currentTime > leadOutTime Then
			currentAlpha = 0
		ElseIf currentTime < time Then
			currentAlpha = Lerp(0, alpha, Float(currentTime-leadInTime)/leadIn)
		ElseIf currentTime > time Then
			currentAlpha = Lerp(alpha, 0, Float(currentTime-time)/leadOut)
		Else
			currentAlpha = alpha
		End
	End
	
	Method Render:Void(x:Float=0, y:Float=0, width:Float=-1, height:Float=-1)
		If currentAlpha <> 0 Then
			SetAlpha(currentAlpha)
			SetColor(red, green, blue)
			DrawRect(x, y, width, height)
		End
	End
End

Private
Global hslArray:Float[] = New Float[3]
Global rgbArray:Int[] = New Int[3]

Function Lerp:Float(startValue:Float, endValue:Float, progress:Float)
	Return startValue + (endValue-startValue) * progress
End

Function Clamp:Float(value:Float, minval:Float=0, maxval:Float=1)
	Return Max(minval,Min(maxval,value))
End
