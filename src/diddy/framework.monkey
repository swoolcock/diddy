#Rem
Copyright (c) 2011 Steve Revill and Shane Woolcock
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#End

#rem
Header: The Screen-Based Diddy Game Framework
This framework allows developers to quickly build screens and move between them quickly.
Also included are image and sound resource managers, a delta timer, sprite and particle classes.
Example of how to set up the DiddyApp:
[code]
Strict

Import diddy

Function Main:Int()
	New MyGame()
	Return 0
End

Global titleScreen:TitleScreen

Class MyGame extends DiddyApp
	Method Create:Void()
		titleScreen = New TitleScreen
		Start(titleScreen)
	End
End

Class TitleScreen Extends Screen
	Method New()
		name = "Title"
	End
	
	Method Start:Void()
		' Load and set up items here
	End
	
	Method Render:Void()
		Cls
		DrawText "TITLE SCREEN!", SCREEN_WIDTH2, SCREEN_HEIGHT2, 0.5, 0.5
		DrawText "Escape to Quit!", SCREEN_WIDTH2, SCREEN_HEIGHT2 + 40, 0.5, 0.5
	End
	
	Method Update:Void()
		If KeyHit(KEY_ESCAPE)
			' fading to Null is the same as fading to diddyGame.exitScreen (which exits the game)
			FadeToScreen(Null)
		End
	End
End
[/code]
#End
Strict

#DIDDY_FRAMEWORK=True

Import brl.json
Import mojo
Import diddy.functions
Import diddy.containers
Import diddy.inputcache
Import diddy.xml
Import diddy.diddydata
Import diddy.math
Import diddy.tween
Import diddy.tile.source

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
Global diddyGame:DiddyApp

' Used for delta timing movement
Global dt:DeltaTimer

' Default fade time
Global defaultFadeTime:Float = 600

'Summary: The main class extends Mojo App
Class DiddyApp Extends App

	Field debugKeyOn:Bool = False
	Field debugOn:Bool = False
	Field drawFPSOn:Bool = False
	Field debugKey:Int = KEY_F1
	
	Field virtualResOn:Bool = True
	Field aspectRatioOn:Bool = False
	Field autoCls:Bool = False

	Field aspectRatio:Float
	Field multi:Float
	Field widthBorder:Float				' Size of border at sides
	Field heightBorder:Float			' Size of border at top/bottom
	
	Field deviceChanged:Int				' Device size changed
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
	' loading Screen
	Field loadingScreen:LoadingScreen
	' used for fading
	Field screenFade:ScreenFade
	' scroll
	Field scrollX:Float
	Field scrollY:Float
	
	' mouse
	Field mouseX:Int, mouseY:Int
	Field mouseHit:Int
	Field diddyMouse:DiddyMouse
	
	' store the images here
	Field images:ImageBank
	' store the sounds here
	Field sounds:SoundBank
	' store screens
	Field screens:Screens
	
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
	
	Field diddyData:DiddyData
	Field localeLanguage:String = "en"
	Field localeCountry:String = "US"
Private
	Field useFixedRateLogic:Bool = False
	Field vsx:Float, vsy:Float, vsw:Float, vsh:Float
	
Public
	Method New()
		' DiddyApp now assigns itself to game, so you just need to do: New MyGame()
		' Assigning it manually will have no effect, but won't break anything.
		diddyGame = Self
		Self.screens = New Screens
		Self.exitScreen = New ExitScreen
		Self.loadingScreen = New LoadingScreen
		Self.screenFade = New ScreenFade
		Self.images = New ImageBank
		Self.sounds = New SoundBank
		Self.inputCache = New InputCache
		tilesetSource = Self.images
		diddyMouse = New DiddyMouse
	End
	
	Method SetFPS:Void(amount:Int)
		FPS = amount
		dt.targetfps = FPS
		dt.lastticks = Millisecs()
		SetUpdateRate(FPS)
	End
		
	Method OnCreate:Int()
		Try
			' Store the device width and height
			DEVICE_WIDTH = DeviceWidth()
			DEVICE_HEIGHT = DeviceHeight()
			
			SetScreenSize(DEVICE_WIDTH, DEVICE_HEIGHT)
			deviceChanged = True
			
			' initialize MouseZ
			MouseZInit()
			
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
			SetLocale(localeLanguage, localeCountry)
			'call Create
			Create()
		Catch e:DiddyException
			Print(e.ToString(True))
			Error(e.ToString(False))
		End
		Return 0
	End
	
	'summary: Main creation method
	Method Create:Void()
	End
	
	'summary: Sets up the virtual resolution
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
		If DeviceWidth() <> SCREEN_WIDTH Or DeviceHeight() <> SCREEN_HEIGHT Then
			deviceChanged = True
		End
	End

	Method PerformVirtualResolution:Void()
		If virtualResOn
			PushMatrix
			If aspectRatioOn
				If (DeviceWidth() <> DEVICE_WIDTH) Or (DeviceHeight() <> DEVICE_HEIGHT) Or deviceChanged
					DEVICE_WIDTH = DeviceWidth()
					DEVICE_HEIGHT = DeviceHeight()
					deviceChanged = False
	
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
	End
	
	Method OnRender:Int()
		Try
			FPSCounter.Update()
			PerformVirtualResolution()
			
			' auto cls
			If autoCls Then Cls()
			
			' render the screen
			If currentScreen Then
				currentScreen.RenderBackgroundLayers()
				currentScreen.Render()
				currentScreen.RenderForegroundLayers()
			End
			
			If virtualResOn
				If aspectRatioOn
					SetScissor 0, 0, DEVICE_WIDTH , DEVICE_HEIGHT
				End
				PopMatrix
			End
			
			If currentScreen
				currentScreen.ExtraRender()
				If screenFade.active Then screenFade.Render()
				currentScreen.DebugRender()
			End
			
			If debugOn
				DrawDebug()
			End

			If drawFPSOn
				DrawFPS()
			End
			diddyMouse.Update()
		Catch e:DiddyException
			Print(e.ToString(True))
			Error(e.ToString(False))
		End
		Return 0
	End

	Method ReadInputs:Void()
		If aspectRatioOn
			Local mouseOffsetX:Float = MouseX() - DEVICE_WIDTH * 0.5
			Local x:Float = (mouseOffsetX / multi) / 1 + (SCREEN_WIDTH * 0.5)
			mouseX = x
			Local mouseOffsetY:Float = MouseY() -DEVICE_HEIGHT * 0.5
			Local y:Float = (mouseOffsetY / multi) / 1 + (SCREEN_HEIGHT * 0.5)
			mouseY = y
		Else
			mouseX = MouseX() / SCREENX_RATIO
			mouseY = MouseY() / SCREENY_RATIO
		End
		
		If inputCache.monitorTouch
			inputCache.ReadInput()
		Else
			mouseHit = MouseHit()
		End
		
		inputCache.HandleEvents(currentScreen)
		
		If debugKeyOn
			If KeyHit(debugKey)
				debugOn = Not debugOn
			End
		End
	End
	
	Method OnUpdate:Int()
		Try
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
				
				Local re:Float = numTicks Mod 1
				If re > 0 Then
					Update(re)
				End
			Else
				Update(0)
			End
		Catch e:DiddyException
			Print(e.ToString(True))
			Error(e.ToString(False))
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
		
		If TweenManager.DefaultManager Then TweenManager.DefaultManager.Update(dt.frametime*0.001)
		
		If screenFade.active Then
			screenFade.Update()
		End
		If currentScreen Then
			If Not screenFade.active Or (screenFade.allowScreenUpdate And screenFade.active) Then currentScreen.Update()
		End
	End

	'summary: Draws debug information
	Method DrawDebug:Void()
		SetColor 255, 255, 255
		FPSCounter.Draw(0,0)
		Local y:Int = 10
		Local gap:Int = 14
		If currentScreen
			DrawText "Screen             = "+currentScreen.name, 0, y
		Else
			DrawText "Screen             = null", 0, y
		End
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
		DrawText "Back Screen Name   = "+currentScreen.backScreenName, 0, y
		y += gap
	End
	
	'summary: Draws current FPS at 0,0
	Method DrawFPS:Void()
		Local oldcolor:Float[] = GetColor()
		SetColor(255, 255, 255)
		DrawText FPSCounter.totalFPS, 0, 0
		SetColor(oldcolor[0], oldcolor[1], oldcolor[2])
	End
	
	'summary: Wrapper for PlayMusic
	Method MusicPlay:Void(file:String, flags:Int=1)
		musicFile = file
		
		musicOkay = PlayMusic("music/"+musicFile, flags)
		If musicOkay = -1
			Print "Error Playing Music - Music must be in the data\music folder"
		End
	End
	
	'summary: Sets the Music volume
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
			SetChannelVolume(i, diddyGame.soundVolume / 100.0)
		Next
	End
	
	'summary: returns an animation length in game frames
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
	
	' convenience method that will trigger a fade in and call PreStart() on the screen (used for first screen)
	Method Start:Void(firstScreen:Screen, autoFadeIn:Bool = True, fadeInTime:Float = defaultFadeTime, fadeSound:Bool = False, fadeMusic:Bool = False)
		ResetDelta()
		firstScreen.autoFadeIn = autoFadeIn
		If autoFadeIn Then
			firstScreen.autoFadeInTime = fadeInTime
			firstScreen.autoFadeInSound = fadeSound
			firstScreen.autoFadeInMusic = fadeMusic
		End
		firstScreen.PreStart()
	End
	
	Method OnSuspend:Int()
		Try
			If currentScreen Then currentScreen.Suspend()
		Catch e:DiddyException
			Print(e.ToString(True))
			Error(e.ToString(False))
		End
		Return 0
	End

	Method OnResume:Int()
		Try
			SetLocale(localeLanguage, localeCountry)
			dt.currentticks = Millisecs()
			dt.lastticks = dt.currentticks
			If currentScreen Then currentScreen.Resume()
		Catch e:DiddyException
			Print(e.ToString(True))
			Error(e.ToString(False))
		End
		Return 0
	End
	
	Method OnBack:Int()
		Try
			If currentScreen Then currentScreen.Back()
		Catch e:DiddyException
			Print(e.ToString(True))
			Error(e.ToString(False))
		End
		Return 0
	End
	
	Method ResetDelta:Void()
		dt.currentticks = Millisecs()
		dt.lastticks = dt.currentticks
	End
	
	'summary: Loads in the diddydata xml file
	Method LoadDiddyData:Void(filename:String="diddydata.xml")
		autoCls = True
		diddyData = New DiddyData(filename)
	End
