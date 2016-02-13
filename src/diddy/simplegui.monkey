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
	

Interface SimpleMenuObject
	Method Update:Int()
	Method Draw:Void()
	Method SetObjectAlpha:Void(alpha:Float)
End

#Rem
Summary: Provides a group of buttons that automatically handle mouseover images and sounds.
The buttons are automatically layed out horizontally or vertically, so only the menu itself needs to be positioned.
#End
Class SimpleMenu Extends List<SimpleMenuObject>
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

		For Local b:SimpleMenuObject = EachIn Self
			If SimpleButton(b)
				Local sb:SimpleButton = SimpleButton(b)
				If sb.x < left Then left = sb.x
				If sb.x + sb.image.w > right Then right = sb.x + sb.image.w
			End
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

		For Local b:SimpleMenuObject = EachIn Self
			If SimpleButton(b)
				Local sb:SimpleButton = SimpleButton(b)
				If sb.y < top Then top = sb.y
				If sb.y + sb.image.h > bot Then bot = sb.y + sb.image.h
			End
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

		For Local b:SimpleMenuObject = EachIn Self
			If SimpleButton(b)
				Local sb:SimpleButton = SimpleButton(b)
				sb.MoveBy(diff, 0)
			End
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

		For Local b:SimpleMenuObject = EachIn Self
			If SimpleButton(b)
				Local sb:SimpleButton = SimpleButton(b)
				sb.MoveBy(0, diff)
			End
		Next		
	End
	
#Rem
Summary: Sets the x coordinate of the menu to be that of the leftmost button.
Developers do not need to call this.
#End
	Method CalcLeft:Void()
		x = 10000
		
		For Local b:SimpleMenuObject = EachIn Self
			If SimpleButton(b)
				Local sb:SimpleButton = SimpleButton(b)
				If sb.x < x Then x = sb.x
			End
		Next						
	End
		
#Rem
Summary: Sets the y coordinate of the menu to be that of the topmost button.
Developers do not need to call this.
#End	
	Method CalcTop:Void()
		y = 10000

		For Local b:SimpleMenuObject = EachIn Self
			If SimpleButton(b)
				Local sb:SimpleButton = SimpleButton(b)
				If sb.y < y Then y = sb.y
			End
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
		Local b:SimpleMenuObject
		If alpha < 0 Then alpha = 0
		if alpha > 1 Then alpha = 1
		For b = EachIn Self
			b.SetObjectAlpha(alpha)
		Next
	End

#Rem
Summary: Creates a new [[SimpleButton]] and initialises it with the specified image, mouseover image, and name.
The button is added to the end of the menu and is positioned to fit the current menu orientation.
[code]
Local sb:SimpleButton = menu.AddButton(diddyGame.images.Find("newgame"), diddyGame.images.Find("newgameMO"), "New Game")
[/code]
#End
	Method AddButton:SimpleButton(buttonImage:GameImage, mouseOverFile:GameImage, name:String = "", drawText:Bool = False, disableImageFile:GameImage = Null, disableImageMOFile:GameImage = Null)
		Local b:SimpleButton = ProcessAddButton(buttonImage, mouseOverFile, name, drawText, disableImageFile, disableImageMOFile)
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
	Method AddButton:SimpleButton(buttonImageFile:String, mouseOverFile:String, name:String = "", drawText:Bool = False, disableImageFile:String = "", disableImageMOFile:String = "")
		Local b:SimpleButton = ProcessAddButton(buttonImageFile, mouseOverFile, name, drawText, disableImageFile, disableImageMOFile)
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
	Method ProcessAddButton:SimpleButton(buttonImage:GameImage, mouseOver:GameImage, name:String, drawText:Bool = False, disabledImage:GameImage = Null, disableMOImage:GameImage = Null)
		Local b:SimpleButton = New SimpleButton
		b.drawText = drawText
		b.name = StripAll(buttonImage.name.ToUpper())
		b.image = buttonImage
		b.image.SetHandle(0, 0)
		If mouseOver <> Null
			b.imageMouseOver = mouseOver
			b.imageMouseOver.SetHandle(0, 0)
		End
		If disabledImage <> Null
			b.imageDisabled = disabledImage
			b.imageDisabled.SetHandle(0, 0)
		End
		If disableMOImage <> Null
			b.imageDisabledMO = disableMOImage
			b.imageDisabledMO.SetHandle(0, 0)
		End
		b = ProcessButton(b, name)
		Return b		
	End

