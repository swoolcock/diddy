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
	Field rotation:Int
	
	Method OnCreate:Int()
		font20 = GLText.GetNewInstance()
		font20.Load("Roboto-Regular.ttf", 18, 2, 2)
		
		font10 = GLText.GetNewInstance()
		font10.Load("Roboto-Regular.ttf", 10, 2, 2)
		
		SetUpdateRate(60)
		Return True
	End
	
	Method OnUpdate:Int()
		rotation += 5
		Return True
	End

	Method OnRender:Int()
		Cls(10, 100, 100)
		
		Local date:Int[] = GetDate();
		
		PushMatrix
			Translate 100, 100
			Rotate rotation
			SetColor 255, 255, 255		
			font20.Draw("Hello Font20! " + date[6], 10, 30)
			font10.Draw("Hello font10! " + date[6], 10, 60)
		PopMatrix
		
		PushMatrix
			Rotate 0
			SetColor 255, 0, 0
			font20.Draw("Hello Font20 Again! " + date[5], 10, 90)
			font10.Draw("Hello font10 Again! " + date[5], 10, 120)
		PopMatrix
		
		Return True
	End

End