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
	Field speck:Image
	
	Field emitting:Bool
	Field rendering:Bool = True
	
	Method New()
		name = "Particle System Test"
		speck = LoadImage("speck.png",,Image.MidHandle)
		CreateSystem()
	End
	
	Method Start:Void()
		game.screenFade.Start(50, false)
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
		DrawText("Tap top half to toggle emitter, bottom half to toggle rendering",0,30)
#Else
		DrawText("Space: toggle emitter, R: toggle rendering",0,30)
#End
		DrawText("pg.AliveParticles="+pg.AliveParticles,0,50)
	End
	
	Method Update:Void()
		If KeyHit(KEY_SPACE) Then emitting = Not emitting
		If KeyHit(KEY_R) Then rendering = Not rendering
		
		If TouchHit() Then
			If TouchY() < SCREEN_HEIGHT2 Then
				emitting = Not emitting
			Else
				rendering = Not rendering
			End
		End
		If emitting Then
			e.EmitAt(3, SCREEN_WIDTH2, SCREEN_HEIGHT2+50)
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
		
		f = New ConstantForce(0,-150) ' constant downward force of 150 pixels per second per second
		pg.Forces.Add(f)
		
		e = New Emitter
		e.SetParticleRGBInterpolated(255,0,0,0,255,0) ' fade from red to green
		e.Life = 3 ' lives for 3 seconds
		e.SetPolarVelocity(PI/2, PI/3, 250, 50) ' points up with a spread of 60 degrees
		e.AlphaInterpolationTime = 0.5 ' will start fading out when there is half a second of life left
		e.ParticleImage = speck
		e.Group = pg
		
		e2 = New Emitter
		e2.Life = 2 ' lives for 2 seconds
		e2.AlphaInterpolationTime = 0.5 ' will start fading out when there is half a second of life left
		e2.SetPolarVelocity(0,2*PI,50,10) ' points right with a spread of 360 degrees (a full circle)
		e2.SetParticleRGBInterpolated(0,255,255,0,255,0) ' fade from cyan to green
		e.AddDeathEmitter(e2, 0.05) ' 5% chance to fire off this emitter when a particle from other emitter dies
	End
End
