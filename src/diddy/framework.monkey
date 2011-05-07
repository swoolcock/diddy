Strict

Import mojo
Import functions

'Device width and height
Global DEVICE_WIDTH%
Global DEVICE_HEIGHT%

' Screen width and height
Global SCREEN_WIDTH#
Global SCREEN_HEIGHT#

' Half of SCREEN_WIDTH and HEIGHT
Global SCREEN_WIDTH2#
Global SCREEN_HEIGHT2#

' Used for Virtual Res
Global SCREENX_RATIO# = 1
Global SCREENY_RATIO# = 1

' THE GAME!!
Global game:DiddyApp

' Used for delta timing movement
Global dt:DeltaTimer

Class DiddyApp Extends App

	Field debugOn:Bool = False
	Field drawFPSOn:Bool = False
	
	Field virtualResOn:Bool = True
	
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
	' volume control
	Field soundVolume:Int = 100
	Field musicVolume:Int = 100
	Field musicOkay:Int
	
	Method OnCreate:Int()
		' Store the device width and height
		DEVICE_WIDTH = DeviceWidth()
		DEVICE_HEIGHT = DeviceHeight()
		
		SetScreenSize(DEVICE_WIDTH, DEVICE_HEIGHT)
		
		' set the mouse x,y
		mouseX = MouseX() / SCREENX_RATIO
		mouseY = MouseY() / SCREENY_RATIO
		
		' Set the Random seed
		Seed = RealMillisecs()
		' Create the delta timer
		dt = New DeltaTimer(FPS)
		SetUpdateRate FPS
		
		'create all the particles
		Particle.Cache()
		
		Return 0
	End
	
	Method SetScreenSize:Void(w:Float, h:Float)
		SCREEN_WIDTH = w
		SCREEN_HEIGHT = h
		SCREEN_WIDTH2 = SCREEN_WIDTH / 2
		SCREEN_HEIGHT2 = SCREEN_HEIGHT / 2
		
		SCREENX_RATIO = DEVICE_WIDTH/SCREEN_WIDTH
		SCREENY_RATIO = DEVICE_HEIGHT/SCREEN_HEIGHT
		
		If SCREENX_RATIO <> 1 Or SCREENY_RATIO <> 1
			virtualResOn = True
		End
	End
		
	Method OnRender:Int()
		FPSCounter.Update()
		If virtualResOn
			PushMatrix 
			Scale SCREENX_RATIO, SCREENY_RATIO
		End
			currentScreen.Render()
			If screenFade.active then screenFade.Render()
		if virtualResOn
			PopMatrix
		End
		currentScreen.ExtraRender()
		If debugOn
			DrawDebug()
		End
		If drawFPSOn
			DrawFPS()
		End
		Return 0
	End
	
	Method OnUpdate:Int()
		dt.UpdateDelta()
		ScreenLogic()

		Return 0
	End
	
	Method ScreenLogic:Int()
		mouseX = MouseX() / SCREENX_RATIO
		mouseY = MouseY() / SCREENY_RATIO
		mouseHit = MouseHit()
 
		If screenFade.active then screenFade.Update()
		currentScreen.Update()
	End

	Method DrawDebug:Void()
		SetColor 255, 255, 255
		FPSCounter.Draw(0,0)
		DrawText "Screen         = "+currentScreen.name, 0, 10
		DrawText "Delta          = "+FormatNumber(dt.delta, 2) , 0, 20
		DrawText "Screen Width   = "+SCREEN_WIDTH, 0, 30
		DrawText "Screen Height  = "+SCREEN_HEIGHT, 0, 40
		DrawText "VMouseX        = "+Self.mouseX, 0, 50
		DrawText "VMouseY        = "+Self.mouseY, 0, 60
		DrawText "MouseX         = "+MouseX(), 0, 70
		DrawText "MouseY         = "+MouseY(), 0, 80
		DrawText "MusicOkay      = "+musicOkay, 0, 90
		DrawText "Music State    = "+MusicState(), 0, 100
		DrawText "Music Volume   = "+Self.musicVolume, 0, 110
		DrawText "Sound Volume   = "+Self.soundVolume, 0, 120
		DrawText "Sound Channel  = "+SoundPlayer.channel, 0, 130
	End
	
	Method DrawFPS:Void()
		DrawText FPSCounter.totalFPS, 0, 0
	End
	
	Method MusicPlay:Void(file:String, flags:Int=1)
		SetMusicVolume(musicVolume/100.0)
		musicOkay = PlayMusic("music/"+file, flags)
	End
	
	Method MusicSetVolume:Void(volume:Int)
		If volume < 0 Then volume = 0
		If volume > 100 Then volume = 100
		Self.musicVolume = volume
		SetMusicVolume(musicVolume/100.0)
	End
	
	Method SoundSetVolume:Void(volume:Int)
		If volume < 0 Then volume = 0
		If volume > 100 Then volume = 100
		Self.soundVolume = volume
		For Local i% = 0 To SoundPlayer.MAX_CHANNELS
			SetChannelVolume(i, game.soundVolume / 100.0)
		Next
	End
	
