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
		// this only works if you change the mojo.xna.cs:
		// public class gxtkApp{
		//        public static gxtkInput input; <---- ADD STATIC KEYWORD HERE (LINE 282 - Monkey V34b)
	
		for( int i=0;i<512;++i ){
			gxtkApp.input.keyStates[i]&=0x100;
		}
	}
	
	public static void showMouse()
	{
		gxtkApp.game.IsMouseVisible=true;
	}
	public static void hideMouse()
	{
		gxtkApp.game.IsMouseVisible=false;
	}
}
