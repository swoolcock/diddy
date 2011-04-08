Strict

import diddy

Function Main:Int()
	game = new MyGame()
	Return 0
End Function

Global gameScreen:GameScreen

Class MyGame Extends DiddyApp

	Method OnCreate:Int()
		Super.OnCreate()
			
		LoadSounds()
		
		gameScreen = new GameScreen
		
		gameScreen.PreStart()
		
		Return 0
	End
	
	'***********************
	'* Load Sounds
	'***********************
	Function LoadSounds:Void()
		sounds.Load("lazer")
		sounds.Load("boom3")
	End
End

Class GameScreen Extends Screen
	Field boom:GameSound
	Field lazer:GameSound
	
	Method New()
		name = "Game"
		boom = game.sounds.Find("boom3")
		lazer = game.sounds.Find("lazer")
	End

	Method Start:Void()
		game.screenFade.Start(50, false)
	End
	
	Method Render:Void()
		Cls
		DrawText "GAME SCREEN!", SCREEN_WIDTH2, SCREEN_HEIGHT2, 0.5, 0.5
		DrawText "Press 1 for Boom Sound", SCREEN_WIDTH2, SCREEN_HEIGHT2 + 20, 0.5, 0.5
		DrawText "Press 2 for Lazer Sound", SCREEN_WIDTH2, SCREEN_HEIGHT2 + 40, 0.5, 0.5
		DrawText "Channel : "+SoundPlayer.channel, SCREEN_WIDTH2, SCREEN_HEIGHT2 + 60, 0.5, 0.5
	End

	Method Update:Void()
		if KeyHit(KEY_1)
			boom.Play()
		End
		if KeyHit(KEY_2)
			lazer.Play()
		End

		If KeyHit(KEY_ESCAPE)
			game.screenFade.Start(50, true)
			game.nextScreen = game.exitScreen
		End
	End
End
