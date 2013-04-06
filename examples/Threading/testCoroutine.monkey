#Rem
Copyright (c) 2011 Steve Revill and Shane Woolcock
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#End

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
