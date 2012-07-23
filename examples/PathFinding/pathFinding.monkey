Strict

Import diddy

Global gameScreen:GameScreen

Function Main:Int()
	New MyGame()
	Return 0
End

Class MyGame Extends DiddyApp

	Method OnCreate:Int()
		Super.OnCreate()
		gameScreen = New GameScreen
		game.Start(gameScreen)
		Return 0
	End
End

Class GameScreen Extends Screen
	Const MAP_WIDTH:Int = 20
	Const MAP_HEIGHT:Int = 20
	Const TILE_SIZE:Int = 20
	
	Field grid:Float[MAP_WIDTH * MAP_HEIGHT]
	Field fx:Int, fy:Int
	Field mx:Int, my:Int
	Field startX:Int = 1, startY:Int = 1
	Field endX:Int = 10, endY:Int = 15
	Field x:Float, y:Float
	Field i:Int
	Field z:Int, g:Float
	Field currentPath:Int = 0
	
	Method New()
		name = "Game"
	End
	
	Method Start:Void()
		PathFinder.SetMap(grid, MAP_WIDTH, MAP_HEIGHT, 2, 0)
		x = startX * TILE_SIZE
		y = startY * TILE_SIZE
	End
	
	Method Render:Void()
		Cls
		
		'Draw grid tiles
		For fy = 0 Until MAP_HEIGHT
			For fx = 0 Until  MAP_WIDTH
				If grid[fx + fy * MAP_WIDTH] > 0 Then
					SetColor grid[fx + fy * 20] * 255, 0, 0
					DrawRect fx * TILE_SIZE, fy * TILE_SIZE, TILE_SIZE, TILE_SIZE
				End
			Next
		Next
		
		'Draw grid lines
		SetColor 255, 255, 255
		For fx = 0 To MAP_WIDTH
			DrawLine fx * TILE_SIZE, 0, fx * TILE_SIZE, MAP_HEIGHT * TILE_SIZE
			DrawLine 0, fx * TILE_SIZE, MAP_WIDTH * TILE_SIZE, fx * TILE_SIZE
		Next
		
		'Draw the "player" position
		SetColor 255, 0, 255
		DrawOval x, y, TILE_SIZE, TILE_SIZE
		
		'Draw end position
		SetColor 255, 255, 0
		DrawOval endX * TILE_SIZE, endY * TILE_SIZE, TILE_SIZE, TILE_SIZE

		'Draw path
		SetColor 0, 255, 0
		For i = 0 Until PathFinder.paths * 2 Step 2
			DrawRect PathFinder.route[i] * TILE_SIZE + TILE_SIZE/2, PathFinder.route[i + 1] * TILE_SIZE+ TILE_SIZE/2, 5, 5
		Next

		SetColor 255, 255, 255		
		DrawHUD()
	End

	Method SetPath:Void()
		startX = x / TILE_SIZE
		startY = y / TILE_SIZE
		PathFinder.FindPath(startX, startY, endX, endY)
		currentPath = (PathFinder.paths - 1) * 2
	End

	Method Update:Void()
		mx = game.mouseX / TILE_SIZE
		my = game.mouseY / TILE_SIZE
		mx = Max(mx, 0)
		mx = Min(mx, 19)
		my = Max(my, 0)
		my = Min(my, 19)
		
		If MouseDown(0) Then 
			grid[mx + my * MAP_WIDTH] = 1
			SetPath()
		End
		
		If MouseDown(MOUSE_MIDDLE) Then
			grid[mx + my * MAP_WIDTH] = 0
			SetPath()
		End

		If KeyHit(KEY_SPACE)
			endX = mx
			endY = my
			SetPath()
		End

		If currentPath >= 0 And PathFinder.route.Length() > 0
			If x < PathFinder.route[currentPath] * TILE_SIZE
				x += 1
			End
			If x > PathFinder.route[currentPath] * TILE_SIZE
				x -= 1
			End
			If y < PathFinder.route[currentPath + 1] * TILE_SIZE
				y += 1
			End
			If y > PathFinder.route[currentPath + 1] * TILE_SIZE
				y -= 1
			End
					
			If x = PathFinder.route[currentPath] * TILE_SIZE And
				y = PathFinder.route[currentPath + 1] * TILE_SIZE
				currentPath -= 2
			End
		End

		If KeyHit(KEY_ESCAPE)
			FadeToScreen(Null)
		End
	End
		
	Method DrawHUD:Void()
		DrawText "No. of paths = "+ PathFinder.paths, SCREEN_WIDTH, 10, 1
		DrawText "Mouse Grid = "+ mx+ "," + my, SCREEN_WIDTH, 30, 1
		If PathFinder.route.Length() > 0 Then DrawText "currentPath = " + PathFinder.route[currentPath] + "," + PathFinder.route[currentPath + 1], SCREEN_WIDTH, 30, 1		
		FPSCounter.Draw(SCREEN_WIDTH, SCREEN_HEIGHT  - 12, 1)
	End
End
