#Rem
Copyright (c) 2011 Steve Revill and Shane Woolcock
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#End

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
			FadeToScreen(diddyGame.exitScreen)
		End
	End	
End