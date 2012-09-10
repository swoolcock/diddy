Strict

Import diddy

Function Main:Int()
	New MyGame()
	Return 0
End

Global gameScreen:GameScreen

Class MyGame Extends DiddyApp
	Method Create:Void()
		debugOn = True
		gameScreen = New GameScreen
		LoadDiddyData()
		Start(gameScreen)
	End	
End

Class GameScreen Extends Screen
	Field sprite:Sprite
	Field background:GameImage
	Field sound:GameSound
	
	Method New()
		name = "GameScreen"
	End

	Method Start:Void()
		sprite = New Sprite(game.images.Find("Ship"), SCREEN_WIDTH2, SCREEN_HEIGHT2)
		background = game.images.Find("bg_1_1")
		sound = game.sounds.Find("fire")
	End
	
	Method Render:Void()
		Cls
		background.Draw(0, 0)
		sprite.Draw()
	End
	
	Method Update:Void()
		If KeyDown(KEY_SPACE)
			sound.Play()
		End
	End
End