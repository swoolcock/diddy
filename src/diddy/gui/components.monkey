Strict

Import mojo
Import diddy
Import core

Const SKIN_NODE_NONE:String = ""
Const SKIN_NODE_WINDOW:String = "window"
Const SKIN_NODE_BUTTON:String = "button"
Const SKIN_NODE_RADIO:String = "radio"
Const SKIN_NODE_CHECKBOX:String = "checkbox"
Const SKIN_NODE_SLIDER:String = "slider"
Const SKIN_NODE_LABEL:String = "label"

Class Component
Private
' Private fields
	Field alpha:Float = 1
	Field children:ArrayList<Component> = New ArrayList<Component>
	Field childrenZOrder:ArrayList<Component> = New ArrayList<Component>
	
	' external listeners (properties) - these can and should be changed by developers for their own needs
	Field mouseListener:IMouseListener
	Field mouseMotionListener:IMouseMotionListener
	Field keyListener:IKeyListener
	Field focusListener:IFocusListener
	Field actionListener:IActionListener
	
	' internal listeners - these can't and shouldn't be changed by developers!!!
	Field internalMouseListener:IMouseListener
	Field internalMouseMotionListener:IMouseMotionListener
	Field internalKeyListener:IKeyListener
	Field internalFocusListener:IFocusListener
	Field internalActionListener:IActionListener
	
	Field layoutManager:ILayoutManager
	Field layoutData:ILayoutData
	
	Field fontName:String = "Tahoma-10"
	
	Field styleNormal:ComponentStyle = New ComponentStyle
	
	Field visible:Bool = True
	Field enabled:Bool = True
	Field focusable:Bool = False
	
	' sizes for layout
	Field preferredWidth:Int
	Field preferredHeight:Int
	Field minimumWidth:Int
	Field minimumHeight:Int
	
	Field parent:Component
	
	Field x:Int, y:Int
	Field w:Int, h:Int
	Field w2:Float, h2:Float
	Field zOrderLocked:Bool = False

' Private methods
	Method RequestFocusDelegate:Bool(thisGui:GUI)
		' check the last focused child
		If focusedChild <> Null Then
			' check focusable first to save a method call
			If focusedChild.focusable Then
				thisGui.SetFocus(focusedChild)
				Return True
			End
			' recurse
			If focusedChild.RequestFocusDelegate(thisGui) Then Return True
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
			If child <> focusedChild And child.RequestFocusDelegate(thisGui) Then Return True
		Next
		' we still couldn't focus
		Return False
	End

	Method ReadSkinFields:Void(node:XMLElement)
	End
	
	' Reads the styles from the XML node.
	Method LoadStyles:Void(node:XMLElement)
		If node = Null Then Return
		' copy styles
		For Local i:Int = 0 Until node.Children.Size
			Local styleNode:XMLElement = node.Children.Get(i)
			Local style:ComponentStyle = GetStyle(styleNode.GetAttribute("name"))
			If style = Null Then style = New ComponentStyle
			style.ReadFromNode(styleNode)
			SetStyle(styleNode.GetAttribute("name"), style)
		Next
	End
	
	Method ApplySkin:Void()
		Local thisGUI:GUI = FindGUI()
		Local node:XMLElement = thisGUI.GetSkinNode(GetSkinNodeName())
		If node <> Null Then
			LoadStyles(node)
			ReadSkinFields(node)
		End
	End
	
Public
' Public Fields
	' Note that these are public for now so they can be referenced from core.monkey
	' Please don't use them directly!!!
	Field mouseHover:Bool = False
	Field mouseDown:Bool = False
	Field focusedChild:Component
	
' Properties
	' X is read/write
	Method X:Int() Property
		Return x
	End
	Method X:Void(x:Int) Property
		Self.x = x
	End
	
	' Y is read/write
	Method Y:Int() Property
		Return y
	End
	Method Y:Void(y:Int) Property
		Self.y = y
	End
	
	' Width is read/write and updates w2
	Method Width:Int() Property
		Return w
	End
	Method Width:Void(width:Int) Property
		Self.w = width
		Self.w2 = width/2.0
	End
	
	' Height is read/write and updates h2
	Method Height:Int() Property
		Return h
	End
	Method Height:Void(height:Int) Property
		Self.h = height
		Self.h2 = height/2.0
	End
	
	' LeftEdge is read/write and updates x, w, and w2
	Method LeftEdge:Int() Property
		Return x
	End
	Method LeftEdge:Void(leftEdge:Int) Property
		Local offset:Int = x-leftEdge
		Self.x = leftEdge
		Self.w += offset
		Self.w2 = Self.w/2.0
	End
	
	' RightEdge is read/write and updates w and w2
	Method RightEdge:Int() Property
		Return x+w
	End
	Method RightEdge:Void(rightEdge:Int) Property
		Self.w = rightEdge-Self.x
		Self.w2 = Self.w/2.0
	End
	
	' TopEdge is read/write and updates y, h, and h2
	Method TopEdge:Int() Property
		Return y
	End
	Method TopEdge:Void(topEdge:Int) Property
		Local offset:Int = y-topEdge
		Self.y = topEdge
		Self.h += offset
		Self.h2 = Self.h/2.0
	End
	
	' BottomEdge is read/write and updates h and h2
	Method BottomEdge:Int() Property
		Return y+h
	End
	Method BottomEdge:Void(bottomEdge:Int) Property
		Self.h = bottomEdge-Self.y
		Self.h2 = Self.h/2.0
	End
	
	' Parent is read only
	Method Parent:Component() Property
		Return parent
	End
	
	' FontName is read/write
	Method FontName:String() Property
		Return fontName
	End
	Method FontName:Void(fontName:String) Property
		Self.fontName = fontName
	End
	
	' Children is read only
	Method Children:ArrayList<Component>() Property
		Return children
	End
	
	' ChildrenZOrder is read only
	Method ChildrenZOrder:ArrayList<Component>() Property
		Return childrenZOrder
	End
	
	' LayoutManager is read/write
	Method LayoutManager:ILayoutManager() Property
		Return layoutManager
	End
	Method LayoutManager:Void(layoutManager:ILayoutManager) Property
		Self.layoutManager = layoutManager
	End
	
	' LayoutData is read/write
	Method LayoutData:ILayoutData() Property
		Return layoutData
	End
	Method LayoutData:Void(layoutData:ILayoutData) Property
		Self.layoutData = layoutData
	End
	
	' ActionListener is read/write
	Method ActionListener:Void(actionListener:IActionListener) Property
		Self.actionListener = actionListener
	End
	Method ActionListener:IActionListener() Property
		Return Self.actionListener
	End
	
	' MouseListener is read/write
	Method MouseListener:Void(mouseListener:IMouseListener) Property
		Self.mouseListener = mouseListener
	End
	Method MouseListener:IMouseListener() Property
		Return Self.mouseListener
	End

	' MouseMotionListener is read/write
	Method MouseMotionListener:Void(mouseMotionListener:IMouseMotionListener) Property
		Self.mouseMotionListener = mouseMotionListener
	End
	Method MouseMotionListener:IMouseMotionListener() Property
		Return Self.mouseMotionListener
	End
	
	' KeyListener is read/write
	Method KeyListener:Void(keyListener:IKeyListener) Property
		Self.keyListener = keyListener
	End
	Method KeyListener:IKeyListener() Property
		Return Self.keyListener
	End

	' FocusListener is read/write
	Method FocusListener:Void(focusListener:IFocusListener) Property
		Self.focusListener = focusListener
	End

	Method FocusListener:IFocusListener() Property
		Return Self.focusListener
	End

	' StyleNormal is read/write
	Method StyleNormal:ComponentStyle() Property
		If styleNormal = Null Then styleNormal = New ComponentStyle
		Return styleNormal
	End
	Method StyleNormal:Void(style:ComponentStyle) Property
		AssertNotNull(style, "StyleNormal may not be null.")
		styleNormal = style
	End
	
	' Focusable is read/write
	Method Focusable:Bool() Property
		Return focusable
	End
	Method Focusable:Void(focusable:Bool) Property
		Self.focusable = focusable
	End
	
	' Focused is read only (use RequestFocus instead)
	Method Focused:Bool() Property
		If parent = Null Then Return False
		Return parent.focusedChild = Self
	End
	
	' Visible is read/write
	Method Visible:Bool() Property
		Return visible
	End
	Method Visible:Void(visible:Bool) Property
		Self.visible = visible
	End
	
	' Enabled is read/write
	Method Enabled:Bool() Property
		Return enabled
	End
	Method Enabled:Void(enabled:Bool) Property
		Self.enabled = enabled
	End
	
	' PreferredWidth is read/write
	Method PreferredWidth:Int() Property
		Return preferredWidth
	End
	Method PreferredWidth:Void(preferredWidth:Int) Property
		Self.preferredWidth = preferredWidth
	End
	
	' PreferredHeight is read/write
	Method PreferredHeight:Int() Property
		Return preferredHeight
	End
	Method PreferredHeight:Void(preferredHeight:Int) Property
		Self.preferredHeight = preferredHeight
	End
	
	' MinimumWidth is read/write
	Method MinimumWidth:Int() Property
		Return minimumWidth
	End
	Method MinimumWidth:Void(minimumWidth:Int) Property
		Self.minimumWidth = minimumWidth
	End
	
	' MinimumHeight is read/write
	Method MinimumHeight:Int() Property
		Return minimumHeight
	End
	Method MinimumHeight:Void(minimumHeight:Int) Property
		Self.minimumHeight = minimumHeight
	End
	
	' Alpha is read/write
	Method Alpha:Float() Property
		Return alpha
	End
	Method Alpha:Void(alpha:Float) Property
		Self.alpha = alpha
		If Self.alpha < 0 Then Self.alpha = 0
		If Self.alpha > 1 Then Self.alpha = 1
	End
	
	' ZOrderLocked is read/write, but should only really be used by subclasses!
	Method ZOrderLocked:Bool() Property
		Return zOrderLocked
	End
	Method ZOrderLocked:Void(zOrderLocked:Bool) Property
		Self.zOrderLocked = zOrderLocked
	End
	
	' AbsoluteX is read only because it is calculated
	Method AbsoluteX:Int() Property
		Local rv:Int = x
		Local comp:Component = Self
		While comp.parent <> Null
			comp = comp.parent
			rv += comp.x
		Wend
		Return rv
	End
	
	' AbsoluteY is read only because it is calculated
	Method AbsoluteY:Int() Property
		Local rv:Int = y
		Local comp:Component = Self
		While comp.parent <> Null
			comp = comp.parent
			rv += comp.y
		Wend
		Return rv
	End
	
