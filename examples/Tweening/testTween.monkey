#Rem
Copyright (c) 2011 Steve Revill and Shane Woolcock
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#End

Strict

Import diddy

Const TWEEN_X% = 10
Const TWEEN_Y% = 10
Const TWEEN_WIDTH% = 200
Const TWEEN_HEIGHT% = 30
Const TWEEN_GAP% = 30

Function Main:Int()
	New MyApp
	Return 0
End

Class MyApp Extends App
	Field lastTime:Int = -1
	Field thisTime:Int = -1
	Field deltaTime:Int = -1
	Field linearTween:Tween
	Field bounceTween:Tween
	Field sineTween:Tween
	Field chainTween:Tween
	
	Method OnCreate:Int()
		Tween.CacheTweens()
		SetUpdateRate(60)
		linearTween = Tween.CreateLinear(1000, TWEEN_X, TWEEN_X+TWEEN_WIDTH, TWEEN_X)
		bounceTween = Tween.CreateBounce(1500, TWEEN_X+TWEEN_WIDTH, TWEEN_X, TWEEN_X+TWEEN_WIDTH)
		sineTween = Tween.CreateSine(3000,TWEEN_X+(TWEEN_WIDTH/2),0,TWEEN_WIDTH/2)
		chainTween = Tween.CreateLinear(2000,TWEEN_X,TWEEN_X+TWEEN_WIDTH,TWEEN_X)
		chainTween.AddChain(Tween.CreateBounce(1000,TWEEN_X+TWEEN_WIDTH,TWEEN_X,TWEEN_X+TWEEN_WIDTH))
		chainTween.AddChain(Tween.CreateSine(4000,TWEEN_X+(TWEEN_WIDTH/2),0.25,TWEEN_WIDTH/2,2.0/3.0))
		Return 0
	End
	
	Method OnUpdate:Int()
		lastTime = thisTime
		thisTime = Millisecs()
		If lastTime < 0 Then lastTime = thisTime
		deltaTime = thisTime - lastTime
		
		Tween.UpdateAll(deltaTime)
		
		Return 0
	End
	
	Method OnRender:Int()
		Cls(0,0,0)
		
		SetColor(255,255,255)
		
		local y:Int = TWEEN_Y
		DrawLine(linearTween.value, y, linearTween.value, y+TWEEN_HEIGHT)
		PrintTweenState(linearTween, TWEEN_X + TWEEN_WIDTH + 10, y)
		
		y += TWEEN_HEIGHT+TWEEN_GAP
		DrawLine(bounceTween.value, y, bounceTween.value, y+TWEEN_HEIGHT)
		PrintTweenState(bounceTween, TWEEN_X + TWEEN_WIDTH + 10, y)
				
		y += TWEEN_HEIGHT+TWEEN_GAP
		DrawLine(sineTween.value, y, sineTween.value, y+TWEEN_HEIGHT)
		PrintTweenState(sineTween, TWEEN_X + TWEEN_WIDTH + 10, y)
				
		y += TWEEN_HEIGHT+TWEEN_GAP
		DrawLine(chainTween.value, y, chainTween.value, y+TWEEN_HEIGHT)
		PrintTweenState(chainTween, TWEEN_X + TWEEN_WIDTH + 10, y)
		
		SetColor(255,0,0)
		
		y = TWEEN_Y
		DrawLine(linearTween.linearStart,y,linearTween.linearStart,y+TWEEN_HEIGHT)
		DrawLine(linearTween.linearEnd,y,linearTween.linearEnd,y+TWEEN_HEIGHT)
		
		y += TWEEN_HEIGHT+TWEEN_GAP
		DrawLine(bounceTween.bounceStart,y,bounceTween.bounceStart,y+TWEEN_HEIGHT)
		DrawLine(bounceTween.bounceEnd,y,bounceTween.bounceEnd,y+TWEEN_HEIGHT)
		
		y += TWEEN_HEIGHT+TWEEN_GAP
		DrawLine(sineTween.waveOffset-sineTween.waveAmplitude,y,sineTween.waveOffset-sineTween.waveAmplitude,y+TWEEN_HEIGHT)
		DrawLine(sineTween.waveOffset+sineTween.waveAmplitude,y,sineTween.waveOffset+sineTween.waveAmplitude,y+TWEEN_HEIGHT)
		
		y += TWEEN_HEIGHT+TWEEN_GAP
		DrawLine(chainTween.linearStart,y,linearTween.linearStart,y+TWEEN_HEIGHT)
		DrawLine(chainTween.linearEnd,y,linearTween.linearEnd,y+TWEEN_HEIGHT)
		
		Return 0
	End
	
	Method PrintTweenState:Void(twn:Tween, x%, y%)
		Local t:Tween = twn
		If twn.chainFirst >= 0 Then twn = Tween.tweens[twn.chainActive]
		Select twn.type
			Case Tween.TWEEN_TYPE_LINEAR
				DrawText("Linear: len="+twn.length+", start="+twn.linearStart+", end="+twn.linearEnd+
						", initial="+twn.linearInitial, x, y)

			Case Tween.TWEEN_TYPE_BOUNCE
				DrawText("Bounce: len="+twn.length+", start="+twn.bounceStart+", end="+twn.bounceEnd+
						", initial="+twn.bounceInitial, x, y)

			Case Tween.TWEEN_TYPE_SINE
				DrawText("Sine: len="+twn.length+", off="+twn.waveOffset+", phase="+twn.wavePhase+
						", amp="+twn.waveAmplitude+", wavelen="+twn.waveLength, x, y)
		End
		If twn.chainFirst < 0 Then
			DrawText("Value: "+Int(t.value), x, y+15)
		Else
			DrawText("Value: "+Int(t.value)+", first="+twn.chainFirst+", prev="+twn.chainPrevious+", next="+twn.chainNext+
					", last="+twn.chainLast+", active="+twn.chainActive, x, y+15)
		End
	End
End







