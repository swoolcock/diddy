Import mojo
Import threading

Function Main()
	New MyApp
End

Class MyApp Extends App
	Field counter1:Counter
	Field counter2:Counter
	Field counter3:Counter
	
	Method OnCreate()
		SetUpdateRate(60)
		counter1 = New Counter
		counter2 = New Counter
		counter3 = New Counter
	End
	
	Method OnUpdate()
		If KeyHit(KEY_ESCAPE) Error ""
		counter1.Resume() ' tell counter1 to continue its work
		counter2.Resume() ' tell counter2 to continue its work
		counter3.Resume() ' tell counter3 to continue its work
	End
	
	Method OnRender()
		Cls
		SetColor 255, 255, 255
		DrawText "counter1: "+counter1.value, 0, 0
		DrawText "counter2: "+counter2.value, 0, 15
		DrawText "counter3: "+counter3.value, 0, 30
	End
End

Class Counter Extends Coroutine
	Field value:Int
	
	Method Run:Int(param:Int)
		Local i:Int = 0
		Repeat
			value = i
			Yield() ' return control to the thread that called Resume
			i += 1
		Forever
	End
End
