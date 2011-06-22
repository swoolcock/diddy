' By default, all public actions get sent to the GUI instance (which implements IActionListener).
' You can assign individual IActionListeners to appropriate components (buttons, sliders, etc.)

Import mojo
Import diddy

Const ACTION_CLICKED:String = "clicked"
Const ACTION_VALUE_CHANGED:String = "changed"

' used for scissors
Class Rectangle
	Field x:Float, y:Float, w:Float, h:Float
	Field empty:Bool = False
	
	Method New(x:Float, y:Float, w:Float, h:Float)
		Set(x, y, w, h)
	End
	
	Method Set:Void(x:Float, y:Float, w:Float, h:Float)
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
	
	Method Intersect:Void(x:Float, y:Float, w:Float, h:Float)
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
End

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
	Method MousePressed:Void(source:Component, x:Float, y:Float, button:Int, absoluteX:Float, absoluteY:Float)
	Method MouseReleased:Void(source:Component, x:Float, y:Float, button:Int, absoluteX:Float, absoluteY:Float)
	Method MouseClicked:Void(source:Component, x:Float, y:Float, button:Int, absoluteX:Float, absoluteY:Float)
	Method MouseEntered:Void(source:Component, x:Float, y:Float, exitedComp:Component, absoluteX:Float, absoluteY:Float)
	Method MouseExited:Void(source:Component, x:Float, y:Float, enteredComp:Component, absoluteX:Float, absoluteY:Float)
End

Interface IMouseMotionListener
	Method MouseMoved:Void(source:Component, x:Float, y:Float, absoluteX:Float, absoluteY:Float)
	Method MouseDragged:Void(source:Component, x:Float, y:Float, button:Int, absoluteX:Float, absoluteY:Float)
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
	Method MousePressed:Void(source:Component, x:Float, y:Float, button:Int, absoluteX:Float, absoluteY:Float)
	End
	Method MouseReleased:Void(source:Component, x:Float, y:Float, button:Int, absoluteX:Float, absoluteY:Float)
	End
	Method MouseClicked:Void(source:Component, x:Float, y:Float, button:Int, absoluteX:Float, absoluteY:Float)
	End
	Method MouseEntered:Void(source:Component, x:Float, y:Float, exitedComp:Component, absoluteX:Float, absoluteY:Float)
	End
	Method MouseExited:Void(source:Component, x:Float, y:Float, enteredComp:Component, absoluteX:Float, absoluteY:Float)
	End
	Method MouseMoved:Void(source:Component, x:Float, y:Float, absoluteX:Float, absoluteY:Float)
	End
	Method MouseDragged:Void(source:Component, x:Float, y:Float, button:Int, absoluteX:Float, absoluteY:Float)
	End
End

Class AbstractKeyAdapter Implements IKeyListener Abstract
	Method KeyPressed:Void(source:Component, keychar:String, keycode:Int)
	End
	Method KeyReleased:Void(source:Component, keychar:String, keycode:Int)
	End
	Method KeyRepeated:Void(source:Component, keychar:String, keycode:Int)
	End
	Method KeyTyped:Void(source:Component, keychar:String, keycode:Int)
	End
End

Class AbstractFocusAdapter Implements IFocusListener Abstract
	Method FocusGained:Void(source:Component, oldFocus:Component)
	End
	Method FocusLost:Void(source:Component, newFocus:Component)
	End
End

