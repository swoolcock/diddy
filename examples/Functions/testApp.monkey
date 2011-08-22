' force strict coding standard
Strict

' import the diddy module
Import diddy

' the starting point for a Monkey app
Function Main:Int()
	' create the "game"
	New MyGame
	Return 0
End

' MyGame
Class MyGame Extends DiddyApp
	' save the starting seed
	Field startingSeed:Int
	Field mouseOn:Bool = false
	Field lat:String
	Field long:String
	
	Method OnCreate:Int()
		Super.OnCreate()
		' set the seed to use the system time
		startingSeed = RealMillisecs()
		Seed = startingSeed
		HideMouse()
		StartGps()
		Return 0
	End
	
	Method OnUpdate:Int()
		If KeyHit(KEY_ENTER)
			If mouseOn
				HideMouse()
				mouseOn = False
				
			Else
				ShowMouse()
				mouseOn = True
				
			End
		End	
		If KeyHit(KEY_F1) or (TouchHit(0) And TouchY() < SCREEN_HEIGHT2)
			LaunchBrowser("http://www.google.com")
			StartVibrate(1000)
		End
		If KeyHit(KEY_F2) or (TouchHit(0) And TouchY() > SCREEN_HEIGHT2)
			LaunchEmail("test@testdomain.com", "TEST SUBJECT", "TEST TEXT!")
			StopVibrate()
		End
		
		If KeyHit(KEY_ESCAPE)
			ExitApp()
		End
		if KeyHit(KEY_Q)
			Print"Setting graphics.. to 1024x768"
			SetGraphics(1024, 768)
		End
		if KeyHit(KEY_W)
			Print"Setting graphics.. to 800 x 600"
			SetGraphics(800, 600)
		End
		if KeyHit(KEY_E)
			Print"Setting graphics.. to 640 x 480"
			SetGraphics(640, 480)
		End
		' this will print "No FlushKeys 3 times
		For Local i:Int = 1 To 3
			If KeyHit(KEY_SPACE)
				Print "No FlushKeys"
			End
		Next
		' this will print "FlushKeys once
		For Local i:Int = 1 To 3
			If KeyHit(KEY_SPACE)
				Print "FlushKeys"
				' force the seed to change
				Rnd(0,1000)
				SetMouse(100, 100)
			End
			' clear the key hits
			FlushKeys()
		Next
		If Not mouseOn
			if (MouseX() < 0 or MouseX() > DEVICE_WIDTH or MouseY()< 0 or MouseY() > DEVICE_HEIGHT)
				ShowMouse()
				SetMouse(MouseX(), MouseY())
			Else
				HideMouse()
			End
		End

		Return 0
	End

	Method OnRender:Int()
		Cls
		DrawText "Starting Seed = "+startingSeed, 10, 10
		DrawText "Seed          = "+Seed, 10, 20
		DrawText "RealMillisecs = "+RealMillisecs(), 10, 30
		DrawText "Millisecs     = "+Millisecs(), 10, 40
		If mouseOn
			DrawText "Mouse On      = true (press enter to toggle)", 10, 50	
		Else
			DrawText "Mouse On      = false (press enter to toggle)", 10, 50	
		End
		DrawText "UpdateRate    = "+GetUpdateRate(), 10, 60
		DrawText "MouseX        = "+MouseX(), 10, 70
		DrawText "MouseY        = "+MouseY(), 10, 80
		DrawText "DEVICE_WIDTH  = "+DEVICE_WIDTH, 10, 90
		DrawText "DEVICE_HEIGHT = "+DEVICE_HEIGHT, 10, 100
		DrawText "Press F1 or click the top half of the screen to Launch Browser", 10, 120
		DrawText "Press F2 or click the bottom half of the screen to Launch Email", 10, 130
		DrawText "Press Q to Change Screen size to 1024x768", 10, 140
		DrawText "Press W to Change Screen size to 800x600", 10, 150
		DrawText "Press E to Change Screen size to 640x480", 10, 160
		DrawText "Day of Month = "+GetDayOfMonth(), 10, 180
		DrawText "Day of Week = "+GetDayOfWeek(), 10, 200
		DrawText "Month = "+GetMonth(), 10, 220
		DrawText "Year = "+GetYear(), 10, 240
		DrawText "Hours = "+GetHours(), 10, 260
		DrawText "Minutes = "+GetMinutes(), 10, 280
		DrawText "Seconds = "+GetSeconds(), 10, 300
		DrawText "MilliSeconds = "+GetMilliSeconds(), 10, 320
		DrawText "GetLatitiude = "+GetLatitiude(), 10, 340
		DrawText "GetLongitude = "+GetLongitude(), 10, 360
		Return 0
	End
		
End








