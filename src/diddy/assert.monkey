#Rem
Copyright (c) 2011 Steve Revill and Shane Woolcock
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#End

#Rem
Header: Assertion functions.
Call the corresponding Assert function with the check that you expect to pass.  If it fails, the error message will be thrown.
The general idea of assertions is "We assume that this logic is true.  If it is not, please throw an exception."
#End

Strict

Private
Import diddy.exception

Const ASSERT_MESSAGE$ = "Assertion failed!"

Public

#Rem
Summary: Throws an AssertException if the passed Bool is False.
[code]
Assert(True) ' nothing happens (True = True)
Assert(False) ' AssertException is thrown (False <> True)
[/code]
#End
Function Assert:Void(val?, msg$=ASSERT_MESSAGE)
	If Not val Then AssertError(msg)
End

#Rem
Summary: Throws an AssertException if the passed object reference is Null.
[code]
AssertNull(Null) ' nothing happens (Null = Null)
AssertNull(New Object) ' AssertException is thrown (New Object <> Null)
[/code]
#End
Function AssertNull:Void(val:Object, msg$=ASSERT_MESSAGE)
	If val <> Null Then AssertError(msg)
End

#Rem
Summary: Throws an AssertException if the passed object reference is NOT Null.
[code]
AssertNotNull(Null) ' AssertException is thrown (Null = Null)
AssertNotNull(New Object) ' nothing happens (New Object <> Null)
[/code]
#End
Function AssertNotNull:Void(val:Object, msg$=ASSERT_MESSAGE)
	If val = Null Then AssertError(msg)
End

#Rem
Summary: Throws an AssertException if the passed Int does not match the expected value.
[code]
AssertEqualsInt(0, 0) ' nothing happens (0 = 0)
AssertEqualsInt(0, 1) ' AssertException is thrown (0 <> 1)
[/code]
#End
Function AssertEqualsInt:Void(val%, expected%, msg$=ASSERT_MESSAGE)
	If val <> expected Then AssertError(msg + " " + val + "<>"+expected)
End