' Top level GUI class.  All public actions from components on the desktop get forwarded here
' unless an ActionListener is explicitly set for that component.
Class GUI Implements IActionListener
	Field desktop:Desktop
	Field scissors:Rectangle[] = New Rectangle[128]
	Field scissorDepth:Int = 0
	
	Field mouseDown:Bool[3]
	Field mouseDownX:Float[3]
	Field mouseDownY:Float[3]
	Field mouseDownComponent:Component[3]
	
	Field mouseLastX:Float
	Field mouseLastY:Float
	Field mouseLastComponent:Component
	Field mouseThisX:Float
	Field mouseThisY:Float
	Field mouseThisComponent:Component
	
	Field useVirtualRes:Bool = False
	
	Field currentFocus:Component = Null
	
	Method New()
		desktop = New Desktop(Self)
		desktop.SetBounds(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)
		For Local i:Int = 0 Until scissors.Length
			scissors[i] = New Rectangle
		Next
	End
	
	Method PushScissor:Void(x:Float, y:Float, w:Float, h:Float)
		' don't use assert, for speed on android (one less method call)
		If scissorDepth >= scissors.Length Then Error("GUI.PushScissor: Out of space for scissors.")
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
	
	Method Draw(useVirtualRes:Bool = False)
		Self.useVirtualRes = useVirtualRes
		desktop.Draw(Self)
		scissorDepth = 0
		SetScissor(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT)
	End
	
	Method ComponentAtPoint:Component(x:Float, y:Float, parent:Component=Null)
		' if no parent, it's the desktop
		If parent = Null Then parent = desktop
		' if the mouse is outside the component, return null
		If x<0 Or y<0 Or x >= parent.w Or y >= parent.h Then Return Null

		' check if it's inside a child (reverse, to honour z-order)
		Local rv:Component = Null
		For Local i:Int = parent.children.Size-1 To 0 Step -1
			Local c:Component = parent.children.Get(i)
			If c.visible Then
				rv = ComponentAtPoint(x-c.x, y-c.y, c)
			End
			If rv <> Null Then Return rv
		Next
		' not inside a child, so it's this one
		Return parent
	End

	Method GetAbsoluteX:Float(comp:Component)
		Local rv:Float = comp.x
		While comp.parent <> Null
			comp = comp.parent
			rv += comp.x
		Wend
		Return rv
	End
	
	Method GetAbsoluteY:Float(comp:Component)
		Local rv:Float = comp.y
		While comp.parent <> Null
			comp = comp.parent
			rv += comp.y
		Wend
		Return rv
	End
	
	Method Update:Void()
		mouseLastX = mouseThisX
		mouseLastY = mouseThisY
		mouseLastComponent = mouseThisComponent
		If useVirtualRes Then
			mouseThisX = game.mouseX
			mouseThisY = game.mouseY
		Else
			mouseThisX = MouseX()
			mouseThisY = MouseY()
		End
		mouseThisComponent = ComponentAtPoint(mouseThisX, mouseThisY)
		DoMouse(MOUSE_LEFT)
		DoMouse(MOUSE_MIDDLE)
		DoMouse(MOUSE_RIGHT)
	End
	
	Method DoMouse:Void(button:Int)
		Local absX:Float, absY:Float
		If MouseHit(button) Then
			mouseDown[button] = True
			mouseDownX[button] = mouseThisX
			mouseDownY[button] = mouseThisY
			mouseDownComponent[button] = mouseThisComponent
			' fire pressed on mouseThisComponent
			If mouseThisComponent.mouseListener <> Null Then
				absX = GetAbsoluteX(mouseThisComponent)
				absY = GetAbsoluteY(mouseThisComponent)
				mouseThisComponent.mouseListener.MousePressed(mouseThisComponent, mouseThisX-absX, mouseThisY-absY, button, mouseThisX, mouseThisY)
			End
			mouseThisComponent.BringToFront()
			' set mouseDown
			mouseThisComponent.mouseDown = True
			
		ElseIf mouseDown[button] Then
			' if we released the button
			If Not MouseDown(button) Then
				mouseDown[button] = False
				Local comp:Component = mouseDownComponent[button]
				mouseDownComponent[button] = Null 
				
				' fire mouse released on comp
				If comp.mouseListener <> Null Then
					absX = GetAbsoluteX(comp)
					absY = GetAbsoluteY(comp)
					comp.mouseListener.MouseReleased(comp, mouseThisX-absX, mouseThisY-absY, button, mouseThisX, mouseThisY)
				End
				
				' clear mouseDown
				comp.mouseDown = False
				
				' if we released on the same component, fire mouse clicked
				If mouseThisComponent = comp Then
					If comp.mouseListener <> Null Then comp.mouseListener.MouseClicked(mouseThisComponent, mouseThisX-absX, mouseThisY-absY, button, mouseThisX, mouseThisY)
				End
				
			ElseIf mouseLastX <> mouseThisX Or mouseLastY <> mouseThisY Then
				' fire mouse dragged on mouseDownComponent
				If mouseDownComponent[button].mouseMotionListener <> Null Then
					absX = GetAbsoluteX(mouseDownComponent[button])
					absY = GetAbsoluteY(mouseDownComponent[button])
					mouseDownComponent[button].mouseMotionListener.MouseDragged(mouseDownComponent[button], mouseThisX-absX, mouseThisY-absY, button, mouseThisX, mouseThisY)
				End
				
				' if the component changed, fire exit/enter
				If mouseThisComponent <> mouseLastComponent Then
					' fire mouse exited on mouseLastComponent
					If mouseLastComponent.mouseListener <> Null Then
						absX = GetAbsoluteX(mouseLastComponent)
						absY = GetAbsoluteY(mouseLastComponent)
						mouseLastComponent.mouseListener.MouseExited(mouseLastComponent, mouseThisX-absX, mouseThisY-absY, mouseThisComponent, mouseThisX, mouseThisY)
					End
					
					' clear mouseHover
					mouseLastComponent.mouseHover = False
					
					' fire mouse entered on mouseThisComponent
					If mouseThisComponent.mouseListener <> Null Then
						absX = GetAbsoluteX(mouseThisComponent)
						absY = GetAbsoluteY(mouseThisComponent)
						mouseThisComponent.mouseListener.MouseEntered(mouseThisComponent, mouseThisX-absX, mouseThisY-absY, mouseLastComponent, mouseThisX, mouseThisY)
					End
					
					' set the STATE_HOVER bit
					mouseThisComponent.mouseHover = True
				End
			End
		Else
			If mouseLastX <> mouseThisX Or mouseLastY <> mouseThisY Then
				' fire mouse moved on mouseThisComponent
				If mouseThisComponent <> Null And mouseThisComponent.mouseMotionListener <> Null Then
					absX = GetAbsoluteX(mouseThisComponent)
					absY = GetAbsoluteY(mouseThisComponent)
					mouseThisComponent.mouseMotionListener.MouseMoved(mouseThisComponent, mouseThisX-absX, mouseThisY-absY, mouseThisX, absY)
				End
				
				' if the component changed, fire exit/enter
				If mouseThisComponent <> mouseLastComponent Then
					' fire mouse exited on mouseLastComponent
					If mouseLastComponent <> Null Then
						If mouseLastComponent.mouseListener <> Null Then
							absX = GetAbsoluteX(mouseLastComponent)
							absY = GetAbsoluteY(mouseLastComponent)
							mouseLastComponent.mouseListener.MouseExited(mouseLastComponent, mouseThisX-absX, mouseThisY-absY, mouseThisComponent, mouseThisX, mouseThisY)
						End
						
						' clear mouseHover
						mouseLastComponent.mouseHover = False
					End
					
					' fire mouse entered on mouseThisComponent
					If mouseThisComponent <> Null Then
						If mouseThisComponent.mouseListener <> Null Then
							absX = GetAbsoluteX(mouseThisComponent)
							absY = GetAbsoluteY(mouseThisComponent)
							mouseThisComponent.mouseListener.MouseEntered(mouseThisComponent, mouseThisX-absX, mouseThisY-absY, mouseLastComponent, mouseThisX, mouseThisY)
						End
						' set mouseHover
						mouseThisComponent.mouseHover = True
					End
				End
			End
		End
	End
	
	Method SetFocus:Void(comp:Component)
		If currentFocus <> Null And currentFocus.focusListener <> Null Then
			 currentFocus.focusListener.FocusLost(currentFocus, comp)
		End
		comp.focusedChild = Null
		Local current:Component = comp
		While current.parent <> Null
			current.BringToFront()
			current.parent.focusedChild = current
			current = current.parent
		End
		Local oldFocus:Component = currentFocus
		currentFocus = comp
		If currentFocus <> Null And currentFocus.focusListener <> Null Then
			 currentFocus.focusListener.FocusGained(currentFocus, oldFocus)
		End
	End
	
	' developer should override this to do anything useful!!!
	Method ActionPerformed:Void(source:Component, action:String)
	End
