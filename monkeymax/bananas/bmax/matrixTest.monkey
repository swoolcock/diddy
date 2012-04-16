Strict

Import mojo

Const WIDTH#=320'/4
Const HEIGHT#=240'/4

Global shearx:Float=1

Global sheary:Float=-1

Function Main:Int()
	New Game()
	Return 0
End

Class Sprite
	Field x#,vx#
	Field y#,vy#
	Field f#,vf#
	
	Method New(xx#,yy#)
		Self.x=xx
		Self.y=yy
	End
		
	Method Update:Void()
		'x+=vx
		'If x<0 Or x>=WIDTH vx=-vx
		'y+=vy
		'If y<0 Or y>=HEIGHT vy=-vy
		'f+=vf
		'If f>=8 f-=8
	End
	
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
	
	Field time%,frames%,fps%
	Field image:Image
	Field sprites:=New Stack<Sprite>

	Method OnCreate:Int()
		image=LoadImage( "floor.png", Image.MidHandle )
		sprites.Push New Sprite(220,80)
		time=Millisecs()
		ReloadImage()
		SetUpdateRate 60
		PushMatrix()
		Return 0
	End
	Method OnUpdate:Int()
	
		For Local sprite:=Eachin sprites
			sprite.Update
		Next
		If KeyDown(KEY_A)
			shearx=shearx+0.01
		Endif
		If KeyDown(KEY_D)
			shearx=shearx-0.01
		Endif
		If KeyDown(KEY_W)
			sheary=sheary+0.01
		Endif
		If KeyDown(KEY_S)
			sheary=sheary-0.01
		Endif
	
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
		frames+=1
		Local e:=Millisecs()-time
		If e>=1000
			fps=frames
			frames=0
			time+=e
		Endif
		
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
		DrawText "a/w/s/d = shear", 100, 455
		
		DrawText "shear x "+shearx,0,0
		DrawText "shear y "+sheary,0,20
		
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

		For Local sprite:=Eachin sprites
			PushMatrix
				Scale DeviceWidth()/WIDTH,DeviceHeight()/HEIGHT
				Translate sprite.x,sprite.y
				Scale(0.5,0.25)
				Transform 1,shearx,sheary,1,0,0
				DrawImage image,0,0,sprite.f
			PopMatrix
		Next

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