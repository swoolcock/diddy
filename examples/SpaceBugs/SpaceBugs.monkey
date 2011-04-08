' Strict code mode please
Strict

' The modules
Import diddy
Import mojo

' Starting Point
Function Main:Int()
	game = new MyGame()
End

' Screens in the game
Global titleScreen:Screen = New TitleScreen()
Global gameScreen:Screen = New GameScreen()
Global nextLevelScreen:Screen = New NextLevelScreen()
Global gameOverScreen:Screen = New GameOverScreen()

' The Game
Class MyGame Extends DiddyApp
	Method OnCreate:Int()
		Super.OnCreate()
		
		' Set the font
		SetFont(LoadImage("graphics/font_16.png",16,16,64))
		
		LoadImages()
		LoadSounds()
		
		titleScreen.PreStart()
		
		Return 0
	End
	
	'***********************
	'* Load Images
	'***********************
	Function LoadImages:Void()
		' create tmpImage for animations
		Local tmpImage:Image
		
		images.Load("galaxy2.png", "", False)
		images.LoadAnim("Ship1.png", 64, 64, 7, tmpImage)
		images.LoadAnim("rusher.png", 64, 32, 24, tmpImage)
	End
	
	'***********************
	'* Load Sounds
	'***********************
	Function LoadSounds:Void()
		sounds.Load("lazer")
		sounds.Load("boom3")
	End
End

Class TitleScreen Extends Screen
	Field background:GameImage
	
	Method New()
		name = "Title"
	End

	Method Start:Void()
		background = game.images.Find("galaxy2")
	
		game.screenFade.Start(25, false)
	End
	
	Method Render:Void()
		DrawImage background.image, 0, 0
		Scale 2, 2
		DrawText "ATTACK OF THE", SCREEN_WIDTH2 / 2, (SCREEN_HEIGHT2-30) / 2, 0.5, 0.5
		DrawText "SPACE-BUGS", SCREEN_WIDTH2 / 2, (SCREEN_HEIGHT2) / 2, 0.5, 0.5
		Scale .5, .5
		DrawText "SPACE TO PLAY!", SCREEN_WIDTH2, SCREEN_HEIGHT2 + 60, 0.5, 0.5
		DrawText "GRAPHICS FROM XENON 2000: PROJECT PCF", SCREEN_WIDTH2, SCREEN_HEIGHT - 20, 0.5, 0.5
	End

	Method Update:Void()
		If KeyHit(KEY_SPACE) or MouseHit(0)
			game.screenFade.Start(25, true)
			game.nextScreen = gameScreen
		End
		If KeyHit(KEY_ESCAPE)
			game.screenFade.Start(25, true)
			game.nextScreen = game.exitScreen
		End
	End
End

Class GameScreen Extends Screen
	Field background:GameImage
	Field player:Player
	Field lIfeImage:GameImage
	
	Method New()
		name = "Game Screen"
	End

	Method Start:Void()
		background = game.images.Find("galaxy2")
		Local gi:GameImage = game.images.Find("Ship1")
		player = New Player(gi, SCREEN_WIDTH2, SCREEN_HEIGHT - gi.h)
		
		StartLevel()
		
		'start fade
		game.screenFade.Start(25, false)
	End
	
	Method ClearLevel:Void()
		If Alien.list <> Null Alien.list.Clear()
	End
	
	Method StartLevel:Void(level% = 1)
		ClearLevel()
		
		'create a few enemies
		Local maxAliensAcross%
		Local maxAliensDown%
		
		#if TARGET="android"
			maxAliensAcross = 2
			maxAliensDown = 2
		#else
			maxAliensAcross = 7
			maxAliensDown = 4		
		#endif
		Local gi:GameImage = game.images.Find("rusher")
		
		Local e:Enemy
		for Local i% = 0 to maxAliensAcross
			for Local j% = 0 to maxAliensDown
				e = new Alien(gi, 64 * i, (40 * j) + 34)
				e.frame = 0
				e.maxFrame = 23
				e.dy = 0
				e.dx = 1 + (level/5) 
				e.movement = 1
				e.SetFrame(0, 23, 80, True)
			next
		next
	End
	
	Method Render:Void()
		DrawImage background.image, 0, 0
		Alien.DrawAll()
		player.Draw()
	End

	Method Update:Void()
		player.Update()
		Alien.UpdateAll()
		If KeyHit(KEY_ESCAPE)
			game.screenFade.Start(25, true)
			game.nextScreen = titleScreen
		End
	End
