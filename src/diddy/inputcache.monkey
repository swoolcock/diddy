#Rem
Copyright (c) 2011 Steve Revill and Shane Woolcock
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#End

Strict

Import mojo
Import assert
Import functions

Private

Global charForCodeArray:Int[]
Global charForShiftCodeArray:Int[]

' warning: do not try to use these externally! they are here until Mark fixes the official monkey constants in input.monkey
Const VK_ALT:Int = 18
Const VK_SEMICOLON:Int = 59
Const VK_EQUALS:Int = 107
Const VK_HYPHEN:Int = 109
Const VK_BACKSLASH:Int = 220

Public

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
	Const FIRST_KEY:Int = KEY_BACKSPACE
	Const LAST_KEY:Int = KEY_QUOTES
	
	Const TOUCH_COUNT:Int = 32
	Const MOUSE_COUNT:Int = 3
	Const KEY_COUNT:Int = LAST_KEY-FIRST_KEY+1
	
	Const INPUT_COUNT:Int = 512
	
	Const FLING_THRESHOLD:Float = 250
	Const IGNORE_CLICK_DISTANCE:Float = 20
	Const LONG_PRESS_TIME:Int = 1000
	
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
	Field keyHit:Int[] = New Int[INPUT_COUNT]
	' The time it was hit
	Field keyHitTime:Int[] = New Int[INPUT_COUNT]
	' KeyDown() for each monitored key
	Field keyDown:Int[] = New Int[INPUT_COUNT]
	' The time it was first down
	Field keyDownTime:Int[] = New Int[INPUT_COUNT]
	' KeyDown() is false but was true last loop
	Field keyReleased:Int[] = New Int[INPUT_COUNT]
	' The time it was released
	Field keyReleasedTime:Int[] = New Int[INPUT_COUNT]
	' is any monitored key down?
	Field keyDownCount:Int
	' was any monitored key hit?
	Field keyHitCount:Int
	' was any monitored key released?
	Field keyReleasedCount:Int
	' If true, we should monitor that key (defaults To false)
	Field monitorKey:Bool[] = New Bool[INPUT_COUNT]
	' the number of keys we are monitoring; this is so we can skip key checks if we aren't monitoring any
	Field monitorKeyCount:Int = 0
	
	' the index of keys that were hit, released, or down (use keyHitCount, keyDownCount, keyReleasedCount]
	Field currentKeysHit:Int[] = New Int[INPUT_COUNT]
	Field currentKeysDown:Int[] = New Int[INPUT_COUNT]
	Field currentKeysReleased:Int[] = New Int[INPUT_COUNT]
	
	' for touch handling
	Field touchData:TouchData[] = New TouchData[TOUCH_COUNT]
	Field flingThreshold:Float = FLING_THRESHOLD
	Field longPressTime:Int = LONG_PRESS_TIME
  
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
	Method FlingThreshold:Float() Property
		Return flingThreshold
	End
	Method FlingThreshold:Void(flingThreshold:Float) Property
		Self.flingThreshold = flingThreshold
	End
	Method LongPressTime:Float() Property
		Return longPressTime
	End
	Method LongPressTime:Void(longPressTime:Float) Property
		Self.longPressTime = longPressTime
	End
	
