Strict

Import mojo
Import diddy

Function Main:Int()
	New MyApp
	Return 0
End

Class MyApp Extends App
	Method OnCreate:Int()
		SetUpdateRate(60)
		LoadI18N()
		Return 0
	End
	
	Method OnUpdate:Int()
		If KeyHit(KEY_1) Then
			SetI18N("french")
			Print("Changed language to French")
			Print(I18N("Hello World!"))
			Print(I18N("Goodbye World!"))
		ElseIf KeyHit(KEY_2) Then
			SetI18N("japanese")
			Print("Changed language to Japanese")
			Print(I18N("Hello World!"))
			Print(I18N("Goodbye World!"))
		ElseIf KeyHit(KEY_3) Then
			Print("Reset language to default")
			ClearI18N()
		End
		Return 0
	End
	
	Method OnRender:Int()
		Cls
		DrawText("1: Load French", 5, 5)
		DrawText("2: Load Japanese", 5, 20)
		DrawText("3: Reset i18n", 5, 35)
		DrawText(I18N("Hello World!"), 5, 60)
		DrawText(I18N("Goodbye World!"), 5, 75)
		Return 0
	End
End