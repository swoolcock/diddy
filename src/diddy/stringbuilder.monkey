#Rem
Copyright (c) 2011 Steve Revill and Shane Woolcock
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#End

#Rem
Header: Provides the StringBuilder class.
#End
Strict
Private
Import diddy.arrays

Public
#Rem
Summary: The StringBuilder class is essentially a buffer for writing strings.
Its purpose is to allow the developer to build a large string without a lot of messy string
manipulation (memory and speed overhead).
Its use as a data buffer has been partially superseded by the new BRL [[DataBuffer]] and [[DataStream]] classes,
but it is still useful for large scale string manipulation.
#End
Class StringBuilder
Private
	Const DEFAULT_SIZE:Int = 128
	
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
		Return cache
	End
	
Public
#Rem
Summary: Returns the current maximum capacity of the StringBuilder.  This may increase as required.
#End
	Method Capacity:Int() Property
		Return characters.Length
	End
	
#Rem
Summary: Returns the current length of the StringBuilder.  This can be less than the maximum capacity.
#End
	Method Length:Int() Property
		Return length
	End
	
#Rem
Summary: Sets the length of the StringBuilder.
If the requested length is less than the current, it will be trimmed.
If the requested length is greater than the current, it will be padded with spaces.
Setting the length to 0 is the same as clearing the StringBuilder.
[code]
Local sb:=New StringBuilder("Hello World")
sb.Length = 15 ' sb now contains "Hello World    "
sb.Length = 5 ' sb now contains "Hello"
sb.Length = 0 ' sb now contains ""
[/code]
#End
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
	
#Rem
Summary: Creates a new StringBuilder with an initial capacity of 128 characters.
#End
	Method New()
		characters = New Int[DEFAULT_SIZE]
		length = 0
		dirty = False
		cache = ""
	End
	
#Rem
Summary: Creates a new StringBuilder with the specified initial capacity.
#End
	Method New(defaultSize:Int)
		If defaultSize <= 0 Then defaultSize = DEFAULT_SIZE
		characters = New Int[defaultSize]
		length = 0
		dirty = False
		cache = ""
	End
	
#Rem
Summary: Creates a new StringBuilder containing the specified string.
#End
	Method New(defaultValue:String)
		SetValue(defaultValue)
	End
	
#Rem
Summary: Returns the string represented by this StringBuilder.
#End
	Method ToString:String()
		If length <= 0 Then Return ""
		If dirty Then
			cache = String.FromChars(characters[0..length])
			dirty = False
		End
		Return cache
	End
	
#Rem
Summary: Sets the value of the StringBuilder to the specified Int.
Returns Self for chaining.
#End
	Method SetValue:StringBuilder(value:Int)
		Return SetValue(String(value))
	End
	
#Rem
Summary: Sets the value of the StringBuilder to the specified Float.
Returns Self for chaining.
#End
	Method SetValue:StringBuilder(value:Float)
		Return SetValue(String(value))
	End
	
#Rem
Summary: Sets the value of the StringBuilder to the specified Bool (either "True" or "False").
Returns Self for chaining.
#End
	Method SetValue:StringBuilder(value:Bool)
		If value Then Return SetValue("True")
		Return SetValue("False")
	End
	
#Rem
Summary: Sets the value of the StringBuilder to the String represented by another StringBuilder.
Returns Self for chaining.
#End
	Method SetValue:StringBuilder(value:StringBuilder)
		Return SetValue(value.ToString())
	End
	
#Rem
Summary: Sets the value of the StringBuilder to the specified String.
Returns Self for chaining.
#End
	Method SetValue:StringBuilder(value:String)
		dirty = True
		length = 0
		Return Append(value)
	End
	
#Rem
Summary: Sets the value of the StringBuilder to the specified Int array, in a similar fashion to [[String.FromChars]].
Returns Self for chaining.
#End
	Method SetValue:StringBuilder(value:Int[])
		dirty = True
		length = 0
		Return Append(value)
	End
	
