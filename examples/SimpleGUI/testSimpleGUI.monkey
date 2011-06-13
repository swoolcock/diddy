Strict

Import diddy

Function Main:Int()
	game = new MyGame()
	Return 0
End Function

Global titleScreen:TitleScreen
Global gameScreen:GameScreen
Global optionScreen:OptionScreen

Class MyGame extends DiddyApp
	Method OnCreate:Int()
		Super.OnCreate()
	
		drawFPSOn = True
		
		titleScreen = New TitleScreen
		gameScreen = New GameScreen
		optionScreen = new OptionScreen
		
		titleScreen.PreStart()
		return 0
	End
End

Class TitleScreen Extends Screen
	Field menu:SimpleMenu
	Field musicFormat:String
	
	Method New()
		name = "TitleScreen"
	End
	
	Method Start:Void()
		game.screenFade.Start(50, false)
		menu = New SimpleMenu("ButtonOver", "ButtonClick", 0, 0, 10)
		Local b:SimpleButton = menu.AddButton("newgame.png", "newgameMO.png")
		b = menu.AddButton("continue.png", "continueMO.png")
		b = menu.AddButton("options.png", "optionsMO.png")
		b = menu.AddButton("quit.png", "quitMO.png")

#If TARGET="glfw"
		musicFormat="wav"
#Elseif TARGET="html5"
		musicFormat="ogg"
#Elseif TARGET="flash"
		musicFormat="mp3"
#Elseif TARGET="android"
		musicFormat="ogg"
#Elseif TARGET="xna"
		musicFormat="wav"
#Elseif TARGET="ios"
		musicFormat="m4a"
#End		
		
		game.MusicPlay("happy."+musicFormat, True)
		menu.Centre()
	End
	
	Method Render:Void()
		Cls
		DrawText "TITLE SCREEN", SCREEN_WIDTH2, 10, 0.5, 0.5
		menu.Draw()
	End
	
	Method Update:Void()
		menu.Update()
		
		If menu.Clicked("newgame") Then
			game.screenFade.Start(50, true)
			game.nextScreen = gameScreen
		End
		
		If menu.Clicked("options") Then
			game.screenFade.Start(50, true)
			game.nextScreen = optionScreen
		End
		
		If menu.Clicked("continue") Then
			game.screenFade.Start(50, true)
			game.nextScreen = titleScreen
		End
		
		If KeyHit(KEY_ESCAPE) or menu.Clicked("quit")
			game.screenFade.Start(50, true)
			game.nextScreen = game.exitScreen
		End
	End
End

Class GameScreen Extends Screen
	Field menu:SimpleMenu
	
	Method Start:Void()
		game.screenFade.Start(50, false)
		menu = New SimpleMenu("ButtonOver", "ButtonClick", 0, 0, 10)
		Local b:SimpleButton = menu.AddButton("quit.png", "quitMO.png")
		menu.Centre()
	End
	
	Method Render:Void()
		Cls
		DrawText "GAME SCREEN", SCREEN_WIDTH2, 10, 0.5, 0.5
		menu.Draw()
	End
	
	Method Update:Void()
		menu.Update()
		
		If menu.Clicked("quit") Then
			game.screenFade.Start(50, true)
			game.nextScreen = titleScreen
		End
	End
End

Class OptionScreen Extends Screen
	Field menu:SimpleMenu
	Field musicSlider:SimpleSlider
	
	Method Start:Void()
		game.screenFade.Start(50, false)
		menu = New SimpleMenu("ButtonOver", "ButtonClick", 0, 0, 10)
		Local b:SimpleButton = menu.AddButton("quit.png", "quitMO.png")
		menu.Centre()
		
		musicSlider = New SimpleSlider("slider_bar.png", "slider.png", SCREEN_WIDTH2 - 93, 115, 35, "music", 20)
		musicSlider.SetValue(game.musicVolume)
	End
	
	Method Render:Void()
		Cls
		DrawText "OPTION SCREEN", SCREEN_WIDTH2, 10, 0.5, 0.5
		menu.Draw()
		DrawText "MUSIC VOLUME:", musicSlider.x + (musicSlider.image.w / 2)  , musicSlider.y - 20, 0.5
		musicSlider.Draw()
	End
	
	Method Update:Void()
		menu.Update()
		
		If musicSlider.Update() Then
			game.MusicSetVolume(musicSlider.value)
		End If
		
		If menu.Clicked("quit") Then
			game.screenFade.Start(50, true)
			game.nextScreen = titleScreen
		End
	End
End