End

Class Desktop Extends Component
	Field restrictWindows:Bool = True
	Field parentGUI:GUI
	Method New(parentGUI:GUI)
		Super.New(Null)
		Self.parentGUI = parentGUI
	End
End

Class Component
Private
	Field alpha:Float = 1
	Field children:ArrayList<Component> = New ArrayList<Component>
	Field focusedChild:Component
	
	Field mouseListener:IMouseListener
	Field mouseMotionListener:IMouseMotionListener
	Field keyListener:IKeyListener
	Field focusListener:IFocusListener
	Field actionListener:IActionListener
	
	Field mouseHover:Bool = False
	Field mouseDown:Bool = False
	
	Field styleNormal:ComponentStyle = Null
	
	Method RequestFocusDelegate:Bool(thisGUI:GUI)
		' check the last focused child
		If focusedChild <> Null Then
			' check focusable first to save a method call
			If focusedChild.focusable Then
				thisGui.SetFocus(focusedChild)
				Return True
			End
			' recurse
			If focusedChild.RequestFocusDelegate(thisGUI) Then Return True
		End
		' find first focusable child
		For Local i:Int = 0 Until children.Size
			Local child:Component = children.Get(i)
			If child.focusable Then
				thisGui.SetFocus(child)
				Return True
			End
		Next
		' request focus on the children
		For Local i:Int = 0 Until children.Size
			Local child:Component = children.Get(i)
			If child <> focusedChild And child.RequestFocusDelegate(thisGUI) Then Return True
		Next
		' we still couldn't focus
		Return False
	End
	
