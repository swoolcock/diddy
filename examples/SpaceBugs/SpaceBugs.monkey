' Strict code mode please
Strict

' The modules
Import mojo
Import diddy

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
	Method LoadImages:Void()
		' create tmpImage for animations
		Local tmpImage:Image
		
		images.Load("galaxy2.png", "", False)
		images.LoadAnim("Ship1.png", 64, 64, 7, tmpImage)
		images.LoadAnim("rusher.png", 64, 32, 24, tmpImage)
		images.LoadAnim("missile.png", 16, 16, 2, tmpImage)
		
	End
	
	'***********************
	'* Load Sounds
	'***********************
	Method LoadSounds:Void()
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
		game.MusicPlay("ShowYourMoves.ogg", True)
		game.screenFade.Start(50, false)
	End
	
	Method Render:Void()
		DrawImage background.image, 0, 0
		Scale 2, 2
		DrawText "ATTACK OF THE", SCREEN_WIDTH2 / 2, (SCREEN_HEIGHT2-30) / 2, 0.5, 0.5
		DrawText "SPACE-BUGS", SCREEN_WIDTH2 / 2, (SCREEN_HEIGHT2) / 2, 0.5, 0.5
		Scale .5, .5
		DrawText "SPACE TO PLAY!", SCREEN_WIDTH2, SCREEN_HEIGHT2 + 60, 0.5, 0.5
		DrawText "GRAPHICS FROM XENON 2000: PROJECT PCF", SCREEN_WIDTH2, SCREEN_HEIGHT - 40, 0.5, 0.5
		DrawText "MUSIC BY KEVIN MACLEOD", SCREEN_WIDTH2, SCREEN_HEIGHT - 20, 0.5, 0.5
	End

	Method Update:Void()
		If KeyHit(KEY_SPACE) or MouseHit(0)
			game.screenFade.Start(50, True, True, True)
			game.nextScreen = gameScreen
		End
		If KeyHit(KEY_ESCAPE)
			game.screenFade.Start(50, True, True, True)
			game.nextScreen = game.exitScreen
		End
	End
End

Class GameScreen Extends Screen
	Field background:GameImage
	Field player:Player
	Field lifeImage:GameImage
	Field missileImage:GameImage
	
	Method New()
		name = "Game Screen"
	End

	Method Start:Void()
		background = game.images.Find("galaxy2")
		Local gi:GameImage = game.images.Find("Ship1")
		player = New Player(gi, SCREEN_WIDTH2, SCREEN_HEIGHT - gi.h, game.images.Find("missile"))
		
		StartLevel()
		game.MusicPlay("SpaceFighterLoop.ogg", True)
		'start fade
		game.screenFade.Start(50, False, True, True)
	End
	
	Method ClearLevel:Void()
		Enemy.list.Clear()
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
				e.dx = 0.2 + (level/5) 
				e.movement = 1
				e.SetFrame(0, 23, 80, True)
				e.score = 10
			next
		next
	End
	
	Method Render:Void()
		DrawImage background.image, 0, 0
		Alien.DrawAll()
		Bullet.DrawAll()
		player.Draw()
		DrawGUI()
	End
	
	Method DrawGUI:Void()
		DrawText "SCORE: "+ player.score, 0, 0
	End
	

	Method Update:Void()
		player.Update()
		Alien.UpdateAll()
		Bullet.UpdateAll()
		CheckCollisions()
		If KeyHit(KEY_ESCAPE)
			game.screenFade.Start(50, True, True, True)
			game.nextScreen = titleScreen
		End
	End
	
	Method CheckCollisions:Void()
		Local b:Bullet
		Local e:Enemy
		Local hit:Bool = False
		
		Enemy.enum.Reset()
		While Enemy.enum.HasNext()
			e = Enemy.enum.NextObject()
			Bullet.enum.Reset()
			While Bullet.enum.HasNext()
				b = Bullet.enum.NextObject()
				If b.Collide(e)
					player.score+=e.score
					Bullet.enum.Remove()
					Enemy.enum.Remove()
					Exit
				End
			End
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
	Field missileImage:GameImage
	
	Method New(img:GameImage, x#, y#, missileImage:GameImage)
		Super.New(img, x, y)
		score = 0
		lives = 3
		level = 1
		frame = 3
		speedX = 1
		maxXSpeed = 5
		Self.missileImage = missileImage
	End
	
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
		If KeyHit(KEY_SPACE)
			New Bullet(missileImage, x, y)
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
		'Self.frame = 0
		'Self.dy = Rnd(1, 3)
		'Self.list.Add(Self)
	End Method
	
	Method Update:Void()
		Super.Update()
		Select movement
			Case 1
				if x > SCREEN_WIDTH
					dx = -dx
					x = SCREEN_WIDTH - 1
					moveCounter = 50
					
				else if x < 0
					dx = -dx
					x = 0 + 1
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
	Global list:ArrayList<Enemy> = New ArrayList<Enemy>
	Global enum:AbstractEnumerator<Enemy> = list.Enumerator()
	
	Field movement:Int
	Field moveCounter:Float
	Field type:Int
	Field score:Int
	
	Method New(img:GameImage, x#, y#)
		Super.New(img, x, y)
		Self.frame = 0
		Self.dy = Rnd(1, 3)
		list.Add(Self)
	End
	
	Function UpdateAll:Void()
		enum.Reset()
		While enum.HasNext()
			Local e:Enemy = enum.NextObject()
			e.Update()
			If e.OutOfBounds() Then enum.Remove()
		End
	End
	
	Method Update:Void()
		UpdateAnimation()
		Move()
	End
	
	Method OutOfBounds:Bool()
		Return y > SCREEN_HEIGHT + image.h
	End
	
	Function DrawAll:Void()
		For Local i% = 0 Until list.Size
			Local e:Enemy = list.Get(i)
			e.Draw()
		Next		
	End
End

Class Bullet Extends Sprite
	Global list:ArrayList<Bullet> = New ArrayList<Bullet>
	Global enum:AbstractEnumerator<Bullet> = list.Enumerator()
	
	Method New(img:GameImage, x#, y#)
		Super.New(img, x, y)
		Self.speedY = -6
		list.Add(Self)
	End
	
	Function UpdateAll:Void()
		enum.Reset()
		While enum.HasNext()
			Local b:Bullet = enum.NextObject()
			b.Update()
			If b.OutOfBounds() Then enum.Remove()
		End
	End
	
	Method Update:Void()
		Self.UpdateAnimation()
		dy = Self.speedY
		Move()
	End
	
	Method OutOfBounds:Bool()
		Return y < -image.h
	End
	
	Function DrawAll:Void()
		For Local i% = 0 Until list.Size
			Local b:Bullet = list.Get(i)
			b.Draw()
		Next		
	End
	
End

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

