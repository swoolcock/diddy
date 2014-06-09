#Rem
Copyright (c) 2011 Steve Revill and Shane Woolcock
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#End

#Rem
Header: A collection of very simple GUI elements, usually for a basic menu system.
#End
Strict

Import diddy

Const VERTICAL:Int = 0
Const HORIZONTAL:Int = 1
	
#Rem
Summary: Provides a group of buttons that automatically handle mouseover images and sounds.
The buttons are automatically layed out horizontally or vertically, so only the menu itself needs to be positioned.
#End
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
	
#Rem
Summary: Creates a new SimpleMenu with the specified configuration.
#End
	Method New(soundMouseOverFile$, soundClickFile$, x:Int, y:Int, gap:Int, useVirtualRes:Bool, orientation:Int = VERTICAL)
		Init(soundMouseOverFile, soundClickFile, x, y, gap, useVirtualRes, orientation)
	End
	
#Rem
Summary: Initialises the menu (internal method).
Developers do not need to call this.
#End
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

#Rem
Summary: Calculates and returns the minimum width of the menu required to fit all buttons at their current positions.
See [[CalcHeight]].
Developers do not need to call this.
#End
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
	
#Rem
Summary: Calculates and returns the minimum height of the menu required to fit all buttons at their current positions.
See [[CalcWidth]].
Developers do not need to call this.
#End
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
	
#Rem
Summary: Sets the X coordinate of the menu, moving all the buttons with it.
#End
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
		
#Rem
Summary: Sets the Y coordinate of the menu, moving all the buttons with it.
#End	
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
	
#Rem
Summary: Sets the x coordinate of the menu to be that of the leftmost button.
Developers do not need to call this.
#End
	Method CalcLeft:Void()
		x = 10000
		Local b:SimpleButton
		For b = EachIn Self
			If b.x <x Then x = b.x
		Next						
	End
		
#Rem
Summary: Sets the y coordinate of the menu to be that of the topmost button.
Developers do not need to call this.
#End	
	Method CalcTop:Void()
		y = 10000
		Local b:SimpleButton
		For b = EachIn Self
			If b.y < y Then y = b.y
		Next						
	End
	
#Rem
Summary: Sets the x coordinate of the menu to be centred horizontally on the screen.
#End
	Method CentreHoriz:Void()
		CalcWidth()
		if useVirtualRes
			SetX((SCREEN_WIDTH-w)/2)
		Else
			SetX((DEVICE_WIDTH-w)/2)
		End
	End
	
#Rem
Summary: Sets the y coordinate of the menu to be centred vertically on the screen.
#End
	Method CentreVert:Void()
		CalcHeight()
		if useVirtualRes
			SetY((SCREEN_HEIGHT-h)/2)
		Else
			SetY((DEVICE_HEIGHT-h)/2)
		End
	End

#Rem
Summary: Sets the x and y coordinates of the menu to be centred both horizontally and vertically on the screen.
#End
	Method Centre:Void()
		CentreHoriz()
		CentreVert()
	End
	
#Rem
Summary: Sets the alpha for each button to the passed value.
#End
	Method SetMenuAlpha:Void(alpha:Float)
		Local b:SimpleButton
		If alpha < 0 Then alpha = 0
		if alpha > 1 Then alpha = 1
		For b = EachIn Self
			b.alpha = alpha
		Next
	End

#Rem
Summary: Creates a new [[SimpleButton]] and initialises it with the specified image, mouseover image, and name.
The button is added to the end of the menu and is positioned to fit the current menu orientation.
[code]
Local sb:SimpleButton = menu.AddButton(diddyGame.images.Find("newgame"), diddyGame.images.Find("newgameMO"), "New Game")
[/code]
#End
	Method AddButton:SimpleButton(buttonImage:GameImage, mouseOverFile:GameImage, name:String = "", drawText:Bool = False)
		Local b:SimpleButton = ProcessAddButton(buttonImage, mouseOverFile, name, drawText)
		If orientation = VERTICAL
			IncreaseHeight(b)
		Else
			IncreaseWidth(b)
		End
		Return b
	End

#Rem
Summary: Creates a new [[SimpleButton]] and initialises it with the specified image, mouseover image, and name.
The button is added to the end of the menu and is positioned to fit the current menu orientation.
[code]
Local sb:SimpleButton = menu.AddButton("newgame", "newgameMO", "New Game")
[/code]
#End
	Method AddButton:SimpleButton(buttonImageFile:String, mouseOverFile:String, name:String = "", drawText:Bool = False)
		Local b:SimpleButton = ProcessAddButton(buttonImageFile, mouseOverFile, name, drawText)
		If orientation = VERTICAL
			IncreaseHeight(b)
		Else
			IncreaseWidth(b)
		End
		Return b
	End
	
