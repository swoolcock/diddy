import android.os.Vibrator;
import android.content.Context;


class diddy
{
	public static Vibrator vibrator;

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
	/*
		For Android to set the graphics size, we need access to the surfaceholder
		currently (V43) in Monkey we dont have access to it. To get access to you need to alter
		the mojo.android.java:
		
			public static class MonkeyView extends GLSurfaceView{
				private SurfaceHolder surfaceHolder;
			
				public MonkeyView( Context context ){
					super( context );
					setUpSurfaceHolder();
				}
				
				public MonkeyView( Context context,AttributeSet attrs ){
					super( context,attrs );
					setUpSurfaceHolder();
				}
				
				private void setUpSurfaceHolder()
				{
					surfaceHolder = getHolder();
					surfaceHolder.addCallback(this);
					surfaceHolder.setType(SurfaceHolder.SURFACE_TYPE_NORMAL);
				}
				
				public SurfaceHolder getSurfaceHolder() {
					return surfaceHolder;
				}
			
		Once that change it in you can then use the following command in this file:
	
			MonkeyGame.view.getSurfaceHolder().setFixedSize(w, h);
		
	*/
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

	static String buildString(int[] arr, int offset, int length) {
		if(offset<0 || length<=0 || offset+length > arr.length)
			return "";
		StringBuilder sb = new StringBuilder(length);
		for(int i=offset;i<offset+length;i++) {
			sb.append((char)arr[i]);
		}
		return sb.toString().intern();
	}
	
	static float realMod(float value, float amount) {
		return value % amount;
	}
	
	public static void startVibrate(int millisec)
	{
		try {
			vibrator = (Vibrator)MonkeyGame.activity.getSystemService(Context.VIBRATOR_SERVICE);
			if (vibrator!=null)
				vibrator.vibrate(millisec);
		} catch (java.lang.SecurityException e) {
			android.util.Log.e("[Monkey]", "SecurityException: " + android.util.Log.getStackTraceString(e));
		}
	}
  
	public static void stopVibrate()
	{
		try {
			if (vibrator!=null)
				vibrator.cancel();
		} catch (java.lang.SecurityException e) {
			android.util.Log.e("[Monkey]", "SecurityException: " + android.util.Log.getStackTraceString(e));
		}
	}
	
	static int getDayOfMonth()
	{
		Calendar c = Calendar.getInstance();
		return c.get(Calendar.DAY_OF_MONTH);
	}
	
	static int getDayOfWeek()
	{
		Calendar c = Calendar.getInstance();
		return c.get(Calendar.DAY_OF_WEEK);
	}
	
	static int getMonth()
	{
		Calendar c = Calendar.getInstance();
		return c.get(Calendar.MONTH)+1;
	}
	
	static int getYear()
	{
		Calendar c = Calendar.getInstance();
		return c.get(Calendar.YEAR);
	}
	
	static int getHours()
	{
		Calendar c = Calendar.getInstance();
		return c.get(Calendar.HOUR_OF_DAY);
	}
	
	static int getMinutes()
	{
		Calendar c = Calendar.getInstance();
		return c.get(Calendar.MINUTE);
	}
	
	static int getSeconds()
	{
		Calendar c = Calendar.getInstance();
		return c.get(Calendar.SECOND);
	}
	
	static int getMilliSeconds()
	{
		Calendar c = Calendar.getInstance();
		return c.get(Calendar.MILLISECOND);
	}
}