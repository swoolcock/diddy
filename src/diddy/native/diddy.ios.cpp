#include <time.h>
#include <math.h>

class diddy
{
	public:

	// only accurate to 1 second 
	static int systemMillisecs() {
		time_t seconds;
		seconds = time (NULL);
		return seconds * 1000;
	}
	
	static int getUpdateRate() {
		return app->updateRate;
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
		if(app->audio->music)
		{
			app->audio->music.currentTime = timeMillis/1000.0;
		}
		// TODO: check it worked
		return 1;
	}
};