#Rem
Summary: Increases the height of the menu to fit the passed SimpleButton.
Developers do not need to call this.
#End
	Method IncreaseHeight:Void(b:SimpleButton)
		nextY = nextY + b.image.h + buttonGap

		h = h + b.image.h
		If addGap Then
			h = h + buttonGap
		Else
			addGap = 1
		End			
	End

#Rem
Summary: Increases the width of the menu to fit the passed SimpleButton.
Developers do not need to call this.
#End
	Method IncreaseWidth:Void(b:SimpleButton)
		nextX = nextX + b.image.w + buttonGap

		w = w + b.image.w
		If addGap Then
			w = w + buttonGap
		Else
			addGap = 1
		End
	End

#Rem
Summary: Internal method to add a button to the menu.
Developers do not need to call this.
#End
	Method ProcessAddButton:SimpleButton(buttonImage:GameImage, mouseOver:GameImage, name:String, drawText:Bool = False)
		Local b:SimpleButton = New SimpleButton
		b.drawText = drawText
		b.name = StripAll(buttonImage.name.ToUpper())
		b.image = buttonImage
		b.image.SetHandle(0, 0)
		If mouseOver <> Null
			b.imageMouseOver = mouseOver
			b.imageMouseOver.SetHandle(0, 0)
		End
		b = ProcessButton(b, name)
		Return b		
	End

#Rem
Summary: Internal method to add a button to the menu.
Developers do not need to call this.
#End
	Method ProcessAddButton:SimpleButton(buttonImageFile:String, mouseOverFile:String, name:String, drawText:Bool = False)
		Local b:SimpleButton = New SimpleButton
		b.drawText = drawText
		b.Load(buttonImageFile, mouseOverFile)
		b = ProcessButton(b, name)
		Return b
	End
	
#Rem
Summary: Internal method to add a button to the menu.
Developers do not need to call this.
#End
	Method ProcessButton:SimpleButton(b:SimpleButton, name:String)
		b.useVirtualRes = Self.useVirtualRes
		b.orientation = Self.orientation
		b.text = name
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
		
#Rem
Summary: Finds the button in the menu with the given name.
[code]
Local sb:SimpleButton = menu.Find("New Game")
[/code]
#End
	Method FindButton:SimpleButton(name:String)
		name = name.ToUpper()
		Local b:SimpleButton
		For b = EachIn Self
			If b.name = name Then Return b
		Next	
		Return Null
	End
	
#Rem
Summary: Returns 1 if the button with the specified name was clicked since the last call to [[Update]].
[code]
menu.Update()
...
If menu.Clicked("New Game") Then
	' start a new game
ElseIf menu.Clicked("Quit") Then
	' exit the game
End
[/code]
#End
	Method Clicked:Int(name:String)
		name = name.ToUpper()
		If name = clickedName
			If clearClickedName Then clickedName = ""
			Return 1		
		Else
			Return 0
		End
	End
	
#Rem
Summary: Determines whether the user clicked on a button, such that the next call to [[Clicked]] can test for it.
This should be called only once, towards the start of your [[Screen.Update]] implementation, or [[App.OnUpdate]].
#End
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
	
#Rem
Summary: Delegates to [[Sprite.Precache]] on each of the buttons.
#End
	Method Precache:Void()
		For Local b:SimpleButton = EachIn Self
			b.Precache()
		Next
	End
	
#Rem
Summary: Delegates to [[SimpleButton.Draw]] on each of the buttons.
#End
	Method Draw:Void()
		For Local b:SimpleButton = EachIn Self
			b.Draw()
		Next
	End
End

#Rem
Summary: A Delegate so that the developer can override the drawing of text on widgets
#END
Class SimpleTextDrawDelegate Abstract
	Method Draw:Void(text:String, x:Float, y:Float)
	End
End

#Rem
Summary: Represents a button in a [[SimpleMenu]].
#End
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
	Field drawText:Bool
	Field text:String
	Field textDrawDelegate:SimpleTextDrawDelegate
	
#Rem
Summary: Delegates to [[Sprite.Precache]] if the button has a valid image.
Developers do not need to call this.
#End
	Method Precache:Void()
		If image<>null
			Super.Precache()
		End
	End
	
#Rem
Summary: Renders the button.
Developers do not need to call this.
#End
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
		If drawText
			If textDrawDelegate <> Null
				textDrawDelegate.Draw(text, x + Self.image.w2, y)
			Else
				DrawText(text, x + Self.image.w2, y + Self.image.h2, 0.5, 0.5)
			End
		End
		SetAlpha 1
	End
	
