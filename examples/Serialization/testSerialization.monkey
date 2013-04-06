#Rem
Copyright (c) 2011 Steve Revill and Shane Woolcock
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#End

Strict

Import diddy

Function Main:Int()
	' the serializer we'll be using
	Local s:Serializer = New MySerializer()
	
	' instantiate a test class
	Local tc:TestClass = New TestClass()
	
	' serialize it
	Print "Serializing"
	Local tcSer:XMLElement = s.SerializeObject("tc", tc)
	
	Print "Checking xml structure"
	#Rem
	For Local node:XMLElement = EachIn tcSer.Children
		Print node.Name
		Print "name="+node.GetAttribute("name")
		Print "value="+node.GetAttribute("value")
		Print "type="+node.GetAttribute("type")
		If node.GetAttribute("type") = "serializable" Then
			Local objNode:XMLElement = node.Children.Get(0)
			Print("child="+objNode.Name)
			For Local c:XMLElement = EachIn objNode.GetChildrenByName("field")
				Print c.GetAttribute("name")+"="+c.GetAttribute("value")
			Next
		End
	Next
	#End
	Print tcSer.ToString()
	
	' deserialize it
	Print "Deserializing"
	Local tc2:TestClass = TestClass(s.DeserializeObject(tcSer))
	tcSer.Dispose()
	
	Print "tc2.intField="+tc2.intField
	Print "tc2.floatField="+tc2.floatField
	If tc2.serField = Null Then
		Print "tc2.serField=Null"
	Else
		Print "tc2.serField="
		Print "  myField="+tc2.serField.myField
	End
	Return 0
End

Class TestClass Implements ISerializable
	Field intField:Int
	Field floatField:Float
	Field serField:TestClassTwo
	
	' fields should NOT be initialised in their declarations, since the Serializer
	' will want to set its own values
	Method New()
		intField = 3
		floatField = 10.5
		serField = New TestClassTwo()
	End
	
	' All Serializable classes must have a constructor similar to this
	' it's called from the extended Serializer class, so it can technically
	' be called whatever you want.
	Method New(serializer:Serializer)
		intField = serializer.ReadInt("intField")
		floatField = serializer.ReadFloat("floatField")
		serField = TestClassTwo(serializer.ReadSerializable("serField"))
	End
	
	Method Serialize:Void(serializer:Serializer)
		serializer.Write("intField", intField)
		serializer.Write("floatField", floatField)
		serializer.Write("serField", serField)
	End
	
	Method GetClassName:String()
		Return "TestClass"
	End
	
	Method GetGenericNames:String[]()
		Return []
	End
End

Class TestClassTwo Implements ISerializable
	Field myField:Int
	
	Method New()
		myField = 10
	End
	
	Method New(serializer:Serializer)
		myField = serializer.ReadInt("myField")
	End
	
	Method Serialize:Void(serializer:Serializer)
		serializer.Write("myField", myField)
	End
	
	Method GetClassName:String()
		Return "TestClassTwo"
	End
	
	Method GetGenericNames:String[]()
		Return []
	End
End

' required because Monkey does not have reflection
' maybe some day this will be unnecessary
Class MySerializer Extends Serializer
	Method CreateSerializable:ISerializable(className:String)
		If className="TestClass" Then Return New TestClass(Self)
		If className="TestClassTwo" Then Return New TestClassTwo(Self)
		Return Null
	End
End





#Rem
Class MyClass Implements ISerializable
  Field intField:Int

  Method New()
    intField = 3
  End

  Method New(serializer:Serializer)
    intField = serializer.ReadInt("intField")
  End

  Method Serialize:Void(serializer:Serializer)
    serializer.Write("intField", intField)
  End

  Method GetClassName:String()
    Return "MyClass"
  End

  Method GetGenericNames:String[]()
    Return []
  End
End

Class MySerializer Extends Serializer
  Method CreateSerializable:ISerializable(className:String)
    If className = "MyClass" Then Return New MyClass(Self)
    Return Null
  End
End

Function Main:Int()
  ' create a serializer
  Local ser:MySerializer = New MySerializer
  ' create a test object
  Local testobj:MyClass = New MyClass
  ' serialize the object to a ConfigNode
  Local node:ConfigNode = ser.SerializeObject("testobj", testobj)
  ' deserialize the object back to a new instance of MyClass with the same fields as the original
  Local newobj:MyClass = MyClass(ser.DeserializeObject(node))
  Return 0
End

#End



