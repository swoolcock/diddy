Import mojo
Import diddy

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

Class GUI
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
	
	Method New()
		desktop = New Desktop(Self)
		desktop.SetBounds(0, 0, DeviceWidth(), DeviceHeight())
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
				SetScissor(scissors[scissorDepth-1].x, scissors[scissorDepth-1].y, scissors[scissorDepth-1].w, scissors[scissorDepth-1].h)
			End
		Else
			SetScissor(0, 0, DeviceWidth(), DeviceHeight())
		End
	End
	
	Method EmptyScissor:Bool()
		If scissorDepth <= 0 Then Return False
		Return scissors[scissorDepth-1].empty
	End
	
	Method Draw()
		desktop.Draw(Self)
		scissorDepth = 0
		SetScissor(0, 0, DeviceWidth(), DeviceHeight())
	End
	
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
	
	Method Update:Void()
		mouseLastX = mouseThisX
		mouseLastY = mouseThisY
		mouseLastComponent = mouseThisComponent
		mouseThisX = MouseX()
		mouseThisY = MouseY()
		mouseThisComponent = ComponentAtPoint(mouseThisX, mouseThisY)
		DoMouse(MOUSE_LEFT)
		DoMouse(MOUSE_MIDDLE)
		DoMouse(MOUSE_RIGHT)
	End
	
	Method DoMouse:Void(button%)
		If MouseHit(button) Then
			mouseDown[button] = True
			mouseDownX[button] = mouseThisX
			mouseDownY[button] = mouseThisY
			mouseDownComponent[button] = mouseThisComponent
			
			' fire pressed on mouseThisComponent
			If mouseThisComponent.mouseAdapter <> Null Then mouseThisComponent.mouseAdapter.MousePressed(mouseThisX, mouseThisY, button)
			
			' set mouseDown
			mouseThisComponent.mouseDown = True
			
		ElseIf mouseDown[button] Then
			' if we released the button
			If Not MouseDown(button) Then
				mouseDown[button] = False
				Local comp:Component = mouseDownComponent[button]
				mouseDownComponent[button] = Null 
				
				' fire mouse released on comp
				If comp.mouseAdapter <> Null Then comp.mouseAdapter.MouseReleased(mouseThisX, mouseThisY, button)
				
				' clear mouseDown
				comp.mouseDown = False
				
				' if we released on the same component, fire mouse clicked
				If mouseThisComponent = comp Then
					If comp.mouseAdapter <> Null Then comp.mouseAdapter.MouseClicked(mouseThisX, mouseThisY, button)
				End
				
			ElseIf mouseLastX <> mouseThisX Or mouseLastY <> mouseThisY Then
				' fire mouse dragged on mouseDownComponent
				If mouseDownComponent[button].mouseMotionAdapter <> Null Then mouseDownComponent[button].mouseMotionAdapter.MouseDragged(mouseThisX, mouseThisY, button)
				
				' if the component changed, fire exit/enter
				If mouseThisComponent <> mouseLastComponent Then
					' fire mouse exited on mouseLastComponent
					If mouseLastComponent.mouseAdapter <> Null Then mouseLastComponent.mouseAdapter.MouseExited(mouseThisX, mouseThisY, mouseThisComponent)
					
					' clear mouseHover
					mouseLastComponent.mouseHover = False
					
					' fire mouse entered on mouseThisComponent
					If mouseThisComponent.mouseAdapter <> Null Then mouseThisComponent.mouseAdapter.MouseEntered(mouseThisX, mouseThisY, mouseLastComponent)
					
					' set the STATE_HOVER bit
					mouseThisComponent.mouseHover = True
				End
			End
		Else
			If mouseLastX <> mouseThisX Or mouseLastY <> mouseThisY Then
				' fire mouse moved on mouseThisComponent
				If mouseThisComponent.mouseMotionAdapter <> Null Then mouseThisComponent.mouseMotionAdapter.MouseMoved(mouseThisX, mouseThisY)
				
				' if the component changed, fire exit/enter
				If mouseThisComponent <> mouseLastComponent Then
					' fire mouse exited on mouseLastComponent
					If mouseLastComponent.mouseAdapter <> Null Then mouseLastComponent.mouseAdapter.MouseExited(mouseThisX, mouseThisY, mouseThisComponent)
					
					' clear mouseHover
					mouseLastComponent.mouseHover = False
					
					' fire mouse entered on mouseThisComponent
					If mouseThisComponent.mouseAdapter <> Null Then mouseThisComponent.mouseAdapter.MouseEntered(mouseThisX, mouseThisY, mouseLastComponent)
					
					' set mouseHover
					mouseThisComponent.mouseHover = True
				End
			End
		End
	End
	
	Method ActionPerformed:Void(source:Component)
	End
End