#Rem
Summary: Throws an AssertException if the passed Float does not match the expected value.
[code]
AssertEqualsFloat(1.0, 1.0) ' nothing happens (1.0 = 1.0)
AssertEqualsFloat(1.0, 2.5) ' AssertException is thrown (1.0 <> 2.5)
[/code]
#End
Function AssertEqualsFloat:Void(val#, expected#, msg$=ASSERT_MESSAGE)
	If val <> expected Then AssertError(msg + " " + val + "<>"+expected)
End

#Rem
Summary: Throws an AssertException if the passed String does not match the expected value (case sensitive).
[code]
AssertEqualsString("hello", "hello") ' nothing happens ("hello" = "hello")
AssertEqualsString("hello", "world") ' AssertException is thrown ("hello" <> "world")
AssertEqualsString("hello", "Hello") ' AssertException is thrown ("hello" <> "Hello", case sensitive)
[/code]
#End
Function AssertEqualsString:Void(val$, expected$, msg$=ASSERT_MESSAGE)
	If val <> expected Then AssertError(msg + " " + val + "<>"+expected)
End

#Rem
Summary: Throws an AssertException if the passed String does not match the expected value (case insensitive).
[code]
AssertEqualsIgnoreCase("hello", "hello") ' nothing happens ("hello" = "hello")
AssertEqualsIgnoreCase("hello", "world") ' AssertException is thrown ("hello" <> "world")
AssertEqualsIgnoreCase("hello", "Hello") ' nothing happens ("hello" = "Hello", case insensitive)
[/code]
#End
Function AssertEqualsIgnoreCase:Void(val$, expected$, msg$=ASSERT_MESSAGE)
	' TODO: optimise this (does it create new objects?)
	If val.ToLower() <> expected.ToLower() Then AssertError(msg + " " + val + "<>"+expected)
End

#Rem
Summary: Throws an AssertException if the passed Int matches the expected value.
[code]
AssertNotEqualInt(0, 1) ' nothing happens (0 <> 1)
AssertNotEqualInt(0, 0) ' AssertException is thrown (0 = 0)
[/code]
#End
Function AssertNotEqualInt:Void(val%, expected%, msg$=ASSERT_MESSAGE)
	If val = expected Then AssertError(msg + " " + val + "="+expected)
End

#Rem
Summary: Throws an AssertException if the passed Float matches the expected value.
[code]
AssertNotEqualFloat(1.0, 1.5) ' nothing happens (1.0 <> 1.5)
AssertNotEqualFloat(1.0, 1.0) ' AssertException is thrown (1.0 = 1.0)
[/code]
#End
Function AssertNotEqualFloat:Void(val#, expected#, msg$=ASSERT_MESSAGE)
	If val = expected Then AssertError(msg + " " + val + "="+expected)
End

#Rem
Summary: Throws an AssertException if the passed String matches the expected value (case sensitive).
[code]
AssertNotEqualString("hello", "hello") ' AssertException is thrown ("hello" = "hello")
AssertNotEqualString("hello", "world") ' nothing happens ("hello" <> "world")
AssertNotEqualString("hello", "Hello") ' nothing happens ("hello" <> "Hello", case sensitive)
[/code]
#End
Function AssertNotEqualString:Void(val$, expected$, msg$=ASSERT_MESSAGE)
	If val = expected Then AssertError(msg + " " + val + "="+expected)
End

#Rem
Summary: Throws an AssertException if the passed String matches the expected value (case insensitive).
[code]
AssertNotEqualIgnoreCase("hello", "hello") ' AssertException is thrown ("hello" = "hello")
AssertNotEqualIgnoreCase("hello", "world") ' nothing happens ("hello" <> "world")
AssertNotEqualIgnoreCase("hello", "Hello") ' AssertException is thrown ("hello" = "Hello", case insensitive)
[/code]
#End
Function AssertNotEqualIgnoreCase:Void(val$, expected$, msg$=ASSERT_MESSAGE)
	' TODO: optimise this (does it create new objects?)
	If val.ToLower() = expected.ToLower() Then AssertError(msg + " " + val + "<>"+expected)
End

#Rem
Summary: Throws an AssertException if the passed Int is greater than or equal to the expected value.
[code]
AssertLessThanInt(0, 1) ' nothing happens (0 < 1)
AssertLessThanInt(1, 1) ' AssertException is thrown (1 = 1)
AssertLessThanInt(2, 1) ' AssertException is thrown (2 > 1)
[/code]
#End
Function AssertLessThanInt:Void(val%, expected%, msg$=ASSERT_MESSAGE)
	If val >= expected Then AssertError(msg + " " + val + ">="+expected)
End

#Rem
Summary: Throws an AssertException if the passed Float is greater than or equal to the expected value.
[code]
AssertLessThanFloat(0.5, 1.0) ' nothing happens (0.5 < 1.0)
AssertLessThanFloat(1.0, 1.0) ' AssertException is thrown (1.0 = 1.0)
AssertLessThanFloat(1.5, 1.0) ' AssertException is thrown (1.5 > 1.0)
[/code]
#End
Function AssertLessThanFloat:Void(val#, expected#, msg$=ASSERT_MESSAGE)
	If val >= expected Then AssertError(msg + " " + val + ">="+expected)
End

#Rem
Summary: Throws an AssertException if the passed Int is less than or equal to the expected value.
[code]
AssertGreaterThanInt(0, 1) ' AssertException is thrown (0 < 1)
AssertGreaterThanInt(1, 1) ' AssertException is thrown (1 = 1)
AssertGreaterThanInt(2, 1) ' nothing happens (2 > 1)
[/code]
#End
Function AssertGreaterThanInt:Void(val%, expected%, msg$=ASSERT_MESSAGE)
	If val <= expected Then AssertError(msg + " " + val + "<="+expected)
End

#Rem
Summary: Throws an AssertException if the passed Float is less than or equal to the expected value.
[code]
AssertGreaterThanFloat(0.5, 1.0) ' AssertException is thrown (0.5 < 1.0)
AssertGreaterThanFloat(1.0, 1.0) ' AssertException is thrown (1.0 = 1.0)
AssertGreaterThanFloat(1.5, 1.0) ' nothing happens (1.5 > 1.0)
[/code]
#End
Function AssertGreaterThanFloat:Void(val#, expected#, msg$=ASSERT_MESSAGE)
	If val <= expected Then AssertError(msg + " " + val + "<="+expected)
End

#Rem
Summary: Throws an AssertException if the passed Int is greater than the expected value.
[code]
AssertLessThanOrEqualInt(0, 1) ' nothing happens (0 < 1)
AssertLessThanOrEqualInt(1, 1) ' nothing happens (1 = 1)
AssertLessThanOrEqualInt(2, 1) ' AssertException is thrown (2 > 1)
[/code]
#End
Function AssertLessThanOrEqualInt:Void(val%, expected%, msg$=ASSERT_MESSAGE)
	If val > expected Then AssertError(msg + " " + val + ">"+expected)
End

#Rem
Summary: Throws an AssertException if the passed Float is greater than the expected value.
[code]
AssertLessThanOrEqualFloat(0.5, 1.0) ' nothing happens (0.5 < 1.0)
AssertLessThanOrEqualFloat(1.0, 1.0) ' nothing happens (1.0 = 1.0)
AssertLessThanOrEqualFloat(1.5, 1.0) ' AssertException is thrown (1.5 > 1.0)
[/code]
#End
Function AssertLessThanOrEqualFloat:Void(val#, expected#, msg$=ASSERT_MESSAGE)
	If val > expected Then AssertError(msg + " " + val + ">"+expected)
End

#Rem
Summary: Throws an AssertException if the passed Int is less than the expected value.
[code]
AssertGreaterThanOrEqualInt(0, 1) ' AssertException is thrown (0 < 1)
AssertGreaterThanOrEqualInt(1, 1) ' nothing happens (1 = 1)
AssertGreaterThanOrEqualInt(2, 1) ' nothing happens (2 > 1)
[/code]
#End
Function AssertGreaterThanOrEqualInt:Void(val%, expected%, msg$=ASSERT_MESSAGE)
	If val < expected Then AssertError(msg + " " + val + "<"+expected)
End

#Rem
Summary: Throws an AssertException if the passed Float is less than the expected value.
[code]
AssertGreaterThanOrEqualFloat(0.5, 1.0) ' AssertException is thrown (0.5 < 1.0)
AssertGreaterThanOrEqualFloat(1.0, 1.0) ' nothing happens (1.0 = 1.0)
AssertGreaterThanOrEqualFloat(1.5, 1.0) ' nothing happens (1.5 > 1.0)
[/code]
#End
Function AssertGreaterThanOrEqualFloat:Void(val#, expected#, msg$=ASSERT_MESSAGE)
	If val < expected Then AssertError(msg + " " + val + "<"+expected)
End

#Rem
Summary: Throws an AssertException if the passed Int is not in the range minbound\<=val\<maxbound.
[code]
AssertRangeInt(0, 1, 5) ' AssertException is thrown (0 < 1)
AssertRangeInt(1, 1, 5) ' nothing happens (1 = 1, minbound inclusive)
AssertRangeInt(2, 1, 5) ' nothing happens (1 <= 2 < 5)
AssertRangeInt(5, 1, 5) ' AssertException is thrown (5 = 5, maxbound exclusive)
AssertRangeInt(6, 1, 5) ' AssertException is thrown (6 > 5)
[/code]
#End
Function AssertRangeInt:Void(val%, minbound%, maxbound%, msg$=ASSERT_MESSAGE)
	If val < minbound Or val >= maxbound Then AssertError(msg + " " + val + " is not " + minbound + "<=val<" + maxbound)
End

#Rem
Summary: Throws an AssertException if the passed Float is not in the range minbound\<=val\<maxbound.
[code]
AssertRangeFloat(0.1, 1.0, 5.5) ' AssertException is thrown (0.1 < 1.0)
AssertRangeFloat(1.0, 1.0, 5.5) ' nothing happens (1.0 = 1.0, minbound inclusive)
AssertRangeFloat(2.5, 1.0, 5.5) ' nothing happens (1.0 <= 2.5 < 5.5)
AssertRangeFloat(5.5, 1.0, 5.5) ' AssertException is thrown (5.5 = 5.5, maxbound exclusive)
AssertRangeFloat(6.0, 1.0, 5.5) ' AssertException is thrown (6.0 > 5.5)
[/code]
#End
Function AssertRangeFloat:Void(val#, minbound#, maxbound#, msg$=ASSERT_MESSAGE)
	If val < minbound Or val >= maxbound Then AssertError(msg + " " + val + " is not " + minbound + "<=val<" + maxbound)
End

#Rem
Summary: Throws an AssertException if the passed Int is not in the range minbound\<=val\<=maxbound.
[code]
AssertRangeInclusiveInt(0, 1, 5) ' AssertException is thrown (0 < 1)
AssertRangeInclusiveInt(1, 1, 5) ' nothing happens (1 = 1, minbound inclusive)
AssertRangeInclusiveInt(2, 1, 5) ' nothing happens (1 <= 2 <= 5)
AssertRangeInclusiveInt(5, 1, 5) ' nothing happens (5 = 5, maxbound inclusive)
AssertRangeInclusiveInt(6, 1, 5) ' AssertException is thrown (6 > 5)
[/code]
#End
Function AssertRangeInclusiveInt:Void(val%, minbound%, maxbound%, msg$=ASSERT_MESSAGE)
	If val < minbound Or val > maxbound Then AssertError(msg + " " + val + " is not " + minbound + "<=val<=" + maxbound)
End

#Rem
Summary: Throws an AssertException if the passed Float is not in the range minbound\<=val\<=maxbound.
[code]
AssertRangeInclusiveFloat(0.1, 1.0, 5.5) ' AssertException is thrown (0.1 < 1.0)
AssertRangeInclusiveFloat(1.0, 1.0, 5.5) ' nothing happens (1.0 = 1.0, minbound inclusive)
AssertRangeInclusiveFloat(2.5, 1.0, 5.5) ' nothing happens (1.0 <= 2.5 <= 5.5)
AssertRangeInclusiveFloat(5.5, 1.0, 5.5) ' nothing happens (5.5 = 5.5, maxbound inclusive)
AssertRangeInclusiveFloat(6.0, 1.0, 5.5) ' AssertException is thrown (6.0 > 5.5)
[/code]
#End
Function AssertRangeInclusiveFloat:Void(val#, minbound#, maxbound#, msg$=ASSERT_MESSAGE)
	If val < minbound Or val > maxbound Then AssertError(msg + " " + val + " is not " + minbound + "<=val<=" + maxbound)
End

#Rem
Summary: Throws an AssertException with the passed message.
[code]
AssertError("Something bad happened!") ' AssertException is thrown
[/code]
#End
Function AssertError:Void(msg:String)
	Throw New AssertException(msg)
End