End

Class ScreenFade
	Field fadeTime:Float
	Field fadeOut:Bool
	Field ratio:Float = 0
	Field active:Bool
	Field counter:Float
	Field fadeMusic:Bool
	Field fadeSound:Bool
	
	Method Start:Void(fadeTime:Float, fadeOut:Bool, fadeSound:Bool = False, fadeMusic:Bool = False)
		If active Then Return
		active = True
		Self.fadeTime = fadeTime	
		Self.fadeOut = fadeOut
		Self.fadeMusic = fadeMusic
		Self.fadeSound = fadeSound
		If fadeOut Then
			ratio = 1
		Else
			ratio = 0
		End
		counter = 0
	End

	Method Update:Void()
		If Not active Return
		counter += dt.delta
		CalcRatio()
		If fadeSound Then
			For Local i% = 0 To SoundPlayer.MAX_CHANNELS
				SetChannelVolume(i, (ratio) * (game.soundVolume / 100.0))
			Next
		End
		If fadeMusic Then
			SetMusicVolume((ratio) * (game.musicVolume / 100.0))
		End
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
		If Not active Return
		
		SetAlpha 1 - ratio
		SetColor 0, 0, 0
		DrawRect 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT
		SetAlpha 1
		SetColor 255, 255, 255
	End
	
End

Class ExitScreen Extends Screen
	Method New()
		name = "exit"
	End
	
	Method Start:Void()
		ExitApp()
	End
	
	Method Render:Void()
	End 
	
	Method Update:Void()
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
	
	Method ExtraRender:Void()
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
End

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
	
	Method PreCache:Void()
		Local gi:GameImage
		For Local key:String = EachIn self.Keys()
			gi = Self.Get(key)
			gi.PreCache()
		Next
	End
	
End

