#Rem
Copyright (c) 2011 Steve Revill and Shane Woolcock
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#End

#if HOST="macos" And TARGET="glfw"
	Import "native/diddy.${TARGET}.mac.${LANG}"
#else
	Import "native/diddy.${TARGET}.${LANG}"
#end

Extern

	#If LANG="cpp" Then
		Function RealMillisecs:Int() = "diddy::systemMillisecs"
		Function SetMouse:Void(x:Int, y:Int) = "diddy::setMouse"
		Function ShowKeyboard:Void() = "diddy::showKeyboard"
		Function LaunchNativeBrowser:Void(address:String, windowName:String) = "diddy::launchBrowser"
		Function LaunchEmail:Void(email:String, subject:String, text:String) = "diddy::launchEmail"
		Function SetNativeGraphicsSize:Void(w:Int, h:Int) = "diddy::setGraphics"
		Function StartVibrate:Void(millisec:Int) = "diddy::startVibrate"
		Function StopVibrate:Void() = "diddy::stopVibrate"
		Function GetDayOfMonth:Int()="diddy::getDayOfMonth"
		Function GetDayOfWeek:Int()="diddy::getDayOfWeek"
		Function GetMonth:Int()="diddy::getMonth"
		Function GetYear:Int()="diddy::getYear"
		Function GetHours:Int()="diddy::getHours"
		Function GetMinutes:Int()="diddy::getMinutes"
		Function GetSeconds:Int()="diddy::getSeconds"
		Function GetMilliSeconds:Int()="diddy::getMilliSeconds"
		Function StartGps:Void()="diddy::startGps"
		Function GetLatitiude:String()="diddy::getLatitiude"
		Function GetLongitude:String()="diddy::getLongitude"
		Function ShowAlertDialog:Void(title:String, message:String) = "diddy::showAlertDialog"
		Function GetInputString:String()="diddy::getInputString"
		Function MouseZInit:Void()="diddy::mouseZInit"
		Function MouseZ:Float()="diddy::mouseZ"
		Function SeekMusic:Int(timeMillis:Int)="diddy::seekMusic"
	#Else
		Function RealMillisecs:Int() = "diddy.systemMillisecs"
		Function SetMouse:Void(x:Int, y:Int) = "diddy.setMouse"
		Function ShowKeyboard:Void() = "diddy.showKeyboard"
		Function LaunchNativeBrowser:Void(address:String, windowName:String) = "diddy.launchBrowser"
		Function LaunchEmail:Void(email:String, subject:String, text:String) = "diddy.launchEmail"
		Function SetNativeGraphicsSize:Void(w:Int, h:Int) = "diddy.setGraphics"
		Function StartVibrate:Void(millisec:Int) = "diddy.startVibrate"
		Function StopVibrate:Void() = "diddy.stopVibrate"
		Function GetDayOfMonth:Int()="diddy.getDayOfMonth"
		Function GetDayOfWeek:Int()="diddy.getDayOfWeek"
		Function GetMonth:Int()="diddy.getMonth"
		Function GetYear:Int()="diddy.getYear"
		Function GetHours:Int()="diddy.getHours"
		Function GetMinutes:Int()="diddy.getMinutes"
		Function GetSeconds:Int()="diddy.getSeconds"
		Function GetMilliSeconds:Int()="diddy.getMilliSeconds"
		Function StartGps:Void()="diddy.startGps"
		Function GetLatitiude:String()="diddy.getLatitiude"
		Function GetLongitude:String()="diddy.getLongitude"
		Function ShowAlertDialog:Void(title:String, message:String) = "diddy.showAlertDialog"
		Function GetInputString:String()="diddy.getInputString"
		Function MouseZInit:Void()="diddy.mouseZInit"
		Function MouseZ:Float()="diddy.mouseZ"
		#If TARGET<>"xna" And TARGET<>"psm" Then
			Function SeekMusic:Int(timeMillis:Int)="diddy.seekMusic"
		#End
	#End
	
	#If TARGET="html5" Then
		Function GetBrowserName:String()="diddy.getBrowserName"
		Function GetBrowserVersion:String()="diddy.getBrowserVersion"
		Function GetBrowserOS:String()="diddy.getBrowserOS"
		Function GetCurrentURL:String()="function (){return document.URL;}"
	#ElseIf TARGET="flash" Then
		Function GetCurrentURL:String()="diddy.getCurrentURL"
	#ElseIf LANG="java" Then
		Function BuildString:String(arr:Int[], offset:Int, length:Int) = "diddy.buildString"
	#End