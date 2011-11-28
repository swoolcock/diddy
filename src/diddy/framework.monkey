Strict

Import mojo
Import functions
Import collections
Import inputcache

'Device width and height
Global DEVICE_WIDTH:Float
Global DEVICE_HEIGHT:Float

' Screen width and height
Global SCREEN_WIDTH:Float
Global SCREEN_HEIGHT:Float

' Half of SCREEN_WIDTH and HEIGHT
Global SCREEN_WIDTH2:Float
Global SCREEN_HEIGHT2:Float

' Used for Virtual Res
Global SCREENX_RATIO:Float = 1
Global SCREENY_RATIO:Float = 1

' THE GAME!!
Global game:DiddyApp

' Used for delta timing movement
Global dt:DeltaTimer

Class DiddyApp Extends App

	Field debugKeyOn:Bool = False
	Field debugOn:Bool = False
	Field drawFPSOn:Bool = False
	Field debugKey:Int = KEY_F1
	
	Field virtualResOn:Bool = True
	Field aspectRatioOn:Bool = False

	Field aspectRatio:Float
	Field multi:Float
	Field widthBorder:Float				' Size of border at sides
	Field heightBorder:Float			' Size of border at top/bottom
	
	Field deviceChanged:Int				' Device size changed
	Field lastDeviceWidth:Int			' For device change detection
	Field lastDeviceHeight:Int			' For device change detection
	Field virtualScaledW:Float
	Field virtualScaledH:Float
	Field virtualXOff:Float
	Field virtualYOff:Float
	
	Field FPS:Int = 60
	
	' current Screen
	Field currentScreen:Screen
	' next Screen
	Field nextScreen:Screen
	' exit Screen
	Field exitScreen:ExitScreen
	' used for fading
	Field screenFade:ScreenFade
	' scroll
	Field scrollX:Float
	Field scrollY:Float
	
	' mouse
	Field mouseX:Int, mouseY:Int
	Field mouseHit:Int
	
	' store the images here
	Field images:ImageBank
	' store the sounds here
	Field sounds:SoundBank
	' volume control
	Field musicFile:String = ""
	Field soundVolume:Int = 100
	Field musicVolume:Int = 100
	Field mojoMusicVolume:Float = 1.0
	Field musicOkay:Int
	
	Field clickSound:GameSound
	
	' input
	Field inputCache:InputCache

	' fixed rate logic stuff
	Field frameRate:Float = 200 ' speed the logic runs at
	Field ms:Float = 0 ' milliseconds per frame eg 1000ms/200framerate = 5ms per frame
	Field tmpMs:Float
	Field numTicks:Float
	Field lastNumTicks:Float
	Field maxMs:Int = 50
	Field lastTime:Float
Private
	Field useFixedRateLogic:Bool = False
	Field vsx:Float, vsy:Float, vsw:Float, vsh:Float
	
