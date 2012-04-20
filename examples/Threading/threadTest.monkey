Strict

Import mojo
Import threading

Global shouldQuit:Bool

Class Foo Extends Thread
	Field val:Float = 0
	Field mut:Mutex
	Field cond:CondVar
	
	Method New()
		Self.mut = New Mutex
		Self.cond = mut.CreateCondVar()
	End
	
	Method Run:Object(arg:Object)
		Local f:Float = 0
		If FloatObject(arg) Then
			f = FloatObject(arg)
		Elseif IntObject(arg) Then
			f = Float(IntObject(arg))
		Elseif StringObject(arg) Then
			f = Float(StringObject(arg).value)
		End
		mut.Lock()
		While Not shouldQuit
			val += f
			cond.Wait()
		End
		mut.Unlock()
		Return Null
	End
End

Function Main:Int()
	New MyApp
	Return 0
End

Class MyApp Extends App
	Field t1:Foo
	Field t2:Foo
	
	Method OnCreate:Int()
		SetUpdateRate(60)
		t1 = New Foo
		t2 = New Foo
		t1.Start(100)
		t2.Start(200)
		Return 0
	End
	
	Method OnUpdate:Int()
		If KeyHit(KEY_ESCAPE) Then
			shouldQuit = True
			Error ""
		End
#If TARGET="android" Then
		If TouchHit() Then
			t1.Cancel()
		End
#End
		Return 0
	End
	
	Method OnRender:Int()
		Cls
		SetColor 255, 255, 255
		Local val1#, val2#
		
		If t1.Running() Then
			t1.mut.Lock()
			val1 = t1.val
			t1.cond.Signal()
			t1.mut.Unlock()
		Else
			val1 = t1.val
		End
		
		If t2.Running() Then
			t2.mut.Lock()
			val2 = t2.val
			t2.cond.Signal()
			t2.mut.Unlock()
		Else
			val2 = t2.val
		End
		
		DrawText "val1="+val1, 10, 10
		DrawText "val2="+val2, 10, 30
		DrawText "ms="+Millisecs(), 10, 50
		Return 0
	End
End
