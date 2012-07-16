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
		backgroundImage = LoadImage(game.images.path + "title_screen.jpg")
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
			FadeToScreen(game.exitScreen)
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
		game.scrollX = 0
		backgroundImage = LoadImage(game.images.path + "area01_bkg0.png")
		Local reader:MyTiledTileMapReader = New MyTiledTileMapReader
		Local tm:TileMap = reader.LoadMap("levels/level1.tmx")
		tilemap = MyTileMap(tm)
		Local playerStart:TileMapObject = tilemap.FindObjectByName("playerStart")
		player = New Player(game.images.Find("gripe.stand"), playerStart.x, playerStart.y)
	End
	
	Method Render:Void()
		Cls
		DrawImage backgroundImage, 0, 0
		tilemap.RenderMap(game.scrollX, game.scrollY, SCREEN_WIDTH, SCREEN_HEIGHT, 1, 1)
		player.Draw(game.scrollX, game.scrollY, True)
		
		if player.jumping
			DrawText "TRUE", 10, 10
		Else
			DrawText "FALSE", 10, 10
		End
		DrawText game.scrollX, 10, 30
	End
	
	Method Update:Void()
		player.Update()
		If KeyDown(KEY_W) Then game.scrollY -= 4
		If KeyDown(KEY_S) Then game.scrollY += 4
		If KeyDown(KEY_A) Then game.scrollX -= 4
		If KeyDown(KEY_D) Then game.scrollX += 4
		If KeyHit(KEY_ESCAPE)
			FadeToScreen(titleScreen)
		End
	End
End