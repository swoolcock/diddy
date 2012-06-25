Strict

Import diddy

Function Main:Int()
	new MyGame()
	Return 0
End

Global gameScreen:GameScreen

Class MyGame Extends DiddyApp
	Method OnCreate:Int()
		Super.OnCreate()
		LoadImages()
		gameScreen = new GameScreen
		game.Start(gameScreen)
		return 0
	End
	
	Method LoadImages:Void()
		' create tmpImage for animations
		Local tmpImage:Image
		' load normal sprite
		images.LoadAnim("Ship1.png", 64, 64, 7, tmpImage)
		' load atlas sprites
		images.LoadAtlas("sprites.xml")
	End
End

Class GameScreen Extends Screen
	Field shipImage:GameImage
	Field axeAltasImage:GameImage
	Field longswordAltasImage:GameImage
		
	Method New()
		name = "Game"
	End
	
	Method Start:Void()
		shipImage = game.images.Find("Ship1")
		axeAltasImage = game.images.Find("axe")
		longswordAltasImage = game.images.Find("longsword")
	End
	
	Method Render:Void()
		Cls
		DrawText "GAME SCREEN!", SCREEN_WIDTH2, 10, 0.5, 0.5
		FPSCounter.Draw(0, 0)
		shipImage.Draw(100, 100, 0, 1, 1, 3)
		axeAltasImage.Draw(200, 100)
		longswordAltasImage.Draw(300, 100)
	End
	
	Method Update:Void()
		If KeyHit(KEY_ESCAPE)
			FadeToScreen(Null)
		End
	End
End