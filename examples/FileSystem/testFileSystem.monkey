Strict

Import diddy

Function Main:Int()
	New TestApp
End Function

Class TestApp Extends App
	Field fileHandler:FileSystem

	Method OnCreate:Int()
		Self.fileHandler = New FileSystem
		Local stream:FileStream
		stream = Self.fileHandler.WriteFile("test.bin")
		stream.WriteString("Hello World!")
		stream.WriteFloat(1.234567890)
		
		Self.fileHandler.SaveAll()
		Self.fileHandler.ListDir()
		
		stream = Self.fileHandler.ReadFile("test.bin")
		if stream
			Print stream.ReadString()
			Print stream.ReadFloat()
		End
		Return 0
	End
End