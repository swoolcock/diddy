Strict

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
		sword = game.images.Find("sword")
	End

	Method Render:Void()
		Cls
		DrawText("Press SPACE or Click to Play", SCREEN_WIDTH2, SCREEN_HEIGHT2, 0.5, 0.5)
		sword.Draw(200, 500)
	End
	
	Method Update:Void()
		If KeyHit(KEY_SPACE) Or MouseHit()
			FadeToScreen(game.screens.Find("Game"), defaultFadeTime, True, True)
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
		sprite = New Sprite(game.images.Find("Ship"), SCREEN_WIDTH2, SCREEN_HEIGHT2)
		sprite.SetFrame(0, 6, 100, True)
		asteroid = New Sprite(game.images.Find("GAster32"), SCREEN_WIDTH2, 200)
		asteroid.SetFrame(0, 15, 100)
		
		background = game.images.Find("bg_1_1")
		planet = game.images.Find("planet")
		
		sound = game.sounds.Find("fire")
		boom = game.sounds.Find("boom")
		
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
			FadeToScreen(game.screens.Find("Title"), defaultFadeTime * 2, True, True)
		End
	End
End