Strict
Import mojo

Global game:MyGame

Function Main:Int()
	game = New MyGame()
	Return 0
End Function

Const PDM_smlparticle%=0
Const PDM_medparticle%=1
Const PDM_bigparticle%=2
Const PDM_spark%=3

Const STATE_TITLE% = 0
Const STATE_GAME% = 1
Const STATE_NEXT_LEVEL% = 2
Const STATE_GAME_OVER% = 3

Global ASTEROIDS_NUM%
Global ASTEROIDS_SIZE%

Class MyGame Extends FrameworkApp
	Field player:Player
	Field cg%, cr%, cb%
	Field level% = 1
	Field score% = 0
	Field bestScore% = 0
	Field noOfStars% = 250
	' Current game state
	Global gameState:Int = STATE_TITLE
	
	Method OnCreate:Int()
		Super.OnCreate()
		createStars()
		reset()		
		Return 0
	End Method
	
	Method setState:Void(state:Int)
		gameState = state
	End
	
	Method createStars:Void()
		For Local i% = 0 To noOfStars
			New Star(Rnd(0, SCREEN_WIDTH), Rnd(0, SCREEN_HEIGHT))
		Next
	End Method
	
	Method reset:Void()
		Bullet.list.Clear()
		Asteroid.list.Clear()
		Particle.list.Clear()
		Spark.list.Clear()
		cg = 0
		cr = 0
		cb = 0
		level = 1
		ASTEROIDS_NUM = 2
		ASTEROIDS_SIZE = 4
		score = 0
		player = New Player(SCREEN_WIDTH2, SCREEN_HEIGHT2)
		fillAsteroids(ASTEROIDS_NUM, ASTEROIDS_SIZE)		
	End Method
	
	Method OnLoading:Int()
		Super.OnLoading()
		Return 0
	End Method
	
	Method OnUpdate:Int()
		Super.OnUpdate()
		
		Select gameState
			Case STATE_TITLE
				Asteroid.updateAll()
				If KeyHit(KEY_SPACE)
			   		setState(STATE_GAME)
				Endif			
			Case STATE_GAME
				player.Update()
				Spark.updateAll
				Bullet.updateAll()
				Asteroid.updateAll()
				Particle.updateAll()
				checkCollisions()
				clscolor()
			Case STATE_NEXT_LEVEL
				Asteroid.updateAll()
				If KeyHit(KEY_SPACE)
			   		setState(STATE_GAME)
				Endif			
				
			Case STATE_GAME_OVER
				Asteroid.updateAll()
				Particle.updateAll()			
				If KeyHit(KEY_SPACE)
			   		setState(STATE_TITLE)
					reset()
				Endif
		End Select
	
		Return 0
	End Method
	
	Method clscolor:Void()
		If cr > 0
			cr-=2*dt.delta
		Else
			cr = 0
		Endif
	End Method

	Method OnRender:Int()
		Super.OnRender()
		
		Select gameState
			Case STATE_TITLE
				Cls 0, 0, 0
				Star.drawAll()
				Asteroid.drawAll()
				DrawText "ASTEROIDS - MONKEY STYLE!", SCREEN_WIDTH2, SCREEN_HEIGHT2, 0.5, 0.5
				DrawText "BEST SCORE: "+Self.bestScore, SCREEN_WIDTH2, SCREEN_HEIGHT2 + 30, 0.5, 0.5
				DrawText "PRESS <SPACE> TO PLAY", SCREEN_WIDTH2, SCREEN_HEIGHT2 + 60, 0.5, 0.5

			Case STATE_GAME		
				Cls cr, cg, cb
				Star.drawAll()
				player.draw()
				Spark.drawAll()
				Bullet.drawAll()
				Asteroid.drawAll()
				Particle.drawAll()
				drawHUD()
			Case STATE_NEXT_LEVEL
				Cls cr, cg, cb
				Star.drawAll()
				
				SetAlpha 0.7
				SetColor 255,0,0
				DrawOval player.x-15, player.y-15, 30, 30

				SetAlpha 0.6
				SetColor 0,55,55
				DrawOval player.x-13, player.y-13, 27, 27
				
				player.draw()
				Spark.drawAll()
				Bullet.drawAll()
				Asteroid.drawAll()
				Particle.drawAll()			
				DrawText "NEXT LEVEL!", SCREEN_WIDTH2, SCREEN_HEIGHT2-60, 0.5, 0.5
				DrawText "PRESS <SPACE> TO PLAY", SCREEN_WIDTH2, SCREEN_HEIGHT2 + 60, 0.5, 0.5
				drawHUD()
			Case STATE_GAME_OVER
				Cls 0, 0, 0
				Star.drawAll()
				Asteroid.drawAll()
				Particle.drawAll()
				DrawText "GAME OVER!", SCREEN_WIDTH2, SCREEN_HEIGHT2, 0.5, 0.5
				DrawText "SCORE: "+score, SCREEN_WIDTH2, SCREEN_HEIGHT2 + 30, 0.5, 0.5
				DrawText "BEST SCORE: "+Self.bestScore, SCREEN_WIDTH2, SCREEN_HEIGHT2 + 60, 0.5, 0.5
				DrawText "PRESS <SPACE> TO RETURN TO THE TITLE SCREEN", SCREEN_WIDTH2, SCREEN_HEIGHT2 + 90, 0.5, 0.5
		End Select
				
		Return 0
	End Method

	Method checkCollisions:Void()
		For Local a:Asteroid = Eachin Asteroid.list
		
			If dist(player.x, player.y, a.x, a.y) <= a.avgrad
				If cr = 0 Then cr = Rnd(100, 155)
				player.shield-=2
			Endif
		
			For Local b:Bullet = Eachin Bullet.list	
				If a <> Null Then	
					If dist(b.x, b.y, a.x, a.y) <= a.avgrad
						a.life = a.life - 1
						b.life = 0
						For Local t%=1 To 4
							New Particle(a.x, a.y, Rnd(-8,8), Rnd(-8,8), 0.95, 30, PDM_spark, 255, 192, 64, 16)
						Next
						For Local t%=1 To 4
							New Particle(a.x, a.y, Rnd(-4,4), Rnd(-4,4), 0.95, 60, PDM_smlparticle, 160, 160, 160, 0)
						Next
					Endif
					If a.life <= 0
					
						For Local t%=1 To 4
							New Particle(a.x,a.y,Rnd(-10,10),Rnd(-10,10),0.95,30,PDM_spark,255,192,64,64)
						Next
						For Local t%=1 To 3
							New Particle(a.x,a.y,Rnd(-6,6),Rnd(-6,6),0.95,30,PDM_medparticle,255,192,64,128)
						Next
						For Local t%=1 To 3
							New Particle(a.x,a.y,Rnd(-8,8),Rnd(-8,8),0.99,60,PDM_smlparticle,160,160,160,0)
						Next
						For Local t%=1 To 2
							New Particle(a.x,a.y,Rnd(-6,6),Rnd(-6,6),0.99,60,PDM_medparticle,160,160,160,0)
						Next
						For Local t%=1 To 2
							New Particle(a.x,a.y,Rnd(-4,4),Rnd(-4,4),0.99,60,PDM_bigparticle,160,160,160,0)
						Next
						
						If a.size > 2
							For Local t% = 1 To 2
								New Asteroid(a.x, a.y, Rnd(-5,5), Rnd(-5,5), a.size-1)
							Next
						Endif
						Asteroid.list.Remove(a)
						a = Null
						score+=5
					Endif
				Endif
			Next
		Next
		If Asteroid.list.Count() = 0
			level+=1
			Asteroid.list.Clear()
			ASTEROIDS_SIZE+=1
			ASTEROIDS_NUM+=1
			fillAsteroids(ASTEROIDS_NUM, ASTEROIDS_SIZE)
			Bullet.list.Clear()
			Spark.list.Clear()	
			Particle.list.Clear()
			cg = 0
			cr = 0
			cb = 0
			player.x = SCREEN_WIDTH2
			player.y = SCREEN_HEIGHT2
			player.rotation = 0
			player.acc = 0
			player.xa  =0
			player.xv = 0
			player.drag = 0
			player.ya = 0
			player.yv  =0
			setState(STATE_NEXT_LEVEL)
		Endif
	End Method
	
	Method drawHUD:Void()
		DrawText "LEVEL: "+level, 0, 0
		DrawText "SCORE: "+score, SCREEN_WIDTH, 0, 1, 0
				
		FPSCounter.draw(SCREEN_WIDTH,SCREEN_HEIGHT, 1, 1)
	End Method

	Method fillAsteroids:Void(num%, size%)
		Local tx#
		Local ty#
		For Local t% = 1 To num
			Repeat
				tx=Rnd(640)
				ty=Rnd(480)
			Until ( tx<280 Or tx>360 ) And ( ty<200 Or ty>280 )
			New Asteroid(tx, ty, Rnd(-3,3), Rnd(-3,3), size+Rnd(1))
		Next
	End Method	
