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
		Local tempx:Float
		Local pts:Vector2D[]
		Local endPoint:Vector2D
		Local okayToMove:Bool = false
			
		if KeyDown(KEY_LEFT)
			tempx = x - speedX
			pts = BresenhamLine(New Vector2D(x - self.image.w2, y), New Vector2D(tempx, y))
			okayToMove = true
			For Local v:Vector2D = EachIn pts
				if gameScreen.tilemap.CollisionTile(v.x, v.y, gameScreen.tilemap.COLLISION_LAYER) <> 0 Then
					okayToMove = False
					x = v.x + image.w2
					Exit
				End
				endPoint = v
			Next
			if okayToMove Then x = tempx
		Else if KeyDown(KEY_RIGHT)
			tempx = x + speedX
			pts = BresenhamLine(New Vector2D(x + self.image.w2, y), New Vector2D(tempx + image.w2, y))
			okayToMove = true
			For Local v:Vector2D = EachIn pts
				if gameScreen.tilemap.CollisionTile(v.x, v.y, gameScreen.tilemap.COLLISION_LAYER) <> 0 Then
					okayToMove = False
					x = v.x - image.w2
					Exit
				End
				endPoint = v
			Next
			if okayToMove Then x = tempx
		End
		
		If KeyDown(KEY_SPACE) And not jumping Then
			dy=-speedY
			jumping = true
		End
		
		Local amount:Int = 1
		Local amountY:int = 1
		
		if not jumping
			pts = BresenhamLine(New Vector2D(x, y + image.h2), New Vector2D(x, y + image.h2 + 2))
			okayToMove = true
			For Local v:Vector2D = EachIn pts
				if gameScreen.tilemap.CollisionTile(v.x, v.y, gameScreen.tilemap.COLLISION_LAYER) <> 0 Then
					okayToMove = False
					Exit
				End
				endPoint = v
			Next
			if okayToMove Then jumping = True
		End
		
		if jumping
			dy += MyTileMap.GRAVITY
			
			local tempY:Float = y + dy
			if dy <> 0
				if dy > 0
					pts = BresenhamLine(New Vector2D(x, y + image.h2), New Vector2D(x, image.h2 + tempY))
					endPoint = new Vector2D(x, y + image.h2)
					okayToMove = true
					For Local v:Vector2D = EachIn pts
						endPoint = v
						if gameScreen.tilemap.CollisionTile(v.x, v.y, gameScreen.tilemap.COLLISION_LAYER) <> 0 Then
							okayToMove = False
							dy = 0
							jumping = false
							y = v.y - image.h2
							Exit
						End
						
					Next
					if okayToMove Then y = tempY
				else
					pts = BresenhamLine(New Vector2D(x, y - image.h2), New Vector2D(x, tempY - image.h2))
					endPoint = new Vector2D(x, y + image.h2)
					okayToMove = true
					For Local v:Vector2D = EachIn pts
						endPoint = v
						if gameScreen.tilemap.CollisionTile(v.x, v.y, gameScreen.tilemap.COLLISION_LAYER) <> 0 Then
							okayToMove = False
							dy = 0
							y = v.y + image.h2
							Exit
						End
						
					Next
					if okayToMove Then y = tempY
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