' Constructors
	Method New()
		NoParent()
	End
	
	Method New(parent:Component)
		styleNormal = New ComponentStyle
		' if this isn't the desktop, it must have a parent
		If Not GUIDesktop(Self) Then
			If parent = Null Then NoParent()
			Self.parent = parent
			parent.children.Add(Self)
			parent.childrenZOrder.Add(Self)
			' if the parent has a layout manager, do it!
			If parent.layoutManager <> Null Then parent.Layout()
		Else
			styleNormal.drawBackground = False
		End
		AddNotify()
	End
	
' Public methods
	' Get an associated style based on a name
	Method GetStyle:ComponentStyle(name:String)
		If name = "normal" Then Return styleNormal
		Return Null
	End
	
	' Set an associated style based on a name
	Method SetStyle:Void(name:String, style:ComponentStyle)
		If name = "normal" Then styleNormal = style
	End
	
	' Convenience method to set the style's background properties.  If the component is skinned, the background will be drawn under it, showing through transparency.
	Method SetBackground:Void(red:Int, green:Int, blue:Int)
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
	
	' Convenience method to enable or disable the background, using whichever colour is already assigned.
	Method SetBackground:Void(drawBackground:Bool)
		styleNormal.drawBackground = drawBackground
	End
	
	' Convenience method to update both the x and y coordinates at once.
	Method SetLocation:Void(x:Int, y:Int)
		Self.x = x
		Self.y = y
	End
	
	' Convenience method to update both the width and height at once. This also fires off the layout manager.
	Method SetSize:Void(w:Int, h:Int)
		Self.w = w
		Self.h = h
		Self.w2 = w / 2.0
		Self.h2 = h / 2.0
		Layout()
	End
	
	' Convenience method to update x, y, width, and height at once. This also fires off the layout manager.
	Method SetBounds:Void(x:Int, y:Int, w:Int, h:Int)
		Self.x = x
		Self.y = y
		Self.w = w
		Self.h = h
		Self.w2 = w / 2.0
		Self.h2 = h / 2.0
		Layout()
	End
	
	' Convenience method to update x, y, width, and height at once using a Rectangle. This also fires off the layout manager.
	Method SetBounds:Void(rect:Rectangle)
		Self.x = rect.x
		Self.y = rect.y
		Self.w = rect.w
		Self.h = rect.h
		Self.w2 = w / 2.0
		Self.h2 = h / 2.0
		Layout()
	End
	
	' Convenience method to set the preferred width and height at once.
	Method SetPreferredSize:Void(w:Int, h:Int)
		Self.preferredWidth = w
		Self.preferredHeight = h
	End
	
	' Convenience method to set the minimum width and height at once.
	Method SetMinimumSize:Void(w:Int, h:Int)
		Self.minimumWidth = w
		Self.minimumHeight = h
	End
	
	' Kicks off the drawing process for this component.
	Method Draw:Void(parentGui:GUI, alpha:Float = 1, absx:Int = 0, absy:Int = 0)
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
	
	' Loops through each of the component's children, translating to the correct position and firing off their Draw methods.
	Method DrawChildren:Void(parentGui:GUI, alpha:Float = 1, absx:Int, absy:Int)
		For Local c:Component = EachIn childrenZOrder
			PushMatrix()
			Translate(c.x, c.y)
			c.Draw(parentGui, c.alpha * alpha, absx + c.x, absy + c.y)
			PopMatrix()
		Next
	End

	' Draws the contents of this component (ignoring any children).
	Method DrawComponent:Void()
		' get the gui and the atlas
		Local parentGui:GUI = FindGUI()
		Local atlas:GameImage = parentGui.SkinAtlas
		
		' work with the current style
		Local style:ComponentStyle = GetCurrentStyle()
		If style <> Null Then
			' background colour first
			If style.drawBackground Then
				SetColor(style.red, style.green, style.blue)
				SetAlpha(alpha)
				DrawRect(0, 0, w, h)
			End
			
			' image next, priority = disabled, down, hover, normal
			Local imageType:Int = -1
			If Not enabled Then
				If style.imageMode[ComponentStyle.IMAGE_DISABLED] <> "" Then
					imageType = ComponentStyle.IMAGE_DISABLED
				ElseIf style.imageMode[ComponentStyle.IMAGE_NORMAL] <> "" Then
					imageType = ComponentStyle.IMAGE_NORMAL
				End
			ElseIf mouseDown And style.imageMode[ComponentStyle.IMAGE_DOWN] <> "" Then
				imageType = ComponentStyle.IMAGE_DOWN
			ElseIf mouseHover And style.imageMode[ComponentStyle.IMAGE_HOVER] <> "" Then
				imageType = ComponentStyle.IMAGE_HOVER
			ElseIf style.imageMode[ComponentStyle.IMAGE_NORMAL] <> "" Then
				imageType = ComponentStyle.IMAGE_NORMAL
			End
			
			' if we have an image to draw, do it!
			If imageType >= 0 Then
				SetColor(255,255,255)
				SetAlpha(alpha)
				If style.imageMode[imageType] = ComponentStyle.IMAGE_MODE_GRID Then
					' nasty call here!
					atlas.DrawSubGrid(0, 0, w, h,
							style.imageX[imageType], style.imageY[imageType], style.imageWidth[imageType], style.imageHeight[imageType],
							style.imageLeftMargin[imageType], style.imageRightMargin[imageType], style.imageTopMargin[imageType], style.imageBottomMargin[imageType],
							style.imageDrawTopLeft[imageType], style.imageDrawTop[imageType], style.imageDrawTopRight[imageType],
							style.imageDrawLeft[imageType], style.imageDrawCenter[imageType], style.imageDrawRight[imageType],
							style.imageDrawBottomLeft[imageType], style.imageDrawBottom[imageType], style.imageDrawBottomRight[imageType])
				ElseIf style.imageMode[imageType] = ComponentStyle.IMAGE_MODE_STRETCH Then
					atlas.DrawSubStretched(0, 0, w, h, style.imageX[imageType], style.imageY[imageType], style.imageWidth[imageType], style.imageHeight[imageType])
				ElseIf style.imageMode[imageType] = ComponentStyle.IMAGE_MODE_NORMAL Then
					atlas.DrawSubImage(0, 0, style.imageX[imageType], style.imageY[imageType], style.imageWidth[imageType], style.imageHeight[imageType])
				End
			End
			
			' reset stuff if we changed it
			If style.drawBackground Or imageType >= 0 Then
				SetColor(255,255,255)
				SetAlpha(1)
			End
		End
	End
	
	' Returns whichever style is marked as "current".  Not all styles can be used this way.
	Method GetCurrentStyle:ComponentStyle()
		Return styleNormal
	End
	
	' Frees any resources used by this component, and propagates to its children.
	Method Dispose:Void(recursing:Bool = False)
		' we do an empty check first to save creating an enumerator object
		If Not children.IsEmpty() Then
			Local enum:AbstractEnumerator<Component> = children.Enumerator()
			While enum.HasNext()
				Local c:Component = enum.NextObject()
				c.Dispose(True)
				childrenZOrder.Remove(c)
				enum.Remove()
			End
		End
		DisposeNotify()
		Local p:Component = Self.parent
		If p.focusedChild = Self Then p.focusedChild = Null
		Local thisGui:GUI = FindGUI()
		If thisGui.CurrentFocus = Self Then thisGui.CurrentFocus = Null
		Self.parent = Null
		If Not recursing Then
			p.children.Remove(Self)
			p.childrenZOrder.Remove(Self)
		End
	End
	
	' Called when a component is first added to its parent.
	Method AddNotify:Void()
	End
	
	' Called when a component is removed from its parent via Dispose().
	Method DisposeNotify:Void()
	End
	
	' Fires off any assigned layout manager.  May be overridden to do a custom layout without using a manager.
	Method Layout:Void()
		If layoutManager <> Null Then
			Local gui:GUI = FindGUI()
			If gui = Null Or gui.LayoutEnabled Then layoutManager.Layout(Self)
		End
	End
	
	'FIXME: Shouldn't need Object casts for interfaces
	Method FindActionTarget:IActionListener()
		' traverse up the hierarchy and find the closest ActionListener to receive the actions
		Local comp:Component = Self
		While comp <> Null And IActionListener(Object(comp)) = Null
			comp = comp.parent
		End
		If comp <> Null Then Return IActionListener(Object(comp))
		' nfi why comp would be null here with android
		Local gui:GUI = FindGUI()
		Return gui
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
	
	' Loops through the parent hierarchy to attempt to find the parentGUI assigned to the desktop.
	Method FindGUI:GUI()
		Local comp:Component = Self
		While comp.parent <> Null
			comp = comp.parent
		End
		If GUIDesktop(comp) <> Null Then Return GUIDesktop(comp).parentGUI
		Return Null
	End
	
	' Moves this component to the top of the z-order, and tells its parent to do the same thing.
	Method BringToFront:Void()
		If parent = Null Then Return
		If parent.childrenZOrder.Size > 1 And Not zOrderLocked Then
			parent.childrenZOrder.Remove(Self)
			parent.childrenZOrder.Add(Self)
		End
		parent.BringToFront()
	End
	
	' Moves this component to the bottom of the z-order, but leaves its parent alone.
	Method SendToBack:Void()
		If parent = Null Then Return
		If parent.childrenZOrder.Size > 1 And Not zOrderLocked Then
			parent.childrenZOrder.Remove(Self)
			parent.childrenZOrder.AddFirst(Self)
		End
	End
	
	' Should be overridden by each component to provide a matching XML element name in the gui skin xml.
	Method GetSkinNodeName:String()
		Return SKIN_NODE_NONE
	End
	
	' Calculates the minimum amount of space required to display the entire contents of this component.  Used for layout managers.
	Method CalculateMinimum:Point(point:Point=Null, dontCreatePoint:Bool=False)
		If point = Null And Not dontCreatePoint Then point = New Point
		If layoutManager <> Null Then
			point = layoutManager.LayoutMinimum(Self, point)
			minimumWidth = point.x
			minimumHeight = point.y
			Return point
		End
		If point <> Null Then
			point.x = 0
			point.y = 0
		End
		minimumWidth = 0
		minimumHeight = 0
		Return point
	End
	
	Method Pack:Void()
		' if we have no layout manager, just find the bottom-right-most component
		If layoutManager = Null Then
			Local w:Int = 0, h:Int = 0
			For Local i:Int = 0 Until Children.Size
				Local child:Component = Children.Get(i)
				w = Max(w, child.X + child.Width)
				h = Max(h, child.Y + child.Height)
			Next
			SetSize(w, h)
		Else
			CalculateMinimum(Null,True)
			SetSize(minimumWidth,minimumHeight)
		End
	End
	
	' Fires an ActionPerformed event to the assigned ActionListener.  If no action listener is assigned, it loops through
	' the parent hierarchy until it finds a component that implements IActionListener, or it reaches the desktop.
	Method FireActionPerformed:Void(source:Component, action:String)
		' first do internal
		If internalActionListener <> Null Then internalActionListener.ActionPerformed(Self, action)
		' now user defined
		Local al:IActionListener = actionListener
		If al = Null Then al = FindActionTarget()
		If al <> Null Then al.ActionPerformed(Self, action)
		' if al is null here, something is seriously wrong!!!
	End
	
	Method FireMousePressed:Void(source:Component, x:Int, y:Int, button:Int, absoluteX:Int, absoluteY:Int)
		' first do internal
		If internalMouseListener <> Null Then internalMouseListener.MousePressed(source, x, y, button, absoluteX, absoluteY)
		' now user defined
		If mouseListener <> Null Then mouseListener.MousePressed(source, x, y, button, absoluteX, absoluteY)
	End
	
	Method FireMouseReleased:Void(source:Component, x:Int, y:Int, button:Int, absoluteX:Int, absoluteY:Int)
		' first do internal
		If internalMouseListener <> Null Then internalMouseListener.MouseReleased(source, x, y, button, absoluteX, absoluteY)
		' now user defined
		If mouseListener <> Null Then mouseListener.MouseReleased(source, x, y, button, absoluteX, absoluteY)
	End
	
	Method FireMouseClicked:Void(source:Component, x:Int, y:Int, button:Int, absoluteX:Int, absoluteY:Int)
		' first do internal
		If internalMouseListener <> Null Then internalMouseListener.MouseClicked(source, x, y, button, absoluteX, absoluteY)
		' now user defined
		If mouseListener <> Null Then mouseListener.MouseClicked(source, x, y, button, absoluteX, absoluteY)
	End
	
	Method FireMouseEntered:Void(source:Component, x:Int, y:Int, exitedComp:Component, absoluteX:Int, absoluteY:Int)
		' first do internal
		If internalMouseListener <> Null Then internalMouseListener.MouseEntered(source, x, y, exitedComp, absoluteX, absoluteY)
		' now user defined
		If mouseListener <> Null Then mouseListener.MouseEntered(source, x, y, exitedComp, absoluteX, absoluteY)
	End
	
	Method FireMouseExited:Void(source:Component, x:Int, y:Int, enteredComp:Component, absoluteX:Int, absoluteY:Int)
		' first do internal
		If internalMouseListener <> Null Then internalMouseListener.MouseExited(source, x, y, enteredComp, absoluteX, absoluteY)
		' now user defined
		If mouseListener <> Null Then mouseListener.MouseExited(source, x, y, enteredComp, absoluteX, absoluteY)
	End
	
	Method FireMouseMoved:Void(source:Component, x:Int, y:Int, absoluteX:Int, absoluteY:Int)
		' first do internal
		If internalMouseMotionListener <> Null Then internalMouseMotionListener.MouseMoved(source, x, y, absoluteX, absoluteY)
		' now user defined
		If mouseMotionListener <> Null Then mouseMotionListener.MouseMoved(source, x, y, absoluteX, absoluteY)
	End
	
	Method FireMouseDragged:Void(source:Component, x:Int, y:Int, button:Int, absoluteX:Int, absoluteY:Int)
		' first do internal
		If internalMouseMotionListener <> Null Then internalMouseMotionListener.MouseDragged(source, x, y, button, absoluteX, absoluteY)
		' now user defined
		If mouseMotionListener <> Null Then mouseMotionListener.MouseDragged(source, x, y, button, absoluteX, absoluteY)
	End
	
	Method FireKeyPressed:Void(source:Component, keychar:String, keycode:Int)
		' first do internal
		If internalKeyListener <> Null Then internalKeyListener.KeyPressed(source, keychar, keycode)
		' now user defined
		If keyListener <> Null Then keyListener.KeyPressed(source, keychar, keycode)
	End
	
	Method FireKeyReleased:Void(source:Component, keychar:String, keycode:Int)
		' first do internal
		If internalKeyListener <> Null Then internalKeyListener.KeyReleased(source, keychar, keycode)
		' now user defined
		If keyListener <> Null Then keyListener.KeyReleased(source, keychar, keycode)
	End
	
	Method FireKeyRepeated:Void(source:Component, keychar:String, keycode:Int)
		' first do internal
		If internalKeyListener <> Null Then internalKeyListener.KeyRepeated(source, keychar, keycode)
		' now user defined
		If keyListener <> Null Then keyListener.KeyRepeated(source, keychar, keycode)
	End
	
	Method FireKeyTyped:Void(source:Component, keychar:String, keycode:Int)
		' first do internal
		If internalKeyListener <> Null Then internalKeyListener.KeyTyped(source, keychar, keycode)
		' now user defined
		If keyListener <> Null Then keyListener.KeyTyped(source, keychar, keycode)
	End
	
	Method FireFocusGained:Void(source:Component, oldFocus:Component)
		' first do internal
		If internalFocusListener <> Null Then internalFocusListener.FocusGained(source, oldFocus)
		' now user defined
		If focusListener <> Null Then focusListener.FocusGained(source, oldFocus)
	End
	
	Method FireFocusLost:Void(source:Component, newFocus:Component)
		' first do internal
		If internalFocusListener <> Null Then internalFocusListener.FocusLost(source, newFocus)
		' now user defined
		If focusListener <> Null Then focusListener.FocusLost(source, newFocus)
	End