End


'summary: Map to store the Screens
Class Screens Extends StringMap<Screen>
	Method Set:Bool(key:String, value:Screen)
		Return Super.Set(key.ToUpper(), value)
	End
	
	Method Find:Screen(name:String)
		name = name.ToUpper()

		' debug: print all keys in the map
		If diddyGame.debugOn
			For Local key:String = Eachin Self.Keys()
				Print key + " is stored in the Screens map."
			Next
		End

		Local i:Screen = Self.Get(name)
		AssertNotNull(i, "Screen '" + name + "' not found in the Screens map")
		Return i
	End
End

'summary: Simple screen fading
Class ScreenFade
	Field fadeTime:Float
	Field fadeOut:Bool
	Field ratio:Float = 0
	Field active:Bool
	Field counter:Float
	Field fadeMusic:Bool
	Field fadeSound:Bool
	Field allowScreenUpdate:Bool = True
	
	Method Start:Void(fadeTime:Float, fadeOut:Bool, fadeSound:Bool = False, fadeMusic:Bool = False, allowScreenUpdate:Bool = True)
		If active Then Return
		diddyGame.ResetDelta()
		active = True
		Self.fadeTime = diddyGame.CalcAnimLength(fadeTime)
		Self.fadeOut = fadeOut
		Self.fadeMusic = fadeMusic
		Self.fadeSound = fadeSound
		Self.allowScreenUpdate = allowScreenUpdate
		If fadeOut Then
			ratio = 1
		Else
			ratio = 0
			' set the music volume to zero if fading in the music
			If Self.fadeMusic
				diddyGame.SetMojoMusicVolume(0)
			End			
		End
		counter = 0
	End

	Method Update:Void()
		If Not active Return
		counter += 1 * dt.delta
		CalcRatio()
		If fadeSound Then
			For Local i% = 0 To SoundPlayer.MAX_CHANNELS
				SetChannelVolume(i, (ratio) * (diddyGame.soundVolume / 100.0))
			Next
		End
		If fadeMusic Then
			diddyGame.SetMojoMusicVolume((ratio) * (diddyGame.musicVolume / 100.0))
		End
		If counter > fadeTime
			diddyGame.ResetDelta()
			active = False
			If fadeOut			
				diddyGame.currentScreen.PostFadeOut()
			Else
				diddyGame.currentScreen.PostFadeIn()
			End
		End
	End
		
	Method CalcRatio:Void()
		ratio = counter/fadeTime
		If ratio < 0
			ratio = 0
			If fadeMusic
				diddyGame.SetMojoMusicVolume(0)
			End
		End
		If ratio > 1
			ratio = 1
			If fadeMusic
				diddyGame.SetMojoMusicVolume(diddyGame.musicVolume / 100.0)
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

Class LoadingBar
	Field fullImage:Image
	Field emptyImage:Image
	Field x:Int, y:Int
	Field steps:Float
	Field stepSize:Float
	Field finished:Bool = False
	Field position:Float
	Field currentStep:Int

	Method SetSteps:Void(steps:Int)
		Self.steps = steps
		stepSize = fullImage.Width() / steps
	End

	Method Progress:Void()
		Print "Please use LoadingScreen.Progress!"
	End
	
	Method MoveBar:Void()
		currentStep = currentStep + 1
		DebugPrint "Loadingbar currentStep = " + currentStep
		position = currentStep * stepSize
		If position > fullImage.Width() Then position = fullImage.Width()
		If currentStep = steps Then finished = True
	End
	
	Method Draw:Void()
		DrawImage(emptyImage, x, y)
		DrawImageRect(fullImage, x, y, 0, 0, position, fullImage.Height())
	End
End

'summary: Simple DrawDelegate Class for the Loading Screen
Class LoadingScreenDelegate Abstract
	Method Load:Void()
	End
	
	Method Draw:Void()
	End
End

'summary: Screen to draw a loading screen
Class LoadingScreen Extends Screen
	Field finished:Bool
	Field destination:Screen
	Field loadingBar:LoadingBar
	Field image:Image
	Field loadingScreenDelegate:LoadingScreenDelegate
	Field rendering:Bool
	
	Method New()
		name = "loading"
		loadingBar = New LoadingBar
	End
	
	Method Init:Void(loadingScreenPath:String, loadingFullBarPath:String, loadingEmptyBarPath:String, steps:Int, loadingBarX:Int = -1, loadingBarY:Int = -1)
		image = LoadBitmap(loadingScreenPath, Image.MidHandle)
		If loadingBarX = -1 Then loadingBarX = SCREEN_WIDTH2
		If loadingBarY = -1 Then loadingBarY = SCREEN_HEIGHT2
		loadingBar.x = loadingBarX
		loadingBar.y = loadingBarY
		loadingBar.fullImage = LoadBitmap(loadingFullBarPath, Image.MidHandle)
		loadingBar.emptyImage = LoadBitmap(loadingEmptyBarPath, Image.MidHandle)
		loadingBar.SetSteps(steps)
		rendering = False
	End
	
	Method Start:Void()
		finished = False
		If destination = Null Then Error "Loading Screen Destination is null!"
	End
	
	Method Render:Void()
		Cls()
		If not diddyGame.screenFade.active Then rendering = True
		DrawImage image, SCREEN_WIDTH2, SCREEN_HEIGHT2
		loadingBar.Draw()
		If loadingScreenDelegate Then loadingScreenDelegate.Draw()
	End
	
	Method Progress:Void()
		loadingBar.MoveBar()
	End
	
	Method Update:Void()
		If loadingScreenDelegate And rendering Then loadingScreenDelegate.Load()
		If KeyHit(KEY_SPACE) Then
			loadingBar.Progress()
		End
		If loadingBar.finished
			FadeToScreen(destination)
		End
	End
End

'summary: Screen to exit the application
Class ExitScreen Extends Screen
	Method New()
		Super.New("exit")
	End
	
	Method Start:Void()
		ExitApp()
	End
	
	Method Render:Void()
		Cls()
		#If TARGET="win8"
			DrawText "Exit Screen - Cant exit a Win8 application", 100, 100
		#End
	End 
	
	Method Update:Void()
	End
End

'summary: Abstract Screen class
Class Screen Abstract
Private
	Field autoFadeIn:Bool = False
	Field autoFadeInTime:Float = 50
	Field autoFadeInSound:Bool = False
	Field autoFadeInMusic:Bool = False
	Field musicPath:String
	Field musicFlag:Int