Public
	Field parent:Component
	
	Field x:Float, y:Float
	Field w:Float, h:Float
	Field w2:Float, h2:Float
	Field visible:Bool = True
	Field enabled:Bool = True
	Field focusable:Bool = False
	Field zOrderLocked:Bool = False
	
	Method ActionListener:Void(actionListener:IActionListener) Property
		Self.actionListener = actionListener
	End
	
	Method ActionListener:IActionListener() Property
		Return Self.actionListener
	End
	
	Method MouseListener:Void(mouseListener:IMouseListener) Property
		Self.mouseListener = mouseListener
	End

	Method MouseListener:IMouseListener() Property
		Return Self.mouseListener
	End

	Method MouseMotionListener:Void(mouseMotionListener:IMouseMotionListener) Property
		Self.mouseMotionListener = mouseMotionListener
	End

	Method MouseMotionListener:IMouseMotionListener() Property
		Return Self.mouseMotionListener
	End
	
	Method KeyListener:Void(keyListener:IKeyListener) Property
		Self.keyListener = keyListener
	End

	Method KeyListener:IKeyListener() Property
		Return Self.keyListener
	End

	Method FocusListener:Void(focusListener:IFocusListener) Property
		Self.focusListener = focusListener
	End

	Method FocusListener:IFocusListener() Property
		Return Self.focusListener
	End

	Method StyleNormal:ComponentStyle() Property
		If styleNormal = Null Then styleNormal = New ComponentStyle
		Return styleNormal
	End

	Method StyleNormal:Void(style:ComponentStyle) Property
		AssertNotNull(style, "StyleNormal may not be null.")
		styleNormal = style
	End
	
	Method Focusable:Bool() Property
		Return focusable
	End
	
	Method Focusable:Void(focusable:Bool) Property
		Self.focusable = focusable
	End
	
	Method Focused:Bool() Property
		If parent = Null Then Return False
		Return parent.focusedChild = Self
	End
	
	Method GetStyle:ComponentStyle(name:String)
		If name = "normal" Then Return styleNormal
		Return Null
	End
	
	Method SetStyle:Void(name:String, style:ComponentStyle)
		If name = "normal" Then styleNormal = style
	End
	
	Method New(parent:Component)
		styleNormal = New ComponentStyle
		' if this isn't the desktop, it must have a parent
		If Not Desktop(Self) Then
			AssertNotNull(parent, "Components must have a parent.")
			Self.parent = parent
			parent.children.Add(Self)
		Else
			styleNormal.drawBackground = False
		End
		AddNotify()
	End

	Method CheckImage()
		If styleNormal.image <> null
			If styleNormal.image.midhandled
				Error "Images can not be midhandled for GUI components"
			End
		End	
		If styleNormal.downImage <> null
			If styleNormal.downImage.midhandled
				Error "Images can not be midhandled for GUI components"
			End
		End
	End
	
	Method Alpha:Float() Property
		Return alpha
	End
	
	Method Alpha:Void(alpha:Float) Property
		Self.alpha = alpha
		If Self.alpha < 0 Then Self.alpha = 0
		If Self.alpha > 1 Then Self.alpha = 1
	End
	
	Method SetBackground:Void(red:Float, green:Float, blue:Float)
		If red < 0 Then red = 0
		If red > 255 Then red = 255
		If green < 0 Then green = 0
		If green > 255 Then green = 255
		If blue < 0 Then blue = 0
		If blue > 255 Then blue = 255
		styleNormal.red = red
		styleNormal.green = green
		styleNormal.blue = blue
		styleNormal.drawBackground = True
	End
	
	Method SetBackground:Void(drawBackground:Bool)
		styleNormal.drawBackground = drawBackground
	End
	
	Method SetLocation:Void(x:Float, y:Float)
		Self.x = x
		Self.y = y
		Layout()
	End
	
	Method SetSize:Void(w:Float, h:Float)
		Self.w = w
		Self.h = h
		Self.w2 = w / 2
		Self.h2 = h / 2
		Layout()
	End
	
	Method SetBounds:Void(x:Float, y:Float, w:Float, h:Float)
		Self.x = x
		Self.y = y
		Self.w = w
		Self.h = h
		Layout()
	End
	
	Method Draw:Void(parentGui:GUI, alpha:Float = 1, absx:Float = 0, absy:Float = 0)
		If visible Then
			parentGui.PushScissor(absx, absy, w, h)
			If Not parentGui.EmptyScissor() Then
				SetAlpha(alpha)
				DrawComponent()
				DrawChildren(parentGui, alpha, absx, absy)
			End
			parentGui.PopScissor()
		End
	End
	
	Method DrawChildren:Void(parentGui:GUI, alpha:Float = 1, absx:Float, absy:Float)
		For Local c:Component = EachIn children
			PushMatrix()
			Translate(c.x, c.y)
			c.Draw(parentGui, c.alpha * alpha, absx + c.x, absy + c.y)
			PopMatrix()
		Next
	End

	Method DrawComponent:Void()
		Local style:ComponentStyle = GetCurrentStyle()
		If style <> Null Then
			' background colour first
			If style.drawBackground Then
				SetColor(style.red, style.green, style.blue)
				SetAlpha(alpha)
				DrawRect(0, 0, w, h)
			End
			
			' image next, priority = down, hover, normal
			If mouseDown And style.downImage <> Null Then
				SetColor(255,255,255)
				SetAlpha(alpha)
				If style.downImageMode = ComponentStyle.IMAGE_GRID Then
					style.downImage.DrawGrid(0, 0, w, h, style.downImageFrame)
				ElseIf style.downImageMode = ComponentStyle.IMAGE_NORMAL Then
					style.downImage.Draw(0, 0, 0, 1, 1, style.downImageFrame)
				End
			ElseIf mouseHover And style.hoverImage <> Null Then
				SetColor(255,255,255)
				SetAlpha(alpha)
				If style.hoverImageMode = ComponentStyle.IMAGE_GRID Then
					style.hoverImage.DrawGrid(0, 0, w, h, style.hoverImageFrame)
				ElseIf style.hoverImageMode = ComponentStyle.IMAGE_NORMAL Then
					style.hoverImage.Draw(0, 0, 0, 1, 1, style.hoverImageFrame)
				End
			ElseIf style.image <> Null Then
				SetColor(255,255,255)
				SetAlpha(alpha)
				If style.imageMode = ComponentStyle.IMAGE_GRID Then
					style.image.DrawGrid(0, 0, w, h, style.imageFrame)
				ElseIf style.imageMode = ComponentStyle.IMAGE_NORMAL Then
					style.image.Draw(0, 0, 0, 1, 1, style.imageFrame)
				End
			End
			
			' reset stuff
			SetColor(255,255,255)
			SetAlpha(1)
		End
	End
	
	Method GetCurrentStyle:ComponentStyle()
		Return styleNormal
	End
	
	Method Dispose:Void(recursing:Bool = False)
		' we do an empty check first to save creating an enumerator object
		If Not children.IsEmpty() Then
			Local enum:AbstractEnumerator<Component> = children.Enumerator()
			While enum.HasNext()
				Local c:Component = enum.NextObject()
				c.Dispose(True)
				enum.Remove()
			End
		End
		DisposeNotify()
		Local p:Component = Self.parent
		If p.focusedChild = Self Then p.focusedChild = Null
		Local thisGui:GUI = FindGUI()
		If thisGui.currentFocus = Self Then thisGui.currentFocus = Null
		Self.parent = Null
		If Not recursing Then p.children.Remove(Self)
	End
	
	Method AddNotify:Void()
	End
	
	Method DisposeNotify:Void()
	End
	
	Method Layout:Void()
	End
	
	Method FireActionPerformed:Void(action:String)
		Local al:IActionListener = actionListener
		If al = Null Then al = FindActionTarget()
		If al <> Null Then al.ActionPerformed(Self, action)
		' if al is null here, something is seriously wrong!!!
	End
	
	'FIXME: Shouldn't need Object casts for interfaces
	Method FindActionTarget:IActionListener()
		' traverse up the hierarchy and find the closest ActionListener to receive the actions
		Local comp:Component = Self
		While comp <> Null And Desktop(comp) = Null And IActionListener(Object(comp)) = Null
			comp = comp.parent
		End
		If Desktop(comp) <> Null Then Return Desktop(comp).parentGUI
		Return IActionListener(Object(comp))
	End
	
	' Tries to make this component the focused one.
	' If it is focusable, make that the new focus.
	' If it is NOT focusable, we check the last focused child to see if that is focusable. If it is, make it the new focus.
	' If the last focused child isn't focusable, we call RequestFocus on that
	' If RequestFocus failed, we set the focus to the first focusable child
	' If no focusable children, we call RequestFocus on all children in order until we succeed (skipping the last focused child)
	' If those requests failed, we set the focus to the first focusable parent.
	' Returns true if this component or a child received the focus.
	Method RequestFocus:Bool()
		Local thisGui:GUI = FindGUI()
		' if this component is focusable...
		If focusable Then
			thisGui.SetFocus(Self)
			Return True
		End
		' otherwise, call the delegate
		If RequestFocusDelegate(thisGui) Then Return True
		' if we couldn't focus, go through the parent hierarchy
		Local comp:Component = Self.parent
		While comp <> Null And Not comp.focusable
			comp = comp.parent
		End
		' if we hit the top level, we can't focus
		If comp = Null Then Return False
		
		thisGui.SetFocus(comp)
		Return True
	End
	
	Method FindGUI:GUI()
		Local comp:Component = Self
		While comp.parent <> Null
			comp = comp.parent
		End
		If Desktop(comp) <> Null Then Return Desktop(comp).parentGUI
		Return Null
	End
	
	Method BringToFront:Void()
		If parent = Null Then Return
		If parent.children.Size > 1 And Not zOrderLocked Then
			parent.children.Remove(Self)
			parent.children.Add(Self)
		End
		parent.BringToFront()
	End
	
	Method SendToBack:Void()
		If parent = Null Then Return
		If parent.children.Size > 1 And Not zOrderLocked Then
			parent.children.Remove(Self)
			parent.children.AddFirst(Self)
		End
		parent.SendToBack()
	End
End

