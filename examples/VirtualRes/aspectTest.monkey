#Rem
Copyright (c) 2011 Steve Revill and Shane Woolcock
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#End

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