End ' Class Component

Class ComponentStyle
Public
' Constants
	Const IMAGE_NORMAL:Int = 0
	Const IMAGE_HOVER:Int = 1
	Const IMAGE_DOWN:Int = 2
	Const IMAGE_DISABLED:Int = 3
	Const IMAGE_FOCUS:Int = 4
	Const IMAGE_COUNT:Int = 5

	Const IMAGE_MODE_NORMAL:String = "normal"
	Const IMAGE_MODE_TILE:String = "tile"
	Const IMAGE_MODE_STRETCH:String = "stretch"
	Const IMAGE_MODE_GRID:String = "grid"

' Public fields
	Field drawBackground:Bool = True
	Field red:Int = 255
	Field green:Int = 255
	Field blue:Int = 255
	
	Field imageMode:String[IMAGE_COUNT]
	Field imageX:Int[IMAGE_COUNT]
	Field imageY:Int[IMAGE_COUNT]
	Field imageWidth:Int[IMAGE_COUNT]
	Field imageHeight:Int[IMAGE_COUNT]
	Field imageLeftMargin:Int[IMAGE_COUNT]
	Field imageRightMargin:Int[IMAGE_COUNT]
	Field imageTopMargin:Int[IMAGE_COUNT]
	Field imageBottomMargin:Int[IMAGE_COUNT]
	Field imageDrawTopLeft:Bool[IMAGE_COUNT]
	Field imageDrawTop:Bool[IMAGE_COUNT]
	Field imageDrawTopRight:Bool[IMAGE_COUNT]
	Field imageDrawLeft:Bool[IMAGE_COUNT]
	Field imageDrawCenter:Bool[IMAGE_COUNT]
	Field imageDrawRight:Bool[IMAGE_COUNT]
	Field imageDrawBottomLeft:Bool[IMAGE_COUNT]
	Field imageDrawBottom:Bool[IMAGE_COUNT]
	Field imageDrawBottomRight:Bool[IMAGE_COUNT]

	Field upSound:String = ""
	Field downSound:String = ""
	Field clickSound:String = ""
	Field enterSound:String = ""
	Field exitSound:String = ""
	