#Rem
Summary: Appends the specified Int to the end of the StringBuilder.
Returns Self for chaining.
[code]
Local sb:=New StringBuilder("Hello World")
sb.Append(12345) ' sb now contains "Hello World12345"
[/code]
#End	
	Method Append:StringBuilder(value:Int)
		Return Append(String(value))
	End
	
#Rem
Summary: Appends the specified Float to the end of the StringBuilder.
Returns Self for chaining.
[code]
Local sb:=New StringBuilder("Hello World")
sb.Append(3.14159) ' sb now contains "Hello World3.1415"
[/code]
#End	
	Method Append:StringBuilder(value:Float)
		Return Append(String(value))
	End
	
#Rem
Summary: Appends the specified Bool to the end of the StringBuilder (either "True" or "False").
Returns Self for chaining.
[code]
Local sb:=New StringBuilder("Hello World")
sb.Append(True) ' sb now contains "Hello WorldTrue"
[/code]
#End
	Method Append:StringBuilder(value:Bool)
		If value Then Return Append("True")
		Return Append("False")
	End
	
#Rem
Summary: Appends to this StringBuilder the String represented by another StringBuilder.
Returns Self for chaining.
[code]
Local sb:=New StringBuilder("Hello World")
sb.Append(New StringBuilder("!!!")) ' sb now contains "Hello World!!!"
[/code]
#End
	Method Append:StringBuilder(value:StringBuilder)
		Return Append(value.ToString())
	End
	
#Rem
Summary: Appends the specified String to the end of the StringBuilder.
Returns Self for chaining.
[code]
Local sb:=New StringBuilder("Hello World")
sb.Append("!!!") ' sb now contains "Hello World!!!"
[/code]
#End	
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
	
#Rem
Summary: Appends the specified Int array to the StringBuilder, in a similar fashion to [[String.FromChars]].
Returns Self for chaining.
[code]
Local sb:=New StringBuilder("Hello World")
sb.Append([65,66,67,68,69]) ' sb now contains "Hello WorldABCDE"
[/code]
#End
	Method Append:StringBuilder(value:Int[])
		dirty = True
		Local temp:Int = length + value.Length
		ResizeArray(temp)
		Arrays<Int>.Copy(value, 0, characters, length, value.Length)
		length += value.Length
		Return Self
	End
	
#Rem
Summary: Appends a single byte to the StringBuilder, in a similar fashion to [[String.FromChar]].
[code]
Local sb:=New StringBuilder("Hello World")
sb.Append(65) ' sb now contains "Hello WorldA"
[/code]
#End
	Method AppendByte:StringBuilder(value:Int)
		dirty = True
		Local temp:Int = length + 1
		ResizeArray(temp)
		characters[length] = value
		length += 1
		Return Self
	End
	
#Rem
Summary: Deletes a range of characters from the StringBuilder and shifts the rest of the String back.
[code]
Local sb:=New StringBuilder("Hello World")
sb.Delete(2, 4) ' sb now contains "Heo World"
[/code]
#End
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
	
#Rem
Summary: Functions the same way as Monkey's [[String.Find]].
#End
	Method Find:Int(str:String, start:Int=0)
		Return ToString().Find(str, start)
	End
	
#Rem
Summary: Functions the same way as Monkey's [[String.FindLast]].
#End
	Method FindLast:Int(str:String)
		Return ToString().FindLast(str)
	End
	
#Rem
Summary: Functions the same way as Monkey's [[String.FindLast]].
#End
	Method FindLast:Int(str:String, start:Int)
		Return ToString().FindLast(str, start)
	End
	
#Rem
Summary: Inserts an Int at the given index and shifts the rest of String forward.
[code]
Local sb:=New StringBuilder("Hello World")
sb.Insert(2, 42) ' sb now contains "He42llo World"
[/code]
#End
	Method Insert:StringBuilder(index:Int, value:Int)
		Return Insert(index, String(value))
	End
	
