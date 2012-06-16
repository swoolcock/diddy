' ***** Start lang.bmx ******
Global D2R:Float=0.017453292519943295;
Global R2D:Float=57.29577951308232;

Function pushErr()
	_errStack.AddLast( _errInfo );
EndFunction

Function popErr()
	_errInfo=String(_errStack.ValueAtIndex(_errStack.Count()-1))
	_errStack.RemoveLast();
EndFunction

Function error( err:String )
	If err = "" Then
		End
	Else
		RuntimeError err;
	EndIf
EndFunction

Function debugLog:Int( str:String )
	Print(str)
	Return 0
EndFunction

Function debugStop:Int()
	error("STOP")
	Return 0
EndFunction

Function resize_string_array:String[]( arr:String[], leng:Int )
	Local i:Int = arr.length;
	arr = arr[0..leng];
	If( leng<=i ) Return arr;
	While( i<leng )
		arr[i]="";
		i:+1
	Wend
	Return arr;
EndFunction

Function resize_float_array:Float[]( arr:Float[], leng:Int )
	Local i:Int = arr.length;
	arr = arr[0..leng];
	If( leng<=i ) Return arr;
	While( i<leng )
		arr[i]=0;
		i:+1
	Wend
	Return arr;
EndFunction

Function resize_int_array:Int[]( arr:Int[], leng:Int )
	Local i:Int = arr.length;
	arr = arr[0..leng];
	If( leng<=i ) Return arr;
	While( i<leng )
		arr[i]=0;
		i:+1
	Wend
	Return arr;
EndFunction

Function resize_object_array:Object[]( arr:_Object[],leng:Int )
	Local i:Int=arr.length;
	arr=arr[0..leng];
	If( leng<=i ) Return arr;
	While( i<leng )
		arr[i]=Null;
		i:+1
	Wend
	Return arr;
EndFunction

Function resize_array_array_Int:Int[][]( arr:Int[][], leng:Int )
	Local i:Int = arr.length;
	arr = arr[..leng];
	If( leng<=i ) Return arr;

	For Local l:Int = 0 Until Len(arr)
		arr[l] = arr[l][..leng]
	Next

	While( i<leng )
		arr[0][i]=0;
		i:+1
	Wend
	Return arr;
EndFunction

Function resize_array_array_Float:Float[][]( arr:Float[][], leng:Int )
	Local i:Int = arr.length;
	arr = arr[..leng];
	If( leng<=i ) Return arr;

	For Local l:Int = 0 Until Len(arr)
		arr[l] = arr[l][..leng]
	Next

	While( i<leng )
		arr[0][i]=0;
		i:+1
	Wend
	Return arr;
EndFunction

Function resize_array_array_String:String[][]( arr:String[][], leng:Int )
	Local i:Int = arr.length;
	arr = arr[..leng];
	If( leng<=i ) Return arr;

	For Local l:Int = 0 Until Len(arr)
		arr[l] = arr[l][..leng]
	Next
	
	While( i<leng )
		arr[0][i]="";
		i:+1
	Wend
	Return arr;
EndFunction

Function slice_string:String(arr:String, from:Int, term:Int = 0)
	Local le:Int = arr.Length

	If from < 0
		from :+ le
		If from <0 Then from = 0
	Else If from > le
		from = le
	EndIf
	If term <= 0
		term :+ le
	Else If term > le
		term = le
	EndIf

	If term <= from Return arr
	Return Mid(arr, from + 1,  term - from)

EndFunction

' ***** End lang.bmx ******


