#Rem
Copyright (c) 2011 Steve Revill and Shane Woolcock
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#End

Strict

#REFLECTION_FILTER="diddy.exception"
Import reflection

Class DiddyException Extends Throwable
Private
	Field message:String
	Field cause:Throwable
	Field type:String
	Field fullType:String

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
	
	Method Type:String() Property Final
		Return type
	End
	
	Method FullType:String() Property Final
		Return fullType
	End
	
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

Class AssertException Extends DiddyException
	Method New(message:String="", cause:Throwable=Null)
		Super.New(message, cause)
	End
End

Class ConcurrentModificationException Extends DiddyException
	Method New(message:String="", cause:Throwable=Null)
		Super.New(message, cause)
	End
End

Class IndexOutOfBoundsException Extends DiddyException
	Method New(message:String="", cause:Throwable=Null)
		Super.New(message, cause)
	End
End

Class IllegalArgumentException Extends DiddyException
	Method New(message:String="", cause:Throwable=Null)
		Super.New(message, cause)
	End
End

Class XMLParseException Extends DiddyException
	Method New(message:String="", cause:Throwable=Null)
		Super.New(message, cause)
	End
End

Class UnsupportedOperationException Extends DiddyException
	Method New(message:String="Unsupported operation.", cause:Throwable=Null)
		Super.New(message, cause)
	End
End
