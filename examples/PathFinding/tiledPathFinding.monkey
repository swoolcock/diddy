#Rem
Copyright (c) 2011 Steve Revill and Shane Woolcock
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#End

Strict
#TEXT_FILES="*.txt|*.xml|*.json|*.tmx"

Import diddy

Global game:MyGame

Function Main:Int()
	game = New MyGame()
	Return 0
End

Class MyGame Extends DiddyApp
	Method Create:Void()
		Start(GameScreen.GetInstance())
	End
End

Class GameScreen Extends Screen
	Global instance:GameScreen
	Field tilemap:MyTileMap
	Field x:Float, y:Float
	Field startX:Int = 1, startY:Int = 1
	Field endX:Int = 10, endY:Int = 15
	Field currentPath:Int = 0
	Field mx:Int, my:Int
			
	Function GetInstance:GameScreen()
		If instance = Null
			instance = New GameScreen()
		End
		Return instance
	End
	
	Method New()
		name = "GameScreen"
	End
	
	Method Load:Void()
		Local reader:MyTiledTileMapReader = New MyTiledTileMapReader
		Local tm:TileMap = reader.LoadMap("maps/map.tmx")
		tilemap = MyTileMap(tm)
	End
	
	Method Start:Void()
		Local layer:TileMapTileLayer = tilemap.FindLayerByName(tilemap.COLLISION_LAYER)
		Local t:Int[] = layer.mapData.tiles
		Local f:Float[]
		f = f.Resize(t.Length())
		For Local i:Int = 0 Until t.Length()
			f[i] = t[i]
		Next
		
		x = startX * tilemap.tileWidth
		y = startY * tilemap.tileHeight
		
		PathFinder.SetMap(f, tilemap.width, tilemap.width, 2, 0)
	End

	Method Render:Void()
		Cls(100, 100, 250)
		tilemap.RenderMap(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)
				
		'Draw the "player" position
		SetColor(255, 0, 255)
		DrawOval(x, y, tilemap.tileWidth, tilemap.tileHeight)
		
		'Draw end position
		SetColor(255, 255, 0)
		DrawOval(endX * tilemap.tileWidth, endY * tilemap.tileHeight, tilemap.tileWidth, tilemap.tileHeight)

		'Draw path
		SetColor(0, 255, 0)
		For Local i:Int = 0 Until PathFinder.paths * 2 Step 2
			DrawRect(PathFinder.route[i] * tilemap.tileWidth + tilemap.tileWidth / 2, PathFinder.route[i + 1] * tilemap.tileHeight + tilemap.tileHeight / 2, 5, 5)
		Next
		SetColor(255, 255, 255)
	End
	
	Method SetPath:Void()
		startX = x / tilemap.tileWidth
		startY = y / tilemap.tileHeight
		PathFinder.FindPath(startX, startY, endX, endY)
		currentPath = (PathFinder.paths - 1) * 2
	End

	Method Update:Void()
		If KeyHit(KEY_ESCAPE)
			FadeToScreen(diddyGame.exitScreen)
		End
		
		mx = diddyGame.mouseX / tilemap.tileWidth
		my = diddyGame.mouseY / tilemap.tileHeight
		mx = Max(mx, 0)
		mx = Min(mx, 19)
		my = Max(my, 0)
		my = Min(my, 19)
		
		If MouseHit(0)
			endX = mx
			endY = my
			SetPath()
		End
		
		If currentPath >= 0 And PathFinder.route.Length() > 0
			If x < PathFinder.route[currentPath] * tilemap.tileWidth
				x += 2
			End
			If x > PathFinder.route[currentPath] * tilemap.tileWidth
				x -= 2
			End
			If y < PathFinder.route[currentPath + 1] * tilemap.tileHeight
				y += 2
			End
			If y > PathFinder.route[currentPath + 1] * tilemap.tileHeight
				y -= 2
			End
					
			If x = PathFinder.route[currentPath] * tilemap.tileWidth And
				y = PathFinder.route[currentPath + 1] * tilemap.tileHeight
				currentPath -= 2
			End
		End
	End
End

Class MyTiledTileMapReader Extends TiledTileMapReader
	Method CreateMap:TileMap()
		Return New MyTileMap
	End
End

Class MyTileMap Extends TileMap
	Const COLLISION_LAYER:String = "COLLISIONS"
	
	Method PreRenderLayer:Void(tileLayer:TileMapLayer)
		SetAlpha(tileLayer.opacity)
	End
End