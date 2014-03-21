#Rem
Copyright (c) 2011 Steve Revill and Shane Woolcock
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#End

Strict

Private
Import diddy.stringbuilder

Public

' enabling lineWrap will wrap the string every lineWrapWidth characters (defaults to 80)
' enabling padOutput will pad the ending of the output with equals characters (=) to next 4-byte boundary
Function EncodeBase64:String(src:Int[], padOutput:Bool=False, lineWrap:Bool=False, lineWrapWidth:Int=80)
	If src.Length = 0 Then Return ""
	Local rv:StringBuilder = New StringBuilder(Int(src.Length*4.0/3.0+10))
	Local s1:Int, s2:Int, s3:Int, a:Int, b:Int, c:Int, d:Int, i:Int
	Local charsAdded:Int = 0
	
	Repeat
		' get 3 source bytes
		s1 = src[i]
		If i+1 < src.Length Then s2 = src[i+1] Else s2 = 0
		If i+2 < src.Length Then s3 = src[i+2] Else s3 = 0
		
		' make 4 target bytes
		a = s1 Shr 2
		b = ((s1 & 3) Shl 4) | (s2 Shr 4)
		c = ((s2 & 15) Shl 2) | (s3 Shr 6)
		d = s3 & 63
		
		' set target bytes 3 and 4 if the source is not divisible by 3
		If i+1 >= src.Length Then c = 64
		If i+2 >= src.Length Then d = 64
		
		' append target bytes, adding a line wrap if we must
		If lineWrap And lineWrapWidth > 0 And charsAdded Mod lineWrapWidth = 0 And charsAdded > 1 Then rv.Append("~n")
		rv.AppendByte(BASE64_CHARS[a]); charsAdded += 1
		If lineWrap And lineWrapWidth > 0 And charsAdded Mod lineWrapWidth = 0 Then rv.Append("~n")
		rv.AppendByte(BASE64_CHARS[b]); charsAdded += 1
		If c < 64 Or padOutput Then
			If lineWrap And lineWrapWidth > 0 And charsAdded Mod lineWrapWidth = 0 Then rv.Append("~n")
			rv.AppendByte(BASE64_CHARS[c]); charsAdded += 1
		End
		If d < 64 Or padOutput Then
			If lineWrap And lineWrapWidth > 0 And charsAdded Mod lineWrapWidth = 0 Then rv.Append("~n")
			rv.AppendByte(BASE64_CHARS[d]); charsAdded += 1
		End
		
		' next 3 bytes!
		i += 3
	Until i >= src.Length
	Return rv.ToString()
End

Function EncodeBase64:String(src:String, padOutput:Bool=False, lineWrap:Bool=False, lineWrapWidth:Int=80)
	Return EncodeBase64(src.ToChars(), padOutput, lineWrap, lineWrapWidth)
End

Function DecodeBase64:String(src:String)
	Return String.FromChars(DecodeBase64Bytes(src))
End

Function DecodeBase64Bytes:Int[](src:String)
	InitBase64()
	Local a:Int, b:Int, c:Int, d:Int, i:Int, j:Int
	Local src2:Int[] = New Int[src.Length]
	Local padding:Int = 0
	
	' find out how many base64 characters
	Local srclen:Int = 0
	For i = 0 Until src.Length
		If BASE64_ARRAY[src[i]] >= 0 Then
			src2[srclen] = src[i]
			srclen += 1
			' check if it's a padding character and increment the count
			If BASE64_ARRAY[src[i]] = 64 Then padding += 1
		End
	Next
	
	' die if there are no base64 chars
	If srclen = 0 Then Return []
	
	' get the target length and create the array
	Local len:Int = 3*(srclen/4)
	If srclen Mod 4 = 0 Then
		len -= padding
	Elseif padding = 0 Then
		If srclen Mod 4 >= 2 Then len += 1
		If srclen Mod 4 = 3 Then len += 1
	End
	Local rv:Int[] = New Int[len]
	
	i = 0
	j = 0
	Repeat
		a = BASE64_ARRAY[src2[i]]
		If i+1 > srclen Then Exit ' This shouldn't happen with base64, so something's wrong!
		b = BASE64_ARRAY[src2[i+1]]
		If i+2 < srclen Then c = BASE64_ARRAY[src2[i+2]] Else c = 64
		If i+3 < srclen Then d = BASE64_ARRAY[src2[i+3]] Else d = 64
		rv[j] = (a Shl 2) | (b Shr 4)
		If j+1 < len Then rv[j+1] = ((b & 15) Shl 4) | (c Shr 2)
		If j+2 < len Then rv[j+2] = ((c & 3) Shl 6) | d
		i += 4
		j += 3
	Until i >= srclen
	Return rv
End

Private

Function InitBase64:Void()
	If BASE64_ARRAY.Length = 0 Then
		BASE64_ARRAY = New Int[256]
		Local i% = 0
		For i = 0 Until BASE64_ARRAY.Length
			BASE64_ARRAY[i] = -1
		Next
		For i = 0 Until BASE64_CHARS.Length
			BASE64_ARRAY[BASE64_CHARS[i]] = i
		Next
	End
End

Const BASE64_CHARS:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/="
Global BASE64_ARRAY:Int[] = []
