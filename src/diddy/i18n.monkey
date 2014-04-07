#Rem
Copyright (c) 2011 Steve Revill and Shane Woolcock
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#End

#Rem
Header: Internationalization module.
Allows you to store all your game's strings in a single XML and give them different values for each
international language you wish to support.

The format for i18n.xml is as follows:
[code]
<?xml version="1.0" ?>
<i18n>
	<language name="french">
		<string>
			<key>Hello World!</key>
			<value>Bonjour, tout le monde!</value>
		</string>
	</language>
	<language name="japanese">
		<string>
			<key>Hello World!</key>
			<value>こんにちは、みなさん！</value>
		</string>
	</language>
</i18n>
[/code]
#End
Strict

Private
Import diddy.xml

Public
#Rem
Summary: This class stores all the strings for a single language.  It is instantiated automatically when [[LoadI18N]] is called.
#End
Class I18NLanguage
Private
	Global languages:StringMap<I18NLanguage> = New StringMap<I18NLanguage>
	Global current:I18NLanguage = Null

	Field name:String
	Field strings:StringMap<StringObject>
	
Public
#Rem
Summary: Returns the name of the language eg. "french"
#End
	Method Name:String() Property
		Return name
	End
	
#Rem
Summary: Creates a new instance of I18NLanguage and initialises the string map.
#End
	Method New()
		strings = New StringMap<StringObject>
	End
	
#Rem
Summary: Retrieves a string from the map, given the supplied key.  If the mapping does not exist, it simply returns the key.
#End
	Method GetString:String(str:String)
		If strings.Contains(str) Then Return strings.Get(str)
		Return str
	End
End

#Rem
Summary: Loads all the strings for the game from the given XML file (default is "i18n.xml").
#End
Function LoadI18N:Void(filename:String="i18n.xml")
	Local parser:XMLParser = New XMLParser
	Local doc:XMLDocument = parser.ParseFile(filename)
	Local languages:DiddyStack<XMLElement> = doc.Root.GetChildrenByName("language")
	For Local languageNode:XMLElement = EachIn languages
		Local l:I18NLanguage = New I18NLanguage
		l.name = languageNode.GetAttribute("name")
		Local stringNodes:DiddyStack<XMLElement> = languageNode.GetChildrenByName("string")
		For Local stringNode:XMLElement = EachIn stringNodes
			Local key:String, value:String
			For Local i:Int = 0 Until stringNode.Children.Count()
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

#Rem
Summary: Sets the specified language as the current one.
[code]
SetI18N("japanese")
[/code]
#End
Function SetI18N:Void(language:String)
	If I18NLanguage.languages.Contains(language) Then
		I18NLanguage.current = I18NLanguage.languages.Get(language)
	End
End

#Rem
Summary: Sets the current language to the passed instance of [[I18NLanguage]].
#End
Function SetI18N:Void(language:I18NLanguage)
	I18NLanguage.current = language
End

#Rem
Summary: Resets the current language so that calls to [[I18N]] will simply return the passed string.
#End
Function ClearI18N:Void()
	SetI18N(Null)
End

#Rem
Summary: Attempts to retrieve the mapped string for the given key, for the current language.
If the mapping does not exist, it simply returns the passed string.
[code]
Print I18N("Hello!") ' if no current language, prints "Hello!"
SetI18N("french"); Print I18N("Hello!") ' if the correct mapping exists for French, prints "Bonjour!"
[/code]
#End
Function I18N:String(str:String)
	If I18NLanguage.current <> Null Then Return I18NLanguage.current.GetString(str)
	Return str
End
