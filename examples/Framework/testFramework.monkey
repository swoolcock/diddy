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

Global titleScreen:TitleScreen
Global gameScreen:GameScreen

Const GRAVITY:Float = 0.06

Class MyGame extends DiddyApp
	Method Create:Void()
		LoadImages()
		titleScreen = New TitleScreen
		gameScreen = new GameScreen
		Start(titleScreen)
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
		' game.Start forces an autofade, so we don't need to manually fade in anymore
	End
	
	Method Render:Void()
		Cls
		DrawText "TITLE SCREEN!", SCREEN_WIDTH2, SCREEN_HEIGHT2, 0.5, 0.5
		DrawText "Click to Play!", SCREEN_WIDTH2, SCREEN_HEIGHT2 + 20, 0.5, 0.5
		DrawText "Escape to Quit!", SCREEN_WIDTH2, SCREEN_HEIGHT2 + 40, 0.5, 0.5
	End
	
	Method Update:Void()
		If MouseHit(MOUSE_LEFT)
			' triggers a fade out and configures the gameScreen so that it will auto fade in
			FadeToScreen(gameScreen)
		End
		
		If KeyHit(KEY_ESCAPE)
			' fading to Null is the same as fading to game.exitScreen (which exits the game)
			FadeToScreen(Null)
		End
	End
End

Class GameScreen Extends Screen
	Field spark:GameImage
	
	Method New()
		name = "Game"
	End
	
	Method Start:Void()
		spark = diddyGame.images.Find("spark")
		' FadeToScreen forces an autofade, so we don't need to manually fade in anymore
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
			FadeToScreen(titleScreen)
		End
		If MouseDown(MOUSE_LEFT)
			For Local i% = 1 To 3
				Particle.Create(spark, diddyGame.mouseX , diddyGame.mouseY, Rnd(-2,2), Rnd(-3,-1), GRAVITY/4, 2000)
			Next
		End
		Particle.UpdateAll()
	End
	
	Method PostFadeOut:Void()
		Particle.Clear()
		Super.PostFadeOut()
	End
End



