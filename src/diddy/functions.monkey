#if HOST="macos" And TARGET="glfw"
	Import "native/diddy.${TARGET}.mac.${LANG}"
#else
	Import "native/diddy.${TARGET}.${LANG}"
#end
Import mojo
Import framework
Import assert
Import vector2d

Extern

	#If LANG="cpp" Then
		Function RealMillisecs:Int() = "diddy::systemMillisecs"
		Function FlushKeys:Void() = "diddy::flushKeys"
		Function HideMouse:Void() = "diddy::hideMouse"
		Function ShowMouse:Void() = "diddy::showMouse"
		Function GetUpdateRate:Int() = "diddy::getUpdateRate"
		Function SetMouse:Void(x:Int, y:Int) = "diddy::setMouse"
		Function ShowKeyboard:Void() = "diddy::showKeyboard"
		Function LaunchNativeBrowser:Void(address:String, windowName:String) = "diddy::launchBrowser"
		Function LaunchEmail:Void(email:String, subject:String, text:String) = "diddy::launchEmail"
		Function SetNativeGraphicsSize:Void(w:Int, h:Int) = "diddy::setGraphics"
		Function StartVibrate:Void(millisec:Int) = "diddy::startVibrate"
		Function StopVibrate:Void() = "diddy::stopVibrate"
		Function GetDayOfMonth:Int()="diddy::getDayOfMonth"
		Function GetDayOfWeek:Int()="diddy::getDayOfWeek"
		Function GetMonth:Int()="diddy::getMonth"
		Function GetYear:Int()="diddy::getYear"
		Function GetHours:Int()="diddy::getHours"
		Function GetMinutes:Int()="diddy::getMinutes"
		Function GetSeconds:Int()="diddy::getSeconds"
		Function GetMilliSeconds:Int()="diddy::getMilliSeconds"
		Function StartGps:Void()="diddy::startGps"
		Function GetLatitiude:String()="diddy::getLatitiude"
		Function GetLongitude:String()="diddy::getLongitude"
		Function ShowAlertDialog:Void(title:String, message:String) = "diddy::showAlertDialog"
		Function GetInputString:String()="diddy::getInputString"
		Function GetColorPixel:Int(x:Int, y:Int)="diddy::getPixel"
		Function MouseZInit:Void()="diddy::mouseZInit"
		Function MouseZ:Float()="diddy::mouseZ"
	#Else
		Function RealMillisecs:Int() = "diddy.systemMillisecs"
		Function FlushKeys:Void() = "diddy.flushKeys"
		Function HideMouse:Void() = "diddy.hideMouse"
		Function ShowMouse:Void() = "diddy.showMouse"
		Function GetUpdateRate:Int() = "diddy.getUpdateRate"
		Function SetMouse:Void(x:Int, y:Int) = "diddy.setMouse"
		Function ShowKeyboard:Void() = "diddy.showKeyboard"
		Function LaunchNativeBrowser:Void(address:String, windowName:String) = "diddy.launchBrowser"
		Function LaunchEmail:Void(email:String, subject:String, text:String) = "diddy.launchEmail"
		Function SetNativeGraphicsSize:Void(w:Int, h:Int) = "diddy.setGraphics"
		Function StartVibrate:Void(millisec:Int) = "diddy.startVibrate"
		Function StopVibrate:Void() = "diddy.stopVibrate"
		Function GetDayOfMonth:Int()="diddy.getDayOfMonth"
		Function GetDayOfWeek:Int()="diddy.getDayOfWeek"
		Function GetMonth:Int()="diddy.getMonth"
		Function GetYear:Int()="diddy.getYear"
		Function GetHours:Int()="diddy.getHours"
		Function GetMinutes:Int()="diddy.getMinutes"
		Function GetSeconds:Int()="diddy.getSeconds"
		Function GetMilliSeconds:Int()="diddy.getMilliSeconds"
		Function StartGps:Void()="diddy.startGps"
		Function GetLatitiude:String()="diddy.getLatitiude"
		Function GetLongitude:String()="diddy.getLongitude"
		Function ShowAlertDialog:Void(title:String, message:String) = "diddy.showAlertDialog"
		Function GetInputString:String()="diddy.getInputString"
		Function GetColorPixel:Int(x:Int, y:Int)="diddy.getPixel"
		Function MouseZInit:Void()="diddy.mouseZInit"
		Function MouseZ:Float()="diddy.mouseZ"
	#End
	
	#If TARGET="html5" Then
		Function GetBrowserName:String()="diddy.getBrowserName"
		Function GetBrowserVersion:String()="diddy.getBrowserVersion"
		Function GetBrowserOS:String()="diddy.getBrowserOS"
		Function GetCurrentURL:String()="function (){return document.URL;}"
	#ElseIf TARGET="flash" Then
		Function GetCurrentURL:String()="diddy.getCurrentURL"
	#ElseIf LANG="java" Then
		Function BuildString:String(arr:Int[], offset:Int, length:Int) = "diddy.buildString"
	#End
