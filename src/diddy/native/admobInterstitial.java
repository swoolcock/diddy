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
