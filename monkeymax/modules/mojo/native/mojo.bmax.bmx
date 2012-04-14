' ***** Start mojo.bmax.bmx ******

Global app:gxtkApp

Type gxtkApp
	Field ginput:gxtkInput
	Field gaudio:gxtkAudio
	Field ggraphics:gxtkGraphics

	Field dead:Int=0
	Field suspended:Int=0
	Field vloading:Int=0
	Field maxloading:Int=0
	Field updateRate:Int=0
	Field nextUpdate:Float=0
	Field updatePeriod:Float=0
	Field startMillis:Float=0
	
	Method New()' gxtkApp()
		app=Self
		ggraphics=New gxtkGraphics
	EndMethod
	
	Method Setup()
		ginput=New gxtkInput
		gaudio=New gxtkAudio

		bb_input__1Set_1Input_1Device(ginput)
		bb_audio__1Set_1Audio_1Device(gaudio)
		
		startMillis=BlitzMaxMillisecs()
		
		SetFrameRate( 0 )
		
		InvokeOnCreate()
		InvokeOnRender()
		Update()
	EndMethod
	
	Method Update()
		While Not AppTerminate()
			If Not updatePeriod return
			Local updates:Int = 0
			
			Repeat
				nextUpdate:+updatePeriod
				InvokeOnUpdate()
				If Not updatePeriod Then Exit
				If nextUpdate>BlitzMaxMillisecs() Then Exit
				updates:+1
				If updates = 7 Then
					nextUpdate = BlitzMaxMillisecs()
					Exit
				EndIf
			Forever
			InvokeOnRender()
			Local del:Int = nextUpdate - BlitzMaxMillisecs()
			If del < 1 Then del = 1
			Delay(del)
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
			updatePeriod=1000.0/fps
			nextUpdate=BlitzMaxMillisecs() +updatePeriod
		Else
			updatePeriod=0
		EndIf
	EndMethod

	Method LoadState:String()
'		var file:SharedObject=SharedObject.getLocal( "gxtkapp" );
'		var state:String=file.data.state;
'		file.close();
'		if( state ) return state;
		Return ""
	EndMethod
	
	Method SaveState:Int( state:String )
'		var file:SharedObject=SharedObject.getLocal( "gxtkapp" );
'		file.data.state=state;
'		file.close();
		Return 0
	EndMethod
	
	Method LoadString:String( path:String )
		path = "data/" + path
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
		Return vloading
	EndMethod

	Method OnCreate:Int()
		Return 0
	EndMethod

	Method OnUpdate:Int()
		Return 0
	EndMethod
	
	Method OnSuspend:Int()
		Return 0
	EndMethod
	
	Method OnResume:Int()
		Return 0
	EndMethod
	
	Method OnRender:Int()
		Return 0
	EndMethod
	
	Method OnLoading:Int()
		Return 0
	EndMethod
EndType

Type gxtkGraphics
	Field gmode:Int = 1
	Field ix:Float=1,iy:Float,jx:Float,jy:Float=1,tx:Float,ty:Float
	Field sx:Float=1,sy:Float=1,rot:Float=0
	
	Method Mode:Int()
		Return gmode
	EndMethod
	
	Method Cls:Int(r:Int = 0, g:Int = 0, b:Int = 0)
		BlitzMaxCls(r, g, b)
		Return 0
	EndMethod
	
	Method DrawPoint:Int(x:Float, y:Float)
		Local nx:Float = TransX(x,y)
		Local ny:Float = TransY(x,y)
		Plot nx, ny
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
		Return GraphicsWidth()
	EndMethod
	
	Method Height:Int()
		Return GraphicsHeight()
	EndMethod
	
	Method SetScissor:Int(x:Int, y:Int, w:Int, h:Int)
		SetViewport(x, y, w, h) ' NOT TESTED!
		Return 0
	EndMethod

	Method TransX:Float(x:Float, y:Float)
		Return ix*x + jx*y + tx
	EndMethod
	
	Method TransY:Float(x:Float, y:Float)
		Return iy*x + jy*y + ty
	EndMethod
	
	Method SetMatrix:Int(ix:Float,iy:Float,jx:Float,jy:Float,tx:Float,ty:Float)
		Self.ix = ix ; Self.iy = iy
		Self.jx = jx ; Self.jy = jy
		Self.tx = tx ; Self.ty = ty
		sx = Sqr( (ix*ix) + (jx*jx) )
		sy = Sqr( (iy*iy) + (jy*jy) )
		rot = -Atan2( jx, ix )
		SetTransform( rot, sx, sy )
		Return 0
	EndMethod
	
	Method DrawSurface:Int(surface:gxtkSurface,x:Float,y:Float)
		Local nx:Float = TransX(x,y)
		Local ny:Float = TransY(x,y)
		DrawImage(surface.image, nx, ny, 0)
		Return 0
	EndMethod
	
	Method DrawSurface2:Int(surface:gxtkSurface,x:Float,y:Float, srcx:Int, srcy:Int, srcw:Int, srch:Int )
		Local nx:Float = TransX(x,y)
		Local ny:Float = TransY(x,y)
		DrawSubImageRect(surface.image, nx, ny, srcw, srch, srcx, srcy, srcw, srch)		
		Return 0
	EndMethod
	
	Method DrawLine:Int( x1:Float,y1:Float,x2:Float,y2:Float )
		Local nx1:Float = TransX(x1,y1)
		Local ny1:Float = TransY(x1,y1)
		Local nx2:Float = TransX(x2,y2)
		Local ny2:Float = TransY(x2,y2)
		' Need to reset transform so that BlitzMax doesn't try to apply rotation
		SetTransform( 0, 1, 1 )
		BlitzMaxDrawLine(nx1, ny1, nx2, ny2)
		SetTransform( rot, sx, sy )
		Return 0
	EndMethod
	
	Method DrawOval:Int( x:Float, y:Float, w:Float, h:Float )
		Local nx:Float = TransX(x,y)
		Local ny:Float = TransY(x,y)
		BlitzMaxDrawOval(nx, ny, w, h)
		Return 0
	EndMethod
	
	Method DrawPoly:Int(vertices:Float[])
		' setting the origin to use the current rotation translation
		SetOrigin(TransX(0,0), TransY(0,0))
		BlitzMaxDrawPoly( vertices )
		SetOrigin(0, 0)
		Return 0
	EndMethod
	
	Method DrawRect:Int( x:Float, y:Float, w:Float, h:Float )
		Local nx:Float = TransX(x,y)
		Local ny:Float = TransY(x,y)
		BlitzMaxDrawRect(nx, ny, w, h)
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
		if( key = 384 ) key = 1 ' change TOUCH0 to MOUSE_LMB

		If( key >= 1 And key <= 3 )
			Return BRL.PolledInput.MouseDown( key )
		EndIf
		If key < 256
			Return BRL.PolledInput.KeyDown( key )
		Else
			Return 0
		EndIf
	EndMethod

	Method KeyHit:Int( key:Int )
		if( key = 384 ) key = 1 ' change TOUCH0 to MOUSE_LMB
		If( key >= 1 And key <= 3 )
			Return BRL.PolledInput.MouseHit( key )
		EndIf
		If key < 256
			Return BRL.PolledInput.KeyHit( key )
		Else
			Return 0
		EndIf
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
		Return BRL.PolledInput.MouseX()
	EndMethod

	Method TouchY:Float( index:Int )
		Return BRL.PolledInput.MouseY()
	EndMethod
	
	Method AccelX:Int()
		return 0
	EndMethod
	
	Method AccelY:Int()
		return 0
	EndMethod
	
	Method AccelZ:Int()
		return 0
	EndMethod
	
	Method SetKeyboardEnabled:Int( enabled:int )
		Return 0
	EndMethod
