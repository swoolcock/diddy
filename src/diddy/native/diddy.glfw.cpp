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
	static float realMod(float value, float amount) {
		return modf(value, &amount);
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
	static int getPixel(int x, int y)
	{
		unsigned char pix[4];
		glReadPixels(x, app->graphics->height-y ,1 ,1 ,GL_RGBA ,GL_UNSIGNED_BYTE ,pix);
		return (pix[3]<<24) | (pix[0]<<16) | (pix[1]<<8) |  pix[2];
	}
};
