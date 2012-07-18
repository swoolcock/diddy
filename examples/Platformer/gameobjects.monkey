Import diddy
Import level
Import screens

Class Player Extends Sprite
	Const STANDING:Int = 0
	Const WALKING:Int = 1
	Const DIE:Int = 2
	Const TURNING:Int = 3

	Field jumping:Bool
	Field speedX:Float = 3
	Field speedY:Float = 15
	Field direction:Int = 1
	Field status:Int = STANDING
	Field olddir:Int
	Field walkImages:GameImage
	Field standImage:GameImage
	Field jumpImage:GameImage
	Field deadImages:GameImage
	Field turningImages:GameImage
	
	Method New(img:GameImage, x:Float, y:Float)
		Self.image = img
		Self.x = x
		Self.y = y
		Self.alpha = 1
		Self.SetHitBox( -img.w2 + 2, - img.h2 + 1, img.w - 2, img.h - 1)
		Self.visible = True
		
		walkImages = game.images.FindSet("gripe.run_right", 32, 32, 8)
		deadImages = game.images.FindSet("gripe.die", 32, 32, 4)
		standImage = game.images.Find("gripe.stand_right")
		jumpImage = game.images.Find("gripe.jump_right")
		turningImages = game.images.FindSet("gripe.turn_right_to_left", 32, 32, 4)
	End
	
	Method SetupWalkAnim:Void()
		If direction = 1
			scaleX = 1
		Else
			scaleX = -1
		End If
		image = walkImages
		If status <> WALKING SetFrame(0, 7, 60)
	End
		
	Method SetupStandAnim:Void()
		status = STANDING
		image = standImage
		SetFrame(0, 0)
	End
	
	Method SetupJumpAnim:Void()
		image = jumpImage
		SetFrame(0, 0)
	End
	
	Method SetupDieAnim:Void()
		status = DIE
		image = deadImages
		SetFrame(0, 3, 50)
	End
	
	Method SetUpTurningAnim:Void()
		status = TURNING
		image = turningImages
		SetFrame(0, 3, 40, False, False)
	End
	
	Method Update:Void()
		Local tempx:Float
		Local tileData:TileCollisionData
		Local tileDatas:TileCollisionData[3]
		Local newY:Float, newX:Float
		local animFinish:Int = UpdateAnimation()
		if status = TURNING
			if animFinish
				if direction = 1
					direction = -1
					scaleX = -1
				Else if direction = - 1
					direction = 1
					scaleX = 1
				End
				SetupStandAnim()
			End
		End
		
				
		If status <> DIE
			If KeyDown(KEY_LEFT)
				if direction = 1
					if jumping
						direction = -1
					Else
						if status <> TURNING Then SetUpTurningAnim()
					End
				Else
					direction = -1
					SetupWalkAnim()
					
					status = WALKING
					tempx = x - speedX * dt.delta
					tileDatas[0] = gameScreen.tilemap.CheckCollision(x - image.w2, y - image.h2 + 1, tempx - image.w2, y - image.h2 + 1, gameScreen.tilemap.COLLISION_LAYER)
					tileDatas[1] = gameScreen.tilemap.CheckCollision(x - image.w2, y, tempx - image.w2, y, gameScreen.tilemap.COLLISION_LAYER)
					tileDatas[2] = gameScreen.tilemap.CheckCollision(x - image.w2, y + image.h2 - 1, tempx - image.w2, y + image.h2 - 1, gameScreen.tilemap.COLLISION_LAYER)
					
					If tileDatas[0].tile = 0 And tileDatas[1].tile = 0 And tileDatas[2].tile = 0 Then
						x = tempx
					Else
						If tileDatas[0].tile <> 0 Then
							newX = tileDatas[0].x
						Else If tileDatas[1].tile <> 0 Then
							newX = tileDatas[1].x
						Else If tileDatas[2].tile <> 0 Then
							newX = tileDatas[2].x
						End
						newX = newX + image.w2 + 1
						x = newX
					End
				End
			Else If KeyDown(KEY_RIGHT)
				if direction = - 1
					if jumping
						direction = 1
					Else
						if status <> TURNING Then SetUpTurningAnim()
					End
				Else
					direction = 1
					SetupWalkAnim()
					status = WALKING
					tempx = x + speedX * dt.delta
					tileDatas[0] = gameScreen.tilemap.CheckCollision(x + image.w2, y - image.h2 + 1, tempx + image.w2, y - image.h2 + 1, gameScreen.tilemap.COLLISION_LAYER)
					tileDatas[1] = gameScreen.tilemap.CheckCollision(x + image.w2, y, tempx + image.w2, y, gameScreen.tilemap.COLLISION_LAYER)
					tileDatas[2] = gameScreen.tilemap.CheckCollision(x + image.w2, y + image.h2 - 1, tempx + image.w2, y + image.h2 - 1, gameScreen.tilemap.COLLISION_LAYER)
					
					If tileDatas[0].tile = 0 And tileDatas[1].tile = 0 And tileDatas[2].tile = 0 Then
						x = tempx
					Else
						If tileDatas[0].tile <> 0 Then
							newX = tileDatas[0].x
						Else If tileDatas[1].tile <> 0 Then
							newX = tileDatas[1].x
						Else If tileDatas[2].tile <> 0 Then
							newX = tileDatas[2].x
						End
						newX = newX - image.w2 - 1
						x = newX
					End
				End
			Else
				if status <> TURNING Then SetupStandAnim()
			End
			If KeyDown(KEY_SPACE) And Not jumping Then
				dy=-speedY
				jumping = True
			End
			
			If Not jumping
				tileDatas[0] = gameScreen.tilemap.CheckCollision(x - image.w2, y+ image.h2, x - image.w2, y + image.h2 + 1, gameScreen.tilemap.COLLISION_LAYER)
				tileDatas[1] = gameScreen.tilemap.CheckCollision(x, y + image.h2, x, y + image.h2 + 1, gameScreen.tilemap.COLLISION_LAYER)
				tileDatas[2] = gameScreen.tilemap.CheckCollision(x + image.w2, y+ image.h2, x + image.w2, y + image.h2 + 1, gameScreen.tilemap.COLLISION_LAYER)
				If tileDatas[0].tile = 0 And tileDatas[1].tile = 0 And tileDatas[2].tile = 0 Then
					jumping = True
				End
			End
			
			If jumping
				SetupJumpAnim()
				dy += MyTileMap.GRAVITY * dt.delta
				
				Local tempY:Float = y + (dy  * dt.delta)
				If dy <> 0
					If dy > 0
						tileDatas[0] = gameScreen.tilemap.CheckCollision(x - image.w2, y + image.h2, x - image.w2, tempY + image.h2, gameScreen.tilemap.COLLISION_LAYER)
						tileDatas[1] = gameScreen.tilemap.CheckCollision(x, y + image.h2, x, tempY + image.h2, gameScreen.tilemap.COLLISION_LAYER)
						tileDatas[2] = gameScreen.tilemap.CheckCollision(x + image.w2, y + image.h2, x + image.w2, tempY + image.h2, gameScreen.tilemap.COLLISION_LAYER)
						If tileDatas[0].tile <> 0 Or tileDatas[1].tile <> 0 Or tileDatas[2].tile <> 0 Then
							dy = 0
							jumping = False
							SetupStandAnim()
							If tileDatas[0].tile <> 0 Then
								newY = tileDatas[0].y
							Else If tileDatas[1].tile <> 0 Then
								newY = tileDatas[1].y
							Else If tileDatas[2].tile <> 0 Then
								newY = tileDatas[2].y
							End
							
							' TODO: Fix this hax!
							If tileDatas[0].tile = 92 Or tileDatas[0].tile = 93 Or tileDatas[1].tile = 92 Or tileDatas[1].tile = 93 Or tileDatas[2].tile = 92 Or tileDatas[2].tile = 93
								SetupDieAnim()
								dy = -10
							End
							
							newY = newY - image.h2
							y = newY
						Else
							y = tempY
						End
					Else
						tileDatas[0] = gameScreen.tilemap.CheckCollision(x - image.w2, y - image.h2, x - image.w2, tempY - image.h2, gameScreen.tilemap.COLLISION_LAYER)
						tileDatas[1] = gameScreen.tilemap.CheckCollision(x, y - image.h2, x, tempY - image.h2, gameScreen.tilemap.COLLISION_LAYER)
						tileDatas[2] = gameScreen.tilemap.CheckCollision(x + image.w2, y - image.h2, x + image.w2, tempY - image.h2, gameScreen.tilemap.COLLISION_LAYER)
						If tileDatas[0].tile <> 0 Or tileDatas[1].tile <> 0 Or tileDatas[2].tile <> 0 Then
							dy = 0
							If tileDatas[0].tile <> 0 Then
								newY = tileDatas[0].y
							Else If tileDatas[1].tile <> 0 Then
								newY = tileDatas[1].y
							Else If tileDatas[2].tile <> 0 Then
								newY = tileDatas[2].y
							End
							newY = newY + image.h2
							y = newY
						Else
							y = tempY
						End
					End
				End
			End
		Else
			dy += MyTileMap.GRAVITY * dt.delta
			y = y + (dy * dt.delta)
			If direction = 1
				x += speedX * dt.delta
			Else
				x -= speedX * dt.delta
			End
			If y - game.scrollY > SCREEN_HEIGHT + 500
				gameScreen.FadeToScreen(titleScreen, defaultFadeTime * 2)
			End
		End
		
		Local borderX:Int = 200
		Local borderY:Int = 200
		If x - game.scrollX < borderX Then gameScreen.tilemap.Scroll( (x - game.scrollX) - borderX, 0)
		If x - game.scrollX > SCREEN_WIDTH - borderX Then gameScreen.tilemap.Scroll( (x - game.scrollX) - (SCREEN_WIDTH - borderX), 0)
		If y - game.scrollY < borderY Then gameScreen.tilemap.Scroll(0, (y - game.scrollY) - borderY)
		If y - game.scrollY > SCREEN_HEIGHT - borderY Then gameScreen.tilemap.Scroll(0, (y - game.scrollY) - (SCREEN_HEIGHT - borderY))

	End
	
End