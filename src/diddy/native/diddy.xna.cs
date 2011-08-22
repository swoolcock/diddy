class diddy
{
	public static int systemMillisecs()
	{
		DateTime centuryBegin = new DateTime(1970, 1, 1);
		DateTime currentDate = DateTime.Now;
		long elapsedTicks = currentDate.Ticks - centuryBegin.Ticks;
		TimeSpan elapsedSpan = new TimeSpan(elapsedTicks);

		int millisecs = (int)elapsedSpan.TotalSeconds * 1000;

		return millisecs;
	}

	public static void flushKeys()
	{
		for( int i=0;i<512;++i ){
			gxtkApp.game.app.input.keyStates[i]&=0x100;
		}
	}
	
	public static int getUpdateRate()
	{
		return gxtkApp.game.app.updateRate;
	}
	
	public static void showMouse()
	{
		gxtkApp.game.IsMouseVisible=true;
	}
	public static void hideMouse()
	{
		gxtkApp.game.IsMouseVisible=false;
	}
	public static void setGraphics(int w, int h)
	{
	}
	public static void setMouse(int x, int y)
	{
	}
	public static void showKeyboard()
	{
	}
	public static void launchBrowser(String address)
	{
#if WINDOWS
		System.Diagnostics.Process.Start(address);
#endif
	}
	public static void launchEmail(String email, String subject, String text)
	{
#if WINDOWS
		string message = string.Format("mailto:{0}?subject={1}&body={2}",email, subject, text);
		System.Diagnostics.Process.Start(message);
#endif
	}
	public static float realMod(float value, float amount) {
		return value % amount;
	}
	public static void startVibrate(int millisecs)
	{
	}
	public static void stopVibrate()
	{
	}
	public static int getDayOfMonth()
	{
		return 0;
	}
	
	public static int getDayOfWeek()
	{
		return 0;
	}
	
	public static int getMonth()
	{
		return 0;
	}
	
	public static int getYear()
	{
		return 0;
	}
	
	public static int getHours()
	{
		return 0;
	}
	
	public static int getMinutes()
	{
		return 0;
	}
	
	public static int getSeconds()
	{
		return 0;
	}
	
	public static int getMilliSeconds()
	{
		return 0;
	}
	public static void startGps()
	{
	}
	public static String getLatitiude()
	{
		return "";
	}
	public static String getLongitude()
	{
		return "";
	}
}
