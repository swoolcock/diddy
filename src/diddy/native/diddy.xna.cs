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
	public static void setMouse(int x, int y)
	{
	}
	public static void showKeyboard()
	{
	}
	public static void launchBrowser(String address)
	{
	}
	public static void launchEmail(String email, String subject, String text)
	{
	}
}
