#Rem
Copyright (c) 2011 Steve Revill and Shane Woolcock
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#End
Strict

#Rem
Header: Provides the Singleton utility class.
#End

Public

#Rem
Summary: Simple wrapper for the singleton pattern to save the developer from creating their own instance/getter global/function.
[code]
Singleton<MyClass>.Instance()
[/code]
This will return the singleton instance of MyClass, creating it if necessary.  This uses the default New() constructor.
#End
Class Singleton<T> Final
Private
	Global instance:T
	
Public
	Method New()
		Error("Singleton utility class cannot be instantiated.")
	End
	
	Function Instance:T()
		If Not instance Then instance = New T
		Return instance
	End
End
