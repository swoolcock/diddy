Import mojo
Import diddy

Const ACTION_CLICKED$ = "clicked"
Const ACTION_VALUE_CHANGED$ = "changed"

Class Rectangle
	Field x#, y#, w#, h#
	Field empty? = False
	
	Method New(x#, y#, w#, h#)
		Set(x, y, w, h)
	End
	
	Method Set:Void(x#, y#, w#, h#)
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
	
	Method Intersect:Void(x#, y#, w#, h#)
		If x >= Self.x + Self.w Or y >= Self.y + Self.h Or Self.x >= x + w Or Self.y >= y + h Then
			Clear()
			Return
		End
		
		Local r% = Self.x + Self.w
		Local b% = Self.y + Self.h
		If Self.x < x Then Self.x = x
		If Self.y < y Then Self.y = y
		If r > x + w Then r = x + w
		If b > y + h Then b = y + h
		Self.w = r - Self.x
		Self.h = b - Self.y
	End
End

Class GUI Implements ActionListener
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
	
	Method New()
		desktop = New Desktop(Self)
		desktop.SetBounds(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)
		For Local i% = 0 Until scissors.Length
			scissors[i] = New Rectangle
		Next
	End
	
	Method PushScissor:Void(x#, y#, w#, h#)
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
				Local xRatio:Float = 1, yRatio:Float = 1
				if useVirtualRes
					xRatio = SCREENX_RATIO
					yRatio = SCREENY_RATIO
				End
				SetScissor(scissors[scissorDepth-1].x * xRatio, scissors[scissorDepth-1].y * yRatio, scissors[scissorDepth-1].w * xRatio, scissors[scissorDepth-1].h * yRatio)
			End
		Else
			SetScissor(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT)
		End
	End
	
	Method EmptyScissor:Bool()
		If scissorDepth <= 0 Then Return False
		Return scissors[scissorDepth-1].empty
	End
	
	Method Draw()
		desktop.Draw(Self)
		scissorDepth = 0
		SetScissor(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT)
	End
	
	' TODO: check Z-order
	Method ComponentAtPoint:Component(x#, y#, parent:Component=Null)
		' if no parent, it's the desktop
		If parent = Null Then parent = desktop
		' if the mouse is outside the component, return null
		If x<0 Or y<0 Or x >= parent.w Or y >= parent.h Then Return Null

		' check if it's inside a child
		Local rv:Component = Null
		For Local i% = 0 Until parent.children.Size
			Local c:Component = parent.children.Get(i)
			rv = ComponentAtPoint(x-c.x, y-c.y, c)

			If rv <> Null Then Return rv
		Next
		' not inside a child, so it's this one
		Return parent
	End


	
	Method GetAbsoluteX:Float(comp:Component)
		Local rv# = comp.x
		While comp.parent <> Null
			comp = comp.parent
			rv += comp.x
		Wend
		Return rv
	End
	
	Method GetAbsoluteY:Float(comp:Component)
		Local rv# = comp.y
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
		if useVirtualRes
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
	
	Method DoMouse:Void(button%)
		Local absX#, absY#
		If MouseHit(button) Then
			mouseDown[button] = True
			mouseDownX[button] = mouseThisX
			mouseDownY[button] = mouseThisY
			mouseDownComponent[button] = mouseThisComponent
			
			' fire pressed on mouseThisComponent
			If mouseThisComponent.mouseAdapter <> Null Then
				absX = GetAbsoluteX(mouseThisComponent)
				absY = GetAbsoluteY(mouseThisComponent)
				mouseThisComponent.mouseAdapter.MousePressed(mouseThisX-absX, mouseThisY-absY, button, mouseThisX, mouseThisY)
			End
			
			' set mouseDown
			mouseThisComponent.mouseDown = True
			
		ElseIf mouseDown[button] Then
			' if we released the button
			If Not MouseDown(button) Then
				mouseDown[button] = False
				Local comp:Component = mouseDownComponent[button]
				mouseDownComponent[button] = Null 
				
				' fire mouse released on comp
				If comp.mouseAdapter <> Null Then
					absX = GetAbsoluteX(comp)
					absY = GetAbsoluteY(comp)
					comp.mouseAdapter.MouseReleased(mouseThisX-absX, mouseThisY-absY, button, mouseThisX, mouseThisY)
				End
				
				' clear mouseDown
				comp.mouseDown = False
				
				' if we released on the same component, fire mouse clicked
				If mouseThisComponent = comp Then
					If comp.mouseAdapter <> Null Then comp.mouseAdapter.MouseClicked(mouseThisX-absX, mouseThisY-absY, button, mouseThisX, mouseThisY)
				End
				
			ElseIf mouseLastX <> mouseThisX Or mouseLastY <> mouseThisY Then
				' fire mouse dragged on mouseDownComponent
				If mouseDownComponent[button].mouseMotionAdapter <> Null Then
					absX = GetAbsoluteX(mouseDownComponent[button])
					absY = GetAbsoluteY(mouseDownComponent[button])
					mouseDownComponent[button].mouseMotionAdapter.MouseDragged(mouseThisX-absX, mouseThisY-absY, button, mouseThisX, mouseThisY)
				End
				
				' if the component changed, fire exit/enter
				If mouseThisComponent <> mouseLastComponent Then
					' fire mouse exited on mouseLastComponent
					If mouseLastComponent.mouseAdapter <> Null Then
						absX = GetAbsoluteX(mouseLastComponent)
						absY = GetAbsoluteY(mouseLastComponent)
						mouseLastComponent.mouseAdapter.MouseExited(mouseThisX-absX, mouseThisY-absY, mouseThisComponent, mouseThisX, mouseThisY)
					End
					
					' clear mouseHover
					mouseLastComponent.mouseHover = False
					
					' fire mouse entered on mouseThisComponent
					If mouseThisComponent.mouseAdapter <> Null Then
						absX = GetAbsoluteX(mouseThisComponent)
						absY = GetAbsoluteY(mouseThisComponent)
						mouseThisComponent.mouseAdapter.MouseEntered(mouseThisX-absX, mouseThisY-absY, mouseLastComponent, mouseThisX, mouseThisY)
					End
					
					' set the STATE_HOVER bit
					mouseThisComponent.mouseHover = True
				End
			End
		Else
			If mouseLastX <> mouseThisX Or mouseLastY <> mouseThisY Then
				' fire mouse moved on mouseThisComponent
				If mouseThisComponent <> Null And mouseThisComponent.mouseMotionAdapter <> Null Then
					absX = GetAbsoluteX(mouseThisComponent)
					absY = GetAbsoluteY(mouseThisComponent)
					mouseThisComponent.mouseMotionAdapter.MouseMoved(mouseThisX-absX, mouseThisY-absY, mouseThisX, absY)
				End
				
				' if the component changed, fire exit/enter
				If mouseThisComponent <> mouseLastComponent Then
					' fire mouse exited on mouseLastComponent
					If mouseLastComponent <> Null Then
						If mouseLastComponent.mouseAdapter <> Null Then
							absX = GetAbsoluteX(mouseLastComponent)
							absY = GetAbsoluteY(mouseLastComponent)
							mouseLastComponent.mouseAdapter.MouseExited(mouseThisX-absX, mouseThisY-absY, mouseThisComponent, mouseThisX, mouseThisY)
						End
						
						' clear mouseHover
						mouseLastComponent.mouseHover = False
					End
					
					' fire mouse entered on mouseThisComponent
					If mouseThisComponent <> Null Then
						If mouseThisComponent.mouseAdapter <> Null Then
							absX = GetAbsoluteX(mouseThisComponent)
							absY = GetAbsoluteY(mouseThisComponent)
							mouseThisComponent.mouseAdapter.MouseEntered(mouseThisX-absX, mouseThisY-absY, mouseLastComponent, mouseThisX, mouseThisY)
						End
						' set mouseHover
						mouseThisComponent.mouseHover = True
					End
				End
			End
		End
	End
	
	Method ActionPerformed:Void(source:Component, action:String)
	End
End

Interface ActionListener
	Method ActionPerformed:Void(source:Component, action:String)
End

Interface MouseListener
	Method MousePressed:Void(x#, y#, button%, absoluteX#, absoluteY#)
	Method MouseReleased:Void(x#, y#, button%, absoluteX#, absoluteY#)
	Method MouseClicked:Void(x#, y#, button%, absoluteX#, absoluteY#)
	Method MouseEntered:Void(x#, y#, exitedComp:Component, absoluteX#, absoluteY#)
	Method MouseExited:Void(x#, y#, enteredComp:Component, absoluteX#, absoluteY#)
End

Class AbstractMouseAdapter Implements MouseListener Abstract
	Method MousePressed:Void(x#, y#, button%, absoluteX#, absoluteY#)
	End
	Method MouseReleased:Void(x#, y#, button%, absoluteX#, absoluteY#)
	End
	Method MouseClicked:Void(x#, y#, button%, absoluteX#, absoluteY#)
	End
	Method MouseEntered:Void(x#, y#, exitedComp:Component, absoluteX#, absoluteY#)
	End
	Method MouseExited:Void(x#, y#, enteredComp:Component, absoluteX#, absoluteY#)
	End
End

Interface MouseMotionListener
	Method MouseMoved:Void(x#, y#, absoluteX#, absoluteY#)
	Method MouseDragged:Void(x#, y#, button%, absoluteX#, absoluteY#)
End

Class AbstractMouseMotionAdapter Implements MouseMotionListener Abstract
	Method MouseMoved:Void(x#, y#, absoluteX#, absoluteY#)
	End
	Method MouseDragged:Void(x#, y#, button%, absoluteX#, absoluteY#)
	End
End

Class Desktop Extends Component
	Field restrictWindows:Bool = True
	Field parentGUI:GUI
	Method New(parentGUI:GUI)
		Super.New(Null)
		Self.parentGUI = parentGUI
	End
	
	Method ActionPerformed:Void(source:Component, action:String)
		parentGUI.ActionPerformed(source, action)
	End
End

Class Component Implements ActionListener
Private
	Field alpha# = 1
	Field children:ArrayList<Component> = New ArrayList<Component>
	Field mouseAdapter:MouseListener
	Field mouseMotionAdapter:MouseMotionListener
	Field forwardAction:ActionListener = Null
	Field mouseHover:Bool = False
	Field mouseDown:Bool = False
	
	Field styleNormal:ComponentStyle = Null
	
Public
	Field parent:Component
	
	Field x#, y#
	Field w#, h#
	Field w2#, h2#
	Field visible:Bool = True
	
	Method MouseAdapter:Void(mouseAdapter:MouseListener) Property
		Self.mouseAdapter = mouseAdapter
	End

	Method MouseAdapter:MouseListener() Property
		Return Self.mouseAdapter
	End

	Method MouseMotionAdapter:Void(mouseMotionAdapter:MouseMotionListener) Property
		Self.mouseMotionAdapter = mouseMotionAdapter
	End

	Method MouseMotionAdapter:MouseMotionListener() Property
		Return Self.mouseMotionAdapter
	End

	Method StyleNormal:ComponentStyle() Property
		If styleNormal = Null Then styleNormal = New ComponentStyle
		Return styleNormal
	End

	Method StyleNormal:Void(style:ComponentStyle) Property
		AssertNotNull(style, "StyleNormal may not be null.")
		styleNormal = style
	End
	
	Method GetStyle:ComponentStyle(name$)
		If name = "normal" Then Return styleNormal
		Return Null
	End
	
	Method SetStyle:Void(name$, style:ComponentStyle)
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
		if styleNormal.image <> null
			If styleNormal.image.midhandled
				Error "Images can not be midhandled for GUI components"
			End
		End	
		if styleNormal.downImage <> null
			If styleNormal.downImage.midhandled
				Error "Images can not be midhandled for GUI components"
			End
		End
	End
	
	Method Alpha#() Property
		Return alpha
	End
	
	Method Alpha:Void(alpha#) Property
		Self.alpha = alpha
		If Self.alpha < 0 Then Self.alpha = 0
		If Self.alpha > 1 Then Self.alpha = 1
	End
	
	Method SetBackground:Void(red#, green#, blue#)
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
	
	Method SetLocation:Void(x#, y#)
		Self.x = x
		Self.y = y
		Layout()
	End
	
	Method SetSize:Void(w#, h#)
		Self.w = w
		Self.h = h
		Self.w2 = w / 2
		Self.h2 = h / 2
		Layout()
	End
	
	Method SetBounds:Void(x#, y#, w#, h#)
		Self.x = x
		Self.y = y
		Self.w = w
		Self.h = h
		Layout()
	End
	
	Method Draw:Void(parentGui:GUI, alpha# = 1, absx# = 0, absy# = 0)
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
	
	Method DrawChildren:Void(parentGui:GUI, alpha# = 1, absx#, absy#)
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
		Self.parent = Null
		If Not recursing Then p.children.Remove(Self)
	End
	
	Method AddNotify:Void()
	End
	
	Method DisposeNotify:Void()
	End
	
	Method Layout:Void()
	End
	
	Method ActionPerformed:Void(source:Component, action:String)
		If forwardAction <> Null Then
			forwardAction.ActionPerformed(source, action)
		End
	End
	
	Method FindActionTarget:ActionListener()
		' if this is a window or desktop, return itself
		If Window(Self) <> Null Or Desktop(Self) <> Null Then Return Self
		' traverse up the hierarchy and find the closest Window or Desktop to receive the actions
		Local comp:Component = Self
		While Window(Self) = Null And Desktop(Self) = Null And comp.parent <> Null
			comp = comp.parent
		End
		Return comp
	End
End

Class ComponentStyle
	Global IMAGE_NORMAL% = 0
	Global IMAGE_TILE% = 1
	Global IMAGE_STRETCH% = 2
	Global IMAGE_GRID% = 3
	
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

Class Window Extends Component Implements MouseListener, MouseMotionListener
Private
	Field contentPane:Panel
	Field titlePane:Panel
	Field buttonPane:Panel
	
	Field closeButton:WindowButtonPanelButton
	
	Field titleHeight:Int = 22
	Field buttonWidth:Int = 15
	
	' note: a window can be all three of these states at once!
	' priority is: minimised, maximised, shaded
	Field maximised:Bool = False
	Field minimised:Bool = False
	Field shaded:Bool = False
	Field dragX#, dragY#, originalX#, originalY#
	Field dragging:Bool = False
	
	Field normalX#, normalY#, normalWidth#, normalHeight#

	Method CreateButtonPane:Void()
		buttonPane = New Panel(Self)
		buttonPane.w = buttonWidth*3
		buttonPane.StyleNormal.drawBackground = False
		'closeButton = New WindowButtonPanelButton(buttonPane, WindowButtonPanelButton.CLOSE_BUTTON)
		'closeButton.StyleNormal.red = 255
		'closeButton.StyleNormal.green = 255
		'closeButton.StyleNormal.blue = 255
		'closeButton.SetBounds(0, 0, buttonWidth, buttonWidth)
	End
	
	Method CreateContentPane:Void()
		contentPane = New Panel(Self)
		contentPane.StyleNormal.drawBackground = False
	End
	
	Method CreateTitlePane:Void()
		titlePane = New Panel(Self)
		titlePane.StyleNormal.drawBackground = False
		titlePane.mouseAdapter = Self
		titlePane.mouseMotionAdapter = Self
	End
Public
	Method ContentPane:Panel() Property
		Return contentPane
	End
	
	Method ContentPane:Void(contentPane:Panel) Property
		If self.contentPane <> Null Then self.contentPane.Dispose()
		Self.contentPane = contentPane
	End
	
	Method TitlePane:Panel() Property
		Return titlePane
	End
	
	Method ButtonPane:Panel() Property
		Return buttonPane
	End
	
	Method Maximised:Void(maximised:Bool) Property
		StoreWindowSize()
		Self.maximised = maximised
		UpdateWindowSize()
	End
	
	Method Maximised:Bool() Property
		Return maximised
	End
	
	Method Minimised:Void(minimised:Bool) Property
		StoreWindowSize()
		Self.minimised = minimised
		UpdateWindowSize()
	End
	
	Method Minimised:Bool() Property
		Return minimised
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
		If maximised Or minimised Then Return
		normalX = x
		normalY = y
		If Not shaded Then
			normalWidth = w
			normalHeight = h
		End
	End
	
	Method UpdateWindowSize:Void()
		If Not maximised And Not minimised And Not shaded Then
			SetBounds(normalX, normalY, normalWidth, normalHeight)
		ElseIf minimised Then
			SetBounds(0, 0, 50, titleHeight)
		ElseIf maximised Then
			SetBounds(0, 0, parent.w, parent.h)
		ElseIf shaded Then
			SetBounds(normalX, normalY, normalWidth, titleHeight)
		End
	End
	
	Method New(parent:Component)
		Super.New(parent)
		CreateButtonPane()
		CreateContentPane()
		CreateTitlePane()
	End
	
	Method Layout:Void()
		If minimised Or shaded Then
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
	
	Method MousePressed:Void(x#, y#, button%, absoluteX#, absoluteY#)
		If dragging Then Return
		If maximised Or minimised Then Return
		dragging = True
		dragX = absoluteX
		dragY = absoluteY
		originalX = Self.x
		originalY = Self.y
	End
	
	Method MouseReleased:Void(x#, y#, button%, absoluteX#, absoluteY#)
		dragging = False
	End
	
	Method MouseDragged:Void(x#, y#, button%, absoluteX#, absoluteY#)
		If maximised Or minimised Then dragging = False
		If Not dragging Then Return
		Local dx# = absoluteX-dragX, dy# = absoluteY-dragY
		Local newX# = originalX + dx, newY# = originalY + dy
		
		If Desktop(parent) <> Null And Desktop(parent).restrictWindows Then
			If newX + w > parent.w Then newX = parent.w - w
			If newY + h > parent.h Then newY = parent.h - h
			If newX < 0 Then newX = 0
			If newY < 0 Then newY = 0
		End
		SetLocation(newX, newY)
	End
	
	Method MouseClicked:Void(x#, y#, button%, absoluteX#, absoluteY#)
	End
	
	Method MouseEntered:Void(x#, y#, exitedComp:Component, absoluteX#, absoluteY#)
	End
	
	Method MouseExited:Void(x#, y#, enteredComp:Component, absoluteX#, absoluteY#)
	End
	
	Method MouseMoved:Void(x#, y#, absoluteX#, absoluteY#)
	End
End

Class WindowButtonPanelButton Extends Button
	Const CLOSE_BUTTON% = 0
	Const MAXIMISE_BUTTON% = 1
	Const MINIMISE_BUTTON% = 2
	Const SHADE_BUTTON% = 3
	Field buttonType%
	
	Method New(parent:Component, buttonType%)
		Super.New(parent)
		Self.buttonType = buttonType
	End
	
	Method ButtonClicked:Void()
		Local window:Window = Window(parent)
		AssertNotNull(window, "WindowButtonPanelButton.ButtonClicked: window was null")
		Select buttonType
			Case CLOSE_BUTTON
				window.Dispose()
		End
	End
End

Class Label Extends Component
Private
	Field text:String
	Field textRed%, textGreen%, textBlue%
	Field textXOffset# = 0
	Field textYOffset# = 0
	Field textXAlign# = 0
	Field textYAlign# = 0

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
		If text.Length > 0
			DrawText text, w*textXAlign+textXOffset, h*textYAlign+textYOffset, textXAlign, textYAlign
		End
	End
End

Class Button Extends Label Implements MouseListener
Private
	Field styleSelected:ComponentStyle = Null
	
Public
	Field selected:Bool
	Field toggle:Bool
	Field radioGroup:RadioGroup
	Field radioValue$
	
	Method New(parent:Component)
		Super.New(parent)
		Self.forwardAction = FindActionTarget()
		mouseAdapter = Self
	End
	
	Method New(parent:Component, image:GameImage)
		Super.New(parent)
		Self.forwardAction = FindActionTarget()
		mouseAdapter = Self
		Self.StyleNormal.image = image
		Self.StyleNormal.drawBackground = False
		Self.SetSize(image.w, image.h)
		CheckImage()
	End
	
	Method New(parent:Component, image:GameImage, clickImage:GameImage)
		Super.New(parent)
		Self.forwardAction = FindActionTarget()
		mouseAdapter = Self
		Self.StyleNormal.image = image
		Self.styleNormal.downImage = clickImage
		Self.StyleNormal.drawBackground = False
		Self.SetSize(image.w, image.h)
		CheckImage()
	End
	
	Method New(parent:Component, forwardAction:Component)
		Super.New(parent)
		Self.forwardAction = forwardAction
		mouseAdapter = Self
	End
	
	Method StyleSelected:ComponentStyle() Property
		If styleSelected = Null Then styleSelected = New ComponentStyle
		Return styleSelected
	End
	Method StyleSelected:Void(style:ComponentStyle) Property
		styleSelected = style
	End
	
	Method GetStyle:ComponentStyle(name$)
		If name = "selected" Then Return styleSelected
		Return Super.GetStyle(name)
	End
	
	Method SetStyle:Void(name$, style:ComponentStyle)
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
	
	Method MouseClicked:Void(x#, y#, button%, absoluteX#, absoluteY#)
		' is it a radio button?
		If radioGroup <> Null Then
			radioGroup.SelectButton(Self)
		' is it a toggle button?
		ElseIf toggle Then
			selected = Not selected
		End
		ActionPerformed(Self, ACTION_CLICKED)
	End
	
	Method MousePressed:Void(x#, y#, button%, absoluteX#, absoluteY#)
	End
	
	Method MouseReleased:Void(x#, y#, button%, absoluteX#, absoluteY#)
	End
	
	Method MouseEntered:Void(x#, y#, exitedComp:Component, absoluteX#, absoluteY#)
	End
	
	Method MouseExited:Void(x#, y#, enteredComp:Component, absoluteX#, absoluteY#)
	End
End

Class RadioGroup
	Field buttons:ArrayList<Button> = New ArrayList<Button>
	Field currentValue$
	
	Method SelectButton:String(button:Button)
		For Local b:Button = EachIn buttons
			b.selected = (b = button)
			If b.selected Then
				currentValue = b.radioValue
			End
		Next
		Return currentValue
	End
	
	Method SelectValue:Button(value$)
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
	
	Method AddButton:Void(button:Button, value$)
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

Class Slider Extends Component Implements MouseListener, MouseMotionListener
	Const SLIDER_HORIZONTAL% = 0
	Const SLIDER_VERTICAL% = 1
	Const SLIDER_DIRECTION_TL_TO_BR% = 0 ' min is top or left, max is bottom or right
	Const SLIDER_DIRECTION_BR_TO_TL% = 1 ' min is bottom or right, max is top or left
Private
	Field buttonUpLeft:Button ' the button used for up and left
	Field buttonDownRight:Button ' the button used for down and right
	Field handle:Label
	Field showButtons:Bool
	Field orientation:Int = SLIDER_HORIZONTAL
	Field direction:Int = SLIDER_DIRECTION_TL_TO_BR
	
	Field dragX%, dragY%, originalX%, originalY%
	Field dragging:Bool = False
	
	Field styleLeftButton:ComponentStyle
	Field styleRightButton:ComponentStyle
	Field styleTopButton:ComponentStyle
	Field styleBottomButton:ComponentStyle
	Field styleHorizontalHandle:ComponentStyle
	Field styleVerticalHandle:ComponentStyle
	
Public
	Field minValue% = 0
	Field maxValue% = 100
	Field value% = 50
	Field tickInterval% = 10
	Field handleMargin% = 10
	Field handleSize% = 10
	Field buttonSize% = 15
	Field snapToTicks:Bool = True
	
	Method New(parent:Component)
		Super.New(parent)
		buttonUpLeft = New Button(Self, Self)
		buttonDownRight = New Button(Self, Self)
		handle = New Label(Self)
		handle.mouseAdapter = Self
		handle.mouseMotionAdapter = Self
		buttonUpLeft.visible = False
		buttonDownRight.visible = False
	End
	
	Method GetStyle:ComponentStyle(name$)
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
		End
		Return Super.GetStyle(name)
	End
	
	Method SetStyle:Void(name$, style:ComponentStyle)
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
	
	Method DrawComponent:Void()
		Super.DrawComponent()
		' TODO: render groove and ticks, etc.
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
			Else
				buttonUpLeft.SetBounds(0, 0, Self.w, buttonSize)
				buttonDownRight.SetBounds(0, Self.h - buttonSize, Self.w, buttonSize)
			End
			buttonUpLeft.visible = True
			buttonDownRight.visible = True
		Else
			buttonUpLeft.visible = False
			buttonDownRight.visible = False
		End
		Local startVal% = buttonSize+handleMargin
		Local endVal% = -buttonSize-handleMargin
		Local fraction# = Float(value-minValue)/Float(maxValue-minValue)
		Local currentVal%
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
	
	Method HandleDrag:Int(mx%, my%)
		Local pos%, topLeft% = handleMargin, bottomRight% = -handleMargin
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
		Local fraction# = Float(pos-topLeft) / Float(bottomRight-topLeft)
		If direction = SLIDER_DIRECTION_BR_TO_TL Then fraction = 1-fraction
		
		Local oldValue% = value
		value = SnapToValue(minValue + (maxValue - minValue)*fraction)
		
		' if it changed, update the layout and fire an event
		If value <> oldValue Then
			Local target:ActionListener = forwardAction
			If target = Null Then target = FindActionTarget()
			If target <> Null Then
				Layout()
				target.ActionPerformed(Self, ACTION_VALUE_CHANGED)
			EndIf
		End
	End
	
	Method ActionPerformed:Void(source:Component, action:String)
		If source = buttonUpLeft And action = ACTION_CLICKED Then
			If direction = SLIDER_DIRECTION_TL_TO_BR Then
				AdjustValue(-1)
			Else
				AdjustValue(1)
			End
		ElseIf source = buttonDownRight And action = ACTION_CLICKED Then
			If direction = SLIDER_DIRECTION_TL_TO_BR Then
				AdjustValue(1)
			Else
				AdjustValue(-1)
			End
		End
	End
	
	Method SnapToValue:Int(val%)
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
	
	Method AdjustValue:Bool(amount%)
		If amount = 0 Then Return
		Local oldValue% = value
		
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
			Local target:ActionListener = forwardAction
			If target = Null Then target = FindActionTarget()
			If target <> Null Then
				Layout()
				target.ActionPerformed(Self, ACTION_VALUE_CHANGED)
			EndIf
		End
		Return value <> oldValue
	End
	
	Method MousePressed:Void(x#, y#, button%, absoluteX#, absoluteY#)
		If dragging Then Return
		dragging = True
		HandleDrag(handle.x + x, handle.y + y)
	End
	
	Method MouseReleased:Void(x#, y#, button%, absoluteX#, absoluteY#)
		dragging = False
		HandleDrag(handle.x + x, handle.y + y)
	End
	
	Method MouseDragged:Void(x#, y#, button%, absoluteX#, absoluteY#)
		If Not dragging Then Return
		HandleDrag(handle.x + x, handle.y + y)
	End
	
	Method MouseClicked:Void(x#, y#, button%, absoluteX#, absoluteY#)
	End
	
	Method MouseEntered:Void(x#, y#, exitedComp:Component, absoluteX#, absoluteY#)
	End
	
	Method MouseExited:Void(x#, y#, enteredComp:Component, absoluteX#, absoluteY#)
	End
	
	Method MouseMoved:Void(x#, y#, absoluteX#, absoluteY#)
	End
End
