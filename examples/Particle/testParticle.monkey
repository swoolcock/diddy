#Rem
Copyright (c) 2011 Steve Revill and Shane Woolcock
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#End

Strict

Import diddy

Global testScreen:ParticleTestScreen

Function Main:Int()
	New ParticleTestApp
	Return 0
End

Class ParticleTestApp Extends DiddyApp
	Method Create:Void()
		drawFPSOn = True
		testScreen = New ParticleTestScreen
		Start(testScreen)
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
	Field gravity:Bool = True
	
	Method New()
		name = "Particle System Test"
		speck = LoadImage("speck.png",,Image.MidHandle)
		CreateSystem()
	End
	
	Method Start:Void()
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
		DrawText("Space: toggle emitter, R: toggle rendering, G: toggle gravity",0,20)
		DrawText("Hold Shift: Cursor repels, Hold Control: Cursor attracts",0,35)
		DrawText("Up/Down arrows increase/decrease emit count from 1-100. Current: "+emitCount,0,50)
		DrawText("pg.AliveParticles="+pg.AliveParticles,0,65)
#End
	End
	
	Method Update:Void()
		pf.X = diddyGame.mouseX
		pf.Y = diddyGame.mouseY
		If KeyDown(KEY_CONTROL) Then
			pf.Acceleration = Abs(pf.Acceleration)
			pf.Enabled = True
			f.Enabled = False
		Elseif KeyDown(KEY_SHIFT) Then
			pf.Acceleration = -Abs(pf.Acceleration)
			pf.Enabled = True
			f.Enabled = False
		Else
			pf.Enabled = False
			f.Enabled = gravity
		End
		
		If KeyHit(KEY_SPACE) Then emitting = Not emitting
		If KeyHit(KEY_G) Then gravity = Not gravity
		If KeyHit(KEY_R) Then rendering = Not rendering
		
		If TouchHit() Then
			If TouchY() < SCREEN_HEIGHT2 Then
				emitting = Not emitting
			Else
				rendering = Not rendering
			End
		End
		
		If KeyDown(KEY_UP) Then emitCount+=1
		If KeyDown(KEY_DOWN) Then emitCount-=1
		If emitCount < 1 Then emitCount = 1
		If emitCount > 100 Then emitCount = 100
		
		If emitting Then
			e.EmitAt(emitCount, diddyGame.mouseX, diddyGame.mouseY)
		End
		ps.Update(dt.frametime)
		If KeyHit(KEY_ESCAPE) Then
			FadeToScreen(diddyGame.exitScreen)
		End
	End
	
	Method CreateSystem:Void()
		Local parser:XMLParser = New XMLParser
		Local doc:XMLDocument = parser.ParseFile("psystem.xml")
		ps = New ParticleSystem(doc)
		pg = ps.GetGroup("group1")
		f = ConstantForce(pg.GetForce("gravity"))
		pf = PointForce(pg.GetForce("point"))
		e = ps.GetEmitter("emit1")
		e.ParticleImage = speck
		e2 = ps.GetEmitter("emit2")
	End
End
