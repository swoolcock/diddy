class diddy
{
	static int systemMillisecs()
	{
		int ms = (int)System.currentTimeMillis();
		return ms;
	}
	
	static void flushKeys()
	{
		for( int i = 0; i < 512; ++i )
		{
			MonkeyGame.app.input.keyStates[i] = 0;
		}
	}
}