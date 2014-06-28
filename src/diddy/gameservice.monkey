#Rem
	Ported from Ironstorm's GameServices module to work with the "new" Andorid target
	
	Copyright (c) 2013-2014 Dominik Kollon
	https://github.com/Ironstorm/bbd
	
	This module is released under the MIT license:
	Copyright (c) 2013-2014 Dominik Kollon

	Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the software, and to permit persons to whom the software is furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all copies or substantial portions of the software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#END

#If TARGET<>"android"
	#Error "Google Play Game Services only available for Android"
#Else
	#ANDROID_LIBRARY_REFERENCE_1="android.library.reference.1=google-play-services_lib"
	
	Import "native/googlegameservice/GameHelper.java"
	Import "native/googlegameservice/GameHelperUtils.java"
	Import "native/gameService.java"
	
	
	#ANDROID_MANIFEST_MAIN+="<uses-permission android:name=~qcom.google.android.providers.gsf.permission.READ_GSERVICES~q/>"
	
	#ANDROID_MANIFEST_APPLICATION+="<meta-data android:name=~qcom.google.android.gms.appstate.APP_ID~q android:value=~q@string/app_id~q />"
	#ANDROID_MANIFEST_APPLICATION+="<meta-data android:name=~qcom.google.android.gms.games.APP_ID~q android:value=~q@string/app_id~q />"

	#ANDROID_MANIFEST_APPLICATION+="<meta-data android:name=~qcom.google.android.gms.version~q android:value=~q@integer/google_play_services_version~q />"
	#ANDROID_MANIFEST_APPLICATION+="<meta-data android:name=~qcom.google.android.maps.v2.API_KEY~q android:value=~qAIzaSyBMLX87Ygin7lfZUSIUfHnckVnWe1cyKNI~q/>"
#End

Extern

Class GameService Extends Null="BBGameService"
	Method SubmitHighscore:Void(id:String, points:Int)
	Method BeginUserSignIn:Void()
	Method IsLoggedIn:Bool()
	Method SignOut:Void()
	Method SetMaxUserSignIns:Void(count:Int)
	Method ShowLeaderBoard:Void(id:String)
	Method ShowAllLeaderBoards:Void()
	Method UnlockAchievement:Void(id:String)
	Method RevealAchievement:Void(id:String)
	Method IncrementAchievement:Void(id:String, steps:Int)
	Method ShowAchievements:Void()
	Method IsNetworkAvailable:Bool()
End