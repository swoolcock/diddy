#Rem
Copyright (c) 2011 Steve Revill and Shane Woolcock
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#End

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
		backgroundImg = diddyGame.images.Find("background")
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

		diddyGame.SetScreenSize(SCREEN_WIDTH, SCREEN_HEIGHT)
		If KeyHit(KEY_ESCAPE)
			FadeToScreen(diddyGame.exitScreen)
		End
	End
End