Public
	Field name:String = ""
	Field backScreenName:String = ""
	Field layers:DiddyDataLayers
	Field destinationScreen:Screen
	Field active:Bool = False
	Field hiding:Bool = False
	' timer
	Field timer:Float
	Field timerSpeed:Float = 0.08
	Field alpha:Float = 0
	Field alphaText:Float = 0
	
	Method New(name:String="")
		Self.name = name
	End
	
	Method PreStart:Void()
		diddyGame.screens.Set(name, Self)
		diddyGame.currentScreen = Self
		Load()
		' load screens graphics
		For Local key:String = EachIn diddyGame.images.Keys()
			Local i:GameImage = diddyGame.images.Get(key)
			If i.preLoad And i.screenName.ToUpper() = name.ToUpper()
				If i.frames > 1
					i.LoadAnim(i.path, i.w, i.h, i.frames, Null, i.midhandle, i.readPixels, i.maskRed, i.maskGreen, i.maskBlue, False, i.screenName)
				Else
					i.Load(i.path, i.midhandle, i.readPixels, i.maskRed, i.maskGreen, i.maskBlue, False, i.screenName)
				End
			End
		Next
		
		' load screens sounds
		For Local key:String = EachIn diddyGame.sounds.Keys()
			Local i:GameSound = diddyGame.sounds.Get(key)
			If i.preLoad And i.screenName.ToUpper() = name.ToUpper()
				i.Load(i.path, False, i.screenName)
			End
		Next
		diddyGame.ResetDelta()
		
		If autoFadeIn Then
			autoFadeIn = False
			diddyGame.screenFade.Start(autoFadeInTime, False, autoFadeInSound, autoFadeInMusic, diddyGame.screenFade.allowScreenUpdate)
		End
		
		' play the screen's music if its set
		If musicPath <> "" Then diddyGame.MusicPlay(musicPath, musicFlag)
		Start()
	End
	
	Method RenderBackgroundLayers:Void()
		If layers Then
			For Local layer:DiddyDataLayer = EachIn layers
				If layer.index >= 0 Then Return
				layer.Render()
			Next
		End
	End
	
	Method RenderForegroundLayers:Void()
		If layers Then
			For Local layer:DiddyDataLayer = Eachin layers
				If layer.index >= 0 Then
					layer.Render()
				End
			Next
		End
	End
	
	Method Start:Void() Abstract
	
	Method Render:Void() Abstract
	
	Method Update:Void() Abstract
	
	Method Back:Void(fadeTime:Float = defaultFadeTime, fadeSound:Bool = False, fadeMusic:Bool = False, allowScreenUpdate:Bool = True)
		If backScreenName="exit" Then
			FadeToScreen(Null)
		ElseIf backScreenName Then
			Local scr:Screen = diddyGame.screens.Find(backScreenName)
			If scr Then FadeToScreen(scr, fadeTime, fadeSound, fadeMusic, allowScreenUpdate)
		End
	End
	
	Method Suspend:Void()
	End

	Method Resume:Void()
	End

	Method Load:Void()
	End
	
	Method PostFadeOut:Void()
		Kill()
		diddyGame.nextScreen.PreStart()
	End
	
	Method Kill:Void()
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
	
	' fired once if any key was hit (before OnKeyHit)
	Method OnAnyKeyHit:Void()
	End
	
	' fired for each key that was hit
	Method OnKeyHit:Void(key:Int)
	End
	
	' fired once if any key is down (before OnKeyDown)
	Method OnAnyKeyDown:Void()
	End
	
	' fired for each key that is down
	Method OnKeyDown:Void(key:Int)
	End
	
	' fired once if any key was released (before OnKeyReleased)
	Method OnAnyKeyReleased:Void()
	End
	
	' fired for each key that was released
	Method OnKeyReleased:Void(key:Int)
	End
	
	Method OnMouseHit:Void(x:Int, y:Int, button:Int)
	End
	
	Method OnMouseDown:Void(x:Int, y:Int, button:Int)
	End
	
	Method OnMouseReleased:Void(x:Int, y:Int, button:Int)
	End
	
	'summary: convenience method
	Method FadeToScreen:Void(screen:Screen, fadeTime:Float = defaultFadeTime, fadeSound:Bool = False, fadeMusic:Bool = False, allowScreenUpdate:Bool = True)
		' don't try to fade twice
		If diddyGame.screenFade.active Then Return
		
		' if the screen is null, assume we're exiting
		If Not screen Then screen = diddyGame.exitScreen
		
		' configure the autofade values
		screen.autoFadeIn = True
		screen.autoFadeInTime = fadeTime
		screen.autoFadeInSound = fadeSound
		screen.autoFadeInMusic = fadeMusic
		
		' trigger the fade out
		diddyGame.nextScreen = screen
		diddyGame.screenFade.Start(fadeTime, True, fadeSound, fadeMusic, allowScreenUpdate)
	End
	
	'summary: sets the screen's music which autoplays when the screen starts
	Method SetMusic:Void(path:String, flag:Int = 0)
		Self.musicPath = path
		Self.musicFlag = flag
	End
End

'summary: Simple Frames per second counter
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

'summary: DeltaTimer by James Boyd
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
		If delta > 5 Then
			If diddyGame.debugOn
				DebugPrint "WARNING DELTA GREATER THAN 5!!! Reseting it to 1"
			End
			delta = 1
		End
		lastticks = currentticks
	End
End

