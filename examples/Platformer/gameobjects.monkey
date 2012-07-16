Import diddy
Import level
Import screens

Class Player Extends Sprite
	Field jumping:Bool
	Field speedX:Float = 3
	Field speedY:Float = 15
	
	Method New(img:GameImage, x:Float, y:Float)
		Self.image = img
		Self.x = x
		Self.y = y
		Self.alpha = 1
		Self.SetHitBox( -img.w2 + 2, - img.h2 + 1, img.w - 2, img.h - 1)
		
		Self.visible = True
	End
	
	Method Update:Void()
		Local tempx:Float
		Local tileData:TileCollisionData
		Local tileDatas:TileCollisionData[3]
	
		If KeyDown(KEY_LEFT)
			tempx = x - speedX
			tileDatas[0] = gameScreen.tilemap.CheckCollision(x - image.w2, y - image.h2 + 1, tempx - image.w2, y - image.h2 + 1, gameScreen.tilemap.COLLISION_LAYER)
			tileDatas[1] = gameScreen.tilemap.CheckCollision(x - image.w2, y, tempx - image.w2, y, gameScreen.tilemap.COLLISION_LAYER)
			tileDatas[2] = gameScreen.tilemap.CheckCollision(x - image.w2, y + image.h2 - 1, tempx - image.w2, y + image.h2 - 1, gameScreen.tilemap.COLLISION_LAYER)
			
			If tileDatas[0].tile = 0 And tileDatas[1].tile = 0 And tileDatas[2].tile = 0 Then
				x = tempx
			End
		Else If KeyDown(KEY_RIGHT)
			tempx = x + speedX
			tileDatas[0] = gameScreen.tilemap.CheckCollision(x + image.w2, y - image.h2 + 1, tempx + image.w2, y - image.h2 + 1, gameScreen.tilemap.COLLISION_LAYER)
			tileDatas[1] = gameScreen.tilemap.CheckCollision(x + image.w2, y, tempx + image.w2, y, gameScreen.tilemap.COLLISION_LAYER)
			tileDatas[2] = gameScreen.tilemap.CheckCollision(x + image.w2, y + image.h2 - 1, tempx + image.w2, y + image.h2 - 1, gameScreen.tilemap.COLLISION_LAYER)
			
			If tileDatas[0].tile = 0 And tileDatas[1].tile = 0 And tileDatas[2].tile = 0 Then
				x = tempx
			End
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
			dy += MyTileMap.GRAVITY
			
			Local tempY:Float = y + dy
			If dy <> 0
				If dy > 0
					tileDatas[0] = gameScreen.tilemap.CheckCollision(x - image.w2, y + image.h2, x - image.w2, tempY + image.h2, gameScreen.tilemap.COLLISION_LAYER)
					tileDatas[1] = gameScreen.tilemap.CheckCollision(x, y + image.h2, x, tempY + image.h2, gameScreen.tilemap.COLLISION_LAYER)
					tileDatas[2] = gameScreen.tilemap.CheckCollision(x + image.w2, y + image.h2, x + image.w2, tempY + image.h2, gameScreen.tilemap.COLLISION_LAYER)
					If tileDatas[0].tile <> 0 Or tileDatas[1].tile <> 0 Or tileDatas[2].tile <> 0 Then
						dy = 0
						jumping = False
					Else
						y = tempY
					End
				Else
					tileDatas[0] = gameScreen.tilemap.CheckCollision(x - image.w2, y - image.h2, x - image.w2, tempY - image.h2, gameScreen.tilemap.COLLISION_LAYER)
					tileDatas[1] = gameScreen.tilemap.CheckCollision(x, y - image.h2, x, tempY - image.h2, gameScreen.tilemap.COLLISION_LAYER)
					tileDatas[2] = gameScreen.tilemap.CheckCollision(x + image.w2, y - image.h2, x + image.w2, tempY - image.h2, gameScreen.tilemap.COLLISION_LAYER)
					If tileDatas[0].tile <> 0 Or tileDatas[1].tile <> 0 Or tileDatas[2].tile <> 0 Then
						dy = 0
					Else
						y = tempY
					End
				End
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