EndType

Type gxtkChannel
	Field channel:TChannel	' null then not playing
	Field sample:gxtkSample
	Field loops:int
	'Field transform:SoundTransform=new SoundTransform()
	'Field pausepos:Number
	Field state:int
	
	Method New()
		channel = New TChannel
	EndMethod
EndType

Type gxtkAudio
	Field amusicState:Int = 0
	Field channels:gxtkChannel[] = New gxtkChannel[33]
	
	Method New()
		For local i:Int = 0 To 33 - 1
			channels[i] = New gxtkChannel
		Next
	EndMethod
	
	Method MusicState:Int()
'		If( musicState = 1 And music.isPlaying() = False )
'			musicState = 0;
'		Endif
		Return amusicState
	EndMethod
	
	Method PlayMusic:Int( path:String, flags:Int )
		Return 0
	EndMethod
	
	Method ChannelState:int( channel:int )
		Return -1
	EndMethod
	
	Method StopMusic()
	EndMethod
	
	Method StopChannel( channel:Int )
	EndMethod

	Method PlaySample( sound:gxtkSample, channel:Int, flags:Int )
		Local chan:gxtkChannel = channels[channel]
		
		'If chan.state <> 0 Then chan.channel.Stop() <-- this crashes after the first play!?
		
		chan.sample = sound
		'chan.loops = flags ? 0x7fffffff : 0;
		'chan.channel = sample.sound.play( 0,chan.loops,chan.transform );
		'chan.channel = sound
		chan.state=1
	
		PlaySound( sound.sound, chan.channel )
	EndMethod

	Method SetPan( channel:Int, pan:Float )
		Local chan:gxtkChannel = channels[channel]
		chan.channel.SetPan(pan)
	EndMethod

	Method SetRate( channel:Int, rate:Float )
		Local chan:gxtkChannel = channels[channel]
		chan.channel.SetRate(rate)
	EndMethod

	Method PauseMusic:Int()
		Return 0
	EndMethod

	Method ResumeMusic:Int()
		Return 0
	EndMethod

	Method SetMusicVolume:Int( volume:Float )
		Return 0
	EndMethod

	Method SetVolume:Int( channel:Int, volume:Float )
		Local chan:gxtkChannel = channels[channel]
		chan.channel.SetVolume(volume)
		Return 0
	EndMethod
	
	Method LoadSample:gxtkSample( path:String )
		Local extension:String = ExtractExt( path)
		If extension = "ogg" Or extension = "wav" Then
			Local sound:TSound = LoadSound("data/"+path)
			If sound Then
				Local gs:gxtkSample = New gxtkSample
				gs.setSound(sound)
				Return gs
			EndIf
		Else
			RuntimeError "BlitzMax can only use ogg and wav file formats"
		EndIf
		Return Null
	EndMethod
EndType

Type gxtkSample
	Field sound:TSound
	
	Method setSound(sound:TSound)
		Self.sound = sound
	EndMethod
	
	Method Discard()
		Self.sound = null
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

