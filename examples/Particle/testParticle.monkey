Strict

Import mojo
Import diddy

Global testScreen:ParticleTestScreen

Function Main:Int()
	game = New ParticleTestApp
	Return 0
End

Class ParticleTestApp Extends DiddyApp
	Method OnCreate:Int()
		Super.OnCreate()
		drawFPSOn = True
		testScreen = New ParticleTestScreen
		testScreen.PreStart()
		Return 0
	End
End

Class ParticleTestScreen Extends Screen
	Field ps:ParticleSystem
	Field pg:ParticleGroup
	Field e:Emitter
	Field e2:Emitter
	Field f:Force
	Field pf:PointForce
	Field speck:Image
	
	Field emitting:Bool = True
	Field emitCount:Int = 3
	Field rendering:Bool = True
	
	Method New()
		name = "Particle System Test"
		speck = LoadImage("speck.png",,Image.MidHandle)
		CreateSystem()
	End
	
	Method Start:Void()
		game.screenFade.Start(50, False)
	End
	
	Method Render:Void()
		Cls
		If rendering Then ps.Render()
		SetColor(255,255,255)
	End
	
	Method DebugRender:Void()
		SetColor(255,255,255)
		SetAlpha(1)
#If TARGET="android" Or TARGET="ios" Then
		DrawText("Tap top half to toggle emitter, bottom half to toggle rendering",0,20)
		DrawText("pg.AliveParticles="+pg.AliveParticles,0,35)
#Else
		DrawText("Space: toggle emitter, R: toggle rendering",0,20)
		DrawText("Hold Shift: Cursor repels, Hold Control: Cursor attracts",0,35)
		DrawText("Up/Down arrows increase/decrease emit count from 1-20. Current: "+emitCount,0,50)
		DrawText("pg.AliveParticles="+pg.AliveParticles,0,65)
#End
	End
	
	Method Update:Void()
		pf.X = game.mouseX
		pf.Y = game.mouseY
		If KeyDown(KEY_CONTROL) Then
			pf.Acceleration = 300
			pf.Enabled = True
			f.Enabled = False
		Elseif KeyDown(KEY_SHIFT) Then
			pf.Acceleration = -300
			pf.Enabled = True
			f.Enabled = False
		Else
			pf.Enabled = False
			f.Enabled = True
		End
	
		If KeyHit(KEY_SPACE) Then emitting = Not emitting
		If KeyHit(KEY_R) Then rendering = Not rendering
		
		If TouchHit() Then
			If TouchY() < SCREEN_HEIGHT2 Then
				emitting = Not emitting
			Else
				rendering = Not rendering
			End
		End
		
		If KeyHit(KEY_UP) Then emitCount+=1
		If KeyHit(KEY_DOWN) Then emitCount-=1
		If emitCount < 1 Then emitCount = 1
		If emitCount > 20 Then emitCount = 20
		
		If emitting Then
			e.EmitAt(emitCount, game.mouseX, game.mouseY)
		End
		ps.Update(dt.frametime)
		If KeyHit(KEY_ESCAPE) Then
			game.screenFade.Start(50, True)
			game.nextScreen = game.exitScreen
		End
	End
	
	Method CreateSystem:Void()
		ps = New ParticleSystem()
		
		pg = New ParticleGroup(5000) ' group of 5000 particles
		ps.Groups.Add(pg)
		
		f = New ConstantForce(0,150) ' constant downward force of 150 pixels per second per second
		pg.Forces.Add(f)
		pf = New PointForce(0, 0, 0)
		pg.Forces.Add(pf)
		
		e = New Emitter
		e.SetParticleRGBInterpolated(255,0,0,0,255,0) ' fade from red to green
		e.Life = 3 ' lives for 3 seconds
		e.SetPolarVelocity(-90, 60, 250, 50) ' points up with a spread of 60 degrees
		e.AlphaInterpolationTime = 0.5 ' will start fading out when there is half a second of life left
		e.ParticleImage = speck
		e.SetParticleScale(1.5,2)
		e.Group = pg
		
		e2 = New Emitter
		e2.Life = 3 ' lives for 3 seconds
		e2.AlphaInterpolationTime = 0.5 ' will start fading out when there is half a second of life left
		e2.SetPolarVelocity(0,360,50,10) ' points right with a spread of 360 degrees (a full circle)
		e2.SetParticleRGBInterpolated(0,255,255,0,255,0) ' fade from cyan to green
		e2.SetParticleScale(2,2)
		e2.SetParticleRotation(0, 22.5, 0, 90)
		e.AddDeathEmitter(e2, 0.05) ' 5% chance to fire off this emitter when a particle from other emitter dies
	End
End
