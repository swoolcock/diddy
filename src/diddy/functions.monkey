Import "native/diddy.${TARGET}.${LANG}"
Import mojo

Extern

	#If LANG="cpp" Then
		Function RealMillisecs:Int() = "diddy::systemMillisecs"
		Function FlushKeys:Void() = "diddy::flushKeys"
		Function HideMouse:Void() = "diddy::hideMouse"
		Function ShowMouse:Void() = "diddy::showMouse"
		Function GetUpdateRate:Int() = "diddy::getUpdateRate"
	#Else
		Function RealMillisecs:Int() = "diddy.systemMillisecs"
		Function FlushKeys:Void() = "diddy.flushKeys"
		Function HideMouse:Void() = "diddy.hideMouse"
		Function ShowMouse:Void() = "diddy.showMouse"
		Function GetUpdateRate:Int() = "diddy.getUpdateRate"
	#End
	
Public

Function ExitApp:Void()
	Error ""
End

Function RectsOverlap:Int(x0:Float, y0:Float, w0:Float, h0:Float, x2:Float, y2:Float, w2:Float, h2:Float)
	If x0 > (x2 + w2) Or (x0 + w0) < x2 Then Return False
	If y0 > (y2 + h2) Or (y0 + h0) < y2 Then Return False
	Return True
End

Function DrawRectOutline:Void(x:Int, y:Int, w:Int, h:Int)
	w -= 1
	h -= 1
	DrawLine(x,y,x+w,y)
	DrawLine(x+w,y,x+w,y+h)
	DrawLine(x+w,y+h,x,y+h)
	DrawLine(x,y+h,x,y)	
End

Function LoadBitmap:Image(path$, flags%=0)
	Local pointer:Image = LoadImage(path, 1, flags)

	If pointer = null
		Error "Error loading bitmap "+path
	End
	
   	Return pointer
End

Function LoadAnimBitmap:Image(path$, w%, h%, count%, tmpImage:Image)
	'tmpImage = loadBitmap(path) <-- This creates another image, decided to just copy the code here
	tmpImage = LoadImage(path)
	
	If tmpImage = null Then
		Error "Error loading bitmap "+path
	End

	local pointer:Image = tmpImage.GrabImage( 0, 0, w, h, count, Image.MidHandle)
	
   	Return pointer
End

Function LoadSoundSample:Sound(path$)
	local pointer:Sound = LoadSound(path)
	if pointer = null
		Error "Error loading sound "+path
	End
	Return pointer
End

Function FormatNumeric:String(value:Float)
	Local i:Int,s:String,ns:String,k:Int
	Local os:String
	s=String(value)
	os=s
	Local pos:Int=s.Length()
	If s.Find(".")>0 pos=s.Find(".") Else os=""
	For i=pos To 1 Step -1
		If k>2 ns+="." k=0
		k+=1
		ns=ns+Mid(s,i,1)
	Next
	s=""
	For i= ns.Length() To 1 Step -1
		s+=Mid(ns,i,1)
	Next
	If os<>"" s=s+","+os[pos+1..]
	Return s
End

Function Left$( str$,n:Int )
	If n>str.Length() n=str.Length()
	Return str[..n]
End

Function Right$( str$,n:Int )
	If n>str.Length() n=str.Length()
	Return str[str.Length()-n..]
End

Function LSet$( str$,n:Int,char:String=" " )
	Local rep:String
	For Local i:Int=1 To n
		rep=rep+char
	Next
	str=str+rep
	Return str[..n]
End

Function RSet$( str$,n:Int,char:String=" " )
	Local rep:String
	For Local i:Int=1 To n
		rep=rep+char
	Next
	str=rep+str
	Return str[str.Length()-n..]
End

Function Mid$( str$,pos:Int,size:Int=-1 )
	If pos>str.Length() Return ""
	pos-=1
	If( size<0 ) Return str[pos..]
	If pos<0 size=size+pos pos=0
	If pos+size>str.Length() size=str.Length()-pos
	Return str[pos..pos+size]
End

Function StripDir$( path$ )
	Local i:=path.FindLast( "/" )
	If i<>-1 Return path[i+1..]
	Return path
End

Function StripExt$( path$ )
	Local i:=path.FindLast( "." )
	If i<>-1 And path.Find( "/",i+1 )=-1 Return path[..i]
	Return path
End

Function StripAll$( path$ )
	Return StripDir( StripExt( path ) )
End

Function Round%(flot#)
	Return Floor(flot+0.5)
End

Function PointInSpot:Int(x1:Float, y1:Float, x2:Float, y2:Float, radius:Float)
	Local dx:Float = x2 - x1
	Local dy:Float = y2 - y1
	Return Sqrt(dx * dx + dy * dy) <= radius
End


