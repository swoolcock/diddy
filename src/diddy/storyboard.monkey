#Rem
Copyright (c) 2011 Steve Revill and Shane Woolcock
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#End

' summary: Diddy Storyboarding Module
' This module lets you create a storyboard consisting of sprites and sounds.  Sprites can have
' timed transformations applied to their position, scale, alpha, rotation, and colour.  These
' values can optionally be tweened with an easing function.

Strict

Private
Import mojo
Import diddy.functions
Import diddy.containers
Import diddy.xml
Import diddy.format

Public
Import diddy.exception

Const KEYFRAME_POSITION:Int = 0
Const KEYFRAME_ALPHA:Int = 1
Const KEYFRAME_SCALE:Int = 2
Const KEYFRAME_SCALE_VECTOR:Int = 3
Const KEYFRAME_ROTATION:Int = 4
Const KEYFRAME_COLOR:Int = 5
Const KEYFRAME_HANDLE:Int = 6
Const KEYFRAME_COUNT:Int = 7

Class Storyboard
Private
	Field sprites:DiddyStack<StoryboardSprite> = New DiddyStack<StoryboardSprite>
	Field sounds:DiddyStack<StoryboardSound> = New DiddyStack<StoryboardSound>
	Field musics:DiddyStack<StoryboardMusic> = New DiddyStack<StoryboardMusic>
	Field effects:DiddyStack<StoryboardEffect> = New DiddyStack<StoryboardEffect>
	Field debugMode:Bool = False
	Field name:String
	Field width:Float
	Field height:Float
	Field length:Int
	Field currentTime:Int
	Field playing:Bool = False
	Field playSpeed:Int
	Field renderer:StoryboardRenderer

Public
	Function LoadXML:Storyboard(filename:String="storyboard.xml")
		' open the xml file
		Local parser:XMLParser = New XMLParser
		Local doc:XMLDocument = parser.ParseFile(filename)
		Local root:XMLElement = doc.Root
		
		' create a new storyboard
		Local sb:Storyboard = New Storyboard
		
		' read the attributes from the root node
		sb.name = root.GetAttribute("name","")
		sb.width = Float(root.GetAttribute("width","640"))
		sb.height = Float(root.GetAttribute("height","480"))
		sb.length = Int(root.GetAttribute("length","0"))
		
		' loop on each child
		For Local node:XMLElement = Eachin root.Children
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
								sb.sprites.Push(sprite)
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
						sb.sounds.Push(New StoryboardSound(soundNode))
					ElseIf soundNode.Name = "music" Then
						' create a new music and add it
						sb.musics.Push(New StoryboardMusic(soundNode))
					End
				Next
			' effects node
			ElseIf node.Name = "effects" Then
				' loop on children
				For Local effectNode:XMLElement = EachIn node.Children
					If effectNode.Name = "flash" Then
						sb.effects.Push(New StoryboardFlash(effectNode))
					End
				Next
			End
		Next
		
		' sort the sprites by layer
		sb.sprites.Sort()
		
		' we're done!
		Return sb
	End
	
	' Allows the developer to use a custom renderer without extending Storyboard
	Method Renderer:StoryboardRenderer() Property
		If Not renderer Then renderer = New StoryboardRenderer
		Return renderer
	End
	
	Method Renderer:Void(renderer:StoryboardRenderer) Property Self.renderer = renderer End
	
	' The sprite list (read only)
	Method Sprites:DiddyStack<StoryboardSprite>() Property Return sprites End
	
	' The effect list (read only)
	Method Effects:DiddyStack<StoryboardEffect>() Property Return effects End
	
	' The sound list (read only)
	Method Sounds:DiddyStack<StoryboardSound>() Property Return sounds End
	
	' The music list (read only)
	Method Musics:DiddyStack<StoryboardMusic>() Property Return musics End
	
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
	
	' The current time in millis
	Method CurrentTime:Int() Property Return currentTime End
	
	' The current play speed (negative values play in reverse)
	Method PlaySpeed:Int() Property Return playSpeed End
	Method PlaySpeed:Void(playSpeed:Int) Property Self.playSpeed = playSpeed End
	
	' Starts or resumes playback from the current position
	Method Play:Void()
		If Not playing Then
			If playSpeed = 0 Then playSpeed = 1
			playing = True
			StoryboardMusic.musicPlaying = False
			StopMusic()
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
		StoryboardMusic.musicPlaying = False
		StopMusic()
	End
	
	' Stops playback, and rewinds to the start
	Method Stop:Void()
		playing = False
		playSpeed = 1
		currentTime = 0
		StoryboardMusic.musicPlaying = False
		StopMusic()
	End

	' Jumps to the specified time	
	Method SeekTo:Void(time:Int)
		currentTime = time
		StoryboardMusic.musicPlaying = False
		StopMusic()
	End
	
	' Adds the specified offset (negative to jump backward)
	Method SeekForward:Void(time:Int)
		currentTime += time
		StoryboardMusic.musicPlaying = False
		StopMusic()
	End
	
	' Updates all the transformations, increasing the current play time based on dt.frametime and the play speed.
	Method Update:Void(updateTime:Bool=True)
		' update the current time based on the millis since the last frame and the play speed, if we should
		If updateTime And playing Then Self.currentTime += dt.frametime * playSpeed
		
		' update the current values for each sprite
		For Local i:Int = 0 Until sprites.Count()
			Local sprite:StoryboardSprite = sprites.Get(i)
			sprite.Update(Self, currentTime)
		Next
		
		' only do sounds etc. if playing
		If playing And updateTime Then
			' update sounds
			For Local i:Int = 0 Until sounds.Count()
				Local sound:StoryboardSound = sounds.Get(i)
				sound.Update(Self, currentTime)
			Next
			
			' update music
			For Local i:Int = 0 Until musics.Count()
				Local music:StoryboardMusic = musics.Get(i)
				music.Update(Self, currentTime)
			Next
			
			' need to seek music here
			If StoryboardMusic.musicPlaying And StoryboardMusic.performSeek Then