' Constructors
	Method New()
		keyHitEnumerator = New KeyEventEnumerator(Self, EVENT_KEY_HIT)
		keyDownEnumerator = New KeyEventEnumerator(Self, EVENT_KEY_DOWN)
		keyReleasedEnumerator = New KeyEventEnumerator(Self, EVENT_KEY_RELEASED)
		keyHitWrapper = New EnumWrapper<KeyEventEnumerator>(keyHitEnumerator)
		keyDownWrapper = New EnumWrapper<KeyEventEnumerator>(keyDownEnumerator)
		keyReleasedWrapper = New EnumWrapper<KeyEventEnumerator>(keyReleasedEnumerator)
		For Local i:Int = 0 Until touchData.Length
			touchData[i] = New TouchData
		Next
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
	End
	
	Method MonitorAll:Void(val:Bool=True)
		MonitorMouse(val)
		MonitorTouch(val)
		MonitorAllKeys(val)
	End
	
	Method MonitorAllKeys:Void(val:Bool=True)
		If val Then
			monitorKeyCount = KEY_COUNT
		Else
			monitorKeyCount = 0
		End
		For Local i:Int = FIRST_KEY To LAST_KEY
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
	
	Method MonitorControlKeys:Void(val:Bool=True)
		MonitorKey(KEY_CONTROL, val)
		MonitorKey(KEY_SHIFT, val)
		MonitorKey(VK_ALT, val)
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
			mouseX = diddyGame.mouseX
			mouseY = diddyGame.mouseY
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
			For Local i:Int = FIRST_KEY To LAST_KEY
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

	Method HandleEvents:Void(screen:Screen)
		' handle calling touch hit
		For Local i:Int = 0 Until touchHitCount
			Local pointer:Int = currentTouchHit[i]
			Local x:Int = Int(touchX[pointer])
			Local y:Int = Int(touchY[pointer])
			touchData[pointer].Reset(x, y)
			screen.OnTouchHit(x, y, pointer)
		Next
	    
		' handle calling touch click/released/fling
		For Local i:Int = 0 Until touchReleasedCount
			Local pointer:Int = currentTouchReleased[i]
			Local x:Int = Int(touchX[pointer])
			Local y:Int = Int(touchY[pointer])
			touchData[pointer].Update(x, y);
			If Not touchData[pointer].movedTooFar And Not touchData[pointer].firedLongPress Then
				screen.OnTouchClick(x, y, pointer)
			Else
				' check to see how fast we were moving to see if we fire a fling
				If touchData[pointer].touchVelocityX * touchData[pointer].touchVelocityX +
						touchData[pointer].touchVelocityY * touchData[pointer].touchVelocityY >=
						flingThreshold * flingThreshold Then
					screen.OnTouchFling(x, y, touchData[pointer].touchVelocityX, touchData[pointer].touchVelocityY,
					touchData[pointer].touchVelocitySpeed, pointer)
				End
			End
			screen.OnTouchReleased(x, y, pointer)
		Next
			
		For Local i:Int = 0 Until touchDownCount
			Local pointer:Int = currentTouchDown[i]
			Local x:Int = Int(touchX[pointer])
			Local y:Int = Int(touchY[pointer])
			touchData[pointer].Update(x, y)
			screen.OnTouchDragged(x, y, touchData[pointer].distanceMovedX, touchData[pointer].distanceMovedY, pointer)
			' check long press
			If Not touchData[pointer].testedLongPress And dt.currentticks-touchData[pointer].firstTouchTime >= longPressTime Then
				touchData[pointer].testedLongPress = True
				If Not touchData[pointer].movedTooFar Then
					' fire long press
					screen.OnTouchLongPress(x, y, pointer)
					touchData[pointer].firedLongPress = True
				End
			End
		Next
		
		' keyhits
		If keyHitCount > 0 Then screen.OnAnyKeyHit()
		For Local i:Int = 0 Until keyHitCount
			Local key:Int = currentKeysHit[i]
			screen.OnKeyHit(key)
		Next
		
		' keydowns
		If keyDownCount > 0 Then screen.OnAnyKeyDown()
		For Local i:Int = 0 Until keyDownCount
			Local key:Int = currentKeysDown[i]
			screen.OnKeyDown(key)
		Next
		
		' keyreleases
		If keyReleasedCount > 0 Then screen.OnAnyKeyReleased()
		For Local i:Int = 0 Until keyReleasedCount
			Local key:Int = currentKeysReleased[i]
			screen.OnKeyReleased(key)
		Next
		
		For Local i:Int = 0 Until mouseHitCount
			Local button:Int = currentMouseHit[i]
			Local x:Int = Int(mouseX)
			Local y:Int = Int(mouseY)
			screen.OnMouseHit(x, y, button)
		Next
		
		For Local i:Int = 0 Until mouseDownCount
			Local button:Int = currentMouseDown[i]
			Local x:Int = Int(mouseX)
			Local y:Int = Int(mouseY)
			screen.OnMouseDown(x, y, button)
		Next
		
		For Local i:Int = 0 Until mouseReleasedCount
			Local button:Int = currentMouseReleased[i]
			Local x:Int = Int(mouseX)
			Local y:Int = Int(mouseY)
			screen.OnMouseReleased(x, y, button)
		Next
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
	Field keyChar:Int
	
