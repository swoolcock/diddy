' Diddy XML parser
' This is a very simple XML parser, and expects a document to be as close to well-formed as possible.
' The only real leniency it has is that attributes may be defined without surrounding quotes/double quotes.
' All XML characters should be escaped in strings. &gt; &lt; etc.
' Currently it supports regular tag and attribute definitions, processing instructions, and skipping comments.
' For now, exported indentation is hardcoded to 2 spaces.
' Based on a Java example: http://www.devx.com/xml/Article/10114

Import functions
Import collections
Import io

Class XMLParser
Private
	Field reader:Reader
	Field elements:ArrayList<XMLElement> = New ArrayList<XMLElement>
	Field currentElement:XMLElement = Null
	
	Method SkipWhitespace:Void()
		While reader.Ready()
			reader.Mark()
			If Not IsWhitespace(reader.Read())
				reader.Reset()
				Return
			End
		End
	End
	
	Method SkipProlog:Void()
		reader.Skip(1)
		Local type:Int = reader.Read()
		While True
			reader.Mark()
			Local str:String = ""
			If type = ASC_QUESTION Then
				str = reader.ReadString(2)
				If str.Length < 2 Or str = "?>" Then Exit
			ElseIf type = ASC_EXCLAMATION Then
				str = reader.ReadString(3)
				If str.Length < 3 Or str = "-->" Then Exit
			End
			reader.Reset()
			If reader.Skip(1) <= 0 Then Exit
		End
	End
	
	Method SkipPrologs:Void()
		While True
			SkipWhitespace()
			Local arr:Int[] = New Int[2]
			Local numread:Int = reader.PeekArray(arr, 0, 2)
			If numread < 2 Then Return
			If arr[0] <> ASC_LESS_THAN Then
				Error("Expected '<' but got '" + String.FromChar(arr[0]) + "'.")
			End
			If arr[1] = ASC_QUESTION Or arr[1] = ASC_EXCLAMATION Then
				SkipProlog()
			Else
				Exit
			End
		End
	End
	
	Method ReadTag:String()
		SkipWhitespace()
		Local rv:String = ""
		Local ch:Int = reader.Peek()
		If ch <> ASC_LESS_THAN Then
			Error("Expected '<' but got '" + String.FromChar(ch) + "'.")
		End
		
		rv += reader.ReadChar()
		While reader.Peek() <> ASC_GREATER_THAN
			rv += reader.ReadChar()
		End
		rv += reader.ReadChar()
		
		Return rv
	End
	
	' at the moment, this does not support the CDATA tag
	Method ReadText:String()
		Local rv:String = ""
		While reader.Peek() <> ASC_LESS_THAN
			rv += reader.ReadChar()
		End
		Return rv
	End
	