Class ComponentStyle
	Global IMAGE_NORMAL:Int = 0
	Global IMAGE_TILE:Int = 1
	Global IMAGE_STRETCH:Int = 2
	Global IMAGE_GRID:Int = 3
	
	Field drawBackground:Bool = True
	Field red:Int = 255
	Field green:Int = 255
	Field blue:Int = 255
	Field image:GameImage = Null
	Field imageFrame:Int = 0
	Field imageMode:Int = IMAGE_NORMAL
	Field imageAlignX:Float = 0
	Field imageAlignY:Float = 0
	Field hoverImage:GameImage = Null
	Field hoverImageFrame:Int = 0
	Field hoverImageMode:Int = IMAGE_NORMAL
	Field hoverImageAlignX:Float = 0
	Field hoverImageAlignY:Float = 0
	Field downImage:GameImage = Null
	Field downImageFrame:Int = 0
	Field downImageMode:Int = IMAGE_NORMAL
	Field downImageAlignX:Float = 0
	Field downImageAlignY:Float = 0
End

Class Panel Extends Component
	Method New(parent:Component)
		Super.New(parent)
	End
End

Class Window Extends Component
Private
	Field contentPane:Panel
	Field titlePane:Panel
	Field buttonPane:Panel
	
	Field closeButton:Button
	Field maximizeButton:Button
	Field minimizeButton:Button
	Field shadeButton:Button
	Field internalWindowAdapter:InternalWindowAdapter
	
	Field titleHeight:Int = 22
	Field buttonWidth:Int = 15
	
	' note: a window can be all three of these states at once!
	' priority is: minimized, maximized, shaded
	Field maximized:Bool = False
	Field minimized:Bool = False
	Field shaded:Bool = False
	Field dragX:Float, dragY:Float, originalX:Float, originalY:Float
	Field dragging:Bool = False
	
	Field normalX:Float, normalY:Float, normalWidth:Float, normalHeight:Float

	Method CreateButtonPane:Void()
		buttonPane = New Panel(Self)
		buttonPane.w = buttonWidth*4
		buttonPane.SetBackground(192,192,192)
		'minimizeButton = New Button(buttonPane)
		'minimizeButton.actionListener = internalWindowAdapter
		'minimizeButton.SetBounds(0, 0, buttonWidth, buttonWidth)
		'shadeButton = New Button(buttonPane)
		'shadeButton.actionListener = internalWindowAdapter
		'shadeButton.SetBounds(0, 0, buttonWidth, buttonWidth)
		'maximizeButton = New Button(buttonPane)
		'maximizeButton.actionListener = internalWindowAdapter
		'maximizeButton.SetBounds(0, 0, buttonWidth, buttonWidth)
		closeButton = New Button(buttonPane)
		closeButton.actionListener = internalWindowAdapter
		closeButton.SetBounds(buttonPane.w-buttonWidth, 0, buttonWidth, buttonWidth)
		closeButton.SetBackground(128,128,128)
	End
	
	Method CreateContentPane:Void()
		contentPane = New Panel(Self)
		contentPane.SetBackground(224,224,224)
	End
	
	Method CreateTitlePane:Void()
		titlePane = New Panel(Self)
		titlePane.SetBackground(192,192,192)
		titlePane.mouseListener = internalWindowAdapter
		titlePane.mouseMotionListener = internalWindowAdapter
	End
Public
	Method ContentPane:Panel() Property
		Return contentPane
	End
	
	Method ContentPane:Void(contentPane:Panel) Property
		If Self.contentPane <> Null Then Self.contentPane.Dispose()
		Self.contentPane = contentPane
	End
	
	Method TitlePane:Panel() Property
		Return titlePane
	End
	
	Method ButtonPane:Panel() Property
		Return buttonPane
	End
	
	Method Maximized:Void(maximized:Bool) Property
		StoreWindowSize()
		Self.maximized = maximized
		UpdateWindowSize()
	End
	
	Method Maximized:Bool() Property
		Return maximized
	End
	
	Method Minimized:Void(minimized:Bool) Property
		StoreWindowSize()
		Self.minimized = minimized
		UpdateWindowSize()
	End
	
	Method Minimized:Bool() Property
		Return minimized
	End
	
	Method Shaded:Void(shaded:Bool) Property
		StoreWindowSize()
		Self.shaded = shaded
		UpdateWindowSize()
	End
	
	Method Shaded:Bool() Property
		Return shaded
	End
	
	Method StoreWindowSize:Void()
		If maximized Or minimized Then Return
		normalX = x
		normalY = y
		If Not shaded Then
			normalWidth = w
			normalHeight = h
		End
	End
	
	Method UpdateWindowSize:Void()
		If Not maximized And Not minimized And Not shaded Then
			SetBounds(normalX, normalY, normalWidth, normalHeight)
		ElseIf minimized Then
			SetBounds(0, 0, 50, titleHeight)
		ElseIf maximized Then
			SetBounds(0, 0, parent.w, parent.h)
		ElseIf shaded Then
			SetBounds(normalX, normalY, normalWidth, titleHeight)
		End
	End
	
	Method New()
		Super.New(Self)
		internalWindowAdapter = New InternalWindowAdapter(Self)
	End
	
	Method New(parent:Component)
		Super.New(parent)
		internalWindowAdapter = New InternalWindowAdapter(Self)
		CreateButtonPane()
		CreateContentPane()
		CreateTitlePane()
	End
	
	Method Layout:Void()
		If minimized Or shaded Then
			If contentPane <> Null Then contentPane.visible = False
		Else
			If contentPane <> Null Then
				contentPane.visible = True
				contentPane.SetBounds(4, titleHeight, w-8, h-titleHeight-4)
			End
		End
		buttonPane.SetBounds(w-buttonPane.w-4, 0, buttonPane.w, titleHeight)
		titlePane.SetBounds(4, 0, buttonPane.x-4, titleHeight)
	End
End

Class Label Extends Component
Private
	Field text:String
	Field textRed:Int, textGreen:Int, textBlue:Int
	Field textXOffset:Float = 0
	Field textYOffset:Float = 0
	Field textXAlign:Float = 0
	Field textYAlign:Float = 0

Public
	Method Text:Void(txt:String, xAlign:Float, yAlign:Float) Property
		text = txt
		textXAlign = xAlign
		textYAlign = yAlign
	End
	
	Method New(parent:Component)
		Super.New(parent)
	End
	
	Method DrawComponent:Void()
		Super.DrawComponent()
		If text.Length > 0 Then
			DrawText text, w*textXAlign+textXOffset, h*textYAlign+textYOffset, textXAlign, textYAlign
		End
	End
