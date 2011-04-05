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

	Field FPS% = 60
	
	' current Screen
	Field currentScreen:Screen
	' next Screen
	Field nextScreen:Screen
	' exit Screen
	Field exitScreen:ExitScreen = new ExitScreen()
	' used for fading
	Field screenFade:ScreenFade = New ScreenFade
	
	Method OnCreate:Int()
		' Store the device width and height
		SCREEN_WIDTH = DeviceWidth()
		SCREEN_HEIGHT = DeviceHeight()
		SCREEN_WIDTH2 = SCREEN_WIDTH / 2
		SCREEN_HEIGHT2 = SCREEN_HEIGHT / 2
		
		' Set the Random seed
		Seed = RealMillisecs()
		' Create the delta timer
		dt = New DeltaTimer(FPS)
		SetUpdateRate FPS

		Return 0
	End
		
	Method OnRender:Int()
		FPSCounter.Update()
		currentScreen.Render()
		If screenFade.active then screenFade.Render()
		Return 0
	End
	
	Method OnUpdate:Int()
		dt.UpdateDelta()
		FPSCounter.Update()
		
		If screenFade.active then screenFade.Update()
		currentScreen.Update()
		Return 0
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
