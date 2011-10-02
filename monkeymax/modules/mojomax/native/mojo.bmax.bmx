' ***** Start mojo.bmax.bmx ******

Global app:gxtkApp;

Type gxtkApp
	Field ggraphics:gxtkGraphics;

	Field dead:int=0;
	Field suspended:int=0;
	Field vloading:int=0;
	Field maxloading:int=0;
	Field updateRate:int=0;
	Field nextUpdate:Float=0;
	Field updatePeriod:Float=0;
	Field startMillis:Float=0;
	
	Method New()' gxtkApp()
		app=self;
		ggraphics=new gxtkGraphics;
	EndMethod
	
	Method Setup()
		
		'input=new gxtkInput;
		'audio=new gxtkAudio;
		
		startMillis=BlitzMaxMillisecs()
		
		'game.stage.addEventListener( Event.ENTER_FRAME,OnEnterFrame );
		
		SetFrameRate( 0 );
		
		InvokeOnCreate();
		InvokeOnRender();
		Update()
	EndMethod
	
	Method Update()
		While Not AppTerminate()
			local updates:Int = 0
			
			local cont:int = 1
			While (cont)
				nextUpdate:+updatePeriod
				InvokeOnUpdate()
				if not updatePeriod then cont = 0
				if nextUpdate>BlitzMaxMillisecs() then cont = 0
				updates:+1
				if updates = 7 then
					nextUpdate = BlitzMaxMillisecs()
					cont = 0
				endif
			Wend
			InvokeOnRender()
		Wend
	EndMethod
	
	Method InvokeOnCreate()
		if dead return
		dead = 1
		OnCreate()
		dead = 0
	EndMethod

	Method InvokeOnUpdate()
		if dead or suspended or not updateRate or vloading return
		OnUpdate()
	EndMethod
	
	Method InvokeOnRender()
		if dead or suspended return
		ggraphics.BeginRender()
		if vloading
			OnLoading()
		else
			OnRender()
		Endif
		ggraphics.EndRender()
	EndMethod
	
	
	Method SetFrameRate( fps:int )
		if fps
			updatePeriod=1000.0/fps;
			nextUpdate=BlitzMaxMillisecs() +updatePeriod;
		else
			updatePeriod=0
		endif
	EndMethod
	
	' ***** GXTK API *****
	
	Method GraphicsDevice:gxtkGraphics()
		Return ggraphics
	EndMethod
	
	Method SetUpdateRate:int(hertz:int)
		updateRate = hertz
		if not vloading then SetFrameRate(updateRate)
		Return 0
	EndMethod
	
	Method MilliSecs:Int()
		return BlitzMaxMillisecs() - startMillis
	EndMethod
	
	Method Loading:int()
		return vloading;
	EndMethod

	Method OnCreate:int()
		return 0;
	EndMethod

	Method OnUpdate:int()
		return 0;
	EndMethod
	
	Method OnSuspend:int()
		return 0;
	EndMethod
	
	Method OnResume:int()
		return 0;
	EndMethod
	
	Method OnRender:int()
		return 0;
	EndMethod
	
	Method OnLoading:int()
		return 0;
	EndMethod
EndType

Function BlitzMaxMillisecs:Int()
	return MilliSecs()
EndFunction

Function BlitzMaxSetColor(r:Int, g:Int, b:Int)
	SetColor(r, g, b)
EndFunction

Function BlitzMaxSetBlend(blend:Int)
	SetBlend(blend)
EndFunction

Function BlitzMaxSetAlpha(a:Float)
	SetAlpha(a)
EndFunction

Function BlitzMaxCls(r:Int = 0, g:Int = 0, b:Int = 0)
	SetClsColor(r, g, b)
	Cls
EndFunction

Type gxtkGraphics
	
	Method Cls:Int(r:int = 0, g:int = 0, b:int = 0)
		BlitzMaxCls(r, g, b)
		Return 0
	EndMethod
	
	Method LoadSurface:gxtkSurface(path:String)
		local image:TImage = LoadImage("data/"+path)
		if image then
			local gs:gxtkSurface = new gxtkSurface
			gs.setImage(image)
			return gs
		endif
		return null
	EndMethod
	
	Method BeginRender()
	EndMethod
	
	Method EndRender()
		Flip
	EndMethod
	
	Method SetColor:Int(r:Int, g:Int, b:Int)
		BlitzMaxSetColor(r, g, b)
		return 0
	EndMethod
	
	Method SetAlpha:Int(a:Float)
		BlitzMaxSetAlpha(a)
		return 0
	EndMethod
	
	Method SetBlend:Int(blend:Int)
		BlitzMaxSetBlend(blend)
		return 0
	EndMethod
	
	Method Width:Int()
		'TO-DO
		Return 800
	EndMethod
	
	Method Height:Int()
		'TO-DO
		Return 600
	EndMethod
	
	Method SetScissor:Int(x:int, y:int, w:int, h:int)
		Return 0
	EndMethod
	
	Method SetMatrix:Int(x:float,iy:float,jx:float,jy:float,tx:float,ty:float)
		Return 0
	EndMethod
	
	Method DrawSurface:Int(surface:gxtkSurface,x:Float,y:Float)
		DrawImage(surface.image, x, y, 0)
		Return 0
	EndMethod
	
	Method DrawSurface2:Int(surface:gxtkSurface,x:Float,y:Float, srcx:int, srcy:int, srcw:int, srch:int )

	'	Print "x = "+x
	'	Print "y = "+y
	'	Print "srcx = "+srcx
	'	Print "srcy = "+srcy
	'	Print "srcw = "+srcw
	'	Print "srch = "+srch
		DrawSubImageRect(surface.image, x, y, srcw, srch, srcx, srcy, srcw, srch)
		
		Return 0
	EndMethod
EndType

Type gxtkSurface
	Field w:Int, h:Int
	Field image:TImage
	
	Method setImage(image:TImage)
		self.image = image
	EndMethod
	
	Method Width:Int()
		return image.Width
	EndMethod
	
	Method Height:Int()
		return image.Height
	EndMethod
EndType

' ***** End mojo.bmax.bmx ******

