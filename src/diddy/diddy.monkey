Import "native/diddy.${TARGET}.${LANG}"

Extern

	#If LANG="cpp" Then
		Function RealMillisecs:Int() = "diddy::systemMillisecs"
		Function FlushKeys:Void() = "diddy::flushKeys"

	#Else
		Function RealMillisecs:Int() = "diddy.systemMillisecs"
		Function FlushKeys:Void() = "diddy.flushKeys"
		
	#End
		
Public