Public
	Method New()
		Self.exitScreen = New ExitScreen
		Self.screenFade = New ScreenFade
		Self.images = New ImageBank
		Self.sounds = New SoundBank
		Self.inputCache = New InputCache
	End
			
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
		' Set the update rate
		SetUpdateRate FPS
		
		'create all the particles
		Particle.Cache()
		
		' fixed rate logic timing
		If useFixedRateLogic
			ResetFixedRateLogic()
		End
		Return 0
	End
	
	Method SetScreenSize:Void(w:Float, h:Float, useAspectRatio:Bool = False)
		SCREEN_WIDTH = w
		SCREEN_HEIGHT = h
		SCREEN_WIDTH2 = SCREEN_WIDTH / 2
		SCREEN_HEIGHT2 = SCREEN_HEIGHT / 2
		
		SCREENX_RATIO = DEVICE_WIDTH/SCREEN_WIDTH
		SCREENY_RATIO = DEVICE_HEIGHT/SCREEN_HEIGHT
		
		If SCREENX_RATIO <> 1 Or SCREENY_RATIO <> 1
			virtualResOn = True
			aspectRatioOn = useAspectRatio
			aspectRatio = h / w
		End
	End
		
	Method OnRender:Int()
		FPSCounter.Update()
		If virtualResOn
			PushMatrix
			If aspectRatioOn
				If (DEVICE_WIDTH <> lastDeviceWidth) Or (DEVICE_HEIGHT <> lastDeviceHeight)
					lastDeviceWidth = DeviceWidth()
					lastDeviceHeight = DeviceHeight()
					deviceChanged = True
				End
				If deviceChanged
					Local deviceRatio:Float = DEVICE_HEIGHT / DEVICE_WIDTH
					If deviceRatio >= aspectRatio
						multi = DEVICE_WIDTH / SCREEN_WIDTH
						heightBorder = (DEVICE_HEIGHT - SCREEN_HEIGHT * multi) * 0.5
						widthBorder = 0
					Else
						multi = DEVICE_HEIGHT / SCREEN_HEIGHT 
						widthBorder = (DEVICE_WIDTH - SCREEN_WIDTH * multi) * 0.5
						heightBorder = 0
					End
				
					vsx = Max(0.0, widthBorder )
					vsy = Max(0.0, heightBorder )
					vsw = Min(DEVICE_WIDTH - widthBorder * 2.0, DEVICE_WIDTH)
					vsh = Min(DEVICE_HEIGHT- heightBorder * 2.0, DEVICE_HEIGHT)
					
					virtualScaledW = (SCREEN_WIDTH * multi)
					virtualScaledH = (SCREEN_HEIGHT * multi)
					
					virtualXOff = (DEVICE_WIDTH - virtualScaledW) * 0.5
					virtualYOff = (DEVICE_HEIGHT - virtualScaledH) * 0.5
					
					virtualXOff = virtualXOff / multi
					virtualYOff = virtualYOff/ multi
					
					deviceChanged = False
				End
				
				SetScissor 0, 0, DEVICE_WIDTH , DEVICE_HEIGHT 
				Cls 0, 0, 0
				
				SetScissor vsx, vsy, vsw, vsh
	
				Scale multi, multi

				Translate virtualXOff, virtualYOff 
			Else
				Scale SCREENX_RATIO, SCREENY_RATIO
			End
		End
		
		' render the screen
		currentScreen.Render()
		
		If virtualResOn
			If aspectRatioOn
				SetScissor 0, 0, DEVICE_WIDTH , DEVICE_HEIGHT
			End
			PopMatrix
		End
		
		currentScreen.ExtraRender()
		If screenFade.active Then screenFade.Render()
		currentScreen.DebugRender()
		If debugOn
			DrawDebug()
		End
		If drawFPSOn
			DrawFPS()
		End
		Return 0
	End
	
	Method ReadInputs:Void()
		If aspectRatioOn
			Local mouseOffsetX:Float = MouseX() - DEVICE_WIDTH * 0.5
			Local x:Float = (mouseOffsetX / multi) / 1 + (SCREEN_WIDTH * 0.5)
			mouseX = x
			Local mouseOffsetY:Float = MouseY() - DEVICE_HEIGHT * 0.5
			Local y:Float = (mouseOffsetY / multi) / 1 + (SCREEN_HEIGHT * 0.5)
			mouseY = y
		Else
			mouseX = MouseX() / SCREENX_RATIO
			mouseY = MouseY() / SCREENY_RATIO
		End
		mouseHit = MouseHit()
		inputCache.ReadInput()
		inputCache.HandleEvents(currentScreen)
		
		If debugKeyOn
			If KeyHit(debugKey)
				debugOn = Not debugOn
			End
		End
	End
	
	Method OnUpdate:Int()
		ReadInputs()
	
		OverrideUpdate()
		If useFixedRateLogic
			Local now:Int = Millisecs()
			If now < lastTime
				numTicks = lastNumTicks
			Else
				tmpMs = now - lastTime
				If tmpMs > maxMs tmpMs = maxMs
				numTicks = tmpMs / ms
			Endif
		
			lastTime = now
			lastNumTicks = numTicks
			For Local i:Int = 1 To Floor(numTicks)
				Update(1)
			Next
			
			' Monkey's MOD doesnt work with floats
			Local re:Float = RealMod(numTicks, 1)
			If re > 0 Then
				Update(re)
			End
		Else
			Update(0)
		End

		Return 0
	End
	
	Method OverrideUpdate:Void()
	End

	Method Update:Void(fixedRateLogicDelta:Float)
		dt.UpdateDelta()
		If useFixedRateLogic
			dt.delta = fixedRateLogicDelta
		End

		If screenFade.active Then screenFade.Update()
		currentScreen.Update()	
	End

	Method DrawDebug:Void()
		SetColor 255, 255, 255
		FPSCounter.Draw(0,0)
		Local y:Int = 10
		Local gap:Int = 10
		DrawText "Screen             = "+currentScreen.name, 0, y
		y += gap
		DrawText "Delta              = "+FormatNumber(dt.delta, 2) , 0, y
		y += gap
		DrawText "Frame Time         = "+dt.frametime , 0, y		
		y += gap
		DrawText "Screen Width       = "+SCREEN_WIDTH, 0, y
		y += gap
		DrawText "Screen Height      = "+SCREEN_HEIGHT, 0, y
		y += gap
		DrawText "VMouseX            = "+Self.mouseX, 0, y
		y += gap
		DrawText "VMouseY            = "+Self.mouseY, 0, y
		y += gap
		DrawText "MouseX             = "+MouseX(), 0, y
		y += gap
		DrawText "MouseY             = "+MouseY(), 0, y
		y += gap
		DrawText "Music File         = "+musicFile, 0, y
		y += gap
		DrawText "MusicOkay          = "+musicOkay, 0, y
		y += gap
		DrawText "Music State        = "+MusicState(), 0, y
		y += gap
		DrawText "Music Volume       = "+Self.musicVolume, 0, y
		y += gap
		DrawText "Mojo Music Volume  = "+Self.mojoMusicVolume, 0, y
		y += gap
		DrawText "Sound Volume       = "+Self.soundVolume, 0, y
		y += gap
		DrawText "Sound Channel      = "+SoundPlayer.channel, 0, y
		y += gap
	End
	
	Method DrawFPS:Void()
		DrawText FPSCounter.totalFPS, 0, 0
	End
	
	Method MusicPlay:Void(file:String, flags:Int=1)
		musicFile = file
		
		musicOkay = PlayMusic("music/"+musicFile, flags)
		If musicOkay = -1
			Print "Error Playing Music - Music must be in the data\music folder"
		End
	End
	
	Method MusicSetVolume:Void(volume:Int)
		If volume < 0 Then volume = 0
		If volume > 100 Then volume = 100
		Self.musicVolume = volume
		SetMojoMusicVolume(musicVolume/100.0)
	End
	
	Method SetMojoMusicVolume:Void(volume:Float)
		If volume < 0 Then volume = 0
		If volume > 1 Then volume = 1
		mojoMusicVolume = volume
		SetMusicVolume(mojoMusicVolume)
	End
	
	Method SoundSetVolume:Void(volume:Int)
		If volume < 0 Then volume = 0
		If volume > 100 Then volume = 100
		Self.soundVolume = volume
		For Local i% = 0 To SoundPlayer.MAX_CHANNELS
			SetChannelVolume(i, game.soundVolume / 100.0)
		Next
	End
	
	Method CalcAnimLength:Float(ms:Int)
		Return ms / (1000.0 / FPS)
	End
	
	Method UseFixedRateLogic:Bool() Property
		Return Self.useFixedRateLogic
	End
	
	Method UseFixedRateLogic:Void(useFrl:Bool) Property
		Self.useFixedRateLogic = useFrl
		ResetFixedRateLogic()
	End
	
	Method ResetFixedRateLogic:Void()
		ms = 1000 / frameRate
		numTicks = 0
		lastNumTicks = 1
		lastTime = Millisecs()
		If dt <> Null
			dt.delta = 1
		End
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
			' set the music volume to zero if fading in the music
			If Self.fadeMusic
				game.SetMojoMusicVolume(0)
			End			
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
			game.SetMojoMusicVolume((ratio) * (game.musicVolume / 100.0))
		End
		If counter > fadeTime
			active = False
			If fadeOut			
				game.currentScreen.PostFadeOut()
			Else
				game.currentScreen.PostFadeIn()
			End
		End
	End
		
	Method CalcRatio:Void()
		ratio = counter/fadeTime
		If ratio < 0
			ratio = 0
			If fadeMusic
				game.SetMojoMusicVolume(0)
			End
		End
		If ratio > 1
			ratio = 1
			If fadeMusic
				game.SetMojoMusicVolume(game.musicVolume / 100.0)
			End
		End
		If fadeOut Then
			ratio = 1 - ratio
		End
	End
	
	Method Render:Void()
		If Not active Return
		SetAlpha 1 - ratio
		SetColor 0, 0, 0
		DrawRect 0, 0, DEVICE_WIDTH, DEVICE_HEIGHT
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
		game.currentScreen = Self
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
	
	Method DebugRender:Void()
	End
	
	' fired when you first touch the screen
	Method OnTouchHit:Void(x:Int, y:Int, pointer:Int)
	End
	
	' fired when you release a finger from the screen
	Method OnTouchReleased:Void(x:Int, y:Int, pointer:Int)
	End
	
	' fired when one of your fingers drags along the screen
	Method OnTouchDragged:Void(x:Int, y:Int, dx:Int, dy:Int, pointer:Int)
	End
	
	Method OnTouchClick:Void(x:Int, y:Int, pointer:Int)
	End
  
	' fired if you touch the screen and hold the finger in the same position for one second (configurable using game.inputCache.LongPressTime)
	' this is checked at a specific time after touching the screen, so if you move your finger around and then
	' hold it still, it won't fire
	Method OnTouchLongPress:Void(x:Int, y:Int, pointer:Int)
	End

	' fired after you release a finger from the screen, if it was moving fast enough (configurable using game.inputCache.FlingThreshold)
	' velocityx/y/speed is in pixels per second, but speed is taken from the entire vector, by pythagoras
	' ie. velocitySpeed = Sqrt(velocityX*velocityX + velocityY*velocityY) in pixels per second
	Method OnTouchFling:Void(releaseX:Int, releaseY:Int, velocityX:Float, velocityY:Float, velocitySpeed:Float, pointer:Int)
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
	
	Method Load:GameImage(name:String, nameoverride:String = "", midhandle:Bool=True, ignoreCache:Bool=False)
		' check if we already have the image in the bank!
		Local storeKey:String = nameoverride.ToUpper()
		If storeKey = "" Then storeKey = StripAll(name.ToUpper())
		If Not ignoreCache And Self.Contains(storeKey) Then Return Self.Get(storeKey)
		
		' discard the old image if it's there
		If Self.Contains(storeKey) Then Self.Get(storeKey).image.Discard()
		
		Local i:GameImage = New GameImage
		i.Load(path + name, midhandle)
		i.name = storeKey
		Self.Set(i.name, i)
		Return i
	End
	
	Method LoadAnim:GameImage(name:String, w%, h%, total%, tmpImage:Image, midhandle:Bool=True, ignoreCache:Bool=False, nameoverride:String = "")
		' check if we already have the image in the bank!
		Local storeKey:String = nameoverride.ToUpper()
		If storeKey = "" Then storeKey = StripAll(name.ToUpper())
		If Not ignoreCache And Self.Contains(storeKey) Then Return Self.Get(storeKey)
		
		' discard the old image if it's there
		If Self.Contains(storeKey) Then Self.Get(storeKey).image.Discard()
		
		Local i:GameImage = New GameImage
		i.LoadAnim(path + name, w, h, total, tmpImage, midhandle)
		i.name = storeKey
		Self.Set(i.name, i)
		Return i
	End
   
	Method LoadTileset:GameImage(name:String, tileWidth%, tileHeight%, tileMargin% = 0, tileSpacing% = 0, nameoverride:String = "", midhandle:Bool=False, ignoreCache:Bool=False)
		' check if we already have the image in the bank!
		Local storeKey:String = nameoverride.ToUpper()
		If storeKey = "" Then storeKey = StripAll(name.ToUpper())
		If Not ignoreCache And Self.Contains(storeKey) Then Return Self.Get(storeKey)
		
		' discard the old image if it's there
		If Self.Contains(storeKey) Then Self.Get(storeKey).image.Discard()
		
		' load the new one
		Local i:GameImage = New GameImage
		i.LoadTileset(path + name, tileWidth, tileHeight, tileMargin, tileSpacing, midhandle)
		i.name = storeKey
		Self.Set(i.name, i)
		Return i
	End
	
	Method Find:GameImage(name:String)
		name = name.ToUpper()

		' debug: print all keys in the map
	'	For Local key:String = EachIn self.Keys()
	'		Print key + " is stored in the map."
	'	Next
	   	
		Local i:GameImage = Self.Get(name)
		AssertNotNull(i, "Image '" + name + "' not found in the ImageBank")
		Return i
	End
	
	Method PreCache:Void()
		Local gi:GameImage
		For Local key:String = Eachin Self.Keys()
			gi = Self.Get(key)
			gi.PreCache()
		Next
	End
	
