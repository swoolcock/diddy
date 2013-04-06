#Rem
Copyright (c) 2011 Steve Revill and Shane Woolcock
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#End

Strict

Import mojo
Import diddy

Global testScreen:InputTestScreen

Function Main:Int()
	New InputTestApp
	Return 0
End

Class InputTestApp Extends DiddyApp
	Method Create:Void()
		drawFPSOn = True
		testScreen = New InputTestScreen
		testScreen.PreStart()
	End
End

Class InputTestScreen Extends Screen
	Method New()
		name = "Game"
	End
	
	Method Start:Void()
		diddyGame.inputCache.MonitorAllKeys()
		diddyGame.screenFade.Start(50, false)
	End
	
	Method Render:Void()
		Cls
	End
	
	Method Update:Void()
		For Local event:KeyEvent = EachIn diddyGame.inputCache.KeysHit
			' do something for each key hit since the last frame
			Print "KeyHit: key,char,at="+event.KeyCode+","+String.FromChar(event.KeyChar)+","+event.EventTime
		Next
		For Local event:KeyEvent = EachIn diddyGame.inputCache.KeysDown
			' do something for each key held down
			'Print "KeyDown: key,char,at="+event.KeyCode+","+String.FromChar(event.KeyChar)+","+event.EventTime
		Next
		For Local event:KeyEvent = EachIn diddyGame.inputCache.KeysReleased
			' do something for each key released since the last frame
			Print "KeyReleased: key,char,at="+event.KeyCode+","+String.FromChar(event.KeyChar)+","+event.EventTime
		Next
		
		If diddyGame.inputCache.keyHit[KEY_ESCAPE] Then
			FadeToScreen(diddyGame.exitScreen)
		End
	End
End