#Rem
Summary: Internal method to add a button to the menu.
Developers do not need to call this.
#End
	Method ProcessAddButton:SimpleButton(buttonImageFile:String, mouseOverFile:String, name:String, drawText:Bool = False, disableImageFile:String = "", disableImageMOFile:String = "")
		Local b:SimpleButton = New SimpleButton
		b.drawText = drawText
		b.Load(buttonImageFile, mouseOverFile, "", "", disableImageFile, disableImageMOFile)
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
		For Local b:SimpleMenuObject = EachIn Self
			If SimpleButton(b)
				Local sb:SimpleButton = SimpleButton(b)
				If sb.name = name Then Return sb
			End
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
		Local change:Int
		For Local b:SimpleMenuObject = EachIn Self
			change = b.Update()
			If SimpleButton(b)
				Local sb:SimpleButton = SimpleButton(b)
				If sb.mouseOver Then mouseOverName = sb.name
				If sb.clicked Then clickedName = sb.name
			End
		Next
		Return change
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
		For Local b:SimpleMenuObject = EachIn Self
			b.Draw()
		Next
	End
	
#Rem
Summary: Loads in a simple menu via JSON
#End
	Function LoadMenuJson:SimpleMenu(path:String)
		Local str:String = LoadString("json/" + path)
		If str = "" Then Error("Error loading json file: json/" + path)
		
		Local sm:SimpleMenu = New SimpleMenu()
		
		Local menuX:Float
		Local menuY:Float
		Local menuOffsetX:Float
		Local gap:Int = 30
		Local useVirtualRes:Bool = True
		Local orientation:Int = VERTICAL
		Local menuPath:String = "menu/"
		
		Try
			Local jo:JsonObject = New JsonObject(str)
			Local menuJo:JsonObject = JsonObject(jo.Get("menu"))
			menuY = menuJo.GetFloat("y")
			menuX = menuJo.GetFloat("x")
			menuOffsetX = menuJo.GetFloat("offsetX")
			
			orientation = menuJo.GetInt("orientation")
			
			gap = menuJo.GetInt("gap", gap)		
			sm.Init("", "", menuX, menuY, gap, useVirtualRes, orientation)
			
			For Local menuMap:map.Node<String, JsonValue> = EachIn menuJo.GetData()
				DebugPrint " menuMap.Key = " + menuMap.Key
				Select menuMap.Key.ToLower()
					Case "buttons"
						Local buttonsJo:JsonObject = JsonObject(menuMap.Value)
						For Local buttonsMap:map.Node<String, JsonValue> = EachIn buttonsJo.GetData()
							DebugPrint "buttonsMap.Key = " + buttonsMap.Key
							Select buttonsMap.Key
								Case "button"
									DebugPrint "extracting button data..."
									
									Local buttonJa:JsonArray = JsonArray(buttonsMap.Value)
									
									For Local d:Int = 0 Until buttonJa.Length()
										Local o:JsonObject = JsonObject(buttonJa.Get(d))
										Local name:String = o.GetString("name")
										Local image:String = o.GetString("image")
										Local useDisabled:Bool = o.GetBool("useDisabled")
										Local offsetY:Float = o.GetFloat("offsetY")
										Local offsetX:Float = o.GetFloat("offsetX")
										Local moveByX:Float = o.GetFloat("moveByX")
										Local moveByY:Float = o.GetFloat("moveByY")
										Local redText:Int = o.GetInt("redText")
										Local greenText:Int = o.GetInt("greenText")
										Local blueText:Int = o.GetInt("blueText")
										Local x:Int = o.GetInt("x", -1000)
										Local y:Int = o.GetInt("y", -1000)
										Local displayText:Bool = o.GetBool("displayText", True)
										Local disabledClick:Bool = o.GetBool("disabledClick")
										
										Local b:SimpleButton
										If useDisabled
											b = sm.AddButton(menuPath + image + ".png", menuPath + image + "MO" + ".png", name, displayText, menuPath + image + "_disabled.png", menuPath + image + "_disabledMO.png")
										Else
											b = sm.AddButton(menuPath + image + ".png", menuPath + image + "MO" + ".png", name, displayText)
										End
										
										b.disabledClick = disabledClick
										
										b.offsetY = offsetY
										b.offsetX = offsetX
										b.textRed = redText
										b.textGreen = greenText
										b.textBlue = blueText
										If x <> - 1000 And y <> - 1000 Then
											b.MoveTo(x, y)
										ElseIf x <> - 1000
											b.MoveTo(x, b.y)
										ElseIf y <> - 1000
											b.MoveTo(b.x, y)
										End
										
										b.MoveBy(moveByX, moveByY)
									Next
							End
						Next
					Case "sliders"
						Local slidersJo:JsonObject = JsonObject(menuMap.Value)
						For Local slidersMap:map.Node<String, JsonValue> = EachIn slidersJo.GetData()
							DebugPrint "slidersMap.Key = " + slidersMap.Key
							Select slidersMap.Key
								Case "slider"
									DebugPrint "extracting slider data..."
									
									Local sliderJa:JsonArray = JsonArray(slidersMap.Value)
									
									For Local d:Int = 0 Until sliderJa.Length()
										Local o:JsonObject = JsonObject(sliderJa.Get(d))
										Local name:String = o.GetString("name")
										Local image:String = o.GetString("image")
										Local x:Int = o.GetInt("x")
										Local y:Int = o.GetInt("y")
										Local borderX:Int = o.GetInt("borderX")
										Local borderY:Int = o.GetInt("borderY")
																				
										Local b:SimpleSlider = New SimpleSlider(menuPath + image + "_bar.png", menuPath + image + ".png", x, y, borderX, name, borderY, True)
										sm.AddLast(b)
										
										
									Next
							End
						Next
				End
			Next
			
		Catch t:JsonError
			Error "JsonError"
		End
		
		DebugPrint "menuOffsetX  = " + menuOffsetX
		If menuOffsetX <> 0
			Local xx:Float
			If orientation = VERTICAL
				xx = SCREEN_WIDTH / 2
			Else
				xx = sm.x
			End
			
			sm.SetX(xx + menuOffsetX)
		End
		
		Return sm
	End
	
	Method SetButtonDrawDelegate:Void(stdd:SimpleTextDrawDelegate)
		For Local b:SimpleMenuObject = EachIn Self
			If SimpleButton(b)
				Local sb:SimpleButton = SimpleButton(b)
				sb.textDrawDelegate = stdd
			End
		Next
	End
