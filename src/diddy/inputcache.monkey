Strict

Import mojo
Import assert
Import functions

Const EVENT_KEY_DOWN:Int = 1
Const EVENT_KEY_RELEASED:Int = 2
Const EVENT_KEY_HIT:Int = 3

Class InputCache
Private
	Field keyHitEnumerator:KeyEventEnumerator
	Field keyDownEnumerator:KeyEventEnumerator
	Field keyReleasedEnumerator:KeyEventEnumerator
	Field keyHitWrapper:EnumWrapper<KeyEventEnumerator>
	Field keyDownWrapper:EnumWrapper<KeyEventEnumerator>
	Field keyReleasedWrapper:EnumWrapper<KeyEventEnumerator>
	
Public
	Const TOUCH_COUNT:Int = 32
	Const MOUSE_COUNT:Int = 3
	Const KEY_COUNT:Int = 512
	
	' TouchHit() for 0-31
	Field touchHit:Int[] = New Int[TOUCH_COUNT]
	' The time it was hit
	Field touchHitTime:Int[] = New Int[TOUCH_COUNT]
	' TouchDown() for 0-31
	Field touchDown:Int[] = New Int[TOUCH_COUNT]
	' The time it was first down
	Field touchDownTime:Int[] = New Int[TOUCH_COUNT]
	' TouchDown() is false but was true last loop
	Field touchReleased:Int[] = New Int[TOUCH_COUNT]
	' The time it was released
	Field touchReleasedTime:Int[] = New Int[TOUCH_COUNT]
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
	
	' the index of touches that were hit, released, or down (use touchHitCount, touchDownCount, touchReleasedCount]
	Field currentTouchHit:Int[] = New Int[TOUCH_COUNT]
	Field currentTouchDown:Int[] = New Int[TOUCH_COUNT]
	Field currentTouchReleased:Int[] = New Int[TOUCH_COUNT]
	
	' MouseHit() for 0-2
	Field mouseHit:Int[] = New Int[MOUSE_COUNT]
	' The time it was hit
	Field mouseHitTime:Int[] = New Int[MOUSE_COUNT]
	' MouseDown() for 0-2
	Field mouseDown:Int[] = New Int[MOUSE_COUNT]
	' The time it was first down
	Field mouseDownTime:Int[] = New Int[MOUSE_COUNT]
	' MouseDown() is false but was true last loop
	Field mouseReleased:Int[] = New Int[MOUSE_COUNT]
	' The time it was released
	Field mouseReleasedTime:Int[] = New Int[MOUSE_COUNT]
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
	
	' the index of mouse buttons that were hit, released, or down (use mouseHitCount, mouseDownCount, mouseReleasedCount]
	Field currentMouseHit:Int[] = New Int[MOUSE_COUNT]
	Field currentMouseDown:Int[] = New Int[MOUSE_COUNT]
	Field currentMouseReleased:Int[] = New Int[MOUSE_COUNT]
	
	' KeyHit() for each monitored key
	Field keyHit:Int[] = New Int[KEY_COUNT]
	' The time it was hit
	Field keyHitTime:Int[] = New Int[KEY_COUNT]
	' KeyDown() for each monitored key
	Field keyDown:Int[] = New Int[KEY_COUNT]
	' The time it was first down
	Field keyDownTime:Int[] = New Int[KEY_COUNT]
	' KeyDown() is false but was true last loop
	Field keyReleased:Int[] = New Int[KEY_COUNT]
	' The time it was released
	Field keyReleasedTime:Int[] = New Int[KEY_COUNT]
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
	
	' the index of keys that were hit, released, or down (use keyHitCount, keyDownCount, keyReleasedCount]
	Field currentKeysHit:Int[] = New Int[KEY_COUNT]
	Field currentKeysDown:Int[] = New Int[KEY_COUNT]
	Field currentKeysReleased:Int[] = New Int[KEY_COUNT]
	
