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
		
		game.images.Load("continue.png",,False)
		game.images.Load("continueMO.png",,False)
		game.images.Load("newgame.png",,False)
		game.images.Load("newgameMO.png",,False)
		game.images.Load("options.png",,False)
		game.images.Load("optionsMO.png",,False)
		
		' enable this and UseVirtualResolution to test the GUI under virtual res
		'SetScreenSize(1024, 768)
		
		Local parser:XMLParser = New XMLParser
		Font.LoadFonts(parser.ParseString(LoadString("fonts.xml")))
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
		DrawText("slider value="+mygui.slider.Value, 0, 20)
		DrawText("radio value="+mygui.rg.SelectedValue, 0, 40)
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
	Field window1:Window
	Field button1:Button
	Field button2:Button
	Field button3:Button
	Field checkbox:Checkbox
	
	Field window2:Window
	Field rg:RadioGroup
	Field slider:Slider
	Field radio1:RadioButton
	Field radio2:RadioButton
	Field radio3:RadioButton
	Field radio4:RadioButton
	Field radio5:RadioButton
	
	Field window3:Window
	Field imageButton1:Button
	Field imageButton2:Button
	Field imageButton3:Button
	
	Method New()
		' by default the GUI will always ignore virtual resolution and display using 1:1 with the device resolution
		'UseVirtualResolution = True
		
		Local parser:XMLParser = New XMLParser
		Local guiskin:XMLDocument = parser.ParseString(LoadString("defaultguiskin.xml"))
		
		' Note: LoadSkin (should) work at any point of the GUI lifecycle
		LoadSkin(guiskin)
		
		window1 = New Window(Desktop)
		window1.SetBounds(50,70,200,200)
		window1.Title = "GridLayout Demo"
		window1.ContentPane.LayoutManager = New GridLayout(0,2)
		
		button1 = New Button(window1.ContentPane)
		button1.Text = "Button 1"
		button1.LayoutData = New GridData(1,2)
		button2 = New Button(window1.ContentPane)
		button2.Text = "Button 2"
		button3 = New Button(window1.ContentPane)
		button3.Text = "Button 3"
	
		window2 = New Window(Desktop)
		window2.Title = "Form Components Example"
		window2.SetBounds(300,200,230,200)
		
		radio1 = New RadioButton(window2.ContentPane)
		radio1.Text = "Lorum"
		radio1.SetBounds(10,10,100,15)
		
		radio2 = New RadioButton(window2.ContentPane)
		radio2.Text = "Ipsum"
		radio2.SetBounds(10,30,100,15)
		
		radio3 = New RadioButton(window2.ContentPane)
		radio3.Text = "Dolor"
		radio3.SetBounds(10,50,100,15)
		
		radio4 = New RadioButton(window2.ContentPane)
		radio4.Text = "Sit"
		radio4.SetBounds(10,70,100,15)
		
		radio5 = New RadioButton(window2.ContentPane)
		radio5.Text = "Amet"
		radio5.SetBounds(10,90,100,15)
		
		rg = New RadioGroup
		rg.AddButton(radio1, "L")
		rg.AddButton(radio2, "I")
		rg.AddButton(radio3, "D")
		rg.AddButton(radio4, "S")
		rg.AddButton(radio5, "A")
		rg.SelectedValue = "I"
		
		slider = New Slider(window2.ContentPane)
		slider.SetBounds(10,110,200,15)
		slider.ShowButtons = True
		
		checkbox = New Checkbox(window2.ContentPane)
		checkbox.Text = "Does diddy rock?"
		checkbox.SetBounds(10,130,150,15)
		
		window3 = New Window(Desktop)
		window3.Title = "Image Button Demo"
		window3.SetBounds(350,50,260,200)
		
		imageButton1 = New Button(window3.ContentPane, game.images.Find("continue"), game.images.Find("continueMO"))
		imageButton1.SetLocation(20,20)
		
		imageButton2 = New Button(window3.ContentPane, game.images.Find("newgame"), game.images.Find("newgameMO"))
		imageButton2.SetLocation(20,imageButton1.Y+imageButton1.Height)
		
		imageButton3 = New Button(window3.ContentPane, game.images.Find("options"), game.images.Find("optionsMO"))
		imageButton3.SetLocation(20,imageButton2.Y+imageButton2.Height)
	End
	
	Method ActionPerformed:Void(source:Component, action:String)
		If source = slider And action = ACTION_VALUE_CHANGED Then
			Print "slider="+slider.Value
		ElseIf source = button1 And action = ACTION_CLICKED Then
			Print("pressed button1!")
		ElseIf source = button2 And action = ACTION_CLICKED Then
			Print("pressed button2!")
		ElseIf source = button3 And action = ACTION_CLICKED Then
			Print("pressed button3!")
		ElseIf source = imageButton1 And action = ACTION_CLICKED Then
			Print("Pressed continue!")
		ElseIf source = imageButton2 And action = ACTION_CLICKED Then
			Print("Pressed new game!")
		ElseIf source = imageButton3 And action = ACTION_CLICKED Then
			Print("Pressed options!")
		ElseIf source = checkbox And action = ACTION_CLICKED Then
			If checkbox.Selected Then
				Print("pressed checkbox! selected=true")
			Else
				Print("pressed checkbox! selected=false")
			End
		ElseIf RadioButton(source) <> Null Then
			Print("pressed radiobutton! value="+rg.SelectedValue)
		End
	End
End