#Rem
Summary: Inserts a Float at the given index and shifts the rest of String forward.
[code]
Local sb:=New StringBuilder("Hello World")
sb.Insert(2, 3.14) ' sb now contains "He3.14llo World"
[/code]
#End
	Method Insert:StringBuilder(index:Int, value:Float)
		Return Insert(index, String(value))
	End
	
#Rem
Summary: Inserts a Bool ("True" or "False") at the given index and shifts the rest of String forward.
[code]
Local sb:=New StringBuilder("Hello World")
sb.Insert(2, True) ' sb now contains "HeTruello World"
[/code]
#End
	Method Insert:StringBuilder(index:Int, value:Bool)
		If value Then Return Insert(index, "True")
		Return Insert(index, "False")
	End
	
#Rem
Summary: Inserts the value of another StringBuilder into this one at the given index and shifts the rest of String forward.
[code]
Local sb:=New StringBuilder("Hello")
sb.Insert(2, New StringBuilder("World")) ' sb now contains "HeWorldllo"
[/code]
#End
	Method Insert:StringBuilder(index:Int, value:StringBuilder)
		Return Insert(index, value.ToString())
	End
	
#Rem
Summary: Inserts a String at the given index and shifts the rest of String forward.
[code]
Local sb:=New StringBuilder("Hello")
sb.Insert(2, "World") ' sb now contains "HeWorldllo"
[/code]
#End
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
	
#Rem
Summary: Inserts an Int array at the given index and shifts the rest of String forward.
This is in a similar fashion to [[String.FromChars]].
[code]
Local sb:=New StringBuilder("Hello World")
sb.Insert(2, [65,66,67,68,69]) ' sb now contains "HeABCDEllo World"
[/code]
#End
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
	
#Rem
Summary: Replaces the characters in a certain range with the given Int value and shifts the rest of String to fit.
[code]
Local sb:=New StringBuilder("Hello World")
sb.Replace(2, 5, 12345) ' sb now contains "He12345 World"
[/code]
#End
	Method Replace:StringBuilder(startIndex:Int, endIndex:Int, value:Int)
		Return Replace(startIndex, endIndex, String(value))
	End
	
#Rem
Summary: Replaces the characters in a certain range with the given Float value and shifts the rest of String to fit.
[code]
Local sb:=New StringBuilder("Hello World")
sb.Replace(2, 5, 3.14159) ' sb now contains "He3.14159 World"
[/code]
#End
	Method Replace:StringBuilder(startIndex:Int, endIndex:Int, value:Float)
		Return Replace(startIndex, endIndex, String(value))
	End
	
#Rem
Summary: Replaces the characters in a certain range with the given Bool value ("True" or "False") and shifts the rest of String to fit.
[code]
Local sb:=New StringBuilder("Hello World")
sb.Replace(2, 5, True) ' sb now contains "HeTrue World"
[/code]
#End
	Method Replace:StringBuilder(startIndex:Int, endIndex:Int, value:Bool)
		If value Then Return Replace(startIndex, endIndex, "True")
		Return Replace(startIndex, endIndex, "False")
	End
	
#Rem
Summary: Replaces the characters in a certain range with the value of another StringBuilder and shifts the rest of String to fit.
[code]
Local sb:=New StringBuilder("Hello World")
sb.Replace(2, 5, New StringBuilder("foobar")) ' sb now contains "Hefoobar World"
[/code]
#End
	Method Replace:StringBuilder(startIndex:Int, endIndex:Int, value:StringBuilder)
		Return Replace(startIndex, endIndex, value.ToString())
	End
	
#Rem
Summary: Replaces the characters in a certain range with a given String and shifts the rest of String to fit.
[code]
Local sb:=New StringBuilder("Hello World")
sb.Replace(2, 5, "foobar") ' sb now contains "Hefoobar World"
[/code]
#End
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
	
#Rem
Summary: Replaces the characters in a certain range with a given Int array and shifts the rest of String to fit.
This is a similar fashion to [[String.FromChars]].
[code]
Local sb:=New StringBuilder("Hello World")
sb.Replace(2, 5, [65,66,67,68,69]) ' sb now contains "HeABCDE World"
[/code]
#End
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
	
