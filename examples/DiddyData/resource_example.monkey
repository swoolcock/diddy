#Rem
Copyright (c) 2011 Steve Revill and Shane Woolcock
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#End

Strict
#REFLECTION_FILTER="resource_example;diddy.framework"

' must import reflection first so that diddydata knows about the user's Screen classes
Import reflection
Import diddy

Function Main:Int()
	New MyGame()
	Return 0
End

Class MyGame Extends DiddyApp
	Method Create:Void()
		LoadDiddyData("resourcedata.xml")
		Start(GameScreen.GetInstance())
	End	
End

Class GameScreen Extends Screen
	Global instance:GameScreen = Null
	Field sprite:Sprite
	
	Function GetInstance:GameScreen()
		If instance = Null
			instance = New GameScreen()
		End
		Return instance
	End
	
	Method New()
		name = "Game"
	End
	
	Method Start:Void()
		sprite = New Sprite(diddyGame.images.Find("planet"), SCREEN_WIDTH2, SCREEN_HEIGHT2)
	End
	
	Method Update:Void()
		If KeyDown(KEY_LEFT) Then sprite.x -= 1
		If KeyDown(KEY_RIGHT) Then sprite.x += 1
		If KeyDown(KEY_UP) Then sprite.y -= 1
		If KeyDown(KEY_DOWN) Then sprite.y += 1
	End
	
	Method Render:Void()
		Cls
		sprite.Draw()
	End
End