'summary: Image resource bank
'Images must be stored in graphics folder
Class ImageBank Extends StringMap<GameImage> Implements ITilesetSource
	Const ATLAS_PREFIX:String = "_diddyAtlas_"
	Const SPARROW_ATLAS:Int = 0
	Const LIBGDX_ATLAS:Int = 1
	Const JSON_HASH_ATLAS:Int = 2
	
	Field path:String = "graphics/"
	
	Method LoadAtlas:Void(fileName:String, format:Int = SPARROW_ATLAS, midHandle:Bool = True, readPixels:Bool = False, maskRed:Int = 0, maskGreen:Int = 0, maskBlue:Int = 0)
		If format = SPARROW_ATLAS
			LoadSparrowAtlas(fileName, midHandle, readPixels, maskRed, maskGreen, maskBlue)
		Elseif format = LIBGDX_ATLAS
			LoadLibGdxAtlas(fileName, midHandle, readPixels, maskRed, maskGreen, maskBlue)
		Elseif format = JSON_HASH_ATLAS
			LoadJsonAtlas(fileName, midHandle, readPixels, maskRed, maskGreen, maskBlue)
		Else
			Error "Invalid atlas format"
		End
	End
	
	Method LoadAtlasString:String(fileName:String)
		Local str:String = LoadString(path + fileName)
		' check to see if the file is valid
		AssertNotEqualInt(str.Length(), 0, "Error loading Atlas "+ path + fileName)
		Return str		
	End
	
	Method SaveAtlasToBank:String(pointer:Image, fileName:String)
		' save the whole atlas with prefix
		Local atlasGameImage:GameImage = New GameImage
		atlasGameImage.name = ATLAS_PREFIX + StripAll(fileName).ToUpper()
		atlasGameImage.image = pointer
		atlasGameImage.CalcSize()
		Self.Set(atlasGameImage.name, atlasGameImage)
		Return atlasGameImage.name
	End
	
	Method LoadLibGdxAtlas:Void(fileName:String, midHandle:Bool=True, readPixels:Bool = False, maskRed:Int = 0, maskGreen:Int = 0, maskBlue:Int = 0)
		Local str:String = LoadAtlasString(fileName)
		Local all:String[] = str.Split("~n")
		Local spriteFileName:String = all[0].Trim()
		Local pointer:Image = LoadImage(path + spriteFileName)
		AssertNotNull(pointer, "Error loading bitmap atlas "+ path + spriteFileName)
		Local atlasGameImageName:String = SaveAtlasToBank(pointer, fileName)
		
		Local line:String = ""
		Local i:Int = 4
		Local xy:String[] =["",""]
		Local debug:Bool = False
		While True
			' name of the image
			line = all[i].Trim()
			If debug Then DebugPrint "name = "+line
			If line = "" Then Exit
			Local name:String = line
			'rotate
			i+=1
			line = all[i].Trim()
			If debug Then DebugPrint "rotate = "+line
			Local rotate:String = line
			' x and y
			i+=1
			line = all[i].Trim()
			If debug Then DebugPrint "x and y = "+line
			xy = line[ (line.FindLast(":")+1)..].Split(",")
			Local x:Int = Int(xy[0].Trim())
			Local y:Int = Int(xy[1].Trim())
			' width and height
			i+=1
			line = all[i].Trim()
			If debug Then Print "width and height = "+line
			xy = line[ (line.FindLast(":")+1)..].Split(",")
			Local width:Int = Int(xy[0].Trim())
			Local height:Int = Int(xy[1].Trim())
			' origX and origY
			i+=1
			line = all[i].Trim()
			If debug Then Print "origX and origY = "+line
			xy = line[ (line.FindLast(":")+1)..].Split(",")
			Local origX:Int = Int(xy[0].Trim())
			Local origY:Int = Int(xy[1].Trim())
			' offsets
			i+=1
			line = all[i].Trim()
			If debug Then Print "offsets = "+line
			xy = line[ (line.FindLast(":")+1)..].Split(",")
			Local offsetX:Int = Int(xy[0].Trim())
			Local offsetY:Int = Int(xy[1].Trim())
			'index
			i+=1
			line = all[i].Trim()
			If debug Then Print "index = "+line
			Local index:Int = Int(line[ (line.FindLast(":") + 1) ..].Trim())
			i+=1
			Local gi:GameImage = New GameImage
			If index > - 1
				name += index
			End
			If debug
				DebugPrint "name    = " + name
				DebugPrint "x       = " + x
				DebugPrint "y       = " + y
				DebugPrint "width   = " + width
				DebugPrint "height  = " + height
				DebugPrint "origX   = " + origX
				DebugPrint "origY   = " + origY
				DebugPrint "offsetX = " + offsetX
				DebugPrint "offsetY = " + offsetY
				DebugPrint "index   = " + index
			End
			
			gi.name = name.ToUpper()
			gi.image = pointer.GrabImage(x, y, width, height)
			gi.CalcSize()
			gi.MidHandle(midHandle)
			
			gi.atlasName = atlasGameImageName
			gi.subX = x
			gi.subY = y
			gi.readPixels = readPixels
			gi.SetMaskColor(maskRed, maskGreen, maskBlue)
			
			Self.Set(gi.name, gi)
		Wend
		
	End
	
	Method LoadJsonAtlas:Void(fileName:String, midHandle:Bool=True, readPixels:Bool = False, maskRed:Int = 0, maskGreen:Int = 0, maskBlue:Int = 0)
		Local str:String = LoadAtlasString(fileName)
		' parse the json
		Local jso:JsonObject = New JsonObject(str)
		
		Local meta:JsonObject = JsonObject( jso.Get("meta") )
		Local image:JsonValue = meta.Get("image")
		Local spriteFileName:String = image.StringValue()
		
		Local pointer:Image = LoadImage(path + spriteFileName)
		AssertNotNull(pointer, "Error loading bitmap atlas "+ path + spriteFileName)
		
		Local atlasGameImageName:String = SaveAtlasToBank(pointer, fileName)
		
		Local sprs:JsonObject = JsonObject( jso.Get("frames") )
		For Local it:map.Node<String, JsonValue> = Eachin sprs.GetData()
			Local name:String = it.Key

			Local spr:JsonObject = JsonObject( it.Value )
			Local frame:JsonObject = JsonObject( spr.Get( "frame" ) )
			Local x:Int = frame.GetInt("x")
			Local y:Int = frame.GetInt("y")
			Local w:Int = frame.GetInt("w")
			Local h:Int = frame.GetInt("h")
			
			Local rotated:JsonValue = spr.Get( "rotated" )
			'TODO
			
			Local trimmed:JsonValue = spr.Get( "trimmed" )
			'TODO

			Local spriteSourceSize:JsonObject = JsonObject( spr.Get( "spriteSourceSize" ) )
			'TODO
			
			Local sourceSize:JsonObject = JsonObject( spr.Get( "sourceSize" ) )
			'TODO
			
			Local gi:GameImage = New GameImage
			gi.name = name.ToUpper()
			gi.image = pointer.GrabImage(x, y, w, h)
			gi.CalcSize()
			gi.MidHandle(midHandle)
			
			gi.atlasName = atlasGameImageName
			gi.subX = x
			gi.subY = y
			gi.readPixels = readPixels
			gi.SetMaskColor(maskRed, maskGreen, maskBlue)
			Self.Set(gi.name, gi)
		Next
	End
	
	Method LoadSparrowAtlas:Void(fileName:String, midHandle:Bool=True, readPixels:Bool = False, maskRed:Int = 0, maskGreen:Int = 0, maskBlue:Int = 0)
		Local str:String = LoadAtlasString(fileName)
		' parse the xml
		Local parser:XMLParser = New XMLParser
		Local doc:XMLDocument = parser.ParseString(str)
		Local rootElement:XMLElement = doc.Root
		Local spriteFileName:String = rootElement.GetAttribute("imagePath")
		
		Local pointer:Image = LoadImage(path + spriteFileName)
		AssertNotNull(pointer, "Error loading bitmap atlas "+ path + spriteFileName)
		
		Local atlasGameImageName:String = SaveAtlasToBank(pointer, fileName)
		
		For Local node:XMLElement = Eachin rootElement.GetChildrenByName("SubTexture")
			Local x:Int = Int(node.GetAttribute("x").Trim())
			Local y:Int = Int(node.GetAttribute("y").Trim())
			Local width:Int = Int(node.GetAttribute("width").Trim())
			Local height:Int = Int(node.GetAttribute("height").Trim())
			Local name:String = node.GetAttribute("name").Trim()

			Local gi:GameImage = New GameImage
			gi.name = name.ToUpper()
			gi.image = pointer.GrabImage(x, y, width, height)
			gi.CalcSize()
			gi.MidHandle(midHandle)
			
			gi.atlasName = atlasGameImageName
			gi.subX = x
			gi.subY = y
			gi.readPixels = readPixels
			gi.SetMaskColor(maskRed, maskGreen, maskBlue)
			Self.Set(gi.name, gi)
		Next
	End
	
	Method Load:GameImage(name:String, nameoverride:String = "", midhandle:Bool = True, ignoreCache:Bool = False, readPixels:Bool = False, maskRed:Int = 0, maskGreen:Int = 0, maskBlue:Int = 0, preLoad:Bool = False, screenName:String = "")
		' check if we already have the image in the bank!
		Local storeKey:String = nameoverride.ToUpper()
		If storeKey = "" Then storeKey = StripAll(name.ToUpper())
		If Not ignoreCache And Self.Contains(storeKey) Then Return Self.Get(storeKey)
		
		' discard the old image if it's there
		If Self.Contains(storeKey) Then Self.Get(storeKey).image.Discard()
		Local i:GameImage = New GameImage
		i.Load(path + name, midhandle, readPixels, maskRed, maskGreen, maskBlue, preLoad, screenName)
		i.name = storeKey
		Self.Set(i.name, i)
		Return i
	End
	
	Method LoadAnim:GameImage(name:String, w:Int, h:Int, total:Int, tmpImage:Image=Null, midhandle:Bool = True, ignoreCache:Bool = False, nameoverride:String = "", readPixels:Bool = False, maskRed:Int = 0, maskGreen:Int = 0, maskBlue:Int = 0, preLoad:Bool = False, screenName:String = "")
		' check if we already have the image in the bank!
		Local storeKey:String = nameoverride.ToUpper()
		If storeKey = "" Then storeKey = StripAll(name.ToUpper())
		If Not ignoreCache And Self.Contains(storeKey) Then Return Self.Get(storeKey)
		
		' discard the old image if it's there
		If Self.Contains(storeKey) Then Self.Get(storeKey).image.Discard()

		Local i:GameImage = New GameImage
		i.LoadAnim(path + name, w, h, total, tmpImage, midhandle, readPixels, maskRed, maskGreen, maskBlue, preLoad, screenName)
		i.name = storeKey
		Self.Set(i.name, i)
		Return i
	End
   
	Method LoadTileset:GameImage(name:String, tileWidth%, tileHeight%, tileMargin% = 0, tileSpacing% = 0, nameoverride:String = "", midhandle:Bool=False, ignoreCache:Bool=False, readPixels:Bool = False, maskRed:Int = 0, maskGreen:Int = 0, maskBlue:Int = 0)
		' check if we already have the image in the bank!
		Local storeKey:String = nameoverride.ToUpper()
		If storeKey = "" Then storeKey = StripAll(name.ToUpper())
		If Not ignoreCache And Self.Contains(storeKey) Then Return Self.Get(storeKey)
		
		' discard the old image if it's there
		If Self.Contains(storeKey) Then Self.Get(storeKey).image.Discard()
		
		' load the new one
		Local i:GameImage = New GameImage
		i.LoadTileset(path + name, tileWidth, tileHeight, tileMargin, tileSpacing, midhandle, readPixels, maskRed, maskGreen, maskBlue)
		i.name = storeKey
		Self.Set(i.name, i)
		Return i
	End
	
	Method LoadTilesetImage:ITilesetImage(name:String, tileWidth%, tileHeight%, tileMargin% = 0, tileSpacing% = 0, nameoverride:String = "", midhandle:Bool=False, ignoreCache:Bool=False, readPixels:Bool = False, maskRed:Int = 0, maskGreen:Int = 0, maskBlue:Int = 0)
		Return LoadTileset(name, tileWidth, tileHeight, tileMargin, tileSpacing, nameoverride, midhandle, ignoreCache, readPixels, maskRed, maskGreen, maskBlue)
	End
	
	Method Find:GameImage(name:String, ignoreError:Bool = False)
		name = name.ToUpper()

		' debug: print all keys in the map
		If diddyGame.debugOn
			For Local key:String = Eachin Self.Keys()
				Local i:GameImage = Self.Get(key)
				if Not i.preLoad Then
					Print key + " is stored in the image map."
				End
			Next
		End
		Local i:GameImage = Self.Get(name)
		If Not ignoreError
			AssertNotNull(i, "Image '" + name + "' not found in the ImageBank")
			If i.preLoad and i.image = Null Then AssertError("Image '" + name + "' not found in the ImageBank")
		End
		Return i
	End
	
	'summary: This returns an animation gameimage from an previous loaded Atas and adds it to the image bank.
	'So you get then just use Find to return the animation gameimage later.
	'name: The first image in the atlas
	'w,h: The width and height of the frames
	'frames: The number of frames to capture from the atlas
	'midhandle: Sets the midhandle of the image
	'nameoverride: If supplied, changes the stored name in the image bank
	Method FindSet:GameImage(name:String, w:Int, h:Int, frames:Int=0, midhandle:Bool = True, nameoverride:String = "")
		name = name.ToUpper()
		Local subImage:GameImage = Self.Get(name)
		AssertNotNull(subImage, "Image '" + name + "' not found in the ImageBank")
		Local atlasGameImage:GameImage = Self.Get(subImage.atlasName)
		AssertNotNull(atlasGameImage, "Atlas Image '" + name + "' not found in the ImageBank")
		Local image:Image = atlasGameImage.image.GrabImage(subImage.subX, subImage.subY, w, h, frames)
		
		Local gi:GameImage = New GameImage
		Local storeKey:String = nameoverride.ToUpper()
		If storeKey = "" Then storeKey = name.ToUpper()
		gi.name = storeKey
		gi.image = image
		gi.CalcSize()
		gi.MidHandle(midhandle)
		Return gi
	End
	
	Method PreCache:Void()
		Local gi:GameImage
		For Local key:String = Eachin Self.Keys()
			gi = Self.Get(key)
			gi.PreCache()
		Next
	End
	
	Method ReadPixelsArray:Void()
		Local gi:GameImage
		For Local key:String = Eachin Self.Keys()
			gi = Self.Get(key)
			gi.ReadPixelsArray()
		Next
	End
End

Class SpriteAnimationsMap Extends StringMap<SpriteAnimation>
		
	Method Find:SpriteAnimation(name:String)
		name = name.ToUpper()
		Local i:SpriteAnimation = Self.Get(name)
		AssertNotNull(i, "SpriteAnimation '" + name + "' not found in the SpriteAnimationsMap")
		Return i
	End
End

