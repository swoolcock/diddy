#Rem
Copyright (c) 2011 Steve Revill and Shane Woolcock
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#End

Import diddy

' Tests encoding/decoding base64, using example string from Wikipedia.
Function Main:Int()
	Print "Test encoding different lengths, with = padding and line wrap of 10"
	Print EncodeBase64("any carnal pleasure.", True, True, 10)
	Print EncodeBase64("any carnal pleasure", True, True, 10)
	Print EncodeBase64("any carnal pleasur", True, True, 10)
	Print EncodeBase64("any carnal pleasu", True, True, 10)
	Print EncodeBase64("any carnal pleas", True, True, 10)
	
	Print "Test decoding different lengths, with = padding and handling non-base64 characters"
	Print DecodeBase64("YW55IGNhcm5hbCB wbGVhc3VyZS4=")
	Print DecodeBase64("YW55;:''~q***IGNhcm5   hbCBwbGVhc3VyZQ==")
	Print DecodeBase64("YW55IGNhcm5hbCBwbGVhc3Vy")
	Print DecodeBase64("YW55IGNhcm5hbCBwbGVhc3U=")
	Print DecodeBase64("YW55IGNhcm5hbCBwbGVhcw==")

	Print "Test encoding different lengths, with no padding"
	Print EncodeBase64("any carnal pleasure.")
	Print EncodeBase64("any carnal pleasure")
	Print EncodeBase64("any carnal pleasur")
	Print EncodeBase64("any carnal pleasu")
	Print EncodeBase64("any carnal pleas")
	
	Print "Test decoding different lengths, with no padding and handling non-base64 characters"
	Print DecodeBase64("YW55IGNhcm5hbCBwbGVhc3VyZS4")
	Print DecodeBase64("YW55IGNh  c m5hb@$%~q~nCBwbGVhc3VyZQ")
	Print DecodeBase64("YW55IGNhcm5hbCBwbGVhc3Vy")
	Print DecodeBase64("YW55IGNhcm5hbCBwbGVhc3U")
	Print DecodeBase64("YW55IGNhcm5hbCBwbGVhcw")
	
	Return 0
End

