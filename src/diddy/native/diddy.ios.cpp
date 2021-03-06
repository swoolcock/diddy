/*
Copyright (c) 2011 Steve Revill and Shane Woolcock
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

#include <time.h>
#include <math.h>
extern gxtkAudio *bb_audio_device;
extern gxtkGraphics *bb_graphics_device;

class diddy
{
	public:

	// only accurate to 1 second 
	static int systemMillisecs() {
		time_t seconds;
		seconds = time (NULL);
		return seconds * 1000;
	}

	static void setGraphics(int w, int h)
	{
	}
	static void setMouse(int x, int y)
	{
	}	
	static void showKeyboard()
	{
	}
	static void launchBrowser(String address, String windowName)
	{
		NSString *NSstrURL = address.ToNSString();
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:NSstrURL]];
	}
	static void launchEmail(String email, String subject, String text)
	{
		NSString *NSstrMailAdress = email.ToNSString();
		NSString *NSstrBody = text.ToNSString();
		NSstrBody = [NSstrBody stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		NSString *NSstrSubject = subject.ToNSString();
		NSstrSubject = [NSstrSubject stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

		NSString *message = [NSString stringWithFormat:@"mailto:%@?subject=%@&body=%@",NSstrMailAdress,NSstrSubject,NSstrBody];

		//Open E-Mail And add message
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:message]];

	}

	static void startVibrate(int millisecs)
	{
	}
	static void stopVibrate()
	{
	}
	static void startGps()
	{
	}
	static String getLatitude()
	{
		return "";
	}
	static String getLongitude()
	{
		return "";
	}
	static void showAlertDialog(String title, String message)
	{
	}
	static String getInputString()
	{
		return "";
	}
	
	// empty function
	static void mouseZInit()
	{
	}
	// empty function
	static float mouseZ()
	{
		return 0;
	}
	
	static int seekMusic(int timeMillis)
	{
		if(bb_audio_device->musicPlayer)
		{
			bb_audio_device->musicPlayer.currentTime = timeMillis/1000.0;
		}
		return 1;
	}
};
