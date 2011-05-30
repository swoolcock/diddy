Import diddy

' Tests encoding/decoding base64, using example string from Wikipedia.
Function Main:Int()
	Print "Test encoding different lengths, with = padding"
	Print EncodeBase64("any carnal pleasure.", True)
	Print EncodeBase64("any carnal pleasure", True)
	Print EncodeBase64("any carnal pleasur", True)
	Print EncodeBase64("any carnal pleasu", True)
	Print EncodeBase64("any carnal pleas", True)
	
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

