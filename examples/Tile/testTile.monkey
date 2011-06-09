Strict

Import mojo
Import diddy

Function Main:Int()
	game = New MyGame
	Return 0
End

Global titleScreen:TitleScreen
Global gameScreen:GameScreen

Class MyGame Extends DiddyApp
	Method OnCreate:Int()
		Super.OnCreate()
		titleScreen = New TitleScreen
		gameScreen = new GameScreen
		titleScreen.PreStart()
		Return 0
	End
End

Class TitleScreen Extends Screen
	Method New()
		name = "Title"
	End
	
	Method Start:Void()
		game.screenFade.Start(50, false)
	End
	
	Method Render:Void()
		Cls
		DrawText "TITLE SCREEN", SCREEN_WIDTH2, SCREEN_HEIGHT2, 0.5, 0.5
		DrawText "CLICK TO PLAY", SCREEN_WIDTH2, SCREEN_HEIGHT2 + 10, 0.5, 0.5
		FPSCounter.Draw(0,0)
	End
	
	Method Update:Void()
		if game.mouseHit
			game.screenFade.Start(50, True, True, True)
			game.nextScreen = gameScreen
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
		Local reader:MyTiledTileMapReader = New MyTiledTileMapReader
		Local tm:TileMap = reader.LoadMap("maps/map.xml")
		tilemap = MyTileMap(tm)
		game.screenFade.Start(50, false)
	End
	
	Method Render:Void()
		Cls
		tilemap.RenderMap(offsetX, offsetY, SCREEN_WIDTH, SCREEN_HEIGHT)
		
		FPSCounter.Draw(0,0)
	End
	
	Method Update:Void()
		If KeyHit(KEY_ESCAPE)
			game.screenFade.Start(50, True)
			game.nextScreen = game.exitScreen
		End
		If KeyDown(KEY_UP) Then offsetY -= 4
		If KeyDown(KEY_DOWN) Then offsetY += 4
		If KeyDown(KEY_LEFT) Then offsetX -= 4
		If KeyDown(KEY_RIGHT) Then offsetX += 4
		
		tilemap.UpdateAnimation(dt.frametime)
	End
End


Class MyTiledTileMapReader Extends TiledTileMapReader
	Method CreateMap:TileMap()
		Return New MyTileMap
	End
End

Class MyTileMap Extends TileMap
	Method ConfigureLayer:Void(tileLayer:TileMapLayer)
		SetAlpha(tileLayer.opacity)
	End
	
	Method DrawTile:Void(tileLayer:TileMapTileLayer, mapTile:TileMapTile, x:Int, y:Int)
		mapTile.image.DrawTile(x, y, mapTile.id, 0, 1, 1)
	End
End

