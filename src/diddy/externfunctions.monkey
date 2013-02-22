#if HOST="macos" And TARGET="glfw"
	Import "native/diddy.${TARGET}.mac.${LANG}"
#else
	Import "native/diddy.${TARGET}.${LANG}"
#end

Extern

	#If LANG="cpp" Then
		Function RealMillisecs:Int() = "diddy::systemMillisecs"
		Function GetUpdateRate:Int() = "diddy::getUpdateRate"
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
		Function GetColorPixel:Int(x:Int, y:Int)="diddy::getPixel"
		Function MouseZInit:Void()="diddy::mouseZInit"
		Function MouseZ:Float()="diddy::mouseZ"
		Function SeekMusic:Int(timeMillis:Int)="diddy::seekMusic"
	#Else
		Function RealMillisecs:Int() = "diddy.systemMillisecs"
		Function GetUpdateRate:Int() = "diddy.getUpdateRate"
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
		Function GetColorPixel:Int(x:Int, y:Int)="diddy.getPixel"
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