Public

#If TARGET<>"html5" Then
	Function GetBrowserName:String()
		Return ""
	End
	Function GetBrowserVersion:String()
		Return ""
	End
	Function GetBrowserOS:String()
		Return ""
	End
	#If TARGET<>"flash" Then
		Function GetCurrentURL:String()
			Return ""
		End
	#End
#End

#If LANG <> "java" Then
	Function BuildString:String(arr:Int[], offset:Int, length:Int)
		If offset<0 Or length<=0 Or offset+length > arr.Length Then Return ""
		Local rv:String = String.FromChar(arr[offset])
		For Local i:Int = offset+1 Until offset+length
			rv += String.FromChar(arr[i])
		Next
		Return rv
	End
#End

Function LaunchBrowser(address:String, openNewWindow:Bool = True)
	Local windowName:String = "_self"
	If openNewWindow
		windowName = "_blank"
	End
	LaunchNativeBrowser(address, windowName)
End

Function SetGraphics:Void(w:Int, h:Int)
	SetNativeGraphicsSize(w, h)
	DEVICE_WIDTH = w
	DEVICE_HEIGHT = h
	SCREEN_HEIGHT = h
	SCREEN_WIDTH = w
	SCREEN_WIDTH2 = SCREEN_WIDTH / 2
	SCREEN_HEIGHT2 = SCREEN_HEIGHT / 2
End

Function GetPixel:Int[](x:Int, y:Int)
	Local colorArr:Int[4]
	Local color:Int = GetColorPixel(x, y)
	'Print color
	colorArr[0] = (color Shr 16) & $ff
	colorArr[1] = (color Shr 8) & $ff
	colorArr[2] = color & $ff
	colorArr[3] = (color Shr 24) & $ff

	Return colorArr
End

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
	DrawLine(x, y, x + w, y)
	DrawLine(x + w, y, x + w, y + h)
	DrawLine(x + w, y + h, x, y + h)
	DrawLine(x, y + h, x, y)
End


Function LoadBitmap:Image(path$, flags%=0)
	Local pointer:Image = LoadImage(path, 1, flags)

	AssertNotNull(pointer, "Error loading bitmap "+path)
	
   	Return pointer
End

Function LoadAnimBitmap:Image(path$, w%, h%, count%, tmpImage:Image)
	'tmpImage = loadBitmap(path) <-- This creates another image, decided to just copy the code here
	tmpImage = LoadImage(path)
	
	AssertNotNull(tmpImage, "Error loading bitmap "+path)

	Local pointer:Image = tmpImage.GrabImage( 0, 0, w, h, count, Image.MidHandle)
	
   	Return pointer
End

Function LoadSoundSample:Sound(path$)
	Local pointer:Sound = LoadSound(path)
	AssertNotNull(pointer, "Error loading sound "+path)
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

'summary: returns an angle between two points
Function CalcAngle:Float(x1:Float, y1:Float, x2:Float, y2:Float)
	Local dx:Float = x2 - x1
	Local dy:Float = y2 - y1
	Return (ATan2(dy, dx) + 360) Mod 360
End

