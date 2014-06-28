import android.database.Cursor;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.os.Bundle;
import android.os.MessageQueue.IdleHandler;
import android.provider.MediaStore;
import android.app.Fragment;
import android.net.ConnectivityManager;

import com.google.android.gms.games.achievement.*

/*
	Ported from Ironstorm's GameServices module to work with the "new" Andorid target
	
	Copyright (c) 2013-2014 Dominik Kollon
	https://github.com/Ironstorm/bbd
	
	This module is released under the MIT license:
	Copyright (c) 2013-2014 Dominik Kollon

	Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the software, and to permit persons to whom the software is furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all copies or substantial portions of the software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

class BBGameService extends ActivityDelegate {
	Activity activity;
	GameHelper mHelper;
	BBGameService parent;
	GameHelper.GameHelperListener listener;

	boolean running;

	int result = -1;
	int REQUEST_LEADERBOARD = 9101;
	int REQUEST_ACHIEVEMENTS = 9102;

	class GameServiceThread extends Thread{

		GameServiceThread(){
			running=true;	
		}

		public void run(){

			Looper.prepare();

			MessageQueue queue = Looper.myQueue();
			queue.addIdleHandler(new IdleHandler() {
				int mReqCount = 0;

				@Override
				public boolean queueIdle() {
				if (++mReqCount == 2) {
					Looper.myLooper().quit();
					return false;
				} else
					return true;
				}
            });

			mHelper = new GameHelper(activity, GameHelper.CLIENT_ALL);
			mHelper.setPlusApiOptions(new Plus.PlusOptions.Builder().build());
    		mHelper.setup(parent.listener);
			mHelper.setMaxAutoSignInAttempts(0);

			Looper.loop();
		}
	}

	@Override
    public void onStart() {
        super.onStart();
		mHelper.onStart(activity);
    }

    @Override
    public void onStop() {
        super.onStop();
		mHelper.onStop();
    }

	@Override	
	public void onActivityResult( int requestCode,int resultCode,Intent data ){
		super.onActivityResult(requestCode, resultCode, data);
		mHelper.onActivityResult(requestCode, resultCode, data);
	}
	
	public boolean IsNetworkAvailable() {
        ConnectivityManager cm = (ConnectivityManager) activity.getSystemService(Context.CONNECTIVITY_SERVICE);

        if (cm.getActiveNetworkInfo() != null && cm.getActiveNetworkInfo().isAvailable()
                && cm.getActiveNetworkInfo().isConnected()) {
            return true;
        } else {
            return false;
        }
    } 

	public BBGameService(){

		activity = BBAndroidGame.AndroidGame().GetActivity();
		parent = this;

		listener = new GameHelper.GameHelperListener() {
	       @Override
		    public void onSignInSucceeded() {
		    }
			@Override
			public void onSignInFailed() {
			}
	    };

		GameServiceThread thread=new GameServiceThread();
		running=true;
		thread.start();

		BBAndroidGame.AndroidGame().AddActivityDelegate( this );

	}

	public void SubmitHighscore(String id, int points) {
		Games.Leaderboards.submitScore(mHelper.getApiClient(), id, points);
	}

	public void UnlockAchievement(String id) {
		Games.Achievements.unlock(mHelper.getApiClient(), id);
	}

	public void RevealAchievement(String id) {
		Games.Achievements.reveal(mHelper.getApiClient(), id);
	}

	public void IncrementAchievement(String id, int step) {
		Games.Achievements.increment(mHelper.getApiClient(), id, step);
	}

	public void ShowLeaderBoard(String id) {
		activity.startActivityForResult(Games.Leaderboards.getLeaderboardIntent(mHelper.getApiClient(), id), REQUEST_LEADERBOARD);
	}
	
	public void ShowAllLeaderBoards() {
		activity.startActivityForResult(Games.Leaderboards.getAllLeaderboardsIntent(mHelper.getApiClient()), REQUEST_LEADERBOARD);
	}

	public void ShowAchievements() {
		activity.startActivityForResult(Games.Achievements.getAchievementsIntent(mHelper.getApiClient()), REQUEST_ACHIEVEMENTS);
	}

	public boolean IsLoggedIn() {
		return mHelper.isSignedIn();
	}

	public void SignOut() {
		mHelper.signOut();
	}

	public void BeginUserSignIn() {
		if(IsNetworkAvailable()) {
			mHelper.beginUserInitiatedSignIn();
		}
	}

	public void SetMaxUserSignIns(int count) {
		mHelper.setMaxAutoSignInAttempts(count);
	}

}