End

Class SimpleImagesDrawDelegate Abstract
	Field spriteList:List<Sprite>
	Field offsetX:Float, offsetY:Float
	Field rounded:Bool = False
	
	Method New()
		spriteList = New List<Sprite>
	End
	
	Method Draw:Void(alpha:Float)
		Local oldAlpha:Float = GetAlpha()
		SetAlpha(alpha)
		For Local s:Sprite = EachIn spriteList
			s.alpha = alpha
			s.Draw(offsetX, offsetY, rounded)
		Next
		SetAlpha(oldAlpha)
	End
End

#Rem
Summary: A Delegate so that the developer can override the drawing of text on widgets
#END
Class SimpleTextDrawDelegate Abstract
	Method Draw:Void(text:String, x:Float, y:Float)
	End
	Method Draw:Void(button:SimpleButton)
	End
End

#Rem
Summary: Represents a button in a [[SimpleMenu]].
#End
Class SimpleButton Extends Sprite Implements SimpleMenuObject
	Field active:Int = 1
	Field clicked:Int = 0
	Field selected:Int = 0
	Field mouseOver:Int = 0
	Field disabled:Bool = False
	Field disabledClick:Bool = False
	
	Field soundMouseOver:GameSound
	Field soundClick:GameSound
	Field imageMouseOver:GameImage
	Field imageSelected:GameImage
	Field imageSelectedMO:GameImage
	Field imageDisabled:GameImage
	Field imageDisabledMO:GameImage
	Field useVirtualRes:Bool = False
	Field orientation:Int = VERTICAL
	Field drawText:Bool
	Field text:String
	Field textDrawDelegate:SimpleTextDrawDelegate
	Field offsetY:Float
	Field offsetX:Float
	Field textRed:Int
	Field textGreen:Int
	Field textBlue:Int
	Field drawShadow:Bool
	Field alignment:Int = 0
	Field data:Int
	
	Field sprite:Sprite
	Field sprite2:Sprite