Class SpriteAnimation
	Field frames:GameImage[] = []
	Field frame:Int
	Field frameTimer:Int
	Field frameStart:Int
	Field frameEnd:Int
	Field frameSpeed:Int = 0 
	Field reverse:Bool = False
	Field pingPong:Bool = False
	Field loop:Bool = True
	Field ping:Int
	Field randomStartFrame:bool = False
	
	Method New(speed:Int = 125, pingPong:Bool = False, loop:Bool = True, randomStartFrame:Bool = False)
		frames = New GameImage[1]
		frameEnd = 0
		frameStart = 0
		Self.pingPong = pingPong
		Self.loop = loop
		Self.randomStartFrame = randomStartFrame
		frameSpeed = speed
		frameTimer = Millisecs()
		ping = 0
	End
	
	Method Add:Void(gi:GameImage)
		frameEnd = frameEnd + 1
		frames = frames.Resize(frameEnd + 1)
		frames[frameEnd - 1] = gi
		If randomStartFrame
			frame = Rand(0, frameEnd)
		End
	End
		
	'summary: Animation process, deals with changing frames. Returns 1 if the animation has finished (only for non looping animations).
	Method UpdateAnimation:Int()
		Local rv:Int = 0
		If frameSpeed > 0
			If Millisecs() > frameTimer + frameSpeed
				If Not reverse
					frame += 1
					If frame > frameEnd - 1
						rv = ResetAnim()
					End
				Else
					frame -= 1
					If frame < frameEnd
						rv = ResetAnim()
					End
				End
				frameTimer = Millisecs()
			End	
		End
		Return rv
	End
	
	Method ResetAnim:Int()
		If loop Then
			If pingPong
				If Not reverse
					frame = frameEnd - 1
				Else
					frame = frameEnd
				End
				reverse = Not reverse
				Local ts:Int = frameStart
				frameStart = frameEnd
				frameEnd = ts
			Else
				frame = frameStart
			End
		Else
			If pingPong And ping <1
				If Not reverse
					frame = frameEnd - 1
				Else
					frame = frameEnd
				End
				reverse = Not reverse
				Local ts:Int = frameStart
				frameStart = frameEnd
				frameEnd = ts
				ping += 1
			Else
				frame = frameEnd
				Return 1
			End
		End
		Return 0
	End
End

'summary: GameImage Class
Class GameImage Implements ITilesetImage

Private
	Field pixels:Int[]
	Field maskRed:Int = 0
	Field maskGreen:Int = 0
	Field maskBlue:Int = 0
	Field preLoad:Bool = False
	Field path:String
	Field midhandle:Bool
	Field screenName:String
Public
	Field name:String
	Field image:Image
	Field w:Int
	Field h:Int
	Field w2:Float
	Field h2:Float
	Field w4:Float
	Field h4:Float
	Field midhandled:Int = 0
	Field frames:Int
	
	Field leftMargin:Int = 0
	Field rightMargin:Int = 0
	Field topMargin:Int = 0
	Field bottomMargin:Int = 0
	
	Field tileWidth:Int, tileHeight:Int
	Field tileCountX:Int, tileCountY:Int
	Field tileCount:Int
	Field tileSpacing:Int, tileMargin:Int
	
	Field subX:Int
	Field subY:Int
	Field atlasName:String

	Field readPixels:Bool
	Field readPixelsComplete:Bool = False
	
	Field offSetX:Int
	Field offSetY:Int

	Method TileWidth:Int() Property; Return tileWidth; End
	Method TileWidth:Void(value:Int) Property; tileWidth = value; End
	Method TileHeight:Int() Property; Return tileHeight; End
	Method TileHeight:Void(value:Int) Property; tileHeight = value; End
	Method TileCountX:Int() Property; Return tileCountX; End
	Method TileCountX:Void(value:Int) Property; tileCountX = value; End
	Method TileCountY:Int() Property; Return tileCountY; End
	Method TileCountY:Void(value:Int) Property; tileCountY = value; End
	Method TileCount:Int() Property; Return tileCount; End
	Method TileCount:Void(value:Int) Property; tileCount = value; End
	Method TileSpacing:Int() Property; Return tileSpacing; End
	Method TileSpacing:Void(value:Int) Property; tileSpacing = value; End
	Method TileMargin:Int() Property; Return tileMargin; End
	Method TileMargin:Void(value:Int) Property; tileMargin = value; End
	
	Method Pixels:Int[]() Property
		If readPixels Then
			If Not readPixelsComplete Then
			#If CONFIG="debug"
				Print "Read Pixels have not been completed, please use ReadPixels on GameImage "+name
			#End
			End
		End
		Return pixels
	End
	
	Method SetMaskColor:Void(r:Int, g:Int, b:Int)
		maskRed = r
		maskGreen = g
		maskBlue = b
	End
	
	Method Load:Void(file:String, midhandle:Bool = True, readPixels:Bool = False, maskRed:Int = 0, maskGreen:Int = 0, maskBlue:Int = 0, preLoad:Bool = False, screenName:String = "", failOkay:Bool = False)
		name = StripAll(file.ToUpper())
		path = file
		Self.midhandle = midhandle
		Self.preLoad = preLoad
		Self.screenName = screenName.ToUpper()
		If Not preLoad Then
			image = LoadBitmap(file, 0, failOkay)
			If image <> Null Then
				CalcSize()
				MidHandle(midhandle)
				pixels = New Int[image.Width() * image.Height()]
				Self.readPixels = readPixels
			End
		End
		SetMaskColor(maskRed, maskGreen, maskBlue)
	End
	
	Method LoadAnim:Void(file:String, w:Int, h:Int, total:Int, tmpImage:Image=Null, midhandle:Bool = True, readPixels:Bool = False, maskRed:Int = 0, maskGreen:Int = 0, maskBlue:Int = 0, preLoad:Bool = False, screenName:String = "")
		name = StripAll(file.ToUpper())
		path = file
		Self.midhandle = midhandle
		Self.preLoad = preLoad
		Self.screenName = screenName.ToUpper()
		Self.w = w
		Self.h = h
		Self.frames = total
		If not preLoad Then
			image = LoadAnimBitmap(file, w, h, total, tmpImage)
			CalcSize()
			MidHandle(midhandle)
			pixels = New Int[image.Width() * image.Height()]
			Self.readPixels = readPixels
		End
		SetMaskColor(maskRed, maskGreen, maskBlue)
	End
	
	Method LoadTileset:Void(file:String, tileWidth:Int, tileHeight:Int, tileMargin:Int = 0, tileSpacing:Int = 0, midhandle:Bool=False, readPixels:Bool = False, maskRed:Int = 0, maskGreen:Int = 0, maskBlue:Int = 0)
		Load(file, midhandle)
		Self.tileWidth = tileWidth
		Self.tileHeight = tileHeight
		Self.tileMargin = tileMargin
		Self.tileSpacing = tileSpacing
		tileCountX = (w - 2*tileMargin + tileSpacing) / (tileWidth + tileSpacing)
		tileCountY = (h - 2*tileMargin + tileSpacing) / (tileHeight + tileSpacing)
		tileCount = tileCountX * tileCountY
		pixels = New Int[image.Width() * image.Height()]
		Self.readPixels = readPixels
		SetMaskColor(maskRed, maskGreen, maskBlue)
	End
	
	Method CalcSize:Void()
		If image <> Null Then
			w = image.Width()
			h = image.Height()
			w2 = w / 2
			h2 = h / 2
			w4 = w / 4
			h4 = h / 4
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
	
	Method Draw:Void(x:Float, y:Float, rotation:Float = 0, scaleX:Float = 1, scaleY:Float = 1, frame:Int = 0, rounded:Bool = False)
		If rounded
			DrawImage(Self.image, Floor(x + 0.5), Floor(y + 0.5), rotation, scaleX, scaleY, frame)
		Else
			DrawImage(Self.image, x + offSetX, y + offSetY, rotation, scaleX, scaleY, frame)
		End
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
	
	Method ReadPixelsArray:Void()
		Cls 0, 0, 0
		Local posX:Int = SCREEN_WIDTH2
		Local posY:Int = SCREEN_HEIGHT2
		DrawImage Self.image, posX, posY
		If readPixels
			If pixels.Length <> image.Width() * image.Height() Then
				pixels = New Int[image.Width() * image.Height()]
			End
			ReadPixels(pixels, posX - image.HandleX(), posY - image.HandleY(), image.Width(), image.Height())
			readPixelsComplete = True
			PixelArrayMask(pixels, maskRed, maskGreen, maskBlue)		
		End	
	End
	
End

'summary: Sound resource bank
'Images must be stored in sounds folder
Class SoundBank Extends StringMap<GameSound>
	
	Global path$ = "sounds/"
	
	Method Load:GameSound(name:String, nameoverride:String = "", ignoreCache:Bool = False, soundDelay:Int = 0, preLoad:Bool = False, screenName:String = "")
		' check if we already have the sound in the bank!
		Local storeKey:String = nameoverride.ToUpper()
		If storeKey = "" Then storeKey = StripAll(name.ToUpper())
		If Not ignoreCache And Self.Contains(storeKey) Then Return Self.Get(storeKey)
		
		' discard the old sound if it's there
		If Self.Contains(storeKey) Then Self.Get(storeKey).sound.Discard()
		
		Local s:GameSound = New GameSound
		s.Load(name, preLoad, screenName)
		s.name = storeKey
		s.soundDelay = soundDelay
		Self.Set(s.name, s)
		Return s
	End
	   
	Method Find:GameSound(name:String)
		name = name.ToUpper()

		' debug: print all keys in the map
		If  diddyGame.debugOn
			For Local key:String = EachIn Self.Keys()
				Local i:GameSound = Self.Get(key)
				If Not i.preLoad Then Print key + " is stored in the sound map."
			Next
		End
		
		Local i:GameSound = Self.Get(name)
		Local err:String = "Sound '" + name + "' not found in the SoundBank"
		If i.preLoad and i.sound = null Then AssertError(err)
		AssertNotNull(i, err)
		Return i
	End
End

