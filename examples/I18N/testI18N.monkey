#Rem
Copyright (c) 2011 Steve Revill and Shane Woolcock
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#End

Strict

Import mojo
Import diddy

Function Main:Int()
	New MyApp
	Return 0
End

Class MyApp Extends App
	Method OnCreate:Int()
		SetUpdateRate(60)
		LoadI18N()
		Return 0
	End
	
	Method OnUpdate:Int()
		If KeyHit(KEY_1) Then
			SetI18N("french")
			Print("Changed language to French")
			Print(I18N("Hello World!"))
			Print(I18N("Goodbye World!"))
		ElseIf KeyHit(KEY_2) Then
			SetI18N("japanese")
			Print("Changed language to Japanese")
			Print(I18N("Hello World!"))
			Print(I18N("Goodbye World!"))
		ElseIf KeyHit(KEY_3) Then
			Print("Reset language to default")
			ClearI18N()
		End
		Return 0
	End
	
	Method OnRender:Int()
		Cls
		DrawText("1: Load French", 5, 5)
		DrawText("2: Load Japanese", 5, 20)
		DrawText("3: Reset i18n", 5, 35)
		DrawText(I18N("Hello World!"), 5, 60)
		DrawText(I18N("Goodbye World!"), 5, 75)
		Return 0
	End
End