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
			' fading to Null is the same as fading to game.exitScreen (which exits the game)
			FadeToScreen(Null)
		End
	End
End
[/code]
#End
Strict

Import mojo
Import functions
Import collections
Import inputcache
Import xml

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
	
Private
	Field useFixedRateLogic:Bool = False
	Field vsx:Float, vsy:Float, vsw:Float, vsh:Float
	
Public
	Method New()
		' DiddyApp now assigns itself to game, so you just need to do: New MyGame()
		' Assigning it manually will have no effect, but won't break anything.
		game = Self
		Self.exitScreen = New ExitScreen
		Self.screenFade = New ScreenFade
		Self.images = New ImageBank
		Self.sounds = New SoundBank
		Self.screens = New Screens
		Self.inputCache = New InputCache
		diddyMouse = New DiddyMouse
	End
			
	Method OnCreate:Int()
		Try
			' Store the device width and height
			DEVICE_WIDTH = DeviceWidth()
			DEVICE_HEIGHT = DeviceHeight()
			
			SetScreenSize(DEVICE_WIDTH, DEVICE_HEIGHT)
			deviceChanged = True
			
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

	Method OnRender:Int()
		Try
			FPSCounter.Update()
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

		If screenFade.active Then screenFade.Update()
		If Not screenFade.active Or screenFade.allowScreenUpdate Then currentScreen.Update()
	End

	'summary: Draws debug information
	Method DrawDebug:Void()
		SetColor 255, 255, 255
		FPSCounter.Draw(0,0)
		Local y:Int = 10
		Local gap:Int = 14
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
	
	'summary: Draws current FPS at 0,0
	Method DrawFPS:Void()
		DrawText FPSCounter.totalFPS, 0, 0
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
			SetChannelVolume(i, game.soundVolume / 100.0)
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
	Method Start:Void(firstScreen:Screen, autoFadeIn:Bool=True, fadeInTime:Float=defaultFadeTime, fadeSound:Bool=False, fadeMusic:Bool=False)
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
			currentScreen.Suspend()
		Catch e:DiddyException
			Print(e.ToString(True))
			Error(e.ToString(False))
		End
		Return 0
	End

	Method OnResume:Int()
		Try
			dt.currentticks = Millisecs()
			dt.lastticks = dt.currentticks
			currentScreen.Resume()
		Catch e:DiddyException
			Print(e.ToString(True))
			Error(e.ToString(False))
		End
		Return 0
	End
	
	'summary: Loads in the diddydata xml file
	Method LoadDiddyData:Void()
		Local str:String = LoadString("diddydata.xml")
		If Not str Then
			Throw New DiddyException("Cannot load diddydata.xml file!")
		End
		
		' parse the xml
		Local parser:XMLParser = New XMLParser
		Local doc:XMLDocument = parser.ParseString(str)
		Local rootElement:XMLElement = doc.Root
		
		Local sw:String = rootElement.GetAttribute("screenWidth").Trim()
		If not sw Then sw = 640

		Local sh:String = rootElement.GetAttribute("screenHeight").Trim()
		If not sh Then sh = 480

		Local useAspect:String = rootElement.GetAttribute("useAspectRatio").Trim()
		Local useAspectBool:Bool
		If useAspect
			If useAspect.ToUpper() = "TRUE" Then useAspectBool = True Else useAspectBool = False
		Else
			useAspectBool = False
		End
		
		If debugOn
			Print "screenWidth    = " + sw
			Print "screenHeight   = " + sh
			Print "useAspectRatio = " + useAspect
		End

		SetScreenSize(Int(sw), Int(sh), useAspectBool)
		
		Local resourcesElement:XMLElement = rootElement.GetFirstChildByName("resources")
		
		' read the images
		Local tmpImage:Image
		Local imagesElement:XMLElement = resourcesElement.GetFirstChildByName("images")
		For Local node:XMLElement = EachIn imagesElement.GetChildrenByName("image")
			Local name:String = node.GetAttribute("name").Trim()
			Local path:String = node.GetAttribute("path").Trim()
			Local frames:Int = Int(node.GetAttribute("frames").Trim())
			Local width:Int = Int(node.GetAttribute("width").Trim())
			Local height:Int = Int(node.GetAttribute("height").Trim())
			Local midhandle:String = node.GetAttribute("midhandle").Trim()
			Local ignoreCache:String = node.GetAttribute("ignoreCache").Trim()
			Local readPixels:String = node.GetAttribute("readPixels").Trim()
			Local maskRed:Int = Int(node.GetAttribute("maskRed").Trim())
			Local maskGreen:Int = Int(node.GetAttribute("maskGreen").Trim())
			Local maskBlue:Int = Int(node.GetAttribute("maskBlue").Trim())
			
			Local midhandleBool:Bool
			If midhandle
				If midhandle.ToUpper() = "TRUE" Then midhandleBool = True Else midhandleBool = False
			Else
				midhandleBool = True
			End
			
			Local ignoreCacheBool:Bool
			If ignoreCache
				If ignoreCache.ToUpper() = "TRUE" Then ignoreCacheBool = True Else ignoreCacheBool = False
			Else
				ignoreCacheBool = False
			End
			
			Local readPixelsBool:Bool
			If readPixels
				If readPixels.ToUpper() = "TRUE" Then readPixelsBool = True Else readPixelsBool = False
			Else
				readPixelsBool = False
			End
			
			If debugOn
				Print "name 		= " + name
				Print "path 		= " + path
				Print "frames		= " + frames
				Print "width 		= " + width
				Print "height 		= " + height
				Print "midhandle 	= " + midhandle
				Print "ignoreCache	= " + ignoreCache
			End
			
			' if frames > 1 assume its an animation image
			If frames > 1
				images.LoadAnim(path, width, height, frames, tmpImage, midhandleBool, ignoreCacheBool, name, readPixelsBool, maskRed, maskGreen, maskBlue)
			Else
				images.Load(path, name, midhandleBool, ignoreCacheBool, readPixelsBool, maskRed, maskGreen, maskBlue)
			End
			
		Next
		
		'read the sounds
		Local soundsElement:XMLElement = resourcesElement.GetFirstChildByName("sounds")
		For Local node:XMLElement = EachIn soundsElement.GetChildrenByName("sound")
			Local name:String = node.GetAttribute("name").Trim()
			Local path:String = node.GetAttribute("path").Trim()
			Local ignoreCache:String = node.GetAttribute("ignoreCache").Trim()
			Local soundDelay:String = node.GetAttribute("soundDelay").Trim()
			
			If debugOn
				Print "name 		= " + name
				Print "path 		= " + path
				Print "ignoreCache	= " + ignoreCache
				Print "soundDelay	= " + soundDelay
			End
			
			Local ignoreCacheBool:Bool
			If ignoreCache
				If ignoreCache.ToUpper() = "TRUE" Then ignoreCacheBool = True Else ignoreCacheBool = False
			Else
				ignoreCacheBool = False
			End
			
			sounds.Load(path, name, ignoreCacheBool, Int(soundDelay))
		Next
				
		Local screenElement:XMLElement = rootElement.GetFirstChildByName("screens")
		For Local node:XMLElement = EachIn screenElement.GetChildrenByName("screen")
			Local name:String = node.GetAttribute("name").Trim()
			Local clazz:String = node.GetAttribute("class").Trim()
			
			If debugOn
				Print "name  = " + name
				Print "class = " + clazz
			End
			Local ci:ClassInfo = GetClass(clazz)
			Local scr:Screen = Screen(ci.NewInstance())
			screens.Add(name.ToUpper(), scr)
		Next
		
	End
