/*
Copyright (c) 2011 Steve Revill and Shane Woolcock
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

#ifdef _WIN32
#include <windows.h>
#include <Shellapi.h>
#include <iostream>
#endif

#include <string.h>
#include <time.h>

extern gxtkAudio *bb_audio_device;
extern gxtkGraphics *bb_graphics_device;

void diddy_mouseScroll(GLFWwindow *window, double xoffset, double yoffset) {
}

float diddy_mouseZ() {
    // TODO: GLFW3 uses a callback for the scrollwheel, so it can't be directly queried
	//glfwSetScrollCallback(BBGlfwGame::GlfwGame()->GetGlfwWindow(), diddy_mouseScroll);
	return 0;
}

class diddy
{
	public:
	
	// Returns an empty string if dialog is cancelled
	static String openfilename() {
		#ifdef _WIN32
		const char *filter = "All Files (*.*)\0*.*\0";
		HWND owner = NULL;
		OPENFILENAME ofn;
		char fileName[MAX_PATH] = "";
		ZeroMemory(&ofn, sizeof(ofn));

		ofn.lStructSize = sizeof(OPENFILENAME);
		ofn.hwndOwner = owner;
		ofn.lpstrFilter = filter;
		ofn.lpstrFile = fileName;
		ofn.nMaxFile = MAX_PATH;
		ofn.Flags = OFN_EXPLORER | OFN_FILEMUSTEXIST | OFN_HIDEREADONLY;
		ofn.lpstrDefExt = "";

		String fileNameStr;

		if ( GetOpenFileName(&ofn) )
			fileNameStr = fileName;

		return fileNameStr;
		#endif
		#ifdef linux
		return "";
		#endif
	}
	
	static String savefilename() {
		#ifdef _WIN32
		const char *filter = "All Files (*.*)\0*.*\0";
		HWND owner = NULL;
		OPENFILENAME ofn;
		char fileName[MAX_PATH] = "";
		ZeroMemory(&ofn, sizeof(ofn));

		ofn.lStructSize = sizeof(OPENFILENAME);
		ofn.hwndOwner = owner;
		ofn.lpstrFilter = filter;
		ofn.lpstrFile = fileName;
		ofn.nMaxFile = MAX_PATH;
		ofn.Flags = OFN_EXPLORER | OFN_FILEMUSTEXIST | OFN_HIDEREADONLY;
		ofn.lpstrDefExt = "";

		String fileNameStr;

		if ( GetSaveFileNameA(&ofn) )
			fileNameStr = fileName;

		return fileNameStr;
		#endif
		#ifdef linux
		return "";
		#endif
	}
	
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
		GLFWwindow *window = BBGlfwGame::GlfwGame()->GetGlfwWindow();
		glfwSetWindowSize(window, w, h);
		
		GLFWmonitor *monitor = glfwGetPrimaryMonitor();
		const GLFWvidmode *desktopMode = glfwGetVideoMode(monitor);
		
		glfwSetWindowPos(window, (desktopMode->width-w)/2,(desktopMode->height-h)/2 );
	}
	
	static void setMouse(int x, int y)
	{
		glfwSetCursorPos(BBGlfwGame::GlfwGame()->GetGlfwWindow(), x, y);
	}
	
	static void showKeyboard()
	{
	}
	static void launchBrowser(String address, String windowName)
	{
		#ifdef _WIN32
		LPCSTR addressStr = address.ToCString<char>();
		ShellExecute(HWND_DESKTOP, "open", addressStr, NULL, NULL, SW_SHOWNORMAL);
		#endif
	}
	static void launchEmail(String email, String subject, String text)
	{
		#ifdef _WIN32
		String tmp = "mailto:";
		tmp+=email;
		tmp+="&subject=";
		tmp+=subject;
		tmp+="&body=";
		tmp+=text;
		LPCSTR addressStr = tmp.ToCString<char>();
		ShellExecute(HWND_DESKTOP, "open", addressStr, NULL, NULL, SW_SHOWNORMAL);
		#endif
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
