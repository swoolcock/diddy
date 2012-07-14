Import diddy
Import level
Import screens

Class Player extends Sprite
	Field jumping:Bool
	Field speedX:Float = 3
	Field speedY:Float = 15
	
	Method New(img:GameImage, x:Float, y:Float)
		Self.image = img
		Self.x = x
		Self.y = y
		Self.alpha = 1
		Self.SetHitBox(-img.w2, -img.h2, img.w, img.h)
		Self.visible = True
	End
	
	Method Update:Void()
	
		if KeyDown(KEY_LEFT)
			Local tempx:Float = x - speedX
			if gameScreen.tilemap.CollisionTile(tempx - image.w2, y + image.h2 - 1, "Tile Layer 1") = 0 and
				gameScreen.tilemap.CollisionTile(tempx - image.w2, y - image.h2, "Tile Layer 1") = 0 and
				gameScreen.tilemap.CollisionTile(tempx - image.w2, y, "Tile Layer 1") = 0 then
				x = tempx
			else
				x = Round( (x - image.w2) / gameScreen.tilemap.tileWidth) * gameScreen.tilemap.tileWidth + image.w2
			End
		Else if KeyDown(KEY_RIGHT)
			Local tempx:Float = x + speedX
			if gameScreen.tilemap.CollisionTile(tempx + image.w2, y + image.h2 - 1, "Tile Layer 1") = 0 and
				gameScreen.tilemap.CollisionTile(tempx + image.w2, y - image.h2, "Tile Layer 1") = 0 and
				gameScreen.tilemap.CollisionTile(tempx + image.w2, y, "Tile Layer 1") = 0 then
				x = tempx
			else
				x = Round( (x + image.w2) / gameScreen.tilemap.tileWidth) * gameScreen.tilemap.tileWidth - image.w2
			end
		End
		
		If KeyDown(KEY_SPACE) And not jumping Then
			dy=-speedY
			jumping = true
		End
		
		Local amount:Int = 1
		Local amountY:int = 1
		
		if not jumping
			if gameScreen.tilemap.CollisionTile(x - image.w2 + amount, y + image.h2, "Tile Layer 1") = 0 And
				gameScreen.tilemap.CollisionTile(x + image.w2 + amount, y + image.h2, "Tile Layer 1") = 0 And
				gameScreen.tilemap.CollisionTile(x, y + image.h2, "Tile Layer 1") = 0
	
				jumping = true
			end
		End
		
		if jumping
			dy += MyTileMap.GRAVITY
			
			local tempY# = y + dy
			if dy <> 0
				if dy > 0
					if gameScreen.tilemap.CollisionTile(x, y + image.h - amountY, "Tile Layer 1") > 0 or
						gameScreen.tilemap.CollisionTile(x - image.w2 + amount, y + image.h - amountY, "Tile Layer 1") > 0 or
						gameScreen.tilemap.CollisionTile(x + image.w2 + amount, y + image.h - amountY, "Tile Layer 1") > 0
						
						dy = 0
						jumping = false
						y = Round( (tempY + image.h) / gameScreen.tilemap.tileHeight) * gameScreen.tilemap.tileHeight - image.h
					else
						y = tempY
					end
				else
					if gameScreen.tilemap.CollisionTile(x, y - image.h - amountY, "Tile Layer 1") > 0 or
						gameScreen.tilemap.CollisionTile(x - image.w2 + amount, y - image.h - amountY, "Tile Layer 1") > 0 or
						gameScreen.tilemap.CollisionTile(x + image.w2 + amount, y - image.h - amountY, "Tile Layer 1") > 0
					
						dy = 0
						y = Round( (tempY - image.h) / gameScreen.tilemap.tileHeight) * gameScreen.tilemap.tileHeight + image.h
						
					else
						y = tempY
					end
				End
			End
		End
		
		Local border:Int = 200
		Local borderY:Int = 200
		If x - game.scrollX < border Then gameScreen.tilemap.Scroll( (x - game.scrollX) - border, 0)
		If x - game.scrollX > SCREEN_WIDTH - border Then gameScreen.tilemap.Scroll( (x - game.scrollX) - (SCREEN_WIDTH - border), 0)
		If y - game.scrollY < borderY Then gameScreen.tilemap.Scroll(0, (y - game.scrollY) - borderY)
		If y - game.scrollY > SCREEN_HEIGHT - borderY Then gameScreen.tilemap.Scroll(0, (y - game.scrollY) - (SCREEN_HEIGHT - borderY))

	End
	
End