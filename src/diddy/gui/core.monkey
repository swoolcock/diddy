#Rem
Copyright (c) 2011 Steve Revill and Shane Woolcock
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#End

Strict

Import mojo
Import diddy
Import diddy.gui.layout

Const ACTION_CLICKED:String = "clicked"
Const ACTION_VALUE_CHANGED:String = "changed"

' used for scissors
Class Rectangle
Public
' Public fields
	Field x:Int, y:Int, w:Int, h:Int
	Field empty:Bool = False

' Constructors
	Method New(x:Int, y:Int, w:Int, h:Int)
		Set(x, y, w, h)
	End
	
' Public methods
	Method Set:Void(x:Int, y:Int, w:Int, h:Int)
		Self.x = x
		Self.y = y
		Self.w = w
		Self.h = h
		Self.empty = Self.w <= 0 Or Self.h <= 0
	End
	
	Method Set:Void(srcRect:Rectangle)
		Self.x = srcRect.x
		Self.y = srcRect.y
		Self.w = srcRect.w
		Self.h = srcRect.h
		Self.empty = Self.w <= 0 Or Self.h <= 0
	End
	
	Method Clear:Void()
		Self.w = -1
		Self.h = -1
		Self.empty = True
	End
	
	Method Intersect:Void(x:Int, y:Int, w:Int, h:Int)
		If x >= Self.x + Self.w Or y >= Self.y + Self.h Or Self.x >= x + w Or Self.y >= y + h Then
			Clear()
			Return
		End
		
		Local r:Int = Self.x + Self.w
		Local b:Int = Self.y + Self.h
		If Self.x < x Then Self.x = x
		If Self.y < y Then Self.y = y
		If r > x + w Then r = x + w
		If b > y + h Then b = y + h
		Self.w = r - Self.x
		Self.h = b - Self.y
	End
End ' Class Rectangle

Class Point
Public
' Public fields
	Field x:Int
	Field y:Int
	
' Constructors
	Method New(x:Int, y:Int)
		Self.x = x
		Self.y = y
	End
End ' Class Point

' Listeners and Adapters:
' An adapter is an abstract implementation of a listener that provides empty methods (for convenience).
' If you're using a standalone class for your listener, extend the adapter and override
' the methods you need.  If you're using an existing class, implement the listener and define
' every method.  Listeners with only one method do not have an accompanying adapter.
' AbstractMouseAdapter implements both MouseListener and MouseMotionListener, for convenience.

Interface IActionListener
	Method ActionPerformed:Void(source:Component, action:String)
End

Interface IMouseListener
	Method MousePressed:Void(source:Component, x:Int, y:Int, button:Int, absoluteX:Int, absoluteY:Int)
	Method MouseReleased:Void(source:Component, x:Int, y:Int, button:Int, absoluteX:Int, absoluteY:Int)
	Method MouseClicked:Void(source:Component, x:Int, y:Int, button:Int, absoluteX:Int, absoluteY:Int)
	Method MouseEntered:Void(source:Component, x:Int, y:Int, exitedComp:Component, absoluteX:Int, absoluteY:Int)
	Method MouseExited:Void(source:Component, x:Int, y:Int, enteredComp:Component, absoluteX:Int, absoluteY:Int)
End

Interface IMouseMotionListener
	Method MouseMoved:Void(source:Component, x:Int, y:Int, absoluteX:Int, absoluteY:Int)
	Method MouseDragged:Void(source:Component, x:Int, y:Int, button:Int, absoluteX:Int, absoluteY:Int)
End

Interface IKeyListener
	Method KeyPressed:Void(source:Component, keychar:String, keycode:Int)
	Method KeyReleased:Void(source:Component, keychar:String, keycode:Int)
	Method KeyRepeated:Void(source:Component, keychar:String, keycode:Int)
	Method KeyTyped:Void(source:Component, keychar:String, keycode:Int)
End

Interface IFocusListener
	Method FocusGained:Void(source:Component, oldFocus:Component)
	Method FocusLost:Void(source:Component, newFocus:Component)
End

