' force strict coding standard
Strict

' import the mojo module
Import mojo
' import the diddy module
Import diddy

' the starting point for a Monkey app
Function Main:Int()
	' create the "game"
	New MyGame
	Return 0
End

' MyGame
Class MyGame Extends App
	' save the starting seed
	Field startingSeed:Int
	
	Method OnCreate:Int()
		' set the seed to use the system time
		startingSeed = RealMillisecs()
		Seed = startingSeed
		' 60 FPS please
		SetUpdateRate 60
		Return 0
	End
	
	Method OnUpdate:Int()
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
			End
			' clear the key hits
			FlushKeys()
		Next
		Return 0
	End

	Method OnRender:Int()
		Cls
		DrawText "Starting Seed = "+startingSeed, 10, 10
		DrawText "Seed          = "+Seed, 10, 20
		DrawText "RealMillisecs = "+RealMillisecs(), 10, 30
		DrawText "Millisecs     = "+Millisecs(), 10, 40
		
		Return 0
	End
		
End