' Properties
	Method KeysHit:EnumWrapper<KeyEventEnumerator>() Property
		Return keyHitWrapper
	End
	Method KeysDown:EnumWrapper<KeyEventEnumerator>() Property
		Return keyDownWrapper
	End
	Method KeysReleased:EnumWrapper<KeyEventEnumerator>() Property
		Return keyReleasedWrapper
	End
	
' Constructors
	Method New()
		keyHitEnumerator = New KeyEventEnumerator(Self, EVENT_KEY_HIT)
		keyDownEnumerator = New KeyEventEnumerator(Self, EVENT_KEY_DOWN)
		keyReleasedEnumerator = New KeyEventEnumerator(Self, EVENT_KEY_RELEASED)
		keyHitWrapper = New EnumWrapper<KeyEventEnumerator>(keyHitEnumerator)
		keyDownWrapper = New EnumWrapper<KeyEventEnumerator>(keyDownEnumerator)
		keyReleasedWrapper = New EnumWrapper<KeyEventEnumerator>(keyReleasedEnumerator)
		#If TARGET="android" Or TARGET="ios"
			monitorTouch = True
			monitorMouse = False
		#Else
			monitorTouch = False
			monitorMouse = True
		#End
	End
	
' Public methods
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
		
		' we still monitor shift/ctrl
		monitorKey[KEY_SHIFT] = True
		monitorKey[KEY_CONTROL] = True
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
		' we still monitor shift/ctrl
		monitorKey[KEY_SHIFT] = True
		monitorKey[KEY_CONTROL] = True
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
		Local now:Int = Millisecs()
		
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
				' get the touch hit
				newval = TouchHit(i)
				If Not touchHit[i] And newval Then
					touchHitTime[i] = now
				End
				touchHit[i] = newval
				' get the touch down
				newval = TouchDown(i)
				If newval And Not touchDown[i] Then
					touchDownTime[i] = now
				End
				' get the touch released
				If touchDown[i] And Not newval Then
					touchReleasedTime[i] = now
					touchReleased[i] = True
				Else
					touchReleased[i] = False
				End
				touchDown[i] = newval
				' get the location of each touch
				touchX[i] = TouchX(i)
				touchY[i] = TouchY(i)
				' update the "current" arrays and the min/max indices
				If touchDown[i] Then
					currentTouchDown[touchDownCount] = i
					touchDownCount += 1
					If minTouchDown < 0 Then minTouchDown = i
					maxTouchDown = i
				End
				If touchHit[i] Then
					currentTouchHit[touchHitCount] = i
					touchHitCount += 1
					If minTouchHit < 0 Then minTouchHit = i
					maxTouchHit = i
				End
				If touchReleased[i] Then
					currentTouchReleased[touchReleasedCount] = i
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
				' get the mouse hit
				newval = MouseHit(i)
				If Not mouseHit[i] And newval Then
					mouseHitTime[i] = now
				End
				mouseHit[i] = newval
				' get the mouse down
				newval = MouseDown(i)
				If newval And Not mouseDown[i] Then
					mouseDownTime[i] = now
				End
				' get the mouse released
				If mouseDown[i] And Not newval Then
					mouseReleasedTime[i] = now
					mouseReleased[i] = True
				Else
					mouseReleased[i] = False
				End
				mouseDown[i] = newval
				' update the "current" arrays
				If mouseDown[i] Then
					currentMouseDown[mouseDownCount] = i
					mouseDownCount += 1
				End
				If mouseHit[i] Then
					currentMouseHit[mouseHitCount] = i
					mouseHitCount += 1
				End
				If mouseReleased[i] Then
					currentMouseReleased[mouseReleasedCount] = i
					mouseReleasedCount += 1
				End
			Next
		End
		
		' get the key events for those we are monitoring
		keyDownCount = 0
		keyHitCount = 0
		keyReleasedCount = 0
		If monitorKeyCount > 0 Then
			For Local i:Int = 0 Until KEY_COUNT
				If monitorKey[i] Then
					' get the key hit
					newval = KeyHit(i)
					If Not keyHit[i] And newval Then
						keyHitTime[i] = now
					End
					keyHit[i] = newval
					' get the key down
					newval = KeyDown(i)
					If newval And Not keyDown[i] Then
						keyDownTime[i] = now
					End
					' get key released
					If keyDown[i] And Not newval Then
						keyReleasedTime[i] = now
						keyReleased[i] = True
					Else
						keyReleased[i] = False
					End
					keyDown[i] = newval
					' update the "current" arrays
					If keyDown[i] Then
						currentKeysDown[keyDownCount] = i
						keyDownCount += 1
					End
					If keyHit[i] Then
						currentKeysHit[keyHitCount] = i
						keyHitCount += 1
					End
					If keyReleased[i] Then
						currentKeysReleased[keyReleasedCount] = i
						keyReleasedCount += 1
					End
				End
			Next
		End
	End
