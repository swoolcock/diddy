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

float diddy_mouseWheel = 0.0f;

float diddy_mouseZ() {
	float ret = glfwGetMouseWheel() - diddy_mouseWheel;
	diddy_mouseWheel = glfwGetMouseWheel();
	return ret;
}

class diddy
{
	public:

	static float mouseZ()
	{
		return diddy_mouseZ();
	}
	
	static void mouseZInit()
	{
		return;
	}
	
	// only accurate to 1 second 
	static int systemMillisecs() {
		time_t seconds;
		seconds = time (NULL);
		return seconds * 1000;
	}
	
	static void setGraphics(int w, int h)
	{
		glfwSetWindowSize(w, h);
		GLFWvidmode desktopMode;
		glfwGetDesktopMode( &desktopMode );
		glfwSetWindowPos( (desktopMode.Width-w)/2,(desktopMode.Height-h)/2 );
	}
	static void setMouse(int x, int y)
	{
		glfwSetMousePos(x, y);
	}
	
	static void showKeyboard()
	{
	}
	static void launchBrowser(String address, String windowName)
	{
	}
	static void launchEmail(String email, String subject, String text)
	{
	}

	static void startVibrate(int millisecs)
	{
	}
	static void stopVibrate()
	{
	}
	static int getDayOfMonth()
	{
		return 0;
	}
	
	static int getDayOfWeek()
	{
		return 0;
	}
	
	static int getMonth()
	{
		return 0;
	}
	
	static int getYear()
	{
		return 0;
	}
	
	static int getHours()
	{
		return 0;
	}
	
	static int getMinutes()
	{
		return 0;
	}
	
	static int getSeconds()
	{
		return 0;
	}
	
	static int getMilliSeconds()
	{
		return 0;
	}
	
	static void startGps()
	{
	}
	static String getLatitiude()
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
	
	static int seekMusic(int timeMillis)
	{
		gxtkChannel *chan = &(bb_audio_device->channels[32]);
		if(chan && chan->state==1)
		{
			alSourcef(chan->source, AL_SEC_OFFSET, (float)(timeMillis / 1000.0));
		}
		// TODO: check it worked
		return 1;
	}
};