End

Class Player Extends Sprite
	Field score:Int
	Field lives:Int
	Field level:Int
	Field frame:Int
	Field frameDelay:Int
	Field maxFrameDelay:Int = 3

	
	Method New(img:GameImage, x#, y#)
		Super.New(img, x, y)
		score = 0
		lives = 3
		level = 1
		frame = 3
		speedX = 1
		maxXSpeed = 5
	End Method
	
	Method Update:Void()
		If KeyDown(KEY_LEFT)
			Self.dx-=Self.speedX
			RollLeft()
		Else If KeyDown(KEY_RIGHT)
			Self.dx+=Self.speedX
			RollRight()
		Else
			SlowShip()
		End
		If dx > Self.maxXSpeed
			dx = Self.maxXSpeed
		End
		If dx < -Self.maxXSpeed
			dx = -Self.maxXSpeed
		End
		Self.Move()
		' limit the player to the screen
		If x < 0 + image.w2
			x = image.w2
		End
		If x > SCREEN_WIDTH - image.w2
			x = SCREEN_WIDTH - image.w2
		End
	End
	
	Method RollLeft:Void()
		If frame > 0
			frameDelay+=1
			If frameDelay > maxFrameDelay
				frame-=1
				frameDelay = 0
			End
		End
	End
	
	Method RollRight:Void()
		If frame < 6
			frameDelay+=1
			If frameDelay > maxFrameDelay
				frame+=1
				frameDelay = 0
			End
		End
	End	
					
	Method SlowShip:Void()
		If frame < 3
			frameDelay+=1
			If frameDelay > maxFrameDelay
				frame+=1
				frameDelay = 0
			End
		Else If frame > 3
			frameDelay+=1
			If frameDelay > maxFrameDelay
				frame-=1
				frameDelay = 0
			End			
		End
		If dx > 0
			dx-=Self.speedX/4
		Else If dx < 0
			dx+=Self.speedX/4
		End
	End
End

Class Alien Extends Enemy
	Method New(img:GameImage, x#, y#)
		Super.New(img, x, y)
		if list = null then list = new List<Enemy>
		self.frame = 0
		self.dy = Rnd(1, 3)
		list.AddLast self
	End Method
	
	Method Update:Void()
		Super.Update()
		Select movement
			Case 1
				if x > SCREEN_WIDTH
					dx = -dx
					x = SCREEN_WIDTH
					moveCounter = 50
					
				else if x < 0
					dx = -dx
					x = 0
					moveCounter = 50
					
				EndIf
				if moveCounter > 1
					dy = 1
					moveCounter-=1 * dt.delta
				else
					dy = 0
					moveCounter = 0
				end if
		End
	End
End

Class Enemy Extends Sprite
	Global list:List<Enemy>
	Field movement:Int
	Field moveCounter#
	field type%
	
	Method New(img:GameImage, x#, y#)
		Super.New(img, x, y)
		if list = null then list = new List<Enemy>
		self.frame = 0
		self.dy = Rnd(1, 3)
		list.AddLast self
	End Method
	
	Function UpdateAll:Void()
		If not list Return
		For Local b:Enemy = Eachin list
			b.Update()
		Next
	End Function
	
	Method Update:Void()
		UpdateAnimation()
		Move()
		if y > SCREEN_HEIGHT + image.h
			list.Remove(self)
		EndIf
	End Method
	
	Function DrawAll:Void()
		If not list Return
		For Local b:Enemy = Eachin list
			b.Draw()
		Next		
	End Function
End Class

Class NextLevelScreen Extends Screen
	Method New()
		name = "Next Level"
	End

	Method Start:Void()
		game.screenFade.Start(25, false)
	End
	
	Method Render:Void()
		Cls
	End

	Method Update:Void()

	End
End

Class GameOverScreen Extends Screen
	Method New()
		name = "Game Over"
	End

	Method Start:Void()
		game.screenFade.Start(25, false)
	End
	
	Method Render:Void()
		Cls
	End

	Method Update:Void()
	End
End

