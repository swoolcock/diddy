#Rem
Copyright (c) 2011 Steve Revill and Shane Woolcock
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#End

Import diddy.arrays

Class StringBuilder
Public
	Const DEFAULT_SIZE:Int = 128
	
Private
	Field characters:Int[]
	Field length:Int
	
	Field dirty:Bool = False
	Field cache:String = ""
	
	Method ResizeArray:Void(targetSize:Int=-1, shrink:Bool=False)
		Local temp:Int = 2
		If targetSize < 0 Then targetSize = length
		While temp < targetSize
			temp *= 2
		End
		If temp = characters.Length Or temp < characters.Length And Not shrink Then Return
		If characters.Length = 0 Then
			characters = New Int[temp]
		Else
			characters = characters.Resize(temp)
		End
	End
	
	Method CachedString:String()
		If length <= 0 Then
			cache = ""
		Else
			cache = String.FromChars(characters[0..length])
		End
	End
	
Public
	Method Capacity:Int() Property
		Return characters.Length
	End
	
	Method Length:Int() Property
		Return length
	End
	
	Method Length:Void(length:Int) Property
		If length < 0 Then length = 0
		Local oldLength:Int = Self.length
		ResizeArray(length, True)
		If oldLength < length Then
			For Local i:Int = oldLength Until length
				characters[i] = $20 ' pad with spaces
			Next
		End
		Self.length = length
		dirty = True
	End
	
	Method New()
		characters = New Int[DEFAULT_SIZE]
		length = 0
		dirty = False
		cache = ""
	End
	
	Method New(defaultSize:Int)
		If defaultSize <= 0 Then defaultSize = DEFAULT_SIZE
		characters = New Int[defaultSize]
		length = 0
		dirty = False
		cache = ""
	End
	
	Method New(defaultValue:String)
		SetValue(defaultValue)
	End
	
	Method ToString:String()
		If length <= 0 Then Return ""
		If dirty Then
			cache = String.FromChars(characters[0..length])
			dirty = False
		End
		Return cache
	End
	
' SetValue
	Method SetValue:StringBuilder(value:Int)
		Return SetValue(String(value))
	End
	
	Method SetValue:StringBuilder(value:Float)
		Return SetValue(String(value))
	End
	
	Method SetValue:StringBuilder(value:Bool)
		If value Then Return SetValue("True")
		Return SetValue("False")
	End
	
	Method SetValue:StringBuilder(value:StringBuilder)
		Return SetValue(value.ToString())
	End
	
	Method SetValue:StringBuilder(value:String)
		dirty = True
		length = 0
		Return Append(value)
	End
	
	Method SetValue:StringBuilder(value:Int[])
		dirty = True
		length = 0
		Return Append(value)
	End
	
' Append	
	Method Append:StringBuilder(value:Int)
		Return Append(String(value))
	End
	
	Method Append:StringBuilder(value:Float)
		Return Append(String(value))
	End
	
	Method Append:StringBuilder(value:Bool)
		If value Then Return Append("True")
		Return Append("False")
	End
	
	Method Append:StringBuilder(value:StringBuilder)
		Return Append(value.ToString())
	End
	
	Method Append:StringBuilder(value:String)
		dirty = True
		Local temp:Int = length + value.Length
		ResizeArray(temp)
		For Local i:Int = 0 Until value.Length
			characters[length+i] = value[i]
		Next
		length += value.Length
		Return Self
	End
	
	Method Append:StringBuilder(value:Int[])
		dirty = True
		Local temp:Int = length + value.Length
		ResizeArray(temp)
		Arrays<Int>.Copy(value, 0, characters, length, value.Length)
		length += value.Length
		Return Self
	End
	
	Method AppendByte:StringBuilder(value:Int)
		dirty = True
		Local temp:Int = length + 1
		ResizeArray(temp)
		characters[length] = value
		length += 1
		Return Self
	End
	
' Delete
	Method Delete:StringBuilder(startIndex:Int, endIndex:Int)
		If startIndex < 0 Or startIndex > length Then Error("Start index ("+startIndex+") out of range [0-"+(length-1)+"]")
		If startIndex > endIndex Then Error("Start index ("+startIndex+") greater than end index ("+endIndex+")")
		If endIndex > length Then endIndex = length
		Local len:Int = endIndex - startIndex
		If len > 0 Then
			dirty = True
			Arrays<Int>.Copy(characters, endIndex, characters, startIndex, length-endIndex)
			Self.length -= len
		End
		Return Self
	End
	
' Find/FindLast (from Monkey strings)
	Method Find:Int(str:String, start:Int=0)
		Return ToString().Find(str, start)
	End
	
	Method FindLast:Int(str:String)
		Return ToString().FindLast(str)
	End
	
	Method FindLast:Int(str:String, start:Int)
		Return ToString().FindLast(str, start)
	End
	