Public
' Methods
	Method ParseString:XMLDocument(xmlString:String)
		Return ParseReader(New StringReader(xmlString))
	End
	
	Method ParseFile:XMLDocument(filename:String)
		' TODO: read from files, once FileReader has been implemented
		Return Null'ParseReader(New FileReader(filename))
	End
	
	Method ParseReader:XMLDocument(reader:Reader)
		Self.reader = reader
		
		Local doc:XMLDocument = New XMLDocument
		
		While True
			SkipPrologs()
			Local index:Int, tagName:String
			Local currentTag:String = ReadTag().Trim()
			If currentTag.StartsWith("</") Then
				tagName = currentTag[2..currentTag.Length-1]
				If currentElement = Null Then
					Error("Got close tag " + tagName + " without open tag.")
				End
				If tagName <> currentElement.name Then
					Error("Expected close tag for " + currentElement.name + " but got " + tagName + ".")
				End
				If elements.IsEmpty() Then
					doc.root = currentElement
					Return doc
				End
				currentElement = elements.RemoveAt(elements.Size-1)
			Else
				index = currentTag.Find(" ")
				If index < 0 Then
					If currentTag.EndsWith("/>") Then
						tagName = currentTag[1..(currentTag.Length-2)]
						currentTag = "/>"
					Else
						tagName = currentTag[1..(currentTag.Length-1)]
						currentTag = ""
					End
				Else
					tagName = currentTag[1..index]
					currentTag = currentTag[(index+1)..]
				End
				
				Local element:XMLElement = New XMLElement(tagName, currentElement)
				Local tagClosed:Bool = False
				While currentTag.Length > 0
					currentTag = currentTag.Trim()

					If currentTag = "/>" Then
						tagClosed = True
						Exit
					ElseIf currentTag = ">" Then
						Exit
					End

					index = currentTag.Find("=")
					If index < 0 Then
						Error("Invalid attribute for tag " + tagName + ".")
					End

					' this handles attributes without quoted values, but that breaks well-formed-ness and should be avoided
					Local attributeName:String = currentTag[0..index]
					currentTag = currentTag[(index+1)..]
					Local attributeValue:String
					Local quoted:Bool = True
					If currentTag.StartsWith("~q") Then
						index = currentTag.Find("~q", 1)
					ElseIf currentTag.StartsWith("'") Then
						index = currentTag.Find("'", 1)
					Else
						quoted = False
						index = currentTag.Find(" ")
						If index < 0 Then
							index = currentTag.Find(">")
							If index < 0 Then
								index = currentTag.Find("/")
							End
						End
					End

					If index < 0 Then
						Error("Invalid attribute for tag " + tagName + ".")
					End

					If quoted Then
						attributeValue = currentTag[1..index]
					Else
						attributeValue = currentTag[0..index]
					End

					element.SetAttribute(attributeName, UnescapeXMLString(attributeValue))
					currentTag = currentTag[(index+1)..]
				End
				
				If Not tagClosed Then
					element.value = UnescapeXMLString(ReadText())
					If currentElement <> Null Then
						elements.Add(currentElement)
					End
					currentElement = element
				ElseIf currentElement = Null Then
					doc.root = element
					Return doc
				End
			End
		End
	End
End

Class XMLDocument
Private
	Field root:XMLElement
	Field xmlVersion:String = "1.0"
	Field xmlEncoding:String = "UTF-8"

Public
' Constructors
	Method New(rootName:String="")
		If rootName <> "" Then root = New XMLElement(rootName)
	End

' Methods
	Method ExportString:String(formatXML:Bool = True)
		' we start with the xml instruction
		Local output:String = "<?xml version=~q"+xmlVersion+"~q encoding=~q"+xmlEncoding+"~q?>"
		If formatXML Then output += "~n"
		' root node
		output += root.ToString(formatXML) + "~n"
		' done!
		Return output
	End

	Method SaveFile:Void(filename:String)
		' TODO when file IO is ready!
	End

' Properties
	Method Root:XMLElement() Property
		Return root
	End
	
	Method Version:String() Property
		Return xmlVersion
	End
	
	Method Encoding:String() Property
		Return xmlEncoding
	End
End

Class XMLAttribute
Private
	Field name:String
	Field value:String

' Constructors
	Method New(name:String, value:String)
		Self.name = name
		Self.value = value
	End
End

Class XMLElement
Private
	Field openTagStart:String = "<"
	Field openTagEnd:String = ">"
	Field selfCloseEnd:String = " />"
	Field closeTagStart:String = "</"
	Field closeTagEnd:String = ">"
	
	Field name:String
	Field attributes:ArrayList<XMLAttribute> = New ArrayList<XMLAttribute>
	Field children:ArrayList<XMLElement> = New ArrayList<XMLElement>
	Field value:String
	Field parent:XMLElement

Public
' Constructors
	Method New(name:String, parent:XMLElement = Null)
		Self.parent = parent
		Self.name = name
		If parent <> Null Then parent.children.Add(Self)
	End

