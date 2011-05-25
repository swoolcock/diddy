Strict

Import functions
Import assert

Class Reader Abstract
Private
	Field skipBuffer:Int[] = New Int[128]

Public
	Method Mark:Void()
		Error("Mark not supported.")
	End
	
	Method MarkSupported:Bool()
		Return False
	End
	
	Method Reset:Void()
		Error("Reset not supported.")
	End
	
	' Default Skip reads "count" number of times, but this may be overridden by implementations that
	' do not need to read to increment the index (ie. StringReader)
	Method Skip:Int(count:Int)
		AssertGreaterThanOrEqual(count, 0, "Skip count must be >= 0!")
		Local numToSkip:Int = count
		While numToSkip > 0
			Local numSkipped:Int = ReadArray(skipBuffer, 0, Min(numToSkip, skipBuffer.Length))
			If numSkipped < 0 Then Exit
			numToSkip -= numSkipped
		End
		Return count - numToSkip
	End
	
	Method Peek:Int()
		Mark()
		Local rv:Int = Read()
		Reset()
		Return rv
	End
	
	Method PeekArray:Int(arr:Int[], offset:Int, length:Int)
		Mark()
		Local numRead:Int = ReadArray(arr, offset, length)
		Reset()
		Return numRead
	End
	
	Method PeekChar:Int()
		Mark()
		Local rv:String = ReadChar()
		Reset()
		Return rv
	End
	
	Method PeekString:String(length:Int)
		Mark()
		Local rv:String = ReadString(length)
		Reset()
		Return rv
	End
	
	' Default ReadChar converts the read integer to a string using String.FromChar
	Method ReadChar:String()
		Return String.FromChar(Read())
	End
	
	' Default ReadString converts the read integer to a string using String.FromChar
	Method ReadString:String(length:Int)
		Local arr:Int[] = New Int[length]
		Local numread:Int = ReadArray(arr, 0, length)
		Local rv:String = ""
		For Local i% = 0 Until numread
			rv += String.FromChar(arr[i])
		Next
		Return rv
	End
	
	Method Read:Int() Abstract
	Method ReadArray:Int(arr:Int[], offset:Int, length:Int) Abstract
	Method Ready:Bool() Abstract
	Method Close:Void() Abstract
End

Class StringReader Extends Reader
	Field index:Int = 0
	Field mark:Int = 0
	Field str:String
	
	Method New(str:String)
		Self.str = str
	End
	
	Method Mark:Void()
		mark = index
	End
	
	Method Reset:Void()
		index = mark
	End
	
	Method Read:Int()
		If Not Ready() Then Error("Reader is not ready!")
		Local oldIndex:Int = index
		index += 1
		Return str[oldIndex]
	End
	
	' ReadArray should take the Val of each character in the string
	Method ReadArray:Int(arr:Int[], offset:Int, length:Int)
		If Not Ready() Then Return -1
		Local oldIndex:Int = index
		Local numRead:Int = 0
		For Local i% = 0 Until length
			If index + i >= str.Length Then Exit
			arr[offset+i] = str[index+i]
			numRead += 1
		Next
		index += numRead
		Return numRead
	End
	
	' ReadChar doesn't need any conversion, it can just slice the string
	Method ReadChar:String()
		If Not Ready() Then Error("Reader is not ready!")
		Local oldIndex:Int = index
		index += 1
		Return str[oldIndex..oldIndex+1]
	End
	
	' ReadString doesn't need any conversion, it can just slice the string
	Method ReadString:String(length:Int)
		If Not Ready() Then Return ""
		Local rv:String = ""
		If index + length >= str.Length Then
			rv = str[index..]
			index = str.Length
			Return rv
		End
		rv = str[index..(index+length)]
		index += length
		Return rv
	End

	' Ready simply checks whether the index is within the string bounds
	Method Ready:Bool()
		Return index >= 0 And index < str.Length
	End
	
	' Skip doesn't need to read anything since it can just update the index
	Method Skip:Int(count:Int)
		If index + count >= str.Length Then
			Local rv:Int = str.Length - index
			index = str.Length
			Return rv
		End
		index += count
		Return count
	End
End


