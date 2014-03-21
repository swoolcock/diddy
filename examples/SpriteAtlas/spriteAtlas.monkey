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
		LoadImages()
		gameScreen = new GameScreen
		Start(gameScreen)
	End
	
	Method LoadImages:Void()
		' load normal sprite
		images.LoadAnim("Ship1.png", 64, 64, 7)
		' load sparrow atlas sprites
		images.LoadAtlas("sprites.xml", images.SPARROW_ATLAS, True, True)
		' load atlas zombie
		images.LoadAtlas("zombie.xml", images.SPARROW_ATLAS)
		' load libgdx atlas
		images.LoadAtlas("libgdx_sprites.txt", images.LIBGDX_ATLAS)
	End
End

Class GameScreen Extends Screen
	Field shipImage:GameImage
	Field axeAtlasImage:GameImage
	Field longswordAtlasImage:GameImage
	Field animImage:GameImage
	Field frame:Int = 0
	Field frameDelay:Float = 0
	Field maxFrameDelay:Int = 10
	Field maxFrame:Int = 14
	Field zombieImage:GameImage
	Field libGdxImage:GameImage
	Field orcImage:GameImage
	Field readComplete:Bool = False
	Field createdImage:Image
	
	Method New()
		name = "Game"
	End
	
	Method Start:Void()
		shipImage = diddyGame.images.Find("Ship1")
		axeAtlasImage = diddyGame.images.Find("axe")
		longswordAtlasImage = diddyGame.images.Find("longsword")
		animImage = diddyGame.images.FindSet("shield_kite", 64, 64, 7)
		zombieImage = diddyGame.images.FindSet("idle_left1", 128, 128, 15)
		libGdxImage = diddyGame.images.Find("a_shield_round_gold")
		orcImage = diddyGame.images.Find("orc_1")
	End
	
	Method Render:Void()
		If Not readComplete
			diddyGame.images.ReadPixelsArray()
			readComplete = True
		End
		Cls
		DrawText "GAME SCREEN!", SCREEN_WIDTH2, 10, 0.5, 0.5
		FPSCounter.Draw(0, 0)
		shipImage.Draw(100, 100, 0, 1, 1, 3)
		axeAtlasImage.Draw(200, 100)
		longswordAtlasImage.Draw(300, 100)
		For Local f:Int = 0 Until animImage.image.Frames()
			animImage.Draw(100 + f * animImage.w, 200, 0, 1, 1, f)
		Next
		libGdxImage.Draw(100, 300)
		orcImage.Draw(200, 300)
		DrawText "Zombie by: Clint Bellanger (CC-BY-SA 3.0)",SCREEN_WIDTH2, 460, .5, .5
		zombieImage.Draw(300, 300, 0, 1, 1, frame)
		DrawText "Press 1 to Create an image",400, 300
		If createdImage
			DrawImage createdImage , 400, 300
		End
	End
	
	Method Update:Void()
		If KeyHit(KEY_1)
			Local gi:GameImage = diddyGame.images.Find("longsword")
			createdImage = CreateImage(gi.image.Width(), gi.image.Height())
			createdImage.WritePixels(gi.Pixels, 0, 0, createdImage.Width(), createdImage.Height())
		End
		
		frameDelay+=1*dt.delta
		If frameDelay > maxFrameDelay
			frame+=1
			frameDelay = 0
			If frame > maxFrame Then frame = 0
		End
	
		If KeyHit(KEY_ESCAPE)
			FadeToScreen(Null)
		End
	End
End