'summary: Calculate distance between two points - overload using x,y
Function CalcDistance:Float(x1:Float, y1:Float, x2:Float, y2:Float)
	Local dx:Float = x2 - x1
	Local dy:Float = y2 - y1
	Return Sqrt(dx * dx + dy * dy)
End

Function PointInSpot:Int(x1:Float, y1:Float, x2:Float, y2:Float, radius:Float)
	Local dx:Float = x2 - x1
	Local dy:Float = y2 - y1
	Return dx * dx + dy * dy <= radius * radius
End

Function AnyInputPressed:Bool()
	For Local i:Int = 0 To 511
		If KeyHit(i) Then Return True
	Next
	Return False
End

Function FormatNumber:String(number:Float, decimal:Int=4, comma:Int=0, padleft:Int=0 )
	Assert(decimal > -1 And comma > -1 And padleft > -1, "Negative numbers not allowed in FormatNumber()")

	Local str:String = number
	Local dl:Int = str.Find(".")
	If decimal = 0 Then decimal = -1
	str = str[..dl+decimal+1]
	
	If comma
		While dl>comma
			str = str[..dl-comma] + "," + str[dl-comma..]
			dl -= comma
		Wend
	End
	
	If padleft
		Local paddedLength:Int = padleft+decimal+1
		If paddedLength < str.Length Then str = "Error"
		str = RSet(str,paddedLength)
	End
	Return str
End

Function IsWhitespace:Bool(str:String)
	Return str = "~t" Or str = "~n" Or str = "~r" Or str = " "
End

Function IsWhitespace:Bool(val:Int)
	Return val = ASC_TAB Or val = ASC_LF Or val = ASC_CR Or val = ASC_SPACE
End

' TODO: allow encoding of Int[]
' TODO: enabling lineWrap will wrap the string every lineWrapWidth characters (defaults to 80)
' enabling padOutput will pad the ending of the output with equals characters (=) to next 4-byte boundary
Function EncodeBase64:String(src:String, padOutput:Bool=False, lineWrap:Bool=False, lineWrapWidth:Int=80)
	Local rv:String = ""
	Local s1:Int, s2:Int, s3:Int, a:Int, b:Int, c:Int, d:Int, i:Int
	If src.Length = 0 Then Return ""
	Repeat
		s1 = src[i]
		If i+1 < src.Length Then s2 = src[i+1] Else s2 = 0
		If i+2 < src.Length Then s3 = src[i+2] Else s3 = 0
		a = s1 Shr 2
		b = ((s1 & 3) Shl 4) | (s2 Shr 4)
		c = ((s2 & 15) Shl 2) | (s3 Shr 6)
		d = s3 & 63
		If i+1 >= src.Length Then c = 64
		If i+2 >= src.Length Then d = 64
		rv += BASE64_CHARS[a..a+1] + BASE64_CHARS[b..b+1]
		If c < 64 Or padOutput Then rv += BASE64_CHARS[c..c+1]
		If d < 64 Or padOutput Then rv += BASE64_CHARS[d..d+1]
		i += 3
	Until i >= src.Length
	Return rv
End

' TODO: convert this to use BASE64_ARRAY
' I'll do this once Monkey has a decent string builder class.
Function DecodeBase64:String(src:String)
	Local rv:String = "", src2:String = ""
	Local s1:Int, s2:Int, s3:Int, a:Int, b:Int, c:Int, d:Int, i:Int
	' remove any non-base64 characters
	For i = 0 Until src.Length
		If BASE64_CHARS.Find(src[i..i+1]) >= 0 Then src2 += src[i..i+1]
	Next
	If src2.Length = 0 Then Return ""
	i = 0
	Repeat
		a = BASE64_CHARS.Find(src2[i..i+1])
		If i+1 > src2.Length Then Exit ' This shouldn't happen with base64, so something's wrong!
		b = BASE64_CHARS.Find(src2[i+1..i+2])
		If i+2 < src2.Length Then c = BASE64_CHARS.Find(src2[i+2..i+3]) Else c = 64
		If i+3 < src2.Length Then d = BASE64_CHARS.Find(src2[i+3..i+4]) Else d = 64
		s1 = (a Shl 2) | (b Shr 4)
		s2 = ((b & 15) Shl 4) | (c Shr 2)
		s3 = ((c & 3) Shl 6) | d
		rv += String.FromChar(s1)
		If c <> 64 Then rv += String.FromChar(s2)
		If d <> 64 Then rv += String.FromChar(s3)
		i += 4
	Until i >= src2.Length
	Return rv
