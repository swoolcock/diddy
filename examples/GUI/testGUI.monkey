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

Global guiScreen:GUIScreen
Global xmlParser:XMLParser = New XMLParser
Global guiSkin:XMLDocument

Class MyGame extends DiddyApp
	Method Create:Void()
		diddyGame.images.Load("continue.png",,False)
		diddyGame.images.Load("continueMO.png",,False)
		diddyGame.images.Load("newgame.png",,False)
		diddyGame.images.Load("newgameMO.png",,False)
		diddyGame.images.Load("options.png",,False)
		diddyGame.images.Load("optionsMO.png",,False)
		
		' enable this and UseVirtualResolution to test the GUI under virtual res
		'SetScreenSize(1024, 768)
		
		Font.LoadFonts(xmlParser.ParseString(LoadString("fonts.xml")))
		guiSkin = xmlParser.ParseString(LoadString("defaultguiskin.xml"))
		
		drawFPSOn = True
		
		guiScreen = new GUIScreen
		Start(guiScreen)
	End
End

Class GUIScreen Extends Screen
	Field mygui:MyGUI = New MyGUI
	
	Method New()
		name = "Game"
	End
	
	Method Start:Void()
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
			FadeToScreen(diddyGame.exitScreen)
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
	Field label:Label
	
	Field window3:Window
	Field imageButton1:Button
	Field imageButton2:Button
	Field imageButton3:Button
	
	Field testPanel:Panel
	
	Method New()
		' by default the GUI will always ignore virtual resolution and display using 1:1 with the device resolution
		'UseVirtualResolution = True
		Self.LayoutEnabled = True
		' Note: LoadSkin (should) work at any point of the GUI lifecycle
		LoadSkin(guiSkin)
		
		window1 = New Window(Self.Desktop)
		window1.ShowMaximize = True
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
	
		window2 = New Window(Self.Desktop)
		window2.ShowMinimize = True
		window2.Title = "Form Components Example"
		window2.SetBounds(300,50,230,200)
		
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
		
		rg = New TestRadioGroup
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
		
		label = New Label(window2.ContentPane)
		label.Text = "Label"
		label.SetBounds(10,150,50,20)
		
		' test panel not using a window
		testPanel = New Panel(Self.Desktop)
		Local gl:GridLayout = New GridLayout(0,1)
		testPanel.LayoutManager = gl
		gl.rowHeightTypes[0] = GridLayout.FILLTYPE_PREFERRED
		gl.rowHeightTypes[1] = GridLayout.FILLTYPE_PREFERRED
		gl.rowHeightTypes[2] = GridLayout.FILLTYPE_PREFERRED
		gl.colWidthTypes[0] = GridLayout.FILLTYPE_PREFERRED
		
		imageButton1 = New Button(testPanel, diddyGame.images.Find("continue"), diddyGame.images.Find("continueMO"))
		imageButton2 = New Button(testPanel, diddyGame.images.Find("newgame"), diddyGame.images.Find("newgameMO"))
		imageButton3 = New Button(testPanel, diddyGame.images.Find("options"), diddyGame.images.Find("optionsMO"))
		
		testPanel.Pack()
		testPanel.SetLocation((Self.Desktop.Width-testPanel.Width)/2,Self.Desktop.Height-testPanel.Height)
		
		' Layout manager is disabled by default (to stop nasty recursion spam while building up the gui); this line enables it.
		' From here on, any changes to the gui structure that affect the layout will cause it to fire.
		Self.LayoutEnabled = True
	End
	
	Method ActionPerformed:Void(source:Component, action:String)
		If source = slider And action = ACTION_VALUE_CHANGED Then
			Print "slider="+slider.Value
		ElseIf source = button1 And action = ACTION_CLICKED Then
			Print("pressed button1!")
			slider.Value = 10
		ElseIf source = button2 And action = ACTION_CLICKED Then
			Print("pressed button2!")
			slider.Value = 20
		ElseIf source = button3 And action = ACTION_CLICKED Then
			Print("pressed button3!")
			slider.Value = 30
		ElseIf source = imageButton1 And action = ACTION_CLICKED Then
			Print("Pressed continue!")
			slider.Value = 40
		ElseIf source = imageButton2 And action = ACTION_CLICKED Then
			Print("Pressed new game!")
			slider.Value = 50
		ElseIf source = imageButton3 And action = ACTION_CLICKED Then
			Print("Pressed options!")
			slider.Value = 60
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

Class TestRadioGroup Extends RadioGroup
	Method ValueChanged:Void(newValue:String, newButton:RadioButton, oldValue:String, oldButton:RadioButton)
		Print("Changed value from "+oldValue+" to "+newValue)
	End
End