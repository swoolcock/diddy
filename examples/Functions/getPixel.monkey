Strict

Import diddy

Function Main:Int()
	game = New MyGame()
	Return 0
End

Global gameScreen:GameScreen

Class MyGame Extends DiddyApp

	Method OnCreate:Int()
		Super.OnCreate()
		gameScreen = New GameScreen
		gameScreen.PreStart()
		Return 0
	End

End

Class GameScreen Extends Screen
	Const max% = 100
	Field r%[max]
	Field g%[max]
	Field b%[max]
	Field x%[max]
	Field y%[max]
	Field w%[max]
	Field h%[max]

	Field pixel:Int[4]
	
	Method New()
		name = "Game"
	End
	
	Method Start:Void()
		game.screenFade.Start(50, False)
		For Local i%=0 To max-1
			r[i] = Rnd(0, 255)
			g[i] = Rnd(0, 255)
			b[i] = Rnd(0, 255)
			
			x[i] = Rnd(SCREEN_WIDTH)
			y[i] = Rnd(SCREEN_HEIGHT)
			w[i] = Rnd(100)
			h[i] = Rnd(100)
		End
		pixel[0] = 0
		pixel[1] = 0
		pixel[2] = 0
		pixel[3] = 1
	End
	
	Method Render:Void()
		Cls(1,2,3)
		For Local i%=0 To max-1
			SetColor(r[i],g[i],b[i])
			DrawRect x[i], y[i], w[i], h[i]
		Next

		SetColor pixel[0], pixel[1], pixel[2]
		DrawRect game.mouseX+12, game.mouseY+12, 50, 50
		SetColor pixel[0], pixel[1], pixel[2]
		DrawOval game.mouseX+12, game.mouseY+62, 50, 50
		
		SetColor 255,255,255

		DrawText "Red   = " + pixel[0], 10, 60
		DrawText "Green = " + pixel[1], 10, 70
		DrawText "Blue  = " + pixel[2], 10, 80
		
		If MouseDown()
			pixel = GetPixel(game.mouseX, game.mouseY)
		End
	End

	Method Update:Void()
		If KeyHit(KEY_ESCAPE)
			game.screenFade.Start(50, True)
			game.nextScreen = game.exitScreen
		End
	End

End