End

Class Button Extends Label
Private
	Field styleSelected:ComponentStyle = Null
	Field internalButtonAdapter:InternalButtonAdapter
	
Public
	Field selected:Bool
	Field toggle:Bool
	Field radioGroup:RadioGroup
	Field radioValue:String
	
	Method New(parent:Component)
		Super.New(parent)
		internalButtonAdapter = New InternalButtonAdapter(Self)
		mouseListener = internalButtonAdapter
	End
	
	Method New(parent:Component, image:GameImage)
		Super.New(parent)
		internalButtonAdapter = New InternalButtonAdapter(Self)
		mouseListener = internalButtonAdapter
		Self.StyleNormal.image = image
		Self.StyleNormal.drawBackground = False
		Self.SetSize(image.w, image.h)
		CheckImage()
	End
	
	Method New(parent:Component, image:GameImage, clickImage:GameImage)
		Super.New(parent)
		internalButtonAdapter = New InternalButtonAdapter(Self)
		mouseListener = internalButtonAdapter
		Self.StyleNormal.image = image
		Self.styleNormal.downImage = clickImage
		Self.StyleNormal.drawBackground = False
		Self.SetSize(image.w, image.h)
		CheckImage()
	End
	
	Method StyleSelected:ComponentStyle() Property
		If styleSelected = Null Then styleSelected = New ComponentStyle
		Return styleSelected
	End
	
	Method StyleSelected:Void(style:ComponentStyle) Property
		styleSelected = style
	End
	
	Method GetStyle:ComponentStyle(name:String)
		If name = "selected" Then Return styleSelected
		Return Super.GetStyle(name)
	End
	
	Method SetStyle:Void(name:String, style:ComponentStyle)
		If name = "selected" Then
			styleSelected = style
		Else
			Super.GetStyle(name)
		End
	End
	
	Method GetCurrentStyle:ComponentStyle()
		If selected And styleSelected <> Null Then Return styleSelected
		Return Super.GetCurrentStyle()
	End
End

Class RadioGroup
	Field buttons:ArrayList<Button> = New ArrayList<Button>
	Field currentValue:String
	
	Method SelectButton:String(button:Button)
		For Local b:Button = EachIn buttons
			b.selected = (b = button)
			If b.selected Then
				currentValue = b.radioValue
			End
		Next
		Return currentValue
	End
	
	Method SelectValue:Button(value:String)
		Local rv:Button = Null
		For Local b:Button = EachIn buttons
			b.selected = (b.radioValue = value)
			If b.selected Then
				currentValue = value
				rv = b
			End
		Next
		Return rv
	End
	
	Method AddButton:Void(button:Button, value:String)
		button.radioValue = value
		button.radioGroup = Self
		buttons.Add(button)
	End
	
	Method RemoveButton:Void(button:Button)
		button.radioValue = ""
		button.radioGroup = Null
		buttons.Remove(button)
	End
End

Class Slider Extends Component
	Const SLIDER_HORIZONTAL:Int = 0
	Const SLIDER_VERTICAL:Int = 1
	Const SLIDER_DIRECTION_TL_TO_BR:Int = 0 ' min is top or left, max is bottom or right
	Const SLIDER_DIRECTION_BR_TO_TL:Int = 1 ' min is bottom or right, max is top or left
Private
	Field buttonUpLeft:Button ' the button used for up and left
	Field buttonDownRight:Button ' the button used for down and right
	Field handle:Label
	Field bar:Label
	Field showButtons:Bool
	Field orientation:Int = SLIDER_HORIZONTAL
	Field direction:Int = SLIDER_DIRECTION_TL_TO_BR
	
	Field dragX:Int, dragY:Int, originalX:Int, originalY:Int
	Field dragging:Bool = False
	
	Field styleLeftButton:ComponentStyle
	Field styleRightButton:ComponentStyle
	Field styleTopButton:ComponentStyle
	Field styleBottomButton:ComponentStyle
	Field styleHorizontalHandle:ComponentStyle
	Field styleVerticalHandle:ComponentStyle
	Field styleHorizontalBar:ComponentStyle
	Field styleVerticalBar:ComponentStyle
	
	Field internalSliderAdapter:InternalSliderAdapter
	