End

Class GameImage
	Field name:String
	Field image:Image
	Field w:Int
	Field h:Int
	Field w2:Float
	Field h2:Float
	Field midhandled:Int = 0
	
	Field leftMargin:Int = 0
	Field rightMargin:Int = 0
	Field topMargin:Int = 0
	Field bottomMargin:Int = 0
	
	Field tileWidth:Int, tileHeight:Int
	Field tileCountX:Int, tileCountY:Int
	Field tileCount:Int
	Field tileSpacing:Int, tileMargin:Int
	
	Method Load:Void(file$, midhandle:Bool=True)
		name = StripAll(file.ToUpper())
		image = LoadBitmap(file)	
		CalcSize()
		MidHandle(midhandle)
	End
	
	Method LoadAnim:Void(file:String, w:Int, h:Int, total%, tmpImage:Image, midhandle:Bool=True)
		name = StripAll(file.ToUpper())
		image = LoadAnimBitmap(file, w, h, total, tmpImage)	
		CalcSize()
		MidHandle(midhandle)
	End
	
	Method LoadTileset:Void(file:String, tileWidth:Int, tileHeight:Int, tileMargin:Int = 0, tileSpacing:Int = 0, midhandle:Bool=False)
		Load(file, midhandle)
		Self.tileWidth = tileWidth
		Self.tileHeight = tileHeight
		Self.tileMargin = tileMargin
		Self.tileSpacing = tileSpacing
		tileCountX = (w - tileMargin) / (tileWidth + tileSpacing)
		tileCountY = (h - tileMargin) / (tileHeight + tileSpacing)
		tileCount = tileCountX * tileCountY
	End
	
	Method CalcSize:Void()
		If image <> Null Then
			w = image.Width()
			h = image.Height()
			w2 = w/2
			h2 = h/2
		End
	End
	
	Method MidHandle:Void(midhandle:Bool) Property
		If midhandle Then
			image.SetHandle(w2, h2)
			Self.midhandled=1
		Else
			image.SetHandle(0, 0)
			Self.midhandled=0
		End 
	End
	
	Method SetHandle:Void(handleX:Float, handleY:Float)
		image.SetHandle(handleX, handleY)
	End
	
	Method MidHandle:Bool() Property
		Return Self.midhandled = 1
	End
	
	Method Draw:Void(x:Float, y:Float, rotation:Float = 0, scaleX:Float = 1, scaleY:Float = 1, frame:Int = 0)
		DrawImage(Self.image, x, y, rotation, scaleX, scaleY, frame)
	End
	
	Method DrawSubImage:Void(destX:Float, destY:Float, srcX:Int, srcY:Int, srcWidth:Int, srcHeight:Int, rotation:Float = 0, scaleX:Float = 1, scaleY:Float = 1, frame:Int = 0)
		DrawImageRect(Self.image, destX, destY, srcX, srcY, srcWidth, srcHeight, rotation, scaleX, scaleY, frame)
	End
	
	Method DrawTile:Void(x:Float, y:Float, tile:Int = 0, rotation:Float = 0, scaleX:Float = 1, scaleY:Float = 1)
		Local srcX% = tileMargin + (tileWidth + tileSpacing) * (tile Mod tileCountX)
		Local srcY% = tileMargin + (tileHeight + tileSpacing) * (tile / tileCountX)
		DrawImageRect(Self.image, x, y, srcX, srcY, tileWidth, tileHeight, rotation, scaleX, scaleY)
	End
	
	Method DrawStretched:Void(destX:Float, destY:Float, destWidth:Float, destHeight:Float,
			rotation:Float = 0)', scaleX:Float = 1, scaleY:Float = 1, frame:Int = 0)
		' scales for stretching
		Local stretchScaleX:Float = destWidth / w
		Local stretchScaleY:Float = destHeight / h
		DrawImage(Self.image, destX, destY, rotation, stretchScaleX, stretchScaleY)', frame)
	End
	
	Method DrawGrid:Void(x:Float, y:Float, rw:Float, rh:Float, frame:Int = 0)
		' draw top left corner
		DrawImageRect(Self.image, x, y, 0, 0, leftMargin, topMargin, frame)
		' draw top right corner
		DrawImageRect(Self.image, x+rw-rightMargin, y, w-rightMargin, 0, rightMargin, topMargin, frame)
		' draw bottom left corner
		DrawImageRect(Self.image, x, y+rh-bottomMargin, 0, h-bottomMargin, leftMargin, bottomMargin, frame)
		' draw bottom right corner
		DrawImageRect(Self.image, x+rw-rightMargin, y+rh-bottomMargin, w-rightMargin, h-bottomMargin, rightMargin, bottomMargin, frame)
		
		' work out how many horizontal and vertical tiles
		Local tileWidth% = (w-leftMargin-rightMargin)
		Local tileHeight% = (h-topMargin-bottomMargin)
		Local tileXCount% = (rw-leftMargin-rightMargin) / tileWidth
		Local tileYCount% = (rh-topMargin-bottomMargin) / tileHeight
		Local tileXOverflow% = (rw-leftMargin-rightMargin) Mod tileWidth
		Local tileYOverflow% = (rh-topMargin-bottomMargin) Mod tileHeight
		
		' tile top and bottom edges
		For Local i% = 0 Until tileXCount
			DrawImageRect(Self.image, leftMargin+i*tileWidth,0,leftMargin,0,tileWidth,topMargin,frame)
			DrawImageRect(Self.image, leftMargin+i*tileWidth,rh-bottomMargin,leftMargin,h-bottomMargin,tileWidth,bottomMargin,frame)
		Next
		If tileXOverflow > 0 Then
			DrawImageRect(Self.image, leftMargin+tileXCount*tileWidth,0,leftMargin,0,tileXOverflow,topMargin,frame)
			DrawImageRect(Self.image, leftMargin+tileXCount*tileWidth,rh-bottomMargin,leftMargin,h-bottomMargin,tileXOverflow,bottomMargin,frame)
		End
		
		' tile left and right edges
		For Local i% = 0 Until tileYCount
			DrawImageRect(Self.image, 0, topMargin+i*tileHeight,0,topMargin,leftMargin,tileHeight,frame)
			DrawImageRect(Self.image, rw-rightMargin,topMargin+i*tileHeight,w-rightMargin,topMargin,rightMargin,tileHeight,frame)
		Next
		If tileYOverflow > 0 Then
			DrawImageRect(Self.image, 0, topMargin+tileYCount*tileHeight,0,topMargin,leftMargin,tileYOverflow,frame)
			DrawImageRect(Self.image, rw-rightMargin,topMargin+tileYCount*tileHeight,w-rightMargin,topMargin,rightMargin,tileYOverflow,frame)
		End
		
		' tile centre
		' TODO
	End
	
	Method DrawSubStretched:Void(destX:Float, destY:Float, destWidth:Float, destHeight:Float, srcX:Int, srcY:Int, srcWidth:Int, srcHeight:Int,
			rotation:Float = 0)', scaleX:Float = 1, scaleY:Float = 1, frame:Int = 0)
		' scales for stretching
		Local stretchScaleX:Float = destWidth / srcWidth
		Local stretchScaleY:Float = destHeight / srcHeight
		DrawImageRect(Self.image, destX, destY, srcX, srcY, srcWidth, srcHeight, rotation, stretchScaleX, stretchScaleY)', frame)
	End
	
	' Yes, a crapload of parameters.  Thankfully most of them are optional, and this will usually only be called internally by the GUI.
	' TODO: apply scale to parameters
	Method DrawSubGrid:Void(x:Float, y:Float, width:Float, height:Float,
			srcX:Int, srcY:Int, srcWidth:Int, srcHeight:Int,
			leftMargin:Int, rightMargin:Int, topMargin:Int, bottomMargin:Int,
			'rotation:Float = 0, scaleX:Float = 1, scaleY:Float = 1,
			drawTopLeft:Bool = True, drawTop:Bool = True, drawTopRight:Bool = True,
			drawLeft:Bool = True, drawCenter:Bool = True, drawRight:Bool = True,
			drawBottomLeft:Bool = True, drawBottom:Bool = True, drawBottomRight:Bool = True)
		' draw the corners
		If drawTopLeft Then DrawImageRect(Self.image,
				x, y, srcX, srcY,
				leftMargin, topMargin)', rotation, scaleX, scaleY)
		If drawTopRight Then DrawImageRect(Self.image,
				x+width-rightMargin, y, srcX+srcWidth-rightMargin, srcY,
				rightMargin, topMargin)', rotation, scaleX, scaleY)
		If drawBottomLeft Then DrawImageRect(Self.image,
				x, y+height-bottomMargin, srcX, srcY+srcHeight-bottomMargin,
				leftMargin, bottomMargin)', rotation, scaleX, scaleY)
		If drawBottomRight Then DrawImageRect(Self.image,
				x+width-rightMargin, y+height-bottomMargin, srcX+srcWidth-rightMargin, srcY+srcHeight-bottomMargin,
				rightMargin, bottomMargin)', rotation, scaleX, scaleY)
		
		' scales for stretching
		Local stretchScaleX:Float = (width-leftMargin-rightMargin) / (srcWidth-leftMargin-rightMargin)
		Local stretchScaleY:Float = (height-topMargin-bottomMargin) / (srcHeight-topMargin-bottomMargin)
		
		' draw edges
		If drawLeft Then DrawImageRect(Self.image,
				x, y+topMargin, srcX, srcY+topMargin,
				leftMargin, srcHeight-topMargin-bottomMargin,
				0, 1, stretchScaleY)
		If drawRight Then DrawImageRect(Self.image,
				x+width-rightMargin, y+topMargin, srcX+srcWidth-rightMargin, srcY+topMargin,
				rightMargin, srcHeight-topMargin-bottomMargin,
				0, 1, stretchScaleY)
		If drawTop Then DrawImageRect(Self.image,
				x+leftMargin, y, srcX+leftMargin, srcY,
				srcWidth-leftMargin-rightMargin, topMargin,
				0, stretchScaleX, 1)
		If drawBottom Then DrawImageRect(Self.image,
				x+leftMargin, y+height-bottomMargin, srcX+leftMargin, srcY+srcHeight-bottomMargin,
				srcWidth-leftMargin-rightMargin, bottomMargin,
				0, stretchScaleX, 1)
		
		' draw center
		If drawCenter Then DrawImageRect(Self.image,
				x+leftMargin, y+topMargin, srcX+leftMargin, srcY+topMargin,
				srcWidth-leftMargin-rightMargin, srcHeight-topMargin-bottomMargin,
				0, stretchScaleX, stretchScaleY)
	End
	
	Method PreCache:Void()
		DrawImage Self.image, -Self.w-50, -Self.h-50
	End