End

Function DecodeBase64Bytes:Int[](src:String)
	InitBase64()
	Local a:Int, b:Int, c:Int, d:Int, i:Int, j:Int
	Local src2:Int[] = New Int[src.Length]
	Local padding:Int = 0
	
	' find out how many base64 characters
	Local srclen:Int = 0
	For i = 0 Until src.Length
		If BASE64_ARRAY[src[i]] >= 0 Then
			src2[srclen] = src[i]
			srclen += 1
			' check if it's a padding character and increment the count
			If BASE64_ARRAY[src[i]] = 64 Then padding += 1
		End
	Next
	
	' die if there are no base64 chars
	If srclen = 0 Then Return []
	
	' get the target length and create the array
	Local len:Int = 3*(srclen/4)
	If srclen Mod 4 = 0 Then
		len -= padding
	Elseif padding = 0 Then
		If srclen Mod 4 >= 2 Then len += 1
		If srclen Mod 4 = 3 Then len += 1
	End
	Local rv:Int[] = New Int[len]
	
	i = 0
	j = 0
	Repeat
		a = BASE64_ARRAY[src2[i]]
		If i+1 > srclen Then Exit ' This shouldn't happen with base64, so something's wrong!
		b = BASE64_ARRAY[src2[i+1]]
		If i+2 < srclen Then c = BASE64_ARRAY[src2[i+2]] Else c = 64
		If i+3 < srclen Then d = BASE64_ARRAY[src2[i+3]] Else d = 64
		rv[j] = (a Shl 2) | (b Shr 4)
		If j+1 < len Then rv[j+1] = ((b & 15) Shl 4) | (c Shr 2)
		If j+2 < len Then rv[j+2] = ((c & 3) Shl 6) | d
		i += 4
		j += 3
	Until i >= srclen
	Return rv
End

Function InitBase64:Void()
	If BASE64_ARRAY.Length = 0 Then
		BASE64_ARRAY = New Int[256]
		Local i% = 0
		For i = 0 Until BASE64_ARRAY.Length
			BASE64_ARRAY[i] = -1
		Next
		For i = 0 Until BASE64_CHARS.Length
			BASE64_ARRAY[BASE64_CHARS[i]] = i
		Next
	End
End

Function Interpolate:Float(type:Int, startValue:Float, endValue:Float, alpha:Float)
	Local range:Float = endValue-startValue
	Local rv:Float = 0
	Select type
		Case INTERPOLATION_LINEAR
			rv = startValue + range*alpha
			
		Case INTERPOLATION_INVERSE_LINEAR
			rv = startValue + range - range*alpha
			
		Case INTERPOLATION_HALF_SINE
			rv = startValue + range * Sinr(alpha*PI)
			
		Case INTERPOLATION_HALF_COSINE
			rv = startValue + range * Cosr(alpha*PI)
	End
	' clip to start/end
	If startValue < endValue And rv < startValue Or startValue > endValue And rv > startValue Then
		rv = startValue
	Elseif startValue < endValue And rv > endValue Or startValue > endValue And rv < endValue Then
		rv = endValue
	End
	Return rv
End

' arghhhh monkey needs enums!!!
Function InterpolationFromString:Int(interp:String)
	If interp = "" Or interp = "none" Then Return INTERPOLATION_NONE
	If interp = "linear" Then Return INTERPOLATION_LINEAR
	If interp = "inverselinear" Then Return INTERPOLATION_INVERSE_LINEAR
	If interp = "halfsine" Then Return INTERPOLATION_HALF_SINE
	If interp = "halfcosine" Then Return INTERPOLATION_HALF_COSINE
End