End Class

Class Star
	Global list:List<Star> = New List<Star>
	Field red%, green%, blue%, alpha#
	Field x#, y#
	Method New(x#,y#)
		Self.x=x
		Self.y=y
		Local col:=Rnd(255)
		Self.red = col
		Self.green = col
		Self.blue = col
		list.AddLast Self
	End Method
	
'	Function updateAll:Void()
'		If not list Return
'		For local b:Star = Eachin list
'			b.update()		
'		Next
'	End Function
	
	Function drawAll:Void()
		If Not list Return
		For Local b:Star = Eachin list
			b.draw()
		Next		
	End Function
	
'	Method update:Void()
'
'	End Method
	
	Method draw:Void()
		SetColor Self.red, Self.green, Self.blue
		DrawRect x, y, 1, 1
		SetColor 1, 1, 1
	End Method
End Class

Class Particle Extends Sprite
	Global list:List<Particle> = New List<Particle>

	Field xv#,yv#
	Field vm#
	Field life#,mlife#
	Field drawmode%
	Field cr%,cg%,cb%
	Field cflash%
	
	Method New(x#,y#,xv#,yv#,vm#,life#,drawmode%,cr%,cg%,cb%,cflash%)
		Self.x=x
		Self.y=y
		Self.xv=xv
		Self.yv=yv
		Self.vm=vm
		Self.life=life
		Self.mlife=life
		Self.drawmode=drawmode
		Self.cr=cr
		Self.cg=cg
		Self.cb=cb
		Self.cflash=cflash
		
		list.AddLast Self
	End Method
	
	Function updateAll:Void()
		If Not list Return
		For Local b:Particle = Eachin list
			b.update()		
		Next
	End Function
	
	Function drawAll:Void()
		If Not list Return
		For Local b:Particle = Eachin list
			b.draw()
		Next		
	End Function
	
	Method update:Void()
		Self.x =Self.x +Self.xv *dt.delta
		Self.y =Self.y +Self.yv *dt.delta
		Self.xv =Self.xv *(1.0-(1.0-Self.vm )*dt.delta )
		Self.yv =Self.yv *(1.0-(1.0-Self.vm )*dt.delta )
		Self.life =Self.life -dt.delta
		If Self.life <0 Then Self.life =0
		
		If Self.life =0
			list.Remove(Self)
		Endif
	End Method
	
	Method draw:Void()
		Local tmul# = Self.life /Self.mlife 
		Local tfls#=Rnd(-Self.cflash,Self.cflash)
		SetColor limit (Self.cr*tmul +tfls,Rnd(0,255),Rnd(0,255)),limit (Self.cg*tmul +tfls, Rnd(0,255), Rnd(0,255)),limit (Self.cb *tmul+tfls,Rnd(0,255),Rnd(0,255))
		Select Self.drawmode
			Case PDM_smlparticle
				SetAlpha 0.8
				DrawRect Self.x ,Self.y , 1, 1
			Case PDM_medparticle
				SetAlpha 0.5
				DrawOval Self.x -1,Self.y -1,3,3
			Case PDM_bigparticle
				SetAlpha 0.6
				DrawOval Self.x -2,Self.y -2,5,5
			Case PDM_spark
				SetAlpha 0.8
				DrawLine Self.x ,Self.y ,Self.x +Self.xv ,Self.y +Self.yv
		End Select
		SetAlpha 1
	End Method
End Class

Class Bullet Extends Sprite
	Global list:List<Bullet> = New List<Bullet>
	Field xv# ,yv#
	Field life#
	Field cr%, cg%, cb%
		
	Method New(x#,y#,xv#,yv#,life#,cr%,cg%,cb%)
		Self.x = x
		Self.y = y
		Self.xv = xv
		Self.yv = yv
		Self.life = life
		Self.cr = cr
		Self.cg = cg
		Self.cb = cb
		
		list.AddLast Self
	End Method
	
	Function updateAll:Void()
		If Not list Return
		For Local b:Bullet = Eachin list
			b.update()
			If b.life < 0
				Bullet.list.Remove(b)
				b = Null
			Endif
			
		Next
	End Function
	
	Method update:Void()
		x = x + xv * dt.delta
		y = y + yv * dt.delta
		
		life-=dt.delta
		If x < 0 x = SCREEN_WIDTH
		If x > SCREEN_WIDTH x = 0
		If y < 0 y = SCREEN_HEIGHT
		If y > SCREEN_HEIGHT y = 0
	End Method
	
	Function drawAll:Void()
		If Not list Return
		For Local b:Bullet = Eachin list
			b.draw()
		Next		
	End Function
	
	Method draw:Void()
		Local tmul#
		If life <= 15.0
			tmul = life / 15.0
		Else
			tmul = 1.0
		Endif
		SetColor cr*tmul, cg*tmul, cb*tmul
		SetAlpha 0.08
		LineB x, y, x + xv, y + yv, 6
		SetAlpha 0.01
		LineB x, y, x + xv, y + yv, 12		
		SetAlpha 1
		DrawLine x, y, x + xv, y + yv
	End Method
End Class

Class Asteroid Extends Sprite
	Global list:List<Asteroid> = New List<Asteroid>
	Field xv#,yv#
	Field ang#,angvel#
	Field rad#[9]
	Field avgrad#
	Field size%
	Field life%
	Field cr%, cg%, cb%	
	
	Method New(x#,y#,xv#,yv#,size%)
		Self.x =x 
		Self.y =y 
		Self.xv =xv 
		Self.yv =yv 
		Self.ang =Rnd(360)
		Self.angvel =Rnd(-6,6)
		Self.size=size
		Self.life=size
		Local tcol% = Rnd(-48,48)
		Self.cr=128+tcol
		Self.cg=128+tcol
		Self.cb=128+tcol
		' Create "Rockiness"
		Self.avgrad =0
		For Local t% = 0 To 7
			Self.rad[t]=size*8.0+Rnd(-size*4.0,size*4.0)
			Self.avgrad =Self.avgrad +Self.rad[t]
		Next
		Self.avgrad =Self.avgrad /6.0
		Self.rad[8] = Self.rad[0]
		
		list.AddLast Self
	End Method
	
	Function drawAll:Void()
		If Not list Return
		For Local b:Asteroid = Eachin list
			b.draw()
		Next		
	End Function
	
	Function updateAll:Void()
		If Not list Return
		For Local b:Asteroid = Eachin list
			b.update()		
		Next
	End Function
	
	Method update:Void()
		Self.x =Self.x +Self.xv * dt.delta 
		Self.y =Self.y +Self.yv * dt.delta 
		Self.rotation =Self.rotation +Self.angvel * dt.delta 
		
		If Self.x <-Self.avgrad  Then Self.x =Self.x + SCREEN_WIDTH + Self.avgrad *2
		If Self.x >SCREEN_WIDTH+Self.avgrad  Then Self.x =Self.x - SCREEN_WIDTH - Self.avgrad *2
		If Self.y <-Self.avgrad  Then Self.y =Self.y + SCREEN_HEIGHT + Self.avgrad *2
		If Self.y >SCREEN_HEIGHT+Self.avgrad  Then Self.y =Self.y - SCREEN_HEIGHT - Self.avgrad *2
	End Method
	
	Method draw:Void()
		Local tmul# = 360.0 / 8.0
		Local r% = limit(cr + 100, 0, 255)
		Local g% = limit(cg + 100, 0, 255)
		
		Local x1# 
		Local y1# 
		Local x2#
		Local y2#
		Local glowOn% = 1
		SetColor r, g, 0
		For Local t% = 0 To 7
			x1 = (Sin(rotation+(t)*tmul)*rad[t])
			y1 = (Cos(rotation+(t)*tmul)*rad[t])
			x2 = (Sin(rotation+(t+1)*tmul)*rad[t+1])
			y2 = (Cos(rotation+(t+1)*tmul)*rad[t+1])
			
			If glowOn = 1
			For Local i% = 1 To 3
				Select i
					Case 1
						SetAlpha 0.04
					Case 2
						SetAlpha 0.01
					Case 3
						SetAlpha 0.01
				End Select
				LineB x - x1, y - y1, x - x2, y - y2, i * 6
			Next
			Endif				
			SetAlpha 1
			DrawLine x-x1,y-y1,x-x2,y-y2
		Next
	End Method
End Class

Class Spark Extends Sprite
	Global list:List<Spark> = New List<Spark>
	Field life#=1
	Field vx#,vy#,van#
	Field size#
		
	Method New(_x#,_y#)
		Local v#=Rnd(1,2)
		size=v/2
		x = _x
		y = _y
		rotation=Rnd(360)
		vx=v*Sin(rotation)
		vy=v*Cos(rotation)
		
		list.AddLast Self
		
	End
	Function updateAll:Void()
		
		If Not list Return
		For Local b:Spark = Eachin list
			b.Update()		
		Next
	End Function
	
	Method Update:Void()

		x += vx
		y += vy
		rotation += van
		
		
		life-=Rnd(.1)
		
		If life<=0
			Die
			Return
		Endif

		red=255*(Min(life,.5)+.5)
		green=255*life
		blue=0
	End
	
	Function drawAll:Void()
		If Not list Return
		For Local b:Spark = Eachin list
			b.Draw()
		Next		
	End Function
	
	Method Draw:Void()
		SetColor red,green,blue
		DrawLine x,y,x-vx,y-vy
	End
	
	Method Die:Void()
		list.Remove Self
	End
End

Class Player Extends Sprite
	Field angVel#
	Field velmul#
	Field vel#
	Field acc#
	Field drag#
	Field xv#,yv#
	Field xa#,ya#
	Field firedel#
	
	Field ship_angvel#
	Field ship_acc#
	Field ship_velmul#
	Field ship_firedel#
	
	Field shield#=100
	
	Method New(x#, y#)
		Self.x = x
		Self.y = y
		ship_angvel = 6
		ship_acc = 0.16
		ship_velmul = -0.0005
		ship_firedel = 4
		shield = 100
	End Method
	
	Method Update:Void()
		
		If KeyDown(KEY_UP)
			acc =  ship_acc
			drag = vel * ship_velmul
			Local tang#=Rnd(-40,40)
			
			'Local s:=New Spark(x-Sgn(acc)*Sin(rotation)*10,y-Sgn(acc)*Cos(rotation)*10)
			Local s:= New Spark(x + (Sin(rotation)*8), y+(Cos(rotation)*8))
			'Local s:=New Spark(x,y)
			Local san#=Rnd(rotation-10,rotation+10)
			s.vx = Sgn(acc)*Sin(san)+xv
			s.vy = Sgn(acc)*Cos(san)+yv
		Else If KeyDown(KEY_DOWN)
			drag = vel * ship_velmul * 50
		Else
			acc = 0
			drag = 0
		End If		
		If KeyDown(KEY_LEFT)
			rotation+=ship_angvel * dt.delta
		End If
		If KeyDown(KEY_RIGHT)
			rotation-=ship_angvel * dt.delta
		End If
		
		If KeyDown(KEY_SPACE) And Self.firedel<=0
			Local tang#=Rnd(-4,4)
			New Bullet(x - (Sin(rotation)*8), y-(Cos(rotation)*8), xv - (Sin(rotation + tang ) *12), yv-(Cos(rotation + tang ) *12), 45, 255-Rnd(4), 192+Rnd(-4,4), 64+Rnd(4,4))
			firedel = ship_firedel
		Endif
		firedel-=dt.delta
		
		xa = (drag * xv) - (Sin(rotation) * acc)
		ya = (drag * yv) - (Cos(rotation) * acc)
		xv = xv + xa *dt.delta
		yv = yv + ya * dt.delta
		x = x + xv * dt.delta
		y = y + yv * dt.delta
		vel = dist(0, 0, xv, yv)
'		
		If x < 0 x = SCREEN_WIDTH
		If x > SCREEN_WIDTH x = 0
		If y < 0 y = SCREEN_HEIGHT
		If y > SCREEN_HEIGHT y = 0
		
		If shield <= 0
			For Local t%=1 To 18
				New Particle( x, y,Rnd(-10,10),Rnd(-10,10),0.95,130,PDM_spark,255,192,64,64)
			Next
			For Local t%=1 To 16
				New Particle( x, y,Rnd(-6,6),Rnd(-6,6),0.95,130,PDM_medparticle,255,192,64,128)
			Next
			For Local t%=1 To 16
				New Particle( x, y,Rnd(-8,8),Rnd(-8,8),0.99,160,PDM_smlparticle,160,160,160,0)
			Next
			For Local t%=1 To 15
				New Particle( x, y,Rnd(-6,6),Rnd(-6,6),0.99,160,PDM_medparticle,160,160,160,0)
			Next
			For Local t%=1 To 14
				New Particle( x, y,Rnd(-4,4),Rnd(-4,4),0.99,160,PDM_bigparticle,160,160,160,0)
			Next
			
			If game.score>game.bestScore
				game.bestScore = game.score
			Endif
			
			game.setState(STATE_GAME_OVER)
		Endif
	End Method

	Method draw:Void()
		Local x1# = x-(Sin(rotation) * 10)
		Local y1# = y-(Cos(rotation) * 10)
		Local x2# = x-(Sin(rotation + 140 ) * 8)
		Local y2# = y-(Cos(rotation + 140 ) * 8)
		Local x3# = x-(Sin(rotation - 140 ) * 8)
		Local y3# = y-(Cos(rotation - 140 ) * 8)
		SetColor 100, 200, 255

			
		SetAlpha 0.04
		LineB x1, y1, x2, y2, 6
		LineB x2, y2, x3, y3, 6
		LineB x3, y3, x1, y1, 6

		SetAlpha 0.01
		LineB x1, y1, x2, y2, 12
		LineB x2, y2, x3, y3, 12
		LineB x3, y3, x1, y1, 12
		
'		SetAlpha 0.1

		SetAlpha 1
		DrawLine x1, y1, x2, y2
		DrawLine x2, y2, x3, y3
		DrawLine x3, y3, x1, y1
		
		Local x% = 20
		Local y% = SCREEN_HEIGHT - 20	
		Local h% = 10
		SetColor 0, 255, 0
		If shield < 50 Then SetColor 255,0,0
		For Local i% = 1 To 3
			SetAlpha 0.1
			DrawRect x - i*2 , y - i*2, Self.shield + i * 4, h + i*4
		Next
		
		SetAlpha 0.8
		DrawRect x, y, Self.shield, h
		SetAlpha 1
		SetColor 255,0,0
	End Method
	
End Class

Function dist#(x1#,y1#,x2#,y2#)
	Return Sqrt(Pow((x1-x2),2) + Pow((y1-y2),2))
End Function

Function limit#(value#,low#,high#)
	If value < low Then Return low
	If value > high Then Return high
	Return value
End Function

Function LineB:Void(x1%, y1%, x2%, y2%, thickness%, rect:Bool = True)
	'Ported
	'Bresenham Line Algorithm 
	'Source - GameDev.Net - Mark Feldman
	'Public Domain
	
	Local deltax% = Abs(x2 - x1)
	Local deltay% = Abs(y2 - y1) 
	
	Local numpixels%,d%,dinc1%,dinc2%,xinc1%,xinc2%,yinc1%,yinc2%,x%,y%,i%
	
	If deltax >= deltay 
		numpixels = deltax + 1
		d = (2 * deltay) - deltax
		dinc1 = deltay Shl 1
		dinc2 = (deltay - deltax) Shl 1
		xinc1 = 1
		xinc2 = 1
		yinc1 = 0
		yinc2 = 1
	Else 
		numpixels = deltay + 1
		d = (2 * deltax) - deltay
		dinc1 = deltax Shl 1
		dinc2 = (deltax - deltay) Shl 1
		xinc1 = 0
		xinc2 = 1
		yinc1 = 1
		yinc2 = 1
	Endif
	
	If x1 > x2
		xinc1 = -xinc1
		xinc2 = -xinc2
	Endif
	
	If y1 > y2 
		yinc1 = -yinc1
		yinc2 = -yinc2
	
	Endif
	
	x = x1
	y = y1
	Local half% = thickness / 2
	For i = 1 To numpixels
		If rect
			DrawRect x - half, y - half, thickness, thickness
		Else
			DrawOval x - half, y- half, thickness, thickness
		Endif
		If d < 0 
			d = d + dinc1
			x = x + xinc1
			y = y + yinc1
		Else
			d = d + dinc2
			x = x + xinc2
			y = y + yinc2
		Endif
	
	Next

End Function

Global SCREEN_WIDTH%
Global SCREEN_HEIGHT%
Global SCREEN_WIDTH2%
Global SCREEN_HEIGHT2%
Global dt:DeltaTimer

Class FrameworkApp Extends App

	Field FPS% = 60
	
	Method OnCreate:Int()
		' Store the device width and height
		SCREEN_WIDTH = DeviceWidth()
		SCREEN_HEIGHT = DeviceHeight()
		SCREEN_WIDTH2 = SCREEN_WIDTH / 2
		SCREEN_HEIGHT2 = SCREEN_HEIGHT / 2
		' Set the Random seed
		Seed = Millisecs()
		' Create the delta timer
		dt = New DeltaTimer(FPS)
		SetUpdateRate FPS
		Return 0
	End Method
	
	Method OnLoading:Int()
		Cls 0,0,0
		DrawText("Loading", SCREEN_WIDTH2, SCREEN_HEIGHT2, 0.5, 0)
		Return 0
	End Method
		
	Method OnRender:Int()
		Return 0
	End Method
	
	Method OnUpdate:Int()
		FPSCounter.update()
		dt.UpdateDelta()
		Return 0
	End Method
End Class

Class FPSCounter Abstract
	Global fpsCount:Int
	Global startTime:Int
	Global totalFPS:Int

	Function update:Void()
		If Millisecs() - startTime >= 1000
			totalFPS = fpsCount
			fpsCount = 0
			startTime = Millisecs()
		Else
			fpsCount+=1
		Endif
	End Function

	Function draw:Void(x% = 0, y% = 0, ax# = 0, ay# = 0)
		DrawText("FPS: " + totalFPS, x, y, ax, ay)
	End Function
		
End Class

' From James Boyd
Class DeltaTimer
	Field targetfps:Float = 60
	Field currentticks:Float
	Field lastticks:Float
	Field frametime:Float
	Field delta:Float
	
	Method New (fps:Float)
		targetfps = fps
		lastticks = Millisecs()
	End
	
	Method UpdateDelta:Void()
		currentticks = Millisecs()
		frametime = currentticks - lastticks
		delta = frametime / (1000.0 / targetfps)
		lastticks = currentticks
	End
End

Class Sprite
	Field x#, y#
	Field dx#, dy#
	Field scaleX# = 1, scaleY# = 1
	Field rotation#, rotationSpeed#
	Field red%, green%, blue%, alpha#
		
	Method move:Void()
		Self.x+=Self.dx * dt.delta
		Self.y+=Self.dy * dt.delta
	End Method
	
	Method moveForward:Void()
		dx = -Sin(rotation) * speed
        dy = -Cos(rotation) * speed

		move()
	End Method
End Class