#If TARGET<>"bmax" Then
				StoryboardMusic.performSeek = Not SeekMusic(StoryboardMusic.performSeekTime)
#End
			End
		End
		
		' update effects
		For Local i:Int = 0 Until effects.Count()
			Local effect:StoryboardEffect = effects.Get(i)
			effect.Update(Self, currentTime)
		Next
	End
	
	Method Render:Void(x:Float=0, y:Float=0, width:Float=-1, height:Float=-1)
		Renderer.Render(Self, x, y, width, height)
	End
End

Class StoryboardRenderer
	Field mtx:Float[] = New Float[6]
	' Renders all the sprites within the specified area, scaling for aspect ratio and setting a scissor.
	Method Render:Void(sb:Storyboard, x:Float=0, y:Float=0, width:Float=-1, height:Float=-1)
		' if width/height not supplied, assume native storyboard width
		If width <= 0 Then width = sb.Width
		If height <= 0 Then height = sb.Height
		
		' get the aspect ratios
		Local targetAR:Float = width/height
		Local sourceAR:Float = sb.Width/sb.Height
		
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
		Scale width/sb.Width, height/sb.Height
		
		' get the current matrix so we can work out the correct scissor
		GetMatrix(mtx)
		Local sx:Float = mtx[4]
		Local sy:Float = mtx[5]
		Local sw:Float = sb.Width*mtx[0]+sb.Height*mtx[2]
		Local sh:Float = sb.Width*mtx[1]+sb.Height*mtx[3]
		
		' set the scissor
		SetScissor(sx, sy, sw, sh)
		
		' render all the sprites
		For Local i:Int = 0 Until sb.Sprites.Count()
			Local sprite:StoryboardSprite = sb.Sprites.Get(i)
			sprite.Render(sb, Self, 0, 0, width, height)
		Next
		
		' render effects
		For Local i:Int = 0 Until sb.Effects.Count()
			Local effect:StoryboardEffect = sb.Effects.Get(i)
			effect.Render(sb, Self, 0, 0, width, height)
		Next
		
		' reset scissor
		SetScissor(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT)
		
		' draw lines if in debug
		If sb.DebugMode Then
			SetAlpha(1)
			SetColor(255,255,255)
			DrawLine(0,0,sb.Width,0)
			DrawLine(sb.Width,0,sb.Width,sb.Height)
			DrawLine(0,0,0,sb.Height)
			DrawLine(0,sb.Height,sb.Width,sb.Height)
		End
		
		' pop the matrix
		PopMatrix
		
		' draw time and timeline if debug
		If sb.DebugMode Then
			' draw time
			Local millis:Int = sb.CurrentTime Mod 1000
			Local secs:Int = (sb.CurrentTime / 1000) Mod 60
			Local mins:Int = (sb.CurrentTime / 60000)
			SetAlpha(1)
			SetColor(255,255,255)
			DrawText(Format("%02d:%02d:%03d", mins, secs, millis), 0, 0)
			
			' draw timeline bar
			DrawLine 10,SCREEN_HEIGHT-10,10,SCREEN_HEIGHT-30
			DrawLine SCREEN_WIDTH-10,SCREEN_HEIGHT-10,SCREEN_WIDTH-10,SCREEN_HEIGHT-30
			DrawLine 10,SCREEN_HEIGHT-20,SCREEN_WIDTH-10,SCREEN_HEIGHT-20
			
			' draw timeline ticks
			For Local i:Int = 0 Until sb.Length Step 5000
				Local x:Int = 10+Int((SCREEN_WIDTH-20)*Float(i)/sb.Length)
				Local y:Int = SCREEN_HEIGHT-22
				If i Mod 30000 = 0 Then y -= 2
				If i Mod 60000 = 0 Then y -= 2
				DrawLine(x, y, x, SCREEN_HEIGHT-20)
			Next
			
			' draw current time bar
			Local x:Int = 10+Int((SCREEN_WIDTH-20)*Float(sb.CurrentTime)/sb.Length)
			SetColor 255,0,0
			DrawLine x,SCREEN_HEIGHT-28,x,SCREEN_HEIGHT-12
			SetColor 255,255,255
		End
	End
	
	Method PreRenderSprite:Bool(sb:Storyboard, sprite:StoryboardSprite, x:Int, y:Int, width:Int, height:Int)
		Return True
	End
	
	Method PostRenderSprite:Void(sb:Storyboard, sprite:StoryboardSprite, x:Int, y:Int, width:Int, height:Int)
	End
	
	Method PreRenderEffect:Bool(sb:Storyboard, effect:StoryboardEffect, x:Int, y:Int, width:Int, height:Int)
		Return True
	End
	
	Method PostRenderEffect:Void(sb:Storyboard, effect:StoryboardEffect, x:Int, y:Int, width:Int, height:Int)
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
	
	Method CompareTo:Int(other:Object)
		Local o:StoryboardElement = StoryboardElement(other)
		If Not o Then Return -1
		If o = Self Then Return 0
		If id < o.id Then Return -1
		If id > o.id Then Return 1
		Return 0
	End
	
	Method Update:Void(sb:Storyboard, currentTime:Int) Abstract
	Method Render:Void(sb:Storyboard, renderer:StoryboardRenderer=Null, x:Float=0, y:Float=0, width:Float=-1, height:Float=-1) Abstract
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
	
	Method Update:Void(sb:Storyboard, currentTime:Int)
		' if we've gone past this sound, check the delta to make sure it's not huge (to stop spam)
		Local shouldPlay:Bool = currentTime >= time And Self.currentTime < time And currentTime - time < SOUND_THRESHOLD
		Self.currentTime = currentTime
		If shouldPlay Then
			If Not sound Then sound = diddyGame.sounds.Find(soundName)
			If Not sound Then Return
			sound.Play()
		End
	End
	
	Method Render:Void(sb:Storyboard, renderer:StoryboardRenderer=Null, x:Float=0, y:Float=0, width:Float=-1, height:Float=-1)
		' can't render a sound.... yet ;)
	End
