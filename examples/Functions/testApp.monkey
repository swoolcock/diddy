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
		ShowMouse()
		
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
		
		If KeyHit(KEY_ESCAPE)
			ExitApp()
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
		
		Return 0
	End
		
End








