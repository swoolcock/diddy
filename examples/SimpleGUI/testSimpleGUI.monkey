#Rem
Copyright (c) 2011 Steve Revill and Shane Woolcock
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#End

Strict

Import diddy

Function Main:Int()
	New MyGame()
	Return 0
End

Global titleScreen:TitleScreen
Global gameScreen:GameScreen
Global optionScreen:OptionScreen

Class MyGame Extends DiddyApp
	Method Create:Void()
		SetScreenSize(1024, 768)
		drawFPSOn = True
		
		images.Load("continue.png")
		images.Load("continueMO.png")
		
		titleScreen = New TitleScreen
		gameScreen = New GameScreen
		optionScreen = New OptionScreen
		
		Start(titleScreen)
	End
End

Class TitleScreen Extends Screen
	Field menu:SimpleMenu
	Field musicFormat:String
	
	Method New()
		name = "TitleScreen"
	End
	
	Method Start:Void()
		menu = New SimpleMenu("ButtonOver", "ButtonClick", 0, 0, 10, False)
		Local b:SimpleButton = menu.AddButton("newgame.png", "newgameMO.png")
		b = menu.AddButton("continue.png", "continueMO.png")
		b = menu.AddButton("options.png", "optionsMO.png")
		b = menu.AddButton("quit.png", "quitMO.png")
		b = menu.AddButton(diddyGame.images.Find("continue"), diddyGame.images.Find("continueMO"), "TEST")
		musicFormat="ogg"
		diddyGame.MusicPlay("happy."+musicFormat, True)
		menu.Centre()
	End
	
	Method Render:Void()
		Cls
		DrawText "TITLE SCREEN", SCREEN_WIDTH2, 10, 0.5, 0.5
	End
	
	Method ExtraRender:Void()
		menu.Draw()
	End
	
	Method Update:Void()
		menu.Update()

		If menu.Clicked("TEST") Then
			FadeToScreen(gameScreen)
		End
		
		If menu.Clicked("newgame") Then
			FadeToScreen(gameScreen)
		End
		
		If menu.Clicked("options") Then
			FadeToScreen(optionScreen)
		End
		
		If menu.Clicked("continue") Then
			FadeToScreen(titleScreen)
		End
		
		If KeyHit(KEY_ESCAPE) Or menu.Clicked("quit")
			FadeToScreen(diddyGame.exitScreen)
		End
	End
End

Class GameScreen Extends Screen
	Field menu:SimpleMenu
	
	Method Start:Void()
		diddyGame.screenFade.Start(50, False)
		menu = New SimpleMenu("ButtonOver", "ButtonClick", 0, 0, 10, True)
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
			FadeToScreen(titleScreen)
		End
	End
End

Class OptionScreen Extends Screen
	Field menu:SimpleMenu
	Field musicSlider:SimpleSlider
	
	Method Start:Void()
		diddyGame.screenFade.Start(50, False)
		menu = New SimpleMenu("ButtonOver", "ButtonClick", 0, 0, 10, True)
		Local b:SimpleButton = menu.AddButton("quit.png", "quitMO.png")
		menu.Centre()
		
		musicSlider = New SimpleSlider("slider_bar.png", "slider.png", SCREEN_WIDTH2 - 93, 115, 35, "music", 20, True)
		musicSlider.SetValue(diddyGame.musicVolume)
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
			diddyGame.MusicSetVolume(musicSlider.value)
		End If
		
		If menu.Clicked("quit") Then
			FadeToScreen(titleScreen)
		End
	End
End