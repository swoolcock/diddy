' ***** Start mojo.bmax.bmx ******

Global app:gxtkApp;

Type gxtkApp
	Field ginput:gxtkInput;
	Field gaudio:gxtkAudio;
	Field ggraphics:gxtkGraphics;

	Field dead:Int=0;
	Field suspended:Int=0;
	Field vloading:Int=0;
	Field maxloading:Int=0;
	Field updateRate:Int=0;
	Field nextUpdate:Float=0;
	Field updatePeriod:Float=0;
	Field startMillis:Float=0;
	
	Method New()' gxtkApp()
		app=Self;
		ggraphics=New gxtkGraphics;
	EndMethod
	
	Method Setup()
		ginput=New gxtkInput;
		gaudio=New gxtkAudio;

		bb_input_SetInputDevice(ginput);
		bb_audio_SetAudioDevice(gaudio);
		
		startMillis=BlitzMaxMillisecs()
		
		SetFrameRate( 0 );
		
		InvokeOnCreate();
		InvokeOnRender();
		Update()
	EndMethod
	
	Method Update()
		While Not AppTerminate()
			Local updates:Int = 0
			
			Local cont:Int = 1
			While (cont)
				nextUpdate:+updatePeriod
				InvokeOnUpdate()
				If Not updatePeriod Then cont = 0
				If nextUpdate>BlitzMaxMillisecs() Then cont = 0
				updates:+1
				If updates = 7 Then
					nextUpdate = BlitzMaxMillisecs()
					cont = 0
				EndIf
			Wend
			InvokeOnRender()
		Wend
	EndMethod
	
	Method InvokeOnCreate()
		If dead Return
		dead = 1
		OnCreate()
		dead = 0
	EndMethod

	Method InvokeOnUpdate()
		If dead Or suspended Or Not updateRate Or vloading Return
		OnUpdate()
	EndMethod
	
	Method InvokeOnRender()
		If dead Or suspended Return
		ggraphics.BeginRender()
		If vloading
			OnLoading()
		Else
			OnRender()
		EndIf
		ggraphics.EndRender()
	EndMethod
	
	
	Method SetFrameRate( fps:Int )
		If fps
			updatePeriod=1000.0/fps;
			nextUpdate=BlitzMaxMillisecs() +updatePeriod;
		Else
			updatePeriod=0
		EndIf
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

	Method SetUpdateRate:Int(hertz:Int)
		updateRate = hertz
		If Not vloading Then SetFrameRate(updateRate)
		Return 0
	EndMethod
	
	Method MilliSecs:Int()
		Return BlitzMaxMillisecs() - startMillis
	EndMethod
	
	Method Loading:Int()
		Return vloading;
	EndMethod

	Method OnCreate:Int()
		Return 0;
	EndMethod

	Method OnUpdate:Int()
		Return 0;
	EndMethod
	
	Method OnSuspend:Int()
		Return 0;
	EndMethod
	
	Method OnResume:Int()
		Return 0;
	EndMethod
	
	Method OnRender:Int()
		Return 0;
	EndMethod
	
	Method OnLoading:Int()
		Return 0;
	EndMethod
EndType

Type gxtkGraphics
	Field gmode:Int = 1

	Method Mode:Int()
		Return gmode
	EndMethod
	
	Method Cls:Int(r:Int = 0, g:Int = 0, b:Int = 0)
		BlitzMaxCls(r, g, b)
		Return 0
	EndMethod
	
	Method LoadSurface:gxtkSurface(path:String)
		Local image:TImage = LoadImage("data/"+path)
		If image Then
			Local gs:gxtkSurface = New gxtkSurface
			gs.setImage(image)
			Return gs
		EndIf
		Return Null
	EndMethod
	
	Method BeginRender()
	EndMethod
	
	Method EndRender()
		Flip
	EndMethod
	
	Method SetColor:Int(r:Int, g:Int, b:Int)
		BlitzMaxSetColor(r, g, b)
		Return 0
	EndMethod
	
	Method SetAlpha:Int(a:Float)
		BlitzMaxSetAlpha(a)
		Return 0
	EndMethod
	
	Method SetBlend:Int(blend:Int)
		BlitzMaxSetBlend(blend)
		Return 0
	EndMethod
	
	Method Width:Int()
		'TO-DO
		Return 800
	EndMethod
	
	Method Height:Int()
		'TO-DO
		Return 480
	EndMethod
	
	Method SetScissor:Int(x:Int, y:Int, w:Int, h:Int)
		Return 0
	EndMethod

	Method SetMatrix:Int(ix:Float,iy:Float,jx:Float,jy:Float,tx:Float,ty:Float)
'		Local sx:Float = Sqr( (ix*ix) + (jx*jx) )
'		Local sy:Float = Sqr( (iy*iy) + (jy*jy) )
'		Local rot:Float = Atan2( jx, ix )
'		SetTransform( rot, sx, sy )
		SetTransform( 0, ix, jy )
		SetOrigin( tx, ty )
		Return 0
	EndMethod
	
	Method DrawSurface:Int(surface:gxtkSurface,x:Float,y:Float)
		DrawImage(surface.image, x, y, 0)
		Return 0
	EndMethod
	
	Method DrawSurface2:Int(surface:gxtkSurface,x:Float,y:Float, srcx:Int, srcy:Int, srcw:Int, srch:Int )
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
		Return BRL.PolledInput.MouseX()
	EndMethod

	Method MouseY:Float()
		Return BRL.PolledInput.MouseY()
	EndMethod
	
	Method KeyDown:Int( key:Int )
		If( key >= 1 And key <= 3 )
			Return BRL.PolledInput.MouseDown( key )
		EndIf
		Return BRL.PolledInput.KeyDown( key )
	EndMethod

	Method KeyHit:Int( key:Int )
		If( key >= 1 And key <= 3 )
			Return BRL.PolledInput.MouseHit( key )
		EndIf
		Return BRL.PolledInput.KeyHit( key )
	EndMethod

	Method GetChar:Int()
		Return BRL.PolledInput.GetChar()
	EndMethod

	Method JoyX:Int( index:Int )
		Return Pub.FreeJoy.JoyX( index )
	EndMethod

	Method JoyY:Int( index:Int )
		Return Pub.FreeJoy.JoyY( index )
	EndMethod

	Method JoyZ:Int( index:Int )
		Return Pub.FreeJoy.JoyZ( index )
	EndMethod

	Method TouchX:Float( index:Int )
		Return 0
	EndMethod

	Method TouchY:Float( index:Int )
		Return 0
	EndMethod
EndType

Type gxtkAudio
	Field amusicState:Int = 0;

	Method MusicState:Int()
'		If( musicState = 1 And music.isPlaying() = False )
'			musicState = 0;
'		Endif
		Return amusicState;
	EndMethod
	
	Method PlayMusic:Int( path:String, flags:Int )
		Return 0
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
	Return MilliSecs()
EndFunction

Function BlitzMaxSetColor(r:Int, g:Int, b:Int)
	SetColor(r, g, b)
EndFunction

Function BlitzMaxSetBlend(blend:Int)
	Select blend
		Case 0
			SetBlend( ALPHABLEND )
		Case 1
			SetBlend( LIGHTBLEND )
	End Select
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
		Self.image = image
	EndMethod
	
	Method Width:Int()
		Return image.Width
	EndMethod
	
	Method Height:Int()
		Return image.Height
	EndMethod
	
	Method Discard()
	EndMethod
EndType

' ***** End mojo.bmax.bmx ******