Class AbstractMouseAdapter Implements IMouseListener, IMouseMotionListener Abstract
Public
' Implements IMouseListener
	Method MousePressed:Void(source:Component, x:Int, y:Int, button:Int, absoluteX:Int, absoluteY:Int)
	End
	
	Method MouseReleased:Void(source:Component, x:Int, y:Int, button:Int, absoluteX:Int, absoluteY:Int)
	End
	
	Method MouseClicked:Void(source:Component, x:Int, y:Int, button:Int, absoluteX:Int, absoluteY:Int)
	End
	
	Method MouseEntered:Void(source:Component, x:Int, y:Int, exitedComp:Component, absoluteX:Int, absoluteY:Int)
	End
	
	Method MouseExited:Void(source:Component, x:Int, y:Int, enteredComp:Component, absoluteX:Int, absoluteY:Int)
	End
	
' Implements IMouseMotionListener
	Method MouseMoved:Void(source:Component, x:Int, y:Int, absoluteX:Int, absoluteY:Int)
	End
	
	Method MouseDragged:Void(source:Component, x:Int, y:Int, button:Int, absoluteX:Int, absoluteY:Int)
	End
End ' Class AbstractMouseAdapter

Class AbstractKeyAdapter Implements IKeyListener Abstract
Public
' Implements IKeyListener
	Method KeyPressed:Void(source:Component, keychar:String, keycode:Int)
	End
	
	Method KeyReleased:Void(source:Component, keychar:String, keycode:Int)
	End
	
	Method KeyRepeated:Void(source:Component, keychar:String, keycode:Int)
	End
	
	Method KeyTyped:Void(source:Component, keychar:String, keycode:Int)
	End
End ' Class AbstractKeyAdapter

Class AbstractFocusAdapter Implements IFocusListener Abstract
Public
'Implements IFocusListener
	Method FocusGained:Void(source:Component, oldFocus:Component)
	End
	Method FocusLost:Void(source:Component, newFocus:Component)
	End
End ' Class AbstractFocusAdapter

' Top level GUI class.  All public actions from components on the desktop get forwarded here
' unless an ActionListener is explicitly set for that component.
Class GUI Implements IActionListener
Private
' Private fields
	Field scissors:Rectangle[] = New Rectangle[128]
	Field scissorDepth:Int = 0
	
	Field mouseDown:Bool[3]
	Field mouseDownX:Int[3]
	Field mouseDownY:Int[3]
	Field mouseDownComponent:Component[3]
	
	Field mouseLastX:Int
	Field mouseLastY:Int
	Field mouseLastComponent:Component
	Field mouseThisX:Int
	Field mouseThisY:Int
	Field mouseThisComponent:Component
	
	Field currentFocus:Component = Null
	
	Field skinDoc:XMLDocument
	Field skinAtlas:GameImage
	
	Field desktop:GUIDesktop
	Field useVirtualRes:Bool = False
	
	Field layoutEnabled:Bool = False
	
