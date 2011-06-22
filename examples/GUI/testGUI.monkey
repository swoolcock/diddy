Strict

Import mojo
Import diddy

Function Main:Int()
	game = new MyGame()
	Return 0
End Function

Global guiScreen:GUIScreen

Class MyGame extends DiddyApp
	Method OnCreate:Int()
		Super.OnCreate()
		drawFPSOn = True
		guiScreen = new GUIScreen
		guiScreen.PreStart()
		return 0
	End
End

Class GUIScreen Extends Screen
	Field mygui:MyGUI = New MyGUI
	
	Method New()
		name = "Game"
	End
	
	Method Start:Void()
		game.screenFade.Start(50, false)
	End
	
	Method Render:Void()
		Cls
		mygui.Draw()
		SetColor(255, 255, 255)
		DrawText("value="+mygui.slider.value, 0, 20)
	End
	
	Method Update:Void()
		mygui.Update()
		If KeyHit(KEY_ESCAPE)
			game.screenFade.Start(50, true)
			game.nextScreen = game.exitScreen
		End
	End

End

Class MyGUI Extends GUI
	Field button:Button
	Field toggleButton:Button
	Field slider:Slider
	Field window1:Window
	Field window2:Window
	
	Method New()
		Super.New()
		window1 = New Window(desktop)
		window1.SetBounds(50,50,200,200)
		
		button = New Button(window1.ContentPane)
		button.SetBounds(10,10,100,50)
		button.StyleNormal.red = 0
		button.StyleNormal.green = 0
		button.StyleNormal.blue = 255
		
		toggleButton = New Button(window1.ContentPane)
		toggleButton.toggle = True
		toggleButton.SetBounds(10,100,100,50)
		toggleButton.StyleNormal.red = 0
		toggleButton.StyleNormal.green = 0
		toggleButton.StyleNormal.blue = 255
		toggleButton.StyleSelected.red = 0
		toggleButton.StyleSelected.green = 255
		toggleButton.StyleSelected.blue = 0
	
		window2 = New Window(desktop)
		window2.SetBounds(300,200,250,100)
		
		slider = New Slider(window2.ContentPane)
		slider.SetBounds(10,10,200,20)
		slider.ShowButtons = True
		slider.StyleNormal.red = 0
		slider.StyleNormal.green = 0
		slider.StyleNormal.blue = 255
		
	End
	
	Method ActionPerformed:Void(source:Component, action:String)
		If source = slider And action = ACTION_VALUE_CHANGED Then
			Print "slider="+Slider(source).value
		ElseIf source = button And action = ACTION_CLICKED Then
			Print("pressed button!")
		ElseIf source = toggleButton And action = ACTION_CLICKED Then
			If toggleButton.selected Then
				Print("pressed toggleButton! selected=true")
			Else
				Print("pressed toggleButton! selected=false")
			End
		End
	End
End





