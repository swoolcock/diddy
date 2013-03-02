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
	
	public static int getPixel(int x, int y)
	{
		return 0;
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
	public static void launchBrowser(String address, String windowName)
	{
	}
	public static void launchEmail(String email, String subject, String text)
	{
	}

	public static void startVibrate(int millisecs)
	{
	}
	public static void stopVibrate()
	{
	}
	
	public static int getDayOfMonth()
	{
		DateTime d = DateTime.Now;
		return d.Day;
	}
	
	public static int getDayOfWeek()
	{
		DateTime d = DateTime.Now;
		return (int)(d.DayOfWeek);
	}
	
	public static int getMonth()
	{
		DateTime d = DateTime.Now;
		return d.Month;
	}
	
	public static int getYear()
	{
		DateTime d = DateTime.Now;
		return d.Year;
	}
	
	public static int getHours()
	{
		DateTime d = DateTime.Now;
		return d.Hour;
	}
	
	public static int getMinutes()
	{
		DateTime d = DateTime.Now;
		return d.Minute;
	}
	
	public static int getSeconds()
	{
		DateTime d = DateTime.Now;
		return d.Second;
	}
	
	public static int getMilliSeconds()
	{
		DateTime d = DateTime.Now;
		return d.Millisecond;
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
	public static void showAlertDialog(String title, String message)
	{ }
	public static String getInputString()
	{
		return "";
	}
	
	// empty function
	public static void mouseZInit()
	{
	}
	
	// empty function
	public static float mouseZ()
	{
		return 0;
	}
}