'summary: GameSound Class
Class GameSound
	Field name:String
	Field sound:Sound
	Field rate:Float = 1
	Field pan:Float = 0
	Field volume:Float = 1
	Field loop:Int = 0
	Field channel:Int
	Field loopChannelList:DiddyIntStack = New DiddyIntStack
	Field soundAvailableMillis:Int
	Field soundDelay:Int
	Field stopChannelBeforePlaying:Bool = true
	Field screenName:String
	Field preLoad:Bool
	Field path:String
	
	Method Load:Void(file:String, preLoad:Bool = False, screenName:String = "")
		Self.path = file
		Self.preLoad = preLoad
		Self.screenName = screenName
		If Not preLoad
			If file.Contains(".wav") Or file.Contains(".ogg") Or file.Contains(".mp3") Or file.Contains(".m4a") Or file.Contains(".wma") Then
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
		End
		name = StripAll(file.ToUpper())
	End
	
	Method Play:Bool(playChannel:Int = -1, force:Bool=False)
		If force Or soundDelay = 0 Or soundAvailableMillis < dt.currentticks
			if stopChannelBeforePlaying And Self.IsPlaying()
				Self.Stop()
			End
			channel = SoundPlayer.PlayFx(sound, pan, rate, volume * (diddyGame.soundVolume / 100.0), loop, playChannel)
			If loop = 1
				loopChannelList.Push(channel)
			End
			soundAvailableMillis = dt.currentticks + soundDelay
			Return True
		End
		Return False
	End
	
	Method Stop:Void()
		SoundPlayer.PlayerStopChannel(channel)
		If Not loopChannelList.IsEmpty()
			Local ch:Int
			For Local i:Int = 0 Until loopChannelList.Count()
				ch = loopChannelList.Get(i)
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
	
	Method Pause:Void()
		If IsPlaying() Then
			PauseChannel(channel)
		End
	End

	Method Resume:Void()
		If IsPlaying() Then
			ResumeChannel(channel)
		End
	End
End

'summary: SoundPlayer Class
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
		If playChannel = -1 Then
			Local cnt:Int = 0
			channel += 1
			If (channel > MAX_CHANNELS) Then channel = 0
			While playerChannelState[channel] = 1 ' channel State doesnt work with Flash
				channel += 1
				If (channel > MAX_CHANNELS) Then channel = 0
				cnt=+1
				If cnt > MAX_CHANNELS * 2 Then Exit ' stop infinite loop if case all channels are playing
			End
		Else
			channel = playChannel
			playerChannelState[playChannel] = 0
		End

		StopChannel(channel)
		PlaySound(s, channel, loop)
		SetChannelPan(channel, pan)
		SetChannelRate(channel, rate)
		SetChannelVolume(channel, volume)
		If loop Then playerChannelState[channel] = 1		
		Return channel
	End
	
End

'summary: Sprite Class
Class Sprite
	Field name:String
	Field visible:Bool = True
	Field x:Float, y:Float
	Field ox:Float, oy:Float
	Field ex:Float, ey:Float
	Field dx:Float, dy:Float
	Field oldRotation:Float, newRotation:Float
	Field speedX:Float, speedY:Float, speed:Float
	Field maxXSpeed:Float, maxYSpeed:Float
	Field image:GameImage
	Field scaleX:Float = 1, scaleY:Float = 1

	Field red:Int = 255, green:Int = 255, blue:Int = 255, alpha:Float = 1
	Field hitBox:HitBox
	Field glow:Bool
	Field glowAmount:Float = 0.1

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
	
	Field currentSpriteAnimation:SpriteAnimation
	Field useSpriteAnimation:Bool = False
	Field spriteAnimations:SpriteAnimationsMap = New SpriteAnimationsMap
	
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
	
	' timer
	Field timer:Float
	Field timerSpeed:Float = 0.01
	Field tweenType:Int = TweenType.LINEAR
	Field doTween:Int = 0
	Field stopWhenFinished:Bool
	
	Method New(img:GameImage, x:Float, y:Float)
		Self.image = img
		Self.x = x
		Self.y = y
		Self.alpha = 1
		Self.SetHitBox(-img.image.HandleX(), -img.image.HandleY(), img.w, img.h)
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
			image.w2 = image.w / 2
			image.h2 = image.h / 2
			image.w4 = image.w / 4
			image.h4 = image.h / 4
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
	
	Method SetupScale:Void(scaleSpeedX:Float, scaleSpeedY:Float, time:Float)
		Self.scaleCounter = time
		Self.scaleXSpeed = scaleSpeedX
		Self.scaleYSpeed = scaleSpeedY
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
	
	Method UpdateTimer:Bool(loop:Bool, stopWhenFinished:Bool)
		timer += timerSpeed * dt.delta
		
		If stopWhenFinished
			If timer >= 1 Then
				timer = 1
				Return True
			End
		ElseIf loop
			If timer >= 1 Then
				timer = 0
				Return True
			End
		End
		Return False
	End
	
	Method SetTweenXYR:Void(ox:Float, oy:Float, ex:Float, ey:Float, oldR:Float, newR:Float, tweenType:Int = TweenType.LINEAR, loop:Bool = False, stopWhenFinished:Bool = True)
		Self.ox = ox
		Self.oy = oy
		Self.ex = ex
		Self.ey = ey
		Self.oldRotation = oldR
		Self.newRotation = newR
		Self.doTween = True
		Self.loop = loop
		Self.tweenType = tweenType
		Self.stopWhenFinished = stopWhenFinished
	End

	Method ManageTween:Bool()
		Local finished:Bool = False
		If doTween
			finished = UpdateTimer(loop, stopWhenFinished)
			Select tweenType
				Case TweenType.LINEAR
					x = LinearTween(ox, ex, timer)
					y = LinearTween(oy, ey, timer)
					rotation = LinearTween(oldRotation, newRotation, timer)
				Case TweenType.DOWN
					x = TweenDown(ox, ex, timer)
					y = TweenDown(oy, ey, timer)
					rotation = TweenDown(oldRotation, newRotation, timer)
				Case TweenType.UP
					x = TweenUp(ox, ex, timer)
					y = TweenUp(oy, ey, timer)
					rotation = TweenUp(oldRotation, newRotation, timer)
				Case TweenType.QUAD
					x = QuadTween(ox, ex, timer)
					y = QuadTween(oy, ey, timer)
					rotation = QuadTween(oldRotation, newRotation, timer)
				Case TweenType.QUINTIC
					x = QuinticTween(ox, ex, timer)
					y = QuinticTween(oy, ey, timer)
					rotation = QuinticTween(oldRotation, newRotation, timer)
				Case TweenType.SMOOTH
					x = TweenSmooth(ox, ex, timer)
					y = TweenSmooth(oy, ey, timer)
					rotation = TweenSmooth(oldRotation, newRotation, timer)
			End
		End
		Return finished
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
	
	'summary: Animation process, deals with changing frames. Returns 1 if the animation has finished (only for non looping animations).
	Method UpdateAnimation:Int()
		Local rv:Int = 0
		If useSpriteAnimation
			Return currentSpriteAnimation.UpdateAnimation()
		Else
			If frameSpeed > 0
				If Millisecs() > frameTimer + frameSpeed
					If Not reverse
						frame+=1
						If frame > frameEnd
							rv = ResetAnim()
						End
					Else
						frame-=1
						If frame < frameEnd
							rv = ResetAnim()
						End			
					End
					frameTimer = Millisecs()
				End	
			End
		End
		Return rv
	End
	
	Method ResetAnim:Int()
		If loop Then
			If pingPong
				reverse = Not reverse
				frame = frameEnd
				Local ts:Int = frameStart
				frameStart = frameEnd
				frameEnd = ts
			Else
				frame = frameStart
			End
		Else
			If pingPong And ping <1
				reverse = Not reverse
				frame = frameEnd
				Local ts:Int = frameStart
				frameStart = frameEnd
				frameEnd = ts
				ping+=1
			Else
				frame = frameEnd
				Return 1
			End
		End
		Return 0
	End
	
	Method Draw:Void()
		Draw(0,0)
	End
	
	Method Draw:Void(rounded:Bool)
		Draw(0,0, rounded)
	End
	
	Method Draw:Void(offsetx:Float, offsety:Float, rounded:Bool = False, drawOffScreen:Bool = False)
		If Not visible Then Return

		If Not drawOffScreen
			Local lensq:Int = image.w * image.w * scaleX * scaleX + image.h * image.h * scaleY * scaleY
			If x - offsetx < 0 And (x - offsetx) * (x - offsetx) > lensq Then Return
			If x - offsetx > SCREEN_WIDTH And (x - offsetx - SCREEN_WIDTH) * (x - offsetx - SCREEN_WIDTH) > lensq Then Return
			If y - offsety < 0 And (y - offsety) * (y - offsety) > lensq Then Return
			If y - offsety > SCREEN_HEIGHT And (y - offsety - SCREEN_HEIGHT) * (y - offsety - SCREEN_HEIGHT) > lensq Then Return
		End
		
		If Self.alpha > 1 Then Self.alpha = 1
		If Self.alpha < 0 Then Self.alpha = 0
		
		SetAlpha(Self.alpha)
		SetColor(red, green, blue)

		If rounded
			If useSpriteAnimation
				DrawImage(currentSpriteAnimation.frames[currentSpriteAnimation.frame].image, Floor(x - offsetx + 0.5) + currentSpriteAnimation.frames[currentSpriteAnimation.frame].offSetX, Floor(y - offsety + 0.5) + currentSpriteAnimation.frames[currentSpriteAnimation.frame].offSetY, rotation, scaleX, scaleY)
			Else
				DrawImage(image.image, Floor(x - offsetx + 0.5), Floor(y - offsety + 0.5), rotation, scaleX, scaleY, frame)
			End
			If glow
			
				SetBlend(AdditiveBlend)
				SetAlpha(glowAmount)
				If useSpriteAnimation
					DrawImage(currentSpriteAnimation.frames[currentSpriteAnimation.frame].image, Floor(x - offsetx + 0.5) + currentSpriteAnimation.frames[currentSpriteAnimation.frame].offSetX, Floor(y - offsety + 0.5) + currentSpriteAnimation.frames[currentSpriteAnimation.frame].offSetY, rotation, scaleX, scaleY)
				Else
					DrawImage(image.image, Floor(x - offsetx + 0.5), Floor(y - offsety + 0.5), rotation, scaleX, scaleY, frame)
				End
				SetAlpha(1)
				SetBlend(AlphaBlend)
			End
		Else
			If useSpriteAnimation
				DrawImage(currentSpriteAnimation.frames[currentSpriteAnimation.frame].image, x - offsetx + currentSpriteAnimation.frames[currentSpriteAnimation.frame].offSetX, y - offsety + currentSpriteAnimation.frames[currentSpriteAnimation.frame].offSetY, rotation, scaleX, scaleY)
			Else
				DrawImage(image.image, x - offsetx, y - offsety, rotation, scaleX, scaleY, frame)
			End

			If glow
				SetBlend(AdditiveBlend)
				SetAlpha(glowAmount)
				If useSpriteAnimation
					DrawImage(currentSpriteAnimation.frames[currentSpriteAnimation.frame].image, x - offsetx + currentSpriteAnimation.frames[currentSpriteAnimation.frame].offSetX, y - offsety + currentSpriteAnimation.frames[currentSpriteAnimation.frame].offSetY, rotation, scaleX, scaleY)
				Else
					DrawImage(image.image, x - offsetx, y - offsety, rotation, scaleX, scaleY, frame)
				End
				SetAlpha(1)
				SetBlend(AlphaBlend)
			End
		End
		
		SetColor 255, 255, 255
		SetAlpha 1
	End
	
	Method DrawHitBox:Void(offsetx:Float = 0, offsety:Float = 0)
		If Not visible Then Return
		' Draw the midhandle
		DrawRect x - 1 - offsetx, y - 1 - offsety, 2, 2
		' Draw the hit box
		DrawRectOutline(x + hitBox.x - offsetx, y + hitBox.y - offsety, hitBox.w, hitBox.h)
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
	
	Method MouseCollide:Int(mw:Int = 1, mh:Int = 1)
		Return RectsOverlap(x + hitBox.x, y + hitBox.y, hitBox.w, hitBox.h,
							diddyGame.mouseX, diddyGame.mouseY, mw, mh)
	End
	
	Method Collide:Int(sprite:Sprite)
		Return RectsOverlap(x + hitBox.x, y + hitBox.y, hitBox.w, hitBox.h,
							sprite.x +sprite.hitBox.x, sprite.y + sprite.hitBox.y, sprite.hitBox.w, sprite.hitBox.h)
	End
		
	Method SetHitBox:Void(hitX:Int, hitY:Int, hitWidth:Int, hitHeight:Int)
		hitBox = New HitBox(hitX, hitY, hitWidth, hitHeight)
	End
	
	Method SetXY:Void(x:Float, y:Float, setO:Int = False)
		Self.x = x
		Self.y = y
		If setO
			Self.ox = x
			Self.oy = y
		End If
	End