#Rem
Summary: Reverses the contents of the StringBuilder.
[code]
Local sb:=New StringBuilder("Hello World")
sb.Reverse() ' sb now contains "dlroW olleH"
[/code]
#End
	Method Reverse:StringBuilder()
		If length <= 0 Then Return Self
		dirty = True
		Arrays<Int>.Reverse(characters, 0, length)
		Return Self
	End
	
#Rem
Summary: Returns a substring/slice of the StringBuilder.
[code]
Local sb:=New StringBuilder("Hello World")
Print sb.Substring(2, 8) ' prints "llo Wo"
[/code]
#End
	Method Substring:String(startIndex:Int, endIndex:Int)
		If startIndex < 0 Or startIndex > length Then Error("Start index ("+startIndex+") out of range [0-"+(length-1)+"]")
		If startIndex > endIndex Then Error("Start index ("+startIndex+") greater than end index ("+endIndex+")")
		If endIndex > length Then endIndex = length
		Local len:Int = endIndex-startIndex
		If len = 0 Then Return ""
		Return ToString()[startIndex..endIndex]
	End
	
#Rem
Summary: Copies a section of the StringBuilder to the target array.
[code]
Local sb:=New StringBuilder("Hello World")
Local arr:Int[] = New Int[10] ' arr contains [0,0,0,0,0,0,0,0,0,0]
sb.GetChars(3, 7, arr, 2) ' arr contains [0,0,108,108,111,32,0,0,0,0]
[/code]
#End
	Method GetChars:Void(startIndex:Int, endIndex:Int, dest:Int[], destIndex:Int)
		If startIndex < 0 Or startIndex > length Then Error("Start index ("+startIndex+") out of range [0-"+(length-1)+"]")
		If startIndex > endIndex Then Error("Start index ("+startIndex+") greater than end index ("+endIndex+")")
		If endIndex > length Then endIndex = length
		Local len:Int = endIndex-startIndex
		If len > 0 Then Arrays<Int>.Copy(characters, startIndex, dest, destIndex, len)
	End
	
#Rem
Summary: Returns a section of the StringBuilder as an array of Ints, as per [[String.ToChars]].
[code]
Local sb:=New StringBuilder("Hello World")
Return sb.GetChars(3,7) ' returns [108,108,111,32]
[/code]
#End
	Method GetChars:Int[](startIndex:Int, endIndex:Int)
		If startIndex < 0 Or startIndex > length Then Error("Start index ("+startIndex+") out of range [0-"+(length-1)+"]")
		If startIndex > endIndex Then Error("Start index ("+startIndex+") greater than end index ("+endIndex+")")
		If endIndex > length Then endIndex = length
		Local len:Int = endIndex-startIndex
		If len = 0 Then Return []
		Return Arrays<Int>.Slice(characters, startIndex, endIndex)
	End
	
#Rem
Summary: Sets a single character in the StringBuilder to be one represented by the given Int in the same fashion as [[String.FromChar]].
[code]
Local sb:=New StringBuilder("Hello World")
sb.SetCharAt(3,65) ' sb now contains "HelAo World"
[/code]
#End
	Method SetCharAt:Void(index:Int, ch:Int)
		If index < 0 Or index > length Then Error("Index ("+index+") out of range [0-"+(length-1)+"]")
		characters[index] = ch
	End
	
#Rem
Summary: Deletes a single character from the StringBuilder and shifts the rest of the string back.
[code]
Local sb:=New StringBuilder("Hello World")
sb.DeleteCharAt(3) ' sb now contains "Helo World"
[/code]
#End
	Method DeleteCharAt:Void(index:Int)
		If index < 0 Or index > length Then Error("Index ("+index+") out of range [0-"+(length-1)+"]")
		Arrays<Int>.Copy(characters, index+1, characters, index, characters.Length-index-1)
		length -= 1
	End
End
