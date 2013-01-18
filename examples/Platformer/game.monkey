Import diddy
Import screens

Class MyGame Extends DiddyApp
	Method Create:Void()
		LoadImages()
		titleScreen = new TitleScreen
		gameScreen = new GameScreen
		defaultFadeTime = 300
		Start(titleScreen)
	End
	
	Method LoadImages:Void()
		images.LoadAtlas("gripe.xml", images.SPARROW_ATLAS)
		' Set the font
		SetFont(LoadImage(images.path + "font_16.png", 16, 16, 64))
	End
End