End

'summary: Map to store the Screens
Class Screens Extends StringMap<Screen>
	Method Find:Screen(name:String)
		name = name.ToUpper()

		' debug: print all keys in the map
		If game.debugOn
			For Local key:String = Eachin Self.Keys()
				Print key + " is stored in the Screens map."
			Next
		End

		Local i:Screen = Self.Get(name)
		AssertNotNull(i, "Image '" + name + "' not found in the Screens map")
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
	Field allowScreenUpdate:Bool
	
	Method Start:Void(fadeTime:Float, fadeOut:Bool, fadeSound:Bool = False, fadeMusic:Bool = False, allowScreenUpdate:Bool = True)
		If active Then Return
		active = True
		Self.fadeTime = game.CalcAnimLength(fadeTime)
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

'summary: Screen to exit the application
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

'summary: Abstract Screen class
Class Screen Abstract
Private
	Field autoFadeIn:Bool = False
	Field autoFadeInTime:Float = 50
	Field autoFadeInSound:Bool = False
	Field autoFadeInMusic:Bool = False
	
Public
	Field name$ = ""
	
	Method PreStart:Void()
		game.currentScreen = Self
		If autoFadeIn Then
			autoFadeIn = False
			game.screenFade.Start(autoFadeInTime, False, autoFadeInSound, autoFadeInMusic)
		End
		Start()
	End
	
	Method Start:Void() Abstract
	
	Method Render:Void() Abstract
	
	Method Update:Void() Abstract
	
	Method Suspend:Void()
	End

	Method Resume:Void()
	End

	Method PostFadeOut:Void()
		Kill()
		game.nextScreen.PreStart()
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
		If game.screenFade.active Then Return
		
		' if the screen is null, assume we're exiting
		If Not screen Then screen = game.exitScreen
		
		' configure the autofade values
		screen.autoFadeIn = True
		screen.autoFadeInTime = fadeTime
		screen.autoFadeInSound = fadeSound
		screen.autoFadeInMusic = fadeMusic
		
		' trigger the fade out
		game.nextScreen = screen
		game.screenFade.Start(fadeTime, True, fadeSound, fadeMusic, allowScreenUpdate)
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
		lastticks = currentticks
	End
