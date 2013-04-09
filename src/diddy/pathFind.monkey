#Rem
Copyright (c) 2011 Steve Revill and Shane Woolcock
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#End

Strict

Import assert

'summary: A* Pathfinder
Class PathFinder Abstract
	'0=no diagonal movement.
	'1=diagonal movement and cutting corners allowed.
	'2=diagonal movement but no cutting corners.
	Global diagonals:Int
	
	'the higher this number, the more the path will randomly differ from what is optimum.
	Global randomity:Float
	
	Global mapWidth:Int
	Global mapHeight:Int
	
	'Map is a float. The closer to 1 the harder it is to move into this tile.
	'All values 1 or greater are considered walls.
	Global map:Float[]
	
	'The amount of steps in the route.
	Global paths:Int
	
	'The resulting path
	Global route:Int[]
	
	'The higher the BasicCost, the more accurate and slow pathfinding will be.
	Const basicCost:Float = .17
	
	'Private
	Global pathMap:Path[]
	Const ROOT2:Float = 1.4142
	
	Function SetMap:Void(arr:Float[], width:Int, height:Int, diag:Int=1, random:Float=0)
		map = arr
		mapWidth = width
		mapHeight = height
		diagonals = diag
		randomity = random
	End
	
	'Returns 1 if successful and 0 if unsuccessful.
	'Fills the route[] array if successful.
	Function FindPath:Int(startX:Int, startY:Int, endX:Int, endY:Int)
		Assert(Not (startX < 0 Or startY < 0 Or startX >= mapWidth Or startY >= mapHeight) ,"Starting point out of bounds: " + startX + "," + startY)
		Assert(Not (endX < 0 Or endY < 0 Or endX >= mapWidth Or endY >= mapHeight), "End point out of bounds: " + endX + "," + endY)
		
		paths = 0
		
		'already on target
		If startX = endX And startY = endY Then
			route = New Int[2]
			route[0] = startX
			route[1] = startY
			paths = 1
			Return 1
		End
		'target is a wall
		If map[endX + endY * mapWidth] >= 1 Then Return 0
		
		Local p:Path
		Local p2:Path
		Local newP:Path
		Local newX:Int
		Local newY:Int
		Local dir:Int
		Local dirMax:Int
		Local done:Int
		Local head:Path
		Local mapHere:Float
		Local distX:Int
		Local distY:Int
		
		pathMap = New Path[mapWidth * mapHeight]
		
		'make first path node at start
		p = New Path
		head = p
		p.x = startX
		p.y = startY
		pathMap[startX + startY * mapWidth] = p
				
		If diagonals Then
			dirMax = 7
		Else
			dirMax = 3
		End
		
		Repeat
			For dir = 0 To dirMax
				'move based on direction
				Select dir
					Case 0
						newX = p.x + 1
						newY = p.y
					Case 1
						newX = p.x
						newY = p.y + 1
					Case 2
						newX = p.x - 1
						newY = p.y
					Case 3
						newX = p.x
						newY = p.y - 1
					Case 4
						newX = p.x + 1
						newY = p.y + 1
					Case 5
						newX = p.x - 1
						newY = p.y + 1
					Case 6
						newX = p.x - 1
						newY = p.y - 1
					Case 7
						newX = p.x + 1
						newY = p.y - 1
				End
		
				'check if it is ok to make a new path node here.
				If newX >= 0 And newY >= 0 And newX < mapWidth And newY < mapHeight Then
					mapHere = map[newX + newY * mapWidth]

					If mapHere < 1 Then
					
						'No cutting corners
						If diagonals = 2 And dir > 3 Then
							If map[newX + p.y * mapWidth] >= 1 Then Continue
							If map[p.x + newY * mapWidth] >= 1 Then Continue
						End
						
						p2 = pathMap[newX + newY * mapWidth]
						
						'check if there already is a path here
						If p2 = Null Then
							'make new node
							newP = New Path
							pathMap[newX + newY * mapWidth] = newP
							newP.parent = p
							newP.x = newX
							newP.y = newY
							
							'cost is slightly more for diagonals
							If dir < 4 Then
								newP.cost = p.cost + .1 + mapHere + Rnd(0, randomity)
							Else
								newP.cost = p.cost + (.1 + mapHere + Rnd(0, randomity)) * ROOT2
							End

							'Calculate distance from this node to target.
							If diagonals Then
								distX = Abs(newX - endX)
								distY = Abs(newY - endY)
								If distX > distY Then
									newP.dist = distX - distY + distY * ROOT2
								Else
									newP.dist = distY - distX + distX * ROOT2
								End
								newP.dist *= .1
							Else
								newP.dist = (Abs(newX - endX) + Abs(newY - endY)) / 8.0
							End
							
							'insert node at appropriate spot in list
							p2 = p
							Repeat
								If p2.after = Null Then
									p2.after = newP
									Exit
								End
								If p2.after.dist + p2.after.cost > newP.dist + newP.cost Then
									newP.after = p2.after
									p2.after = newP
									Exit
								End
								p2 = p2.after
							Forever
							
							'check if found end
							If newX = endX And newY = endY Then
								done = 1
								Exit
							End
						Else
							'overwrite existing path node if this way costs less.
							If p2.cost > p.cost + basicCost + mapHere * ROOT2 + randomity Then
								p2.parent = p
								'cost is slightly more for diagnols
								If dir < 4 Then
									p2.cost = p.cost + basicCost + mapHere + Rnd(0, randomity)
								Else
									p2.cost = p.cost + (basicCost + mapHere + Rnd(0, randomity)) * ROOT2
								End
							End
						End
					End
				End
			Next
			
			If done = 1 Then Exit
			
			p = p.after
			If p = Null Then Exit
			
		Forever
		
		If done Then
			'count how many paths
			p2 = newP
			Repeat
				paths += 1
				p2 = p2.parent
				If p2 = Null Then Exit
			Forever
			
			'make route from end to start
			route = New Int[paths * 2]
			Local i:Int = 0
			p2 = newP
			Repeat
				route[i] = p2.x
				i += 1
				route[i] = p2.y
				i += 1
				p2 = p2.parent
				If p2 = Null Then Exit
			Forever
		End
		
		'nullify pointers so mem will be deallocated.
		p = head
		Repeat
			p.parent = Null
			p = p.after
			If p = Null Then Exit
		Forever
		
		Return done
	End
End

Class Path
	Field x:Int
	Field y:Int
	Field parent:Path
	Field cost:Float
	Field dist:Float
	Field after:Path
End