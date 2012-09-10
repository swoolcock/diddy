Strict

Import diddy

Function Main:Int()
	New MyGame()
	Return 0
End

Global gameScreen:GameScreen

Class MyGame Extends DiddyApp
	Method Create:Void()
		images.Load("background.png", "", False)
		SetScreenSize(480, 320)
		
		gameScreen = new GameScreen
		Start(gameScreen)
	End
End

Class GameScreen Extends Screen
	Field backgroundImg:GameImage
	
	Method New()
		name = "Game"
	End

	Method Start:Void()
		backgroundImg = game.images.Find("background")
	End
	
	Method Render:Void()
		Cls
		backgroundImg.Draw(0, 0)
	End
	
	Method ExtraRender:Void()
		DrawText "This part of the render isnt affected by the virtual resolution!", 0, 10
		DrawText "but is affected by fading!", 0, 25
	End
	
	Method DebugRender:Void()
		Local starty% = 120
		Local height% = 20
		DrawText "This part of the render isnt affected by the virtual resolution or fading either!", 0, DEVICE_HEIGHT - starty
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
			FadeToScreen(gameScreen)
		End

		game.SetScreenSize(SCREEN_WIDTH, SCREEN_HEIGHT)
		If KeyHit(KEY_ESCAPE)
			FadeToScreen(game.exitScreen)
		End
	End
End