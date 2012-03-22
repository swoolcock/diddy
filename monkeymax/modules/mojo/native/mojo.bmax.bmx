' ***** Start mojo.bmax.bmx ******

Global app:gxtkApp;

Type gxtkApp
	Field ginput:gxtkInput;
	Field gaudio:gxtkAudio;
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
		
		ginput=new gxtkInput;
		gaudio=new gxtkAudio;

		bb_input_SetInputDevice(ginput);
		bb_audio_SetAudioDevice(gaudio);
		
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
	
	Method LoadString:String( path:String )
		path = "data/" + path;
		Return LoadText( path )
	EndMethod
	
	' ***** GXTK API *****
	
	Method GraphicsDevice:gxtkGraphics()
		Return ggraphics
	EndMethod

	Method InputDevice:gxtkInput()
		Return ginput
	EndMethod

	Method AudioDevice:gxtkAudio()
		Return gaudio
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

Type gxtkGraphics
	Field gmode:Int = 1

	Method Mode:Int()
		return gmode
	EndMethod
	
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
	
	Method DrawLine:Int( x1:Float,y1:Float,x2:Float,y2:Float )
		BlitzMaxDrawLine(x1, y1, x2, y2)
		Return 0
	EndMethod
	
	Method DrawOval:Int( x:Float, y:Float, w:Float, h:Float )
		BlitzMaxDrawOval(x, y, w, h)
		Return 0
	EndMethod
	
	Method DrawPoly:Int(vertices:Float[])
		BlitzMaxDrawPoly( vertices )
		Return 0
	EndMethod
	
	Method DrawRect:Int( x:Float, y:Float, w:Float, h:Float )
		BlitzMaxDrawRect(x, y, w, h)
		Return 0
	EndMethod
EndType

Type gxtkInput
	Method MouseX:Float()
		return 0
	EndMethod

	Method MouseY:Float()
		return 0
	EndMethod
	
	Method KeyDown:Int( key:Int )
		return BRL.PolledInput.KeyDown( key )
	EndMethod

	Method KeyHit:Int( key:Int )
		return BRL.PolledInput.KeyHit( key )
	EndMethod

	Method GetChar:Int()
		return BRL.PolledInput.GetChar()
	EndMethod

	Method JoyX:Int( index:Int )
		return Pub.FreeJoy.JoyX( index )
	EndMethod

	Method JoyY:Int( index:Int )
		return Pub.FreeJoy.JoyY( index )
	EndMethod

	Method JoyZ:Int( index:Int )
		return Pub.FreeJoy.JoyZ( index )
	EndMethod

	Method TouchX:Float( index:Int )
		return 0
	EndMethod

	Method TouchY:Float( index:Int )
		return 0
	EndMethod
EndType

Type gxtkAudio
	Field amusicState:Int = 0;

	Method MusicState:Int()
'		If( musicState = 1 And music.isPlaying() = False )
'			musicState = 0;
'		Endif
		return amusicState;
	EndMethod
	
	Method PlayMusic:Int( path:String, flags:int )
		return 0
	EndMethod
	
	Method StopMusic()
	EndMethod
	
	Method StopChannel( channel:Int )
	EndMethod

	Method PlaySample( sound:gxtkSample, channel:Int, flags:Int )
	EndMethod

	Method SetPan( channel:Int, pan:Float )
	EndMethod

	Method SetRate( channel:Int, rate:Float )
	EndMethod

	Method SetMusicVolume:Int( volume:Float )
		Return 0
	EndMethod

	Method SetVolume:Int( channel:Int, volume:Float )
		Return 0
	EndMethod
	
	Method LoadSample:gxtkSample( path:String )
		Return Null
	EndMethod
EndType

Type gxtkSample
	Method Discard()
	EndMethod
EndType

Function BlitzMaxDrawPoly:Int(vertices:Float[])
	DrawPoly vertices
	Return 0
EndFunction

Function BlitzMaxDrawRect:Int( x:Float, y:Float, w:Float, h:Float )
	DrawRect x, y, w, h
	Return 0
EndFunction

Function BlitzMaxDrawOval:Int( x:Float, y:Float, w:Float, h:Float )
	DrawOval x, y, w, h
	Return 0
EndFunction

Function BlitzMaxDrawLine:Int( x1:Float,y1:Float,x2:Float,y2:Float )
	DrawLine x1, y1, x2, y2
	Return 0
EndFunction

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
	
	Method Discard()
	EndMethod
EndType

' ***** End mojo.bmax.bmx ******

