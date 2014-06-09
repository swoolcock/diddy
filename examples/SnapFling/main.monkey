#Rem
Copyright (c) 2011 Steve Revill and Shane Woolcock
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#End

Strict

Import diddy

Function Main:Int()
	New MyGame()
	Return 0
End

Class MyGame Extends DiddyApp
	Method Create:Void()
		#If TARGET<>"ios" or TARGET<>"android"
			diddyGame.inputCache.MonitorTouch(True)
		#End
		
		images.Load("scroll.png")
		Start(Singleton<GameScreen>.Instance())
	End
End

Class GameScreen Extends Screen
	Field dialogs:SnapFlingStack
	Field scroll:GameImage
		
	Method New()
		name = "GameScreen"
	End
	
	Method Load:Void()
		scroll = diddyGame.images.Find("scroll")
	End
		
	Method Start:Void()
		dialogs = New SnapFlingStack
		For Local i:Int = 0 To 2
			Local d:MySimpleDialog = New MySimpleDialog(Null, scroll)
			d.title = "MySimpleDialog " + (i + 1)
			d.show = True
			d.MoveBy(scroll.w * i, 0, False)
			d.ox = d.x
			dialogs.AddItem(d)
		Next
	End
	
	Method Update:Void()
		dialogs.Update()
	End
	
	Method OnTouchHit:Void(x:Int, y:Int, pointer:Int)
		dialogs.OnTouchHit(x, y, pointer)
	End
	
	Method OnTouchFling:Void(releaseX:Int, releaseY:Int, velocityX:Float, velocityY:Float, velocitySpeed:Float, pointer:Int)
		dialogs.OnTouchFling(releaseX, releaseY, velocityX, velocityY, velocitySpeed, pointer)
	End
	
	Method OnTouchDragged:Void(x:Int, y:Int, dx:Int, dy:Int, pointer:Int)
		dialogs.OnTouchDragged(x, y, dx, dy, pointer)
	End

	Method OnTouchReleased:Void(x:Int, y:Int, pointer:Int)
		dialogs.OnTouchReleased(x, y, pointer)
	End
	
	Method Render:Void()
		Cls
		dialogs.Render()
	End
End

Class MySimpleDialog Extends SimpleDialog Implements SnapFlingObject
	Method New(menu:SimpleMenu, image:GameImage)
		Super.New(menu, image)
	End
	
	Method GetPercentageOnScreen:Float()
		Local imageWidth:Int = Self.image.w
				
		Local left:Float = Self.x - Self.image.w2
		Local right:Float = Self.x + Self.image.w2
		
		Local per:Float
		If left < 0
			per = (right / imageWidth)
		Else If right > SCREEN_WIDTH
			per = 1 - ( (right - SCREEN_WIDTH) / imageWidth)
		Else
			per = 1
		End
		Return per
	End
	
	Method Update:Void()
		Super.Update()
	End
	
	Method MoveToXY:Void(x:Float, y:Float)
		Self.MoveTo(x, y, False)
	End
	
	Method MoveByXY:Void(dx:Float, dy:Float)
		Self.MoveBy(dx, dy, False)
	End

	Method GetX:Float()
		Return Self.x
	End
	
	Method GetY:Float()
		Return Self.y
	End
	
	Method GetDx:Float()
		Return Self.dx
	End
	
	Method GetDy:Float()
		Return Self.dy
	End
	
	Method SetX:Void(val:Float)
		Self.x = val
	End
	
	Method SetY:Void(val:Float)
		Self.y = val
	End
	
	Method SetDx:Void(val:Float)
		Self.dx = val
	End
	
	Method SetDy:Void(val:Float)
		Self.dy = val
	End
	
	Method GetOx:Float()
		Return Self.ox
	End
	
	Method SetOx:Void(val:Float)
		Self.ox = val
	End
		
	Method GetEx:Float()
		Return Self.ex
	End
	
	Method SetEx:Void(val:Float)
		Self.ex = val
	End
	
	Method GetTimer:Float()
		Return Self.timer
	End
	
	Method SetTimer:Void(val:Float)
		Self.timer = val
	End
	
	Method GetTimerSpeed:Float()
		Return Self.timerSpeed
	End
	
	Method SetTimerSpeed:Void(val:Float)
		Self.timerSpeed = val
	End
	
	Method Render:Void()
		Self.Draw()
	End
End