Public
	Method KeyCode:Int() Property
		Return keyCode
	End
	Method KeyChar:Int() Property
		Return keyChar
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
		event.altDown = ic.keyDown[VK_ALT]<>0
		event.keyCode = idx
		event.keyChar = CharForCode(idx, event.shiftDown)
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

Function CharForCode:Int(code:Int, shiftDown:Bool)
	BuildCharForCodeArray()
	If shiftDown Then
		Return charForShiftCodeArray[code]
	Else
		Return charForCodeArray[code]
	End
End

Private

Class TouchData
	Const FLING_SAMPLE_RATE:Int = 10
	
	Field firstTouchX:Int
	Field firstTouchY:Int
	Field firstTouchTime:Int
	Field lastTouchX:Int
	Field lastTouchY:Int
	Field flingSamplesX:Int[FLING_SAMPLE_RATE]
	Field flingSamplesY:Int[FLING_SAMPLE_RATE]
	Field flingSamplesTime:Int[FLING_SAMPLE_RATE]
	Field flingSampleCount:Int
	Field flingSampleNext:Int
	
	' calculated values
	Field movedTooFar:Bool
	Field testedLongPress:Bool
	Field firedLongPress:Bool
	Field distanceMovedX:Int
	Field distanceMovedY:Int
	Field touchVelocityX:Float
	Field touchVelocityY:Float
	Field touchVelocitySpeed:Float
	
	Method Reset:Void(x:Int, y:Int)
		firstTouchX = x
		firstTouchY = y
		lastTouchX = x
		lastTouchY = y
		firstTouchTime = Int(dt.currentticks)
		testedLongPress = False
		firedLongPress = False
		For Local i:Int = 0 Until FLING_SAMPLE_RATE
			flingSamplesX[i] = 0
			flingSamplesY[i] = 0
			flingSamplesTime[i] = 0
		Next
		flingSampleCount = 0
		flingSampleNext = 0
		movedTooFar = False
		touchVelocityX = 0
		touchVelocityY = 0
		touchVelocitySpeed = 0
		AddFlingSample(x, y)
	End

	Method AddFlingSample:Void(x:Int, y:Int)
		flingSamplesX[flingSampleNext] = x
		flingSamplesY[flingSampleNext] = y
		flingSamplesTime[flingSampleNext] = Int(dt.currentticks)
		If flingSampleCount < FLING_SAMPLE_RATE Then flingSampleCount += 1
		flingSampleNext += 1
		If flingSampleNext >= FLING_SAMPLE_RATE Then flingSampleNext = 0
		
		' find the first and last samples
		Local first:Int = flingSampleNext - flingSampleCount
		Local last:Int = flingSampleNext - 1
		While first < 0
			first += FLING_SAMPLE_RATE
		End
		While last < 0
			last += FLING_SAMPLE_RATE
		End
		
		' get the total delta
		If flingSampleCount > 0 Then
			' calculate the velocity in pixels per second
			Local secs:Float = Float(flingSamplesTime[last] - flingSamplesTime[first]) / 1000
			touchVelocityX = (flingSamplesX[last] - flingSamplesX[first]) / secs
			touchVelocityY = (flingSamplesY[last] - flingSamplesY[first]) / secs
			touchVelocitySpeed = Sqrt(touchVelocityX * touchVelocityX + touchVelocityY * touchVelocityY)
		End
	End
	
	Method Update:Void(x:Int, y:Int)
		' update distance
		distanceMovedX = x - lastTouchX
		distanceMovedY = y - lastTouchY
		lastTouchX = x
		lastTouchY = y
		' update the fling
		AddFlingSample(x, y)
		' check to see if we moved far enough away that we won't count this as a click
		If Not movedTooFar Then
			' get the first delta
			Local dx:Int = x - firstTouchX
			Local dy:Int = y - firstTouchY
			If dx * dx + dy * dy > InputCache.IGNORE_CLICK_DISTANCE * InputCache.IGNORE_CLICK_DISTANCE Then
				movedTooFar = True
			End
		End
	End
