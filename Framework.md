To use the Diddy Framework your file needs to have the following template:

```
Strict

Import diddy

Function Main:Int()
	New MyGame()
	Return 0
End

Class MyGame Extends DiddyApp

End
```

Here is a small example which uses the Screen class:

```
Strict

Import diddy

Global titleScreen:TitleScreen

Function Main:Int()
	New MyGame()
	Return 0
End

Class MyGame Extends DiddyApp
	Method Create:Void()
		titleScreen = New TitleScreen
		Start(titleScreen)
	End
End

Class TitleScreen Extends Screen
	Method New()
		name = "Title"
	End
	
	Method Start:Void()
	End
	
	Method Render:Void()
		Cls
		DrawText "TITLE SCREEN!", SCREEN_WIDTH2, SCREEN_HEIGHT2, 0.5, 0.5
		DrawText "Click to Play!", SCREEN_WIDTH2, SCREEN_HEIGHT2 + 20, 0.5, 0.5
		DrawText "Escape to Quit!", SCREEN_WIDTH2, SCREEN_HEIGHT2 + 40, 0.5, 0.5
	End
	
	Method Update:Void()
		If KeyHit(KEY_ESCAPE)
			FadeToScreen(game.exitScreen)
		End
	End
End
```