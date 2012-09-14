Strict

Import diddy

Global musicExt:String

Function Main:Int()
	new MyGame()
	Return 0
End

Global titleScreen:TitleScreen
Global gameScreen:GameScreen

Class MyGame extends DiddyApp
	Method Create:Void()
		debugOn = True
		musicExt=".ogg" 
		titleScreen = New TitleScreen
		gameScreen = new GameScreen
		Start(titleScreen)
	End

End

Class TitleScreen Extends Screen
	Method New()
		name = "Title"
	End
	
	Method Start:Void()
		game.MusicPlay("NewsTheme"+musicExt, 1)
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
			FadeToScreen(gameScreen)
		End
		
		If KeyHit(KEY_ESCAPE)
			FadeToScreen(game.exitScreen)
		End
	End
End

Class GameScreen Extends Screen
	
	Method New()
		name = "Game"
	End
	
	Method Start:Void()
		game.MusicPlay("SplitInSynapse"+musicExt, 1)
	End
	
	Method Render:Void()
		Cls
		DrawText "GAME SCREEN!", SCREEN_WIDTH2, SCREEN_HEIGHT2, 0.5, 0.5
	End
	
	Method Update:Void()
		If KeyHit(KEY_ESCAPE) or MouseHit(MOUSE_LEFT)
			FadeToScreen(titleScreen)
		End
	End
End