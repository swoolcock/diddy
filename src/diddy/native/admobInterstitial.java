/*
Copyright (c) 2011 Steve Revill and Shane Woolcock
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

import com.google.android.gms.ads.*;

/**
 * Simple Admob Interstitial support for Monkey
 * Note: Only works on Monkey < v84d due to changes in androidgame.java
 *       See bug report http://www.monkey-x.com/Community/posts.php?topic=10440
*/
class AdmobInterstitial implements Runnable{

	// kind of "singleton"
	static AdmobInterstitial _admob;
	// the ad
	InterstitialAd interstitialAd;
	// ad Unit ID
	String adUnitId;
	// test device ID
	String testDeviceId;
	
	// creates an instance of the object and start the thread
	static public AdmobInterstitial GetAdmobInterstitial(String adUnitId, String testDeviceId){
		if( _admob==null ) _admob=new AdmobInterstitial();
		_admob.startAd(adUnitId, testDeviceId);
		return _admob;
	}

	// displays the ad to the user if it is ready
	public void ShowAd( ){
		if (interstitialAd != null ) {
			if (interstitialAd.isLoaded()) {
				interstitialAd.show();
			}
		}
	}
	
	// start the thread 
	private void startAd(String adUnitId, String testDeviceId){
		this.adUnitId = adUnitId;
		this.testDeviceId = testDeviceId;
		BBAndroidGame.AndroidGame().GetGameView().post(this);
	}
	
	// loads an ad
	private void loadAd(){
		if (interstitialAd != null ) {
			AdRequest adRequest = null;
			if (testDeviceId.length()>0) {
				adRequest = new AdRequest.Builder().addTestDevice(testDeviceId).build();
			} else {
				adRequest = new AdRequest.Builder().build();
			}
			interstitialAd.loadAd(adRequest);
		}
	}
	
	// the runner
	public void run(){
		Activity activity = BBAndroidGame.AndroidGame().GetActivity();
		interstitialAd = new InterstitialAd( activity );
		interstitialAd.setAdUnitId(adUnitId);
		
		// set listener so we load a new ad when the user closes one
		interstitialAd.setAdListener(new AdListener() {
		
			public void onAdFailedToLoad(int errorCode) {
			}			
			
			public void onAdClosed() {
				loadAd();
			}
			
			public void onAdLeftApplication() {
			}
			
			public void onAdLoaded() {
			}
			
			public void onAdOpened() {
			}

		});
		
		// load the first ad
		loadAd();
	}
}