' Constructors
	Method New()
		For Local i% = 0 Until IMAGE_COUNT
			imageMode[i] = ""
		Next
	End

' Public methods
	Method ReadFromNode:Void(node:XMLElement)
		drawBackground = node.GetAttribute("drawBackground", "false") = "true"
		red = Int(node.GetAttribute("red", "255"))
		green = Int(node.GetAttribute("green", "255"))
		blue = Int(node.GetAttribute("blue", "255"))
		For Local subNode:XMLElement = EachIn node.Children
			Local imageType:Int = -1
			If subNode.Name = "enterSound" Then
				enterSound = subNode.GetAttribute("name")
			ElseIf subNode.Name = "exitSound" Then
				exitSound = subNode.GetAttribute("name")
			ElseIf subNode.Name = "downSound" Then
				downSound = subNode.GetAttribute("name")
			ElseIf subNode.Name = "upSound" Then
				upSound = subNode.GetAttribute("name")
			ElseIf subNode.Name = "clickSound" Then
				clickSound = subNode.GetAttribute("name")
			ElseIf subNode.Name = "normalImage" Then
				imageType = IMAGE_NORMAL
			ElseIf subNode.Name = "hoverImage" Then
				imageType = IMAGE_HOVER
			ElseIf subNode.Name = "downImage" Then
				imageType = IMAGE_DOWN
			ElseIf subNode.Name = "disabledImage" Then
				imageType = IMAGE_DISABLED
			ElseIf subNode.Name = "focusImage" Then
				imageType = IMAGE_FOCUS
			End
			
			If imageType >= 0 Then
				imageMode[imageType]            = subNode.GetAttribute("mode")
				imageX[imageType]               = Int(subNode.GetAttribute("x", "0"))
				imageY[imageType]               = Int(subNode.GetAttribute("y", "0"))
				imageWidth[imageType]           = Int(subNode.GetAttribute("width", "0"))
				imageHeight[imageType]          = Int(subNode.GetAttribute("height", "0"))
				imageLeftMargin[imageType]      = Int(subNode.GetAttribute("leftMargin", "0"))
				imageRightMargin[imageType]     = Int(subNode.GetAttribute("rightMargin", "0"))
				imageTopMargin[imageType]       = Int(subNode.GetAttribute("topMargin", "0"))
				imageBottomMargin[imageType]    = Int(subNode.GetAttribute("bottomMargin", "0"))
				imageDrawTopLeft[imageType]     = subNode.GetAttribute("drawTopLeft", "true") = "true"
				imageDrawTop[imageType]         = subNode.GetAttribute("drawTop", "true") = "true"
				imageDrawTopRight[imageType]    = subNode.GetAttribute("drawTopRight", "true") = "true"
				imageDrawLeft[imageType]        = subNode.GetAttribute("drawLeft", "true") = "true"
				imageDrawCenter[imageType]      = subNode.GetAttribute("drawCenter", "true") = "true"
				imageDrawRight[imageType]       = subNode.GetAttribute("drawRight", "true") = "true"
				imageDrawBottomLeft[imageType]  = subNode.GetAttribute("drawBottomLeft", "true") = "true"
				imageDrawBottom[imageType]      = subNode.GetAttribute("drawBottom", "true") = "true"
				imageDrawBottomRight[imageType] = subNode.GetAttribute("drawBottomRight", "true") = "true"
			End
		Next
	End
End ' Class ComponentStyle

Class GUIDesktop Extends Component
Private
' Private fields
	Field restrictWindows:Bool = True
	Field parentGUI:GUI
	
Public
' Properties
	' RestrictWindows is read/write
	Method RestrictWindows:Bool() Property
		Return restrictWindows
	End
	Method RestrictWindows:Void(restrictWindows:Bool) Property
		Self.restrictWindows = restrictWindows
	End
	
	' ParentGUI is read only
	Method ParentGUI:GUI() Property
		Return parentGUI
	End
	
' Constructors
	Method New()
		AssertError("Must pass a parent GUI.")
	End
	
	Method New(parentGUI:GUI)
		Super.New(Null)
		Self.parentGUI = parentGUI
	End
End ' Class GUIDesktop

Class Panel Extends Component
Private
' Private methods
	Method ApplySkin:Void()
		Super.ApplySkin()
		For Local i:Int = 0 Until children.Size
			children.Get(i).ApplySkin()
		Next
	End

Public
' Constructors
	Method New()
		NoParent()
	End
	
	Method New(parent:Component)
		Super.New(parent)
	End
End ' Class Panel

Class Window Extends Component
Private
' Private fields
	Field contentPane:Panel
	Field titlePane:Label
	Field buttonPane:Panel
	
	Field styleShadeButton:ComponentStyle
	Field styleMinimizeButton:ComponentStyle
	Field styleMaximizeButton:ComponentStyle
	Field styleRestoreButton:ComponentStyle
	Field styleCloseButton:ComponentStyle
	Field styleContentPane:ComponentStyle
	Field styleButtonPane:ComponentStyle
	Field styleTitlePane:ComponentStyle
	
	Field closeButton:Button
	Field maximizeButton:Button
	Field minimizeButton:Button
	Field shadeButton:Button
	Field internalWindowAdapter:InternalWindowAdapter
	
	' read from skin
	Field contentPaneLeft:Int
	Field contentPaneRight:Int
	Field contentPaneTop:Int
	Field contentPaneBottom:Int
	Field titlePaneLeft:Int
	Field titlePaneRight:Int
	Field titlePaneTop:Int
	Field titlePaneBottom:Int
	Field buttonPaneRight:Int
	Field buttonPaneTop:Int
	Field buttonPaneBottom:Int
	Field buttonWidth:Int
	Field buttonHeight:Int
	Field buttonMargin:Int
	Field titlePaneTextXOffset:Int
	Field titlePaneTextYOffset:Int
	
	' note: a window can be all three of these states at once!
	' priority is: minimized, maximized, shaded
	Field maximized:Bool = False
	Field minimized:Bool = False
	Field shaded:Bool = False
	Field dragX:Int, dragY:Int, originalX:Int, originalY:Int
	Field dragging:Bool = False
	
	Field normalX:Int, normalY:Int, normalWidth:Int, normalHeight:Int

	Field showMinimize:Bool = False
	Field showMaximize:Bool = False
	Field showShade:Bool = False
	Field showClose:Bool = True
	
	Field title:String = ""
	
