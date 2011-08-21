import flash.ui.Mouse;

class diddy
{
	static public function systemMillisecs():Number
	{
		return (new Date).getTime();
	}

	static public function flushKeys():void
	{
		for( var i:int=0;i<512;++i ){
			bb_input_device.keyStates[i]=0;
		}
	}
	
	static public function showMouse():void
	{
		Mouse.show();
	}

	static public function hideMouse():void
	{
		Mouse.hide();
	}
	static public function setGraphics(w:int, h:int):void
	{
	}
	static public function setMouse(x:int, y:int):void
	{
		
	}
	
	static public function getUpdateRate():Number
	{
		return app.updateRate;
	}
	
	static public function showKeyboard():void
	{
	}
	
	static public function launchBrowser(address:String):void
	{
		var adobeURL:URLRequest = new URLRequest(address);
		navigateToURL(adobeURL);
	}
	
	static public function launchEmail(email:String, subject:String, text:String):void
	{
		var adobeURL:URLRequest = new URLRequest("mailto:"+email+"&subject="+subject+"&body="+text+"");
		navigateToURL(adobeURL, "_self");
	}
	
	static public function realMod(value:Number, amount:Number):Number {
		return value % amount;
	}
	static public function startVibrate(millisec:Number):void
	{
	}
	static public function stopVibrate():void
	{
	}
	
	static public function getDayOfMonth():int
	{
		return 0;
	}
	
	static public function getDayOfWeek():int
	{
		return 0;
	}
	
	static public function getMonth():int
	{
		return 0;
	}

	static public function getYear():int
	{
		return 0;
	}
	
	static public function getHours():int
	{
		return 0;
	}
	
	static public function getMinutes():int
	{
		return 0;
	}
	
	static public function getSeconds():int
	{
		return 0;
	}
	
	static public function getMilliSeconds():int
	{
		return 0;
	}

}