Class GameImage
	Field name$
	Field image:Image
	Field w%
	Field h%
	Field w2#
	Field h2#
	Field midhandled%=0
	
	Field leftMargin%=0
	Field rightMargin%=0
	Field topMargin%=0
	Field bottomMargin%=0
	
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
	
	Method DrawTiled:Void(x#, y#, w#, h#, scaleX# = 1, scaleY# = 1, frame% = 0)
	End
	
	Method DrawStretched:Void(x#, y#, rw#, rh#, frame% = 0)
	End
	
	Method DrawGrid:Void(x#, y#, rw#, rh#, frame% = 0)
		' draw top left corner
		DrawImageRect(self.image, x, y, 0, 0, leftMargin, topMargin, frame)
		' draw top right corner
		DrawImageRect(self.image, x+rw-rightMargin, y, w-rightMargin, 0, rightMargin, topMargin, frame)
		' draw bottom left corner
		DrawImageRect(self.image, x, y+rh-bottomMargin, 0, h-bottomMargin, leftMargin, bottomMargin, frame)
		' draw bottom right corner
		DrawImageRect(self.image, x+rw-rightMargin, y+rh-bottomMargin, w-rightMargin, h-bottomMargin, rightMargin, bottomMargin, frame)
		
		' work out how many horizontal and vertical tiles
		Local tileWidth% = (w-leftMargin-rightMargin)
		Local tileHeight% = (h-topMargin-bottomMargin)
		Local tileXCount% = (rw-leftMargin-rightMargin) / tileWidth
		Local tileYCount% = (rh-topMargin-bottomMargin) / tileHeight
		Local tileXOverflow% = (rw-leftMargin-rightMargin) Mod tileWidth
		Local tileYOverflow% = (rh-topMargin-bottomMargin) Mod tileHeight
		
		' tile top and bottom edges
		For Local i% = 0 Until tileXCount
			DrawImageRect(self.image, leftMargin+i*tileWidth,0,leftMargin,0,tileWidth,topMargin,frame)
			DrawImageRect(self.image, leftMargin+i*tileWidth,rh-bottomMargin,leftMargin,h-bottomMargin,tileWidth,bottomMargin,frame)
		Next
		If tileXOverflow > 0 Then
			DrawImageRect(self.image, leftMargin+tileXCount*tileWidth,0,leftMargin,0,tileXOverflow,topMargin,frame)
			DrawImageRect(self.image, leftMargin+tileXCount*tileWidth,rh-bottomMargin,leftMargin,h-bottomMargin,tileXOverflow,bottomMargin,frame)
		End
		
		' tile left and right edges
		For Local i% = 0 Until tileYCount
			DrawImageRect(self.image, 0, topMargin+i*tileHeight,0,topMargin,leftMargin,tileHeight,frame)
			DrawImageRect(self.image, rw-rightMargin,topMargin+i*tileHeight,w-rightMargin,topMargin,rightMargin,tileHeight,frame)
		Next
		If tileYOverflow > 0 Then
			DrawImageRect(self.image, 0, topMargin+tileYCount*tileHeight,0,topMargin,leftMargin,tileYOverflow,frame)
			DrawImageRect(self.image, rw-rightMargin,topMargin+tileYCount*tileHeight,w-rightMargin,topMargin,rightMargin,tileYOverflow,frame)
		End
		
		' tile centre
		' TODO
	End
	
	Method PreCache:Void()
		DrawImage self.image, -self.w-50, -self.h-50
	End
End


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
	
		If file.Contains(".wav") Or file.Contains(".ogg") Or file.Contains(".mp3") Then
			sound = LoadSoundSample(SoundBank.path + file)
		Else
			#if TARGET="flash"
				sound = LoadSoundSample(SoundBank.path + file +".mp3")
			#else If TARGET="android"
				sound = LoadSoundSample(SoundBank.path + file +".ogg")
			#else
				sound = LoadSoundSample(SoundBank.path + file +".wav")
			#endif
		End
		
		name = StripAll(file.ToUpper())	
	End
	
	Method Play:Void()
		SoundPlayer.PlayFx(sound, pan, rate, volume * (game.soundVolume / 100.0), loop)
	End
End

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
	Field visible?
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
		Self.visible = True
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
		If Self.alpha > 1 Then Self.alpha = 1
		If Self.alpha < 0 Then Self.alpha = 0
		SetAlpha Self.alpha
		SetColor red, green, blue ' doesnt work with images!?!??!
		DrawImage(image.image, x - offsetx, y - offsety, rotation, scaleX, scaleY, frame)
		SetColor 255, 255, 255
		SetAlpha 1

	'	if debug
	'		drawRectOutline(x + hitBoxX, y + hitBoxY, hitBoxWidth, hitBoxHeight)
	'	End
	End

	Method SetupRotation:Void(rotationSpeed:Float, length:Int, loop:Bool = False, rndPosition:Bool = False)	
		Self.rotationSpeed = rotationSpeed
		If loop Then
			rotationLoop = 1
			If rndPosition Then rotation = Rnd(0,360)
		Else
			rotationLength = length
			rotationCounter = rotationLength 	
		End
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



















