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
	
	public static int getUpdateRate()
	{
		return MonkeyGame.app.updateRate;
	}
	
	// empty function
	static void showMouse()
	{
	}

	// empty function
	static void hideMouse()
	{
	}
	static void setGraphics(int w, int h)
	{
	}
	// empty function
	static void setMouse(int x, int y)
	{
	}
	
	static void showKeyboard()
	{
		android.view.inputmethod.InputMethodManager inputMgr = (android.view.inputmethod.InputMethodManager)MonkeyGame.activity.getSystemService(android.content.Context.INPUT_METHOD_SERVICE);
		inputMgr.toggleSoftInput(0, 0);
	}
	
	static void launchBrowser(String address) {
		android.net.Uri uriUrl = android.net.Uri.parse(address);
		android.content.Intent launchBrowserActivity = new android.content.Intent(android.content.Intent.ACTION_VIEW, uriUrl);
		MonkeyGame.activity.startActivity(launchBrowserActivity);
	}
	
	static void launchEmail(String email, String subject, String text)
	{
		android.content.Intent emailIntent = new Intent(android.content.Intent.ACTION_SEND);	
		emailIntent.putExtra(android.content.Intent.EXTRA_EMAIL, new String[]{email});
		emailIntent.putExtra(android.content.Intent.EXTRA_SUBJECT, subject);  
		emailIntent.setType("plain/text");  
		emailIntent.putExtra(android.content.Intent.EXTRA_TEXT, text);  
		MonkeyGame.activity.startActivity(emailIntent);
	}

	
}