#Rem
Summary: Delegates to [[Sprite.Precache]] if the button has a valid image.
Developers do not need to call this.
#End
	Method Precache:Void()
		If image<>null
			Super.Precache()
		End
	End
	
	Method SetObjectAlpha:Void(alpha:Float)
		Self.alpha = alpha
		If sprite
			sprite.alpha = alpha
		End
		if sprite2
			sprite2.alpha = alpha
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
			If disabled And imageDisabledMO <> Null Then
				DrawImage Self.imageDisabledMO.image, x, y
			ElseIf selected And imageSelectedMO <> Null Then
				DrawImage Self.imageSelectedMO.image, x, y
			ElseIf imageMouseOver.image <> Null
				DrawImage Self.imageMouseOver.image, x, y
			Else
				DrawImage Self.image.image, x, y
			End
		ElseIf selected And imageSelected <> null Then
			DrawImage Self.imageSelected.image, x, y
		ElseIf disabled And imageDisabled <> Null Then
			DrawImage Self.imageDisabled.image, x, y
		Else
			DrawImage Self.image.image, x, y
		EndIf
		If drawText
			If textDrawDelegate <> Null
				textDrawDelegate.Draw(text, x + Self.image.w2 + offsetX, y + offsetY)
				textDrawDelegate.Draw(Self)
				SetAlpha Self.alpha
			Else
				DrawText(text, x + Self.image.w2, y + Self.image.h2, 0.5, 0.5)
			End
		End
		If sprite
			sprite.Draw()
			SetAlpha Self.alpha
		End
		If sprite2
			sprite2.Draw()
			SetAlpha Self.alpha
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
	Method Load:Void(buttonImage:String, mouseOverImage:String = "", soundMouseOverFile:String = "", soundClickFile:String = "", disableImageFile:String = "", disableMOImageFile:String = "")
		Self.image = New GameImage
		image.Load(diddyGame.images.path + buttonImage, False)
		
		If mouseOverImage <> ""
			imageMouseOver = New GameImage
			imageMouseOver.Load(diddyGame.images.path + mouseOverImage, False, False, 0, 0, 0, False, "", True)
		End

		If disableImageFile <> ""
			imageDisabled = New GameImage
			imageDisabled.Load(diddyGame.images.path + disableImageFile, False)
		End

		If disableMOImageFile <> ""
			imageDisabledMO = New GameImage
			imageDisabledMO.Load(diddyGame.images.path + disableMOImageFile, False)
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
	Method Update:Int()
		If active = 0 or (disabled And not disabledClick) Then Return 0
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
		Return 1
	End
End

