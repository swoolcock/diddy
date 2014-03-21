#Rem
Copyright (c) 2011 Steve Revill and Shane Woolcock
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#End

Import mojo
Import diddy.framework
Import diddy.assert
Import diddy.vector2d
Import diddy.externfunctions
Import diddy.constants

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

#If TARGET="xna" Or TARGET="psm" Then
	Private
	Global seekMusicCalled:Bool = False
	Public
	Function SeekMusic:Int(timeMillis:Int)
		If Not seekMusicCalled Then
			seekMusicCalled = True
			Print "Warning: SeekMusic is not implemented in XNA and PSM!"
		End
		Return 1
	End
#End

Function FlushKeys:Void()
	ResetInput()
End

Function GetUpdateRate:Int()
	Return UpdateRate()
End

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

Function ExitApp:Void()
	#If TARGET="win8"
		Print "Cant exit a Win8 application"
	#Else
		EndApp()
	#End
End

Function GetDayOfMonth:Int()
	 Local date:=GetDate()
	 Local day:=date[2]
	 Return day
End

Function GetDayOfWeek:Int()
	Print "GetDayOfWeek is not supported returning -1"
	Print "GetDayOfWeek will be removed in future versions!!!"
	Return -1
End

Function GetMonth:Int()
	Local date:=GetDate()
	Local month:=date[1]
	Return month
End

Function GetYear:Int()
	Local date:=GetDate()
	Local year:=date[0]
	Return year
End

Function GetHours:Int()
	Local date:=GetDate()
	Local hour:=date[3]
	Return hour
End

Function GetMinutes:Int()
	Local date:=GetDate()
	Local min:=date[4]
	Return min
End

Function GetSeconds:Int()
	Local date:=GetDate()
	Local sec:=date[5]
	Return sec
End

Function GetMilliSeconds:Int()
	Local date:=GetDate()
	Local msec:=date[6]
	Return msec
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

Function CircleOverlap:Bool(x1:Float, y1:Float, r1:Float, x2:Float, y2:Float, r2:Float)
	Local dx:Float = x1 - x2
	Local dy:Float = y1 - y2
	Local r:Float = r1 + r2
	If dx * dx + dy * dy <= r * r Then ' collided
		Return True
	End
	Return False
End

Function CircleRectsOverlap:Bool(x1:Float, y1:Float, w1:Float, h1:Float, cx:Float, cy:Float, r:Float)
	Local testX:Float = cx
	Local testY:Float = cy
	If testX < x1 Then testX = x1
	If testX > (x1 + w1) Then testX = (x1 + w1)
	If testY < y1 Then testY = y1
	If testY > (y1 + h1) Then testY = (y1 + h1)
	Return ( (cx - testX) * (cx - testX) + (cy - testY) * (cy - testY)) < r * r
End

Function LoadBitmap:Image(path$, flags%=0)
	Local pointer:Image = LoadImage(path, 1, flags)

	AssertNotNull(pointer, "Error loading bitmap "+path)
	
   	Return pointer
End

Function LoadAnimBitmap:Image(path$, w%, h%, count%, tmpImage:Image=Null)
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

Function Lerp:Float(startValue:Float, endValue:Float, progress:Float)
	Return startValue + (endValue-startValue) * progress
End

Function InterpolateWithEase:Float(startValue:Float, endValue:Float, progress:Float, ease:Int)
	If progress <= 0 Then Return startValue
	If progress >= 1 Then Return endValue
	Select ease
		Case EASE_IN_DOUBLE
			Return Lerp(endValue, startValue, (1-progress)*(1-progress)*(1-progress)*(1-progress))
		Case EASE_IN
			Return Lerp(endValue, startValue, (1-progress)*(1-progress))
		Case EASE_IN_HALF
			Return Lerp(endValue, startValue, Pow(1-progress, 1.5))
		Case EASE_OUT
			Return Lerp(startValue, endValue, progress * progress)
		Case EASE_OUT_HALF
			Return Lerp(startValue, endValue, Pow(progress, 1.5))
		Case EASE_OUT_DOUBLE
			Return Lerp(startValue, endValue, progress*progress*progress*progress)
		Case EASE_IN_OUT
			Return startValue + (-2*(progress*progress*progress) + 3*(progress*progress)) * (endValue - startValue)
		Default
			Return Lerp(startValue, endValue, progress);
	End
End

' summary:
' CastUtil is a utility class to allow casting of primitives to Null in the case that the variable type is unknown.
' Assuming Hello is a class, and T is a generic in the current scope...
' [code]
' Local foo:T = <something>
' Local bar:Hello = CastUtil<Hello>.Cast(foo) ' returns Null if foo is primitive
' Local baz:Hello = Hello(foo) ' error if foo is primitive
' [/code]
Class CastUtil<T>
Private
	Global NIL:T

Public
	Function Cast:T(value:Int)
		Return NIL
	End
	
	Function Cast:T(value:Float)
		Return NIL
	End
	
	Function Cast:T(value:String)
		Return NIL
	End
	
	Function Cast:T(value:Bool)
		Return NIL
	End
	
	Function Cast:T(value:Object)
		'Return T(value) FIXME: this is no longer working for some reason
		Return NIL
	End
	
	Function IsPrimitive:Bool(value:T)
		'Return Cast(value) = Null ' FIXME
		Return False
	End
End
