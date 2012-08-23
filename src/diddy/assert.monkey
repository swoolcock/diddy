Strict

Const ASSERT_MESSAGE$ = "Assertion failed!"

#Rem
	header:	Assertion functions.
	Call the corresponding Assert function with the check that you expect to pass.  If it fails, the error message will be thrown.
#End

'summary: Boolean assertion
Function Assert:Void(val?, msg$=ASSERT_MESSAGE)
	If Not val Then AssertError(msg)
End

'summary: Null assertion
Function AssertNull:Void(val:Object, msg$=ASSERT_MESSAGE)
	If val <> Null Then AssertError(msg)
End

'summary: Not Null assertion
Function AssertNotNull:Void(val:Object, msg$=ASSERT_MESSAGE)
	If val = Null Then AssertError(msg)
End

'summary: Equals Int assertion
Function AssertEqualsInt:Void(val%, expected%, msg$=ASSERT_MESSAGE)
	If val <> expected Then AssertError(msg + " " + val + "<>"+expected)
End

'summary: Equals Float assertion
Function AssertEqualsFloat:Void(val#, expected#, msg$=ASSERT_MESSAGE)
	If val <> expected Then AssertError(msg + " " + val + "<>"+expected)
End

'summary: Equals String assertion
Function AssertEqualsString:Void(val$, expected$, msg$=ASSERT_MESSAGE)
	If val <> expected Then AssertError(msg + " " + val + "<>"+expected)
End

'summary: Equals String (Ignore Case) assertion
Function AssertEqualsIgnoreCase:Void(val$, expected$, msg$=ASSERT_MESSAGE)
	' TODO: optimise this (does it create new objects?)
	If val.ToLower() <> expected.ToLower() Then AssertError(msg + " " + val + "<>"+expected)
End

'summary: Not Equals Int assertion
Function AssertNotEqualInt:Void(val%, expected%, msg$=ASSERT_MESSAGE)
	If val = expected Then AssertError(msg + " " + val + "="+expected)
End

'summary: Not Equals Float assertion
Function AssertNotEqualFloat:Void(val#, expected#, msg$=ASSERT_MESSAGE)
	If val = expected Then AssertError(msg + " " + val + "="+expected)
End

'summary: Not Equals String assertion
Function AssertNotEqualString:Void(val$, expected$, msg$=ASSERT_MESSAGE)
	If val = expected Then AssertError(msg + " " + val + "="+expected)
End

'summary: Not Equals IgnoreCase assertion
Function AssertNotEqualIgnoreCase:Void(val$, expected$, msg$=ASSERT_MESSAGE)
	' TODO: optimise this (does it create new objects?)
	If val.ToLower() = expected.ToLower() Then AssertError(msg + " " + val + "<>"+expected)
End

'summary: Less Than Int assertion
Function AssertLessThanInt:Void(val%, expected%, msg$=ASSERT_MESSAGE)
	If val >= expected Then AssertError(msg + " " + val + ">="+expected)
End

'summary: Less Than Float assertion
Function AssertLessThanFloat:Void(val#, expected#, msg$=ASSERT_MESSAGE)
	If val >= expected Then AssertError(msg + " " + val + ">="+expected)
End

'summary: Greater Than Int assertion
Function AssertGreaterThanInt:Void(val%, expected%, msg$=ASSERT_MESSAGE)
	If val <= expected Then AssertError(msg + " " + val + "<="+expected)
End

'summary: Greater Than Float assertion
Function AssertGreaterThanFloat:Void(val#, expected#, msg$=ASSERT_MESSAGE)
	If val <= expected Then AssertError(msg + " " + val + "<="+expected)
End

'summary: Less Than or Equal Int assertion
Function AssertLessThanOrEqualInt:Void(val%, expected%, msg$=ASSERT_MESSAGE)
	If val > expected Then AssertError(msg + " " + val + ">"+expected)
End

'summary: Less Than or Equal Float assertion
Function AssertLessThanOrEqualFloat:Void(val#, expected#, msg$=ASSERT_MESSAGE)
	If val > expected Then AssertError(msg + " " + val + ">"+expected)
End

'summary: Greater Than or Equal Int assertion
Function AssertGreaterThanOrEqualInt:Void(val%, expected%, msg$=ASSERT_MESSAGE)
	If val < expected Then AssertError(msg + " " + val + "<"+expected)
End

'summary: Greater Than or Equal Float assertion
Function AssertGreaterThanOrEqualFloat:Void(val#, expected#, msg$=ASSERT_MESSAGE)
	If val < expected Then AssertError(msg + " " + val + "<"+expected)
End

'summary: Assert Range Int assertion
Function AssertRangeInt:Void(val%, minbound%, maxbound%, msg$=ASSERT_MESSAGE)
	If val < minbound Or val >= maxbound Then AssertError(msg + " " + val + " is not " + minbound + "<=val<" + maxbound)
End

'summary: Assert Range Float assertion
Function AssertRangeFloat:Void(val#, minbound#, maxbound#, msg$=ASSERT_MESSAGE)
	If val < minbound Or val >= maxbound Then AssertError(msg + " " + val + " is not " + minbound + "<=val<" + maxbound)
End

'summary: Assert Range Inclusive Int assertion
Function AssertRangeInclusiveInt:Void(val%, minbound%, maxbound%, msg$=ASSERT_MESSAGE)
	If val < minbound Or val > maxbound Then AssertError(msg + " " + val + " is not " + minbound + "<=val<=" + maxbound)
End

'summary: Assert Range Inclusive Float assertion
Function AssertRangeInclusiveFloat:Void(val#, minbound#, maxbound#, msg$=ASSERT_MESSAGE)
	If val < minbound Or val > maxbound Then AssertError(msg + " " + val + " is not " + minbound + "<=val<=" + maxbound)
End

'summary: Assert Error, outputs the error of the assertion
Function AssertError:Void(msg:String)
	Throw New AssertException(msg)
End

Class AssertException Extends DiddyException
	Method New(message:String="", cause:Throwable=Null)
		Super.New(message, cause)
	End
End

Class DiddyException Extends Throwable
Private
	Field message:String
	Field cause:Throwable

Public
	Method Message:String() Property Final
		Return message
	End
	
	Method Message:Void(message:String) Property Final
		Self.message = message
	End
	
	Method Cause:Throwable() Property Final
		Return cause
	End
	
	Method Cause:Void(cause:Throwable) Property Final
		If cause = Self Then cause = Null
		Self.cause = cause
	End
	
	Method New(message:String="", cause:Throwable=Null)
		Self.message = message
		Self.cause = cause
	End
	
	Method ToString:String(recurse:Bool=False)
		Local rv:String = "Exception: "+message
		If recurse Then
			Local depth:Int = 10
			Local current:Throwable = cause
			While current And depth > 0
				If DiddyException(current) Then
					rv += "~nCaused by: "+DiddyException(current).message
					current = DiddyException(current).cause
					depth -= 1
				Else
					rv += "~nCaused by a non-Diddy exception."
					current = Null
				End
			End
		End
		Return rv
	End
End
