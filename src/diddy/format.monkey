Strict

Import functions

' Monkey converts primitives to strings when calling this function.
Function Format:String(fmt:String, arg1:String="", arg2:String="", arg3:String="", arg4:String="", arg5:String="", arg6:String="", arg7:String="", arg8:String="", arg9:String="", arg10:String="")
	Return FormatImpl(fmt, StringObject(arg1), StringObject(arg2), StringObject(arg3), StringObject(arg4), StringObject(arg5), StringObject(arg6), StringObject(arg7), StringObject(arg8), StringObject(arg9), StringObject(arg10))
End

Private

' This is a very simple implementation of sprintf.  I can't guarantee that it'll be bulletproof at this time, so use at your own risk!
' Note that due to Monkey's lack of varargs, Format accepts a maximum of 10 optional arguments.  Arguments are parsed up until the first Null.
' TODO: round floats rather than truncating them
Function FormatImpl:String(fmt:String, arg1:Object=Null, arg2:Object=Null, arg3:Object=Null, arg4:Object=Null, arg5:Object=Null, arg6:Object=Null, arg7:Object=Null, arg8:Object=Null, arg9:Object=Null, arg10:Object=Null)
	Local args:Object[] = [arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10]
	Local argcount:Int = 0
	For Local i:Int = 0 Until args.Length
		If args[i] = Null Or StringObject(args[i]) = "" Then
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
		Local chr:String = fmt[ptr..ptr+1]
		ptr+=1
		' if we're escaping with a backslash, just add the character
		If escapingBackslash Then
			rv += chr
			escapingBackslash = False
			
		' if we're not escaping but we received a backslash, just enable escaping
		ElseIf chr = "\" Then
			escapingBackslash = True

		' if we're not formatting and receive a %, enable formatting and escape percent
		ElseIf Not formatting And chr = "%" Then
			formatting = True
			escapingPercent = True
		
		' if we're escaping the percent and receive it, disable formatting
		ElseIf escapingPercent And chr = "%" Then
			rv += chr
			escapingPercent = False
			formatting = False
		
		' if we're not formatting, just add the character
		ElseIf Not formatting Then
			rv += chr
			
		' we're formatting
		Else
			' check that we have enough args
			If argnum >= argcount Then Error("Error: Didn't receive enough arguments in call to Format")
			Local fmtarg:String = chr
			Local foundPeriod:Bool = False, foundMinus:Bool = False, foundPadding:Bool = False
			Local formatLengthStr:String = "", formatLength:Int = 0, formatDPStr:String = "", formatDP:Int = 0
			Local formatType:String = ""
			' extract the rest of the format tag
			If Not IsValidFormat(chr) Then
				While ptr < fmt.Length()
					fmtarg += fmt[ptr..ptr+1]
					ptr+=1
					If IsValidFormat(fmtarg[fmtarg.Length-1..]) Then Exit
				End
			End
			' set format type
			formatType = fmtarg[fmtarg.Length-1..]
			
			' get the last character as the format type and die if it's wrong
			If formatType = "" Then
				' error!
				Error "Error parsing format string!"
			End
			
			Local fmtargptr:Int = 0
			' check for minus
			If fmtarg[0..1] = "-" Then
				foundMinus = True
				fmtargptr+=1
			' check for padding
			ElseIf fmtarg[fmtargptr..fmtargptr+1] = "0" Then
				foundPadding = True
				fmtargptr+=1
			End
			' check for digits up to a period or a character
			While fmtargptr < fmtarg.Length()
				If IsValidFormat(fmtargptr) Then
					Exit
				ElseIf fmtarg[fmtargptr] >= 48 And fmtarg[fmtargptr] <= 57 Then
					If Not foundPeriod Then
						formatLengthStr += fmtarg[fmtargptr..fmtargptr+1]
					Else
						formatDPStr += fmtarg[fmtargptr..fmtargptr+1]
					End
				ElseIf fmtarg[fmtargptr..fmtargptr+1] = "." Then
					foundPeriod = True
				End
				fmtargptr+=1
			End
			
			formatting = False
			If formatLengthStr <> "" Then formatLength = Int(formatLengthStr)
			If formatDPStr <> "" Then formatDP = Int(formatDPStr)
			
			If formatType = "d" Then
				Local ds:String = ArgToString(args[argnum])
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
				Local df:Float = ArgToFloat(args[argnum])
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
				If foundPadding Or foundMinus Then Error "Error parsing format string!"
				rv += String.FromChar(ArgToInt(args[argnum]))
			ElseIf formatType = "s" Or formatType = "S" Then
				If foundPadding Then Error "Error parsing format string!"
				Local ds:String = ArgToString(args[argnum])
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
				Local ds:String = DecToHex(ArgToInt(args[argnum])).ToLower()
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

Function IsValidFormat:Bool(chr:String)
	Return chr = "d" Or chr = "f" Or chr = "s" Or chr = "S" Or chr = "c" Or chr = "x" Or chr = "X"
End

Function ArgToFloat:Float(arg:Object)
	If FloatObject(arg) Then Return FloatObject(arg)
	If IntObject(arg) Then Return IntObject(arg)
	If StringObject(arg) Then Return Float(StringObject(arg).value)
	Return 0
End

Function ArgToInt:Int(arg:Object)
	If FloatObject(arg) Then Return FloatObject(arg)
	If IntObject(arg) Then Return IntObject(arg)
	If StringObject(arg) Then Return Int(StringObject(arg).value)
	Return 0
End

Function ArgToString:String(arg:Object)
	If FloatObject(arg) Then Return String(FloatObject(arg).value)
	If IntObject(arg) Then Return String(IntObject(arg).value)
	If StringObject(arg) Then Return StringObject(arg)
	Return ""
End
