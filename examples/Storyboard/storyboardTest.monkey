Strict

Import diddy
Import diddy.storyboard

Function Main:Int()
	New MyGame()
	Return 0
End

Global gameScreen:GameScreen

Class MyGame Extends DiddyApp

	Method Create:Void()
		SetGraphics(1280,960)
		SetScreenSize(640,480)
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
		images.Load("layer1.png")
		images.Load("layer2.png")
		images.Load("layer3.png")
		images.Load("loadoverlay.png")
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
		sb.Render(0,0,SCREEN_WIDTH,SCREEN_HEIGHT)
	End

	Method Update:Void()
		If KeyHit(KEY_R) Then sb = Storyboard.LoadXML("storyboard.xml")
		If playing Then currentTime += dt.frametime
		If KeyHit(KEY_SPACE) Then playing = Not playing
		If KeyHit(KEY_Z) Then sb.DebugMode = Not sb.DebugMode
		If MouseDown(0) Then currentTime = Int(lengthTime * Float(MouseX())/DEVICE_WIDTH)
		sb.Update(currentTime)
	End
End