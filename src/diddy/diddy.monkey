Import "native/diddy.${TARGET}.${LANG}"

Extern

	#If TARGET="android" Then
		Function RealMillisecs:Int() = "diddy.systemMillisecs"
		Function FlushKeys:Void() = "diddy.flushKeys"
		
	#Else If TARGET="html5"
		Function RealMillisecs:Int() = "systemMillisecs"
		Function FlushKeys:Void() = "flushKeys"

	#Else If TARGET="flash"
		Function RealMillisecs:Int() = "systemMillisecs"
		Function FlushKeys:Void() = "flushKeys"
		
	#Endif

		
Public
