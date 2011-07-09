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
	Field mouseOn:Bool = true
	
	Method OnCreate:Int()
		Super.OnCreate()
		' set the seed to use the system time
		startingSeed = RealMillisecs()
		Seed = startingSeed
		HideMouse()
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
		End
		If KeyHit(KEY_F2) or (TouchHit(0) And TouchY() > SCREEN_HEIGHT2)
			LaunchEmail("test@testdomain.com", "TEST SUBJECT", "TEST TEXT!")
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
		Return 0
	End
		
End








