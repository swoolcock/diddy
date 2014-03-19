#Rem
Copyright (c) 2011 Steve Revill and Shane Woolcock
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#End

Strict

Import diddy

Global musicExt:String

Function Main:Int()
	new MyGame()
	Return 0
End

Global titleScreen:TitleScreen
Global gameScreen:GameScreen

Class MyGame extends DiddyApp
	Method Create:Void()
		debugOn = True
		musicExt=".ogg" 
		titleScreen = New TitleScreen
		gameScreen = new GameScreen
		Start(titleScreen)
	End

End

Class TitleScreen Extends Screen
	Method New()
		name = "Title"
	End
	
	Method Start:Void()
		diddyGame.MusicPlay("NewsTheme"+musicExt, 1)
	End
	
	Method Render:Void()
		Cls
		DrawText "TITLE SCREEN!", SCREEN_WIDTH2, SCREEN_HEIGHT2, 0.5, 0.5
		DrawText "Click to Play!", SCREEN_WIDTH2, SCREEN_HEIGHT2 + 20, 0.5, 0.5
		DrawText "Escape to Quit!", SCREEN_WIDTH2, SCREEN_HEIGHT2 + 40, 0.5, 0.5
		DrawText "Music: Kevin Macleod", SCREEN_WIDTH2, SCREEN_HEIGHT2 + 100, 0.5, 0.5
	End
	
	Method Update:Void()
		If MouseHit(MOUSE_LEFT)
			FadeToScreen(gameScreen)
		End
		
		If KeyHit(KEY_ESCAPE)
			FadeToScreen(diddyGame.exitScreen)
		End
	End
End

Class GameScreen Extends Screen
	
	Method New()
		name = "Game"
	End
	
	Method Start:Void()
		diddyGame.MusicPlay("SplitInSynapse"+musicExt, 1)
	End
	
	Method Render:Void()
		Cls
		DrawText "GAME SCREEN!", SCREEN_WIDTH2, SCREEN_HEIGHT2, 0.5, 0.5
	End
	
	Method Update:Void()
		If KeyHit(KEY_ESCAPE) or MouseHit(MOUSE_LEFT)
			FadeToScreen(titleScreen)
		End
	End
End