End

Class StoryboardMusic Extends StoryboardElement
Private
	Global musicPlaying:Bool = False
	Global performSeek:Bool = False
	Global performSeekTime:Int = 0
	Const MUSIC_THRESHOLD:Int = 50
	Field musicName:String
	Field time:Int
	Field length:Int
	Field channel:Int
	Field loop:Bool = False
	
Public
	Method New(node:XMLElement)
		musicName = node.GetAttribute("musicName","")
		time = Int(node.GetAttribute("time","0"))
		length = Int(node.GetAttribute("length","0"))
		name = node.GetAttribute("name","")
		loop = node.GetAttribute("loop","true").ToLower() = "true"
	End
	
	Method Update:Void(sb:Storyboard, currentTime:Int)
		' find out if we're inside the music
		If currentTime >= Self.time And (currentTime < Self.time+Self.length Or Self.loop) Then
			' if we're not playing, need to start playing
			If Not musicPlaying Then
				musicPlaying = True
				StopMusic()
				performSeekTime = currentTime-Self.time
				If loop Then
					diddyGame.MusicPlay(musicName, 1)
					performSeekTime = performSeekTime Mod Self.length
				Else
					diddyGame.MusicPlay(musicName, 0)
				End
				performSeek = performSeekTime >= MUSIC_THRESHOLD
			End
		End
	End
	
	Method Render:Void(sb:Storyboard, renderer:StoryboardRenderer=Null, x:Float=0, y:Float=0, width:Float=-1, height:Float=-1)
		' can't render music.... yet ;)
	End
