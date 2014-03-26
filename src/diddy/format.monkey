#Rem
Copyright (c) 2011 Steve Revill and Shane Woolcock
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#End

Strict

Private
Import diddy.functions
Import diddy.exception

Public

' This is a very simple implementation of sprintf.  I can't guarantee that it'll be bulletproof at this time, so use at your own risk!
' Note that due to Monkey's lack of varargs, Format accepts a maximum of 10 optional arguments.  Arguments are parsed up until the first Null.
' TODO: round floats rather than truncating them
Function Format:String(fmt:String, arg1:String="", arg2:String="", arg3:String="", arg4:String="", arg5:String="", arg6:String="", arg7:String="", arg8:String="", arg9:String="", arg10:String="")
	Local args:String[] = [arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10]
	Local argcount:Int = 0
	For Local i:Int = 0 Until args.Length
		If args[i] = "" Then
			argcount = i
			Exit
		End
	Next
	Local rv:String = ""
	Local formatting:Bool = False
	Local escapingBackslash:Bool = False
	Local escapingPercent:Bool = False
	Local ptr:Int = 0
	Local argnum:Int = 0
	While ptr < fmt.Length()
		Local chr:Int = fmt[ptr]
		ptr+=1
		' if we're escaping with a backslash, just add the character
		If escapingBackslash Then
			rv += String.FromChar(chr)
			escapingBackslash = False
			
		' if we're not escaping but we received a backslash, just enable escaping
		ElseIf chr = "\"[0] Then
			escapingBackslash = True

		' if we're not formatting and receive a %, enable formatting and escape percent
		ElseIf Not formatting And chr = "%"[0] Then
			formatting = True
			escapingPercent = True
		
		' if we're escaping the percent and receive it, disable formatting
		ElseIf escapingPercent And chr = "%"[0] Then
			rv += String.FromChar(chr)
			escapingPercent = False
			formatting = False
		
		' if we're not formatting, just add the character
		ElseIf Not formatting Then
			rv += String.FromChar(chr)
			
		' we're formatting
		Else
			' check that we have enough args
			If argnum >= argcount Then Throw New FormatException("Error: Didn't receive enough arguments in call to Format")
			Local fmtarg:String = String.FromChar(chr)
			Local foundPeriod:Bool = False, foundMinus:Bool = False, foundPadding:Bool = False
			Local formatLengthStr:String = "", formatLength:Int = 0, formatDPStr:String = "", formatDP:Int = 0
			Local formatType:String = ""
			' extract the rest of the format tag
			If Not IsValidFormat(String.FromChar(chr)) Then
				While ptr < fmt.Length()
					fmtarg += fmt[ptr..ptr+1]
					ptr+=1
					If IsValidFormat(fmtarg[fmtarg.Length-1..]) Then Exit
				End
			End
			' set format type
			formatType = fmtarg[fmtarg.Length-1..]
			
			' get the last character as the format type and die if it's wrong
			If formatType = "" Then Throw New FormatException("Error parsing format string!")
			
			Local fmtargptr:Int = 0
			' check for minus
			If fmtarg[0] = "-"[0] Then
				foundMinus = True
				fmtargptr+=1
			' check for padding
			ElseIf fmtarg[fmtargptr] = "0"[0] Then
				foundPadding = True
				fmtargptr+=1
			End
			' check for digits up to a period or a character
			While fmtargptr < fmtarg.Length()
				If IsValidFormat(fmtargptr) Then
					Exit
				ElseIf fmtarg[fmtargptr] >= "0"[0] And fmtarg[fmtargptr] <= "9"[0] Then
					If Not foundPeriod Then
						formatLengthStr += fmtarg[fmtargptr..fmtargptr+1]
					Else
						formatDPStr += fmtarg[fmtargptr..fmtargptr+1]
					End
				ElseIf fmtarg[fmtargptr] = "."[0] Then
					foundPeriod = True
				End
				fmtargptr+=1
			End
			
			formatting = False
			If formatLengthStr <> "" Then formatLength = Int(formatLengthStr)
			If formatDPStr <> "" Then formatDP = Int(formatDPStr)
			
			If formatType = "d" Then
				Local ds:String = Int(args[argnum])
				While ds.Length() < formatLength
					If foundPadding Then
						ds = "0"+ds
					ElseIf foundMinus Then
						ds += " "
					Else
						ds = " "+ds
					End
				End
				rv += ds
			ElseIf formatType = "f" Then
				Local df:Float = Float(args[argnum])
				' TODO: round float instead of truncating
				Local ds:String = df
				Local dp:Int = ds.Find(".")
				If dp < 0 Then dp = ds.Length()
				Local whole:String = ds[..dp]
				Local part:String = "0"
				If dp < ds.Length()-1 Then part = ds[dp+1..]
				If part.Length() > formatDP Then part = part[..formatDP]
				While part.Length() < formatDP
					part+="0"
				End
				ds = whole
				If part.Length()>0 Then ds+="."+part
				While ds.Length() < formatLength
					If foundPadding Then
						ds = "0"+ds
					ElseIf foundMinus Then
						ds += " "
					Else
						ds = " "+ds
					End
				End
				rv += ds
			ElseIf formatType = "c" Then
				If foundPadding Or foundMinus Then Throw New FormatException("Error parsing format string!")
				rv += String.FromChar(Int(args[argnum]))
			ElseIf formatType = "s" Or formatType = "S" Then
				If foundPadding Then Throw New FormatException("Error parsing format string!")
				Local ds:String = args[argnum]
				If formatType = "S" Then ds = ds.ToUpper()
				While ds.Length() < formatLength
					If foundMinus Then
						ds += " "
					Else
						ds = " "+ds
					End
				End
				rv += ds
			ElseIf formatType = "x" Or formatType = "X" Then
				Local ds:String = DecToHex(Int(args[argnum])).ToLower()
				If formatType = "X" Then ds = ds.ToUpper()
				While ds.Length() < formatLength
					If foundPadding Then
						ds = "0"+ds
					ElseIf foundMinus Then
						ds += " "
					Else
						ds = " "+ds
					End
				End
				rv += ds
			End
			argnum+=1
		End
	End
	Return rv
End

Private

Function IsValidFormat:Bool(chr:String)
	Return chr = "d" Or chr = "f" Or chr = "s" Or chr = "S" Or chr = "c" Or chr = "x" Or chr = "X"
End