Public
	Field minValue:Int = 0
	Field maxValue:Int = 100
	Field value:Int = 50
	Field tickInterval:Int = 10
	Field handleMargin:Int = 10
	Field handleSize:Int = 10
	Field buttonSize:Int = 15
	Field snapToTicks:Bool = True
	
	Method New(parent:Component)
		Super.New(parent)
		internalSliderAdapter = New InternalSliderAdapter(Self)
		bar = New Label(Self)
		bar.zOrderLocked = True
		bar.SetBackground(192,192,192)
		bar.mouseListener = internalSliderAdapter
		bar.mouseMotionListener = internalSliderAdapter
		buttonUpLeft = New Button(Self)
		buttonUpLeft.actionListener = internalSliderAdapter
		buttonUpLeft.SetBackground(128,128,128)
		buttonUpLeft.zOrderLocked = True
		buttonDownRight = New Button(Self)
		buttonDownRight.actionListener = internalSliderAdapter
		buttonDownRight.SetBackground(128,128,128)
		buttonDownRight.zOrderLocked = True
		handle = New Label(Self)
		handle.SetBackground(128,128,128)
		handle.mouseListener = internalSliderAdapter
		handle.mouseMotionListener = internalSliderAdapter
		handle.zOrderLocked = True
		buttonUpLeft.visible = False
		buttonDownRight.visible = False
	End
	
	Method GetStyle:ComponentStyle(name:String)
		If name = "leftButton" Then
			Return styleLeftButton
		ElseIf name = "rightButton" Then
			Return styleRightButton
		ElseIf name = "topButton" Then
			Return styleTopButton
		ElseIf name = "bottomButton" Then
			Return styleBottomButton
		ElseIf name = "horizontalHandle" Then
			Return styleHorizontalHandle
		ElseIf name = "verticalHandle" Then
			Return styleVerticalHandle
		ElseIf name = "horizontalBar" Then
			Return styleHorizontalBar
		ElseIf name = "verticalBar" Then
			Return styleVerticalBar
		End
		Return Super.GetStyle(name)
	End
	
	Method SetStyle:Void(name:String, style:ComponentStyle)
		If name = "leftButton" Then
			styleLeftButton = style
		ElseIf name = "rightButton" Then
			styleRightButton = style
		ElseIf name = "topButton" Then
			styleTopButton = style
		ElseIf name = "bottomButton" Then
			styleBottomButton = style
		ElseIf name = "horizontalHandle" Then
			styleHorizontalHandle = style
		ElseIf name = "verticalHandle" Then
			styleVerticalHandle = style
		ElseIf name = "horizontalBar" Then
			styleHorizontalBar = style
		ElseIf name = "verticalBar" Then
			styleVerticalBar = style
		Else
			Super.SetStyle(name, style)
		End
		UpdateStyles()
	End
	
	Method ShowButtons:Bool() Property
		Return showButtons
	End
	
	Method ShowButtons:Void(showButtons:Bool) Property
		If showButtons <> Self.showButtons Then
			Self.showButtons = showButtons
			Layout()
		End
		Self.showButtons = showButtons
	End
	
	Method Orientation:Int() Property
		Return orientation
	End
	
	Method Orientation:Void(orientation:Int) Property
		If Self.orientation <> orientation Then
			Self.orientation = orientation
			UpdateStyles()
			Layout()
		End
		Self.orientation = orientation
	End
	
	Method Direction:Int() Property
		Return direction
	End
	
	Method Direction:Void(direction:Int) Property
		If Self.direction <> direction Then
			Self.direction = direction
			Layout()
		End
		Self.direction = direction
	End
	
	Method UpdateStyles:Void()
		If orientation = SLIDER_HORIZONTAL Then
			buttonUpLeft.StyleNormal = styleLeftButton
			buttonDownRight.StyleNormal = styleRightButton
			handle.StyleNormal = styleHorizontalHandle
		Else
			buttonUpLeft.StyleNormal = styleTopButton
			buttonDownRight.StyleNormal = styleBottomButton
			handle.StyleNormal = styleVerticalHandle
		End
	End
	
	' TODO: adjust layout using xml offsets rather than hardcoded
	Method Layout:Void()
		If showButtons Then
			If orientation = SLIDER_HORIZONTAL Then
				buttonUpLeft.SetBounds(0, 0, buttonSize, Self.h)
				buttonDownRight.SetBounds(Self.w - buttonSize, 0, buttonSize, Self.h)
				bar.SetBounds(buttonUpLeft.w, 0, Self.w - buttonSize*2, Self.h)
			Else
				buttonUpLeft.SetBounds(0, 0, Self.w, buttonSize)
				buttonDownRight.SetBounds(0, Self.h - buttonSize, Self.w, buttonSize)
				bar.SetBounds(0, buttonUpLeft.h, Self.w, Self.h - buttonSize*2)
			End
			buttonUpLeft.visible = True
			buttonDownRight.visible = True
		Else
			buttonUpLeft.visible = False
			buttonDownRight.visible = False
		End
		Local startVal:Int = buttonSize+handleMargin
		Local endVal:Int = -buttonSize-handleMargin
		Local fraction:Float = Float(value-minValue)/Float(maxValue-minValue)
		Local currentVal:Int
		If orientation = SLIDER_HORIZONTAL Then
			endVal += Self.w
			currentVal = startVal + (endVal - startVal) * fraction
			handle.SetBounds(currentVal-handleSize/2, 0, handleSize, Self.h)
		Else
			endVal += Self.h
			currentVal = startVal + (endVal - startVal) * fraction
			handle.SetBounds(0, currentVal-handleSize/2, Self.w, handleSize)
		End
	End
	
	Method DoDrag:Int(mx:Int, my:Int)
		Local pos:Int, topLeft:Int = handleMargin, bottomRight:Int = -handleMargin
		If showButtons Then
			topLeft += buttonSize
			bottomRight -= buttonSize
		End
		If orientation = SLIDER_HORIZONTAL Then
			bottomRight += w
			pos = Min(Max(topLeft, mx), bottomRight)
		Else
			bottomRight += h
			pos = Min(Max(topLeft, my), bottomRight)
		End
		Local fraction:Float = Float(pos-topLeft) / Float(bottomRight-topLeft)
		If direction = SLIDER_DIRECTION_BR_TO_TL Then fraction = 1-fraction
		
		Local oldValue:Int = value
		value = SnapToValue(minValue + (maxValue - minValue)*fraction)
		
		' if it changed, update the layout and fire an event
		If value <> oldValue Then
			Layout()
			FireActionPerformed(ACTION_VALUE_CHANGED)
		End
	End
	
	Method SnapToValue:Int(val:Int)
		If val < minValue Then
			val = minValue
			Return val
		End
		If val > maxValue Then
			val = maxValue
			Return val
		End
		If val Mod tickInterval = 0 Then Return val
		If val Mod tickInterval < tickInterval / 2 Then
			val -= val Mod tickInterval
		Else
			val -= val Mod tickInterval
			val += tickInterval
		End
		Return val
	End
	
	Method AdjustValue:Bool(amount:Int)
		If amount = 0 Then Return
		Local oldValue:Int = value
		
		' snap if we must
		If value Mod tickInterval > 0 Then
			If amount < 0 Then
				value += tickInterval - (value Mod tickInterval)
			Else
				value -= value Mod tickInterval
			End
		End
		
		' adjust it
		value += amount * tickInterval

		' check that it's in range
		If value < minValue Then value = minValue
		If value > maxValue Then value = maxValue
		
		' if it changed, update the layout and fire an event
		If value <> oldValue Then
			Layout()
			FireActionPerformed(ACTION_VALUE_CHANGED)
		End
		Return value <> oldValue
	End
End

' private internal classes
Private

