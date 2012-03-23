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

Function resize_object_array:Object[]( arr:Object[],leng:Int )
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
	While( i<leng )
		arr[0][i]="";
		i:+1
	Wend
	Return arr;
EndFunction

' ***** End lang.bmx ******