' colour conversions (hsl is range 0-1, return is RGB as a single int)
' Monkey conversion of http://www.geekymonkey.com/Programming/CSharp/RGB2HSL_HSL2RGB.htm
Function HSLtoRGB:Int(hue:Float, saturation:Float, luminance:Float, rgbArray:Int[] = [])
	Local r:Float = luminance, g:Float = luminance, b:Float = luminance
	Local v:Float = 0
	If luminance <= 0.5 Then
		v = luminance * (1.0 + saturation)
	Else
		v = luminance + saturation - luminance * saturation
	End
	If v > 0 Then
		Local m:Float = luminance + luminance - v
		Local sv:Float = (v - m) / v
		hue *= 6
		Local sextant:Int = Int(hue)
		Local fract:Float = hue - sextant
		Local vsf:Float = v * sv * fract
		Local mid1:Float = m + vsf
		Local mid2:Float = v - vsf
		
		Select sextant
			Case 0
				r = v
				g = mid1
				b = m

			Case 1
				r = mid2
				g = v
				b = m

			Case 2
				r = m
				g = v
				b = mid1

			Case 3
				r = m
				g = mid2
				b = v

			Case 4
				r = mid1
				g = m
				b = v
			
			Case 5
				r = v
				g = m
				b = mid2
		End
	End
	If rgbArray.Length = 3 Then
		rgbArray[0] = Int(r*255)
		rgbArray[1] = Int(g*255)
		rgbArray[2] = Int(b*255)
	End
	Return $ff000000 | (Int(r*255) Shl 16) | (Int(g*255) Shl 8) | (Int(b*255) Shl 0)
End

' colour conversions (rgb is 0-255, return is a float array, reusing the hslvals array if it was big enough)
' Monkey conversion of http://www.geekymonkey.com/Programming/CSharp/RGB2HSL_HSL2RGB.htm
Function RGBtoHSL:Float[](red:Int, green:Int, blue:Int, hslvals:Float[] = [])
	If hslvals.Length <> 3 Then hslvals = New Float[3]
	Local r:Float = red/255.0, g:Float = green/255.0, b:Float = blue/255.0
	hslvals[0] = 0
	hslvals[1] = 0
	hslvals[2] = 0
	
	' calculate luminance
	Local v:Float = Max(Max(r,g),b)
	Local m:Float = Min(Min(r,g),b)
	hslvals[2] = (m + v) / 2.0
	' die if it's black
	If hslvals[2] <= 0 Then Return hslvals
	
	' precalculate saturation
	Local vm:Float = v - m
	hslvals[1] = vm
	' die if it's grey
	If hslvals[1] <= 0 Then Return hslvals
	
	' finish saturation
	If hslvals[2] <= 0.5 Then
		hslvals[1] /= v + m
	Else
		hslvals[1] /= 2 - v - m
	End
	
	Local r2:Float = (v - r) / vm
	Local g2:Float = (v - g) / vm
	Local b2:Float = (v - b) / vm
	If r = v Then
		If g = m Then hslvals[0] = 5 + b2 Else hslvals[0] = 1 - g2
	Elseif g = v Then
		If b = m Then hslvals[0] = 1 + r2 Else hslvals[0] = 3 - b2
	Else
		If r = m Then hslvals[0] = 3 + g2 Else hslvals[0] = 5 - r2
	End
	hslvals[0] /= 6.0
	
	Return hslvals
End

Function DecToHex:String(dec:Int)
	Local rv:String = ""
	If dec <= 0 Then Return "0"
	While dec > 0
		If dec Mod 16 < 10 Then
			rv += dec Mod 16
		Else
			rv += String.FromChar(ASC_LOWER_A+(dec Mod 16)-10)
		End
		dec = dec / 16
	End
	Return rv
End

Function HexToDec:Int(hx:String)
	Local rv:Int = 0
	Local lookup:String = "0123456789abcdef"
	hx = hx.ToLower()
	For Local i:Int = 0 Until hx.Length()
		rv *= 16
		Local idx:Int = lookup.Find(hx[i..i+1])
		If idx < 0 Then Error("Error parsing Hex string!")
		rv += idx
	Next
	Return rv
End

