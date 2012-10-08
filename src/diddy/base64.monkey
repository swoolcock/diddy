Strict

Public

' TODO: allow encoding of Int[]
' TODO: enabling lineWrap will wrap the string every lineWrapWidth characters (defaults to 80)
' enabling padOutput will pad the ending of the output with equals characters (=) to next 4-byte boundary
Function EncodeBase64:String(src:String, padOutput:Bool=False, lineWrap:Bool=False, lineWrapWidth:Int=80)
	Local rv:String = ""
	Local s1:Int, s2:Int, s3:Int, a:Int, b:Int, c:Int, d:Int, i:Int
	If src.Length = 0 Then Return ""
	Repeat
		s1 = src[i]
		If i+1 < src.Length Then s2 = src[i+1] Else s2 = 0
		If i+2 < src.Length Then s3 = src[i+2] Else s3 = 0
		a = s1 Shr 2
		b = ((s1 & 3) Shl 4) | (s2 Shr 4)
		c = ((s2 & 15) Shl 2) | (s3 Shr 6)
		d = s3 & 63
		If i+1 >= src.Length Then c = 64
		If i+2 >= src.Length Then d = 64
		rv += BASE64_CHARS[a..a+1] + BASE64_CHARS[b..b+1]
		If c < 64 Or padOutput Then rv += BASE64_CHARS[c..c+1]
		If d < 64 Or padOutput Then rv += BASE64_CHARS[d..d+1]
		i += 3
	Until i >= src.Length
	Return rv
End

' TODO: convert this to use BASE64_ARRAY
' I'll do this once Monkey has a decent string builder class.
Function DecodeBase64:String(src:String)
	Local rv:String = "", src2:String = ""
	Local s1:Int, s2:Int, s3:Int, a:Int, b:Int, c:Int, d:Int, i:Int
	' remove any non-base64 characters
	For i = 0 Until src.Length
		If BASE64_CHARS.Find(src[i..i+1]) >= 0 Then src2 += src[i..i+1]
	Next
	If src2.Length = 0 Then Return ""
	i = 0
	Repeat
		a = BASE64_CHARS.Find(src2[i..i+1])
		If i+1 > src2.Length Then Exit ' This shouldn't happen with base64, so something's wrong!
		b = BASE64_CHARS.Find(src2[i+1..i+2])
		If i+2 < src2.Length Then c = BASE64_CHARS.Find(src2[i+2..i+3]) Else c = 64
		If i+3 < src2.Length Then d = BASE64_CHARS.Find(src2[i+3..i+4]) Else d = 64
		s1 = (a Shl 2) | (b Shr 4)
		s2 = ((b & 15) Shl 4) | (c Shr 2)
		s3 = ((c & 3) Shl 6) | d
		rv += String.FromChar(s1)
		If c <> 64 Then rv += String.FromChar(s2)
		If d <> 64 Then rv += String.FromChar(s3)
		i += 4
	Until i >= src2.Length
	Return rv
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
