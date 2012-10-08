import flash.ui.Mouse;
import flash.external.ExternalInterface;
import Date;

class diddy
{
	static public function getPixel(x:int, y:int):int{
		var bmd:BitmapData = new BitmapData(1, 1);
		var matrix:Matrix = new Matrix();
		matrix.translate(-x, -y);
		bmd.draw(game.stage, matrix);
		var pixel:uint = bmd.getPixel32(0, 0);

		return pixel;
	}

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
	
	static public function launchBrowser(address:String, windowName:String):void
	{
		var adobeURL:URLRequest = new URLRequest(address);
		navigateToURL(adobeURL, windowName);
	}
	
	static public function launchEmail(email:String, subject:String, text:String):void
	{
		var adobeURL:URLRequest = new URLRequest("mailto:"+email+"&subject="+subject+"&body="+text+"");
		navigateToURL(adobeURL, "_self");
	}
	
	static public function startVibrate(millisec:Number):void
	{
	}
	static public function stopVibrate():void
	{
	}
	
	static public function getDayOfMonth():int
	{
		var d:Date = new Date();
		return d.getDate();
	}
	
	static public function getDayOfWeek():int
	{
		var d:Date = new Date();
		return d.getDay();
	}
	
	static public function getMonth():int
	{
		var d:Date = new Date();
		return d.getMonth();
	}

	static public function getYear():int
	{
		var d:Date = new Date();
		return d.getFullYear();
	}
	
	static public function getHours():int
	{
		var d:Date = new Date();
		return d.getHours();
	}
	
	static public function getMinutes():int
	{
		var d:Date = new Date();
		return d.getMinutes();
	}
	
	static public function getSeconds():int
	{
		var d:Date = new Date();
		return d.getSeconds();
	}
	
	static public function getMilliSeconds():int
	{
		var d:Date = new Date();
		return d.getMilliseconds();
	}
	
	static public function startGps():void
	{
	}
	static public function getLatitiude():String
	{
		return "";
	}
	static public function getLongitude():String
	{
		return "";
	}
	
	static public function showAlertDialog(title:String, message:String):void
	{
	}
	
	static public function getInputString():String
	{
		return "";
	}
	
	static public function getCurrentURL():String
	{
		return ExternalInterface.call('window.location.href.toString');
	}
	
	static public function mouseZ():Number {
		var t:Number = diddy_mouseWheelDelta;
		
		diddy_mouseWheelDelta = 0.0
		return t;
	}

	static public function mouseZInit():void {
		var stage:Stage=game.stage;
		stage.addEventListener(MouseEvent.MOUSE_WHEEL,  diddy_onMouseWheelEvent);
	}
	
	static public function seekMusic(timeMillis:int):void {
		if(bb_audio_device) {
			var chan:gxtkChannel = bb_audio_device.channels[32];
			if(chan.channel) {
				chan.channel.stop();
				chan.channel = chan.sample.sound.play(timeMillis, chan.loops, chan.transform);
			}
		}
	}
}
var diddy_mouseWheelDelta:Number = 0.0;

function diddy_onMouseWheelEvent(e:MouseEvent):void {
	diddy_mouseWheelDelta += e.delta;
}