End

' top level class for input events
Class InputEvent
Private
	Field eventType:Int
	Field eventTime:Int
	Field shiftDown:Bool
	Field ctrlDown:Bool
	Field altDown:Bool
	
Public
	Method EventType:Int() Property
		Return eventType
	End
	Method EventTime:Int() Property
		Return eventTime
	End
	Method ShiftDown:Bool() Property
		Return shiftDown
	End
	Method CtrlDown:Bool() Property
		Return ctrlDown
	End
	Method AltDown:Bool() Property
		Return altDown
	End
	
	Method New(eventType:Int)
		Self.eventType = eventType
	End
End

' subclass of InputEvent to store the key code
Class KeyEvent Extends InputEvent
Private
	Field keyCode:Int
	
Public
	Method KeyCode:Int() Property
		Return keyCode
	End
	
	Method New(eventType:Int)
		Super.New(eventType)
	End
End

Private

Class InputEventEnumerator
Private
	Field ic:InputCache
	Field index:Int
	Field eventType:Int
	
Public
	Method New(ic:InputCache, eventType:Int)
		Self.ic = ic
		Self.eventType = eventType
	End
	
	Method Reset:Void()
		index = 0
	End
End

' enumerator class to handle KeyEvents
Class KeyEventEnumerator Extends InputEventEnumerator
Private
	Field event:KeyEvent
	
Public
	Method New(ic:InputCache, eventType:Int)
		Super.New(ic, eventType)
		Self.event = New KeyEvent
	End
	
	Method HasNext:Bool()
		If eventType = EVENT_KEY_DOWN Then Return index < ic.keyDownCount
		If eventType = EVENT_KEY_RELEASED Then Return index < ic.keyReleasedCount
		If eventType = EVENT_KEY_HIT Then Return index < ic.keyHitCount
		Return False
	End
	
	Method NextObject:KeyEvent()
		Assert(HasNext())
		Local idx:Int = 0
		If eventType = EVENT_KEY_DOWN Then
			idx = ic.currentKeysDown[index]
			event.eventTime = ic.keyDownTime[idx]
		ElseIf eventType = EVENT_KEY_RELEASED Then
			idx = ic.currentKeysReleased[index]
			event.eventTime = ic.keyReleasedTime[idx]
		ElseIf eventType = EVENT_KEY_HIT Then
			idx = ic.currentKeysHit[index]
			event.eventTime = ic.keyHitTime[idx]
		End
		index += 1
		event.shiftDown = ic.keyDown[KEY_SHIFT]<>0
		event.ctrlDown = ic.keyDown[KEY_CONTROL]<>0
		'event.altDown = ic.keyDown[KEY_ALT] 'FIXME: apparently KEY_ALT doesn't exist in monkey
		event.keyCode = idx
		Return event
	End
End

' i'd love to use <T Extends InputEventEnumerator> but monkey doesn't support it
Class EnumWrapper<T>
Private
	Field wrappedEnum:T
	
Public
	Method New(wrappedEnum:T)
		Self.wrappedEnum = wrappedEnum
	End
	
	Method ObjectEnumerator:T()
		If InputEventEnumerator(wrappedEnum) <> Null Then InputEventEnumerator(wrappedEnum).Reset()
		Return wrappedEnum
	End
End
