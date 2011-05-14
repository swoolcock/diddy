Strict

Import mojo
import diddy

Function Main:Int()
	game = new MyGame()
	Return 0
End Function

Global gameScreen:GameScreen
Global titleScreen:TitleScreen

Class MyGame Extends DiddyApp

	Method OnCreate:Int()
		Super.OnCreate()
			
		LoadImages()
		
		gameScreen = new GameScreen
		titleScreen = new TitleScreen
		
		titleScreen.PreStart()
		
		Return 0
	End
	
	'***********************
	'* Load Images
	'***********************
	Method LoadImages:Void()
		' create tmpImage for animations
		local tmpImage:Image
		
		images.LoadAnim("Ship1.png", 64, 64, 7, tmpImage)
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
	End

	Method Update:Void()
		if KeyHit(KEY_SPACE) or MouseHit(0)
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
	Field player:Player

	Method New()
		name = "Game"
	End
	
	Method Start:Void()
		game.screenFade.Start(50, false)
		player = new Player(game.images.Find("Ship1"), SCREEN_WIDTH2, SCREEN_HEIGHT2)
	End
	
	Method Render:Void()
		Cls
		player.Draw()
		DrawHUD()
	End

	Method Update:Void()
		player.UpdateAnimation()
		player.Update()
		
		if KeyHit(KEY_1)
			player.SetFrame(0, 6, 100, false, false)
		End
		if KeyHit(KEY_2)
			player.SetFrame(0, 6, 100, false, true)			
		End
		if KeyHit(KEY_3)
			player.SetFrame(0, 6, 100, true, false)			
		End
		if KeyHit(KEY_4)
			player.SetFrame(0, 6, 100, true, true)			
		End
		
		if KeyHit(KEY_Q)
			player.SetFrame(6, 0, 100, false, false)
		End
		if KeyHit(KEY_W)
			player.SetFrame(6, 0, 100, false, true)			
		End
		if KeyHit(KEY_E)
			player.SetFrame(6, 0, 100, true, false)			
		End
		if KeyHit(KEY_R)
			player.SetFrame(6, 0, 100, true, true)			
		End
		
		if KeyHit(KEY_ESCAPE)
			game.screenFade.Start(50, true)
			game.nextScreen = titleScreen
		End
	End
		
	Method DrawHUD:Void()
		DrawText("frame = "+player.frame, 10, 0)
	
		If player.pingPong
			DrawText("pingPong = true" , 10, 30)
		else
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

		
		FPSCounter.Draw(SCREEN_WIDTH, SCREEN_HEIGHT  - 12, 1)
		
	End
End


Class Player Extends Sprite
    Field vx:Float, vy:Float
    Field ax:Float, ay:Float
    Field direction:Float
	
	Method New(gi:GameImage, x#, y#)
		Super.New(gi, x, y)
		direction = -90
		frame = 3
	End
	
	Method Update:Void()
		Local Acceleration:Float
		
		If KeyDown(KEY_UP)
			Acceleration=.2
		else If KeyDown(KEY_DOWN)
			Acceleration=-.2
		Else
			Acceleration=0
		End If		
		If KeyDown(KEY_LEFT)
			direction-=2
			self.rotation+=2
		End If
		If KeyDown(KEY_RIGHT)
			direction+=2
			self.rotation-=2
		End If
		
		Local ax:Float = Acceleration * Cos(direction)
		Local ay:Float = Acceleration * Sin(direction)
		
		vx+=ax 
		vy+=ay
		x+=vx * dt.delta
		y+=vy * dt.delta
		
		If x < 0 x = SCREEN_WIDTH
		If x > SCREEN_WIDTH x = 0
		If y < 0 y = SCREEN_HEIGHT
		If y > SCREEN_HEIGHT y = 0
	End
	
End

