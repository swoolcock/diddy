/*
Copyright (c) 2011 Steve Revill and Shane Woolcock
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

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

	static void setGraphics(int w, int h)
	{
	}
	
	static void setMouse(int x, int y)
	{
	}
	
	static void showKeyboard()
	{
		android.view.inputmethod.InputMethodManager inputMgr = (android.view.inputmethod.InputMethodManager)BBAndroidGame._androidGame._activity.getSystemService(android.content.Context.INPUT_METHOD_SERVICE);
		inputMgr.toggleSoftInput(0, 0);
	}
	
	static void showAlertDialog(String title, String message)
	{
		alert = new AlertDialog.Builder(BBAndroidGame._androidGame._activity);
		alert.setTitle(title);
		alert.setMessage(message);
		// Set an EditText view to get user input 
		input = new EditText(BBAndroidGame._androidGame._activity);
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
		BBAndroidGame._androidGame._activity.startActivity(launchBrowserActivity);
	}
	
	static void launchEmail(String email, String subject, String text)
	{
		android.content.Intent emailIntent = new Intent(android.content.Intent.ACTION_SEND);	
		emailIntent.putExtra(android.content.Intent.EXTRA_EMAIL, new String[]{email});
		emailIntent.putExtra(android.content.Intent.EXTRA_SUBJECT, subject);  
		emailIntent.setType("plain/text");  
		emailIntent.putExtra(android.content.Intent.EXTRA_TEXT, text);  
		BBAndroidGame._androidGame._activity.startActivity(emailIntent);
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
			vibrator = (Vibrator)BBAndroidGame._androidGame._activity.getSystemService(Context.VIBRATOR_SERVICE);
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
	
	static void startGps()
	{
		try {
			myManager = (LocationManager)BBAndroidGame._androidGame._activity.getSystemService(Context.LOCATION_SERVICE);

			final LocationListener locationListener = new LocationListener() {

				public void onLocationChanged(Location location) {
					latitude = String.format("%.6f", location.getLatitude());
					longitude = String.format("%.6f", location.getLongitude());
				}
				public void onStatusChanged(String provider, int status, Bundle extras) {}
				public void onProviderEnabled(String provider) {}
				public void onProviderDisabled(String provider) {}
			};

			BBAndroidGame._androidGame._activity.runOnUiThread(new Runnable() {
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
		android.media.MediaPlayer mp = bb_audio.g_device.music;
		if(mp!=null)
		{
			mp.seekTo(timeMillis);
		}
		// TODO: check it worked
		return 1;
	}
}