#Rem
Summary: Fires a button click.
Developers do not need to call this.
#End
	Method Click:Void()
		If clicked = 0
			clicked = 1
			If soundClick <> null
				soundClick.Play()
			End
		End
	End
	
#Rem
Summary: Centres the button horizontally within the screen, also setting the Y position to the passed value.
#End
	Method CentreX:Void(yCoord:Int)
		if useVirtualRes
			MoveTo((SCREEN_WIDTH-image.w)/2, yCoord)
		Else
			MoveTo((DEVICE_WIDTH-image.w)/2, yCoord)
		End
		
	End
	
#Rem
Summary: Centres the button vertically within the screen, also setting the X position to the passed value.
#End
	Method CentreY:Void(xCoord:Int)
		If useVirtualRes
			MoveTo((SCREEN_HEIGHT-image.h)/2, xCoord)
		Else
			MoveTo((DEVICE_HEIGHT-image.h)/2, xCoord)
		End
	End
	
#Rem
Summary: Moves the button by the passed number of pixels.
#End
	Method MoveBy:Void(dx:Float,dy:Float)
		x += dx
		y += dy
	End

#Rem
Summary: Moves the button to the exact specified location.
#End
	Method MoveTo:Void(dx:Float,dy:Float)
		x = dx
		y = dy
	End
		
#Rem
Summary: Loads the required images and sounds for the button.
Developers do not need to call this.
#End
	Method Load:Void(buttonImage:String, mouseOverImage:String = "", soundMouseOverFile:String="", soundClickFile:String="")
		Self.image = New GameImage
		image.Load(diddyGame.images.path + buttonImage, False)
		
		If mouseOverImage <> ""
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
	
#Rem
Summary: Sets additional images so that the button can be used as a toggle button.
#End
	Method SetSelectedImage:Void(buttonImage:String, buttonImageMO:String = "")
		imageSelected = New GameImage
		imageSelected.Load(diddyGame.images.path + buttonImage, False)
		
		If buttonImageMO <> ""
			imageSelectedMO = New GameImage
			imageSelectedMO.Load(diddyGame.images.path + buttonImageMO, False)
		End
	End
	
#Rem
Summary: Updates the clicked status of the button, and plays mouseover sounds.
Developers only need to call this if they are using the button outside of a [[SimpleMenu]].
#End
	Method Update:Void()
		If active = 0 or disabled Then Return
		Local mx:Int = diddyGame.mouseX
		Local my:Int = diddyGame.mouseY
		If not useVirtualRes
			mx = MouseX()
			my = MouseY()
		End
		If mx >= x And mx < x + image.w And my >= y And my < y + image.h Then
			#if TARGET="android" or TARGET="ios"
			#Else
				If mouseOver = 0
					if soundMouseOver <> null
						soundMouseOver.Play()
					End
				End
				mouseOver = 1
			#End
			

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

#Rem
Summary: Represents a slider control, often used for volume levels.
#End
Class SimpleSlider Extends Sprite
	Field active:Int
	Field dotImage:GameImage
	Field dotX:Int, dotY:Int
	Field value:Int
	Field border:Int=0
	Field borderY:Int=5
	Field useVirtualRes:Bool = False
	
#Rem
Summary: Creates a new [[SimpleSlider]] with the specified configuration.
#End
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
	
#Rem
Summary: Sets the value of the slider (between 0 and 100 inclusive) and updates the position of the bar.
#End
	Method SetValue:Void(toSet:int)
		value = toSet
		If toSet < 0 Then value = 0	
		If toSet > 100 Then value = 100
		Local percent:Float = value/100.0		
		dotX = x + border + (percent * (image.w - (border * 2))) - dotImage.w2
	End

#Rem
Summary: Updates the value of the slider if the user has dragged somewhere on it.
This should be called only once per slider, towards the start of your [[Screen.Update]] implementation, or [[App.OnUpdate]].
Returns 1 if the slider changed value since the last frame, otherwise 0.
#End
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
			If mx >= x - buffer And mx < x + image.w + buffer And my >= y - borderY And my < y + image.h + borderY
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
	
#Rem
Summary: Renders the slider.
#End
	Method Draw:Void()
		If active
			DrawImage(image.image,x,y)
			DrawImage(dotImage.image,dotX,dotY)		
		End
	End
End

