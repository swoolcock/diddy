Strict

Import config
Import assert

Interface Serializable
	Method Serialize:Void(serializer:Serializer)
	Method GetClassName:String()
	Method GetGenericNames:String[]()
End

Class Serializer Abstract
Private
	Field currentNode:ConfigNode

Public
	Method Write:Void(name:String, value:Int)
		Local node:ConfigNode = New ConfigNode("field")
		node.SetAttribute("name", name)
		node.SetAttribute("value", value)
		node.SetAttribute("type", "int")
		currentNode.AddChild(node)
	End
	
	Method Write:Void(name:String, value:Float)
		Local node:ConfigNode = New ConfigNode("field")
		node.SetAttribute("name", name)
		node.SetAttribute("value", value)
		node.SetAttribute("type", "float")
		currentNode.AddChild(node)
	End
	
	Method Write:Void(name:String, value:String)
		'TODO: escape the string
		Local node:ConfigNode = New ConfigNode("field")
		node.SetAttribute("name", name)
		node.SetAttribute("value", value)
		node.SetAttribute("type", "string")
		currentNode.AddChild(node)
	End
	
	Method Write:Void(name:String, value:Serializable)
		Local lastCurrent:ConfigNode = currentNode
		Local fieldNode:ConfigNode = New ConfigNode("field")
		fieldNode.SetAttribute("name", name)
		fieldNode.SetAttribute("type", "serializable")
		currentNode.AddChild(fieldNode)
		Local objectNode:ConfigNode = New ConfigNode("object")
		objectNode.SetAttribute("class", value.GetClassName())
		fieldNode.AddChild(objectNode)
		' TODO: generics
		currentNode = objectNode
		value.Serialize(Self)
		currentNode = lastCurrent
	End
	
	Method ReadInt:Int(name:String)
		' find the named field
		For Local node:ConfigNode = EachIn currentNode.FindNodesByName("field")
			If node.GetAttribute("name") = name Then
				Return Int(node.GetAttribute("value", "0"))
			End
		Next
		Error("Couldn't find field" + name)
	End
	
	Method ReadFloat:Float(name:String)
		' find the named field
		For Local node:ConfigNode = EachIn currentNode.FindNodesByName("field")
			If node.GetAttribute("name") = name Then
				Return Float(node.GetAttribute("value", "0"))
			End
		Next
		Error("Couldn't find field" + name)
	End
	
	Method ReadString:String(name:String)
		' find the named field
		For Local node:ConfigNode = EachIn currentNode.FindNodesByName("field")
			If node.GetAttribute("name") = name Then
				Return node.GetAttribute("value")
			End
		Next
		Error("Couldn't find field" + name)
	End
	
	Method ReadSerializable:Serializable(name:String)
		' find the named field
		For Local node:ConfigNode = EachIn currentNode.FindNodesByName("field")
			If node.GetAttribute("name") = name Then
				' store the last currentNode
				Local lastCurrent:ConfigNode = currentNode
				
				' get the object node and assert it's not null
				For Local objectNode:ConfigNode = EachIn node.FindNodesByName("object")
					' set the current node to be our object node
					currentNode = objectNode
					
					' make that object serialize itself
					Local rv:Serializable = CreateSerializable(objectNode.GetAttribute("class"))
					
					' reset the current node
					currentNode = lastCurrent
					
					Return rv
				Next
			End
		Next
		Error("Couldn't find field" + name)
	End
	
	Method SerializeObject:ConfigNode(name:String, value:Serializable)
		Local objectNode:ConfigNode = New ConfigNode("object")
		objectNode.SetAttribute("name", name)
		objectNode.SetAttribute("class", value.GetClassName())
		currentNode = objectNode
		value.Serialize(Self)
		Return objectNode
	End
	
	Method DeserializeObject:Serializable(node:ConfigNode)
		AssertEquals(node.GetName(), "object", "Wasn't an object node!")
		currentNode = node
		Local rv:Serializable = CreateSerializable(node.GetAttribute("class"))
		Return rv
	End
	
	Method CreateSerializable:Serializable(className:String) Abstract
End





