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
		DrawText("slider value="+mygui.slider.value, 0, 20)
		DrawText("radio value="+mygui.rg.currentValue, 0, 40)
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
	Field checkbox:Checkbox
	Field slider:Slider
	Field window1:Window
	Field window2:Window
	Field rg:RadioGroup
	Field radio1:RadioButton
	Field radio2:RadioButton
	Field radio3:RadioButton
	Field radio4:RadioButton
	Field radio5:RadioButton
	
	Method New()
		Local parser:XMLParser = New XMLParser
		Local guiskin:XMLDocument = parser.ParseString(LoadString("defaultguiskin.xml"))
		LoadSkin(guiskin)
		
		window1 = New Window(desktop)
		window1.SetBounds(50,70,200,200)
		
		button = New Button(window1.ContentPane)
		button.SetBounds(10,10,100,50)
		
		checkbox = New Checkbox(window1.ContentPane)
		checkbox.toggle = True
		checkbox.SetBounds(10,100,50,15)
	
		window2 = New Window(desktop)
		window2.SetBounds(300,200,250,200)
		
		LoadSkin(guiskin)
		
		radio1 = New RadioButton(window2.ContentPane)
		radio1.SetBounds(10,10,100,15)
		
		radio2 = New RadioButton(window2.ContentPane)
		radio2.SetBounds(10,30,100,15)
		
		radio3 = New RadioButton(window2.ContentPane)
		radio3.SetBounds(10,50,100,15)
		
		radio4 = New RadioButton(window2.ContentPane)
		radio4.SetBounds(10,70,100,15)
		
		radio5 = New RadioButton(window2.ContentPane)
		radio5.SetBounds(10,90,100,15)
		
		rg = New RadioGroup
		rg.AddButton(radio1, "Lorum")
		rg.AddButton(radio2, "Ipsum")
		rg.AddButton(radio3, "Dolor")
		rg.AddButton(radio4, "Sit")
		rg.AddButton(radio5, "Amet")
		rg.SelectValue("Lorum")
		
		slider = New Slider(window2.ContentPane)
		slider.SetBounds(10,110,200,15)
		slider.ShowButtons = True
	End
	
	Method ActionPerformed:Void(source:Component, action:String)
		If source = slider And action = ACTION_VALUE_CHANGED Then
			Print "slider="+Slider(source).value
		ElseIf source = button And action = ACTION_CLICKED Then
			Print("pressed button!")
		ElseIf source = checkbox And action = ACTION_CLICKED Then
			If checkbox.selected Then
				Print("pressed checkbox! selected=true")
			Else
				Print("pressed checkbox! selected=false")
			End
		ElseIf RadioButton(source) <> Null Then
			Print("pressed radiobutton! value="+rg.currentValue)
		End
	End
End





