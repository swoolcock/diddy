Strict

Import diddy

Global musicExt:String

Function Main:Int()
	game = new MyGame()
	game.debugOn = True
	Return 0
End Function

Global titleScreen:TitleScreen
Global gameScreen:GameScreen

Class MyGame extends DiddyApp
	Method OnCreate:Int()
		Super.OnCreate()
		
#If TARGET="glfw"
		'GLFW supports WAV only
		musicExt=".wav"
#Elseif TARGET="html5"
		musicExt=".ogg" 'use M4a for IE...
#Elseif TARGET="flash"
		'Flash supports MP3, M4A online, but only MP3 embedded.
		musicExt=".mp3"
#Elseif TARGET="android"
		'Android supports WAV, OGG, MP3, M4A (M4A only appears to work for music though)
		musicExt=".ogg"
#Elseif TARGET="xna"
		'XNA supports WAV, MP3
		musicExt=".wav"
#Elseif TARGET="ios"
		'iOS supports WAV, MP3, M4A
		musicExt=".m4a"
#End

		titleScreen = New TitleScreen
		gameScreen = new GameScreen
		titleScreen.PreStart()
		return 0
	End

End

Class TitleScreen Extends Screen
	Method New()
		name = "Title"
	End
	
	Method Start:Void()
		game.MusicPlay("NewsTheme"+musicExt, 1)
		game.screenFade.Start(50, False, True, True)
		
	End
	
	Method Render:Void()
		Cls
		DrawText "TITLE SCREEN!", SCREEN_WIDTH2, SCREEN_HEIGHT2, 0.5, 0.5
		DrawText "Click to Play!", SCREEN_WIDTH2, SCREEN_HEIGHT2 + 20, 0.5, 0.5
		DrawText "Escape to Quit!", SCREEN_WIDTH2, SCREEN_HEIGHT2 + 40, 0.5, 0.5
		DrawText "Music: Kevin Macleod", SCREEN_WIDTH2, SCREEN_HEIGHT2 + 100, 0.5, 0.5
	End
	
	Method Update:Void()
		If MouseHit(MOUSE_LEFT)
			game.screenFade.Start(50, True, True, True)
			game.nextScreen = gameScreen
		End
		
		If KeyHit(KEY_ESCAPE)
			game.screenFade.Start(50, True, True, True)
			game.nextScreen = game.exitScreen
		End
	End
End

Class GameScreen Extends Screen
	
	Method New()
		name = "Game"
	End
	
	Method Start:Void()
		game.screenFade.Start(50, False, True, True)
		game.MusicPlay("SplitInSynapse"+musicExt, 1)
	End
	
	Method Render:Void()
		Cls
		DrawText "GAME SCREEN!", SCREEN_WIDTH2, SCREEN_HEIGHT2, 0.5, 0.5
	End
	
	Method Update:Void()
		If KeyHit(KEY_ESCAPE) or MouseHit(MOUSE_LEFT)
			game.screenFade.Start(50, True, True, True)
			game.nextScreen = titleScreen
		End
	End
End