Class AbstractMouseAdapter Abstract
	Method MousePressed:Void(x#, y#, button%)
	End
	Method MouseReleased:Void(x#, y#, button%)
	End
	Method MouseClicked:Void(x#, y#, button%)
	End
	Method MouseEntered:Void(x#, y#, exitedComp:Component)
	End
	Method MouseExited:Void(x#, y#, enteredComp:Component)
	End
End

Class AbstractMouseMotionAdapter Abstract
	Method MouseMoved:Void(x#, y#)
	End
	Method MouseDragged:Void(x#, y#, button%)
	End
End

Class Desktop Extends Component
	Field restrictWindows:Bool = True
	Field parentGUI:GUI
	Method New(parentGUI:GUI)
		Super.New(Null)
		Self.parentGUI = parentGUI
	End
	
	Method ActionPerformed:Void(source:Component)
		parentGUI.ActionPerformed(source)
	End
End

Class Component
Private
	Field alpha# = 1
	Field children:ArrayList<Component> = New ArrayList<Component>
	Field mouseAdapter:AbstractMouseAdapter
	Field mouseMotionAdapter:AbstractMouseMotionAdapter
	Field forwardAction:Component = Null
	Field mouseHover:Bool = False
	Field mouseDown:Bool = False
	
	Field styleNormal:ComponentStyle = Null
	
Public
	Field parent:Component
	
	Field x#, y#
	Field w#, h#
	Field visible:Bool = True
	
	Method MouseAdapter:Void(mouseAdapter:AbstractMouseAdapter) Property
		Self.mouseAdapter = mouseAdapter
	End
	Method MouseAdapter:AbstractMouseAdapter() Property
		Return Self.mouseAdapter
	End
	Method MouseMotionAdapter:Void(mouseMotionAdapter:AbstractMouseMotionAdapter) Property
		Self.mouseMotionAdapter = mouseMotionAdapter
	End
	Method MouseMotionAdapter:AbstractMouseMotionAdapter() Property
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
	
	Method ActionPerformed:Void(source:Component)
		If forwardAction <> Null Then
			forwardAction.ActionPerformed(source)
		End
	End
	
	Method FindActionTarget:Component()
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

Class Window Extends Component
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
		titlePane.mouseAdapter = New WindowTitlePaneMouseAdapter(Self)
		titlePane.mouseMotionAdapter = New WindowTitlePaneMouseMotionAdapter(Self)
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
	
	
End

Class WindowTitlePaneMouseAdapter Extends AbstractMouseAdapter
	Field window:Window
	Method New(window:Window)
		Self.window = window
	End
	Method MousePressed:Void(x#, y#, button%)
		If window.dragging Then Return
		If window.maximised Or window.minimised Then Return
		window.dragging = True
		window.dragX = x
		window.dragY = y
		window.originalX = window.x
		window.originalY = window.y
	End
	Method MouseReleased:Void(x#, y#, button%)
		window.dragging = False
	End
End
	
Class WindowTitlePaneMouseMotionAdapter Extends AbstractMouseMotionAdapter
	Field window:Window
	Method New(window:Window)
		Self.window = window
	End
	Method MouseDragged:Void(x#, y#, button%)
		If window.maximised Or window.minimised Then window.dragging = False
		If Not window.dragging Then Return
		Local dx# = x-window.dragX, dy# = y-window.dragY
		Local newX# = window.originalX + dx, newY# = window.originalY + dy
		
		If Desktop(window.parent) <> Null And Desktop(window.parent).restrictWindows Then
			If newX + window.w > window.parent.w Then newX = window.parent.w - window.w
			If newY + window.h > window.parent.h Then newY = window.parent.h - window.h
			If newX < 0 Then newX = 0
			If newY < 0 Then newY = 0
		End
		window.SetLocation(newX, newY)
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

Class Button Extends Component
Private
	Field styleSelected:ComponentStyle = Null
	
Public
	Field selected:Bool
	Field toggle:Bool
	
	Method New(parent:Component)
		Super.New(parent)
		Self.forwardAction = FindActionTarget()
		mouseAdapter = New ButtonMouseAdapter(Self)
	End
	
	Method New(parent:Component, forwardAction:Component)
		Super.New(parent)
		Self.forwardAction = forwardAction
		mouseAdapter = New ButtonMouseAdapter(Self)
	End
	
	Method StyleSelected:ComponentStyle() Property
		If styleSelected = Null Then styleSelected = New ComponentStyle
		Return styleSelected
	End
	Method StyleSelected:Void(style:ComponentStyle) Property
		styleSelected = style
	End
	
	Method GetCurrentStyle:ComponentStyle()
		If selected And styleSelected <> Null Then Return styleSelected
		Return Super.GetCurrentStyle()
	End
End

Class ButtonMouseAdapter Extends AbstractMouseAdapter
	Field button:Button
	Method New(button:Button)
		Self.button = button
	End
	Method MouseClicked:Void(x#, y#, button%)
		If Self.button.toggle Then Self.button.selected = Not Self.button.selected
		Self.button.ActionPerformed(Self.button)
	End
End





