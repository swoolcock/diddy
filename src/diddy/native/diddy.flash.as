/*
Copyright (c) 2011 Steve Revill and Shane Woolcock
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

import flash.ui.Mouse;
import flash.external.ExternalInterface;
import Date;

class diddy
{
	static public function systemMillisecs():Number
	{
		return (new Date).getTime();
	}

	static public function setGraphics(w:int, h:int):void
	{
	}
	static public function setMouse(x:int, y:int):void
	{
		
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
		var stage:Stage=BBFlashGame._flashGame._root.stage;
		stage.addEventListener(MouseEvent.MOUSE_WHEEL,  diddy_onMouseWheelEvent);
	}
	
	static public function seekMusic(timeMillis:int):int {
		if(bb_audio_device) {
			var chan:gxtkChannel = bb_audio_device.channels[32];
			if(chan.channel) {
				chan.channel.stop();
				chan.channel = chan.sample.sound.play(timeMillis, chan.loops, chan.transform);
			}
		}
		// TODO: check it worked
		return 1;
	}
}
var diddy_mouseWheelDelta:Number = 0.0;

function diddy_onMouseWheelEvent(e:MouseEvent):void {
	diddy_mouseWheelDelta += e.delta;
}