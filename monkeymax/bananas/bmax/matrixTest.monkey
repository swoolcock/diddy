Strict

Import mojo

Function Main:Int()
	New Game()
	Return 0
End

Class Game Extends App
	Field sprite:Image
	Field x# = 300
	Field y# = 300
	Field rot# = 0
	Field scaleX# = 1
	Field scaleY# = 1
	Field frame% = 0
	Field midhandled:Bool = True
	
	Method OnCreate:Int()
		ReloadImage()
		SetUpdateRate 60
		Return 0
	End
	Method OnUpdate:Int()
		If KeyDown(KEY_Z) Then rot+=1
		If KeyDown(KEY_X) Then rot-=1
		If KeyDown(KEY_RIGHT) Then scaleX+=0.1
		If KeyDown(KEY_LEFT) Then scaleX-=0.1
		If KeyDown(KEY_UP) Then scaleY+=0.1
		If KeyDown(KEY_DOWN) Then scaleY-=0.1
		If KeyHit(KEY_ESCAPE) Then Error ""
		If KeyHit(KEY_SPACE) Then
			midhandled = Not midhandled
			ReloadImage()
		End
		If KeyHit(KEY_C) Then
			rot = 0
			scaleX = 1
			scaleY = 1
		Endif
		Return 0
	End
	Method OnRender:Int()
		Cls(0, 0 ,0)
		DrawImage sprite, 100, 100
		
		SetColor(255,255,0)
		DrawImage sprite, x, y, rot, -scaleX, scaleY, frame
		
		SetColor(0,255,0)
		DrawImage sprite, x, y, rot, scaleX, -scaleY, frame
		
		SetColor(255,0,255)
		DrawImage sprite, x, y, rot, -scaleX, -scaleY, frame
		
		' draw the unflipped one last, so that we can see it when midhandled
		SetColor(0,255,255)
		DrawImage sprite, x, y, rot, scaleX, scaleY, frame
		
		SetColor(255,255,255)
		DrawCircle x,y,3
		DrawText "up/down/left/right=scale, z/x=rotation, c=reset, space=toggle midhandle", 100, 400
		DrawText "scaleX="+scaleX, 100, 415
		DrawText "scaleY="+scaleY, 100, 430
		DrawText "rot="+rot, 100, 445

		DrawText "-1, 1", 200, 130
		PushMatrix
		Translate 200, 100
		Scale -1, 1
		DrawImage sprite, 0, 0
		PopMatrix

		DrawText "1, -1", 300, 130
		PushMatrix
		Translate 300, 100
		Scale 1, -1
		DrawImage sprite, 0, 0
		PopMatrix
		
		DrawText "-1, -1", 400, 130
		PushMatrix		
		Translate 400, 100
		Scale -1, -1
		DrawImage sprite, 0, 0
		PopMatrix
				
		Return 0
	End
	
	Method ReloadImage:Void()
		If midhandled Then
			sprite = LoadImage("gripe.jump_right.png", 1,Image.MidHandle)
		Else
			sprite = LoadImage("gripe.jump_right.png", 1)
		End
	End
End