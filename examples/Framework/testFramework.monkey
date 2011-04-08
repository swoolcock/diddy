Strict

Import mojo
Import diddy

Function Main:Int()
	game = new MyGame()
	Return 0
End Function

Global titleScreen:TitleScreen
Global gameScreen:GameScreen

Const GRAVITY:Float = 0.06

Class MyGame extends DiddyApp
	Method OnCreate:Int()
		Super.OnCreate()
		LoadImages()
		titleScreen = New TitleScreen
		gameScreen = new GameScreen
		titleScreen.PreStart()
		return 0
	End
	
	'***********************
	'* Load Images
	'***********************
	Method LoadImages:Void()
		' create tmpImage for animations
		Local tmpImage:Image
		
		images.Load("spark.png")
	End
End

Class TitleScreen Extends Screen
	Method New()
		name = "Title"
	End
	
	Method Start:Void()
		game.screenFade.Start(50, false)
	End
	
	Method Render:Void()
		Cls
		DrawText "TITLE SCREEN!", SCREEN_WIDTH2, SCREEN_HEIGHT2, 0.5, 0.5
		DrawText "Click to Play!", SCREEN_WIDTH2, SCREEN_HEIGHT2 + 20, 0.5, 0.5
		DrawText "Escape to Quit!", SCREEN_WIDTH2, SCREEN_HEIGHT2 + 40, 0.5, 0.5
	End
	
	Method Update:Void()
		If MouseHit(MOUSE_LEFT)
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
	Field spark:GameImage
	
	Method New()
		name = "Game"
	End
	
	Method Start:Void()
		spark = game.images.Find("spark")
		
		game.screenFade.Start(50, false)
	End
	
	Method Render:Void()
		Cls
		DrawText "GAME SCREEN!", SCREEN_WIDTH2, SCREEN_HEIGHT2, 0.5, 0.5
		DrawText "Mouse Click to Create Particles!", SCREEN_WIDTH2, SCREEN_HEIGHT2 + 20, 0.5, 0.5
		Particle.DrawAll()
		FPSCounter.Draw(0,0)
	End
	
	Method Update:Void()
		If KeyHit(KEY_ESCAPE)
			game.screenFade.Start(50, true)
			game.nextScreen = titleScreen
		End
		If MouseDown(MOUSE_LEFT)
			For Local i% = 1 To 3
				Particle.Create(spark, game.mouseX , game.mouseY, Rnd(-2,2), Rnd(-3,-1), GRAVITY/4, 2000)
			Next
		End
		Particle.UpdateAll()
	End
	
	Method PostFadeOut:Void()
		Particle.Clear()
		Super.PostFadeOut()
	End
End