End

Class StoryboardSprite Extends StoryboardElement
Private
	Field layer:Int
	Field imageName:String
	Field image:GameImage
	
	' these are read from the <sprite> tag and are used as the first keyframe
	Field firstX:Float=0, firstY:Float=0
	field firstScaleX:Float=1, firstScaleY:Float=1
	Field firstScale:Float=1, firstRotation:Float=0
	Field firstRed:Float=255, firstGreen:Float=255, firstBlue:Float=255, firstAlpha:Float=1
	
	' these are the values at the current time
	Field x:Float=0, y:Float=0
	field scaleX:Float=1, scaleY:Float=1
	Field scale:Float=1, rotation:Float=0
	Field red:Float=255, green:Float=255, blue:Float=255, alpha:Float=1
	
	Field keyframes:DiddyStack<StoryboardSpriteKeyframe> = New DiddyStack<StoryboardSpriteKeyframe>
	Field previousKeyframes:StoryboardSpriteKeyframe[] = New StoryboardSpriteKeyframe[KEYFRAME_COUNT]
	Field nextKeyframes:StoryboardSpriteKeyframe[] = New StoryboardSpriteKeyframe[KEYFRAME_COUNT]
	
Public
	Method SpriteImage:GameImage() Property
		If Not image Then image = diddyGame.images.Find(imageName)
		If Not image Then
			Print "Couldn't load "+imageName+" for sprite."
			Return Null
		End
		Return image
	End
	
	Method X:Float() Property Return x End
	Method Y:Float() Property Return y End
	
	Method Width:Float() Property
		Local image:GameImage = SpriteImage
		If image Then Return image.image.Width()
		Return 0
	End
	
	Method Height:Float() Property
		Local image:GameImage = SpriteImage
		If image Then Return image.image.Height()
		Return 0
	End
	
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
		firstAlpha = Float(node.GetAttribute("alpha","0"))
		CreateKeyframesFromXML(node)
		keyframes.Sort()
	End
	
	Method CreateKeyframesFromXML:Void(node:XMLElement, timeOffset:Int=0)
		For Local childNode:XMLElement = EachIn node.Children
			Local name:String = childNode.Name
			If name = "group" Then
				Local loopCount:Int = Int(childNode.GetAttribute("loopCount","1"))
				Local time:Int = Int(childNode.GetAttribute("time","0"))
				Local length:Int = Int(childNode.GetAttribute("length","0"))
				Local myOffset:Int = timeOffset + time
				For Local i:Int = 0 Until loopCount
					CreateKeyframesFromXML(childNode, myOffset)
					myOffset += length
				Next
			Else
				keyframes.Push(New StoryboardSpriteKeyframe(childNode, timeOffset))
			End
		Next
	End
	
	Method Layer:Int() Property Return layer End
	
	Method CompareTo:Int(other:Object)
		Local o:StoryboardSprite = StoryboardSprite(other)
		If Not o Then Return -1
		If o = Self Then Return 0
		If layer < o.layer Then Return -1
		If layer > o.layer Then Return 1
		Return Super.CompareTo(other)
	End
	
	Method Update:Void(sb:Storyboard, currentTime:Int)
		Self.currentTime = currentTime
		x = firstX; y = firstY
		scaleX = firstScaleX; scaleY = firstScaleY
		scale = firstScale; rotation = firstRotation
		red = firstRed; green = firstGreen; blue = firstBlue; alpha = firstAlpha
		
		' clear the keyframe arrays
		For Local i:Int = 0 Until previousKeyframes.Length
			previousKeyframes[i] = Null
			nextKeyframes[i] = Null
		Next
		
		' find the keyframes either side of the current time
		For Local i:Int = 0 Until keyframes.Count()
			Local kf:StoryboardSpriteKeyframe = keyframes.Get(i)
			' if we've already found the next one, skip it
			If nextKeyframes[kf.keyframeType] Then Continue
			' set the next keyframe if we should
			If currentTime <= kf.time Then
				nextKeyframes[kf.keyframeType] = kf
			Else
				previousKeyframes[kf.keyframeType] = kf
			End
		Next
		
		' loop through each of the keyframe types
		For Local i:Int = 0 Until previousKeyframes.Length
			Local prevKF:StoryboardSpriteKeyframe = previousKeyframes[i]
			Local nextKF:StoryboardSpriteKeyframe = nextKeyframes[i]
			' if we have no previous, we do nothing (can't tween from the start, yet)
			If Not prevKF Then Continue
			' if we have no next, or the next doesn't tween, we just use the previous
			If Not nextKF Or Not nextKF.Tween Then nextKF = prevKF
			' interp and apply
			nextKF.Apply(Self, prevKF, currentTime)
		Next
	End
	
	Method Render:Void(sb:Storyboard, renderer:StoryboardRenderer=Null, x:Float=0, y:Float=0, width:Float=-1, height:Float=-1)
		If alpha = 0 Then Return
		If Not renderer Then renderer = sb.Renderer
		Local image:GameImage = SpriteImage
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
		If renderer.PreRenderSprite(sb, Self, x, y, width, height) Then
			image.Draw(0, 0)
			renderer.PostRenderSprite(sb, Self, x, y, width, height)
		End
		PopMatrix
	End
