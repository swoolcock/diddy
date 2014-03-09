
#If TARGET<>"android"
#Error "The AdmobInterstitial module is only available on the Android"
#End

#If TARGET="android"
	Import brl.admob
	Import "native/admobInterstitial.java"
#End

Extern

Class AdmobInterstitial Extends Null = "AdmobInterstitial"
	Function GetAdmobInterstitial:AdmobInterstitial(adUnitId:String)
	Method ShowAd:Void()
End
