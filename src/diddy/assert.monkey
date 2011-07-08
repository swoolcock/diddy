Strict

Const ASSERT_MESSAGE$ = "Assertion failed!"

#Rem
	Assertion functions.
	Call the corresponding Assert function with the check that you expect to pass.  If it fails, the
	error message will be thrown.
#End

Function Assert:Void(val?, msg$=ASSERT_MESSAGE)
	If Not val Then AssertError(msg)
End

Function AssertNull:Void(val:Object, msg$=ASSERT_MESSAGE)
	If val <> Null Then AssertError(msg)
End

Function AssertNotNull:Void(val:Object, msg$=ASSERT_MESSAGE)
	If val = Null Then AssertError(msg)
End

Function AssertEqualsInt:Void(val%, expected%, msg$=ASSERT_MESSAGE)
	If val <> expected Then AssertError(msg + " " + val + "<>"+expected)
End

Function AssertEqualsFloat:Void(val#, expected#, msg$=ASSERT_MESSAGE)
	If val <> expected Then AssertError(msg + " " + val + "<>"+expected)
End

Function AssertEqualsString:Void(val$, expected$, msg$=ASSERT_MESSAGE)
	If val <> expected Then AssertError(msg + " " + val + "<>"+expected)
End

Function AssertEqualsIgnoreCase:Void(val$, expected$, msg$=ASSERT_MESSAGE)
	' TODO: optimise this (does it create new objects?)
	If val.ToLower() <> expected.ToLower() Then AssertError(msg + " " + val + "<>"+expected)
End

Function AssertNotEqualInt:Void(val%, expected%, msg$=ASSERT_MESSAGE)
	If val = expected Then AssertError(msg + " " + val + "="+expected)
End

Function AssertNotEqualFloat:Void(val#, expected#, msg$=ASSERT_MESSAGE)
	If val = expected Then AssertError(msg + " " + val + "="+expected)
End

Function AssertNotEqualString:Void(val$, expected$, msg$=ASSERT_MESSAGE)
	If val = expected Then AssertError(msg + " " + val + "="+expected)
End

Function AssertNotEqualIgnoreCase:Void(val$, expected$, msg$=ASSERT_MESSAGE)
	' TODO:
End

Function AssertLessThanInt:Void(val%, expected%, msg$=ASSERT_MESSAGE)
	If val >= expected Then AssertError(msg + " " + val + ">="+expected)
End

Function AssertLessThanFloat:Void(val#, expected#, msg$=ASSERT_MESSAGE)
	If val >= expected Then AssertError(msg + " " + val + ">="+expected)
End

Function AssertGreaterThanInt:Void(val%, expected%, msg$=ASSERT_MESSAGE)
	If val <= expected Then AssertError(msg + " " + val + "<="+expected)
End

Function AssertGreaterThanFloat:Void(val#, expected#, msg$=ASSERT_MESSAGE)
	If val <= expected Then AssertError(msg + " " + val + "<="+expected)
End

Function AssertLessThanOrEqualInt:Void(val%, expected%, msg$=ASSERT_MESSAGE)
	If val > expected Then AssertError(msg + " " + val + ">"+expected)
End

Function AssertLessThanOrEqualFloat:Void(val#, expected#, msg$=ASSERT_MESSAGE)
	If val > expected Then AssertError(msg + " " + val + ">"+expected)
End

Function AssertGreaterThanOrEqualInt:Void(val%, expected%, msg$=ASSERT_MESSAGE)
	If val < expected Then AssertError(msg + " " + val + "<"+expected)
End

Function AssertGreaterThanOrEqualFloat:Void(val#, expected#, msg$=ASSERT_MESSAGE)
	If val < expected Then AssertError(msg + " " + val + "<"+expected)
End

Function AssertRangeInt:Void(val%, minbound%, maxbound%, msg$=ASSERT_MESSAGE)
	If val < minbound Or val >= maxbound Then AssertError(msg + " " + val + " is not " + minbound + "<=val<" + size)
End

Function AssertRangeFloat:Void(val#, minbound#, maxbound#, msg$=ASSERT_MESSAGE)
	If val < minbound Or val >= maxbound Then AssertError(msg + " " + val + " is not " + minbound + "<=val<" + size)
End

Function AssertRangeInclusiveInt:Void(val%, minbound%, maxbound%, msg$=ASSERT_MESSAGE)
	If val < minbound Or val > maxbound Then AssertError(msg + " " + val + " is not " + minbound + "<=val<=" + size)
End

Function AssertRangeInclusiveFloat:Void(val#, minbound#, maxbound#, msg$=ASSERT_MESSAGE)
	If val < minbound Or val > maxbound Then AssertError(msg + " " + val + " is not " + minbound + "<=val<=" + size)
End

Function AssertError:Void(msg:String)
	Print(msg)
	Error(msg)
End

