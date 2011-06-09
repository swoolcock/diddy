' Diddy XML parser
' This is a very simple XML parser, and expects a document to be as close to well-formed as possible.
' The only real leniency it has is that attributes may be defined without surrounding quotes/double quotes.
' All XML characters should be escaped in strings. &gt; &lt; etc.
' Currently it supports regular tag and attribute definitions, processing instructions, and skipping comments.
' For now, exported indentation is hardcoded to 2 spaces.
' Written from scratch, using as little string manipulation as possible.

Import functions
Import collections

' note that we don't define a separate method for checking whitespace, to improve performance on android
Class XMLParser
	Field str:String
	
	' find a string, ignoring quoted strings
	Method FindUnquoted:Int(findit:String, start:Int)
		' look for the string
		Local a:Int = str.Find(findit, start)
		
		' look for a single or double quote
		Local singleQuote:Int = str.Find("'", start)
		Local doubleQuote:Int = str.Find("~q", start)
		Local quoteToFind:String = ""
		Local b:Int = -1
		If singleQuote >= 0 And doubleQuote < 0 Or singleQuote >= 0 And singleQuote < doubleQuote Then
			quoteToFind = "'"
			b = singleQuote
		ElseIf doubleQuote >= 0 And singleQuote < 0 Or doubleQuote >= 0 And doubleQuote < singleQuote Then
			quoteToFind = "~q"
			b = doubleQuote
		End
		
		' while there's a quote to check
		While b >= 0 And a >= 0 And a > b
			' find the ending quote
			b = str.Find(quoteToFind, b+1)
			
			' if not found, the quote doesn't end, so error
			If b < 0 Then Error("Unclosed quote detected.")
			
			' find the next instance after b
			a = str.Find(findit, b+1)
			
			' look for another starting quote
			singleQuote = str.Find("'", b+1)
			doubleQuote = str.Find("~q", b+1)
			b = -1
			If singleQuote >= 0 And doubleQuote < 0 Or singleQuote >= 0 And singleQuote < doubleQuote Then
				quoteToFind = "'"
				b = singleQuote
			ElseIf doubleQuote >= 0 And singleQuote < 0 Or doubleQuote >= 0 And doubleQuote < singleQuote Then
				quoteToFind = "~q"
				b = doubleQuote
			End
		End
		' done, so return a (it may be negative if not found)
		Return a
	End

	' get the contents of a tag (given start and end)
	Method GetTagContents:XMLElement(startIndex:Int, endIndex:Int)
		' trim trailing whitespace
		While endIndex > startIndex And (str[endIndex]=ASC_SPACE Or str[endIndex]=ASC_TAB Or str[endIndex]=ASC_LF Or str[endIndex]=ASC_CR)
			endIndex += 1
		End
		' die if empty tag
		If startIndex = endIndex Then Error("Empty tag detected.")
		' our element
		Local e:XMLElement = New XMLElement
		Local a:Int, singleQuoted:Bool, doubleQuoted:Bool, key:String, value:String
		
		' trim leading whitespace
		While str[startIndex]=ASC_SPACE Or str[startIndex]=ASC_TAB Or str[startIndex]=ASC_LF Or str[startIndex]=ASC_CR
			startIndex += 1
		End
		
		' get the name
		a = startIndex
		While a < endIndex
			If str[a]=ASC_SPACE Or str[a]=ASC_TAB Or str[a]=ASC_LF Or str[a]=ASC_CR Or a = endIndex-1 Then
				If a = endIndex-1 Then
					e.name = str[startIndex..endIndex]
				Else
					e.name = str[startIndex..a]
				End
				a += 1
				Exit
			End
			a += 1
		End
		startIndex = a
		
		' TODO: validate tag name is alphanumeric
		' if no name, die
		If e.name = "" Then Error("Error reading tag name.")
		
		' loop on all tokens
		While startIndex < endIndex
			' trim leading whitespace
			While startIndex < endIndex And (str[startIndex]=ASC_SPACE Or str[startIndex]=ASC_TAB Or str[startIndex]=ASC_LF Or str[startIndex]=ASC_CR)
				startIndex += 1
			End
			
			' clear check variables
			singleQuoted = False
			doubleQuoted = False
			key = ""
			value = ""
			
			' find the key
			a = startIndex
			While a < endIndex
				If str[a] = ASC_EQUALS Or str[a]=ASC_SPACE Or str[a]=ASC_TAB Or str[a]=ASC_LF Or str[a]=ASC_CR Or a = endIndex-1 Then
					If a=endIndex-1 Then
						key = str[startIndex..endIndex]
					Else
						key = str[startIndex..a]
					End
					a += 1
					Exit
				End
				a += 1
			End
			startIndex = a
			
			' if the key is empty, there was an error (unless we've hit the end of the string)
			If key = "" Then
				If a < endIndex Then
					Error("Error reading attribute key.")
				Else
					Exit
				End
			End
			
			' if it stopped on an equals, get the value
			If str[a-1] = ASC_EQUALS Then
				singleQuoted = False
				doubleQuoted = False
				While a < endIndex
					' check if it's a single quote
					If str[a] = ASC_SINGLE_QUOTE And Not doubleQuoted Then
						' if this is the first index, mark it as quoted
						If a = startIndex Then
							singleQuoted = True
						' otherwise, if we're not quoted at all, die
						ElseIf Not singleQuoted And Not doubleQuoted Then
							Error("Unexpected single quote detected in attribute value.")
						Else
							' we must be ending the quote here, so grab it and break out
							singleQuoted = False
							value = str[startIndex+1..a]
							a += 1
							Exit
						End
						
					' check if it's a double quote
					ElseIf str[a] = ASC_DOUBLE_QUOTE And Not singleQuoted Then
						' if this is the first index, mark it as quoted
						If a = startIndex Then
							doubleQuoted = True
						' otherwise, if we're not quoted at all, die
						ElseIf Not singleQuoted And Not doubleQuoted Then
							Error("Unexpected double quote detected in attribute value.")
						Else
							' we must be ending the quote here, so break out
							doubleQuoted = False
							value = str[startIndex+1..a]
							a += 1
							Exit
						End
						
					' should we be ending the attribute?
					ElseIf a = endIndex-1 Or (Not singleQuoted And Not doubleQuoted And (str[a]=ASC_SPACE Or str[a]=ASC_TAB Or str[a]=ASC_LF Or str[a]=ASC_CR))
						If a=endIndex-1 Then
							value = str[startIndex..endIndex]
						Else
							value = str[startIndex..a]
						End
						a += 1
						Exit
					End
					a += 1
				End
				startIndex = a
				value = UnescapeXMLString(value)
				
				If singleQuoted Or doubleQuoted Then Error("Unclosed quote detected.")
			End
			
			' set the attribute
			e.SetAttribute(key, value)

			If a >= endIndex Then Exit
		End
		Return e
	End

	Method ParseFile:XMLDocument(filename:String)
		Return ParseString(LoadString(filename))
	End
	
	' parses an xml doc, currently doesn't support nested PI or prolog
	Method ParseString:XMLDocument(str:String)
		Self.str = str
		
		Local doc:XMLDocument = New XMLDocument
		Local elements:ArrayList<XMLElement> = New ArrayList<XMLElement>
		Local thisE:XMLElement = Null, newE:XMLElement = Null
		Local index:Int = 0, a:Int, b:Int, c:Int, nextIndex:Int
		
		' find first opening tag
		a = str.Find("<", index)
		While a >= index
			' read text between tags
			If a > index And str[index..a].Trim() <> "" Then
				If thisE <> Null Then
					thisE.value += UnescapeXMLString(str[index..a].Trim())
				Else
					Error("Loose text outside of any tag!")
				End
			End
			' check for PI
			If str[a+1] = ASC_QUESTION Then
				' die if the PI is inside the document
				If thisE <> Null Then Error("Processing instruction detected inside main document tag.")
				' create PI element up until next unquoted ?> after a
				nextIndex = FindUnquoted("?>", a+2)
				newE = GetTagContents(a+2, nextIndex)
				newE.pi = True
				doc.pi.Add(newE)
				newE = Null
				nextIndex += 2
			' check for prolog
			ElseIf str[a+1] = ASC_EXCLAMATION Then
				' if the next two chars are -- it's a comment
				If str[a+2] = ASC_HYPHEN And str[a+3] = ASC_HYPHEN Then
					' ignore everything until the next -->
					nextIndex = str.Find("-->", a+4)
					' if we couldn't find a comment end, die
					If nextIndex < 0 Then Error("Unclosed comment detected.")
					' XML specifications say that ---> is invalid
					If str[nextIndex-1] = ASC_HYPHEN Then Error("Invalid comment close detected (too many hyphens).")
					nextIndex += 3
					
				' if the next seven chars are [CDATA[ it's a cdata block
				ElseIf str.Find("[CDATA[", a+2) = a+2 Then
					' die if the CDATA is outside the document
					If thisE = Null Then Error("CDATA detected outside main document tag.")
					nextIndex = str.Find("]]>", a+9)
					' die if it doesn't end
					If nextIndex < 0 Then Error("Unclosed CDATA tag detected.")
					newE = New XMLElement
					newE.value = str[a+9..nextIndex]
					newE.cdata = True
					thisE.AddChild(newE)
					newE = Null
					nextIndex += 3
					
				' if the next seven chars are DOCTYPE it's a dtd tag
				ElseIf str.Find("DOCTYPE", a+2) = a+2 Then
					' die if the doctype is inside the document
					If thisE <> Null Then Error("DOCTYPE detected inside main document tag.")
					nextIndex = FindUnquoted(">", a+9)
					newE = GetTagContents(a+9, nextIndex)
					newE.prolog = True
					doc.prologs.Add(newE)
					newE = Null
					nextIndex += 1
				
				' don't know!
				Else
					Error("Unknown prolog detected.")
				End
				
			' check for closing tag
			ElseIf str[a+1] = ASC_SLASH Then
				' if no current element, die
				If thisE = Null Then Error("Closing tag found outside main document tag.")
				' find the next >
				nextIndex = str.Find(">", a+2)
				' if not found, the closing tag is broken
				If nextIndex < 0 Then Error("Incomplete closing tag detected.")
				' check that the tag name matches
				If str[a+2..nextIndex].Trim() <> thisE.name Then Error("Closing tag ~q"+str[a+2..nextIndex].Trim()+"~q does not match opening tag ~q"+thisE.name+"~q")
				If Not elements.IsEmpty() Then
					thisE = elements.RemoveLast()
				Else
					doc.root = thisE
					Exit
				End
				nextIndex += 1
				
			' check for opening tag
			Else
				' look for the end of the tag, and whether it's self-closing
				b = FindUnquoted("/>", a+1)
				c = FindUnquoted(">", a+1)
				' if we couldn't find either
				If c < 0 Then
					Error("Incomplete opening tag detected.")
					
				' if it's not self-closing
				ElseIf b < 0 Or c < b Then
					' get the new one
					newE = GetTagContents(a+1, c)
					If thisE <> Null Then
						' push the current element to the stack
						elements.AddLast(thisE)
						' add it as a child element
						thisE.AddChild(newE)
					End
					thisE = newE
					newE = Null
					nextIndex = c+1
				' it's self-closing
				Else
					newE = GetTagContents(a+1, b)
					If thisE <> Null Then
						thisE.AddChild(newE)
					Else
						doc.root = newE
						Exit
					End
					newE = Null
					nextIndex = b+2
				End
			End
			index = nextIndex
			a = str.Find("<", index)
		End
		If doc.root = Null Then Error("Error parsing XML: no document tag found.")
		Return doc
	End