' Private methods
	Method PushScissor:Void(x:Float, y:Float, w:Float, h:Float)
		' don't use assert, for speed on android (one less method call)
		If scissorDepth >= scissors.Length Then
			AssertError("GUI.PushScissor: Out of space for scissors.")
		End
		If scissorDepth = 0 Then
			scissors[0].Set(x, y, w, h)
		Else
			scissors[scissorDepth].Set(scissors[scissorDepth-1])
			scissors[scissorDepth].Intersect(x, y, w, h)
		End
		scissorDepth += 1
		UpdateScissor()
	End
	
	Method PopScissor:Void()
		If scissorDepth > 0 Then
			scissorDepth -= 1
			scissors[scissorDepth].Clear()
		End
		UpdateScissor()
	End
	
	Method UpdateScissor:Void()
		If scissorDepth > 0 Then
			If Not EmptyScissor() Then
				Local xRatio:Float = 1
				Local yRatio:Float = 1
				
				If useVirtualRes Then
					xRatio = SCREENX_RATIO
					yRatio = SCREENY_RATIO
				End
				
				Local sx:Float = scissors[scissorDepth-1].x * xRatio
				Local sy:Float = scissors[scissorDepth-1].y * yRatio
				Local sw:Float = scissors[scissorDepth-1].w * xRatio
				Local sh:Float = scissors[scissorDepth-1].h * yRatio
				
				If sx < 0 Then sx = 0
				If sy < 0 Then sy = 0
				If sx+sw < 0 Then sw = 0
				If sy+sh < 0 Then sh = 0
				
				If sx > DEVICE_WIDTH Then sx = DEVICE_WIDTH
				If sy > DEVICE_HEIGHT Then sy = DEVICE_HEIGHT
				If sx+sw > DEVICE_WIDTH Then sw = 0
				If sy+sh > DEVICE_HEIGHT Then sh = 0

				SetScissor(sx, sy, sw, sh)
			End
		Else
			SetScissor(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT)
		End
	End
	
	Method EmptyScissor:Bool()
		If scissorDepth <= 0 Then Return False
		Return scissors[scissorDepth-1].empty
	End
	
	Method DoMouse:Void(button:Int)
		Local absX:Int, absY:Int, style:ComponentStyle
		If MouseHit(button) Then
			mouseDown[button] = True
			mouseDownX[button] = mouseThisX
			mouseDownY[button] = mouseThisY
			mouseDownComponent[button] = mouseThisComponent
			
			' null safety check
			If mouseThisComponent <> Null Then
				' request the focus
				mouseThisComponent.RequestFocus()
				' fire pressed on mouseThisComponent
				absX = mouseThisComponent.AbsoluteX
				absY = mouseThisComponent.AbsoluteY
				style = mouseThisComponent.GetCurrentStyle()
				If style <> Null And style.downSound <> "" Then PlayComponentSound(mouseThisComponent, style.downSound)
				mouseThisComponent.FireMousePressed(mouseThisComponent, mouseThisX-absX, mouseThisY-absY, button, mouseThisX, mouseThisY)
				' bring the component to front
				mouseThisComponent.BringToFront()
				' set mouseDown
				mouseThisComponent.mouseDown = True
			End
			
		ElseIf mouseDown[button] Then
			' if we released the button
			If Not MouseDown(button) Then
				mouseDown[button] = False
				Local comp:Component = mouseDownComponent[button]
				mouseDownComponent[button] = Null 
				
				' null safety check
				If comp <> Null Then
					' fire mouse released on comp
					absX = comp.AbsoluteX
					absY = comp.AbsoluteY
					style = comp.GetCurrentStyle()
					If style <> Null And style.upSound <> "" Then PlayComponentSound(comp, style.upSound)
					comp.FireMouseReleased(comp, mouseThisX-absX, mouseThisY-absY, button, mouseThisX, mouseThisY)
					
					' clear mouseDown
					comp.mouseDown = False
					
					' if we released on the same component, fire mouse clicked
					If mouseThisComponent = comp Then
						style = comp.GetCurrentStyle()
						If style <> Null And style.clickSound <> "" Then PlayComponentSound(comp, style.clickSound)
						comp.FireMouseClicked(mouseThisComponent, mouseThisX-absX, mouseThisY-absY, button, mouseThisX, mouseThisY)
					End
				End
				
			ElseIf mouseLastX <> mouseThisX Or mouseLastY <> mouseThisY Then
				' null safety check
				If mouseDownComponent[button] <> Null Then
					' this check is only commented for now, because i'm not sure if the extra method calls every update will affect android
					' if the performance drops i'll have to rethink this part
					
					' fire mouse dragged on mouseDownComponent
					'If mouseDownComponent[button].MouseMotionListener <> Null Then
						absX = mouseDownComponent[button].AbsoluteX
						absY = mouseDownComponent[button].AbsoluteY
						mouseDownComponent[button].FireMouseDragged(mouseDownComponent[button], mouseThisX-absX, mouseThisY-absY, button, mouseThisX, mouseThisY)
					'End
				End
				
				' if the component changed, fire exit/enter
				If mouseThisComponent <> mouseLastComponent Then
					' null safety check
					If mouseLastComponent <> Null Then
						' fire mouse exited on mouseLastComponent
						absX = mouseLastComponent.AbsoluteX
						absY = mouseLastComponent.AbsoluteY
						style = mouseLastComponent.GetCurrentStyle()
						If style <> Null And style.exitSound <> "" Then PlayComponentSound(mouseLastComponent, style.exitSound)
						mouseLastComponent.FireMouseExited(mouseLastComponent, mouseThisX-absX, mouseThisY-absY, mouseThisComponent, mouseThisX, mouseThisY)
						
						' clear mouseHover
						mouseLastComponent.mouseHover = False
					End
					
					' null safety check
					If mouseThisComponent <> Null Then
						' fire mouse entered on mouseThisComponent
						absX = mouseThisComponent.AbsoluteX
						absY = mouseThisComponent.AbsoluteY
						style = mouseThisComponent.GetCurrentStyle()
						If style <> Null And style.enterSound <> "" Then PlayComponentSound(mouseThisComponent, style.enterSound)
						mouseThisComponent.FireMouseEntered(mouseThisComponent, mouseThisX-absX, mouseThisY-absY, mouseLastComponent, mouseThisX, mouseThisY)
						
						' set the STATE_HOVER bit
						mouseThisComponent.mouseHover = True
					End
				End
			End
		Else
			If mouseLastX <> mouseThisX Or mouseLastY <> mouseThisY Then
				' check is commented for the same reason as above
				' fire mouse moved on mouseThisComponent
				If mouseThisComponent <> Null Then 'And mouseThisComponent.MouseMotionListener <> Null Then
					absX = mouseThisComponent.AbsoluteX
					absY = mouseThisComponent.AbsoluteY
					mouseThisComponent.FireMouseMoved(mouseThisComponent, mouseThisX-absX, mouseThisY-absY, mouseThisX, absY)
				End
				
				' if the component changed, fire exit/enter
				If mouseThisComponent <> mouseLastComponent Then
					' fire mouse exited on mouseLastComponent
					If mouseLastComponent <> Null Then
						absX = mouseLastComponent.AbsoluteX
						absY = mouseLastComponent.AbsoluteY
						style = mouseLastComponent.GetCurrentStyle()
						If style <> Null And style.exitSound <> "" Then PlayComponentSound(mouseLastComponent, style.exitSound)
						mouseLastComponent.FireMouseExited(mouseLastComponent, mouseThisX-absX, mouseThisY-absY, mouseThisComponent, mouseThisX, mouseThisY)
						
						' clear mouseHover
						mouseLastComponent.mouseHover = False
					End
					
					' fire mouse entered on mouseThisComponent
					If mouseThisComponent <> Null Then
						absX = mouseThisComponent.AbsoluteX
						absY = mouseThisComponent.AbsoluteY
						style = mouseThisComponent.GetCurrentStyle()
						If style <> Null And style.enterSound <> "" Then PlayComponentSound(mouseThisComponent, style.enterSound)
						mouseThisComponent.FireMouseEntered(mouseThisComponent, mouseThisX-absX, mouseThisY-absY, mouseLastComponent, mouseThisX, mouseThisY)
						' set mouseHover
						mouseThisComponent.mouseHover = True
					End
				End
			End
		End
	End
	
