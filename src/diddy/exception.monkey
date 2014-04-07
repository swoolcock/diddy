#Rem
Copyright (c) 2011 Steve Revill and Shane Woolcock
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#End

#Rem
Header: Provides chainable exception-handling.
Exceptions are automatically caught and handled in the event methods of DiddyApp.
#End

Strict

#REFLECTION_FILTER="diddy.exception"
Import reflection

#Rem
Summary: The DiddyException class extends Throwable to provide chainable exceptions with an optional message.
#End
Class DiddyException Extends Throwable
Private
	Field message:String
	Field cause:Throwable
	Field type:String
	Field fullType:String

Public
#Rem
Summary: Gets the message assigned to this exception.
#End
	Method Message:String() Property Final
		Return message
	End
	
#Rem
Summary: Sets the message assigned to this exception.
#End
	Method Message:Void(message:String) Property Final
		Self.message = message
	End
	
#Rem
Summary: Gets the exception that caused this one, if applicable.
#End
	Method Cause:Throwable() Property Final
		Return cause
	End
	
#Rem
Summary: Sets the exception that caused this one.
#End
	Method Cause:Void(cause:Throwable) Property Final
		If cause = Self Then cause = Null
		Self.cause = cause
	End
	
#Rem
Summary: Returns the class name of this exception.
#End
	Method Type:String() Property Final
		Return type
	End
	
#Rem
Summary: Returns the fully qualified class name of this exception.
#End
	Method FullType:String() Property Final
		Return fullType
	End
	
#Rem
Summary: Creates a new DiddyException with an optional message and an optional cause.
[code]
Throw New DiddyException("This is an exception.")
[/code]
#End
	Method New(message:String="", cause:Throwable=Null)
		Self.message = message
		Self.cause = cause
		Local ci:ClassInfo = GetClass(Self)
		If ci Then
			Self.fullType = ci.Name
		Else
			Self.fullType = "diddy.exception.DiddyException"
		End
		If Self.fullType.Contains(".") Then
			Self.type = Self.fullType[Self.fullType.FindLast(".")+1..]
		Else
			Self.type = Self.fullType
		End
	End
	
#Rem
Summary: Returns a summary of the exception, and optionally its chain of causes.
#End
	Method ToString:String(recurse:Bool=False)
		Local rv:String = type+": "+message
		If recurse Then
			Local depth:Int = 10
			Local current:Throwable = cause
			While current And depth > 0
				If DiddyException(current) Then
					rv += "~nCaused by "+type+": "+DiddyException(current).message
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

''''''''''''''''''' EXCEPTIONS '''''''''''''''''''

#Rem
Summary: AssertException is thrown whenever an assertion fails.
#End
Class AssertException Extends DiddyException
	Method New(message:String="", cause:Throwable=Null)
		Super.New(message, cause)
	End
End

#Rem
Summary: ConcurrentModificationException is thrown when an ArrayList is modified while it is in an EachIn iterator.
#End
Class ConcurrentModificationException Extends DiddyException
	Method New(message:String="", cause:Throwable=Null)
		Super.New(message, cause)
	End
End

#Rem
Summary: IndexOutOfBoundsException should be thrown when the program would attempt to access an array outside of its valid range.
#End
Class IndexOutOfBoundsException Extends DiddyException
	Method New(message:String="", cause:Throwable=Null)
		Super.New(message, cause)
	End
End

#Rem
Summary: IllegalArgumentException should be thrown when a method or function determines that one or all of its arguments are invalid.
The message should describe which argument failed, and why it failed.
#End
Class IllegalArgumentException Extends DiddyException
	Method New(message:String="", cause:Throwable=Null)
		Super.New(message, cause)
	End
End

#Rem
Summary: XMLParseException is thrown when the XML parser cannot successfully parse an XML file.
#End
Class XMLParseException Extends DiddyException
	Method New(message:String="", cause:Throwable=Null)
		Super.New(message, cause)
	End
End

#Rem
Summary: UnsupportedOperationException is thrown when an "optional" container method is called but unimplemented.
#End
Class UnsupportedOperationException Extends DiddyException
	Method New(message:String="Unsupported operation.", cause:Throwable=Null)
		Super.New(message, cause)
	End
End

#Rem
Summary: FormatException is thrown when the Format function cannot successfully parse the format string.
#End
Class FormatException Extends DiddyException
	Method New(message:String="", cause:Throwable=Null)
		Super.New(message, cause)
	End
End