End

'summary: Image resource bank
'Images must be stored in graphics folder
Class ImageBank Extends StringMap<GameImage>
	Const ATLAS_PREFIX:String = "_diddyAtlas_"
	Const SPARROW_ATLAS:Int = 0
	Const LIBGDX_ATLAS:Int = 1
	
	Field path:String = "graphics/"
	
	Method LoadAtlas:Void(fileName:String, format:Int = SPARROW_ATLAS, midHandle:Bool=True, readPixels:Bool = False, maskRed:Int = 0, maskGreen:Int = 0, maskBlue:Int = 0)
		If format = SPARROW_ATLAS
			LoadSparrowAtlas(fileName, midHandle, readPixels, maskRed, maskGreen, maskBlue)
		Elseif format = LIBGDX_ATLAS
			LoadLibGdxAtlas(fileName, midHandle, readPixels, maskRed, maskGreen, maskBlue)
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
			If debug Then Print "name = "+line
			If line = "" Then Exit
			Local name:String = line
			'rotate
			i+=1
			line = all[i].Trim()
			If debug Then Print "rotate = "+line
			Local rotate:String = line
			' x and y
			i+=1
			line = all[i].Trim()
			If debug Then Print "x and y = "+line
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
				Print "name    = " + name
				Print "x       = " + x
				Print "y       = " + y
				Print "width   = " + width
				Print "height  = " + height
				Print "origX   = " + origX
				Print "origY   = " + origY
				Print "offsetX = " + offsetX
				Print "offsetY = " + offsetY
				Print "index   = " + index
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
	
	Method Load:GameImage(name:String, nameoverride:String = "", midhandle:Bool=True, ignoreCache:Bool=False, readPixels:Bool = False, maskRed:Int = 0, maskGreen:Int = 0, maskBlue:Int = 0)
		' check if we already have the image in the bank!
		Local storeKey:String = nameoverride.ToUpper()
		If storeKey = "" Then storeKey = StripAll(name.ToUpper())
		If Not ignoreCache And Self.Contains(storeKey) Then Return Self.Get(storeKey)
		
		' discard the old image if it's there
		If Self.Contains(storeKey) Then Self.Get(storeKey).image.Discard()
		Local i:GameImage = New GameImage
		i.Load(path + name, midhandle, readPixels, maskRed, maskGreen, maskBlue)
		i.name = storeKey
		Self.Set(i.name, i)
		Return i
	End
	
	Method LoadAnim:GameImage(name:String, w%, h%, total%, tmpImage:Image, midhandle:Bool=True, ignoreCache:Bool=False, nameoverride:String = "", readPixels:Bool = False, maskRed:Int = 0, maskGreen:Int = 0, maskBlue:Int = 0)
		' check if we already have the image in the bank!
		Local storeKey:String = nameoverride.ToUpper()
		If storeKey = "" Then storeKey = StripAll(name.ToUpper())
		If Not ignoreCache And Self.Contains(storeKey) Then Return Self.Get(storeKey)
		
		' discard the old image if it's there
		If Self.Contains(storeKey) Then Self.Get(storeKey).image.Discard()

		Local i:GameImage = New GameImage
		i.LoadAnim(path + name, w, h, total, tmpImage, midhandle, readPixels, maskRed, maskGreen, maskBlue)
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
	
	Method Find:GameImage(name:String)
		name = name.ToUpper()

		' debug: print all keys in the map
		If game.debugOn
			For Local key:String = Eachin Self.Keys()
				Print key + " is stored in the image map."
			Next
		End
	   	
		Local i:GameImage = Self.Get(name)
		AssertNotNull(i, "Image '" + name + "' not found in the ImageBank")
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

