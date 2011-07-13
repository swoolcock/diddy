Strict

Import mojo
Import diddy

Global testScreen:InputTestScreen

Function Main:Int()
	game = New InputTestApp
	Return 0
End

Class InputTestApp Extends DiddyApp
	Method OnCreate:Int()
		Super.OnCreate()
		drawFPSOn = True
		testScreen = New InputTestScreen
		testScreen.PreStart()
		Return 0
	End
End

Class InputTestScreen Extends Screen
	Method New()
		name = "Game"
	End
	
	Method Start:Void()
		game.inputCache.MonitorAllKeys()
		game.screenFade.Start(50, false)
	End
	
	Method Render:Void()
		Cls
	End
	
	Method Update:Void()
		For Local event:KeyEvent = EachIn game.inputCache.KeysHit
			' do something for each key hit since the last frame
			Print "KeyHit: key,at="+String.FromChar(event.KeyCode)+","+event.EventTime
		Next
		For Local event:KeyEvent = EachIn game.inputCache.KeysDown
			' do something for each key held down
			'Print "KeyDown: key,at="+String.FromChar(event.KeyCode)+","+event.EventTime
		Next
		For Local event:KeyEvent = EachIn game.inputCache.KeysReleased
			' do something for each key released since the last frame
			Print "KeyReleased: key,at="+String.FromChar(event.KeyCode)+","+event.EventTime
		Next
		
		If game.inputCache.keyHit[KEY_ESCAPE] Then
			game.screenFade.Start(50, true)
			game.nextScreen = game.exitScreen
		End
	End
End
