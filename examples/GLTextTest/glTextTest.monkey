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
	Field font18:GLText
	Field font10:GLText
	
	Method OnCreate:Int()
		font18 = GLText.GetNewInstance()
		font18.Load("Roboto-Regular.ttf", 18, 2, 2)
		
		font10 = GLText.GetNewInstance()
		font10.Load("Roboto-Regular.ttf", 10, 2, 2)
		
		SetUpdateRate(60)
		Return True
	End
	
	Method OnUpdate:Int()
		Return True
	End

	Method OnRender:Int()
		Cls(10, 100, 100)
		
		Rotate 0
		SetColor 255, 255, 255
		DrawText("Testing...", 10, 10)
		Local date:Int[] = GetDate();
		font18.Draw("Hello World! " + date[6], 10, 30)
		font10.Draw("Hello World! " + date[6], 10, 60)
		
		Rotate 45
		SetColor 255, 0, 0
		font18.Draw("Hello World Again! " + date[6], 10, 90)
		
		Return True
	End

End