#Rem
Copyright (c) 2011 Steve Revill and Shane Woolcock
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#End

Strict

Import mojo
Import threading

Function Main:Int()
	New MyApp
	Return 0
End

Class MyApp Extends App
	Field robot:Robot
	
	Method OnCreate:Int()
		SetUpdateRate(60)
		robot = New Robot(50, 50)
		Return 0
	End
	
	Method OnUpdate:Int()
		' Handle exit
		If KeyHit(KEY_ESCAPE) Then Error ""
		' Update our robot, which handles scripting and movement
		robot.Update()
		Return 0
	End
	
	Method OnRender:Int()
		Cls
		' Render our robot
		robot.Render()
		Return 0
	End
End

Class Robot Extends Coroutine
	' Our current location
	Field x:Float, y:Float
	
	' Where we first started moving from
	Field sourceX:Float, sourceY:Float
	
	' Where we're going
	Field targetX:Float, targetY:Float
	
	' How many frames it should take us to get there
	Field movementTotalFrames:Int
	
	' How many frames are left before we get there
	Field movementRemainingFrames:Int
	
	' How long left to wait
	Field waitFrames:Int
	
	Method New(x:Float, y:Float)
		Self.x = x
		Self.y = y
	End
	
	' Tell our robot where to move to
	Method MoveTo:Void(targetX:Float, targetY:Float, distancePerFrame:Float)
		' Store our source and target waypoints
		Self.sourceX = Self.x
		Self.sourceY = Self.y
		Self.targetX = targetX
		Self.targetY = targetY
		
		' Work out how many frames it will take to get there
		Local distance:Float = Sqrt((Self.targetX-Self.sourceX)*(Self.targetX-Self.sourceX)+(Self.targetY-Self.sourceY)*(Self.targetY-Self.sourceY))
		Local totalFrames:Int = distance/distancePerFrame
		Self.movementTotalFrames = totalFrames
		Self.movementRemainingFrames = totalFrames
	End
	
	' update our robot
	Method Update:Void()
		' If the robot is waiting, subtract one frame, otherwise resume the coroutine
		If waitFrames > 0 Then
			waitFrames -= 1
		Else
			' The parameter passed to Yield will be the return value for Resume
			waitFrames = Resume()
		End
		
		' If we're currently moving, interpolate our position
		If movementRemainingFrames > 0 Then
			' We've moved one frame closer
			movementRemainingFrames -= 1
			
			' This is how far we are into the movement
			Local alpha:Float = 1 - Float(movementRemainingFrames)/Float(movementTotalFrames)
			
			' Run a smoothstep algorithm on it (optional, but it makes the movement look much nicer)
			' See this website for an explanation: http://sol.gfxile.net/interpolation/
			alpha *= alpha * (3-2*alpha)
			
			' Update our position
			x = sourceX + alpha * (targetX-sourceX)
			y = sourceY + alpha * (targetY-sourceY)
		End
	End
	
	' Render our robot.
	Method Render:Void()
		' Our robot isn't very pretty and just looks like a circle
		SetColor 255, 0, 0
		DrawCircle x, y, 20
	End
	
	' The Run method acts as a kind of AI script, telling the robot what to do
	' This is called on the first call to Resume()
	Method Run:Int(param:Int)
		' Store our starting position
		Local startX:Float = x
		Local startY:Float = y
		
		' Our robot is fairly stupid and will just follow a set path forever
		Repeat
			' Start moving from start position to 200,200 at a speed of 4 pixels per frame
			MoveTo(200,200,4)
			
			' Wait until we get there
			Yield(Self.movementTotalFrames)
			
			' Announce we've arrived
			Print "Arrived at waypoint 1!"
			
			' Wait there for 60 frames
			Yield(60)
			
			' Start moving from 200,200 to 350,300 at a speed of 2 pixels per frame
			MoveTo(350,300,2)
			
			' Wait until we get there
			Yield(Self.movementTotalFrames)
			
			' Announce we've arrived
			Print "Arrived at waypoint 2!"
			
			' Wait there for 60 frames
			Yield(60)
			
			' Start moving back to the start at 5 pixels per frame
			MoveTo(startX,startY,5)
			
			' Wait until we get there
			Yield(Self.movementTotalFrames)
			
			' Announce we've arrived
			Print "Arrived at starting point!"
			
			' Wait there for 60 frames
			Yield(60)
			
			' Loop, starting all over again!
		Forever
	End
End