' Private methods
	Method CreateButtonPane:Void()
		buttonPane = New Panel(Self)
		shadeButton = New Button(buttonPane)
		shadeButton.internalActionListener = internalWindowAdapter
		minimizeButton = New Button(buttonPane)
		minimizeButton.internalActionListener = internalWindowAdapter
		maximizeButton = New Button(buttonPane)
		maximizeButton.toggle = True
		maximizeButton.internalActionListener = internalWindowAdapter
		closeButton = New Button(buttonPane)
		closeButton.internalActionListener = internalWindowAdapter
	End
	
	Method CreateContentPane:Void()
		contentPane = New Panel(Self)
		contentPane.SetBackground(224,224,224)
	End
	
	Method CreateTitlePane:Void()
		titlePane = New Label(Self)
		titlePane.SetBackground(False)
		titlePane.internalMouseListener = internalWindowAdapter
		titlePane.internalMouseMotionListener = internalWindowAdapter
		titlePane.text = title
		titlePane.textRed = 0
		titlePane.textGreen = 0
		titlePane.textBlue = 0
		titlePane.textXOffset = titlePaneTextXOffset
		titlePane.textYOffset = titlePaneTextYOffset
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
			SetBounds(0, 0, 50, contentPaneTop)
		ElseIf maximized Then
			SetBounds(-contentPaneLeft, -titlePaneTop, parent.w+contentPaneLeft-contentPaneRight, parent.h+titlePaneTop-contentPaneBottom)
		ElseIf shaded Then
			SetBounds(normalX, normalY, normalWidth, contentPaneTop)
		End
	End
	
	Method ReadSkinFields:Void(node:XMLElement)
		Super.ReadSkinFields(node)
		contentPaneLeft   = Int(node.GetAttribute("contentPaneLeft","0"))
		contentPaneRight  = Int(node.GetAttribute("contentPaneRight","-1"))
		contentPaneTop    = Int(node.GetAttribute("contentPaneTop","0"))
		contentPaneBottom = Int(node.GetAttribute("contentPaneBottom","-1"))
		titlePaneLeft     = Int(node.GetAttribute("titlePaneLeft","0"))
		titlePaneRight    = Int(node.GetAttribute("titlePaneRight","-1"))
		titlePaneTop      = Int(node.GetAttribute("titlePaneTop","0"))
		titlePaneBottom   = Int(node.GetAttribute("titlePaneBottom","-1"))
		buttonPaneRight   = Int(node.GetAttribute("buttonPaneRight","-1"))
		buttonPaneTop     = Int(node.GetAttribute("buttonPaneTop","0"))
		buttonPaneBottom  = Int(node.GetAttribute("buttonPaneBottom","-1"))
		buttonWidth       = Int(node.GetAttribute("buttonWidth","17"))
		buttonHeight      = Int(node.GetAttribute("buttonHeight","17"))
		buttonMargin      = Int(node.GetAttribute("buttonMargin","1"))
		titlePaneTextXOffset = Int(node.GetAttribute("titlePaneTextXOffset","0"))
		titlePaneTextYOffset = Int(node.GetAttribute("titlePaneTextYOffset","0"))
	End
	
	Method LoadStyles:Void(node:XMLElement)
		Super.LoadStyles(node)
		If styleShadeButton <> Null Then shadeButton.StyleNormal = styleShadeButton
		If styleMinimizeButton <> Null Then minimizeButton.StyleNormal = styleMinimizeButton
		If styleMaximizeButton <> Null Then maximizeButton.StyleNormal = styleMaximizeButton
		If styleRestoreButton <> Null Then maximizeButton.StyleSelected = styleRestoreButton
		If styleCloseButton <> Null Then closeButton.StyleNormal = styleCloseButton
		If styleContentPane <> Null Then contentPane.StyleNormal = styleContentPane
		If styleTitlePane <> Null Then titlePane.StyleNormal = styleTitlePane
		If styleButtonPane <> Null Then buttonPane.StyleNormal = styleButtonPane
	End
	
Public
' Properties
	' Title is read/write and updates the title pane's text.
	Method Title:String() Property
		Return title
	End
	Method Title:Void(title:String) Property
		Self.title = title
		If titlePane <> Null Then titlePane.text = title
	End
	
	' ContentPane is read/write (but shouldn't really be replaced)
	Method ContentPane:Panel() Property
		Return contentPane
	End
	Method ContentPane:Void(contentPane:Panel) Property
		AssertNotNull(contentPane, "Content pane may not be null.")
		If Self.contentPane <> Null Then Self.contentPane.Dispose()
		Self.contentPane = contentPane
		Self.contentPane.ApplySkin()
	End
	
	' TitlePane is read only
	Method TitlePane:Label() Property
		Return titlePane
	End
	
	' ButtonPane is read only
	Method ButtonPane:Panel() Property
		Return buttonPane
	End
	
	' Maximized is read/write
	Method Maximized:Void(maximized:Bool) Property
		StoreWindowSize()
		Self.maximized = maximized
		UpdateWindowSize()
	End
	Method Maximized:Bool() Property
		Return maximized
	End
	
	' Minimized is read/write
	Method Minimized:Void(minimized:Bool) Property
		StoreWindowSize()
		Self.minimized = minimized
		UpdateWindowSize()
	End
	Method Minimized:Bool() Property
		Return minimized
	End
	
	' Shaded is read/write
	Method Shaded:Void(shaded:Bool) Property
		StoreWindowSize()
		Self.shaded = shaded
		UpdateWindowSize()
	End
	Method Shaded:Bool() Property
		Return shaded
	End
	
	' ShowMinimize is read/write and forces a Layout and ApplySkin
	Method ShowMinimize:Bool() Property
		Return showMinimize
	End
	Method ShowMinimize:Void(showMinimize:Bool) Property
		If Self.showMinimize <> showMinimize Then
			Self.showMinimize = showMinimize
			Layout()
			ApplySkin()
		End
	End
	
	' ShowMaximize is read/write and forces a Layout and ApplySkin
	Method ShowMaximize:Bool() Property
		Return showMaximize
	End
	Method ShowMaximize:Void(showMaximize:Bool) Property
		If Self.showMaximize <> showMaximize Then
			Self.showMaximize = showMaximize
			Layout()
			ApplySkin()
		End
	End
	
	' ShowShade is read/write and forces a Layout and ApplySkin
	Method ShowShade:Bool() Property
		Return showShade
	End
	Method ShowShade:Void(showShade:Bool) Property
		If Self.showShade <> showShade Then
			Self.showShade = showShade
			Layout()
			ApplySkin()
		End
	End
	
	' ShowClose is read/write and forces a Layout and ApplySkin
	Method ShowClose:Bool() Property
		Return showClose
	End
	Method ShowClose:Void(showClose:Bool) Property
		If Self.showClose <> showClose Then
			Self.showClose = showClose
			Layout()
			ApplySkin()
		End
	End
	
' Constructors
	Method New()
		AssertError("Must pass a desktop.")
	End
	
	Method New(parent:GUIDesktop)
		Super.New(parent)
		internalWindowAdapter = New InternalWindowAdapter(Self)
		CreateButtonPane()
		CreateContentPane()
		CreateTitlePane()
		ApplySkin()
		Layout()
	End
	
' Overrides Component
	' Lays out all the panels and buttons.
	Method Layout:Void()
		If contentPane = Null Then Return
		Local l:Int,r:Int,t:Int,b:Int
		If minimized Or shaded Then
			If contentPane <> Null Then contentPane.visible = False
		Else
			If contentPane <> Null Then
				contentPane.visible = True
				l = contentPaneLeft
				r = contentPaneRight
				t = contentPaneTop
				b = contentPaneBottom
				If l < 0 Then l += w
				If r < 0 Then r += w
				If t < 0 Then t += h
				If b < 0 Then b += h
				contentPane.SetBounds(l, t, r-l, b-t)
			End
		End
		Local buttonX:Int = 0
		If showShade Then
			shadeButton.visible = True
			shadeButton.SetBounds(buttonX,0,buttonWidth,buttonHeight)
			buttonX += buttonWidth + buttonMargin
		End
		If showMinimize Then
			minimizeButton.visible = True
			minimizeButton.SetBounds(buttonX,0,buttonWidth,buttonHeight)
			buttonX += buttonWidth + buttonMargin
		End
		If showMaximize Then
			maximizeButton.visible = True
			maximizeButton.SetBounds(buttonX,0,buttonWidth,buttonHeight)
			buttonX += buttonWidth + buttonMargin
		End
		If showClose Then
			closeButton.visible = True
			closeButton.SetBounds(buttonX,0,buttonWidth,buttonHeight)
			buttonX += buttonWidth + buttonMargin
		End
		If buttonX = 0 Then
			buttonPane.visible = False
		Else
			buttonPane.visible = True
			r = buttonPaneRight
			t = buttonPaneTop
			b = buttonPaneBottom
			If r < 0 Then r += w
			If t < 0 Then t += h
			If b < 0 Then b += h
			l = r - buttonX + buttonMargin
			buttonPane.SetBounds(l, t, r-l, b-t)
		End
		l = titlePaneLeft
		r = titlePaneRight
		t = titlePaneTop
		b = titlePaneBottom
		If l < 0 Then l += w
		If t < 0 Then t += h
		If b < 0 Then b += h
		If r < 0 Then
			If buttonPane.visible Then
				r += buttonPane.x
			Else
				r += w
			End
		End
		If titlePane <> Null Then
			titlePane.text = title
			titlePane.textXOffset = titlePaneTextXOffset
			titlePane.textYOffset = titlePaneTextYOffset
			titlePane.SetBounds(l, t, r-l, b-t)
		End
	End
	
	' Provide the node name of "window".
	Method GetSkinNodeName:String()
		Return SKIN_NODE_WINDOW
	End
	
	Method ApplySkin:Void()
		Super.ApplySkin()
		If contentPane <> Null Then contentPane.ApplySkin()
	End
	
	' Handles the custom styles.
	Method SetStyle:Void(name:String, style:ComponentStyle)
		If name = "contentPane" Then
			styleContentPane = style
		ElseIf name = "buttonPane" Then
			styleButtonPane = style
		ElseIf name = "titlePane" Then
			styleTitlePane = style
		ElseIf name = "shadeButton" Then
			styleShadeButton = style
		ElseIf name = "minimizeButton" Then
			styleMinimizeButton = style
		ElseIf name = "maximizeButton" Then
			styleMaximizeButton = style
		ElseIf name = "restoreButton" Then
			styleRestoreButton = style
		ElseIf name = "closeButton" Then
			styleCloseButton = style
		Else
			Super.SetStyle(name, style)
		End
	End
