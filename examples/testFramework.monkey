Strict

Import mojo
Import diddy

Function Main:Int()
	game = new MyGame()
	Return 0
End Function

Global titleScreen:TitleScreen
Global gameScreen:GameScreen

Class MyGame extends DiddyApp
	Method OnCreate:Int()
		Super.OnCreate()

		titleScreen = New TitleScreen
		gameScreen = new GameScreen
		titleScreen.PreStart()
		return 0
	End Method
End

Class TitleScreen Extends Screen
	Method New()
		name = "Title"
	End
	
	Method Start:Void()
		game.screenFade.Start(50, false)
	End Method
	
	Method Render:Void()
		Cls
		DrawText "TITLE SCREEN!", SCREEN_WIDTH2, SCREEN_HEIGHT2, 0.5, 0.5
		DrawText "Press Space to Play!", SCREEN_WIDTH2, SCREEN_HEIGHT2 + 20, 0.5, 0.5
		DrawText "Press Escape to Quit!", SCREEN_WIDTH2, SCREEN_HEIGHT2 + 40, 0.5, 0.5
	End
	
	Method Update:Void()
		If KeyHit(KEY_SPACE)
			game.screenFade.Start(50, true)
			game.nextScreen = gameScreen
		End
		
		If KeyHit(KEY_ESCAPE)
			game.screenFade.Start(50, true)
			game.nextScreen = game.exitScreen
		End
	End
End

Class GameScreen Extends Screen
	Method New()
		name = "Game"
	End
	
	Method Start:Void()
		game.screenFade.Start(50, false)
	End Method
	
	Method Render:Void()
		Cls
		DrawText "GAME SCREEN!", SCREEN_WIDTH2, SCREEN_HEIGHT2, 0.5, 0.5
	End
	
	Method Update:Void()
		If KeyHit(KEY_ESCAPE)
			game.screenFade.Start(50, true)
			game.nextScreen = titleScreen
		End
	End
End
