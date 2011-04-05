Import "native/diddy.${TARGET}.${LANG}"

Extern

	#If LANG="cpp" Then
		Function RealMillisecs:Int() = "diddy::systemMillisecs"
		Function FlushKeys:Void() = "diddy::flushKeys"
		Function HideMouse:Void() = "diddy::hideMouse"
		Function ShowMouse:Void() = "diddy::showMouse"
	#Else
		Function RealMillisecs:Int() = "diddy.systemMillisecs"
		Function FlushKeys:Void() = "diddy.flushKeys"
		Function HideMouse:Void() = "diddy.hideMouse"
		Function ShowMouse:Void() = "diddy.showMouse"
	#End
	
Public

Function ExitApp:Void()
	Error ""
End
