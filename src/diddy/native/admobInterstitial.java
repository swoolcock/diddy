/*
Copyright (c) 2011 Steve Revill and Shane Woolcock
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

import com.google.ads.*;

/**
 * Simple Admob Interstitial support for Monkey
 *
*/
class AdmobInterstitial implements Runnable{

	// the kind of "singleton"
	static AdmobInterstitial _admob;
	// the ad
	InterstitialAd interstitialAd;
	// ad Unit ID
	String adUnitId;
	
	// creates an instance of the object and start the thread
	static public AdmobInterstitial GetAdmobInterstitial(String adUnitId){
		if( _admob==null ) _admob=new AdmobInterstitial();
		_admob.startAd(adUnitId);
		return _admob;
	}

	// displays the ad to the user if it is ready
	public void ShowAd( ){
		if (interstitialAd != null ) {
			if (interstitialAd.isReady()) {
				interstitialAd.show();
			}
		}
	}
	
	// start the thread 
	private void startAd(String adUnitId){
		this.adUnitId = adUnitId;
		BBAndroidGame.AndroidGame().GetGameView().post(this);
	}
	
	// loads an ad
	private void loadAd(){
		if (interstitialAd != null ) {
			AdRequest adRequest = new AdRequest();
			interstitialAd.loadAd(adRequest);
		}
	}
	
	// the runner
	public void run(){
		Activity activity = BBAndroidGame.AndroidGame().GetActivity();
		interstitialAd = new InterstitialAd( activity, adUnitId );
		
		// set listener so we load a new ad when the user closes one
		interstitialAd.setAdListener(new AdListener() {
		
			public void onDismissScreen(Ad ad) {
				loadAd();
			}
			
			public void onFailedToReceiveAd(Ad ad, AdRequest.ErrorCode error) {
			}			
			
			public void onLeaveApplication(Ad ad) {
			}
			
			public void onPresentScreen(Ad ad) {
			}
			
			public void onReceiveAd(Ad ad) {
			}
		});
		
		// load the first ad
		loadAd();
	}
}