Public
' Properties
	' LayoutEnabled is read/write
	Method LayoutEnabled:Bool() Property
		Return layoutEnabled
	End
	Method LayoutEnabled:Void(layoutEnabled:Bool) Property
		If layoutEnabled <> Self.layoutEnabled Then
			Self.layoutEnabled = layoutEnabled
			If layoutEnabled Then
				desktop.Layout()
			End
		End
	End
	
	' Desktop is read only
	Method Desktop:GUIDesktop() Property
		Return desktop
	End
	
	' UseVirtualResolution is read/write
	Method UseVirtualResolution:Bool() Property
		Return useVirtualRes
	End
	Method UseVirtualResolution:Void(useVirtualResolution:Bool) Property
		If Self.useVirtualRes And Not useVirtualResolution Then
			Self.useVirtualRes = useVirtualResolution
			desktop.SetBounds(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT)
		ElseIf Not Self.useVirtualRes And useVirtualResolution Then
			Self.useVirtualRes = useVirtualResolution
			desktop.SetBounds(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)
		End
	End
	
	' CurrentFocus is read/write (only use write to set null, use RequestFocus on the component instead)
	Method CurrentFocus:Component() Property
		Return currentFocus
	End
	Method CurrentFocus:Void(currentFocus:Component) Property
		AssertNull(currentFocus, "Writing to the CurrentFocus property should only be used for clearing it!")
		Self.currentFocus = Null
	End
	
	' SkinDocument is read only (use LoadSkin)
	Method SkinDocument:XMLDocument() Property
		Return skinDoc
	End
	
	' SkinAtlas is read only (use LoadSkin)
	Method SkinAtlas:GameImage() Property
		Return skinAtlas
	End
	