#Rem
Summary: Represents a slider control, often used for volume levels.
#End
Class SimpleSlider Extends Sprite Implements SimpleMenuObject
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
		Self.name = name'StripAll(barFile.ToUpper())	
		
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
	
	Method SetSliderXY:Void(x:Float, y:Float)
		Self.x = x
		Self.y = y
		SetValue(value)
		Self.dotY = y - 3
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
	
	Method GetValue:Int()
		Local rv:Int
		Local d:Float = dotX - x - border
		Local p:Float = d / (image.w - (border * 2))
		rv = p * 100
		Return rv
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
			SetAlpha alpha
			DrawImage(image.image, x, y)
			DrawImage(dotImage.image, dotX, dotY)
			SetAlpha 1
		End
	End
	
	Method SetObjectAlpha:Void(alpha:Float)
		Self.alpha = alpha
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
	Field imagesDrawDelegate:SimpleImagesDrawDelegate
	Field titleDrawDelegate:SimpleTextDrawDelegate
	Field alphaControl:Float
	Field text:String
	Field textX:Float
	Field textY:Float
	Field textDrawDelegate:SimpleTextDrawDelegate
	Field text1:String
	Field textX1:Float
	Field textY1:Float
	Field textDrawDelegate1:SimpleTextDrawDelegate
	
	Field textColor:Int[3]
	Field textColor1:Int[3]
	Field titleColor:Int[3]
	Field color:Int[3]
	Field dx:Float
	Field dy:Float
	Field ox:Float
	Field oy:Float
	Field ex:Float
	Field ey:Float
	
	Field dimAmount:Float
	Field maxDimAmount:Float = 0.5
	Field dimInSpeed:Float
	Field dimOutSpeed:Float
	
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
		dimInSpeed = 0.05
		dimOutSpeed = 0.08
		
		alphaControl = 0.4
		textX = SCREEN_WIDTH2
		textY = titleY + 50
		SetTextColor(255, 255, 255)
		SetTitleColor(255, 255, 255)
		SetImageColor(255, 255, 255)
	End
	
	Method SetText:Void(text:String, textX:Float, textY:Float, r:Int = 255, g:Int = 255, b:Int = 255, textDrawDelegate:SimpleTextDrawDelegate = Null)
		Self.text = text
		Self.textX = textX
		Self.textY = textY
		Self.textDrawDelegate = textDrawDelegate
		SetTextColor(r, g, b)
	End
	
	Method SetText1:Void(text:String, textX:Float, textY:Float, r:Int = 255, g:Int = 255, b:Int = 255, textDrawDelegate:SimpleTextDrawDelegate = Null)
		Self.text1 = text
		Self.textX1 = textX
		Self.textY1 = textY
		Self.textDrawDelegate1 = textDrawDelegate
		SetTextColor(r, g, b)
	End
	
	Method SetTitle:Void(titleText:String, titleX:Float, titleY:Float, r:Int = 255, g:Int = 255, b:Int = 255, titleDrawDelegate:SimpleTextDrawDelegate = Null)
		Self.title = titleText
		Self.titleX = titleX
		Self.titleY = titleY
		Self.titleDrawDelegate = titleDrawDelegate
		SetTitleColor(r, g, b)
	End
	
#Rem
Summary: Updates the dialog, controls the alpha and menu (menu is only usable if alpha is greater than alphaControl
#End	
	Method Update:Void()
		If show
			If dimAmount < maxDimAmount
				dimAmount += dimInSpeed * dt.delta
			Else
				dimAmount = maxDimAmount
			End
		
		
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
			If dimAmount > 0
				dimAmount -= dimOutSpeed * dt.delta
			Else
				dimAmount = 0
			End
		
			If alpha > 0
				alpha -= fadeOutSpeed * dt.delta
				If alpha < 0 Then alpha = 0
				If menu Then menu.SetMenuAlpha(alpha)
			Else
				alpha = 0
				show = False
			End
		End
		If dimAmount < 0 Then dimAmount = 0
		If dimAmount > maxDimAmount Then dimAmount = maxDimAmount
		
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
		If dimAmount > 0
			SetAlpha dimAmount
			SetColor 0, 0, 0
			DrawRect 0, 0, SCREEN_WIDTH, SCREEN_WIDTH
			SetColor 255, 255, 255
			SetAlpha alpha
		End
	
		If alpha > 0
			SetAlpha alpha
			SetColor(color[0], color[1], color[2])
			image.Draw(x, y)
			
			If imagesDrawDelegate <> Null
				imagesDrawDelegate.Draw(alpha)
			End
			
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
			
			SetColor(textColor1[0], textColor1[1], textColor1[2])
			If textDrawDelegate1 <> Null Then
				textDrawDelegate1.Draw(text1, textX1, textY1)
			Else
				DrawText(text1, textX1, textY1, 0.5, 0.5)
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