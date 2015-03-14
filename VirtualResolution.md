Diddy now has support for Virtual Resolutions.

To use, all you need to do is set the screen size in the OnCreate method:

```
Class MyGame Extends DiddyApp
 	Method OnCreate:Int()
 		Super.OnCreate() 
		SetScreenSize(480, 320)
```

Now any screen rendering will be displayed in the virtual resolution. If you want any extra rendering which is not affected by the virtual resolution there is a method called ExtraRender:

```
Class GameScreen Extends Screen
	Method Render:Void()
 		Cls
 		backgroundImg.Draw(0, 0)
 	End

	Method ExtraRender:Void()
		DrawText "This part of the render isnt affected by the virtual resolution!", 0, 0
 	End
```


If you dont set the screen size, the framework will set it to the device size.