' Constructors
	Method New()
		desktop = New GUIDesktop(Self)
		desktop.SetBounds(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT)
		For Local i:Int = 0 Until scissors.Length
			scissors[i] = New Rectangle
		Next
	End
	
' Public methods
	Method LoadSkin:Void(doc:XMLDocument)
		Local atlas:String = doc.Root.GetAttribute("atlas","")
		skinAtlas = diddyGame.images.Load(atlas,,False)
		skinDoc = doc
		ApplySkin()
	End
	
	Method ApplySkin:Void()
		If desktop <> Null Then desktop.ApplySkin()
	End
	
	Method Draw:Void()
		If Not useVirtualRes Then
			PushMatrix
			SetMatrix(1,0,0,1,0,0)
		End
		desktop.Draw(Self)
		scissorDepth = 0
		SetScissor(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT)
		If Not useVirtualRes Then PopMatrix
	End
	
	Method ComponentAtPoint:Component(x:Int, y:Int, parent:Component=Null)
		' if no parent, it's the desktop
		If parent = Null Then parent = desktop
		' if the mouse is outside the component, return null
		If x<0 Or y<0 Or x >= parent.Width Or y >= parent.Height Then Return Null

		' check if it's inside a child (reverse, to honour z-order)
		Local rv:Component = Null
		For Local i:Int = parent.ChildrenZOrder.Size-1 To 0 Step -1
			Local c:Component = parent.ChildrenZOrder.Get(i)
			If c.Visible Then
				rv = ComponentAtPoint(x-c.X, y-c.Y, c)
			End
			If rv <> Null Then Return rv
		Next
		' not inside a child, so it's this one
		Return parent
	End

	Method Update:Void()
		mouseLastX = mouseThisX
		mouseLastY = mouseThisY
		mouseLastComponent = mouseThisComponent
		If useVirtualRes Then
			mouseThisX = diddyGame.mouseX
			mouseThisY = diddyGame.mouseY
		Else
			mouseThisX = MouseX()
			mouseThisY = MouseY()
		End
		Local cap:Component = ComponentAtPoint(mouseThisX, mouseThisY)
		If cap <> Null Then mouseThisComponent = cap
		DoMouse(MOUSE_LEFT)
		DoMouse(MOUSE_MIDDLE)
		DoMouse(MOUSE_RIGHT)
	End
	
	Method SetFocus:Void(comp:Component)
		If currentFocus <> Null Then
			 currentFocus.FireFocusLost(currentFocus, comp)
		End
		comp.focusedChild = Null
		Local current:Component = comp
		While current.Parent <> Null
			current.BringToFront()
			current.Parent.focusedChild = current
			current = current.Parent
		End
		Local oldFocus:Component = currentFocus
		currentFocus = comp
		If currentFocus <> Null Then
			 currentFocus.FireFocusGained(currentFocus, oldFocus)
		End
	End
	
	Method GetSkinNode:XMLElement(nodeName:String)
		If skinDoc = Null Then Return Null
		If nodeName = "" Then Return Null
		Local node:XMLElement = Null
		For Local i:Int = 0 Until skinDoc.Root.Children.Size
			node = skinDoc.Root.Children.Get(i)
			If node.Name = nodeName Then Return node
		Next
		AssertError("Couldn't find skin node with name "+nodeName)
		Return Null
	End
	
	' developer should override this to do anything useful!!!
	Method ActionPerformed:Void(source:Component, action:String)
	End
End ' Class GUI

Function PlayComponentSound:Void(comp:Component, soundName:String)
	' TODO: play sounds!
End