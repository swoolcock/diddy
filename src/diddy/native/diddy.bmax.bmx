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
	
	Function getDayOfMonth:Int()
		Local date$ = CurrentDate()
		Return Int(date[..2])
	EndFunction
	
	Function getDayOfWeek:Int()
		Return 0
	EndFunction
	
	Function getMonth:Int()
		Local date$ = CurrentDate()
		Return (Instr("JANFEBMARAPRMAYJUNJULAUGSEPOCTNOVDEC", date$[3..6].ToUpper(), 1) / 3) + 1
	EndFunction
	
	Function getYear:Int()
		Local date$ = CurrentDate()
		Return Int(date[date.length - 4..]);
	EndFunction
	
	Function getHours:Int()
		Local time$ = CurrentTime()
		Return Int(time[..2])
	EndFunction
	
	Function getMinutes:Int()
		Local time$ = CurrentTime()
		Return Int(time[3..5])
	EndFunction
	
	Function getSeconds:Int()
		Local time$ = CurrentTime()
		Return Int(time[6..8])
	EndFunction
	
	Function getMilliSeconds:Int()
		Return Millisecs()
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
	
	Function getPixel:Int( x:int, y:int )
'		unsigned char pix[4];
'		glReadPixels(x, app->graphics->height-y ,1 ,1 ,GL_RGBA ,GL_UNSIGNED_BYTE ,pix);
'		return (pix[3]<<24) | (pix[0]<<16) | (pix[1]<<8) |  pix[2];
		Return 0
	EndFunction
	
	Function mouseZInit()
	EndFunction

	Function mouseZ:Float()
		Local ret:Float = BlitzMaxMouseZ() - diddy_mouseWheel
		diddy_mouseWheel = BlitzMaxMouseZ()
		Return ret
	EndFunction
EndType

Function BlitzMaxMouseZ:Float()
	Return MouseZ()
EndFunction

' ***** End diddy.bmax.bmx ******


