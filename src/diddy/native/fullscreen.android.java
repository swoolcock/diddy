/*
Android Immersive MonkeyX Mod by sygem.
Original: https://github.com/sygem/fullscreen
LICENSE:
The MIT License (MIT)

Copyright (c) 2015 

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

class NativeFullScreen extends ActivityDelegate {

    private boolean isFullScreen = false;
    private Handler mHandler;

    final Runnable mHider = new Runnable() {
        public void run() {
            if (isFullScreen) {
                EnableFullScreenMode();
            }
        }
    };

    public NativeFullScreen() {
		if (Build.VERSION.SDK_INT < 11) {
			return;
		}
        BBAndroidGame.AndroidGame().AddActivityDelegate(this);
        BBAndroidGame.AndroidGame().GetActivity().runOnUiThread(new Runnable() {
            public void run() {
                mHandler = new Handler();
                View decorView = BBAndroidGame.AndroidGame().GetActivity().getWindow().getDecorView();
                decorView.setOnSystemUiVisibilityChangeListener(new View.OnSystemUiVisibilityChangeListener() {
                    @Override
                    public void onSystemUiVisibilityChange(int visibility) {
                        // Note that system bars will only be "visible" if none of the
                        // LOW_PROFILE, HIDE_NAVIGATION, or FULLSCREEN flags are set.
                        if ((visibility & View.SYSTEM_UI_FLAG_FULLSCREEN) == 0) {
                            // nothing to do?
                        } else {
                            if (isFullScreen) {
                                mHandler.removeCallbacks(mHider);
                                mHandler.postDelayed(mHider,2500);
                            }
                        }
                    }
                });
            }
        });
    }
    
    public void EnableFullScreenMode() {
        isFullScreen = true;
        BBAndroidGame.AndroidGame().GetActivity().runOnUiThread(new Runnable() {
            public void run() {
                if (Build.VERSION.SDK_INT < 11) {
                    return;
                }
                int newUiOptions = View.STATUS_BAR_HIDDEN;
        
                // Navigation bar hiding:  Backwards compatible to ICS.
                if (Build.VERSION.SDK_INT >= 14) {
                    newUiOptions |= View.SYSTEM_UI_FLAG_LOW_PROFILE;
                    newUiOptions |= View.SYSTEM_UI_FLAG_HIDE_NAVIGATION;
                }
                
                // Status bar hiding: Backwards compatible to Jellybean
                if (Build.VERSION.SDK_INT >= 16) {
                    newUiOptions |= View.SYSTEM_UI_FLAG_FULLSCREEN;
                    newUiOptions |= View.SYSTEM_UI_FLAG_LAYOUT_STABLE;
                    newUiOptions |= View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION;
                    newUiOptions |= View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN;
                }
        
                // Immersive mode: Backward compatible to KitKat.
                // Note that this flag doesn't do anything by itself, it only augments the behavior
                // of HIDE_NAVIGATION and FLAG_FULLSCREEN.  For the purposes of this sample
                // all three flags are being toggled together.
                // Note that there are two immersive mode UI flags, one of which is referred to as "sticky".
                // Sticky immersive mode differs in that it makes the navigation and status bars
                // semi-transparent, and the UI flag does not get cleared when the user interacts with
                // the screen.
                if (Build.VERSION.SDK_INT >= 19) {
                    newUiOptions |= View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY;
                }
                
                BBAndroidGame.AndroidGame().GetActivity().getWindow().getDecorView().setSystemUiVisibility(newUiOptions);        
            }
        });
    }
    
    public boolean IsFullScreen() {
        return isFullScreen;
    }
    
    public void DisableFullScreenMode() {
        isFullScreen = false;
        BBAndroidGame.AndroidGame().GetActivity().runOnUiThread(new Runnable() {
            public void run() {
                BBAndroidGame.AndroidGame().GetActivity().getWindow().getDecorView().setSystemUiVisibility(0);
            }
        });
    }

    public void onResume() {
        if (isFullScreen) {
            EnableFullScreenMode();
        }
    }
}