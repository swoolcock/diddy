Strict

Import mojo
Import functions

' Store the device width and height
Global SCREEN_WIDTH%
Global SCREEN_HEIGHT%
' Half of SCREEN_WIDTH and HEIGHT
Global SCREEN_WIDTH2%
Global SCREEN_HEIGHT2%

' THE GAME!!
Global game:DiddyApp

' Used for delta timing movement
Global dt:DeltaTimer

Class DiddyApp Extends App

	Field debugOn:Bool = False

	Field FPS% = 60
	
	' current Screen
	Field currentScreen:Screen
	' next Screen
	Field nextScreen:Screen
	' exit Screen
	Field exitScreen:ExitScreen = new ExitScreen()
	' used for fading
	Field screenFade:ScreenFade = New ScreenFade
	
	' mouse
	Field mouseX:Int, mouseY:Int
	Field mouseHit:Int
	
	' Store the images here
	Global images:ImageBank = New ImageBank
	' Store the sounds here
	Global sounds:SoundBank = New SoundBank
	
	Method OnCreate:Int()
		' Store the device width and height
		SCREEN_WIDTH = DeviceWidth()
		SCREEN_HEIGHT = DeviceHeight()
		SCREEN_WIDTH2 = SCREEN_WIDTH / 2
		SCREEN_HEIGHT2 = SCREEN_HEIGHT / 2
		
		' set the mouse x,y
		mouseX = MouseX()
		mouseY = MouseY()
		
		' Set the Random seed
		Seed = RealMillisecs()
		' Create the delta timer
		dt = New DeltaTimer(FPS)
		SetUpdateRate FPS
		
		'create all the particles
		Particle.Cache()
		
		Return 0
	End
		
	Method OnRender:Int()
		FPSCounter.Update()
		currentScreen.Render()
		If screenFade.active then screenFade.Render()
		If debugOn
			DrawDebug()
		End
		Return 0
	End
	
	Method OnUpdate:Int()
		dt.UpdateDelta()
		ScreenLogic()

		Return 0
	End
	
	Method ScreenLogic:Int()
		mouseX = MouseX()
		mouseY = MouseY()
		mouseHit = MouseHit()
 
		If screenFade.active then screenFade.Update()
		currentScreen.Update()
	End

	Method DrawDebug:Void()
		SetAlpha 0.2
		SetColor 0, 0, 0
		DrawRect 0, 0, 200, 200
		SetColor 255, 255, 255
		SetAlpha 1
		FPSCounter.Draw(0,0)
		DrawText "Delta = "+dt.delta, 0, 10
		DrawText "Screen = "+currentScreen.name,0, 20
	End
	
End

Class ScreenFade
	Field fadeTime:Float
	Field fadeOut:Bool
	Field ratio# = 0
	Field active:Bool
	Field counter:Float
	
	Method Start:Void(fadeTime:Float, fadeOut:Bool)
		If active Then Return
		active = true
		self.fadeTime = fadeTime	
		self.fadeOut = fadeOut

		If fadeOut Then
			ratio = 1
		Else
			ratio = 0
		End
		counter = 0
	End

	Method Update:Void()
		if not active return
		counter += dt.delta
		CalcRatio()
				
		if counter > fadeTime
			active = false
			if fadeOut			
				game.currentScreen.PostFadeOut()
			else
				game.currentScreen.PostFadeIn()
			End
		End
	End
	
	Method CalcRatio:Void()
		ratio = counter/fadeTime
		If ratio < 0 Then ratio = 0
		If ratio > 1 Then ratio = 1			
		If fadeOut Then
			ratio = 1 - ratio
		End
	End
	
	Method Render:Void()
		if not active return
		
		SetAlpha 1 - ratio
		SetColor 0, 0, 0
		DrawRect 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT
		SetAlpha 1
		SetColor 255, 255, 255
	End
	
End Class

Class ExitScreen Extends Screen
	Method New()
		name = "exit"
	End
	
	method Start:Void()
		ExitApp()
	End

	method Render:Void()
		
	End 
	
	method Update:Void()
		
	End 

End


Class Screen Abstract
	Field name$ = ""
	
	Method PreStart:Void()
		game.currentScreen = self
		Start()
	End
	
	Method Start:Void() Abstract
	
	Method Render:Void() Abstract
	
	Method Update:Void() Abstract
	
	Method PostFadeOut:Void()
		game.nextScreen.PreStart()
	End
	
	Method PostFadeIn:Void()
	
	End
End Class

