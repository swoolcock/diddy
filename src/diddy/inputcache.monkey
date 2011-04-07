Strict

Import mojo

Class InputCache
	Const TOUCH_COUNT:Int = 32
	Const MOUSE_COUNT:Int = 3
	Const KEY_COUNT:Int = 512
	
	' TouchHit() for 0-31
	Field touchHit:Int[] = New Int[TOUCH_COUNT]
	' TouchDown() for 0-31
	Field touchDown:Int[] = New Int[TOUCH_COUNT]
	' TouchDown() is false but was true last loop
	Field touchReleased:Int[] = New Int[TOUCH_COUNT]
	' the number of TouchDown() calls that returned true
	Field touchDownCount:Int
	' thte number of TouchHit() calls that returned true
	Field touchHitCount:Int
	' the number of released touches
	Field touchReleasedCount:Int
	' the highest index of TouchDown() that returned true
	Field maxTouchDown:Int = -1
	' the highest index of TouchHit() that returned true
	Field maxTouchHit:Int = -1
	' the highest index of a released touch
	Field maxTouchReleased:Int = -1
	' the lowest index of TouchDown() that returned true
	Field minTouchDown:Int = -1
	' the lowest index of TouchHit() that returned true
	Field minTouchHit:Int = -1
	' the lowest index of a released touch
	Field minTouchReleased:Int = -1
	' TouchX() And TouchY() For 0-31
	Field touchX:Float[] = New Float[TOUCH_COUNT]
	Field touchY:Float[] = New Float[TOUCH_COUNT]
	' should we monitor touch events?
	Field monitorTouch:Bool = False
	
	' MouseHit() for 0-2
	Field mouseHit:Int[] = New Int[MOUSE_COUNT]
	' MouseDown() for 0-2
	Field mouseDown:Int[] = New Int[MOUSE_COUNT]
	' MouseDown() is false but was true last loop
	Field mouseReleased:Int[] = New Int[MOUSE_COUNT]
	' MouseX() And MouseY()
	Field mouseX:Int
	Field mouseY:Int
	' is any mouse button down?
	Field mouseDownCount:Int
	' was any mouse button hit?
	Field mouseHitCount:Int
	' was any mouse button released?
	Field mouseReleasedCount:Int
	' should we monitor mouse events?
	Field monitorMouse:Bool = False
	
	' KeyHit() for each monitored key
	Field keyHit:Int[] = New Int[KEY_COUNT]
	' KeyDown() for each monitored key
	Field keyDown:Int[] = New Int[KEY_COUNT]
	' KeyDown() is false but was true last loop
	Field keyReleased:Int[] = New Int[KEY_COUNT]
	' is any monitored key down?
	Field keyDownCount:Int
	' was any monitored key hit?
	Field keyHitCount:Int
	' was any monitored key released?
	Field keyReleasedCount:Int
	' If true, we should monitor that key (defaults To false)
	Field monitorKey:Bool[] = New Bool[KEY_COUNT]
	' the number of keys we are monitoring; this is so we can skip key checks if we aren't monitoring any
	Field monitorKeyCount:Int = 0
	
	Method New()
		#If TARGET="android" Or TARGET="ios"
			monitorTouch = True
			monitorMouse = False
		#Else
			monitorTouch = False
			monitorMouse = True
		#End
	End
	
	Method MonitorNothing:Void()
		' clear mouse
		monitorMouse = False
		mouseDownCount = 0
		mouseHitCount = 0
		mouseReleasedCount = 0
		
		' clear touch
		monitorTouch = False
		touchDownCount = 0
		touchHitCount = 0
		touchReleasedCount = 0
		maxTouchDown = -1
		maxTouchHit = -1
		maxTouchReleased = -1
		minTouchDown = -1
		minTouchHit = -1
		minTouchReleased = -1
		
		' clear keys
		monitorKeyCount = 0
		For Local i:Int = 0 Until KEY_COUNT
			monitorKey[i] = False
			keyHit[i] = 0
			keyDown[i] = 0
			keyReleased[i] = 0
		Next
	End
	
	Method MonitorAllKeys:Void(val:Bool=True)
		If val Then
			monitorKeyCount = KEY_COUNT
		Else
			monitorKeyCount = 0
		End
		For Local i:Int = 0 Until KEY_COUNT
			monitorKey[i] = val
			keyHit[i] = 0
			keyDown[i] = 0
			keyReleased[i] = 0
		Next
	End
	
	Method MonitorKey:Void(keyNum:Int, val:Bool=True)
		If val And Not monitorKey[keyNum] Then
			monitorKeyCount += 1
		ElseIf Not val And monitorKey[keyNum] Then
			monitorKeyCount -= 1
		End
		monitorKey[keyNum] = val
		keyHit[keyNum] = 0
		keyDown[keyNum] = 0
		keyReleased[keyNum] = 0
	End
	
	Method MonitorTouch:Void(val:Bool=True)
		monitorTouch = val
		touchDownCount = 0
		touchHitCount = 0
		touchReleasedCount = 0
		maxTouchDown = -1
		maxTouchHit = -1
		maxTouchReleased = -1
		minTouchDown = -1
		minTouchHit = -1
		minTouchReleased = -1
	End
	
	Method MonitorMouse:Void(val:Bool=True)
		monitorMouse = val
		mouseDownCount = 0
		mouseHitCount = 0
		mouseReleasedCount = 0
	End
	
	Method ReadInput:Void()
		Local newval:Int = 0
		
		' get the touch events
		If monitorTouch Then
			touchDownCount = 0
			touchHitCount = 0
			touchReleasedCount = 0
			maxTouchDown = -1
			maxTouchHit = -1
			maxTouchReleased = -1
			minTouchDown = -1
			minTouchHit = -1
			minTouchReleased = -1
			For Local i:Int = 0 Until TOUCH_COUNT
				touchHit[i] = TouchHit(i)
				newval = TouchDown(i)
				touchReleased[i] = (touchDown[i] And Not newval)
				touchDown[i] = newval
				touchX[i] = TouchX(i)
				touchY[i] = TouchY(i)
				If touchDown[i] Then
					touchDownCount += 1
					If minTouchDown < 0 Then minTouchDown = i
					maxTouchDown = i
				End
				If touchHit[i] Then
					touchHitCount += 1
					If minTouchHit < 0 Then minTouchHit = i
					maxTouchHit = i
				End
				If touchReleased[i] Then
					touchReleasedCount += 1
					If minTouchReleased < 0 Then minTouchReleased = i
					maxTouchReleased = i
				End
			Next
		End
		
		' get the mouse events
		If monitorMouse Then
			mouseDownCount = 0
			mouseHitCount = 0
			mouseReleasedCount = 0
			For Local i:Int = 0 Until MOUSE_COUNT
				mouseHit[i] = MouseHit(i)
				newval = MouseDown(i)
				mouseReleased[i] = (mouseDown[i] And Not newval)
				mouseDown[i] = newval
				If mouseDown[i] Then mouseDownCount += 1
				If mouseHit[i] Then mouseHitCount += 1
				If mouseReleased[i] Then mouseReleasedCount += 1
			Next
		End
		
		' get the key events for those we are monitoring
		keyDownCount = 0
		keyHitCount = 0
		keyReleasedCount = 0
		If monitorKeyCount > 0 Then
			For Local i:Int = 0 Until KEY_COUNT
				If monitorKey[i] Then
					keyHit[i] = KeyHit(i)
					newval = KeyDown(i)
					keyReleased[i] = (keyDown[i] And Not newval)
					keyDown[i] = newval
					If keyDown[i] Then keyDownCount += 1
					If keyHit[i] Then keyHitCount += 1
					If keyReleased[i] Then keyReleasedCount += 1
				End
			Next
		End
	End
End

