Strict

Import diddy

Function Main:Int()
	game = new MyGame()
	Return 0
End Function

Global gameScreen:GameScreen

Class MyGame extends DiddyApp
	Method OnCreate:Int()
		Super.OnCreate()
		' enable touch for non-phones
		#If TARGET<>"ios" or TARGET<>"android"
			game.inputCache.MonitorTouch(True)
		#End
		gameScreen = new GameScreen
		gameScreen.PreStart()
		return 0
	End
End

Class GameScreen Extends Screen
	Const CIRCLE_RADIUS:Float = 20
	Const DEFAULT_LIFE:Float = 2000
	Const EPSILON:Float = 3
	Field x:Float[32]
	Field y:Float[32]
	Field vx:Float[32]
	Field vy:Float[32]
	Field life:Float[32]
	Field down:Bool[32]
	Field red:Int, green:Int, blue:Int
	Field useBigCircles:Bool
	
	Method New()
		name = "Game"
	End
	
	Method Start:Void()
		game.screenFade.Start(50, false)
	End
	
	Method Render:Void()
		' fill the background with an awful colour
		Cls(red, green, blue)
		' for each of the circles
		For Local i:Int = 0 Until life.Length
			' if we're touching the screen for this circle, or it has some life left
			If life[i]>0 Or down[i] Then
				' if we're touching the screen or its life is over half
				If down[i] Or life[i] > DEFAULT_LIFE/2 Then
					' draw at full alpha
					SetAlpha(1)
				Else
					' otherwise fade it out
					SetAlpha(life[i]/(DEFAULT_LIFE/2))
				End
				' draw a white circle and reset the alpha
				SetColor(255,255,255)
				If i=1 And useBigCircles Then
					DrawCircle(x[i],y[i],2*CIRCLE_RADIUS)
				Else
					DrawCircle(x[i],y[i],CIRCLE_RADIUS)
				End
				SetAlpha(1)
			End
		Next
		SetColor(255,255,255)
		DrawInfo()
	End
	
	Method DrawInfo:Void()
		DrawText("Diddy's Touch Test", 0, 0)
		DrawText("Press to move the circle and release to 'fling' it!", 0, 15)
		DrawText("Press down for a few seconds to change the background colour", 0, 30)
		DrawText("Do two touches to switch between big and small circles just for that fling", 0, 45)
		FPSCounter.Draw(0, 60)
	End
	
	Method Update:Void()
		If KeyHit(KEY_ESCAPE)
			game.screenFade.Start(50, true)
			game.nextScreen = game.exitScreen
		End
		' for each of the circles
		For Local i:Int = 0 Until life.Length
			' if we're not touching the screen for this circle and it has some life left
			If Not down[i] And life[i]>0 Then
				' slow down the velocity
				vx[i] *= 0.95
				vy[i] *= 0.95
				
				' move the circles
				x[i] += vx[i]*dt.frametime/1000
				y[i] += vy[i]*dt.frametime/1000
				
				' dodgy bouncing code
				If x[i]<0 Then
					x[i] *= -1
					vx[i] *= -1
				End
				If x[i]>SCREEN_WIDTH Then
					x[i] = 2*SCREEN_WIDTH - x[i]
					vx[i] *= -1
				End
				If y[i]<0 Then
					y[i] *= -1
					vy[i] *= -1
				End
				If y[i]>SCREEN_HEIGHT Then
					y[i] = 2*SCREEN_HEIGHT - y[i]
					vy[i] *= -1
				End
				If vx[i]*vx[i]+vy[i]*vy[i]<=EPSILON*EPSILON Then
					vx[i] = 0
					vy[i] = 0
				End
			
				' if it's stopped moving
				If vx[i]=0 And vy[i]=0 Then
					' decrease the life
					life[i] -= dt.frametime
					' clip it to 0
					If life[i] < 0 Then life[i] = 0
				End
			End
		Next
	End
	
	Method OnTouchHit:Void(x:Int, y:Int, pointer:Int)
		' if we touched, update the position of the circle for this pointer and mark it as down
		Self.x[pointer] = x
		Self.y[pointer] = y
		Self.vx[pointer] = 0
		Self.vy[pointer] = 0
		Self.down[pointer] = True
	End

	Method OnTouchReleased:Void(x:Int, y:Int, pointer:Int)
		' if we dragged, update the position of the circle for this pointer, and prepare it to fade out
		Self.x[pointer] = x
		Self.y[pointer] = y
		Self.down[pointer] = False
		Self.life[pointer] = DEFAULT_LIFE
	End

	Method OnTouchDragged:Void(x:Int, y:Int, dx:Int, dy:Int, pointer:Int)
		' if we dragged, update the position of the circle for this pointer
		Self.x[pointer] = x
		Self.y[pointer] = y
	End

	Method OnTouchFling:Void(releaseX:Int, releaseY:Int, velocityX:Float, velocityY:Float, velocitySpeed:Float, pointer:Int)
		' if we fling, update the position and velocity of the circle for this pointer
		Self.x[pointer] = releaseX
		Self.y[pointer] = releaseY
		Self.vx[pointer] = velocityX
		Self.vy[pointer] = velocityY
	End

	Method OnTouchLongPress:Void(x:Int, y:Int, pointer:Int)
		' if we long press, change the background colour to something random
		red = Rnd(0,255)
		green = Rnd(0,255)
		blue = Rnd(0,255)
		If red+green+blue < 192 Then
			red = Rnd(128,255)
			green = Rnd(128,255)
			blue = Rnd(128,255)
		End
	End

	Method OnTouchClick:Void(x:Int, y:Int, pointer:Int)
		' if we clicked with the second finger, switch between big and small circles just for that one
		If pointer = 1 Then useBigCircles = Not useBigCircles
	End
End