'summary: GameImage Class
Class GameImage

Private
	Field pixels:Int[]
	Field maskRed:Int = 0
	Field maskGreen:Int = 0
	Field maskBlue:Int = 0
	
Public
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
	
	Field subX:Int
	Field subY:Int
	Field atlasName:String

	Field readPixels:Bool
	Field readPixelsComplete:Bool = False

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
	
	Method Load:Void(file:String, midhandle:Bool = True, readPixels:Bool = False, maskRed:Int = 0, maskGreen:Int = 0, maskBlue:Int = 0)
		name = StripAll(file.ToUpper())
		image = LoadBitmap(file)	
		CalcSize()
		MidHandle(midhandle)
		pixels = New Int[image.Width() * image.Height()]
		Self.readPixels = readPixels
		SetMaskColor(maskRed, maskGreen, maskBlue)
	End
	
	Method LoadAnim:Void(file:String, w:Int, h:Int, total%, tmpImage:Image, midhandle:Bool=True, readPixels:Bool = False, maskRed:Int = 0, maskGreen:Int = 0, maskBlue:Int = 0)
		name = StripAll(file.ToUpper())
		image = LoadAnimBitmap(file, w, h, total, tmpImage)	
		CalcSize()
		MidHandle(midhandle)
		pixels = New Int[image.Width() * image.Height()]
		Self.readPixels = readPixels
		SetMaskColor(maskRed, maskGreen, maskBlue)
	End
	
	Method LoadTileset:Void(file:String, tileWidth:Int, tileHeight:Int, tileMargin:Int = 0, tileSpacing:Int = 0, midhandle:Bool=False, readPixels:Bool = False, maskRed:Int = 0, maskGreen:Int = 0, maskBlue:Int = 0)
		Load(file, midhandle)
		Self.tileWidth = tileWidth
		Self.tileHeight = tileHeight
		Self.tileMargin = tileMargin
		Self.tileSpacing = tileSpacing
		tileCountX = (w - tileMargin) / (tileWidth + tileSpacing)
		tileCountY = (h - tileMargin) / (tileHeight + tileSpacing)
		tileCount = tileCountX * tileCountY
		pixels = New Int[image.Width() * image.Height()]
		Self.readPixels = readPixels
		SetMaskColor(maskRed, maskGreen, maskBlue)
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
	
	Method ReadPixelsArray:Void()
		Cls 0, 0, 0
		Local posX:Int = SCREEN_WIDTH2
		Local posY:Int = SCREEN_HEIGHT2
		DrawImage Self.image, posX, posY
		If readPixels
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
	
	Method Load:GameSound(name:String, nameoverride:String = "", ignoreCache:Bool = False, soundDelay:Int=0)
		' check if we already have the sound in the bank!
		Local storeKey:String = nameoverride.ToUpper()
		If storeKey = "" Then storeKey = StripAll(name.ToUpper())
		If Not ignoreCache And Self.Contains(storeKey) Then Return Self.Get(storeKey)
		
		' discard the old sound if it's there
		If Self.Contains(storeKey) Then Self.Get(storeKey).sound.Discard()
		
		Local s:GameSound = New GameSound
		s.Load(name)
		s.name = storeKey
		s.soundDelay = soundDelay
		Self.Set(s.name, s)
		Return s
	End
	   
	Method Find:GameSound(name:String)
		name = name.ToUpper()

		' debug: print all keys in the map
		If  game.debugOn
			For Local key:String = Eachin Self.Keys()
				Print key + " is stored in the sound map."
			Next
		End
		
		Local i:GameSound =  Self.Get(name)
		AssertNotNull(i, "Sound '" + name + "' not found in the SoundBank")
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
	Field loopChannelList:IntArrayList = New IntArrayList
	Field soundAvailableMillis:Int
	Field soundDelay:Int
	Field stopChannelBeforePlaying:Bool = true
	
	Method Load:Void(file$)
	
		If file.Contains(".wav") Or file.Contains(".ogg") Or file.Contains(".mp3") Or file.Contains(".m4a")  Or file.Contains(".wma") Then
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
	
	Method Play:Bool(playChannel:Int = -1, force:Bool=False)
		If force Or soundDelay = 0 Or soundAvailableMillis < dt.currentticks
			if stopChannelBeforePlaying And Self.IsPlaying()
				Self.Stop()
			End
			channel = SoundPlayer.PlayFx(sound, pan, rate, volume * (game.soundVolume / 100.0), loop, playChannel)
			If loop = 1
				loopChannelList.Add(channel)
			End
			soundAvailableMillis = dt.currentticks + soundDelay
			Return True
		End
		Return False
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
	Field dx:Float, dy:Float
	Field speedX:Float, speedY:Float, speed:Float
	Field maxXSpeed:Float, maxYSpeed:Float
	Field image:GameImage
	Field scaleX:Float = 1, scaleY:Float = 1

	Field red:Int = 255, green:Int = 255, blue:Int = 255, alpha:Float = 1
	Field hitBox:HitBox

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
	
	'summary: Animation process, deals with changing frames. Returns 1 if the animation has finished (only for non looping animations).
	Method UpdateAnimation:Int()
		Local rv:Int = 0
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
		Return rv
	End
	
	Method ResetAnim:Int()
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
	
	Method Draw:Void(offsetx:Float = 0, offsety:Float = 0, rounded:Bool = False)
		If Not visible Then Return
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
	'		DrawRectOutline(x + hitBoxX, y + hitBoxY, hitBoxWidth, hitBoxHeight)
	'	End
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
	
	Method Collide:Int(sprite:Sprite)
		Return RectsOverlap(x + hitBox.x, y + hitBox.y, hitBox.w, hitBox.h,
							sprite.x +sprite.hitBox.x, sprite.y + sprite.hitBox.y, sprite.hitBox.w, sprite.hitBox.h)
	End
		
	Method SetHitBox:Void(hitX:Int, hitY:Int, hitWidth:Int, hitHeight:Int)
		hitBox = New HitBox(hitX, hitY, hitWidth, hitHeight)
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
	
	Function DrawAll:Void(offsetx:Float = 0, offsety:Float = 0)
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

'summary: Simple Mouse functions class
Class DiddyMouse
	Field lastX:Int
	Field lastY:Int

	Method New()
		MouseZInit()
	End
	
	'summary: Returns the MouseX speed
	Method MouseXSpeed:Int()
		Return game.mouseX - lastX
	End
	
	'summary: Returns the MouseY speed
	Method MouseYSpeed:Int()
		Return game.mouseY - lastY
	End
	
	'summary: Updates the last positions
	Method Update:Void()
		lastX = game.mouseX
		lastY = game.mouseY
	End
End

'summary: Wrapper function for MouseXSpeed
Function MouseXSpeed:Int()
	Return game.diddyMouse.MouseXSpeed()
End

'summary: Wrapper function for MouseYSpeed
Function MouseYSpeed:Int()
	Return game.diddyMouse.MouseYSpeed()
End