End


Class SoundBank Extends StringMap<GameSound>
	
	Global path$ = "sounds/"
	
	Method Load:GameSound(name:String, nameoverride:String = "", ignoreCache:Bool = False)
		' check if we already have the sound in the bank!
		Local storeKey:String = nameoverride.ToUpper()
		If storeKey = "" Then storeKey = StripAll(name.ToUpper())
		If Not ignoreCache And Self.Contains(storeKey) Then Return Self.Get(storeKey)
		
		' discard the old sound if it's there
		If Self.Contains(storeKey) Then Self.Get(storeKey).sound.Discard()
		
		Local s:GameSound = New GameSound
		s.Load(name)
		s.name = storeKey
		Self.Set(s.name, s)
		Return s
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
	Field name:String
	Field sound:Sound
	Field rate:Float = 1
	Field pan:Float = 0
	Field volume:Float = 1
	Field loop:Int = 0
	Field channel:Int
	Field loopChannelList:IntArrayList = New IntArrayList
	
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
	
	Method Play:Void(playChannel:Int = -1)
		channel = SoundPlayer.PlayFx(sound, pan, rate, volume * (game.soundVolume / 100.0), loop, playChannel)
		If loop = 1
			loopChannelList.Add(channel)
		End
	End
	
	Method Stop:Void()
		SoundPlayer.PlayerStopChannel(channel)
		If loopChannelList.Size > 0
			Local ch:Int
			For Local i:Int = 0 Until loopChannelList.Size
				ch = loopChannelList.GetInt(i)
				SoundPlayer.PlayerStopChannel(ch)
			Next
			loopChannelList.Clear()
		End
	End

	Method IsPlaying:Int()
		#if TARGET="flash"
			Return 0
		#end
		Return(ChannelState(channel))
	End
