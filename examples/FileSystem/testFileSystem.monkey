#Rem
Copyright (c) 2011 Steve Revill and Shane Woolcock
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#End

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