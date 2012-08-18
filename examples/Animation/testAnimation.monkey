Strict

Import diddy

Function Main:Int()
	game = New MyGame()
	Return 0
End Function

Global gameScreen:GameScreen
Global titleScreen:TitleScreen

Class MyGame Extends DiddyApp

	Method OnCreate:Int()
		Super.OnCreate()
			
		LoadImages()
		
		gameScreen = New GameScreen
		titleScreen = New TitleScreen
		
		titleScreen.PreStart()
		
		Return 0
	End
	
	'***********************
	'* Load Images
	'***********************
	Method LoadImages:Void()
		' create tmpImage for animations
		Local tmpImage:Image
		
		images.LoadAnim("Ship1.png", 64, 64, 7, tmpImage)
	End
	
	Method OverrideUpdate:Void()
	End
End


Class TitleScreen Extends Screen

	Method New()
		name = "Title"
	End

	Method Start:Void()
		game.screenFade.Start(50, False)
	End
	
	Method Render:Void()
		Cls
		DrawText "TITLE SCREEN!", SCREEN_WIDTH2, SCREEN_HEIGHT2, 0.5, 0.5
		DrawText "Click to Play!", SCREEN_WIDTH2, SCREEN_HEIGHT2 + 20, 0.5, 0.5
	End

	Method Update:Void()
		If KeyHit(KEY_SPACE) Or MouseHit(0)
			game.screenFade.Start(50, True)
			game.nextScreen = gameScreen
		End
		If KeyHit(KEY_ESCAPE)
			game.screenFade.Start(50, True)
			game.nextScreen = game.exitScreen
		End
	End
End

Class GameScreen Extends Screen
	Field player:Player
	Field yPos:Float = 180.0
	
	Method New()
		name = "Game"
	End
	
	Method Start:Void()
		game.screenFade.Start(50, False)
		player = New Player(game.images.Find("Ship1"), SCREEN_WIDTH2, SCREEN_HEIGHT2)
	End
	
	Method Render:Void()
		Cls
		player.Draw()
		DrawHUD()
	End

	Method Update:Void()
		player.UpdateAnimation()
		player.Update()

		yPos -= MouseZ() * 3.0
		
		If KeyHit(KEY_1)
			player.SetFrame(0, 6, 100, False, False)
		End
		If KeyHit(KEY_2)
			player.SetFrame(0, 6, 100, False, True)			
		End
		If KeyHit(KEY_3)
			player.SetFrame(0, 6, 100, True, False)			
		End
		If KeyHit(KEY_4)
			player.SetFrame(0, 6, 100, True, True)			
		End
		
		If KeyHit(KEY_Q)
			player.SetFrame(6, 0, 100, False, False)
		End
		If KeyHit(KEY_W)
			player.SetFrame(6, 0, 100, False, True)			
		End
		If KeyHit(KEY_E)
			player.SetFrame(6, 0, 100, True, False)			
		End
		If KeyHit(KEY_R)
			player.SetFrame(6, 0, 100, True, True)			
		End
		
		If KeyHit(KEY_ESCAPE)
			game.screenFade.Start(50, True)
			game.nextScreen = titleScreen
		End
		
	End
		
	Method DrawHUD:Void()
		DrawText("frame = "+player.frame, 10, 0)
	
		If player.pingPong
			DrawText("pingPong = true" , 10, 30)
		Else
			DrawText("pingPong = false" , 10, 30)
		End
		If player.loop
			DrawText("loop = true" , 10, 60)
		Else
			DrawText("loop = false" , 10, 60)
		End	
		DrawText("startFrame = "+player.frameStart, 10, 90)
		DrawText("startEnd = "+player.frameEnd, 10, 120)
		
		DrawText("Press 1 - 4 to change animation", 10, 150)

		DrawText("Press <ESC> to return to the Title Screen", 10, SCREEN_HEIGHT-12)

		DrawText("MouseXSpeed: " + MouseXSpeed() , 10, yPos + 10)

		DrawText("MouseYSpeed: " + MouseYSpeed() , 10, yPos + 20 )
		
		FPSCounter.Draw(SCREEN_WIDTH, SCREEN_HEIGHT  - 12, 1)
		
	End
End


Class Player Extends Sprite
	Field vx:Float, vy:Float
	Field ax:Float, ay:Float
	
	Method New(gi:GameImage, x#, y#)
		Super.New(gi, x, y)
		rotation = 0
		frame = 3
	End
	
	Method Update:Void()
		Local Acceleration:Float
		
		If KeyDown(KEY_UP)
			speed+=.3
		Else If KeyDown(KEY_DOWN)
			speed-=.3
		Else
			If speed > 0
				speed-=.1
			Else
				speed+=.1
			End
		End If		
		If KeyDown(KEY_LEFT)
			Self.rotation+=2
		End If
		If KeyDown(KEY_RIGHT)
			Self.rotation-=2
		End If
		
		MoveForward()
		
		If x < 0 x = SCREEN_WIDTH
		If x > SCREEN_WIDTH x = 0
		If y < 0 y = SCREEN_HEIGHT
		If y > SCREEN_HEIGHT y = 0
	End
	
End