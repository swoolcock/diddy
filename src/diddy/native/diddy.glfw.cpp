#include <time.h>
#include <Shellapi.h>

class diddy
{
	public:

	// only accurate to 1 second 
	static int systemMillisecs() {
		time_t seconds;
		seconds = time (NULL);
		return seconds * 1000;
	}

	static void flushKeys() {
		for( int i=0;i<512;++i ){
			app->input->keyStates[i]&=0x100;
		}
	}
	
	static int getUpdateRate() {
		return app->updateRate;
	}
	
	static void showMouse()
	{
		//ShowCursor(true);
		glfwEnable( GLFW_MOUSE_CURSOR );
	}
	
	static void hideMouse()
	{
		//ShowCursor(false);
		glfwDisable( GLFW_MOUSE_CURSOR );
	}
	
	static void setMouse(int x, int y)
	{
		glfwSetMousePos(x, y);
	}
	
	static void showKeyboard()
	{
	}
	static void launchBrowser(String address)
	{
		LPCSTR addressStr = address.ToCString<char>();
		ShellExecute(HWND_DESKTOP, "open", addressStr, NULL, NULL, SW_SHOWNORMAL);
	}
	static void launchEmail(String email, String subject, String text)
	{
		String tmp = "mailto:";
		tmp+=email;
		tmp+="&subject=";
		tmp+=subject;
		tmp+="&body=";
		tmp+=text;
		LPCSTR addressStr = tmp.ToCString<char>();
		ShellExecute(HWND_DESKTOP, "open", addressStr, NULL, NULL, SW_SHOWNORMAL);
	}
};
