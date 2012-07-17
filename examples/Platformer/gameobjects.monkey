Import diddy
Import level
Import screens

Class Player Extends Sprite
	Field jumping:Bool
	Field speedX:Float = 3
	Field speedY:Float = 15
	Field direction:Int = 1
	Const STANDING:Int = 0
	Const WALKING:Int = 1
	Const DIE:Int = 2
	Field status:Int = STANDING
	Field olddir:Int
	Field walkImages:GameImage
	Field standImage:GameImage
	Field jumpImage:GameImage
	Field deadImages:GameImage
	
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
	End
	
	Method SetupWalkAnim:Void()
		If direction = 1
			scaleX = 1
		Else
			scaleX = -1
		End If
		image = walkImages
		if status <> WALKING SetFrame(0, 7, 60)
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
	
	Method Update:Void()
		Local tempx:Float
		Local tileData:TileCollisionData
		Local tileDatas:TileCollisionData[3]
		Local newY:Float, newX:Float
		UpdateAnimation()
		
		if status <> DIE
			If KeyDown(KEY_LEFT)
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
					if tileDatas[0].tile <> 0 Then
						newX = tileDatas[0].x
					Else if tileDatas[1].tile <> 0 Then
						newX = tileDatas[1].x
					else if tileDatas[2].tile <> 0 Then
						newX = tileDatas[2].x
					End
					newX = newX + image.w2 + 1
					x = newX
				End
			Else If KeyDown(KEY_RIGHT)
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
					if tileDatas[0].tile <> 0 Then
						newX = tileDatas[0].x
					Else if tileDatas[1].tile <> 0 Then
						newX = tileDatas[1].x
					else if tileDatas[2].tile <> 0 Then
						newX = tileDatas[2].x
					End
					newX = newX - image.w2 - 1
					x = newX
				End
			Else
				SetupStandAnim()
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
							if tileDatas[0].tile <> 0 Then
								newY = tileDatas[0].y
							Else if tileDatas[1].tile <> 0 Then
								newY = tileDatas[1].y
							else if tileDatas[2].tile <> 0 Then
								newY = tileDatas[2].y
							End
							
							' TODO: Fix this hax!
							if tileDatas[0].tile = 92 or tileDatas[0].tile = 93 or tileDatas[1].tile = 92 or tileDatas[1].tile = 93 or tileDatas[2].tile = 92 or tileDatas[2].tile = 93
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
							if tileDatas[0].tile <> 0 Then
								newY = tileDatas[0].y
							Else if tileDatas[1].tile <> 0 Then
								newY = tileDatas[1].y
							Else if tileDatas[2].tile <> 0 Then
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
			Print y
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