End

'summary: Simple HitBox class
Class HitBox
	Field x:Float, y:Float
	Field w:Float, h:Float
	
	Method New(x:Float, y:Float, w:Float, h:Float)
		Self.x = x
		Self.y = y
		Self.w = w
		Self.h = h
	End
	
	Method Draw:Void(offsetx:Float = 0, offsety:Float = 0)
		DrawRectOutline(x - offsetx, y - offsety, w, h)
	End
	
	Method Contains:Bool(x:Int, y:Int)
		Return Inside(x, y)
	End
	
	Method Contains:Bool(X:Int, Y:Int, W:Int, H:Int)
		Local w:Int = Self.w
		Local h:Int = Self.h
		If ( (w | h | W | H) < 0)
	    	Return False
		End
	
	
		Local x:Int = Self.x
		Local y:Int = Self.y
		If X < x or Y < y
	    	Return False
		End
		
		w += x
		W += X
		If (W <= X)
		    If (w >= x or W > w) Return False
		Else
		    If (w >= x And W > w) Return False
		End
		h += y
		H += Y
		If (H <= Y)
	    	If (h >= y or H > h) Return False
		Else
	    	If (h >= y And H > h) Return False
		End
		
		Return True
		
	End
	
	Method Inside:Bool(X:Int, Y:Int)
		Local w:Int = Self.w
		Local h:Int = Self.h
		If ( (w | h) < 0) Then
		    Return False
		End

		Local x:Int = Self.x;
		Local y:Int = Self.y;
		If (X < x or Y < y)
		    Return False
		End
		w += x
		h += y
		Return ( (w < x or w > X) and (h < y or h > Y))
	End
	
	Method Intersects:Bool(r:HitBox)
		Local tw:Int = Self.w
		Local th:Int = Self.h
		Local rw:Int = r.w
		Local rh:Int = r.h
		If rw <= 0 or rh <= 0 or tw <= 0 or th <= 0 Then
			Return False
		End
		Local tx:Int = Self.x
		Local ty:Int = Self.y
		Local rx:Int = r.x
		Local ry:Int = r.y
		rw += rx
		rh += ry
		tw += tx
		th += ty
		
		Return ( (rw < rx or rw > tx) And (rh < ry or rh > ty) And (tw < tx or tw > rx) And (th < ty or th > ry))
	End
	
End

Class TweenType
	Const LINEAR:Int = 0
	Const QUAD:Int = 1
	Const QUINTIC:Int = 2
	Const SMOOTH:Int = 3
	Const UP:Int = 4
	Const DOWN:Int = 5
End

Class ExtrasParticleObject
	Field particle:ParticleObject
	Field userObject1:Object
	Field userObject2:Object
	
	Method New(p:ParticleObject)
		Self.particle = p
	End
	
	Method PostTween:Void()
		
	End
End

Class ExtrasParticle
	Field particle:Particle
	Field userObject1:Object
	Field userObject2:Object
	
	Method New(p:Particle)
		Self.particle = p
	End
	
	Method PostTween:Void()
		
	End
End


Class ParticleObject Extends Sprite
	Global ParticlesList:List<ParticleObject> = New List<ParticleObject>()
	Field lifeCounter:Float = 0
	Field fadeIn:Int = 0
	Field fadeCounter:Float
	Field fadeInLength:Float = 0
	Field fadeLength:Float = 0
	Field active:Int = 0
	Field doFade:Int = 0
	Field tweenFinished:Bool
	Field extras:ExtrasParticleObject
		
	Method SetExtras:Void(extras:ExtrasParticleObject)
		Self.extras = extras
	End
	
	Method SetFade:Void(fadeIn:Bool, fadeInLength:Float, fadeLength:Float)
		Self.fadeIn = fadeIn
		If fadeIn
			alpha = 0
		End
		Self.fadeInLength = fadeInLength'diddyGame.CalcAnimLength(500)
		Self.fadeLength = fadeLength'diddyGame.CalcAnimLength(1000)
		Self.doFade = 1
	End
	
	Function Create:ParticleObject(gi:GameImage, x:Float, y:Float, dx:Float = 0, dy:Float = 0, gravity:Float = 0, fadeLength:Float = 0, lifeCounter:Int = 0)

		Local particle:ParticleObject = New ParticleObject()
		particle.SetImage(gi)
		particle.x = x
		particle.y = y
		particle.dx = dx
		particle.dy = dy
		
		particle.frame = 0
		particle.rotationCounter = 0
		particle.scaleCounter = 0
		particle.rotationLoop = False
		particle.rotation = 0
		particle.SetScaleXY(1, 1)
		
		particle.ygravity = gravity
		particle.fadeLength = fadeLength / 10
		particle.fadeCounter = particle.fadeLength
		particle.tweenFinished = False
		particle.timerSpeed = 0.01
		particle.tweenType = TweenType.LINEAR
		particle.doTween = 0
		
		If particle.fadeLength > 0
			particle.doFade = 1
			particle.alpha = 0
		Else
			particle.doFade = 0
			particle.alpha = 1
		End
		
		If lifeCounter>0 Then particle.lifeCounter = lifeCounter / 10
		particle.active = 1

		ParticlesList.AddLast(particle)
		
		Return particle

	End
	
	Function Clear:Void()
		ParticlesList.Clear()
	End
	
	Function DrawAll:Void(offsetx:Float = 0, offsety:Float = 0)
		For Local particle:ParticleObject = EachIn ParticlesList
			If particle.doFade = 1
				If particle.fadeCounter > 0 And particle.active Then
					If particle.fadeIn Then
						particle.alpha = particle.fadeCounter / particle.fadeInLength
					Else
						particle.alpha = particle.fadeCounter / particle.fadeLength
					End
				End
			End
			particle.Draw(offsetx, offsety)
		Next
	End
	
	Function UpdateAll:Void()
		For Local particle:ParticleObject = EachIn ParticlesList
			If particle.active
				particle.Update()
			End
		Next
	End
	
	Method Update:Void()
		Super.Move()

		ManageRotation()
		ManageScale()
		tweenFinished = ManageTween()
		If tweenFinished
			If extras Then extras.PostTween()
		End
		If doFade
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
					Kill()
				End
			End
		End
	End
	
	Method Kill:Void()
		ParticlesList.Remove(Self)
	End

	Function KillAll:Void()
		For Local p:ParticleObject = EachIn ParticlesList
			p.Kill()
		Next
	End
End

