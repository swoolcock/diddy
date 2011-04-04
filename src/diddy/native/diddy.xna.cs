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
	/* Does not work, no access to gxtkGame
	Generated Monkey code:
		#if !WINDOWS_PHONE
		public static void Main(){
			new gxtkGame().Run();
		}
		#endif
	
		for( int i=0;i<512;++i ){
			gxtkGame.app.input.keyStates[i]&=0x100;
		}
	*/
    }
}
