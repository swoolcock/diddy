Strict

Import diddy
Import diddy.format
Import diddy.storyboard

Function Main:Int()
	New MyGame()
	Return 0
End

Global gameScreen:GameScreen

Class MyGame Extends DiddyApp

	Method Create:Void()
		LoadImages()
		
		gameScreen = New GameScreen
		
		Start(gameScreen)
	End
	
	'***********************
	'* Load Images
	'***********************
	Method LoadImages:Void()
		images.Load("bar.png")
		images.Load("bg.jpg")
		images.Load("black.png")
		images.Load("bmbs.png")
		images.Load("clouds.png")
		images.Load("layer 1.png")
		images.Load("layer 2.png")
		images.Load("layer 3.png")
		images.Load("load overlay.png")
		images.Load("LSB.png")
		images.Load("nebula.png")
		images.Load("nebula2.png")
		images.Load("planet.png")
		images.Load("SBB.png")
		images.Load("sun.png")
		images.Load("white.png")
		images.Load("X.png")
	End
End


Class GameScreen Extends Screen
	Field sb:Storyboard
	Field currentTime:Int = 0
	Field playing:Bool = False
	Field lengthTime:Int = 113110
	
	Method New()
		name = "Storyboard Test"
	End
	
	Method Start:Void()
		sb = Storyboard.LoadXML("storyboard.xml")
	End
	
	Method Render:Void()
		Cls
		SetAlpha(1)
		SetColor(255,255,255)
		game.images.Find("bg").Draw(SCREEN_WIDTH2,SCREEN_HEIGHT2)
		sb.Render()
		Local millis:Int = currentTime Mod 1000
		Local secs:Int = (currentTime / 1000) Mod 60
		Local mins:Int = (currentTime / 60000)
		SetAlpha(1)
		SetColor(255,255,255)
		DrawText(Format("%02d:%02d:%03d", mins, secs, millis), 0, 0)
	End

	Method Update:Void()
		If playing Then currentTime += dt.frametime
		If KeyHit(KEY_SPACE) Then playing = Not playing
		If MouseDown(0) Then currentTime = Int(lengthTime * Float(MouseX())/DEVICE_WIDTH)
		sb.Update(currentTime)
	End
End