End

Class XMLDocument
Private
	Field xmlVersion:String = "1.0"
	Field xmlEncoding:String = "UTF-8"
	Field root:XMLElement
	Field pi:ArrayList<XMLElement> = New ArrayList<XMLElement>
	Field prologs:ArrayList<XMLElement> = New ArrayList<XMLElement>
	
Public
	
' Constructors
	Method New(rootName:String="")
		If rootName <> "" Then root = New XMLElement(rootName)
	End

	Method New(root:XMLElement)
		Self.root = root
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
	
	Method Prologs:ArrayList<XMLElement>() Property
		Return prologs
	End
	
	Method ProcessingInstructions:ArrayList<XMLElement>() Property
		Return pi
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

	Field pi:Bool
	Field prolog:Bool
	Field cdata:Bool
	
Public
' Constructors
	Method New()
	End
	
	Method New(name:String, parent:XMLElement = Null)
		Self.parent = parent
		Self.name = name
		If parent <> Null Then parent.children.Add(Self)
	End

' Methods
	Method IsProcessingInstruction:Bool()
		Return pi
	End
	
	Method IsProlog:Bool()
		Return prolog
	End
	
	Method IsCharacterData:Bool()
		Return cdata
	End
	
	' avoid using this method if you can, because you should try not to have "floating" elements
	Method AddChild:Void(child:XMLElement)
		If children.Contains(child) Return
		children.Add(child)
		child.parent = Self
	End
	
	Method HasAttribute:Bool(name:String)
		For Local i% = 0 Until attributes.Size
			Local att:XMLAttribute = attributes.Get(i)
			If att.name = name Then Return True
		Next
		Return False
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