End

Class SoundPlayer
	Global channel:Int
	Const MAX_CHANNELS:Int = 31
	Global playerChannelState:Int[] = [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ] ' 32 indexes - (0 to 31)
	
	Function StopChannels:Void()
		For Local i:Int = 0 To MAX_CHANNELS
			StopChannel(i)
			playerChannelState[i] = 0
		Next
	End
	
	Function PlayerStopChannel:Void(playerChannel:Int)
		StopChannel(playerChannel)
		playerChannelState[playerChannel] = 0
	End
	
	Function PlayFx:Int(s:Sound, pan:Float=0, rate:Float=1, volume:Float=1, loop:Int = 0, playChannel:Int = -1)
		If playChannel = -1
			Local cnt:Int = 0
			channel += 1
			If (channel > MAX_CHANNELS) Then channel = 0
			While playerChannelState[channel] = 1 ' channel State doesnt work with Flash
				channel += 1
				If (channel > MAX_CHANNELS) Then channel = 0
				cnt=+1
				If cnt > MAX_CHANNELS * 2 Then Exit ' stop infinite loop if case all channels are playing
			Wend
		Else
			channel = playChannel
			playerChannelState[playChannel] = 0
		End

		StopChannel(channel)
		PlaySound(s, channel, loop)
		SetChannelPan(channel, pan)
		SetChannelRate(channel, rate)
		SetChannelVolume(channel, volume)
		If loop
			playerChannelState[channel] = 1		
		End
		Return channel
	End
	
