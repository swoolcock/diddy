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
	}
	static void hideMouse()
	{
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
	static void launchBrowser(String address)
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
	static float realMod(float value, float amount) {
		return fmod(value, amount);
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
};
