Strict

Import diddy

Function Main:Int()
	game = New MyGame()
	Return 0
End

Global gameScreen:GameScreen

Class MyGame Extends DiddyApp
	Method OnCreate:Int()
		Super.OnCreate()
		
		images.Load("background.png", "", False)
		SetScreenSize(480, 320)
		
		gameScreen = new GameScreen
		gameScreen.PreStart()
		
		Return 0
	End
End

Class GameScreen Extends Screen
	Field backgroundImg:GameImage
	
	Method New()
		name = "Game"
	End

	Method Start:Void()
		game.screenFade.Start(50, false)
		backgroundImg = game.images.Find("background")
	End
	
	Method Render:Void()
		Cls
		backgroundImg.Draw(0, 0)
	End
	
	Method ExtraRender:Void()
		Local starty% = 120
		Local height% = 20
		DrawText "This part of the render isnt affected by the virtual resolution!", 0, DEVICE_HEIGHT - starty
		starty-=height
		DrawText "Use the cursor keys to change the virtual resolution", 0, DEVICE_HEIGHT - starty
		starty-=height
		DrawText "Press Space to reset to 480 x 320", 0, DEVICE_HEIGHT - starty
		starty-=height
		DrawText "Device Width x Height = "+DEVICE_WIDTH+" x "+DEVICE_HEIGHT, 0, DEVICE_HEIGHT - starty
		starty-=height
		DrawText "Virtual Width x Height = "+FormatNumber(SCREEN_WIDTH, 3)+" x "+FormatNumber(SCREEN_HEIGHT,3), 0, DEVICE_HEIGHT - starty

	End

	Method Update:Void()
		If KeyDown(KEY_LEFT)
			SCREEN_WIDTH-=1*dt.delta
		End
		If KeyDown(KEY_RIGHT)
			SCREEN_WIDTH+=1*dt.delta
		End
		If KeyDown(KEY_UP)
			SCREEN_HEIGHT-=1*dt.delta
		End
		If KeyDown(KEY_DOWN)
			SCREEN_HEIGHT+=1*dt.delta
		End
		If KeyHit(KEY_SPACE)
			SCREEN_WIDTH = 480
			SCREEN_HEIGHT = 320
		End
		If KeyHit(KEY_ENTER)
			game.screenFade.Start(50, true)
			game.nextScreen = gameScreen
		End

		game.SetScreenSize(SCREEN_WIDTH, SCREEN_HEIGHT)
		If KeyHit(KEY_ESCAPE)
			game.screenFade.Start(50, true)
			game.nextScreen = game.exitScreen
		End
	End
End