End ' Class Window

Class Label Extends Component
Private
' Private fields
	Field text:String
	Field textRed:Int, textGreen:Int, textBlue:Int
	Field textXOffset:Int = 0
	Field textYOffset:Int = 0
	Field textXAlign:Float = 0
	Field textYAlign:Float = 0
	Field useBaseline:Bool = True

	Field simpleNormalImage:GameImage
	
	Method ReadSkinFields:Void(node:XMLElement)
		Super.ReadSkinFields(node)
		textXOffset = Int(node.GetAttribute("textXOffset", "5"))
		textYOffset = Int(node.GetAttribute("textYOffset", "14"))
		textXAlign = Float(node.GetAttribute("textXAlign", "0"))
		textYAlign = Float(node.GetAttribute("textYAlign", "0"))
		useBaseline = (node.GetAttribute("useBaseline","true") = "true")
	End
	
Public
' Properties
	' Text is read/write
	Method Text:String() Property
		Return text
	End
	Method Text:Void(text:String) Property
		Self.text = text
	End
	
	' SimpleNormalImage is read/write
	Method SimpleNormalImage:GameImage() Property
		Return simpleNormalImage
	End
	Method SimpleNormalImage:Void(simpleNormalImage:GameImage) Property
		Self.simpleNormalImage = simpleNormalImage
	End
	
	' Convenience method to set the text, alignment, and offset all at once.
	Method SetText:Void(text:String, textXAlign:Float=0, textYAlign:Float=0, textXOffset:Int=0, textYOffset:Int=0)
		Self.text = text
		Self.textXAlign = textXAlign
		Self.textYAlign = textYAlign
		Self.textXOffset = textXOffset
		Self.textYOffset = textYOffset
	End
	
' Constructors
	Method New(parent:Component, simpleNormalImage:GameImage=Null)
		Super.New(parent)
		If simpleNormalImage <> Null Then
			CheckMidhandle(simpleNormalImage)
			Self.simpleNormalImage = simpleNormalImage
			Self.SetPreferredSize(simpleNormalImage.w, simpleNormalImage.h)
			Self.SetSize(simpleNormalImage.w, simpleNormalImage.h)
		End
		ApplySkin()
	End

' Overrides Component
	' Overrides Component.DrawComponent() to render the text.
	Method DrawComponent:Void()
		If simpleNormalImage <> Null Then
			simpleNormalImage.Draw(0, 0)
		Else
			Super.DrawComponent()
			If text.Length > 0 And FontName.Length > 0 And Font.fonts.Contains(FontName) Then
				If textXOffset = 0 And textYOffset = 0 Then
					Font.fonts.Get(FontName).DrawString(text, w*textXAlign, h*textYAlign, textXAlign, textYAlign, useBaseline, textRed, textGreen, textBlue)
				Else
					Font.fonts.Get(FontName).DrawString(text, textXOffset, textYOffset, textXAlign, textYAlign, useBaseline, textRed, textGreen, textBlue)
				End
			End
		End
	End
	
	Method GetSkinNodeName:String()
		Return SKIN_NODE_LABEL
	End
End ' Class Label

Class Button Extends Label
Private
' Private fields
	Field styleSelected:ComponentStyle = Null
	Field internalButtonAdapter:InternalButtonAdapter
	Field selected:Bool
	Field toggle:Bool
	
	Field simpleHoverImage:GameImage
	Field simpleDownImage:GameImage
	Field simpleSelectedNormalImage:GameImage
	Field simpleSelectedHoverImage:GameImage
	Field simpleSelectedDownImage:GameImage
	
' Private methods
	Method ReadSkinFields:Void(node:XMLElement)
		Super.ReadSkinFields(node)
		toggle = (node.GetAttribute("toggle","false") = "true")
	End

Public
' Properties
	' StyleSelected is read/write
	Method StyleSelected:ComponentStyle() Property
		If styleSelected = Null Then styleSelected = New ComponentStyle
		Return styleSelected
	End
	Method StyleSelected:Void(style:ComponentStyle) Property
		styleSelected = style
	End
	
	' Selected is read/write
	Method Selected:Bool() Property
		Return selected
	End
	Method Selected:Void(selected:Bool) Property
		Self.selected = selected
	End
	
	' Toggle is read/write
	Method Toggle:Bool() Property
		Return toggle
	End
	Method Toggle:Void(toggle:Bool) Property
		Self.toggle = toggle
	End
	
	' SimpleNormalImage is read/write
	Method SimpleNormalImage:GameImage() Property
		Return simpleNormalImage
	End
	Method SimpleNormalImage:Void(simpleNormalImage:GameImage) Property
		Self.simpleNormalImage = simpleNormalImage
	End
	
	' SimpleHoverImage is read/write
	Method SimpleHoverImage:GameImage() Property
		Return simpleHoverImage
	End
	Method SimpleHoverImage:Void(simpleHoverImage:GameImage) Property
		Self.simpleHoverImage = simpleHoverImage
	End
	
	' SimpleDownImage is read/write
	Method SimpleDownImage:GameImage() Property
		Return simpleDownImage
	End
	Method SimpleDownImage:Void(simpleDownImage:GameImage) Property
		Self.simpleDownImage = simpleDownImage
	End
	
	' SimpleSelectedNormalImage is read/write
	Method SimpleSelectedNormalImage:GameImage() Property
		Return simpleSelectedNormalImage
	End
	Method SimpleSelectedNormalImage:Void(simpleSelectedNormalImage:GameImage) Property
		Self.simpleSelectedNormalImage = simpleSelectedNormalImage
	End
	
	' SimpleSelectedHoverImage is read/write
	Method SimpleSelectedHoverImage:GameImage() Property
		Return simpleSelectedHoverImage
	End
	Method SimpleSelectedHoverImage:Void(simpleSelectedHoverImage:GameImage) Property
		Self.simpleSelectedHoverImage = simpleSelectedHoverImage
	End
	
	' SimpleSelectedDownImage is read/write
	Method SimpleSelectedDownImage:GameImage() Property
		Return simpleSelectedDownImage
	End
	Method SimpleSelectedDownImage:Void(simpleSelectedDownImage:GameImage) Property
		Self.simpleSelectedDownImage = simpleSelectedDownImage
	End
	
' Constructors
	Method New()
		NoParent()
	End
	
	Method New(parent:Component, simpleNormalImage:GameImage=Null, simpleHoverImage:GameImage=Null, simpleDownImage:GameImage=Null)
		Super.New(parent)
		focusable = True
		internalButtonAdapter = New InternalButtonAdapter(Self)
		internalMouseListener = internalButtonAdapter
		If simpleDownImage <> Null Then
			CheckMidhandle(simpleDownImage)
			Self.simpleDownImage = simpleDownImage
		End
		If simpleHoverImage <> Null Then
			CheckMidhandle(simpleHoverImage)
			Self.simpleHoverImage = simpleHoverImage
		End
		If simpleNormalImage <> Null Then
			CheckMidhandle(simpleNormalImage)
			Self.simpleNormalImage = simpleNormalImage
			Self.SetPreferredSize(simpleNormalImage.w, simpleNormalImage.h)
			Self.SetSize(simpleNormalImage.w, simpleNormalImage.h)
		End
		ApplySkin()
	End
	
' Overrides Component
	Method DrawComponent:Void()
		Local simple:GameImage = Null
		If selected Then
			If mouseDown And simpleSelectedDownImage <> Null Then
				simple = simpleSelectedDownImage
			ElseIf mouseHover And simpleSelectedHoverImage <> Null Then
				simple = simpleSelectedHoverImage
			ElseIf simpleSelectedNormalImage <> Null Then
				simple = simpleSelectedNormalImage
			End
		Else
			If mouseDown And simpleDownImage <> Null Then
				simple = simpleDownImage
			ElseIf mouseHover And simpleHoverImage <> Null Then
				simple = simpleHoverImage
			End
		End
		If simple <> Null Then
			simple.Draw(0, 0)
		Else
			Super.DrawComponent()
		End
	End
	
	Method GetStyle:ComponentStyle(name:String)
		If name = "selected" Then Return styleSelected
		Return Super.GetStyle(name)
	End
	
	Method SetStyle:Void(name:String, style:ComponentStyle)
		If name = "selected" Then
			styleSelected = style
		Else
			Super.SetStyle(name, style)
		End
	End
	
	Method GetCurrentStyle:ComponentStyle()
		If selected And styleSelected <> Null Then Return styleSelected
		Return Super.GetCurrentStyle()
	End
	
	Method GetSkinNodeName:String()
		Return SKIN_NODE_BUTTON
	End
End ' Class Button

Class RadioButton Extends Button
Private
' Private fields
	Field radioGroup:RadioGroup
	Field radioValue:String

Public
' Properties
	' AssignedRadioGroup is read only (remove the RadioButton through the group itself)
	Method AssignedRadioGroup:RadioGroup() Property
		Return radioGroup
	End
	
	' RadioValue is read/write
	Method RadioValue:String() Property
		Return radioValue
	End
	Method RadioValue:Void(radioValue:String) Property
		If radioGroup <> Null And radioGroup.currentValue = Self.radioValue Then
			radioGroup.currentValue = radioValue
		End
		Self.radioValue = radioValue
	End
	
