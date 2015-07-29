#Rem
Copyright (c) 2011 Steve Revill and Shane Woolcock
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
	The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#End
Strict

Private
Import brl.stream

Public
Interface IContentHandler
	Method StartDocument:Void()
	Method EndDocument:Void()
	Method StartElement:Void(name:String, attrs:StringMap<String>)
	Method EndElement:Void(name:String)
	Method Text:Void(text:String)
End

Class SAXException Extends Throwable
Private
	Field message:String
	Field line:Int
	Field column:Int
Public
	Method New(message:String, line:Int, column:Int)
		Self.message = message
		Self.line = line
		Self.column = column
	End
	
	Method Message:String() Property; Return message; End
	Method Line:Int() Property; Return line; End
	Method Column:Int() Property; Return column; End
	
	Method ToString:String()
		Return message + " near line " + line + ", column " + column
	End
End

' based very very loosely on QDParser by Steven R. Brandt
' http://www.javaworld.com/article/2077493/mobile-java/java-tip-128--create-a-quick-and-dirty-xml-parser.html
Class SAXParser
Private
	Function PopMode:Int(st:IntStack)
		If Not st.IsEmpty() Then
			Return st.Pop()
		Else
			Return MODE_PRE
		End
	End
	
	Const MODE_TEXT% = 1
	Const MODE_ENTITY% = 2
	Const MODE_OPEN_TAG% = 3
	Const MODE_CLOSE_TAG% = 4
	Const MODE_START_TAG% = 5
	Const MODE_ATTRIBUTE_LVALUE% = 6
	Const MODE_ATTRIBUTE_EQUAL% = 7
	Const MODE_ATTRIBUTE_RVALUE% = 8
	Const MODE_QUOTE% = 9
	Const MODE_IN_TAG% = 10
	Const MODE_SINGLE_TAG% = 11
	Const MODE_COMMENT% = 12
	Const MODE_DONE% = 13
	Const MODE_DOCTYPE% = 14
	Const MODE_PRE% = 15
	Const MODE_CDATA% = 16
	
	Function ParseImpl:Void(handler:IContentHandler, sourceStream:Stream, sourceString:String)
		' prepare
		Local depth:Int = 0, mode:Int = MODE_PRE, c:Int = 0, quotec:Int = "~q"[0]
		Local tagName:String = "", lvalue:String = "", rvalue:String = ""
		Local attrs:StringMap<String> = Null
		Local st := New IntStack
		Local line:Int=1, col:Int=0
		Local eol:Bool = False, usingStream:Bool = (sourceStream <> Null)
		Local position:Int = 0
		Local buffer:DataBuffer
		Local sb := New StringBuffer, etag := New StringBuffer
		
		If usingStream Then buffer = New DataBuffer(100)
		
		' start event
		handler.StartDocument()
		
		' loop through document
		Repeat
			' get the next character
			If usingStream Then
				' TODO: check end of stream
				sourceStream.ReadAll(buffer, position, 1)
				c = buffer.PeekInt(position)
			Else
				' die if we've reached the end
				If position >= sourceString.Length() Then Exit
				c = sourceString[position]
			End
			
			' increment to the next character
			position += 1
			
			' some magic to handle EOL types
			If c = "~n"[0] And eol Then
				eol = False
				Continue
			ElseIf eol Then
				eol = False
			ElseIf c = "~n"[0] Then
				line += 1
				col = 0
			ElseIf c = "~r"[0] Then
				eol = True
				c = "~n"[0]
				line += 1
				col = 0
			Else
				col += 1
			End
			
			' if we're done, end
			If mode = MODE_DONE Then
				handler.EndDocument()
				Return
			End
			
			' between tags, collecting text
			If mode = MODE_TEXT Then
				If c = "<"[0] Then
					st.Push(mode)
					mode = MODE_START_TAG
					If sb.charCount > 0 Then
						Local txt:String = sb.GetString().Trim()
						If txt Then handler.Text(txt)
					End
				ElseIf c = "&"[0] Then
					st.Push(mode)
					mode = MODE_ENTITY
					etag.charCount = 0
				ElseIf sb.charCount > 0 Or Not IsWhitespace(c) Then
					sb.Append(c)
				End
			' processing closing tag
			ElseIf mode = MODE_CLOSE_TAG Then
				If c = ">"[0] Then
					mode = PopMode(st)
					tagName = sb.GetString()
					depth -= 1
					If depth = 0 Then mode = MODE_DONE
					handler.EndElement(tagName)
				Else
					sb.Append(c)
				End
			' processing CDATA
			ElseIf mode = MODE_CDATA Then
				If c = ">"[0] And sb.EndsWith("]]") Then
					sb.charCount -= 2
					handler.Text(sb.GetString())
				Else
					sb.Append(c)
				End
			' processing comment
			ElseIf mode = MODE_COMMENT Then
				If c = ">"[0] And sb.EndsWith("--") Then
					sb.charCount = 0
					mode = PopMode(st)
				Else
					sb.Append(c)
				End
			' outside root
			ElseIf mode = MODE_PRE Then
				If c = "<"[0] Then
					mode = MODE_TEXT
					st.Push(mode)
					mode = MODE_START_TAG
				End
			' <?...?> or <!DOCTYPE...>
			ElseIf mode = MODE_DOCTYPE Then
				If c = ">"[0] Then
					mode = PopMode(st)
					If mode = MODE_TEXT Then mode = MODE_PRE
				End
			' found <
			ElseIf mode = MODE_START_TAG Then
				mode = PopMode(st)
				If c = "/"[0] Then
					st.Push(mode)
					mode = MODE_CLOSE_TAG
				ElseIf c = "?"[0] Then
					mode = MODE_DOCTYPE
				Else
					st.Push(mode)
					mode = MODE_OPEN_TAG
					tagName = ""
					attrs = Null
					sb.Append(c)
				End
			' entity
			ElseIf mode = MODE_ENTITY Then
				If c = ";"[0] Then
					mode = PopMode(st)
					Local cent:String = etag.GetString()
					If cent = "lt" Then
						sb.Append("<"[0])
					ElseIf cent = "gt" Then
						sb.Append(">"[0])
					ElseIf cent = "amp" Then
						sb.Append("&"[0])
					ElseIf cent = "quot" Then
						sb.Append("~q"[0])
					ElseIf cent = "apos" Then
						sb.Append("'"[0])
					ElseIf cent[0] = "#"[0] Then
						' TODO
					Else
						Exc("Unknown entity: &"+cent+";",line,col)
					End
				Else
					etag.Append(c)
				End
			' self closing tag
			ElseIf mode = MODE_SINGLE_TAG Then
				If tagName = "" And sb.charCount > 0 Then tagName = sb.GetString()
				If c <> ">"[0] Then Exc("Expected > for tag: <"+tagName+"/>",line,col)
				handler.StartElement(tagName, attrs)
				handler.EndElement(tagName)
				If depth = 0 Then
					handler.EndDocument()
					Return
				End
				attrs = Null
				tagName = ""
				mode = PopMode(st)
			' processing inside tag
			ElseIf mode = MODE_OPEN_TAG Then
				If c = ">"[0] Then
					If tagName = "" And sb.charCount > 0 Then tagName = sb.GetString()
					depth += 1
					handler.StartElement(tagName, attrs)
					tagName = ""
					attrs = Null
					mode = PopMode(st)
				ElseIf c = "/"[0] Then
					mode = MODE_SINGLE_TAG
				ElseIf c = "-"[0] And sb.Equals("!-") Then
					mode = MODE_COMMENT
				ElseIf c = "["[0] And sb.Equals("![CDATA") Then
					mode = MODE_CDATA
					sb.charCount = 0
				ElseIf c = "E"[0] And sb.Equals("!DOCTYP") Then
					sb.charCount = 0
					mode = MODE_DOCTYPE
				ElseIf IsWhitespace(c) Then
					tagName = sb.GetString()
					mode = MODE_IN_TAG
				Else
					sb.Append(c)
				End
			' right hand side of attribute value
			ElseIf mode = MODE_QUOTE Then
				If c = quotec Then
					rvalue = sb.GetString()
					If Not attrs Then attrs = New StringMap<String>
					attrs.Set(lvalue, rvalue)
					mode = MODE_IN_TAG
				ElseIf IsWhitespace(c) Then
					sb.Append(" "[0])
				ElseIf c = "&"[0] Then
					st.Push(mode)
					mode = MODE_ENTITY
					etag.charCount = 0
				Else
					sb.Append(c)
				End
			' rvalue
			ElseIf mode = MODE_ATTRIBUTE_RVALUE Then
				If c = "~q"[0] Or c = "'"[0] Then
					quotec = c
					mode = MODE_QUOTE
				ElseIf Not IsWhitespace(c) Then
					Exc("Error in attribute processing",line,col)
				End
			' lvalue
			ElseIf mode = MODE_ATTRIBUTE_LVALUE Then
				If IsWhitespace(c) Then
					lvalue = sb.GetString()
					mode = MODE_ATTRIBUTE_EQUAL
				ElseIf c = "="[0] Then
					lvalue = sb.GetString()
					mode = MODE_ATTRIBUTE_RVALUE
				Else
					sb.Append(c)
				End
			' equal
			ElseIf mode = MODE_ATTRIBUTE_EQUAL Then
				If c = "="[0] Then
					mode = MODE_ATTRIBUTE_RVALUE
				ElseIf Not IsWhitespace(c) Then
					Exc("Error in attribute processing",line,col)
				End
			' in tag
			ElseIf mode = MODE_IN_TAG Then
				If c = ">"[0] Then
					mode = PopMode(st)
					handler.StartElement(tagName, attrs)
					depth += 1
					tagName = ""
				ElseIf c = "/"[0] Then
					mode = MODE_SINGLE_TAG
				ElseIf Not IsWhitespace(c) Then
					mode = MODE_ATTRIBUTE_LVALUE
					sb.Append(c)
				End
			End
		Forever
		If mode = MODE_DONE Then
			handler.EndDocument()
		Else
			Exc("Missing end tag",line,col)
		End
	End
	
	Function Exc:Void(s:String, line:Int, col:Int)
		Throw New SAXException(s, line, col)
	End
	
	Function IsWhitespace:Bool(c:Int)
		Return c = " "[0] Or c = "~r"[0] Or c = "~n"[0] Or c = "~t"[0]
	End
	
Public
	Function Parse:Void(handler:IContentHandler, sourceStream:Stream)
		ParseImpl(handler, sourceStream, "")
	End
	
	Function Parse:Void(handler:IContentHandler, sourceString:String)
		ParseImpl(handler, Null, sourceString)
	End
End

Private

Class StringBuffer
	Field charArray:Int[]
	Field charCount:Int = 0
	
	Method Append:Void(c:Int)
		If charCount >= charArray.Length Then charArray = charArray.Resize(charCount*2)
		charArray[charCount] = c
		charCount += 1
	End
	
	Method GetString:String(reset:Bool=True)
		If charCount = 0 Then Return ""
		Local rv := String.FromChars(charArray[..charCount])
		If reset Then charCount = 0
		Return rv
	End
	
	Method EndsWith:Bool(str:String)
		Local len:Int = str.Length()
		If charCount = 0 Or len > charCount Then Return False
		For Local i:Int = 0 Until len
			If charArray[charCount-len+i] <> str[i] Then Return False
		Next
		Return True
	End
	
	Method Equals:Bool(str:String)
		If str.Length() <> charCount Then Return False
		For Local i:Int = 0 Until charCount
			If str[i] <> charArray[i] Then Return False
		Next
		Return True
	End
End
