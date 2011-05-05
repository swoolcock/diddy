Strict

Const ASSERT_MESSAGE$ = "Assertion failed!"

#Rem
	Assertion functions.
	Call the corresponding Assert function with the check that you expect to pass.  If it fails, the
	error message will be thrown.
#End

Function Assert:Void(val?, msg$=ASSERT_MESSAGE)
	If Not val Then Error(msg)
End

Function AssertNull:Void(val:Object, msg$=ASSERT_MESSAGE)
	If val <> Null Then Error(msg)
End

Function AssertNotNull:Void(val:Object, msg$=ASSERT_MESSAGE)
	If val = Null Then Error(msg)
End

Function AssertEquals:Void(val%, expected%, msg$=ASSERT_MESSAGE)
	If val <> expected Then Error(msg + " " + val + "<>"+expected)
End

Function AssertEquals:Void(val#, expected#, msg$=ASSERT_MESSAGE)
	If val <> expected Then Error(msg + " " + val + "<>"+expected)
End

Function AssertEquals:Void(val$, expected$, msg$=ASSERT_MESSAGE)
	If val <> expected Then Error(msg + " " + val + "<>"+expected)
End

Function AssertEqualsIgnoreCase:Void(val$, expected$, msg$=ASSERT_MESSAGE)
	' TODO:
End

Function AssertNotEqual:Void(val%, expected%, msg$=ASSERT_MESSAGE)
	If val = expected Then Error(msg + " " + val + "="+expected)
End

Function AssertNotEqual:Void(val#, expected#, msg$=ASSERT_MESSAGE)
	If val = expected Then Error(msg + " " + val + "="+expected)
End

Function AssertNotEqual:Void(val$, expected$, msg$=ASSERT_MESSAGE)
	If val = expected Then Error(msg + " " + val + "="+expected)
End

Function AssertNotEqualIgnoreCase:Void(val$, expected$, msg$=ASSERT_MESSAGE)
	' TODO:
End

Function AssertLessThan:Void(val%, expected%, msg$=ASSERT_MESSAGE)
	If val >= expected Then Error(msg + " " + val + ">="+expected)
End

Function AssertLessThan:Void(val#, expected#, msg$=ASSERT_MESSAGE)
	If val >= expected Then Error(msg + " " + val + ">="+expected)
End

Function AssertGreaterThan:Void(val%, expected%, msg$=ASSERT_MESSAGE)
	If val <= expected Then Error(msg + " " + val + "<="+expected)
End

Function AssertGreaterThan:Void(val#, expected#, msg$=ASSERT_MESSAGE)
	If val <= expected Then Error(msg + " " + val + "<="+expected)
End

Function AssertLessThanOrEqual:Void(val%, expected%, msg$=ASSERT_MESSAGE)
	If val > expected Then Error(msg + " " + val + ">"+expected)
End

Function AssertLessThanOrEqual:Void(val#, expected#, msg$=ASSERT_MESSAGE)
	If val > expected Then Error(msg + " " + val + ">"+expected)
End

Function AssertGreaterThanOrEqual:Void(val%, expected%, msg$=ASSERT_MESSAGE)
	If val < expected Then Error(msg + " " + val + "<"+expected)
End

Function AssertGreaterThanOrEqual:Void(val#, expected#, msg$=ASSERT_MESSAGE)
	If val < expected Then Error(msg + " " + val + "<"+expected)
End

Function AssertRange:Void(val%, minbound%, maxbound%, msg$=ASSERT_MESSAGE)
	If val < minbound Or val >= maxbound Then Error(msg + " " + val + " is not " + minbound + "<=val<" + size)
End

Function AssertRange:Void(val%, minbound#, maxbound#, msg$=ASSERT_MESSAGE)
	If val < minbound Or val >= maxbound Then Error(msg + " " + val + " is not " + minbound + "<=val<" + size)
End

Function AssertRangeInclusive:Void(val%, minbound%, maxbound%, msg$=ASSERT_MESSAGE)
	If val < minbound Or val > maxbound Then Error(msg + " " + val + " is not " + minbound + "<=val<=" + size)
End

Function AssertRangeInclusive:Void(val%, minbound#, maxbound#, msg$=ASSERT_MESSAGE)
	If val < minbound Or val > maxbound Then Error(msg + " " + val + " is not " + minbound + "<=val<=" + size)
End