#Rem
Summary: Provides a dialog which a menu can be added to
#End
Class SimpleDialog
	Field alpha:Float = 0
	Field menu:SimpleMenu
	Field title:String
	Field image:GameImage
	Field show:Bool
	Field titleX:Float
	Field titleY:Float
	Field x:Float
	Field y:Float
	Field fadeInSpeed:Float
	Field fadeOutSpeed:Float
	Field titleDrawDelegate:SimpleTextDrawDelegate
	Field alphaControl:Float
	Field text:String
	Field textX:Float
	Field textY:Float
	Field textDrawDelegate:SimpleTextDrawDelegate
	Field textColor:Int[3]
	Field titleColor:Int[3]
	Field color:Int[3]
	Field dx:Float
	Field dy:Float
	Field ox:Float
	Field oy:Float
	Field ex:Float
	Field ey:Float
	
	' timer
	Field timer:Float
	Field timerSpeed:Float = 0.01
	
#Rem
Summary: Creates a new [[SimpleDialog]] with the specified configuration.
#End	
	Method New(menu:SimpleMenu, image:GameImage)
		Self.alpha = 0
		Self.menu = menu
		Self.image = image
		x = SCREEN_WIDTH2
		y = SCREEN_HEIGHT2
		titleX = SCREEN_WIDTH2
		titleY = 40
		fadeInSpeed = 0.05
		fadeOutSpeed = 0.08
		alphaControl = 0.4
		textX = SCREEN_WIDTH2
		textY = titleY + 50
		SetTextColor(255, 255, 255)
		SetTitleColor(255, 255, 255)
		SetImageColor(255, 255, 255)
	End
	
#Rem
Summary: Updates the dialog, controls the alpha and menu (menu is only usable if alpha is greater than alphaControl
#End	
	Method Update:Void()
		If show
			If alpha < 1
				alpha += fadeInSpeed * dt.delta
			Else
				alpha = 1
			End
			If menu
				menu.SetMenuAlpha(alpha)
				If alpha > alphaControl Then
					menu.Update()
				End
			End
		Else
			If alpha > 0
				alpha -= fadeOutSpeed * dt.delta
				If alpha < 0 Then alpha = 0
				If menu Then menu.SetMenuAlpha(alpha)
			Else
				alpha = 0
				show = False
			End
		End
		If alpha < 0 Then alpha = 0
		If alpha > 1 Then alpha = 1
	End
	
#Rem
Summary: Set the colour of the image
#END	
	Method SetImageColor:Void(r:Int, g:Int, b:Int)
		color[0] = r
		color[1] = g
		color[2] = b
	End
		
#Rem
Summary: Set the colour of the text
#END
	Method SetTextColor:Void(r:Int, g:Int, b:Int)
		textColor[0] = r
		textColor[1] = g
		textColor[2] = b
	End

#Rem
Summary: Set the colour of the title
#END
	Method SetTitleColor:Void(r:Int, g:Int, b:Int)
		titleColor[0] = r
		titleColor[1] = g
		titleColor[2] = b
	End
	
#Rem
Summary: Controls the timer
#End
	Method UpdateTimer:Void(loop:Bool, stopWhenFinished:Bool)
		timer += timerSpeed * dt.delta
		
		If stopWhenFinished
			If timer >= 1 Then
				timer = 1
			End
		ElseIf loop
			If timer >= 1 Then
				timer = 0
			End
		End
		
	End	
#Rem
Summary: Renders the dialog.
#End	
	Method Draw:Void()
		If alpha > 0
			SetAlpha alpha
			SetColor(color[0], color[1], color[2])
			image.Draw(x, y)
			
			SetColor(titleColor[0], titleColor[1], titleColor[2])
			If titleDrawDelegate <> Null Then
				titleDrawDelegate.Draw(title, titleX, titleY)
			Else
				DrawText(title, titleX, titleY, 0.5, 0.5)
			End
			
			SetColor(textColor[0], textColor[1], textColor[2])
			If textDrawDelegate <> Null Then
				textDrawDelegate.Draw(text, textX, textY)
			Else
				DrawText(text, textX, textY, 0.5, 0.5)
			End
			
			SetColor(255, 255, 255)
			If menu Then menu.Draw()
			
			SetAlpha 1
		End
	End
	
#Rem
Summary: Moves the dialog by the set amounts along with text and menus
#End
	Method MoveBy:Void(x:Float, y:Float, moveButtons:Bool = True)
		Self.x += x
		Self.y += y
		Self.textX += x
		Self.textY += y
		Self.titleX += x
		Self.titleY += y
		
		If moveButtons
			If menu
				For Local b:SimpleButton = EachIn Self.menu
					b.MoveBy(x, y)
				Next
			End
		End
	End
	
#Rem
Summary: Moves the dialog to the set coords along with text and menus
#End	
	Method MoveTo:Void(newX:Float, newY:Float, moveButtons:Bool = True)
		MoveBy(newX - x, newY - y, moveButtons)
	End
End