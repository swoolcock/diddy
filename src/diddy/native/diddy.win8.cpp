/*
Copyright (c) 2011 Steve Revill and Shane Woolcock
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

#include <time.h>
#include <Shellapi.h>
extern gxtkAudio *bb_audio_device;
extern gxtkGraphics *bb_graphics_device;

float diddy_mouseWheel = 0.0f;

float diddy_mouseZ() {
	return 0;
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
	}
	
	static void setMouse(int x, int y)
	{
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
		SYSTEMTIME st;
		GetSystemTime(&st);
		return st.wDay;
	}
	
	static int getDayOfWeek()
	{
		SYSTEMTIME st;
		GetSystemTime(&st);
		return st.wDayOfWeek;
	}
	
	static int getMonth()
	{
		SYSTEMTIME st;
		GetSystemTime(&st);
		return st.wMonth;
	}
	
	static int getYear()
	{
		SYSTEMTIME st;
		GetSystemTime(&st);
		return st.wYear;
	}
	
	static int getHours()
	{
		SYSTEMTIME st;
		GetSystemTime(&st);
		return st.wHour;
	}
	
	static int getMinutes()
	{
		SYSTEMTIME st;
		GetSystemTime(&st);
		return st.wMinute;
	}
	
	static int getSeconds()
	{
		SYSTEMTIME st;
		GetSystemTime(&st);
		return st.wSecond;
	}
	
	static int getMilliSeconds()
	{
		SYSTEMTIME st;
		GetSystemTime(&st);
		return st.wMilliseconds;
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
		return 1;
	}
};
