#Rem
Copyright (c) 2011 Steve Revill and Shane Woolcock
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#End

#Rem
Header: Provides the DiddyStack class and associated utility classes.
#End

Strict

Import diddy

Class SnapFlingStack<SnapFlingObject> Extends DiddyStack<SnapFlingObject>
	Field selected:SnapFlingObject
	Field endPositionX:Int = SCREEN_WIDTH2
	Field timerSpeed:Float = 0.04
	
	Method Update:Void()
		For Local i:SnapFlingObject = EachIn Self
			i.Update()		
			If i <> selected
				' slow down the objects
				i.SetDx(i.GetDx() * 0.95 * dt.delta)
				
				' stop run away floats
				If i.GetDx() <> 0 and Abs(i.GetDx()) < 0.3 Then
					i.SetDx(0)
					GetSelectedObject()
				End
				i.MoveByXY(i.GetDx(), 0)
			End
		Next
		If selected
			If selected.GetTimer() <> 1
				Local mx:Float = BackEaseOutTween(selected.GetOx(), selected.GetEx(), selected.GetTimer())
				
				Local selectedDiff:Float = mx - selected.GetX()
	
				For Local i:SnapFlingObject = EachIn Self
					If i <> selected
						i.MoveByXY(selectedDiff, 0)
					End
				Next
				selected.MoveToXY(mx, selected.GetY())
				
				If selected.GetTimer() < 1
					Local t:Float = selected.GetTimer()
					t += selected.GetTimerSpeed() * dt.delta
					selected.SetTimer(t)
				Else
					selected.SetTimer(1)
				End
			End
		End
	End
	
	Method OnTouchHit:Void(x:Int, y:Int, pointer:Int)
		For Local i:SnapFlingObject = EachIn Self
			i.SetDx(0)
			i.SetDy(0)
			selected = Null
		End		
	End
	
	Method OnTouchFling:Void(releaseX:Int, releaseY:Int, velocityX:Float, velocityY:Float, velocitySpeed:Float, pointer:Int)
		For Local i:SnapFlingObject = EachIn Self
			i.SetDx(velocityX / 100)
			selected = Null
		End
	End
	
	Method OnTouchDragged:Void(x:Int, y:Int, dx:Int, dy:Int, pointer:Int)
		For Local i:SnapFlingObject = EachIn Self
			i.SetDx(dx)
			selected = Null
		End
	End

	Method OnTouchReleased:Void(x:Int, y:Int, pointer:Int)
		GetSelectedObject()
	End
	
	Method GetSelectedObject:Void()
		' find the object most out of view percentage
		Local oldPercentage:Float = 0
		For Local i:SnapFlingObject = EachIn Self
			If i.GetPercentageOnScreen() < oldPercentage
				oldPercentage = i.GetPercentageOnScreen()
			End
		Next
		
		' find the object which is the most in view
		Local found:Bool = False
		For Local i:SnapFlingObject = EachIn Self
			If i.GetDx() = 0
				If i.GetPercentageOnScreen() > oldPercentage
					oldPercentage = i.GetPercentageOnScreen()
					selected = i
					found = True
				End
			End
		Next
		If found
			If selected
				selected.SetEx(endPositionX)
				selected.SetOx(selected.GetX())
				selected.SetTimer(0)
				selected.SetTimerSpeed(timerSpeed)
			End
		End
	End
	
	Method Render:Void()
		For Local i:SnapFlingObject = EachIn Self
			i.Render()
		End
	End
End

Interface SnapFlingObject
	Method MoveByXY:Void(dx:Float, dy:Float)
	Method MoveToXY:Void(x:Float, y:Float)
	Method GetPercentageOnScreen:Float()
	Method Update:Void()
	Method Render:Void()

	' getters / setters
	Method GetX:Float()
	Method GetY:Float()
	Method GetDx:Float()
	Method GetDy:Float()
	Method SetX:Void(val:Float)
	Method SetY:Void(val:Float)
	Method SetDx:Void(val:Float)
	Method SetDy:Void(val:Float)
	Method GetOx:Float()
	Method SetOx:Void(val:Float)	
	Method GetEx:Float()
	Method SetEx:Void(val:Float)
	Method GetTimer:Float()
	Method SetTimer:Void(val:Float)
	Method GetTimerSpeed:Float()
	Method SetTimerSpeed:Void(val:Float)
End