End

Class Sprite
	Field name$
	Field visible?
	Field x:Float, y:Float
	Field ox:Float, oy:Float
	Field dx:Float, dy:Float
	Field speedX:Float, speedY:Float, speed:Float
	Field maxXSpeed:Float, maxYSpeed:Float
	Field image:GameImage
	Field scaleX:Float = 1, scaleY:Float = 1

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
	Field reverse:Bool = False
	Field pingPong:Bool = False
	Field loop:Bool = True
	Field ping:Int
	
	' Scale
	Field scaleCounter:Float = 0
	Field scaleXSpeed:Float = 0.1
	Field scaleYSpeed:Float = 0.1
	Field ygravity:Float
	Field maxFrame:Int
	
	' Rotation
	Field rotationCounter:Float = 0
	Field rotationLength:Int = 1000
	Field rotationLoop:Int = 0
	Field rotation:Float
	Field rotationSpeed:Float = 1
	
	Method New(img:GameImage, x:Float, y:Float)
		Self.image = img
		Self.x = x
		Self.y = y
		Self.alpha = 1
		Self.SetHitBox(-img.w2, -img.h2, img.w, img.h)
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
	
	Method SetRGB:Void(r:Int, g:Int ,b:Int)
		Self.red = r
		Self.green = g
		Self.blue = b
	End
	
	Method SetScaleXY:Void(sx:Float, sy:Float)
		Self.scaleX = sx
		Self.scaleY = sy
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

		Move()
	End

	Method SetFrame:Void(startFrame:Int=0, endFrame:Int=0, speed:Int=125, pingPong:Bool = False, loop:Bool = True)
		frame = startFrame
		frameStart = startFrame
		frameEnd = endFrame
		If startFrame > endFrame
			reverse = True
		Else
			reverse = False
		End
		Self.pingPong = pingPong
		Self.loop = loop
		frameSpeed = speed
		frameTimer = Millisecs()
		ping = 0
	End
	
	Method UpdateAnimation:Void()
		If frameSpeed > 0
			If Millisecs() > frameTimer + frameSpeed
				If Not reverse
					frame+=1
					If frame > frameEnd
						ResetAnim()
					End
				Else
					frame-=1
					If frame < frameEnd
						ResetAnim()
					End			
				End
				frameTimer = Millisecs()
			End	
		End
	End
	
	Method ResetAnim:Void()
		If loop Then
			If pingPong
				reverse = Not reverse
				frame = frameEnd
				Local ts% = frameStart
				frameStart = frameEnd
				frameEnd = ts
			Else
				frame = frameStart
			End
		Else
			If pingPong And ping <1
				reverse = Not reverse
				frame = frameEnd
				Local ts% = frameStart
				frameStart = frameEnd
				frameEnd = ts
				ping+=1
			Else
				frame = frameEnd
			End
		End
	End
	
	Method Draw:Void()
		Draw(0,0)
	End
	
	Method Draw:Void(rounded:Bool)
		Draw(0,0, rounded)
	End
	
	Method Draw:Void(offsetx:Float = 0, offsety:Float = 0, rounded:Bool = False)
		If x - offsetx + image.w < 0 Or x - offsetx - image.w >= SCREEN_WIDTH Or y - offsety + image.h < 0 Or y - offsety - image.h >= SCREEN_HEIGHT Then Return
		If Self.alpha > 1 Then Self.alpha = 1
		If Self.alpha < 0 Then Self.alpha = 0
		SetAlpha Self.alpha
		SetColor red, green, blue
		If rounded
			DrawImage(image.image, Floor(x - offsetx + 0.5), Floor(y- offsety + 0.5), rotation, scaleX, scaleY, frame)
		Else
			DrawImage(image.image, x - offsetx, y - offsety, rotation, scaleX, scaleY, frame)
		End
		
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
	Global MAX_PARTICLES:Int = 800
	Global particles:Particle[MAX_PARTICLES]
	Global lastDeath:Int = 0
	Global maxIndex:Int = -1
	Global minIndex:Int = -1
	Global particleCount:Int = 0
	Field lifeCounter:Float = 0
	Field fadeIn:Float = 0
	Field fadeCounter:Float
	Field fadeInLength:Float = 0
	Field fadeLength:Float = 0
	Field active:Int = 0
	
	Function Cache:Void()
		For Local i:Int = 0 To MAX_PARTICLES - 1
			particles[i] = New Particle()
		Next
	End
	
	Function Create:Particle(gi:GameImage, x:Float, y:Float, dx:Float = 0, dy:Float = 0, gravity:Float = 0, fadeLength:Float = 0, lifeCounter:Int = 0)
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
		For Local i:Int = 0 To MAX_PARTICLES - 1
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
		For Local i% = minIndex To maxIndex
			If particles[i] <> Null And particles[i].image <> Null
				If particles[i].fadeCounter > 0 And particles[i].active Then
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
		Local newMinIndex:Int = -1
		Local newMaxIndex:Int = -1
		For Local i:Int = minIndex To maxIndex
			If particles[i] <> Null And particles[i].image <> Null
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
		Elseif fadeCounter>0 Then
			fadeCounter-=dt.delta
			If fadeCounter <= 0 Then
				alpha = 0
				active = 0
			End 
		End
	End
	
End
