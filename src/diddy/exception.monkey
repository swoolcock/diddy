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
		Self.fullType = GetClass(Self).Name
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
