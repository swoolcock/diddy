Copy the mojo monkey files here and alter app.monkey:

Add "Method SetUp()" to Class gxtkApp="gxtkApp"

And change the App Class' New method:

Class App

	Method New()
		device=New AppDevice( Self )
		device.SetUp()
	End

And Comment out the input and audio stuff...