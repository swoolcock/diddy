Strict

Import reflection
Import diddy

Function Main:Int()
	New MyGame()
	Return 0
End

Class MyGame Extends DiddyApp
	Method Create:Void()
		debugOn = True
		LoadDiddyData()
		Start(screens.Find("Title"))
	End	
End

Class TitleScreen Extends Screen
	Method Start:Void()
	End

	Method Render:Void()
		Cls
		DrawText("Press SPACE to Play", SCREEN_WIDTH2, SCREEN_HEIGHT2, 0.5, 0.5)
	End
	
	Method Update:Void()
		If KeyHit(KEY_SPACE)
			FadeToScreen(game.screens.Find("Game"))
		End
	End
End

Class GameScreen Extends Screen
	Field sprite:Sprite
	Field background:GameImage
	Field sound:GameSound
	
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
		If KeyHit(KEY_ESCAPE)
			FadeToScreen(game.screens.Find("Title"))
		End
	End
End