' Constructors
	Method New()
		NoParent()
	End
	
	Method New(parent:Component, simpleNormalImage:GameImage=Null, simpleHoverImage:GameImage=Null, simpleDownImage:GameImage=Null,
			simpleSelectedNormalImage:GameImage=Null, simpleSelectedHoverImage:GameImage=Null, simpleSelectedDownImage:GameImage=Null)
		Super.New(parent, simpleNormalImage, simpleHoverImage, simpleDownImage)
		If simpleSelectedNormalImage <> Null Then
			Self.simpleSelectedNormalImage = simpleSelectedNormalImage
			CheckMidhandle(simpleSelectedNormalImage)
		End
		If simpleSelectedHoverImage <> Null Then
			Self.simpleSelectedHoverImage = simpleSelectedHoverImage
			CheckMidhandle(simpleSelectedHoverImage)
		End
		If simpleSelectedDownImage <> Null Then
			Self.simpleSelectedDownImage = simpleSelectedDownImage
			CheckMidhandle(simpleSelectedDownImage)
		End
	End

' Overrides Component
	' Overrides Component.GetSkinNodeName() to return the node name of "radio".	
	Method GetSkinNodeName:String()
		Return SKIN_NODE_RADIO
	End
End ' Class RadioButton

Class Checkbox Extends Button
Public
' Constructors
	Method New()
		NoParent()
	End
	
	Method New(parent:Component, simpleNormalImage:GameImage=Null, simpleHoverImage:GameImage=Null, simpleDownImage:GameImage=Null,
			simpleSelectedNormalImage:GameImage=Null, simpleSelectedHoverImage:GameImage=Null, simpleSelectedDownImage:GameImage=Null)
		Super.New(parent, simpleNormalImage, simpleHoverImage, simpleDownImage)
		If simpleSelectedNormalImage <> Null Then
			Self.simpleSelectedNormalImage = simpleSelectedNormalImage
			CheckMidhandle(simpleSelectedNormalImage)
		End
		If simpleSelectedHoverImage <> Null Then
			Self.simpleSelectedHoverImage = simpleSelectedHoverImage
			CheckMidhandle(simpleSelectedHoverImage)
		End
		If simpleSelectedDownImage <> Null Then
			Self.simpleSelectedDownImage = simpleSelectedDownImage
			CheckMidhandle(simpleSelectedDownImage)
		End
	End
	
' Overrides Component
	' Overrides Component.GetSkinNodeName() to return the node name of "checkbox".	
	Method GetSkinNodeName:String()
		Return SKIN_NODE_CHECKBOX
	End
End ' Class Checkbox

Class RadioGroup
Private
' Private fields
	Field buttons:ArrayList<RadioButton> = New ArrayList<RadioButton>
	Field currentValue:String
	
Public
' Properties
	' RadioButtons is read only
	Method RadioButtons:ArrayList<RadioButton>() Property
		Return buttons
	End
	
	' SelectedButton is read/write
	Method SelectedButton:RadioButton() Property
		For Local b:RadioButton = EachIn buttons
			If b.radioValue = currentValue Then Return b
		Next
		Return Null
	End
	Method SelectedButton:Void(button:RadioButton) Property
		Local oldValue:String = currentValue
		Local oldButton:Button = Null
		For Local b:RadioButton = EachIn buttons
			If b.selected Then oldButton = b
			b.selected = (b = button)
			If b.selected Then currentValue = b.radioValue
		Next
		If oldButton <> button Then ValueChanged(currentValue, RadioButton(button), oldValue, RadioButton(oldButton))
	End
	
	' SelectedValue is read/write
	Method SelectedValue:String() Property
		Return currentValue
	End
	Method SelectedValue:Void(value:String) Property
		Local oldValue:String = currentValue
		Local oldButton:Button = Null
		Local newButton:Button = Null
		For Local b:RadioButton = EachIn buttons
			If b.selected Then oldButton = b
			b.selected = (b.radioValue = value)
			If b.selected Then
				currentValue = value
				newButton = b
			End
		Next
		If oldValue <> value Then ValueChanged(currentValue, RadioButton(newButton), oldValue, RadioButton(oldButton))
	End
	
' Public methods
	Method AddButton:Void(button:RadioButton, value:String)
		button.radioValue = value
		button.radioGroup = Self
		buttons.Add(button)
	End
	
	Method RemoveButton:Void(button:RadioButton)
		button.radioValue = ""
		button.radioGroup = Null
		buttons.Remove(button)
	End
	
	Method ValueChanged:Void(newValue:String, newButton:RadioButton, oldValue:String, oldButton:RadioButton)
	End
End

Class Slider Extends Component
Public
' Constants
	Const SLIDER_HORIZONTAL:Int = 0
	Const SLIDER_VERTICAL:Int = 1
	Const SLIDER_DIRECTION_TL_TO_BR:Int = 0 ' min is top or left, max is bottom or right
	Const SLIDER_DIRECTION_BR_TO_TL:Int = 1 ' min is bottom or right, max is top or left
	
Private
' Private fields
	Field buttonUpLeft:Button ' the button used for up and left
	Field buttonDownRight:Button ' the button used for down and right
	Field handle:Label
	Field bar:Label
	Field showButtons:Bool
	Field orientation:Int = SLIDER_HORIZONTAL
	Field direction:Int = SLIDER_DIRECTION_TL_TO_BR
	
	Field dragX:Int, dragY:Int, originalX:Int, originalY:Int
	Field dragging:Bool = False
	
	Field styleLeftButton:ComponentStyle = New ComponentStyle
	Field styleRightButton:ComponentStyle = New ComponentStyle
	Field styleTopButton:ComponentStyle = New ComponentStyle
	Field styleBottomButton:ComponentStyle = New ComponentStyle
	Field styleHorizontalHandle:ComponentStyle = New ComponentStyle
	Field styleVerticalHandle:ComponentStyle = New ComponentStyle
	Field styleHorizontalBar:ComponentStyle = New ComponentStyle
	Field styleVerticalBar:ComponentStyle = New ComponentStyle
	
	Field internalSliderAdapter:InternalSliderAdapter
	
	Field leftButtonWidth:Int
	Field leftButtonHeight:Int
	Field rightButtonWidth:Int
	Field rightButtonHeight:Int
	Field topButtonWidth:Int
	Field topButtonHeight:Int
	Field bottomButtonWidth:Int
	Field bottomButtonHeight:Int
	
	Field minValue:Int = 0
	Field maxValue:Int = 100
	Field value:Int = 50
	Field tickInterval:Int = 10
	Field handleMargin:Int = 10
	Field handleSize:Int = 10
	Field buttonSize:Int = 15
	Field snapToTicks:Bool = True

' Private methods
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
			FireActionPerformed(Self, ACTION_VALUE_CHANGED)
		End
	End
	
	Method UpdateStyles:Void()
		If orientation = SLIDER_HORIZONTAL Then
			buttonUpLeft.StyleNormal = styleLeftButton
			buttonDownRight.StyleNormal = styleRightButton
			bar.StyleNormal = styleHorizontalBar
			handle.StyleNormal = styleHorizontalHandle
		Else
			buttonUpLeft.StyleNormal = styleTopButton
			buttonDownRight.StyleNormal = styleBottomButton
			bar.StyleNormal = styleVerticalBar
			handle.StyleNormal = styleVerticalHandle
		End
	End
	
	Method ReadSkinFields:Void(node:XMLElement)
		handleMargin = Int(node.GetAttribute("handleMargin", "8"))
		leftButtonWidth = Int(node.GetAttribute("leftButtonWidth", "15"))
		leftButtonHeight = Int(node.GetAttribute("leftButtonHeight", "16"))
		rightButtonWidth = Int(node.GetAttribute("rightButtonWidth", "15"))
		rightButtonHeight = Int(node.GetAttribute("rightButtonHeight", "16"))
		topButtonWidth = Int(node.GetAttribute("topButtonWidth", "16"))
		topButtonHeight = Int(node.GetAttribute("topButtonHeight", "15"))
		bottomButtonWidth = Int(node.GetAttribute("bottomButtonWidth", "16"))
		bottomButtonHeight = Int(node.GetAttribute("bottomButtonHeight", "15"))
	End
	
Public
' Properties
	' ShowButtons is read/write and fires off a Layout()
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
	
	' Orientation is read/write and fires off a Layout()
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
	
	' Direction is read/write and fires off a Layout()
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
	
	' MinValue is read/write
	Method MinValue:Int() Property
		Return minValue
	End
	Method MinValue:Void(minValue:Int) Property
		Self.minValue = minValue
	End
	
	' MaxValue is read/write
	Method MaxValue:Int() Property
		Return maxValue
	End
	Method MaxValue:Void(maxValue:Int) Property
		Self.maxValue = maxValue
	End
	
	' Value is read/write
	Method Value:Int() Property
		Return value
	End
	Method Value:Void(value:Int) Property
		Self.value = value
	End
	
	' TickInterval is read/write
	Method TickInterval:Int() Property
		Return tickInterval
	End
	Method TickInterval:Void(tickInterval:Int) Property
		Self.tickInterval = tickInterval
	End
	
	' SnapToTicks is read/write
	Method SnapToTicks:Bool() Property
		Return snapToTicks
	End
	Method SnapToTicks:Void(snapToTicks:Bool) Property
		Self.snapToTicks = snapToTicks
	End

