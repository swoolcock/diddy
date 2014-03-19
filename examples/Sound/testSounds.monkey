#Rem
Copyright (c) 2011 Steve Revill and Shane Woolcock
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#End

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


