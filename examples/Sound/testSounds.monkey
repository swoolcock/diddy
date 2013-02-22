Strict

import diddy

Function Main:Int()
	New MyGame()
	Return 0
End Function

Global gameScreen:GameScreen

Class MyGame Extends DiddyApp

	Method Create:Void()
		LoadSounds()
		gameScreen = new GameScreen
		Start(gameScreen)
	End
	
	'***********************
	'* Load Sounds
	'***********************
	Method LoadSounds:Void()
		sounds.Load("lazer")
		sounds.Load("boom3")
	End
End

Class GameScreen Extends Screen
	Field boom:GameSound
	Field lazer:GameSound
	
	Method New()
		name = "Game"
		boom = diddyGame.sounds.Find("boom3")
		lazer = diddyGame.sounds.Find("lazer")
	End

	Method Start:Void()
	End
	
	Method Render:Void()
		Cls
		DrawText "GAME SCREEN!", SCREEN_WIDTH2, SCREEN_HEIGHT2, 0.5, 0.5
		DrawText "Press 1 for Boom Sound", SCREEN_WIDTH2, SCREEN_HEIGHT2 + 20, 0.5, 0.5
		DrawText "Press 2 for Lazer Sound", SCREEN_WIDTH2, SCREEN_HEIGHT2 + 40, 0.5, 0.5
		DrawText "Press 3 for Looping Lazer Sound", SCREEN_WIDTH2, SCREEN_HEIGHT2 + 60, 0.5, 0.5
		DrawText "Press 4 to Stop Lazer Sound", SCREEN_WIDTH2, SCREEN_HEIGHT2 + 80, 0.5, 0.5
		DrawText "Channel : "+SoundPlayer.channel, SCREEN_WIDTH2, SCREEN_HEIGHT2 + 120, 0.5, 0.5
		
		For Local i:Int = 0 to SoundPlayer.MAX_CHANNELS
			DrawText "C", 1 + (i * 20), 10
			DrawText i, 1 + (i * 20), 20
			
			DrawText ChannelState(i), 1 + (i * 20), 40 ' doesnt work in Flash!!!
			DrawText SoundPlayer.playerChannelState[i], 1 + (i * 20), 60
		Next
		
	End

	Method Update:Void()
		if KeyHit(KEY_1)
			boom.Play()
		End
		if KeyHit(KEY_2)
			lazer.loop = 0
			lazer.Play()
		End
		
		if KeyHit(KEY_3)
			lazer.loop = 1
			lazer.Play()
		End
		
		if KeyHit(KEY_4)
			lazer.Stop()
		End

		If KeyHit(KEY_ESCAPE)
			FadeToScreen(diddyGame.exitScreen)
		End
	End
End


