Rem
Copyright (c) 2011 Steve Revill and Shane Woolcock
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
EndRem

' ***** Start diddy.bmax.bmx ******
Global diddy_mouseWheel:Float = 0.0

Type diddy
	Function systemMillisecs:Float()
		Return Millisecs()
	EndFunction
	
	Function setGraphics(w:int, h:int, fullScreen:Int = False)
		local d% = 0
		if fullScreen then d = 32
		Graphics w, h, d, 60
	EndFunction
	
	Function setMouse(x:Int, y:Int)
		MoveMouse(x, y)
	EndFunction
	
	Function showKeyboard()
	EndFunction
	
	Function launchBrowser(address:String, windowName:String)
	EndFunction
	
	Function launchEmail(email:String, subject:String, text:String)
	EndFunction
	
	Function realMod:Float( value:Float, amount:Float )
		Return value Mod amount
	EndFunction
	
	Function startVibrate(millisecs:int)
	EndFunction
	
	Function stopVibrate()
	EndFunction
	
	Function startGps()
	EndFunction
	
	Function getLatitiude:String()
		Return ""
	EndFunction
	
	Function getLongitude:String()
		Return ""
	EndFunction

	Function showAlertDialog(title:String, message:String)
	EndFunction
	
	Function getInputString:String()
		Return "";
	EndFunction
	
	Function mouseZInit()
	EndFunction

	Function mouseZ:Float()
		Local ret:Float = BlitzMaxMouseZ() - diddy_mouseWheel
		diddy_mouseWheel = BlitzMaxMouseZ()
		Return ret
	EndFunction
	
	Function SeekMusic:Int(timeMillis:Int)
		Return 0
	EndFunction
EndType

Function BlitzMaxMouseZ:Float()
	Return MouseZ()
EndFunction

' ***** End diddy.bmax.bmx ******