End

Class StoryboardSpriteKeyframe Implements IComparable
Private
	Field keyframeType:Int
	Field values:Float[]
	Field tween:Bool = True
	Field ease:Int = EASE_NONE
	Field time:Int
	
Public
	Method KeyframeType:Int() Property Return keyframeType End
	Method KeyframeType:Void(keyframeType:Int) Property
		Init(keyframeType)
	End
	
	Method Tween:Bool() Property Return tween End
	Method Tween:Void(tween:Bool) Self.tween = tween End
	
	Method Ease:Int() Property Return ease End
	Method Ease:Void(ease:Int) Self.ease = ease End
	
	Method Time:Int() Property Return time End
	Method Time:Void(time:Int) Property Self.time = time End
	
	Method X:Float() Property Return values[0] End
	Method X:Void(val:Float) Property values[0] = val End
	Method Y:Float() Property Return values[1] End
	Method Y:Void(val:Float) Property values[1] = val End
	
	Method ScaleX:Float() Property Return values[0] End
	Method ScaleX:Void(val:Float) Property values[0] = val End
	Method ScaleY:Float() Property Return values[1] End
	Method ScaleY:Void(val:Float) Property values[1] = val End
	
	Method Scale:Float() Property Return values[0] End
	Method Scale:Void(val:Float) Property values[0] = val End
	
	Method Rotation:Float() Property Return values[0] End
	Method Rotation:Void(val:Float) Property values[0] = val End
	
	Method Alpha:Float() Property Return values[0] End
	Method Alpha:Void(val:Float) Property values[0] = val End
	
	Method Hue:Float() Property Return values[0] End
	Method Hue:Void(val:Float) Property values[0] = val End
	Method Saturation:Float() Property Return values[1] End
	Method Saturation:Void(val:Float) Property values[1] = val End
	Method Luminance:Float() Property Return values[2] End
	Method Luminance:Void(val:Float) Property values[2] = val End
	
	' Constructor for manually building a storyboard
	Method New(keyframeType:Int)
		Init(keyframeType)
	End
	
	' Constructor for reading from xml
	Method New(node:XMLElement, timeOffset:Int=0)
		Local name:String = node.Name
		Self.tween = node.GetAttribute("tween","false").ToLower() = "true"
		Self.time = Int(node.GetAttribute("time","0"))+timeOffset
		
		Local easeStr:String = node.GetAttribute("ease","")
		Local easeType:Int = EASE_NONE
		Select easeStr.ToLower()
			Case "in", ""+EASE_IN
				Self.ease = EASE_IN
			Case "inhalf", ""+EASE_IN_HALF
				Self.ease = EASE_IN_HALF
			Case "indouble", ""+EASE_IN_DOUBLE
				Self.ease = EASE_IN_DOUBLE
			Case "out", ""+EASE_OUT
				Self.ease = EASE_OUT
			Case "outhalf", ""+EASE_OUT_HALF
				Self.ease = EASE_OUT_HALF
			Case "outdouble", ""+EASE_OUT_DOUBLE
				Self.ease = EASE_OUT_DOUBLE
			Case "inout", ""+EASE_IN_OUT
				Self.ease = EASE_IN_OUT
			Default
				Self.ease = EASE_NONE
		End
		
		If name = "scale" Then
			Local scale:Float = Float(node.GetAttribute("scale","1"))
			Init(KEYFRAME_SCALE, scale)
		ElseIf name = "scaleVector" Then
			Local scaleX:Float = Float(node.GetAttribute("scaleX","1"))
			Local scaleY:Float = Float(node.GetAttribute("scaleY","1"))
			Init(KEYFRAME_SCALE_VECTOR, scaleX, scaleY)
		ElseIf name = "alpha" Then
			Local alpha:Float = Clamp(Float(node.GetAttribute("alpha","1")),0.0,1.0)
			Init(KEYFRAME_ALPHA, alpha)
		ElseIf name = "rotation" Then
			Local rotation:Float = Float(node.GetAttribute("rotation","0"))
			Init(KEYFRAME_ROTATION, rotation)
		ElseIf name = "position" Then
			Local x:Float = Float(node.GetAttribute("x","0"))
			Local y:Float = Float(node.GetAttribute("y","0"))
			Init(KEYFRAME_POSITION, x, y)
		ElseIf name = "handle" Then
			Local x:Float = Float(node.GetAttribute("x","0"))
			Local y:Float = Float(node.GetAttribute("y","0"))
			Init(KEYFRAME_HANDLE, x, y)
		ElseIf name = "color" Then
			If node.HasAttribute("red") Or node.HasAttribute("green") Or node.HasAttribute("blue") Then
				Local red:Float = Clamp(Float(node.GetAttribute("red","255")),0.0,255.0)
				Local green:Float = Clamp(Float(node.GetAttribute("green","255")),0.0,255.0)
				Local blue:Float = Clamp(Float(node.GetAttribute("blue","255")),0.0,255.0)
				RGBtoHSL(red, green, blue, hslArray)
			Else
				hslArray[0] = Clamp(Float(node.GetAttribute("hue","0")),0.0,1.0)
				hslArray[1] = Clamp(Float(node.GetAttribute("saturation","0")),0.0,1.0)
				hslArray[2] = Clamp(Float(node.GetAttribute("luminance","0")),0.0,1.0)
			End
			Init(KEYFRAME_COLOR, hslArray[0], hslArray[1], hslArray[2])
		End
	End
	
	Method Apply:Void(sprite:StoryboardSprite, prevKF:StoryboardSpriteKeyframe, currentTime:Int)
		Local progress:Float = 0
		If Self.time >= prevKF.time Then progress = Float(currentTime-prevKF.time)/(Self.time-prevKF.time)
		Select keyframeType
			Case KEYFRAME_ALPHA
				sprite.alpha = InterpolateWithEase(prevKF.values[0], values[0], progress, ease)
			Case KEYFRAME_SCALE
				sprite.scale = InterpolateWithEase(prevKF.values[0], values[0], progress, ease)
			Case KEYFRAME_ROTATION
				sprite.rotation = InterpolateWithEase(prevKF.values[0], values[0], progress, ease)
			Case KEYFRAME_POSITION
				sprite.x = InterpolateWithEase(prevKF.values[0], values[0], progress, ease)
				sprite.y = InterpolateWithEase(prevKF.values[1], values[1], progress, ease)
			Case KEYFRAME_SCALE_VECTOR
				sprite.scaleX = InterpolateWithEase(prevKF.values[0], values[0], progress, ease)
				sprite.scaleY = InterpolateWithEase(prevKF.values[1], values[1], progress, ease)
			Case KEYFRAME_COLOR
				HSLtoRGB(
					InterpolateWithEase(prevKF.values[0], values[0], progress, ease),
					InterpolateWithEase(prevKF.values[1], values[1], progress, ease),
					InterpolateWithEase(prevKF.values[2], values[2], progress, ease), rgbArray)
				sprite.red = rgbArray[0]
				sprite.green = rgbArray[1]
				sprite.blue = rgbArray[2]
			Case KEYFRAME_HANDLE
				If sprite And sprite.image And sprite.image.image Then
					sprite.image.image.SetHandle(InterpolateWithEase(prevKF.values[0], values[0], progress, ease), InterpolateWithEase(prevKF.values[1], values[1], progress, ease))
				End
		End
	End
	
	Method CompareTo:Int(other:Object)
		Local o:StoryboardSpriteKeyframe = StoryboardSpriteKeyframe(other)
		If Not o Then Return -1
		If o = Self Then Return 0
		If time < o.time Then Return -1
		If time > o.time Then Return 1
		If keyframeType < o.keyframeType Then Return -1
		If keyframeType > o.keyframeType Then Return 1
		Return 0
	End
	
