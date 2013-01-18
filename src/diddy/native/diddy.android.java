import android.os.Vibrator;
import android.content.Context;
import android.location.LocationManager;
import android.location.LocationListener;
import android.location.Location;
import android.app.AlertDialog;
import android.widget.EditText;
import android.content.DialogInterface;
import android.widget.EditText;

class diddy
{
	public static Vibrator vibrator;
	public static LocationManager myManager;
	public static String latitude = "";
	public static String longitude = "";
	public static boolean gpsStarted = false;
	public static AlertDialog.Builder alert;
	public static EditText input;
	public static String inputString = "";
	
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
	
	static int getPixel(int x, int y)
	{
		ByteBuffer pixelBuffer = ByteBuffer.allocateDirect(4);
		pixelBuffer.order(ByteOrder.LITTLE_ENDIAN); 
		GLES11.glReadPixels((int)x, (int)MonkeyGame.app.graphics.height - y, 1, 1, GL10.GL_RGBA, GL10.GL_UNSIGNED_BYTE, pixelBuffer);
		int red = pixelBuffer.get(0) & 0xff;
		int green = pixelBuffer.get(1) & 0xff;
		int blue = pixelBuffer.get(2) & 0xff;
		int alpha = pixelBuffer.get(3) & 0xff;
		// returning ARGB
		return (alpha<<24) | (red<<16) | (green<<8) |  blue;
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
	
	static void showAlertDialog(String title, String message)
	{
		alert = new AlertDialog.Builder(MonkeyGame.activity);
		alert.setTitle(title);
		alert.setMessage(message);
		// Set an EditText view to get user input 
		input = new EditText(MonkeyGame.activity);
		alert.setView(input);
		alert.setPositiveButton("Ok", new DialogInterface.OnClickListener() {
			public void onClick(DialogInterface dialog, int whichButton) {
				inputString = input.getText().toString();
			}
		});
		
		alert.setNegativeButton("Cancel", new DialogInterface.OnClickListener() { 
			public void onClick(DialogInterface dialog, int whichButton) {   
				// Canceled.  
			}
		});
		
		alert.show();
	}
	
	static String getInputString()
	{
		return inputString;
	}
	
	static void launchBrowser(String address, String windowName) {
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
	
	static void startGps()
	{
		try {
			myManager = (LocationManager)MonkeyGame.activity.getSystemService(Context.LOCATION_SERVICE);

			final LocationListener locationListener = new LocationListener() {

				public void onLocationChanged(Location location) {
					latitude = String.format("%.6f", location.getLatitude());
					longitude = String.format("%.6f", location.getLongitude());
				}
				public void onStatusChanged(String provider, int status, Bundle extras) {}
				public void onProviderEnabled(String provider) {}
				public void onProviderDisabled(String provider) {}
			};

			MonkeyGame.activity.runOnUiThread(new Runnable() {
				public void run() {
					try {
						if (!gpsStarted) {
							myManager.requestLocationUpdates(LocationManager.GPS_PROVIDER, 0, 0, locationListener); 
							gpsStarted = true;
						}
					}catch (java.lang.SecurityException e) {
						android.util.Log.e("[Monkey]", "SecurityException: " + android.util.Log.getStackTraceString(e));
					}
				}
			});
		} catch (java.lang.SecurityException e) {
			android.util.Log.e("[Monkey]", "SecurityException: " + android.util.Log.getStackTraceString(e));
		}
	}
	static String getLatitiude() {
		return latitude;
	}
	static String getLongitude() {
		return longitude;
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
		android.media.MediaPlayer mp = MonkeyGame.app.audio.music;
		if(mp!=null)
		{
			mp.seekTo(timeMillis);
		}
		// TODO: check it worked
		return 1;
	}
}
