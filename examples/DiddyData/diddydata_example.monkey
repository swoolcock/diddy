#Rem
Copyright (c) 2011 Steve Revill and Shane Woolcock
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#End

Strict
#REFLECTION_FILTER="*"

' must import reflection first so that diddydata knows about the user's Screen classes
Import reflection
Import diddy

Function Main:Int()
	New MyGame()
	Return 0
End

Class MyGame Extends DiddyApp
	Method Create:Void()
	'	debugOn = True
		LoadDiddyData()
		Start(screens.Find("Title"), True, defaultFadeTime, True, True)
	End	
End

Class TitleScreen Extends Screen
	Field sword:GameImage
	
	Method Start:Void()
		sword = diddyGame.images.Find("sword")
	End

	Method Render:Void()
		Cls
		DrawText("Press SPACE or Click to Play", SCREEN_WIDTH2, SCREEN_HEIGHT2, 0.5, 0.5)
		sword.Draw(200, 500)
	End
	
	Method Update:Void()
		If KeyHit(KEY_SPACE) Or MouseHit()
			FadeToScreen(diddyGame.screens.Find("Game"), defaultFadeTime, True, True)
		End
	End
End

Class GameScreen Extends Screen
	Field sprite:Sprite
	Field asteroid:Sprite
	Field background:GameImage
	Field planet:GameImage
	Field sound:GameSound
	Field boom:GameSound
	Field planetObj:DiddyDataObject
	
	Method Start:Void()
		sprite = New Sprite(diddyGame.images.Find("Ship"), SCREEN_WIDTH2, SCREEN_HEIGHT2)
		sprite.SetFrame(0, 6, 100, True)
		asteroid = New Sprite(diddyGame.images.Find("GAster32"), SCREEN_WIDTH2, 200)
		asteroid.SetFrame(0, 15, 100)
		
		background = diddyGame.images.Find("bg_1_1")
		planet = diddyGame.images.Find("planet")
		
		sound = diddyGame.sounds.Find("fire")
		boom = diddyGame.sounds.Find("boom")
		
		planetObj = layers.FindObject("planet")
	End
	
	Method Render:Void()
		asteroid.Draw()
		sprite.Draw()
	End
	
	Method Update:Void()
		sprite.UpdateAnimation()
		asteroid.UpdateAnimation()
		
		If KeyDown(KEY_1)
			sound.Play()
		End
		If KeyDown(KEY_2)
			boom.Play()
		End
		
		If planetObj Then
			Local dx:Int = 0, dy:Int = 0, speed:Float = 3
			If KeyDown(KEY_LEFT) Then dx -= 1
			If KeyDown(KEY_RIGHT) Then dx += 1
			If KeyDown(KEY_UP) Then dy -= 1
			If KeyDown(KEY_DOWN) Then dy += 1
			If dx <> 0 Or dy <> 0 Then
				planetObj.x += dx * speed * dt.delta
				planetObj.y += dy * speed * dt.delta
			End
		End
		
		If KeyHit(KEY_ESCAPE)
			FadeToScreen(diddyGame.screens.Find("Title"), defaultFadeTime * 2, True, True)
		End
	End
End