Class FPSCounter Abstract
	Global fpsCount:Int
	Global startTime:Int
	Global totalFPS:Int

	Function Update:Void()
		If Millisecs() - startTime >= 1000
			totalFPS = fpsCount
			fpsCount = 0
			startTime = Millisecs()
		Else
			fpsCount+=1
		End
	End

	Function Draw:Void(x% = 0, y% = 0, ax# = 0, ay# = 0)
		DrawText("FPS: " + totalFPS, x, y, ax, ay)
	End
End Class

' From James Boyd
Class DeltaTimer
	Field targetfps:Float = 60
	Field currentticks:Float
	Field lastticks:Float
	Field frametime:Float
	Field delta:Float
	
	Method New (fps:Float)
		targetfps = fps
		lastticks = Millisecs()
	End
	
	Method UpdateDelta:Void()
		currentticks = Millisecs()
		frametime = currentticks - lastticks
		delta = frametime / (1000.0 / targetfps)
		lastticks = currentticks
	End
End


Class ImageBank Extends StringMap<GameImage>
	
	Field path$ = "graphics/"
	
	Method Load:Void(name:String, nameoverride:String = "", midhandle:bool=true)
		Local i:GameImage = New GameImage
		i.Load(path + name, midhandle)
		
		If nameoverride <> "" Then i.name = nameoverride.ToUpper()
		Self.Set(i.name , i)
	End
	
	Method LoadAnim:Void(name:String, w%, h%, total%, tmpImage:Image, midhandle:Bool=true)
		Local i:GameImage = New GameImage
		i.LoadAnim(path + name, w, h, total, tmpImage, midhandle)
		Self.Set(i.name, i)
	End
   
	Method Find:GameImage(name:String)
		name = name.ToUpper()

		' debug: print all keys in the map
	'	For Local key:String = EachIn self.Keys()
	'		Print key + " is stored in the map."
	'	Next
	   	
		Local i:GameImage =  self.Get(name)
		AssertNotNull(i, "Image '" + name + "' not found in the ImageBank")
		Return i
	End
End Class

Class GameImage
	Field name$
	Field image:Image
	Field w%
	Field h%
	Field w2#
	Field h2#
	Field midhandled%=0
	
	Method Load:Void(file$, midhandle:bool=true)
		name = StripAll(file.ToUpper())		
		image = LoadBitmap(file)	
		CalcSize()
		MidHandle(midhandle)
	End
	
	Method LoadAnim:Void(file$, w%, h%, total%, tmpImage:Image, midhandle:Bool=true)
		name = StripAll(file.ToUpper())
		image = LoadAnimBitmap(file, w, h, total, tmpImage)	
		CalcSize()
		MidHandle(midhandle)
	End
	
	Method CalcSize:Void()
		If image <> Null Then
			w = image.Width()
			h = image.Height()
			w2 = w/2
			h2 = h/2
		End
	End
	
	Method MidHandle:Void(On:Bool)
		If On Then
			image.SetHandle(w2, h2)
			midhandled=1
		Else
			image.SetHandle(0, 0)
			midhandled=0
		End 
	End
	
	Method Draw:Void(x#, y#, rotation# = 0, scaleX# = 1, scaleY# = 1, frame% = 0)
		DrawImage(self.image, x, y, rotation, scaleX, scaleY, frame)
	End
	
End Class


Class SoundBank Extends StringMap<GameSound>
	
	Global path$ = "sounds/"
	
	Method Load:Void(name:String, nameoverride:String = "")
		Local i:GameSound = New GameSound
		i.Load(name)
				
		If nameoverride <> "" Then i.name = nameoverride.ToUpper()
		Self.Set(i.name , i)
	End
	   
	Method Find:GameSound(name:String)
		name = name.ToUpper()

		' debug: print all keys in the map
	'	For Local key:String = EachIn self.Keys()
	'		Print key + " is stored in the map."
	'	Next

		Local i:GameSound =  Self.Get(name)
		AssertNotNull(i, "Sound '" + name + "' not found in the SoundBank")
		Return i
	End
End

Class GameSound
	Field name$
	Field sound:Sound
	Field rate# = 1
	Field pan# = 0
	Field volume# = 1
	Field loop% = 0
	
	Method Load:Void(file$)
		#if TARGET="flash"
			sound = LoadSoundSample(SoundBank.path + file +".mp3")
		#else If TARGET="android"
			sound = LoadSoundSample(SoundBank.path + file +".ogg")
		#else
			sound = LoadSoundSample(SoundBank.path + file +".wav")
		#endif
		
		name = StripAll(file.ToUpper())	
	End Method
	
	Method Play:Void()
		SoundPlayer.PlayFx(sound, pan, rate, volume, loop)
	End Method
End Class

Class SoundPlayer
	Global channel:Int
	Const MAX_CHANNELS:Int = 31
	Function PlayFx:Void(s:Sound, pan#=0, rate#=1, volume#=1, loop% = 0)
		channel += 1
		If (channel > MAX_CHANNELS) Then channel = 0

		StopChannel(channel)
		PlaySound(s, channel, loop)
		SetChannelPan(channel, pan)
		SetChannelRate(channel, rate)
		SetChannelVolume(channel, volume)
	End
End

Class Sprite
	Field name$
	Field x#, y#
	Field ox#, oy#
	Field dx#, dy#
	Field speedX#, speedY#, speed#
	Field maxXSpeed#, maxYSpeed#
	Field image:GameImage
	Field scaleX# = 1, scaleY# = 1

	Field red% = 255, green% = 255, blue% = 255, alpha# = 1
	Field hitBoxX:Int = 0
	Field hitBoxY:Int = 0
	Field hitBoxWidth:Int
	Field hitBoxHeight:Int
	
	' Animation
	Field frame:Int
	Field frameTimer:Int
	Field frameStart:Int
	Field frameEnd:Int
	Field frameSpeed:Int = 0 
	Field reverse:Bool = false
	Field pingPong:Bool = false
	Field loop:Bool = true
	Field ping%
	
	' Scale
	Field scaleCounter#=0
	Field scaleXSpeed# = 0.1
	Field scaleYSpeed# = 0.1
	Field ygravity#
	Field maxFrame:Int
	
	' Rotation
	Field rotationCounter#=0
	Field rotationLength%=1000
	Field rotationLoop% = 0
	Field rotation#, rotationSpeed# = 1
	
	Method New(img:GameImage,x#, y#)
		Self.image = img
		Self.x = x
		Self.y = y
		self.alpha = 1
		self.SetHitBox(-img.w2, -img.h2, img.w, img.h)
	End
	
	Method SetImage:Void(gi:GameImage)
		image = gi
		GetSize()
	End
	
	Method GetSize:Void()
		'Sets w and h based on the current image.
		If image <> Null Then
			image.w = image.image.Width()
			image.h = image.image.Height()
			image.w2 = image.w/2
			image.h2 = image.h/2
		End	
	End
	
	Method Precache:Void()
		DrawImage image.image, -image.w-50, -image.h-50		
	End
	
	Method SetRGB:Void(r%,g%,b%)
		Self.red = r
		Self.green = g
		Self.blue = b
	End
	
	Method SetScaleXY:Void(sx#, sy#)
		self.scaleX = sx
		self.scaleY = sy
	End
	
	Method Move:Void()
		Self.x+=Self.dx * dt.delta
		Self.y+=Self.dy * dt.delta
		
		If ygravity > 0 Then dy += ygravity * dt.delta
	End
	
	Method ManageScale:Void()
		If scaleCounter>0 Then
			scaleCounter-=1*dt.delta
			scaleX+=scaleXSpeed*dt.delta
			scaleY+=scaleYSpeed*dt.delta
		End
	End
	
	Method ManageRotation:Void()
		If rotationLoop Then
			rotation+=rotationSpeed*dt.delta
			If rotation >= 360 Then rotation-=360
			If rotation <0 Then rotation+=360
		Else
			If rotationCounter>0 Then		
				rotationCounter-=1 * dt.delta
				rotation+=rotationSpeed * dt.delta
			End
		End				
	End
	
	Method MoveForward:Void()
		dx = -Sin(rotation) * speed
        dy = -Cos(rotation) * speed

		move()
	End

	Method SetFrame:Void(startFrame:Int=0, endFrame:Int=0, speed:Int=125, pingPong:Bool = false, loop:Bool = true)
		frame = startFrame
		frameStart = startFrame
		frameEnd = endFrame
		if startFrame > endFrame
			reverse = true
		else
			reverse = false
		End
		self.pingPong = pingPong
		self.loop = loop
		frameSpeed = speed
		frameTimer = Millisecs()
		ping = 0
	End
	
	Method UpdateAnimation:Void()
		if frameSpeed > 0
			If Millisecs() > frameTimer + frameSpeed
				if not reverse
					frame+=1
					If frame > frameEnd
						ResetAnim()
					End
				else
					frame-=1
					If frame < frameEnd
						ResetAnim()
					End			
				End
				frameTimer = Millisecs()
			End	
		end
	End
	
	Method ResetAnim:Void()
		if loop then
			if pingPong
				reverse = Not reverse
				frame = frameEnd
				local ts% = frameStart
				frameStart = frameEnd
				frameEnd = ts
			else
				frame = frameStart
			End
		else
			if pingPong and ping <1
				reverse = Not reverse
				frame = frameEnd
				local ts% = frameStart
				frameStart = frameEnd
				frameEnd = ts
				ping+=1
			else
				frame = frameEnd
			End
		End
	End
	
	Method Draw:Void()
		Draw(0,0)
	End
	
	Method Draw:Void(offsetx#=0, offsety#=0)
		If x - offsetx + image.w < 0 Or x - offsetx - image.w >= SCREEN_WIDTH Or y - offsety + image.h < 0 Or y - offsety - image.h >= SCREEN_HEIGHT Then Return
		SetAlpha self.alpha
		SetColor red, green, blue ' doesnt work with images!?!??!
		DrawImage(image.image, x - offsetx, y - offsety, rotation, scaleX, scaleY, frame)
		SetColor 255, 255, 255
		SetAlpha 1

	'	if debug
	'		drawRectOutline(x + hitBoxX, y + hitBoxY, hitBoxWidth, hitBoxHeight)
	'	End
	End
		
	
	Method Collide:Int(sprite:Sprite)
		Return RectsOverlap(x + hitBoxX, y + hitBoxY, hitBoxWidth, hitBoxHeight, 
							sprite.x + sprite.hitBoxX, sprite.y + sprite.hitBoxY, sprite.hitBoxWidth, sprite.hitBoxHeight)
	End
		
	Method SetHitBox:Void(hitX:Int, hitY:Int, hitWidth:Int, hitHeight:Int)
		hitBoxX = hitX
		hitBoxY = hitY
		hitBoxWidth = hitWidth
		hitBoxHeight = hitHeight
	End
End

Class Particle Extends Sprite
	Global MAX_PARTICLES% = 800
	Global particles:Particle[MAX_PARTICLES]
	Global lastDeath% = 0
	Global maxIndex% = -1
	Global minIndex% = -1
	Global particleCount% = 0
	Field lifeCounter# = 0
	Field fadeIn# = 0
	Field fadeCounter#
	Field fadeInLength# = 0
	Field fadeLength#=0
	Field active% = 0
	
	Function Cache:Void()
		For Local i% = 0 to MAX_PARTICLES - 1
			particles[i] = New Particle()
		Next
	End
	
	Function Create:Particle(gi:GameImage, x#, y#, dx#=0, dy#=0, gravity#=0, fadeLength#=0, lifeCounter%=0)
		Local i%=lastDeath
		Repeat
			If particles[i] = Null Then particles[i] = New Particle()
			If Not particles[i].active Then
				particles[i].SetImage(gi)
				particles[i].x = x
				particles[i].y = y
				particles[i].dx = dx
				particles[i].dy = dy

				particles[i].ygravity = gravity
				particles[i].fadeLength = fadeLength / 10
				particles[i].fadeCounter = particles[i].fadeLength
				If lifeCounter>0 Then particles[i].lifeCounter = lifeCounter / 10
				particles[i].active = 1
				If maxIndex < 0 Or i > maxIndex Then maxIndex = i
				If minIndex < 0 Or i < minIndex Then minIndex = i
				particleCount += 1
				Return particles[i]
			End
			i += 1
			If i >= MAX_PARTICLES Then i = 0
		Until i = lastDeath
		Return Null
	End
	
	Function Clear:Void()
		For Local i% = 0 to MAX_PARTICLES - 1
			particles[i].alpha = 0
			particles[i].active = False
		Next
		minIndex = -1
		maxIndex = -1
		particleCount = 0
		lastDeath = 0
	End
	
	Function DrawAll:Void()
		If minIndex < 0 Or maxIndex < 0 Then Return
		For Local i% = minIndex to maxIndex
			if particles[i] <> null And particles[i].image <> null
				If particles[i].fadeCounter > 0 and particles[i].active Then
					If particles[i].fadeIn Then
						particles[i].alpha = particles[i].fadeCounter/particles[i].fadeInLength
					Else
						particles[i].alpha = particles[i].fadeCounter/particles[i].fadeLength
					End
				End
				particles[i].Draw()
			End
		Next
	End
	
	Function UpdateAll:Void()
		If minIndex < 0 Or maxIndex < 0 Then Return
		Local newMinIndex% = -1
		Local newMaxIndex% = -1
		For Local i% = minIndex to maxIndex
			if particles[i] <> null And particles[i].image <> null
				If particles[i].active
					particles[i].Update()
					If particles[i].active Then
						If newMinIndex < 0 Then newMinIndex = i
						newMaxIndex = i
					Else
						lastDeath = i
						particleCount -= 1
					End
				End
			End
		Next
		minIndex = newMinIndex
		maxIndex = newMaxIndex
	End	
	
	Method Update:Void()
		Super.Move()

		If fadeIn Then
			fadeCounter+=dt.delta

			If fadeCounter >= fadeInLength Then
				fadeCounter = fadeLength
				fadeIn = 0
				alpha = 1
			End
		ElseIf fadeCounter>0 Then
			fadeCounter-=dt.delta
			If fadeCounter <= 0 Then
				alpha = 0
				active = 0
			End 
		End
	End
	
End