Private
	Method Init:Void(keyframeType:Int, value1:Float=0, value2:Float=0, value3:Float=0, value4:Float=0, value5:Float=0)
		Self.keyframeType = keyframeType
		Select keyframeType
			Case KEYFRAME_ROTATION, KEYFRAME_SCALE, KEYFRAME_ALPHA
				InitArray(1, value1)
			Case KEYFRAME_POSITION, KEYFRAME_SCALE_VECTOR
				InitArray(2, value1, value2)
			Case KEYFRAME_COLOR
				InitArray(3, value1, value2, value3)
		End
	End
	
	Method InitArray:Void(elementCount:Int, value1:Float=0, value2:Float=0, value3:Float=0, value4:Float=0, value5:Float=0)
		values = New Float[elementCount]
		If elementCount >= 1 Then values[0] = value1
		If elementCount >= 2 Then values[1] = value2
		If elementCount >= 3 Then values[2] = value3
		If elementCount >= 4 Then values[3] = value4
		If elementCount >= 5 Then values[4] = value5
	End
End

Class StoryboardEffect Abstract
Public
	Method Update:Void(sb:Storyboard, currentTime:Int) Abstract
	Method Render:Void(sb:Storyboard, renderer:StoryboardRenderer=Null, x:Float, y:Float, width:Float, height:Float) Abstract
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
		alpha = Clamp(Float(node.GetAttribute("alpha","1")),0.0,1.0)
		If node.HasAttribute("hue") Or node.HasAttribute("saturation") Or node.HasAttribute("luminance") Then
			Local hue:Float = Clamp(Float(node.GetAttribute("hue","0")),0.0,1.0)
			Local saturation:Float = Clamp(Float(node.GetAttribute("saturation","0")),0.0,1.0)
			Local luminance:Float = Clamp(Float(node.GetAttribute("luminance","0")),0.0,1.0)
			HSLtoRGB(hue, saturation, luminance, rgbArray)
			red = rgbArray[0]; green = rgbArray[1]; blue = rgbArray[2]
		Else
			red = Clamp(Float(node.GetAttribute("red","255")),0.0,255.0)
			green = Clamp(Float(node.GetAttribute("green","255")),0.0,255.0)
			blue = Clamp(Float(node.GetAttribute("blue","255")),0.0,255.0)
		End
	End
	
	Method Update:Void(sb:Storyboard, currentTime:Int)
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
	
	Method Render:Void(sb:Storyboard, renderer:StoryboardRenderer=Null, x:Float=0, y:Float=0, width:Float=-1, height:Float=-1)
		If Not renderer Then renderer = sb.Renderer
		If renderer.PreRenderEffect(sb, Self, x, y, width, height) And currentAlpha <> 0 Then
			SetAlpha(currentAlpha)
			SetColor(red, green, blue)
			DrawRect(x, y, width, height)
			renderer.PostRenderEffect(sb, Self, x, y, width, height)
		End
	End
End

Private
Global hslArray:Float[] = New Float[3]
Global rgbArray:Int[] = New Int[3]
