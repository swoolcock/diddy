#Rem
Copyright (c) 2011 Steve Revill and Shane Woolcock
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#End

Import diddy

Const VERTICAL:Int = 0
Const HORIZONTAL:Int = 1
	
Class SimpleMenu Extends List<SimpleButton>
	Field x:Float, y:Float
	Field buttonGap:Int = 0
	Field mouseOverName:String = ""
	Field clickedName:String = ""
	Field clearClickedName:Int = 1 
	Field nextX:Int = 0
	Field nextY:Int = 0
	Field w:Int, h:Int
	Field addGap:Int = 0
	Field soundMouseOver:GameSound
	Field soundClick:GameSound
	Field useVirtualRes:Bool = False
	Field orientation:Int = VERTICAL
	
	Method New()
		Error "Please use a different constructor"
	End
	
	Method New(soundMouseOverFile$, soundClickFile$, x:Int, y:Int, gap:Int, useVirtualRes:Bool, orientation:Int = VERTICAL)
		Init(soundMouseOverFile, soundClickFile, x, y, gap, useVirtualRes, orientation)
	End
	
	Method Init:Void(soundMouseOverFile:String="", soundClickFile:String="", x:Float, y:Float, gap:Int, useVirtualRes:Bool, orientation:Int)
		Self.Clear()
		Self.useVirtualRes = useVirtualRes
		Self.orientation = orientation
		Self.x = x
		Self.y = y
		nextX = x
		nextY = y
		Self.buttonGap = gap
		w = 0
		h = 0
		mouseOverName = ""
		clickedName = ""
		addGap = 0
		If soundMouseOverFile<>"" Then
			soundMouseOver = New GameSound
			soundMouseOver.Load(soundMouseOverFile)
		End
		If soundClickFile<>"" Then
			soundClick = New GameSound
			soundClick.Load(soundClickFile)		
		End
	End

	Method CalcWidth:Int()
		Local left:Int=10000
		Local right:Int=-10000
		Local b:SimpleButton
		For b = EachIn Self
			If b.x < left Then left = b.x
			If b.x+b.image.w > right Then right = b.x + b.image.w
		Next				
		w = right - left
		Return w
	End
	
	Method CalcHeight:Int()
		Local top:Int=10000
		Local bot:Int=-10000
		Local b:SimpleButton
		For b = EachIn Self
			If b.y < top Then top = b.y
			If b.y+b.image.h > bot Then bot = b.y + b.image.h
		Next				
		h = bot - top
		Return h
	End
	
	Method SetX:Void(thex#)
		CalcLeft()
		Local oldx# = x	
		x = thex
		Local diff# = x - oldx
		Local b:SimpleButton
		For b = EachIn Self
			b.MoveBy(diff,0)
		Next	
	End
		
	Method SetY:Void(they#)
		CalcTop()
		Local oldy# = y	
		y = they
		Local diff# = y-oldy
		Local b:SimpleButton
		For b = EachIn Self
			b.MoveBy(0,diff)
		Next		
	End
	
	Method CalcLeft:Void()
		x = 10000
		Local b:SimpleButton
		For b = EachIn Self
			If b.x <x Then x = b.x
		Next						
	End
		
	Method CalcTop:Void()
		y = 10000
		Local b:SimpleButton
		For b = EachIn Self
			If b.y < y Then y = b.y
		Next						
	End
	
	Method CentreHoriz:Void()
		CalcWidth()
		if useVirtualRes
			SetX((SCREEN_WIDTH-w)/2)
		Else
			SetX((DEVICE_WIDTH-w)/2)
		End
	End
	
	Method CentreVert:Void()
		CalcHeight()
		if useVirtualRes
			SetY((SCREEN_HEIGHT-h)/2)
		Else
			SetY((DEVICE_HEIGHT-h)/2)
		End
	End

	Method Centre:Void()
		CentreHoriz()
		CentreVert()
	End
	
	Method SetMenuAlpha:Void(alpha:Float)
		Local b:SimpleButton
		For b = EachIn Self
			b.alpha = alpha
		Next
	End

	Method AddButton:SimpleButton(buttonImageFile:String, mouseOverFile:String, name:String="")
		Local b:SimpleButton = ProcessAddButton(buttonImageFile, mouseOverFile, name)
		If orientation = VERTICAL
			IncreaseHeight(b)
		Else
			IncreaseWidth(b)
		End
		Return b
	End
	
	Method IncreaseHeight:Void(b:SimpleButton)
		nextY = nextY + b.image.h + buttonGap

		h = h + b.image.h
		If addGap Then
			h = h + buttonGap
		Else
			addGap = 1
		End			
	End

	Method IncreaseWidth:Void(b:SimpleButton)
		nextX = nextX + b.image.w + buttonGap

		w = w + b.image.w
		If addGap Then
			w = w + buttonGap
		Else
			addGap = 1
		End
	End

	Method ProcessAddButton:SimpleButton(buttonImageFile:String, mouseOverFile:String, name:String)
		Local b:SimpleButton = New SimpleButton
		b.Load(buttonImageFile, mouseOverFile)
		b.useVirtualRes = Self.useVirtualRes
		b.orientation = Self.orientation
		If name <> "" Then b.name = name.ToUpper()
		If orientation = VERTICAL
			b.CentreX(nextY)
		Else
			b.MoveTo(nextX, nextY)
		End
		
		b.soundMouseOver = soundMouseOver 
		b.soundClick = soundClick 
		AddLast(b)
		Return b
	End
	
	Method FindButton:SimpleButton(name:String)
		name = name.ToUpper()
		Local b:SimpleButton
		For b = EachIn Self
			If b.name = name Then Return b
		Next	
		Return Null
	End
	
	Method Clicked:Int(name:String)
		name = name.ToUpper()
		If name = clickedName
			If clearClickedName Then clickedName = ""
			Return 1		
		Else
			Return 0
		End
	End
	
	Method Update:Int()
		If diddyGame.screenFade.active
			Return 0
		EndIf
		clickedName = ""
		Local b:SimpleButton
		For b = EachIn Self
			b.Update()
			If b.mouseOver Then mouseOverName = b.name
			If b.clicked Then clickedName = b.name	
		Next
		Return 1
	End
	
	Method Precache:Void()
		For Local b:SimpleButton = EachIn Self
			b.Precache()
		Next
	End
	
	Method Draw:Void()
		For Local b:SimpleButton = EachIn Self
			b.Draw()
		Next
	End
End

Class SimpleButton Extends Sprite
	Field active:Int = 1
	Field clicked:Int = 0
	Field selected:Int = 0
	Field mouseOver:Int = 0
	Field disabled:Bool = False
	Field soundMouseOver:GameSound
	Field soundClick:GameSound
	Field imageMouseOver:GameImage
	Field imageSelected:GameImage
	Field imageSelectedMO:GameImage
	Field useVirtualRes:Bool = False
	Field orientation:Int = VERTICAL
	
	Method Precache:Void()
		If image<>null
			Super.Precache()
		End
	End
	
	Method Draw:Void()
		If active = 0 Then Return
		SetAlpha Self.alpha
		if mouseOver
			if selected And imageSelectedMO <> null Then
				DrawImage Self.imageSelectedMO.image, x, y
			Else
				DrawImage Self.imageMouseOver.image, x, y
			End
		ElseIf selected And imageSelected <> null Then
			DrawImage Self.imageSelected.image, x, y
		Else
			DrawImage Self.image.image, x, y
		EndIf
		SetAlpha 1
	End
	
	Method Click:Void()
		If clicked = 0
			clicked = 1
			If soundClick <> null
				soundClick.Play()
			End
		End
	End
	
	Method CentreX:Void(yCoord:Int)
		if useVirtualRes
			MoveTo((SCREEN_WIDTH-image.w)/2, yCoord)
		Else
			MoveTo((DEVICE_WIDTH-image.w)/2, yCoord)
		End
		
	End
	
	Method CentreY:Void(xCoord:Int)
		If useVirtualRes
			MoveTo((SCREEN_HEIGHT-image.h)/2, xCoord)
		Else
			MoveTo((DEVICE_HEIGHT-image.h)/2, xCoord)
		End
	End
	
	Method MoveBy:Void(dx:Float,dy:Float)
		x+=dx
		y+=dy
	End Method

	Method MoveTo:Void(dx:Float,dy:Float)
		x=dx
		y=dy
	End Method
		
	Method Load:Void(buttonImage:String, mouseOverImage:String = "", soundMouseOverFile:String="", soundClickFile:String="")
		Self.image = New GameImage
		image.Load(diddyGame.images.path + buttonImage, False)
		
		if  mouseOverImage <> ""
			imageMouseOver = New GameImage
			imageMouseOver.Load(diddyGame.images.path + mouseOverImage, False)
		End
		
		name = StripAll(buttonImage.ToUpper())
		
		If soundMouseOverFile<>"" Then
			soundMouseOver = New GameSound
			soundMouseOver.Load(soundMouseOverFile)
		End
		If soundClickFile<>"" Then
			soundClick = New GameSound
			soundClick.Load(soundClickFile)
		End
	End
	
	Method SetSelectedImage:Void(buttonImage:String, buttonImageMO:String = "")
		imageSelected = New GameImage
		imageSelected.Load(diddyGame.images.path + buttonImage, False)
		
		if  buttonImageMO <> ""
			imageSelectedMO = New GameImage
			imageSelectedMO.Load(diddyGame.images.path + buttonImageMO, False)
		End

	End
	
	Method Update:Void()
		If active = 0 or disabled Then Return
		Local mx:Int = diddyGame.mouseX
		Local my:Int = diddyGame.mouseY
		if not useVirtualRes
			mx = MouseX()
			my = MouseY()
		End
		If mx >= x And mx < x+image.w And my >= y And my < y+image.h Then
			If mouseOver = 0
				if soundMouseOver <> null
					soundMouseOver.Play()
				End
			End
			mouseOver = 1
			If MouseHit() Then
				Click()
			Else
				clicked = 0
			End
		Else
			mouseOver = 0	
			clicked = 0
		End
	End
End

Class SimpleSlider Extends Sprite
	Field active:Int
	Field dotImage:GameImage
	Field dotX:Int, dotY:Int
	Field value:Int
	Field border:Int=0
	Field borderY:Int=5
	Field useVirtualRes:Bool = False
	
	Method New(barFile:String, dotFile:String, x:Int, y:int, border:int = 0, name:String="", borderY:int=5, useVirtualRes:Bool = True)
		Self.image = New GameImage
		Self.useVirtualRes = useVirtualRes
		
		image.Load(diddyGame.images.path + barFile, False)
		name = StripAll(barFile.ToUpper())	
		
		dotImage = New GameImage
		dotImage.Load(diddyGame.images.path + dotFile, False)
		dotImage.name = StripAll(dotFile.ToUpper())
		
		Self.x = x
		Self.y = y
		Self.border = border
		Self.borderY = borderY

		Self.SetValue(50)
		Self.dotY = y-3
		Self.active = 1
	End
	
	Method SetValue:Void(toSet:int)
		value = toSet
		If toSet < 0 Then value = 0	
		If toSet > 100 Then value = 100
		Local percent:Float = value/100.0		
		dotX = x + border + (percent * (image.w - (border * 2))) - dotImage.w2
	End Method
		
	Method Update:Int()
		Local change:Int=0
		If active
			Local buffer:int = 10
			Local mx:Int = diddyGame.mouseX
			Local my:Int = diddyGame.mouseY
			if not useVirtualRes
				mx = MouseX()
				my = MouseY()
			End
			If mx >= x-buffer And mx < x + image.w + buffer And my >= y-borderY And my < y+image.h+borderY
				If MouseDown(MOUSE_LEFT)
					If mx <= x+border
						SetValue(0)
						change = 1
					ElseIf mx >= x+image.w-border
						SetValue(100)
						change = 1
					Else
						Local d:Float = mx - x - border
						Local p:Float = d/(image.w-(border*2))
						SetValue(Round(p*100))
						change = 1
					End
				End
			End
		End
		Return change
	End
	
	Method Draw:Void()
		If active
			DrawImage(image.image,x,y)
			DrawImage(dotImage.image,dotX,dotY)		
		End
	End
End