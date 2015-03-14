# Introduction #

Here you will find a list of the New Commands in Diddy

# Details #

### RealMillisecs() ###
Returns the system's millisecs.

### FlushKeys() ###
Clears all the key hits (and mouse hits).

### GetUpdateRate() ###
Returns the current updaterate which was set by SetUpdateRate.

### SetMouse(x, y) ###
Sets the Mouse position in GLFW.

### ShowMouse() ###
Displays the mouse pointer.

NA for Android and iOS.

### HideMouse() ###
Hides the mouse pointer. (NA for Android and iOS)

### LaunchBrowser(address, openNewWindow) ###

Opens the default internet browser.

Params:
  * address - the URL for the browser to go to
  * openNewWindow - When set to False for HTML5 and Flash it will change the current window to the entered in URL (Defaults to True).

### LaunchEmail(email, subject, text) ###
Opens the default email program.

### SetGraphics(w, h) ###
HTML5 and GLFW

Changes the game resolution.

For HTML5 it will change the game canvas in the Javascript.

### StartVibrate(millisecs) ###
Android
Starts the Vibrator in the phone.

Must add <uses-permission android:name="android.permission.VIBRATE" />  in the AndroidManifest.xml to work.

### StopVibrate() ###
Android

Stops the vibrator (if it is running).

Must add <uses-permission android:name="android.permission.VIBRATE" />  in the AndroidManifest.xml to work.

### GetDayOfMonth() ###

### GetDayOfWeek() ###

### GetMonth() ###

### GetYear() ###

### GetHours() ###

### GetMinutes() ###

### GetSeconds() ###

### GetMilliSeconds() ###

### StartGps() ###

### GetLatitiude() ###

### GetLongitude() ###

### ShowAlertDialog() ###

### GetInputString() ###

### GetColorPixel() ###

### GetBrowserName() ###

### GetBrowserVersion() ###

### GetBrowserOS() ###

### Format(formatstring, ...) ###

### MouseZ() ###

### DrawLineThick() ###

### Rand(low, high) ###