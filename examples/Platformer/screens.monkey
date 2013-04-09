#Rem
Copyright (c) 2011 Steve Revill and Shane Woolcock
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#End

Import diddy
Import level
Import gameobjects

Global titleScreen:TitleScreen
Global gameScreen:GameScreen

Class TitleScreen extends Screen
	Field backgroundImage:Image
	
	Method New()
		name = "Title"
	End
	
	Method Start:Void()
		backgroundImage = LoadImage(diddyGame.images.path + "title_screen.jpg")
	End
	
	Method Render:Void()
		Cls
		DrawImage backgroundImage, 0, 0
		DrawText "PRESS SPACE TO PLAY", SCREEN_WIDTH2, 260, 0.5, 0.5
		DrawText "PRESS ESCAPE TO QUIT", SCREEN_WIDTH2, 290, 0.5, 0.5
		DrawText "GRAPHICS BY MARC RUSSELL", SCREEN_WIDTH2, 440, 0.5, 0.5
		DrawText "SPICYPIXEL.NET", SCREEN_WIDTH2, 460, 0.5, 0.5
	End
	
	Method Update:Void()
		if KeyHit(KEY_SPACE)
			FadeToScreen(gameScreen)
		End
		If KeyHit(KEY_ESCAPE)
			FadeToScreen(diddyGame.exitScreen)
		End
	End
End

Class GameScreen extends Screen
	Field player:Player
	Field tilemap:MyTileMap
	Field backgroundImage:Image
	
	Method New()
		name = "Game"
	End
	
	Method Start:Void()
		diddyGame.scrollX = 0
		backgroundImage = LoadImage(diddyGame.images.path + "area01_bkg0.png")
		Local reader:MyTiledTileMapReader = New MyTiledTileMapReader
		Local tm:TileMap = reader.LoadMap("levels/level1.tmx")
		tilemap = MyTileMap(tm)
		Local playerStart:TileMapObject = tilemap.FindObjectByName("playerStart")
		player = New Player(diddyGame.images.Find("gripe.stand_right"), playerStart.x, playerStart.y)
		
		
	End
	
	Method Render:Void()
		Cls
		DrawImage backgroundImage, 0, 0
		tilemap.RenderMap(diddyGame.scrollX, diddyGame.scrollY, SCREEN_WIDTH, SCREEN_HEIGHT, 1, 1)
		player.Draw(diddyGame.scrollX, diddyGame.scrollY, True)
		Local status:String = ""
		Select player.status
			Case player.STANDING
				status = "STANDING"
			Case player.WALKING
				status = "WALKING"
			Case player.TURNING
				status = "TURNING"
			Case player.DIE
				status = "DIEING"
		End
		if player.jumping Then status = "JUMPING"
		DrawText "STATUS: " + status, 10, 10
	End
	
	Method Update:Void()
		player.Update()
		If KeyDown(KEY_W) Then diddyGame.scrollY -= 4
		If KeyDown(KEY_S) Then diddyGame.scrollY += 4
		If KeyDown(KEY_A) Then diddyGame.scrollX -= 4
		If KeyDown(KEY_D) Then diddyGame.scrollX += 4
		If KeyHit(KEY_ESCAPE)
			FadeToScreen(titleScreen)
		End
	End
End