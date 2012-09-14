Strict

Import diddy

Global testScreen:TestScreen

Function Main:Int()
	New MyGame()
	Return 0
End Function

Class MyGame Extends DiddyApp

	Method Create:Void()
		testScreen = New TestScreen()
		Start(testScreen)
	End
End

Class TestScreen Extends Screen
	Method Start:Void()
		Local parser:XMLParser = New XMLParser
		Local doc:XMLDocument = parser.ParseString(LoadString("test.xml"))
		Print doc.Root.GetAttribute("shutdown")
		Print doc.Root.Children.Get(0).Parent.Name
		Print doc.ExportString()	

		#Rem
			Local doc:XMLDocument = New XMLDocument
			doc.root = New XMLElement
			doc.root.name = "root"
			
			Local child1 := New XMLElement
			child1.name = "mychild"
			child1.SetAttribute("foo", "bar")
			child1.SetAttribute("hello", "world")
			doc.root.AddChild(child1)
			
			Local child2 := New XMLElement
			child2.name = "mychild"
			child2.SetAttribute("david", "jones")
			child2.SetAttribute("harvey", "norman")
			doc.root.AddChild(child2)
			
			Print(doc.ExportString())
			Print(doc.ExportString(False))
			Return 0
		#End

	End
	
	Method Render:Void()
		Cls
		DrawText "Testing XML", SCREEN_WIDTH2, SCREEN_HEIGHT2 + 20, 0.5, 0.5
	End

	Method Update:Void()
		If KeyHit(KEY_ESCAPE)
			FadeToScreen(game.exitScreen)
		End
	End	
End