' Constructors
	Method New()
		NoParent()
	End
	
	Method New(parent:Component)
		Super.New(parent)
		internalSliderAdapter = New InternalSliderAdapter(Self)
		
		bar = New Label(Self)
		bar.zOrderLocked = True
		bar.internalMouseListener = internalSliderAdapter
		bar.internalMouseMotionListener = internalSliderAdapter
		
		buttonUpLeft = New Button(Self)
		buttonUpLeft.internalActionListener = internalSliderAdapter
		buttonUpLeft.zOrderLocked = True
		
		buttonDownRight = New Button(Self)
		buttonDownRight.internalActionListener = internalSliderAdapter
		buttonDownRight.zOrderLocked = True
		
		handle = New Label(Self)
		handle.internalMouseListener = internalSliderAdapter
		handle.internalMouseMotionListener = internalSliderAdapter
		handle.zOrderLocked = True
		
		buttonUpLeft.visible = False
		buttonDownRight.visible = False
		
		ApplySkin()
	End

' Public methods
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
		If amount = 0 Then Return False
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
			FireActionPerformed(Self, ACTION_VALUE_CHANGED)
		End
		Return value <> oldValue
	End

' Overrides Component
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
	
	Method Layout:Void()
		Local startVal:Int, endVal:Int
		If showButtons Then
			If orientation = SLIDER_HORIZONTAL Then
				buttonUpLeft.SetBounds(0, 0, leftButtonWidth, leftButtonHeight)
				buttonDownRight.SetBounds(Self.w - rightButtonWidth, 0, rightButtonWidth, rightButtonHeight)
				bar.SetBounds(buttonUpLeft.w, 0, Self.w - leftButtonWidth - rightButtonWidth, Self.h)
				startVal = leftButtonWidth+handleMargin
				endVal = startVal + bar.w - 2*handleMargin
			Else
				buttonUpLeft.SetBounds(0, 0, topButtonWidth, topButtonHeight)
				buttonDownRight.SetBounds(0, Self.h - bottomButtonHeight, bottomButtonWidth, bottomButtonHeight)
				bar.SetBounds(0, buttonUpLeft.h, Self.w, Self.h - topButtonHeight - bottomButtonHeight)
				startVal = topButtonHeight+handleMargin
				endVal = startVal + bar.h - 2*handleMargin
			End
			buttonUpLeft.visible = True
			buttonDownRight.visible = True
		Else
			buttonUpLeft.visible = False
			buttonDownRight.visible = False
		End
		Local fraction:Float = Float(value-minValue)/Float(maxValue-minValue)
		Local currentVal:Int
		If orientation = SLIDER_HORIZONTAL Then
			currentVal = startVal + (endVal - startVal) * fraction
			handle.SetBounds(currentVal-handleSize/2, 0, handleSize, Self.h)
		Else
			currentVal = startVal + (endVal - startVal) * fraction
			handle.SetBounds(0, currentVal-handleSize/2, Self.w, handleSize)
		End
	End
	
	Method GetSkinNodeName:String()
		Return SKIN_NODE_SLIDER
	End
End ' Class Slider



' private internal classes
Private

' handles all the internal events for the Slider component
Class InternalSliderAdapter Implements IActionListener, IMouseListener, IMouseMotionListener
Private
' Private fields
	Field slider:Slider
	
Public
' Constructors
	Method New(slider:Slider)
		Self.slider = slider
	End
	
' Implements IActionListener
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
	
' Implements IMouseListener
	Method MousePressed:Void(source:Component, x:Int, y:Int, button:Int, absoluteX:Int, absoluteY:Int)
		If slider.dragging Then Return
		slider.dragging = True
		If source = slider.handle Then
			slider.DoDrag(slider.handle.x + x, slider.handle.y + y)
		ElseIf source = slider.bar Then
			slider.DoDrag(slider.bar.x + x, slider.bar.y + y)
		End
	End
	
	Method MouseReleased:Void(source:Component, x:Int, y:Int, button:Int, absoluteX:Int, absoluteY:Int)
		slider.dragging = False
		If source = slider.handle Then
			slider.DoDrag(slider.handle.x + x, slider.handle.y + y)
		ElseIf source = slider.bar Then
			slider.DoDrag(slider.bar.x + x, slider.bar.y + y)
		End
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
		If Not slider.dragging Then Return
		If source = slider.handle Then
			slider.DoDrag(slider.handle.x + x, slider.handle.y + y)
		ElseIf source = slider.bar Then
			slider.DoDrag(slider.bar.x + x, slider.bar.y + y)
		End
	End
End ' Class InternalSliderAdapter

' handles all the internal events for the Window component
Class InternalWindowAdapter Implements IActionListener, IMouseListener, IMouseMotionListener
Private
' Private fields
	Field window:Window

Public
' Constructors
	Method New(window:Window)
		Self.window = window
	End

' Implements IActionListener
	Method ActionPerformed:Void(source:Component, action:String)
		If source = window.closeButton And action = ACTION_CLICKED Then
			window.Dispose()
		ElseIf source = window.maximizeButton And action = ACTION_CLICKED Then
			window.Maximized = Not window.Maximized
		ElseIf source = window.minimizeButton And action = ACTION_CLICKED Then
			'window.Minimized = True ' TODO: disabled until positioning of minimised windows is done
		ElseIf source = window.shadeButton And action = ACTION_CLICKED Then
			window.Shaded = Not window.Shaded
		End
	End
	
' Implements IMouseListener
	Method MousePressed:Void(source:Component, x:Int, y:Int, button:Int, absoluteX:Int, absoluteY:Int)
		If window.dragging Then Return
		If window.maximized Or window.minimized Then Return
		window.dragging = True
		window.dragX = absoluteX
		window.dragY = absoluteY
		window.originalX = window.x
		window.originalY = window.y
	End
	
	Method MouseReleased:Void(source:Component, x:Int, y:Int, button:Int, absoluteX:Int, absoluteY:Int)
		window.dragging = False
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
		If window.maximized Or window.minimized Then window.dragging = False
		If Not window.dragging Then Return
		Local dx:Int = absoluteX-window.dragX, dy:Int = absoluteY-window.dragY
		Local newX:Int = window.originalX + dx, newY:Int = window.originalY + dy
		
		If GUIDesktop(window.parent) <> Null And GUIDesktop(window.parent).restrictWindows Then
			If newX + window.w > window.parent.w Then newX = window.parent.w - window.w
			If newY + window.h > window.parent.h Then newY = window.parent.h - window.h
			If newX < 0 Then newX = 0
			If newY < 0 Then newY = 0
		End
		window.SetLocation(newX, newY)
	End
End ' Class InternalWindowAdapter

' handles all the internal events for the Button component
Class InternalButtonAdapter Implements IMouseListener
Private
' Private fields
	Field button:Button
	
' Private methods
	Method DoClick:Void(source:Component, x:Int, y:Int, button:Int, absoluteX:Int, absoluteY:Int)
		' is it a radio button?
		If RadioButton(Self.button) <> Null And RadioButton(Self.button).radioGroup <> Null Then
			RadioButton(Self.button).radioGroup.SelectedButton = RadioButton(Self.button)
		' is it a toggle button?
		ElseIf Self.button.toggle Then
			Self.button.selected = Not Self.button.selected
		End
		Self.button.FireActionPerformed(Self.button, ACTION_CLICKED)
	End
	
Public
' Constructors
	Method New(button:Button)
		Self.button = button
	End
	
' Implements IMouseListener
	Method MouseClicked:Void(source:Component, x:Int, y:Int, button:Int, absoluteX:Int, absoluteY:Int)
#If TARGET="ios" Or TARGET="android" Then
		If Self.button.simpleNormalImage = Null Then DoClick(source, x, y, button, absoluteX, absoluteY)
#Else
		DoClick(source, x, y, button, absoluteX, absoluteY)
#End
	End
	
	Method MousePressed:Void(source:Component, x:Int, y:Int, button:Int, absoluteX:Int, absoluteY:Int)
#If TARGET="ios" Or TARGET="android" Then
		If Self.button.simpleNormalImage <> Null Then DoClick(source, x, y, button, absoluteX, absoluteY)
#End
	End
	
	Method MouseReleased:Void(source:Component, x:Int, y:Int, button:Int, absoluteX:Int, absoluteY:Int)
	End
	
	Method MouseEntered:Void(source:Component, x:Int, y:Int, exitedComp:Component, absoluteX:Int, absoluteY:Int)
	End
	
	Method MouseExited:Void(source:Component, x:Int, y:Int, enteredComp:Component, absoluteX:Int, absoluteY:Int)
	End
End ' Class InternalButtonAdapter

' This function exists to prevent developers from instantiating a component without a parent (since Monkey always provides an empty default constructor)
Function NoParent:Void()
	AssertError("Must pass a parent component.")
End

Function CheckMidhandle:Void(img:GameImage)
	If img.MidHandle Then
		AssertError("Components may not use a midhandled image.")
	End
End