' handles all the internal events for the Slider component
Class InternalSliderAdapter Implements IActionListener, IMouseListener, IMouseMotionListener
	Field slider:Slider
	
	Method New(slider:Slider)
		Self.slider = slider
	End
	
	Method ActionPerformed:Void(source:Component, action:String)
		If source = slider.buttonUpLeft And action = ACTION_CLICKED Then
			If slider.direction = Slider.SLIDER_DIRECTION_TL_TO_BR Then
				slider.AdjustValue(-1)
			Else
				slider.AdjustValue(1)
			End
		ElseIf source = slider.buttonDownRight And action = ACTION_CLICKED Then
			If slider.direction = Slider.SLIDER_DIRECTION_TL_TO_BR Then
				slider.AdjustValue(1)
			Else
				slider.AdjustValue(-1)
			End
		End
	End
	
	Method MousePressed:Void(source:Component, x:Float, y:Float, button:Int, absoluteX:Float, absoluteY:Float)
		If slider.dragging Then Return
		slider.dragging = True
		If source = slider.handle Then
			slider.DoDrag(slider.handle.x + x, slider.handle.y + y)
		ElseIf source = slider.bar Then
			slider.DoDrag(slider.bar.x + x, slider.bar.y + y)
		End
	End
	
	Method MouseReleased:Void(source:Component, x:Float, y:Float, button:Int, absoluteX:Float, absoluteY:Float)
		slider.dragging = False
		If source = slider.handle Then
			slider.DoDrag(slider.handle.x + x, slider.handle.y + y)
		ElseIf source = slider.bar Then
			slider.DoDrag(slider.bar.x + x, slider.bar.y + y)
		End
	End
	
	Method MouseDragged:Void(source:Component, x:Float, y:Float, button:Int, absoluteX:Float, absoluteY:Float)
		If Not slider.dragging Then Return
		If source = slider.handle Then
			slider.DoDrag(slider.handle.x + x, slider.handle.y + y)
		ElseIf source = slider.bar Then
			slider.DoDrag(slider.bar.x + x, slider.bar.y + y)
		End
	End
	
	Method MouseClicked:Void(source:Component, x:Float, y:Float, button:Int, absoluteX:Float, absoluteY:Float)
	End
	
	Method MouseEntered:Void(source:Component, x:Float, y:Float, exitedComp:Component, absoluteX:Float, absoluteY:Float)
	End
	
	Method MouseExited:Void(source:Component, x:Float, y:Float, enteredComp:Component, absoluteX:Float, absoluteY:Float)
	End
	
	Method MouseMoved:Void(source:Component, x:Float, y:Float, absoluteX:Float, absoluteY:Float)
	End
End

' handles all the internal events for the Window component
Class InternalWindowAdapter Implements IActionListener, IMouseListener, IMouseMotionListener
	Field window:Window
	
	Method New(window:Window)
		Self.window = window
	End
	
	Method ActionPerformed:Void(source:Component, action:String)
		If source = window.closeButton And action = ACTION_CLICKED Then
			window.Dispose()
		ElseIf source = window.maximizeButton And action = ACTION_CLICKED Then
		ElseIf source = window.minimizeButton And action = ACTION_CLICKED Then
		ElseIf source = window.shadeButton And action = ACTION_CLICKED Then
		End
	End
	
	Method MousePressed:Void(source:Component, x:Float, y:Float, button:Int, absoluteX:Float, absoluteY:Float)
		If window.dragging Then Return
		If window.maximized Or window.minimized Then Return
		window.dragging = True
		window.dragX = absoluteX
		window.dragY = absoluteY
		window.originalX = window.x
		window.originalY = window.y
	End
	
	Method MouseReleased:Void(source:Component, x:Float, y:Float, button:Int, absoluteX:Float, absoluteY:Float)
		window.dragging = False
	End
	
	Method MouseDragged:Void(source:Component, x:Float, y:Float, button:Int, absoluteX:Float, absoluteY:Float)
		If window.maximized Or window.minimized Then window.dragging = False
		If Not window.dragging Then Return
		Local dx:Float = absoluteX-window.dragX, dy:Float = absoluteY-window.dragY
		Local newX:Float = window.originalX + dx, newY:Float = window.originalY + dy
		
		If Desktop(window.parent) <> Null And Desktop(window.parent).restrictWindows Then
			If newX + window.w > window.parent.w Then newX = window.parent.w - window.w
			If newY + window.h > window.parent.h Then newY = window.parent.h - window.h
			If newX < 0 Then newX = 0
			If newY < 0 Then newY = 0
		End
		window.SetLocation(newX, newY)
	End
	
	Method MouseClicked:Void(source:Component, x:Float, y:Float, button:Int, absoluteX:Float, absoluteY:Float)
	End
	
	Method MouseEntered:Void(source:Component, x:Float, y:Float, exitedComp:Component, absoluteX:Float, absoluteY:Float)
	End
	
	Method MouseExited:Void(source:Component, x:Float, y:Float, enteredComp:Component, absoluteX:Float, absoluteY:Float)
	End
	
	Method MouseMoved:Void(source:Component, x:Float, y:Float, absoluteX:Float, absoluteY:Float)
	End
End

' handles all the internal events for the Button component
Class InternalButtonAdapter Implements IMouseListener
	Field button:Button
	
	Method New(button:Button)
		Self.button = button
	End
	
	Method MouseClicked:Void(source:Component, x:Float, y:Float, button:Int, absoluteX:Float, absoluteY:Float)
		' is it a radio button?
		If Self.button.radioGroup <> Null Then
			Self.button.radioGroup.SelectButton(Self.button)
		' is it a toggle button?
		ElseIf Self.button.toggle Then
			Self.button.selected = Not Self.button.selected
		End
		Self.button.FireActionPerformed(ACTION_CLICKED)
	End
	
	Method MousePressed:Void(source:Component, x:Float, y:Float, button:Int, absoluteX:Float, absoluteY:Float)
	End
	
	Method MouseReleased:Void(source:Component, x:Float, y:Float, button:Int, absoluteX:Float, absoluteY:Float)
	End
	
	Method MouseEntered:Void(source:Component, x:Float, y:Float, exitedComp:Component, absoluteX:Float, absoluteY:Float)
	End
	
	Method MouseExited:Void(source:Component, x:Float, y:Float, enteredComp:Component, absoluteX:Float, absoluteY:Float)
	End
End

