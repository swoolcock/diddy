#Rem
Copyright (c) 2011 Steve Revill and Shane Woolcock
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#End

Strict

Import reflection
Import diddy

Function Main:Int()
	New MyGame()
	Return 0
End

Global gameScreen:GameScreen

Class MyGame Extends DiddyApp
	Method Create:Void()
		gameScreen = New GameScreen
		Start(gameScreen )
	End
End

Class GameScreen Extends Screen
	Field player:Player

	Method New()
		name = "Game"
	End
	
	Method Start:Void()
		player = New Player
	End
	
	Method Render:Void()
		Cls
		player.Draw()
		DrawHUD()
	End

	Method Update:Void()
		player.Update()	
		If KeyHit(KEY_ESCAPE)
			FadeToScreen(diddyGame.exitScreen)
		End
	End
		
	Method DrawHUD:Void()
		FPSCounter.Draw(SCREEN_WIDTH, SCREEN_HEIGHT  - 12, 1)
	End
End

Class Player Extends Sprite
	Field position:Vector2D = New Vector2D( 200,200 )
	Field velocity:Vector2D = New Vector2D
	Field force:Vector2D = New Vector2D
	Field jumpCount:Int = 0
	Field jumpForce:Float = 10
	Field size:Int = 30
	
	Method Update:Void()
		Local groundHeight:Float = SCREEN_HEIGHT - size / 2
		
		If KeyDown( KEY_LEFT ) 
			force.Add( New Vector2D( -0.1, 0) )
		End
		If KeyDown( KEY_RIGHT ) 
			force.Add( New Vector2D(0.1, 0) )
		End
		If KeyHit(KEY_SPACE)
			' We can only jump when out feet touch the ground
			If Abs(position.y - groundHeight) < 0.1
				force.Add( New Vector2D(0, - jumpForce) ) 'Jump up
				jumpCount+=1
			Else If Abs(position.y - groundHeight) > 30 And jumpCount > 0 And jumpCount < 2 And velocity.y > 0
				jumpCount+=1
				force.Add( New Vector2D(0, - jumpForce) ) 'Double jump
			End
		End
		
		Print position.x +","+position.y +" distance from 10, 465:"+ CalcDistance(10, 465, position.x, position.y)
		
		' Gravity
		force.Add(New Vector2D(0, 0.3))
		velocity.Add( force )
		force.Set(0 ,0)
	
		position.Add(velocity)
		' Friction 
		velocity.Multiply( 0.99 )

		If position.y > groundHeight
			position.y = groundHeight
			velocity.y = 0
			jumpCount = 0
		End
		If position.x < 0 + size / 2
			position.x = 0 + size / 2
			velocity.x = 0
		End
		If position.x > SCREEN_WIDTH - size / 2
			position.x = SCREEN_WIDTH - size / 2
			velocity.x = 0
		End
	End

	Method Draw:Void()
		SetColor 255, 255, 255
		DrawOval position.x - size/2, position.y - size/2, size, size
	End
End