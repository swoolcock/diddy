Strict

Import mojo.app
Import mojo.graphics
Import mojo.input
Import monkey.list
Import diddy

Function Main:Int()
	game = New Game()
	Return 0
End Function

Class Game Extends DiddyApp
	Method OnCreate:Int()
		Print( "App::OnCreate" )
		Super.OnCreate()
		Local screen:Screen = New LoadScreen()
		screen.PreStart()
		Return 0
	End
End

Class LoadScreen Extends Screen
	Method New()
		Print( "LoadScreen::New" )
		name = "Load"
	End

	Method Start:Void()
		Print( "LoadScreen::Start" )
	End

	Method Render:Void()
		Print( "LoadScreen::Render" )
	End

	Method Update:Void()
		Print( "LoadScreen::Update" )
	End
End