Function DrawLineThick(x1:Int, y1:Int, x2:Int, y2:Int, thinkness:Int = 2)
	Local steep:Bool = Abs(y2 - y1) > Abs(x2 - x1)
	Local swapped:Bool = False
	
	If steep
		Local tmp:Int = x1
		x1 = y1
		y1 = tmp
	
		tmp = x2
		x2 = y2
		y2 = tmp
	End
	
	If x1 > x2
		Local t:Float = x1
		x1 = x2
		x2 = t
		t = y1
		y1 = y2
		y2 = t
		swapped = True
	End
	
	Local deltax:Float = x2 - x1
	Local deltay:Float = Abs(y2 - y1)
	Local error:Float = deltax / 2
	Local ystep:Float
	Local y:Float = y1
	
	If y1 < y2 Then
		ystep = 1
	Else
		ystep = -1
	End
	Local offset:Int = thinkness / 2
	For Local x:Int = x1 Until x2
		If steep
			DrawRect(y - offset, x - offset, thinkness, thinkness)
		Else
			DrawRect(x - offset, y - offset, thinkness, thinkness)
		End
	
		error -= deltay
		If error < 0
			y += ystep
			error += deltax
		End
	Next
End

Function BresenhamLine:Vector2D[](startPos:Vector2D, endPos:Vector2D)
	Local points:Stack<Vector2D> = New Stack<Vector2D>
	Local steep:Bool = Abs(endPos.y - startPos.y) > Abs(endPos.x - startPos.x)
	Local swapped:Bool = False
	
	If steep
		startPos.SwapXY(startPos.x, startPos.y)
		endPos.SwapXY(endPos.x, endPos.y)
	End
	
	If startPos.x > endPos.x
		Local t:Float = startPos.x
		startPos.x = endPos.x
		endPos.x = t
		t = startPos.y
		startPos.y = endPos.y
		endPos.y = t
		swapped = True
	End
	
	Local deltax:Float = endPos.x - startPos.x
	Local deltay:Float = Abs(endPos.y - startPos.y)
	Local error:Float = deltax / 2
	Local ystep:Float
	Local y:Float = startPos.y
	
	If startPos.y < endPos.y Then
		ystep = 1
	Else
		ystep = -1
	End
	
	For Local x:Int = startPos.x Until endPos.x
		If steep
			points.Push(New Vector2D(y, x))
		Else
			points.Push(New Vector2D(x, y))
		End
	
		error -= deltay
		If error < 0
			y += ystep
			error += deltax
		End
	Next
	Local arr:Vector2D[] = points.ToArray()
	If swapped
		Arrays < Vector2D >.Reverse(arr)
	End
	Return arr
End

Private
Global screenshotPixels:Int[] ' this is globally cached for performance
Public
' summary: Takes a screenshot of a certain rectangle on the screen.  Defaults to the entire screen.
Function CreateScreenshot:Image(x%=0, y%=0, width%=0, height%=0)
	' if no width passed in, assume the whole width
	If width <= 0 Then
		width = DeviceWidth()
		x = 0
	End
	
	' if no height passed in, assume the whole height
	If height <= 0 Then
		height = DeviceHeight()
		y = 0
	End
	
	' check that the rectangle is entirely within the screen bounds
	If x < 0 Or y < 0 Or x + width > DeviceWidth() Or y + height > DeviceHeight() Then Return Null
	
	' create an image
	Local image:Image = CreateImage(width, height)
	
	' read the screen
	If screenshotPixels.Length <> width*height Then screenshotPixels = New Int[width*height]
	ReadPixels(screenshotPixels, x, y, width, height)
	image.WritePixels(screenshotPixels, 0, 0, width, height)
	
	Return image
End

'summary: Returns a random int in the range low (inclusive) to high (exclusive).
Function Rand:Int (low:Int, high:Int)
	Local v:Float = Rnd(low, high)
	if (v < 0) Then v -= 1.0
	Local vi:Int = Int(v)
	if vi = (low - 1) Then vi = Min (-1, high)
	Return vi
End

