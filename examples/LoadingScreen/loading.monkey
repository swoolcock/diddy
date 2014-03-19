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
		LoadData()
	End
	
	Method LoadData:Void()
		diddyGame.loadingScreen.Init("graphics/loadingScreen.png", "graphics/loadingbar.png", "graphics/loadingbarempty.png", 4, -1, 400)
		diddyGame.loadingScreen.destination = gameScreen		
		Start(diddyGame.loadingScreen)
		LoadImages()
	End
	
	Method LoadImages:Void()
		images.Load("Ship1.png")
		diddyGame.loadingScreen.loadingBar.Progress()
		
		images.Load("sprites.png")
		diddyGame.loadingScreen.loadingBar.Progress()

		images.Load("zombie_0.png")
		diddyGame.loadingScreen.loadingBar.Progress()

		images.Load("libgdx_sprites.png")
		diddyGame.loadingScreen.loadingBar.Progress()
	End
End

Class GameScreen Extends Screen
	Field shipImage:GameImage
	Field spritesImage:GameImage
	Field zombieImage:GameImage
	Field libgdx_spritesImage:GameImage

	Method New()
		name = "Game"
	End
	
	Method Start:Void()
		shipImage = diddyGame.images.Find("Ship1")
		spritesImage = diddyGame.images.Find("sprites")
		zombieImage = diddyGame.images.Find("zombie_0")
		libgdx_spritesImage = diddyGame.images.Find("libgdx_sprites")
	End
	
	Method Render:Void()
		Cls
		DrawText "GAME SCREEN!", SCREEN_WIDTH2, 10, 0.5, 0.5
		shipImage.Draw(SCREEN_WIDTH2, 100)
		spritesImage.Draw(SCREEN_WIDTH2, 200)
		zombieImage.Draw(SCREEN_WIDTH2, 300)
		libgdx_spritesImage.Draw(SCREEN_WIDTH2, 400)
		FPSCounter.Draw(0, 0)
	End
	
	Method Update:Void()
		If KeyHit(KEY_ESCAPE)
			FadeToScreen(Null)
		End
	End
End