#Rem
Copyright (c) 2011 Steve Revill and Shane Woolcock
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#End

Strict

Import mojo
Import diddy.storyboard
Import diddy.externfunctions

Function Main:Int()
	New MyGame()
	Return 0
End

Class MyGame Extends App
	Field lastFrameMillis:Int
	Field thisFrameMillis:Int = -1
	Field deltaMillis:Int
	
	Field sb:Storyboard
	Field scale:Float = 1
	Field seeking:Bool = False
	
	Method OnCreate:Int()
		SetUpdateRate(60)
		sb = Storyboard.LoadXML("storyboard.xml")
		sb.Play()
		Return 0
	End
	
	Method OnRender:Int()
		Cls
		SetAlpha(1)
		SetColor(255,255,255)
		sb.Render(0,0,DeviceWidth()*scale,DeviceHeight()*scale)
		Return 0
	End
	
	Method OnResume:Int()
		lastFrameMillis = Millisecs()
		thisFrameMillis = lastFrameMillis
		deltaMillis = 0
		Return 0
	End
	
	Method OnUpdate:Int()
		' delta time
		If thisFrameMillis < 0 Then thisFrameMillis = Millisecs()
		lastFrameMillis = thisFrameMillis
		thisFrameMillis = Millisecs()
		deltaMillis = thisFrameMillis - lastFrameMillis
		
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
			sb.SeekTo(Int(sb.Length * Float(MouseX())/DeviceWidth()))
		ElseIf seeking Then
			seeking = False
		End
		
		' Use mouse wheel to seek forward and backward one second at a time
		Local mz:Float = MouseZ()
		If mz <> 0 Then
			sb.SeekForward(mz*1000)
		End
		
		' update the storyboard (don't increment the time while seeking - it makes no sense!)
		sb.Update(Not seeking, deltaMillis)
		
		Return 0
	End
End