'summary: Converts Mask Pixel Color to Transparent Pixel
Function PixelArrayMask:Void(pixels:Int[], maskRed:Int = 0, maskGreen:Int = 0, maskBlue:Int = 0)
	For Local i:Int = 0 Until pixels.Length
		Local argb:Int = pixels[i]
		Local a:Int = (argb Shr 24) & $ff
		Local r:Int = (argb Shr 16) & $ff
		Local g:Int = (argb Shr 8) & $ff
		Local b:Int = argb & $ff
				
		If a = 255 And r = maskRed And g = maskGreen And b = maskBlue
			a = 0
			argb = (a Shl 24) | (r Shl 16) | (g Shl 8) | b
			pixels[i] = argb
		End
	Next
End


' constants

Const BASE64_CHARS:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/="
Global BASE64_ARRAY:Int[] = []

' control characters
Const ASC_NUL:Int = 0       ' Null character
Const ASC_SOH:Int = 1       ' Start of Heading
Const ASC_STX:Int = 2       ' Start of Text
Const ASC_ETX:Int = 3       ' End of Text
Const ASC_EOT:Int = 4       ' End of Transmission
Const ASC_ENQ:Int = 5       ' Enquiry
Const ASC_ACK:Int = 6       ' Acknowledgment
Const ASC_BEL:Int = 7       ' Bell
Const ASC_BACKSPACE:Int = 8 ' Backspace
Const ASC_TAB:Int = 9       ' Horizontal tab
Const ASC_LF:Int = 10       ' Linefeed
Const ASC_VTAB:Int = 11     ' Vertical tab
Const ASC_FF:Int = 12       ' Form feed
Const ASC_CR:Int = 13       ' Carriage return
Const ASC_SO:Int = 14       ' Shift Out
Const ASC_SI:Int = 15       ' Shift In
Const ASC_DLE:Int = 16      ' Data Line Escape
Const ASC_DC1:Int = 17      ' Device Control 1
Const ASC_DC2:Int = 18      ' Device Control 2
Const ASC_DC3:Int = 19      ' Device Control 3
Const ASC_DC4:Int = 20      ' Device Control 4
Const ASC_NAK:Int = 21      ' Negative Acknowledgment
Const ASC_SYN:Int = 22      ' Synchronous Idle
Const ASC_ETB:Int = 23      ' End of Transmit Block
Const ASC_CAN:Int = 24      ' Cancel
Const ASC_EM:Int = 25       ' End of Medium
Const ASC_SUB:Int = 26      ' Substitute
Const ASC_ESCAPE:Int = 27   ' Escape
Const ASC_FS:Int = 28       ' File separator
Const ASC_GS:Int = 29       ' Group separator
Const ASC_RS:Int = 30       ' Record separator
Const ASC_US:Int = 31       ' Unit separator

