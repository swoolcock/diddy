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
		gameScreen = New GameScreen
		Start(gameScreen)
	End
End

Class GameScreen Extends Screen
	Const max% = 100
	Field r%[max]
	Field g%[max]
	Field b%[max]
	Field x%[max]
	Field y%[max]
	Field w%[max]
	Field h%[max]

	Field pixel:Int[4]
	
	Method New()
		name = "Game"
	End
	
	Method Start:Void()
		diddyGame.screenFade.Start(50, False)
		For Local i%=0 To max-1
			r[i] = Rnd(0, 255)
			g[i] = Rnd(0, 255)
			b[i] = Rnd(0, 255)
			
			x[i] = Rnd(SCREEN_WIDTH)
			y[i] = Rnd(SCREEN_HEIGHT)
			w[i] = Rnd(100)
			h[i] = Rnd(100)
		End
		pixel[0] = 0
		pixel[1] = 0
		pixel[2] = 0
		pixel[3] = 1
	End
	
	Method Render:Void()
		Cls(1,2,3)
		For Local i%=0 To max-1
			SetColor(r[i],g[i],b[i])
			DrawRect x[i], y[i], w[i], h[i]
		Next

		SetColor pixel[0], pixel[1], pixel[2]
		DrawRect diddyGame.mouseX+12, diddyGame.mouseY+12, 50, 50
		SetColor pixel[0], pixel[1], pixel[2]
		DrawOval diddyGame.mouseX+12, diddyGame.mouseY+62, 50, 50
		
		SetColor 255,255,255

		DrawText "Red   = " + pixel[0], 10, 60
		DrawText "Green = " + pixel[1], 10, 70
		DrawText "Blue  = " + pixel[2], 10, 80
		
		If MouseDown()
			pixel = GetPixel(diddyGame.mouseX, diddyGame.mouseY)
		End
	End

	Method Update:Void()
		If KeyHit(KEY_ESCAPE)
			FadeToScreen(diddyGame.exitScreen)
		End
	End

End