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
		if game.mouseHit
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
		Local tmpImage:Image
		game.images.LoadAnim("tileslostgarden.png", 20, 20, 21, tmpImage, True, False)	
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
			FadeToScreen(game.exitScreen)
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
	Method PreRenderLayer:Void(tileLayer:TileMapLayer)
		SetAlpha(tileLayer.opacity)
	End
End
