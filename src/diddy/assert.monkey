Strict

Const ASSERT_MESSAGE$ = "Assertion failed!"

Function Assert:Void(val?, msg$=ASSERT_MESSAGE)
	If Not val Then Error(msg)
End

Function AssertNotNull:Void(val:Object, msg$=ASSERT_MESSAGE)
	If val = Null Then Error(msg)
End

Function AssertEquals:Void(val%, expected%, msg$=ASSERT_MESSAGE)
	If val <> expected Then Error(msg)
End

Function AssertEquals:Void(val#, expected#, msg$=ASSERT_MESSAGE)
	If val <> expected Then Error(msg)
End

Function AssertEquals:Void(val$, expected$, msg$=ASSERT_MESSAGE)
	If val <> expected Then Error(msg)
End

Function AssertEqualsIgnoreCase:Void(val$, expected$, msg$=ASSERT_MESSAGE)
	' TODO:
End

Function AssertNotEqual:Void(val%, expected%, msg$=ASSERT_MESSAGE)
	If val = expected Then Error(msg)
End

Function AssertNotEqual:Void(val#, expected#, msg$=ASSERT_MESSAGE)
	If val = expected Then Error(msg)
End

Function AssertNotEqual:Void(val$, expected$, msg$=ASSERT_MESSAGE)
	If val = expected Then Error(msg)
End

Function AssertNotEqualIgnoreCase:Void(val$, expected$, msg$=ASSERT_MESSAGE)
	' TODO:
End

Function AssertLessThan:Void(val%, expected%, msg$=ASSERT_MESSAGE)
	If val >= expected Then Error(msg)
End

Function AssertLessThan:Void(val#, expected#, msg$=ASSERT_MESSAGE)
	If val >= expected Then Error(msg)
End

Function AssertGreaterThan:Void(val%, expected%, msg$=ASSERT_MESSAGE)
	If val <= expected Then Error(msg)
End

Function AssertGreaterThan:Void(val#, expected#, msg$=ASSERT_MESSAGE)
	If val <= expected Then Error(msg)
End

Function AssertLessThanOrEqual:Void(val%, expected%, msg$=ASSERT_MESSAGE)
	If val > expected Then Error(msg)
End

Function AssertLessThanOrEqual:Void(val#, expected#, msg$=ASSERT_MESSAGE)
	If val > expected Then Error(msg)
End

Function AssertGreaterThanOrEqual:Void(val%, expected%, msg$=ASSERT_MESSAGE)
	If val < expected Then Error(msg)
End

Function AssertGreaterThanOrEqual:Void(val#, expected#, msg$=ASSERT_MESSAGE)
	If val < expected Then Error(msg)
End

Function AssertRange:Void(val%, minbound%, maxbound%, msg$=ASSERT_MESSAGE)
	If val < minbound Or val >= maxbound Then Error(msg)
End

Function AssertRange:Void(val%, minbound#, maxbound#, msg$=ASSERT_MESSAGE)
	If val < minbound Or val >= maxbound Then Error(msg)
End

Function AssertRangeInclusive:Void(val%, minbound%, maxbound%, msg$=ASSERT_MESSAGE)
	If val < minbound Or val > maxbound Then Error(msg)
End

Function AssertRangeInclusive:Void(val%, minbound#, maxbound#, msg$=ASSERT_MESSAGE)
	If val < minbound Or val > maxbound Then Error(msg)
End


