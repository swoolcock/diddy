Import xml

Class I18NLanguage
Private
	Global languages:StringMap<I18NLanguage> = New StringMap<I18NLanguage>
	Global current:I18NLanguage = Null

	Field name:String
	Field strings:StringMap<StringObject>
	
Public
	Method Name:String() Property
		Return name
	End
	
	Method New()
		strings = New StringMap<StringObject>
	End
	
	Method GetString:String(str:String)
		If strings.Contains(str) Then Return strings.Get(str)
		Return str
	End
End

Function LoadI18N:Void(filename:String="i18n.xml")
	Local parser:XMLParser = New XMLParser
	Local doc:XMLDocument = parser.ParseFile(filename)
	Local languages:ArrayList<XMLElement> = doc.Root.GetChildrenByName("language")
	For Local languageNode:XMLElement = EachIn languages
		Local l:I18NLanguage = New I18NLanguage
		l.name = languageNode.GetAttribute("name")
		Local stringNodes:ArrayList<XMLElement> = languageNode.GetChildrenByName("string")
		For Local stringNode:XMLElement = EachIn stringNodes
			Local key:String, value:String
			For Local i:Int = 0 Until stringNode.Children.Size
				Local child:XMLElement = stringNode.Children.Get(i)
				If child.Name = "key" Then
					key = child.Value
				ElseIf child.Name = "value" Then
					value = child.Value
				End
			Next
			l.strings.Set(key, value)
		Next
		I18NLanguage.languages.Set(l.name, l)
	Next
	doc.Root.Dispose()
End

Function SetI18N:Void(language:String)
	If I18NLanguage.languages.Contains(language) Then
		I18NLanguage.current = I18NLanguage.languages.Get(language)
	End
End

Function SetI18N:Void(language:I18NLanguage)
	I18NLanguage.current = language
End

Function ClearI18N:Void()
	SetI18N(Null)
End

Function I18N:String(str:String)
	If I18NLanguage.current <> Null Then Return I18NLanguage.current.GetString(str)
	Return str
End
