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