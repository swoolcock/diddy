Strict

Import diddy

Function Main:Int()
	New TestApp
	Return 0	
End Function

Class TestApp Extends App
	Field fileHandler:FileSystem

  Method OnCreate:Int()
    Self.fileHandler = FileSystem.Create()
    
    Local stream:FileStream
    Local n:int
    stream = Self.fileHandler.WriteFile("test/test.bin")
    stream.WriteString("Hello")
    stream.WriteInt(1234343)
    stream.WriteString("Bye!")
    
    stream = Self.fileHandler.WriteFile("anotherfile.dat")
    stream.WriteFloat(1.234)

    Self.fileHandler.SaveAll()
    Self.fileHandler.ListDir()
    
    stream = Self.fileHandler.ReadFile("test/test.bin")
    if stream
      Print stream.ReadString()
      Print stream.ReadInt()
      Print stream.ReadString()
    EndIf
    Return 0
  End Method
End Class