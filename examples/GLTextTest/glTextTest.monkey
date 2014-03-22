#Rem
Copyright (c) 2011 Steve Revill and Shane Woolcock
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#End

Strict
#TEXT_FILES+="*.ttf"
#ANDROID_APP_LABEL="Diddy GLText Test"
#ANDROID_APP_PACKAGE="com.therevillsgames.gltexttest"

Import mojo
Import diddy.gltext

Function Main:Int()
	New MyApp()
	Return True
End

Class MyApp Extends App
	Field font20:GLText
	Field font10:GLText
	Field scoreText:GLText
	Field lotsOfText:GLText
	
	Field rotation:Int
	
	Method OnCreate:Int()
		font20 = GLText.GetNewInstance()
		font20.Load("Roboto-Regular.ttf", 20, 2, 2)
		
		font10 = GLText.GetNewInstance()
		font10.Load("Roboto-Regular.ttf", 10, 2, 2)

		scoreText = GLText.GetNewInstance()
		scoreText.CreateText("Roboto-Regular.ttf", "SCORE:", 30)

		lotsOfText = GLText.GetNewInstance()
		lotsOfText.CreateText("Roboto-Regular.ttf", "This is a lot of text just to test that GLText can handle the size! This is a lot of text just to test that GLText can handle the size!", 10)
		
		SetUpdateRate(60)
		Return True
	End
	
	Method OnUpdate:Int()
		rotation += 1
		Return True
	End

	Method OnRender:Int()
		Cls
		
		Local date:Int[] = GetDate();
		
		PushMatrix
			Translate 100, 100
			Rotate rotation
			SetColor 255, 255, 255		
			font20.Draw("Hello Font20! " + date[6], 10, 30)
			font10.Draw("Hello font10! " + date[6], 10, 60)
			
			scoreText.DrawTexture(10, 100)
		PopMatrix
		
		PushMatrix
			Rotate 0
			SetColor 255, 0, 0
			font20.Draw("Hello Font20 Again! " + date[5], 10, 90)
			font10.Draw("Hello font10 Again! " + date[5], 10, 120)
			scoreText.DrawTexture(10, 140)
			SetColor 255, 255, 255
			lotsOfText.DrawTexture(10, 280)
		PopMatrix
		
		Return True
	End

End