' Methods
	' avoid using this method if you can, because you should try not to have "floating" elements
	Method AddChild:Void(child:XMLElement)
		If children.Contains(child) Return
		children.Add(child)
		child.parent = Self
	End
	
	Method GetAttribute:String(name:String, defaultValue:String = "")
		For Local i% = 0 Until attributes.Size
			Local att:XMLAttribute = attributes.Get(i)
			If att.name = name Then Return att.value
		Next
		Return defaultValue
	End
	
	Method SetAttribute:String(name:String, value:String)
		For Local i% = 0 Until attributes.Size
			Local att:XMLAttribute = attributes.Get(i)
			If att.name = name Then
				Local old:String = att.value
				att.value = value
				Return old
			End
		Next
		attributes.Add(New XMLAttribute(name, value))
		Return ""
	End
	
	Method ClearAttribute:String(name:String)
		For Local i% = 0 Until attributes.Size
			Local att:XMLAttribute = attributes.Get(i)
			If att.name = name Then
				attributes.Remove(att)
				Return att.value
			End
		Next
		Return ""
	End
	
	Method Dispose:Void(removeSelf:Bool = True)
		' dispose children
		Local en:AbstractEnumerator<XMLElement> = children.Enumerator()
		While en.HasNext()
			Local element:XMLElement = en.NextObject()
			element.Dispose(False)
			en.Remove()
		End
		' remove self from parent if this is not recursing
		If removeSelf And parent <> Null Then parent.children.Remove(Self)
		' clear out the parent
		parent = Null
	End
	
	Method ToString:String(formatXML:Bool=True, indentation:Int=0)
		Local rv:String = ""
		If formatXML Then
			For Local i% = 0 Until indentation
				rv += "  "
			Next
		End
		rv += openTagStart + name
		If Not attributes.IsEmpty() Then
			For Local i% = 0 Until attributes.Size
				Local att:XMLAttribute = attributes.Get(i)
				rv += " " + att.name + "=~q" + EscapeXMLString(att.value) + "~q"
			Next
		End
		If children.IsEmpty() Then
			Local esc:String = EscapeXMLString(value.Trim())
			If esc.Length() = 0
				rv += selfCloseEnd
			Else
				rv += openTagEnd + value.Trim() + closeTagStart + name + closeTagEnd
			End
		Else
			rv += openTagEnd
			If formatXML Then
				rv += "~n"
			End
			For Local i% = 0 Until children.Size
				rv += children.Get(i).ToString(formatXML, indentation + 1)
			End
			Local esc:String = EscapeXMLString(value.Trim())
			If esc.Length() > 0 Then
				If Not formatXML Then
					rv += esc
				Else
					rv += "~n" + esc + "~n"
				End
			End
			If formatXML Then
				For Local i% = 0 Until indentation
					rv += "  "
				Next
			End
			rv += closeTagStart + name + closeTagEnd
		End
		If formatXML Then
			rv += "~n"
		End
		Return rv
	End
	
	Method GetChildrenByName:ArrayList<XMLElement>(findName:String)
		Local rv:ArrayList<XMLElement> = New ArrayList<XMLElement>
		For Local element:XMLElement = EachIn children
			If element.name = findName Then rv.Add(element)
		Next
		Return rv
	End
	
' Properties
	Method Children:ArrayList<XMLElement>() Property
		Return children
	End
	
	Method Parent:XMLElement() Property
		Return parent
	End
	
	Method Name:String() Property
		Return name
	End
	
	Method Value:String() Property
		Return value
	End
End

Function EscapeXMLString:String(str:String)
	str = str.Replace("&", "&amp;")
	str = str.Replace("<", "&lt;")
	str = str.Replace(">", "&gt;")
	str = str.Replace("'", "&apos;")
	str = str.Replace("~q", "&quot;")
	Return str
End

Function UnescapeXMLString:String(str:String)
	str = str.Replace("&quot;", "~q")
	str = str.Replace("&apos;", "'")
	str = str.Replace("&gt;", ">")
	str = str.Replace("&lt;", "<")
	str = str.Replace("&amp;", "&")
	Return str
End