' visible characters
Const ASC_SPACE:Int = 32                ' '
Const ASC_EXCLAMATION:Int = 33          '!'
Const ASC_DOUBLE_QUOTE:Int = 34         '"'
Const ASC_HASH:Int = 35                 '#'
Const ASC_DOLLAR:Int = 36               '$'
Const ASC_PERCENT:Int = 37              '%'
Const ASC_AMPERSAND:Int = 38            '&'
Const ASC_SINGLE_QUOTE:Int = 39         '''
Const ASC_OPEN_PARENTHESIS:Int = 40     '('
Const ASC_CLOSE_PARENTHESIS:Int = 41    ')'
Const ASC_ASTERISK:Int = 42             '*'
Const ASC_PLUS:Int = 43                 '+'
Const ASC_COMMA:Int = 44                ','
Const ASC_HYPHEN:Int = 45               '-'
Const ASC_PERIOD:Int = 46               '.'
Const ASC_SLASH:Int = 47                '/'
Const ASC_0:Int = 48
Const ASC_1:Int = 49
Const ASC_2:Int = 50
Const ASC_3:Int = 51
Const ASC_4:Int = 52
Const ASC_5:Int = 53
Const ASC_6:Int = 54
Const ASC_7:Int = 55
Const ASC_8:Int = 56
Const ASC_9:Int = 57
Const ASC_COLON:Int = 58        ':'
Const ASC_SEMICOLON:Int = 59    ';'
Const ASC_LESS_THAN:Int = 60    '<'
Const ASC_EQUALS:Int = 61       '='
Const ASC_GREATER_THAN:Int = 62 '>'
Const ASC_QUESTION:Int = 63     '?'
Const ASC_AT:Int = 64           '@'
Const ASC_UPPER_A:Int = 65
Const ASC_UPPER_B:Int = 66
Const ASC_UPPER_C:Int = 67
Const ASC_UPPER_D:Int = 68
Const ASC_UPPER_E:Int = 69
Const ASC_UPPER_F:Int = 70
Const ASC_UPPER_G:Int = 71
Const ASC_UPPER_H:Int = 72
Const ASC_UPPER_I:Int = 73
Const ASC_UPPER_J:Int = 74
Const ASC_UPPER_K:Int = 75
Const ASC_UPPER_L:Int = 76
Const ASC_UPPER_M:Int = 77
Const ASC_UPPER_N:Int = 78
Const ASC_UPPER_O:Int = 79
Const ASC_UPPER_P:Int = 80
Const ASC_UPPER_Q:Int = 81
Const ASC_UPPER_R:Int = 82
Const ASC_UPPER_S:Int = 83
Const ASC_UPPER_T:Int = 84
Const ASC_UPPER_U:Int = 85
Const ASC_UPPER_V:Int = 86
Const ASC_UPPER_W:Int = 87
Const ASC_UPPER_X:Int = 88
Const ASC_UPPER_Y:Int = 89
Const ASC_UPPER_Z:Int = 90
Const ASC_OPEN_BRACKET:Int = 91     '['
Const ASC_BACKSLASH:Int = 92        '\'
Const ASC_CLOSE_BRACKET:Int = 93    ']'
Const ASC_CIRCUMFLEX:Int = 94       '^'
Const ASC_UNDERSCORE:Int = 95       '_'
Const ASC_BACKTICK:Int = 96         '`'
Const ASC_LOWER_A:Int = 97
Const ASC_LOWER_B:Int = 98
Const ASC_LOWER_C:Int = 99
Const ASC_LOWER_D:Int = 100
Const ASC_LOWER_E:Int = 101
Const ASC_LOWER_F:Int = 102
Const ASC_LOWER_G:Int = 103
Const ASC_LOWER_H:Int = 104
Const ASC_LOWER_I:Int = 105
Const ASC_LOWER_J:Int = 106
Const ASC_LOWER_K:Int = 107
Const ASC_LOWER_L:Int = 108
Const ASC_LOWER_M:Int = 109
Const ASC_LOWER_N:Int = 110
Const ASC_LOWER_O:Int = 111
Const ASC_LOWER_P:Int = 112
Const ASC_LOWER_Q:Int = 113
Const ASC_LOWER_R:Int = 114
Const ASC_LOWER_S:Int = 115
Const ASC_LOWER_T:Int = 116
Const ASC_LOWER_U:Int = 117
Const ASC_LOWER_V:Int = 118
Const ASC_LOWER_W:Int = 119
Const ASC_LOWER_X:Int = 120
Const ASC_LOWER_Y:Int = 121
Const ASC_LOWER_Z:Int = 122
Const ASC_OPEN_BRACE:Int = 123  '{'
Const ASC_PIPE:Int = 124        '|'
Const ASC_CLOSE_BRACE:Int = 125 '}'
Const ASC_TILDE:Int = 126       '~'
Const ASC_DELETE:Int = 127

Const INTERPOLATION_NONE:Int = 0
Const INTERPOLATION_LINEAR:Int = 1          ' interpolates from start to end
Const INTERPOLATION_INVERSE_LINEAR:Int = 2  ' interpolates from end to start
Const INTERPOLATION_HALF_SINE:Int = 3       ' interpolates from start to end and back again, in a wave
Const INTERPOLATION_HALF_COSINE:Int = 4     ' interpolates from end to start and back again, in a wave
Const INTERPOLATION_COUNT:Int = 5