'summary: Particle Class
Class Particle Extends Sprite
	Global MAX_PARTICLES:Int = 800
	Global particles:Particle[MAX_PARTICLES]
	Global lastDeath:Int = 0
	Global maxIndex:Int = -1
	Global minIndex:Int = -1
	Global particleCount:Int = 0
	Field lifeCounter:Float = 0
	Field fadeIn:Int = 0
	Field fadeCounter:Float
	Field fadeInLength:Float = 0
	Field fadeLength:Float = 0
	Field active:Int = 0
	Field doFade:Int = 0
	Field tweenFinished:Bool
	Field extras:ExtrasParticle
	
	Function Cache:Void()
		For Local i:Int = 0 To MAX_PARTICLES - 1
			particles[i] = New Particle()
		Next
	End
	
	Method SetExtras:Void(extras:ExtrasParticle)
		Self.extras = extras
	End
	
	Method SetFade:Void(fadeIn:Bool, fadeInLength:Float, fadeLength:Float)
		Self.fadeIn = fadeIn
		If fadeIn
			alpha = 0
		End
		Self.fadeInLength = fadeInLength'diddyGame.CalcAnimLength(500)
		Self.fadeLength = fadeLength'diddyGame.CalcAnimLength(1000)
		Self.doFade = 1
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
				
				particles[i].frame = 0
				particles[i].rotationCounter = 0
				particles[i].scaleCounter = 0
				particles[i].rotationLoop = False
				particles[i].rotation = 0
				particles[i].SetScaleXY(1, 1)
				
				particles[i].ygravity = gravity
				particles[i].fadeLength = fadeLength / 10
				particles[i].fadeCounter = particles[i].fadeLength
				particles[i].tweenFinished = False
				particles[i].timerSpeed = 0.01
				particles[i].tweenType = TweenType.LINEAR
				particles[i].doTween = 0
				
				If particles[i].fadeLength > 0
					particles[i].doFade = 1
					particles[i].alpha = 0
				Else
					particles[i].doFade = 0
					particles[i].alpha = 1
				End
				
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
			particles[i].frame = 0
			particles[i].rotationCounter = 0
			particles[i].scaleCounter = 0
			particles[i].rotationLoop = False
			particles[i].rotation = 0
			particles[i].timer = 0
			particles[i].tweenFinished = False
			particles[i].timerSpeed = 0.01
			particles[i].tweenType = TweenType.LINEAR
			particles[i].doTween = 0
			particles[i].doFade = 0
			particles[i].SetScaleXY(1, 1)
			If particles[i].extras
				particles[i].extras = Null
			End
		Next
		minIndex = -1
		maxIndex = -1
		particleCount = 0
		lastDeath = 0
	End
	
	Function DrawAll:Void(offsetx:Float = 0, offsety:Float = 0)
		If minIndex < 0 Or maxIndex < 0 Then Return
		For Local i% = minIndex To maxIndex
			If particles[i] <> Null And particles[i].image <> Null
				If particles[i].doFade = 1
					If particles[i].fadeCounter > 0 And particles[i].active Then
						If particles[i].fadeIn Then
							particles[i].alpha = particles[i].fadeCounter/particles[i].fadeInLength
						Else
							particles[i].alpha = particles[i].fadeCounter/particles[i].fadeLength
						End
					End
				End
				particles[i].Draw(offsetx, offsety)
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

		ManageRotation()
		ManageScale()
		tweenFinished = ManageTween()
		If tweenFinished
			If extras Then extras.PostTween()
		End
		If doFade
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
End

'summary: Simple Mouse functions class
Class DiddyMouse
	Field lastX:Int
	Field lastY:Int

	'summary: Returns the MouseX speed
	Method MouseXSpeed:Int()
		Return diddyGame.mouseX - lastX
	End
	
	'summary: Returns the MouseY speed
	Method MouseYSpeed:Int()
		Return diddyGame.mouseY - lastY
	End
	
	'summary: Updates the last positions
	Method Update:Void()
		lastX = diddyGame.mouseX
		lastY = diddyGame.mouseY
	End
End

'summary: Wrapper function for MouseXSpeed
Function MouseXSpeed:Int()
	Return diddyGame.diddyMouse.MouseXSpeed()
End

'summary: Wrapper function for MouseYSpeed
Function MouseYSpeed:Int()
	Return diddyGame.diddyMouse.MouseYSpeed()
End

#Rem
Summary: Simple SplashScreen
#End
Class SplashScreen Extends Screen
	Field img:Image
	Field time:Float
	Field timeOut:Float = 100
	Field fade:Bool
	Field nextScreen:Screen
	Field imagePath:String
	Field flags:Int
	Field x:Int, y:Float
	Field debug:Bool
	Field clsColor:Int[3]
		
	Method New(imagePath:String, flags:Int, x:Int, y:Int, nextScreen:Screen, timeOut:Int = 250)
		name = "Splash"
		Self.imagePath = imagePath
		Self.flags = flags
		Self.nextScreen = nextScreen
		Self.x = x
		Self.y = y
		Self.timeOut = diddyGame.CalcAnimLength(timeOut)
		SetClsColor(0, 0, 0)
	End
	
	Method SetClsColor:Void(r:Int = 0, g:Int = 0, b:Int = 0)
		clsColor[0] = r
		clsColor[1] = g
		clsColor[2] = b
	End
		
	Method Start:Void()
		fade = False
	End
	
	Method Load:Void()
		img = LoadBitmap("graphics/" + imagePath, flags)
	End
	
	Method Update:Void()
		' if debug is set the splash screen is only displayed briefly
		If debug
			time += 100
		End
		If time < timeOut
			time += 1 * dt.delta
		Else
			If not fade
				FadeToScreen(nextScreen)
			End
		End
	End
	
	Method Render:Void()
		Cls(clsColor[0], clsColor[1], clsColor[2])
		DrawImage(img, x, y)
	End
End

#Rem
Summary: AnimationTimer
#End
Class AnimationTimer
	Const FORWARD:Int = 1
	Const BACKWARD:Int = 0

	Field maxPhases:Int = 50
	Field active:Bool = False
	Field loopTotal:Int = 0
	Field counter:Int = 0
	Field currentPhase:Int = 0
	Field finished:Bool = False
	Field totalPhases:Int = 1
	
	Field cycle:Int = 0
	Field direction:Int = FORWARD
	Field length:Float[]
	Field leaveActive:Bool = False
	Field pingPong:Bool = False
	Field reverse:Bool = False
	Field originalReverse:Bool = False
	Field loopCount:Int = 0
	
	Method New(timeAmount:Int, leaveActive:Bool = False, reverse:Bool = False, cycle:Bool = False, pingPong:Bool = False)
		Init(timeAmount, leaveActive, reverse, cycle, pingPong)
	End
	
	Method Init:Void(timeAmount:Int, leaveActive:Bool = False, reverse:Bool = False, cycle:Bool = False, pingPong:Bool = False)
		Self.length = New Float[maxPhases]
		Self.length[0] = diddyGame.CalcAnimLength(timeAmount)
		Self.currentPhase = 0
		Self.finished = False
		Self.totalPhases = 1
		Self.cycle = cycle
		Self.direction = FORWARD
		Self.leaveActive = leaveActive
		Self.pingPong = pingPong
		Self.reverse = reverse
		Self.originalReverse = reverse
		Self.loopCount = 0
	End
	
	Method Clear:Void()
		active = False
		loopTotal = 0
		counter = 0
		currentPhase = 0
		finished = False
		totalPhases = 1
		cycle = 0
		direction = FORWARD
		leaveActive = False
		pingPong = False
		reverse = False
		originalReverse = False
		loopCount = 0
	End

	Method Update:Int()
		If active
			If not reverse
				counter -= dt.delta
				If counter <= 0
					EndAnim()
					Return 1
				End
			Else
				counter += dt.delta
				If counter > length[currentPhase]
					EndAnim()
					Return 1
				End
			End
		End
		Return 0
	End
	
	Method Reset:Void()
		counter = 0
		Start()
	End
	
	Method Start:Void()
		If pingPong Then reverse = originalReverse
		If not reverse
			If counter <= 0
				counter = length[currentPhase]
			End
		Else
			counter = 0
		End
		active = True
		currentPhase = 0
		finished = False
		direction = FORWARD
		loopCount = 0
	End
	
	Method Stop:Void()
		If direction = FORWARD
			currentPhase = totalPhases - 1
		Else
			currentPhase = 0
		End
		EndAnim()
	End
	
	Method EndAnim:Int()
		If direction = FORWARD
			currentPhase += 1
		Else
			currentPhase -= 1
		End

		If (direction = FORWARD And currentPhase = totalPhases) Or (direction = BACKWARD And currentPhase = -1)
			Local doCycle:Int = cycle
			loopCount += 1
			If loopTotal > 0 And loopCount = loopTotal Then doCycle = 0
			
			If doCycle
				If pingPong
					If direction = FORWARD
						counter = 0 - counter
						reverse = True
						direction = BACKWARD
						currentPhase = totalPhases - 1
					Else
						counter = length[0] - (counter - length[0])
						reverse = False
						direction = FORWARD
						currentPhase = 0
					End
					Return 0
				Else
					currentPhase = 0
				End
			Else
				finished = True
				If leaveActive
					currentPhase = totalPhases - 1
					If Not reverse
						counter = 0
					Else
						counter = length[currentPhase]
					End
					Return 1
				Else
					counter = 0
					currentPhase = 0
					active = False
					Return 1
				End
			End
		End
		If Not reverse
			counter = length[currentPhase]
		Else
			counter = 0
		End
		
		Return 0
	End

	Method GetRatio:Float()
		Return counter / length[currentPhase]
	End
	
	Method GetRatioSine:Float()
		Return Sin(GetRatio() * 90)
	End
	
	Method GetRatioInv:Float()
		Return 1 - (counter / length[currentPhase])
	End
	
	Method GetRatioInvSine:Float()
		Return Sin( (1 - GetRatio()) * 90)
	End
	
	Method AddPhase:Void(timeAmount:Int)
		length[totalPhases] = diddyGame.CalcAnimLength(timeAmount)
		totalPhases += 1
	End
End