' Insert
	Method Insert:StringBuilder(index:Int, value:Int)
		Return Insert(index, String(value))
	End
	
	Method Insert:StringBuilder(index:Int, value:Float)
		Return Insert(index, String(value))
	End
	
	Method Insert:StringBuilder(index:Int, value:Bool)
		If value Then Return Insert(index, "True")
		Return Insert(index, "False")
	End
	
	Method Insert:StringBuilder(index:Int, value:StringBuilder)
		Return Insert(index, value.ToString())
	End
	
	Method Insert:StringBuilder(index:Int, value:String)
		dirty = True
		If index < 0 Or index > length Then Error("Index ("+index+") out of range [0-"+(length-1)+"]")
		Local len:Int = value.Length()
		Local newlen:Int = length + len
		ResizeArray(newlen)
		Arrays<Int>.Copy(characters, index, characters, index+len, length-index)
		For Local i:Int = 0 Until len
			characters[index+i] = value[i]
		Next
		length += value.Length
		Return Self
	End
	
	Method Insert:StringBuilder(index:Int, value:Int[])
		dirty = True
		If index < 0 Or index > length Then Error("Index ("+index+") out of range [0-"+(length-1)+"]")
		Local len:Int = value.Length
		Local newlen:Int = length + len
		ResizeArray(newlen)
		Arrays<Int>.Copy(characters, index, characters, index+len, length-index)
		Arrays<Int>.Copy(value, 0, characters, index, len)
		length += value.Length
		Return Self
	End
	
' Replace
	Method Replace:StringBuilder(startIndex:Int, endIndex:Int, value:Int)
		Return Replace(startIndex, endIndex, String(value))
	End
	
	Method Replace:StringBuilder(startIndex:Int, endIndex:Int, value:Float)
		Return Replace(startIndex, endIndex, String(value))
	End
	
	Method Replace:StringBuilder(startIndex:Int, endIndex:Int, value:Bool)
		If value Then Return Replace(startIndex, endIndex, "True")
		Return Replace(startIndex, endIndex, "False")
	End
	
	Method Replace:StringBuilder(startIndex:Int, endIndex:Int, value:StringBuilder)
		Return Replace(startIndex, endIndex, value.ToString())
	End
	
	Method Replace:StringBuilder(startIndex:Int, endIndex:Int, value:String)
		If startIndex < 0 Or startIndex > length Then Error("Start index ("+startIndex+") out of range [0-"+(length-1)+"]")
		If startIndex > endIndex Then Error("Start index ("+startIndex+") greater than end index ("+endIndex+")")
		If endIndex > length Then endIndex = length
		dirty = True
		Local len:Int = value.Length()
		Local newlen:Int = length + len - (endIndex - startIndex)
		ResizeArray(newlen)
		Arrays<Int>.Copy(characters, endIndex, characters, startIndex + len, length - endIndex)
		For Local i:Int = 0 Until len
			characters[startIndex+i] = value[i]
		Next
		length -= endIndex-startIndex
		length += value.Length
		Return Self
	End
	
	Method Replace:StringBuilder(startIndex:Int, endIndex:Int, value:Int[])
		If startIndex < 0 Or startIndex > length Then Error("Start index ("+startIndex+") out of range [0-"+(length-1)+"]")
		If startIndex > endIndex Then Error("Start index ("+startIndex+") greater than end index ("+endIndex+")")
		If endIndex > length Then endIndex = length
		dirty = True
		Local len:Int = value.Length
		Local newlen:Int = length + len - (endIndex - startIndex)
		ResizeArray(newlen)
		Arrays<Int>.Copy(characters, endIndex, characters, startIndex + len, length - endIndex)
		Arrays<Int>.Copy(value, 0, characters, startIndex, len)
		length -= endIndex-startIndex
		length += value.Length
		Return Self
	End
	
' Reverse
	Method Reverse:StringBuilder()
		If length <= 0 Then Return Self
		dirty = True
		Arrays<Int>.Reverse(characters, 0, length)
		Return Self
	End
	
' Substring
	Method Substring:String(startIndex:Int, endIndex:Int)
		If startIndex < 0 Or startIndex > length Then Error("Start index ("+startIndex+") out of range [0-"+(length-1)+"]")
		If startIndex > endIndex Then Error("Start index ("+startIndex+") greater than end index ("+endIndex+")")
		If endIndex > length Then endIndex = length
		Local len:Int = endIndex-startIndex
		If len = 0 Then Return ""
		Return ToString()[startIndex..endIndex]
	End
	
' GetChars
	Method GetChars:Void(startIndex:Int, endIndex:Int, dest:Int[], destIndex:Int)
		If startIndex < 0 Or startIndex > length Then Error("Start index ("+startIndex+") out of range [0-"+(length-1)+"]")
		If startIndex > endIndex Then Error("Start index ("+startIndex+") greater than end index ("+endIndex+")")
		If endIndex > length Then endIndex = length
		Local len:Int = endIndex-startIndex
		If len > 0 Then Arrays<Int>.Copy(characters, startIndex, dest, destIndex, len)
	End
	
	Method GetChars:Int[](startIndex:Int, endIndex:Int)
		If startIndex < 0 Or startIndex > length Then Error("Start index ("+startIndex+") out of range [0-"+(length-1)+"]")
		If startIndex > endIndex Then Error("Start index ("+startIndex+") greater than end index ("+endIndex+")")
		If endIndex > length Then endIndex = length
		Local len:Int = endIndex-startIndex
		If len = 0 Then Return []
		Return Arrays<Int>.Slice(characters, startIndex, endIndex)
	End
	
' SetCharAt
	Method SetCharAt:Void(index:Int, ch:Int)
		If index < 0 Or index > length Then Error("Index ("+index+") out of range [0-"+(length-1)+"]")
		characters[index] = ch
	End
	
' DeleteCharAt
	Method DeleteCharAt:Void(index:Int)
		If index < 0 Or index > length Then Error("Index ("+index+") out of range [0-"+(length-1)+"]")
		Arrays<Int>.Copy(characters, index+1, characters, index, characters.Length-index-1)
		length -= 1
	End
End