End

' Builds up arrays to convert key codes to characters.
' This is based off a US keyboard layout (sorry!)
' I may look at doing something native to correctly match keyboards to locale.
' warning: 107 seems to be the code for both the EQUALS in the number row and the PLUS on the number pad... wtf?
Function BuildCharForCodeArray:Void()
	If charForCodeArray.Length > 0 Then Return
	charForCodeArray = New Int[InputCache.INPUT_COUNT]
	charForShiftCodeArray = New Int[InputCache.INPUT_COUNT]
	
	' letters
	For Local i:Int = KEY_A To KEY_Z
		charForCodeArray[i] = i+32
		charForShiftCodeArray[i] = i
	Next
	
	' numbers
	For Local i:Int = KEY_0 To KEY_9
		charForCodeArray[i] = i
	Next
	
	' keypad numbers
	For Local i:Int = 96 To 105
		charForCodeArray[i] = KEY_0 + i - 96
	Next
	
	' shift-numbers
	charForShiftCodeArray[KEY_0] = ASC_CLOSE_PARENTHESIS
	charForShiftCodeArray[KEY_1] = ASC_EXCLAMATION
	charForShiftCodeArray[KEY_2] = ASC_AT
	charForShiftCodeArray[KEY_3] = ASC_HASH
	charForShiftCodeArray[KEY_4] = ASC_DOLLAR
	charForShiftCodeArray[KEY_5] = ASC_PERCENT
	charForShiftCodeArray[KEY_6] = ASC_CIRCUMFLEX
	charForShiftCodeArray[KEY_7] = ASC_AMPERSAND
	charForShiftCodeArray[KEY_8] = ASC_ASTERISK
	charForShiftCodeArray[KEY_9] = ASC_OPEN_PARENTHESIS
	
	charForCodeArray[VK_SEMICOLON] = ASC_SEMICOLON
	charForCodeArray[VK_EQUALS] = ASC_EQUALS
	charForCodeArray[KEY_COMMA] = ASC_COMMA
	charForCodeArray[VK_HYPHEN] = ASC_HYPHEN
	charForCodeArray[KEY_PERIOD] = ASC_PERIOD
	charForCodeArray[KEY_SLASH] = ASC_SLASH
	charForCodeArray[KEY_TILDE] = ASC_BACKTICK
	charForCodeArray[KEY_OPENBRACKET] = ASC_OPEN_BRACKET
	charForCodeArray[KEY_CLOSEBRACKET] = ASC_CLOSE_BRACKET
	charForCodeArray[KEY_QUOTES] = ASC_DOUBLE_QUOTE
	charForCodeArray[VK_BACKSLASH] = ASC_BACKSLASH
	charForCodeArray[KEY_SPACE] = ASC_SPACE
	
	charForShiftCodeArray[VK_SEMICOLON] = ASC_COLON
	charForShiftCodeArray[VK_EQUALS] = ASC_PLUS
	charForShiftCodeArray[KEY_COMMA] = ASC_LESS_THAN
	charForShiftCodeArray[VK_HYPHEN] = ASC_UNDERSCORE
	charForShiftCodeArray[KEY_PERIOD] = ASC_GREATER_THAN
	charForShiftCodeArray[KEY_SLASH] = ASC_QUESTION
	charForShiftCodeArray[KEY_TILDE] = ASC_TILDE
	charForShiftCodeArray[KEY_OPENBRACKET] = ASC_OPEN_BRACE
	charForShiftCodeArray[KEY_CLOSEBRACKET] = ASC_CLOSE_BRACE
	charForShiftCodeArray[KEY_QUOTES] = ASC_SINGLE_QUOTE
	charForShiftCodeArray[VK_BACKSLASH] = ASC_PIPE
	charForShiftCodeArray[KEY_SPACE] = ASC_SPACE
End