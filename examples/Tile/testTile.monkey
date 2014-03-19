#Rem
Copyright (c) 2011 Steve Revill and Shane Woolcock
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#End

Strict

Import diddy

Function Main:Int()
	New MyGame
	Return 0
End

Global titleScreen:TitleScreen
Global gameScreen:GameScreen

Class MyGame Extends DiddyApp
	Method Create:Void()
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
	End
	
	Method Render:Void()
		Cls
		DrawText "TITLE SCREEN", SCREEN_WIDTH2, SCREEN_HEIGHT2, 0.5, 0.5
		DrawText "CLICK TO PLAY", SCREEN_WIDTH2, SCREEN_HEIGHT2 + 10, 0.5, 0.5
		FPSCounter.Draw(0,0)
	End
	
	Method Update:Void()
		If diddyGame.mouseHit
			FadeToScreen(gameScreen)
		End
	End
End

Class GameScreen Extends Screen
	Field tilemap:MyTileMap
	Field offsetX:Int, offsetY:Int
	Field str$
	
	Method New()
		name = "Game"
	End

	Method Start:Void()
		diddyGame.images.LoadAnim("tileslostgarden.png", 20, 20, 21, Null, True, False)	
		Local reader:MyTiledTileMapReader = New MyTiledTileMapReader
		Local tm:TileMap = reader.LoadMap("maps/map.xml")
		tilemap = MyTileMap(tm)
	End
	
	Method Render:Void()
		Cls
		tilemap.RenderMap(offsetX, offsetY, SCREEN_WIDTH, SCREEN_HEIGHT)
		
		FPSCounter.Draw(0,0)
	End
	
	Method Update:Void()
		If KeyHit(KEY_ESCAPE)
			FadeToScreen(diddyGame.exitScreen)
		End
		If KeyDown(KEY_UP) Then offsetY -= 4
		If KeyDown(KEY_DOWN) Then offsetY += 4
		If KeyDown(KEY_LEFT) Then offsetX -= 4
		If KeyDown(KEY_RIGHT) Then offsetX += 4
		
		If MouseDown(0)
			tilemap.ChangeTile(diddyGame.mouseX + offsetX, diddyGame.mouseY + offsetY, 4, "Tile Layer 1")
		Endif
		
		tilemap.UpdateAnimation(dt.frametime)
	End
End


Class MyTiledTileMapReader Extends TiledTileMapReader
	Method CreateMap:TileMap()
		Return New MyTileMap
	End
End

Class MyTileMap Extends TileMap
	Method PreRenderLayer:Void(tileLayer:TileMapLayer)
		SetAlpha(tileLayer.opacity)
	End
End
