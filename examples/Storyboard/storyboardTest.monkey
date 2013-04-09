#Rem
Copyright (c) 2011 Steve Revill and Shane Woolcock
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#End

Strict

Import diddy
Import diddy.storyboard

Function Main:Int()
	New MyGame()
	Return 0
End

Global gameScreen:GameScreen

Class MyGame Extends DiddyApp

	Method Create:Void()
		'SetGraphics(1280,960)
		'SetScreenSize(640,480)
		LoadImages()
		
		gameScreen = New GameScreen
		Start(gameScreen)
	End
	
	'***********************
	'* Load Images
	'***********************
	Method LoadImages:Void()
		images.Load("bar.png")
		images.Load("bg.jpg")
		images.Load("black.png")
		images.Load("bmbs.png")
		images.Load("clouds.png")
		images.Load("layer1.png")
		images.Load("layer2.png")
		images.Load("layer3.png")
		images.Load("loadoverlay.png")
		images.Load("LSB.png")
		images.Load("nebula.png")
		images.Load("nebula2.png")
		images.Load("planet.png")
		images.Load("SBB.png")
		images.Load("sun.png")
		images.Load("white.png")
		images.Load("X.png")
		sounds.Load("soft-hitwhistle.wav")
	End
End


Class GameScreen Extends Screen
	Field sb:Storyboard
	Field scale:Float = 1
	Field seeking:Bool = False
	
	Method New()
		name = "Storyboard Test"
	End
	
	Method Start:Void()
		sb = Storyboard.LoadXML("storyboard.xml")
		sb.Play()
	End
	
	Method Render:Void()
		Cls
		SetAlpha(1)
		SetColor(255,255,255)
		sb.Render(0,0,SCREEN_WIDTH*scale,SCREEN_HEIGHT*scale)
	End

	Method Update:Void()
		' Hit R to reload the storyboard
		If KeyHit(KEY_R) Then sb = Storyboard.LoadXML("storyboard.xml")
		
		' Hit space to play/pause
		If KeyHit(KEY_SPACE) Then sb.PlayPause()
		
		' Hit Z to show debug info
		If KeyHit(KEY_Z) Then sb.DebugMode = Not sb.DebugMode
		
		' Hit escape to quit
		If KeyHit(KEY_ESCAPE) Then Error ""
		
		' Hold up/down to change the scale
		If KeyDown(KEY_UP) Then scale+=0.01
		If KeyDown(KEY_DOWN) Then scale-=0.01
		
		' Hit left/right to change the playback speed
		If KeyHit(KEY_LEFT) Then
			sb.PlaySpeed -= 1
			If sb.PlaySpeed = 0 Then sb.PlaySpeed = -1
		End
		If KeyHit(KEY_RIGHT) Then
			sb.PlaySpeed += 1
			If sb.PlaySpeed = 0 Then sb.PlaySpeed = 1
		End
		
		' Hit enter to reset the scale and speed
		If KeyHit(KEY_ENTER) Then
			scale=1
			sb.Stop()
			sb.PlaySpeed = 1
		End
		
		' clamp scale from 0.1 to 3
		If scale < 0.1 Then scale = 0.1
		If scale > 3 Then scale = 3
		
		' left click to move the position (doesn't line up perfectly with the slider, for now)
		If MouseDown(0) Then
			If MouseHit() Then seeking = True
			sb.SeekTo(Int(sb.Length * Float(MouseX())/DEVICE_WIDTH))
		ElseIf seeking Then
			seeking = False
		End
		
		' Use mouse wheel to seek forward and backward one second at a time
		Local mz:Float = MouseZ()
		If mz <> 0 Then
			sb.SeekForward(mz*1000)
		End
		
		' update the storyboard (don't increment the time while seeking - it makes no sense!)
		sb.Update(Not seeking)
	End
End