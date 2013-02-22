#ANDROID_SCREEN_ORIENTATION="sensor"

Strict

Import diddy

Global screen:TestScreen

Function Main:Int()
	New MyGame()
	Return 0
End

Class MyGame Extends DiddyApp
	Method Create:Void()
		SetGraphics(320,480)
		SetScreenSize(960, 640, True)
		screen = New TestScreen()
		Start(screen)
	End
End

Class TestScreen Extends Screen
	Field logo:GameImage
	Field landscape:Int = True
	
	Method New()
		name = "title"
	End
		
	Method Start:Void()
		logo = diddyGame.images.Load("logo.png", "logo", False)
	End
	
	Method Render:Void()
		Cls
		logo.Draw(0,0)
	End
	
	Method ExtraRender:Void()
		Local starty% = 60
		Local height% = 20
		DrawText "Device Width x Height = "+DEVICE_WIDTH+" x "+DEVICE_HEIGHT, 0, DEVICE_HEIGHT - starty
		starty-=height
		DrawText "Virtual Width x Height = "+FormatNumber(SCREEN_WIDTH, 3)+" x "+FormatNumber(SCREEN_HEIGHT,3), 0, DEVICE_HEIGHT - starty
		starty-=height
		DrawText "Press Space to flip between landscape and portrait", 0, DEVICE_HEIGHT - starty
	End
	
	Method Update:Void()
		If KeyHit(KEY_SPACE) Then
			landscape = Not landscape
			If landscape
				SetGraphics(480, 320)
			Else
				SetGraphics(320, 480)
			End
			diddyGame.SetScreenSize(960, 640, True)
		End
		If KeyHit(KEY_ESCAPE)
			FadeToScreen(diddyGame.exitScreen)
		End
	End
End 