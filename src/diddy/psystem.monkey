Import diddy

' Due to complaints that the particle system actually uses real mathematics, the y-axis now points down
' when rendering.  Note that this means polar velocity angles are inverted (clockwise from right).
Class ParticleSystem Implements IPSReader
Private
' Private fields
	Field groups:ArrayList<ParticleGroup>
	Field emitters:ArrayList<Emitter>
	
Public
' Properties
	Method Groups:ArrayList<ParticleGroup>() Property
		Return groups
	End
	
	Method Emitters:ArrayList<Emitter>() Property
		Return emitters
	End
	
' Constructors
	Method New()
		groups = New ArrayList<ParticleGroup>
		emitters = New ArrayList<Emitter>
	End
	
	Method New(doc:XMLDocument)
		groups = New ArrayList<ParticleGroup>
		emitters = New ArrayList<Emitter>
		ReadXML(doc.Root)
	End
	
	Method New(node:XMLElement)
		groups = New ArrayList<ParticleGroup>
		emitters = New ArrayList<Emitter>
		ReadXML(node)
	End
	
' Public methods
	Method GetGroup:ParticleGroup(name:String)
		For Local i:Int = 0 Until groups.Size
			If groups.Get(i).Name = name Then
				Return groups.Get(i)
			End
		Next
		Return Null
	End
	
	Method GetEmitter:Emitter(name:String)
		For Local i:Int = 0 Until emitters.Size
			If emitters.Get(i).Name = name Then
				Return emitters.Get(i)
			End
		Next
		Return Null
	End
	
	Method Render:Void()
		Local rgb:Float[] = GetColor()
		Local alpha:Float = GetAlpha()
		For Local i:Int = 0 Until groups.Size
			groups.Get(i).Render()
		Next
		SetAlpha(alpha)
		SetColor(rgb[0], rgb[1], rgb[2])
	End
	
	Method Update:Void(delta:Float)
		For Local i:Int = 0 Until groups.Size
			groups.Get(i).Update(delta)
		Next
	End
	
	Method ReadXML:Void(node:XMLElement)
		' read from a <psystem> node
		Local children:ArrayList<XMLElement> = node.Children
		For Local i:Int = 0 Until children.Size
			If children.Get(i).Name = "groups" Then
				' parse groups
				Local groupNodes:ArrayList<XMLElement> = children.Get(i).Children
				For Local j:Int = 0 Until groupNodes.Size
					Local groupNode:XMLElement = groupNodes.Get(j)
					If groupNode.Name = "group" Then
						Local group:ParticleGroup = New ParticleGroup(groupNode)
						groups.Add(group)
					End
				Next
			ElseIf children.Get(i).Name = "emitters" Then
				' parse emitters
				Local emitterNodes:ArrayList<XMLElement> = children.Get(i).Children
				For Local j:Int = 0 Until emitterNodes.Size
					Local emitterNode:XMLElement = emitterNodes.Get(j)
					If emitterNode.Name = "emitter" Then
						Local emitter:Emitter = New Emitter(emitterNode)
						emitters.Add(emitter)
					End
				Next
			End
		Next
		' go through the emitters and set the groups by name
		For Local i:Int = 0 Until emitters.Size
			Local group:ParticleGroup = GetGroup(emitters.Get(i).groupName)
			If group <> Null Then emitters.Get(i).Group = group
		Next
	End
End

Class Emitter Implements IPSReader
Private
' Property fields
	Field velocityX:Float                       ' the default X velocity
	Field velocityXSpread:Float                 ' the X velocity random spread
	Field velocityY:Float                       ' the default Y velocity
	Field velocityYSpread:Float                 ' the Y velocity random spread
	Field polarVelocityAmplitude:Float          ' the default polar velocity amplitude
	Field polarVelocityAmplitudeSpread:Float    ' the polar velocity amplitude random spread
	Field polarVelocityAngle:Float              ' the default polar velocity angle (radians)
	Field polarVelocityAngleSpread:Float        ' the polar velocity angle random spread (radians)
	Field usePolar:Bool                         ' whether we should use a polar velocity
	Field spawnMinRange:Float                   ' the minimum distance to spawn from the emit point
	Field spawnMaxRange:Float                   ' the maximum distance to spawn from the emit point
	Field life:Float                            ' the default life of the particle in seconds
	Field lifeSpread:Float                      ' the life spread in seconds
	Field rotation:Float
	Field rotationSpread:Float
	Field rotationSpeed:Float
	Field rotationSpeedSpread:Float
	Field scale:Float = 1
	Field scaleSpread:Float
	
	' colours
	Field redInterpolation:Int = INTERPOLATION_NONE     ' interpolates the particle's red based on life
	Field redInterpolationTime:Float = -1               ' the number of seconds to interpolate across (if <0, defaults to life)
	Field greenInterpolation:Int = INTERPOLATION_NONE   ' interpolates the particle's green based on life
	Field greenInterpolationTime:Float = -1             ' the number of seconds to interpolate across (if <0, defaults to life)
	Field blueInterpolation:Int = INTERPOLATION_NONE    ' interpolates the particle's blue based on life
	Field blueInterpolationTime:Float = -1              ' the number of seconds to interpolate across (if <0, defaults to life)
	Field alphaInterpolation:Int = INTERPOLATION_LINEAR ' interpolates the particle's alpha based on life
	Field alphaInterpolationTime:Float = -1             ' the number of seconds to interpolate across (if <0, defaults to life)
	
	Field minStartRed:Int = 255, maxStartRed:Int = 255
	Field minStartGreen:Int = 255, maxStartGreen:Int = 255
	Field minStartBlue:Int = 255, maxStartBlue:Int = 255
	Field minStartAlpha:Float = 1, maxStartAlpha:Float = 1
	Field minEndRed:Int = 255, maxEndRed:Int = 255
	Field minEndGreen:Int = 255, maxEndGreen:Int = 255
	Field minEndBlue:Int = 255, maxEndBlue:Int = 255
	Field minEndAlpha:Float = 0, maxEndAlpha:Float = 0
	
	Field particleImage:Image
	
' Emitter info
	Field name:String
	Field x:Float               ' the x position of the emitter (if we don't pass it into the Emit methods)
	Field y:Float               ' the y position of the emitter (if we don't pass it into the Emit methods)
	Field amplitude:Float = 10  ' the polar amplitude of the emitter (unused for now)
	Field angle:Float           ' the polar angle of the emitter (unused for now) (radians)
	Field group:ParticleGroup   ' the source group for this emitter (important for death emitters)
	Field groupName:String      ' temporary, only for reading XML

' Death emitters
	Field deathEmitters:ArrayList<Emitter>      ' the death emitters will fire at the particle's point of death
	                                            ' using the particle's normalised velocity
	Field deathEmitterChances:FloatArrayList    ' 0-1 random chance as to whether the death emitter will fire
	
Public
' Properties
	' velocityX
	Method VelocityX:Float() Property
		Return velocityX
	End
	Method VelocityX:Void(velocityX:Float) Property
		Self.velocityX = velocityX
		Self.usePolar = False
	End
	
	' velocityXSpread
	Method VelocityXSpread:Float() Property
		Return velocityXSpread
	End
	Method VelocityXSpread:Void(velocityXSpread:Float) Property
		Self.velocityXSpread = velocityXSpread
		Self.usePolar = False
	End
	
	' velocityY
	Method VelocityY:Float() Property
		Return velocityY
	End
	Method VelocityY:Void(velocityY:Float) Property
		Self.velocityY = velocityY
		Self.usePolar = False
	End
	
	' velocityYSpread
	Method VelocityYSpread:Float() Property
		Return velocityYSpread
	End
	Method VelocityYSpread:Void(velocityYSpread:Float) Property
		Self.velocityYSpread = velocityYSpread
		Self.usePolar = False
	End
	
	' polarVelocityAmplitude
	Method PolarVelocityAmplitude:Float() Property
		Return polarVelocityAmplitude
	End
	Method PolarVelocityAmplitude:Void(polarVelocityAmplitude:Float) Property
		Self.polarVelocityAmplitude = polarVelocityAmplitude
		Self.usePolar = True
	End
	
	' polarVelocityAmplitudeSpread
	Method PolarVelocityAmplitudeSpread:Float() Property
		Return polarVelocityAmplitudeSpread
	End
	Method PolarVelocityAmplitudeSpread:Void(polarVelocityAmplitudeSpread:Float) Property
		Self.polarVelocityAmplitudeSpread = polarVelocityAmplitudeSpread
		Self.usePolar = True
	End
	
	' polarVelocityAngle (property is degrees)
	Method PolarVelocityAngle:Float() Property
		Return polarVelocityAngle * R2D
	End
	Method PolarVelocityAngle:Void(polarVelocityAngle:Float) Property
		Self.polarVelocityAngle = polarVelocityAngle * D2R
		Self.usePolar = True
	End
	Method PolarVelocityAngleRadians:Float() Property
		Return polarVelocityAngle
	End
	Method PolarVelocityAngleRadians:Void(polarVelocityAngle:Float) Property
		Self.polarVelocityAngle = polarVelocityAngle
		Self.usePolar = True
	End
	
	' polarVelocityAngleSpread (property is degrees)
	Method PolarVelocityAngleSpread:Float() Property
		Return polarVelocityAngleSpread * R2D
	End
	Method PolarVelocityAngleSpread:Void(polarVelocityAngleSpread:Float) Property
		Self.polarVelocityAngleSpread = polarVelocityAngleSpread * D2R
		Self.usePolar = True
	End
	Method PolarVelocityAngleSpreadRadians:Float() Property
		Return polarVelocityAngleSpread
	End
	Method PolarVelocityAngleSpreadRadians:Void(polarVelocityAngleSpread:Float) Property
		Self.polarVelocityAngleSpread = polarVelocityAngleSpread
		Self.usePolar = True
	End
	
	' usePolar
	Method UsePolar:Bool() Property
		Return usePolar
	End
	Method UsePolar:Void(usePolar:Bool) Property
		Self.usePolar = usePolar
	End
	
	' spawnMinRange
	Method SpawnMinRange:Float() Property
		Return spawnMinRange
	End
	Method SpawnMinRange:Void(spawnMinRange:Float) Property
		Self.spawnMinRange = spawnMinRange
	End
	
	' spawnMaxRange
	Method SpawnMaxRange:Float() Property
		Return spawnMaxRange
	End
	Method SpawnMaxRange:Void(spawnMaxRange:Float) Property
		Self.spawnMaxRange = spawnMaxRange
	End

	' life
	Method Life:Float() Property
		Return life
	End
	Method Life:Void(life:Float) Property
		Self.life = life
	End
	
	' lifeSpread
	Method LifeSpread:Float() Property
		Return lifeSpread
	End
	Method LifeSpread:Void(lifeSpread:Float) Property
		Self.lifeSpread = lifeSpread
	End
	
	' redInterpolation
	Method RedInterpolation:Int() Property
		Return redInterpolation
	End
	Method RedInterpolation:Void(redInterpolation:Int) Property
		AssertRangeInt(redInterpolation, INTERPOLATION_NONE, INTERPOLATION_COUNT, "Invalid RedInterpolation")
		Self.redInterpolation = redInterpolation
	End
	
	' redInterpolationTime
	Method RedInterpolationTime:Float() Property
		Return redInterpolationTime
	End
	Method RedInterpolationTime:Void(redInterpolationTime:Float) Property
		Self.redInterpolationTime = redInterpolationTime
	End
	
	' greenInterpolation
	Method GreenInterpolation:Int() Property
		Return greenInterpolation
	End
	Method GreenInterpolation:Void(greenInterpolation:Int) Property
		AssertRangeInt(greenInterpolation, INTERPOLATION_NONE, INTERPOLATION_COUNT, "Invalid GreenInterpolation")
		Self.greenInterpolation = greenInterpolation
	End
	
	' greenInterpolationTime
	Method GreenInterpolationTime:Float() Property
		Return greenInterpolationTime
	End
	Method GreenInterpolationTime:Void(greenInterpolationTime:Float) Property
		Self.greenInterpolationTime = greenInterpolationTime
	End
	
	' blueInterpolation
	Method BlueInterpolation:Int() Property
		Return blueInterpolation
	End
	Method BlueInterpolation:Void(blueInterpolation:Int) Property
		AssertRangeInt(blueInterpolation, INTERPOLATION_NONE, INTERPOLATION_COUNT, "Invalid BlueInterpolation")
		Self.blueInterpolation = blueInterpolation
	End
	
	' blueInterpolationTime
	Method BlueInterpolationTime:Float() Property
		Return blueInterpolationTime
	End
	Method BlueInterpolationTime:Void(blueInterpolationTime:Float) Property
		Self.blueInterpolationTime = blueInterpolationTime
	End
	
	' alphaInterpolation
	Method AlphaInterpolation:Int() Property
		Return alphaInterpolation
	End
	Method AlphaInterpolation:Void(alphaInterpolation:Int) Property
		AssertRangeInt(alphaInterpolation, INTERPOLATION_NONE, INTERPOLATION_COUNT, "Invalid AlphaInterpolation")
		Self.alphaInterpolation = alphaInterpolation
	End
	
	' alphaInterpolationTime
	Method AlphaInterpolationTime:Float() Property
		Return alphaInterpolationTime
	End
	Method AlphaInterpolationTime:Void(alphaInterpolationTime:Float) Property
		Self.alphaInterpolationTime = alphaInterpolationTime
	End
	
	' minStartRed
	Method MinStartRed:Int() Property
		Return minStartRed
	End
	Method MinStartRed:Void(minStartRed:Int) Property
		Self.minStartRed = Min(Max(minStartRed,0),255)
	End
	
	' maxStartRed
	Method MaxStartRed:Int() Property
		Return maxStartRed
	End
	Method MaxStartRed:Void(maxStartRed:Int) Property
		Self.maxStartRed = Min(Max(maxStartRed,0),255)
	End
	
	' minStartGreen
	Method MinStartGreen:Int() Property
		Return minStartGreen
	End
	Method MinStartGreen:Void(minStartGreen:Int) Property
		Self.minStartGreen = Min(Max(minStartGreen,0),255)
	End
	
	' maxStartGreen
	Method MaxStartGreen:Int() Property
		Return maxStartGreen
	End
	Method MaxStartGreen:Void(maxStartGreen:Int) Property
		Self.maxStartGreen = Min(Max(maxStartGreen,0),255)
	End
	
	' minStartBlue
	Method MinStartBlue:Int() Property
		Return minStartBlue
	End
	Method MinStartBlue:Void(minStartBlue:Int) Property
		Self.minStartBlue = Min(Max(minStartBlue,0),255)
	End
	
	' maxStartBlue
	Method MaxStartBlue:Int() Property
		Return maxStartBlue
	End
	Method MaxStartBlue:Void(maxStartBlue:Int) Property
		Self.maxStartBlue = Min(Max(maxStartBlue,0),255)
	End
	
	' minStartAlpha
	Method MinStartAlpha:Float() Property
		Return minStartAlpha
	End
	Method MinStartAlpha:Void(minStartAlpha:Float) Property
		Self.minStartAlpha = Min(Max(minStartAlpha,0.0),1.0)
	End
	
	' maxStartAlpha
	Method MaxStartAlpha:Float() Property
		Return maxStartAlpha
	End
	Method MaxStartAlpha:Void(maxStartAlpha:Float) Property
		Self.maxStartAlpha = Min(Max(maxStartAlpha,0.0),1.0)
	End
	
	' minEndRed
	Method MinEndRed:Int() Property
		Return minEndRed
	End
	Method MinEndRed:Void(minEndRed:Int) Property
		Self.minEndRed = Min(Max(minEndRed,0),255)
	End
	
	' maxEndRed
	Method MaxEndRed:Int() Property
		Return maxEndRed
	End
	Method MaxEndRed:Void(maxEndRed:Int) Property
		Self.maxEndRed = Min(Max(maxEndRed,0),255)
	End
	
	' minEndGreen
	Method MinEndGreen:Int() Property
		Return minEndGreen
	End
	Method MinEndGreen:Void(minEndGreen:Int) Property
		Self.minEndGreen = Min(Max(minEndGreen,0),255)
	End
	
	' maxEndGreen
	Method MaxEndGreen:Int() Property
		Return maxEndGreen
	End
	Method MaxEndGreen:Void(maxEndGreen:Int) Property
		Self.maxEndGreen = Min(Max(maxEndGreen,0),255)
	End
	
	' minEndBlue
	Method MinEndBlue:Int() Property
		Return minEndBlue
	End
	Method MinEndBlue:Void(minEndBlue:Int) Property
		Self.minEndBlue = Min(Max(minEndBlue,0),255)
	End
	
	' maxEndBlue
	Method MaxEndBlue:Int() Property
		Return maxEndBlue
	End
	Method MaxEndBlue:Void(maxEndBlue:Int) Property
		Self.maxEndBlue = Min(Max(maxEndBlue,0),255)
	End
	
	' minEndAlpha
	Method MinEndAlpha:Float() Property
		Return minEndAlpha
	End
	Method MinEndAlpha:Void(minEndAlpha:Float) Property
		Self.minEndAlpha = Min(Max(minEndAlpha,0.0),1.0)
	End
	
	' maxEndAlpha
	Method MaxEndAlpha:Float() Property
		Return maxEndAlpha
	End
	Method MaxEndAlpha:Void(maxEndAlpha:Float) Property
		Self.maxEndAlpha = Min(Max(maxEndAlpha,0.0),1.0)
	End
	
	' particleImage
	Method ParticleImage:Image() Property
		Return particleImage
	End
	Method ParticleImage:Void(particleImage:Image) Property
		Self.particleImage = particleImage
	End
	
	' rotation (property is degrees)
	Method Rotation:Float() Property
		Return rotation * R2D
	End
	Method Rotation:Void(rotation:Float) Property
		Self.rotation = rotation * D2R
	End
	Method RotationRadians:Float() Property
		Return rotation
	End
	Method RotationRadians:Void(rotation:Float) Property
		Self.rotation = rotation
	End
	
	' rotationSpread (property is degrees)
	Method RotationSpread:Float() Property
		Return rotationSpread * R2D
	End
	Method RotationSpread:Void(rotationSpread:Float) Property
		Self.rotationSpread = rotationSpread * D2R
	End
	Method RotationSpreadRadians:Float() Property
		Return rotationSpread
	End
	Method RotationSpreadRadians:Void(rotationSpread:Float) Property
		Self.rotationSpread = rotationSpread
	End
	
	' rotationSpeed (property is degrees)
	Method RotationSpeed:Float() Property
		Return rotationSpeed * R2D
	End
	Method RotationSpeed:Void(rotationSpeed:Float) Property
		Self.rotationSpeed = rotationSpeed * D2R
	End
	Method RotationSpeedRadians:Float() Property
		Return rotationSpeed
	End
	Method RotationSpeedRadians:Void(rotationSpeed:Float) Property
		Self.rotationSpeed = rotationSpeed
	End
	
	' rotationSpeedSpread (property is degrees)
	Method RotationSpeedSpread:Float() Property
		Return rotationSpeedSpread * R2D
	End
	Method RotationSpeedSpread:Void(rotationSpeedSpread:Float) Property
		Self.rotationSpeedSpread = rotationSpeedSpread * D2R
	End
	Method RotationSpeedSpreadRadians:Float() Property
		Return rotationSpeedSpread
	End
	Method RotationSpeedSpreadRadians:Void(rotationSpeedSpread:Float) Property
		Self.rotationSpeedSpread = rotationSpeedSpread
	End
	
	' scale
	Method Scale:Float() Property
		Return scale
	End
	Method Scale:Void(scale:Float) Property
		Self.scale = scale
	End
	
	' scaleSpread
	Method ScaleSpread:Float() Property
		Return scaleSpread
	End
	Method ScaleSpread:Void(scaleSpread:Float) Property
		Self.scaleSpread = scaleSpread
	End
	
	' name
	Method Name:String() Property
		Return name
	End
	Method Name:Void(name:String) Property
		Self.name = name
	End
	
	' x
	Method X:Float() Property
		Return x
	End
	Method X:Void(x:Float) Property
		Self.x = x
	End
	
	' y
	Method Y:Float() Property
		Return y
	End
	Method Y:Void(y:Float) Property
		Self.y = y
	End
	
	' angle (property is degrees)
	Method Angle:Float() Property
		Return angle * R2D
	End
	Method Angle:Void(angle:Float) Property
		Self.angle = angle * D2R
	End
	Method AngleRadians:Float() Property
		Return angle
	End
	Method AngleRadians:Void(angle:Float) Property
		Self.angle = angle
	End
	
	' amplitude
	Method Amplitude:Float() Property
		Return amplitude
	End
	Method Amplitude:Void(amplitude:Float) Property
		Self.amplitude = amplitude
	End
	
	' group
	Method Group:ParticleGroup() Property
		Return group
	End
	Method Group:Void(group:ParticleGroup) Property
		Self.group = group
	End

' Convenience properties for static colours
	Method Red:Int() Property
		Return minStartRed
	End
	Method Red:Void(red:Int) Property
		red = Min(Max(red,0),255)
		Self.minStartRed = red
		Self.maxStartRed = red
		Self.minEndRed = red
		Self.maxEndRed = red
		Self.redInterpolation = INTERPOLATION_NONE
		Self.redInterpolationTime = -1
	End
	
	Method Green:Int() Property
		Return minStartGreen
	End
	Method Green:Void(green:Int) Property
		green = Min(Max(green,0),255)
		Self.minStartGreen = green
		Self.maxStartGreen = green
		Self.minEndGreen = green
		Self.maxEndGreen = green
		Self.greenInterpolation = INTERPOLATION_NONE
		Self.greenInterpolationTime = -1
	End
	
	Method Blue:Int() Property
		Return minStartBlue
	End
	Method Blue:Void(blue:Int) Property
		blue = Min(Max(blue,0),255)
		Self.minStartBlue = blue
		Self.maxStartBlue = blue
		Self.minEndBlue = blue
		Self.maxEndBlue = blue
		Self.blueInterpolation = INTERPOLATION_NONE
		Self.blueInterpolationTime = -1
	End
	
	Method Alpha:Float() Property
		Return minStartAlpha
	End
	Method Alpha:Void(alpha:Float) Property
		alpha = Min(Max(alpha,0.0),1.0)
		Self.minStartAlpha = alpha
		Self.maxStartAlpha = alpha
		Self.minEndAlpha = 0
		Self.maxEndAlpha = 0
		Self.alphaInterpolation = INTERPOLATION_LINEAR
		Self.alphaInterpolationTime = -1
	End
	
' Convenience properties for interpolated colours
	Method StartRed:Int() Property
		Return minStartRed
	End
	Method StartRed:Void(startRed:Int) Property
		startRed = Min(Max(startRed,0),255)
		Self.minStartRed = startRed
		Self.maxStartRed = startRed
	End
	
	Method StartGreen:Int() Property
		Return minStartGreen
	End
	Method StartGreen:Void(startGreen:Int) Property
		startGreen = Min(Max(startGreen,0),255)
		Self.minStartGreen = startGreen
		Self.maxStartGreen = startGreen
	End
	
	Method StartBlue:Int() Property
		Return minStartBlue
	End
	Method StartBlue:Void(startBlue:Int) Property
		startBlue = Min(Max(startBlue,0),255)
		Self.minStartBlue = startBlue
		Self.maxStartBlue = startBlue
	End
	
	Method StartAlpha:Float() Property
		Return minStartAlpha
	End
	Method StartAlpha:Void(startAlpha:Float) Property
		startAlpha = Min(Max(startAlpha,0.0),1.0)
		Self.minStartAlpha = startAlpha
		Self.maxStartAlpha = startAlpha
	End
	
	Method EndRed:Int() Property
		Return minEndRed
	End
	Method EndRed:Void(endRed:Int) Property
		endRed = Min(Max(endRed,0),255)
		Self.minEndRed = endRed
		Self.maxEndRed = endRed
	End
	
	Method EndGreen:Int() Property
		Return minEndGreen
	End
	Method EndGreen:Void(endGreen:Int) Property
		endGreen = Min(Max(endGreen,0),255)
		Self.minEndGreen = endGreen
		Self.maxEndGreen = endGreen
	End
	
	Method EndBlue:Int() Property
		Return minEndBlue
	End
	Method EndBlue:Void(endBlue:Int) Property
		endBlue = Min(Max(endBlue,0),255)
		Self.minEndBlue = endBlue
		Self.maxEndBlue = endBlue
	End
	
	Method EndAlpha:Float() Property
		Return minEndAlpha
	End
	Method EndAlpha:Void(endAlpha:Float) Property
		endAlpha = Min(Max(endAlpha,0.0),1.0)
		Self.minEndAlpha = endAlpha
		Self.maxEndAlpha = endAlpha
	End
	
' Constructors
	Method New()
		deathEmitters = New ArrayList<Emitter>
		deathEmitterChances = New FloatArrayList
	End
	
	Method New(node:XMLElement)
		deathEmitters = New ArrayList<Emitter>
		deathEmitterChances = New FloatArrayList
		ReadXML(node)
	End

' Convenience setters
	Method SetParticleRGBInterpolated:Void(startRed:Int, startGreen:Int, startBlue:Int, endRed:Int, endGreen:Int, endBlue:Int)
		' clamp 0-255
		startRed = Min(Max(startRed,0),255)
		startGreen = Min(Max(startGreen,0),255)
		startBlue = Min(Max(startBlue,0),255)
		endRed = Min(Max(endRed,0),255)
		endGreen = Min(Max(endGreen,0),255)
		endBlue = Min(Max(endBlue,0),255)
		minStartRed = startRed
		maxStartRed = startRed
		minEndRed = endRed
		maxEndRed = endRed
		If startRed <> endRed Then
			redInterpolation = INTERPOLATION_LINEAR
			redInterpolationTime = -1
		Else
			redInterpolation = INTERPOLATION_NONE
		End
		
		minStartGreen = startGreen
		maxStartGreen = startGreen
		minEndGreen = endGreen
		maxEndGreen = endGreen
		If startGreen <> endGreen Then
			greenInterpolation = INTERPOLATION_LINEAR
			greenInterpolationTime = -1
		Else
			greenInterpolation = INTERPOLATION_NONE
		End
		
		minStartBlue = startBlue
		maxStartBlue = startBlue
		minEndBlue = endBlue
		maxEndBlue = endBlue
		If startBlue <> endBlue Then
			blueInterpolation = INTERPOLATION_LINEAR
			blueInterpolationTime = -1
		Else
			blueInterpolation = INTERPOLATION_NONE
		End
	End
	
	Method SetParticleRGB:Void(red:Int, green:Int, blue:Int)
		' clamp 0-255
		red = Min(Max(red,0),255)
		green = Min(Max(green,0),255)
		blue = Min(Max(blue,0),255)
		minStartRed = red
		maxStartRed = red
		minEndRed = red
		maxEndRed = red
		redInterpolation = INTERPOLATION_NONE
		minStartGreen = green
		maxStartGreen = green
		minEndGreen = green
		maxEndGreen = green
		greenInterpolation = INTERPOLATION_NONE
		minStartBlue = blue
		maxStartBlue = blue
		minEndBlue = blue
		maxEndBlue = blue
		blueInterpolation = INTERPOLATION_NONE
	End
	
	Method SetParticleAlpha:Void(alpha:Float, time:Int=-1)
		' clamp 0-1
		alpha = Min(Max(alpha,0.0),1.0)
		minStartAlpha = alpha
		maxStartAlpha = alpha
		minEndAlpha = 0
		maxEndAlpha = 0
		alphaInterpolation = INTERPOLATION_LINEAR
		If time < 0 Then time = life
		alphaInterpolationTime = life
	End
	
	Method SetVelocity:Void(velocityX:Float, velocityY:Float)
		SetVelocity(velocityX, 0, velocityY, 0)
	End
	
	Method SetVelocity:Void(velocityX:Float, velocityXSpread:Float, velocityY:Float, velocityYSpread:Float)
		usePolar = False
		Self.velocityX = velocityX
		Self.velocityXSpread = velocityXSpread
		Self.velocityY = velocityY
		Self.velocityYSpread = velocityYSpread
	End
	
	' Degrees
	Method SetPolarVelocity:Void(polarVelocityAngle:Float, polarVelocityAmplitude:Float)
		SetPolarVelocityRadians(polarVelocityAngle*D2R, 0, polarVelocityAmplitude, 0)
	End
	
	Method SetPolarVelocityRadians:Void(polarVelocityAngle:Float, polarVelocityAmplitude:Float)
		SetPolarVelocityRadians(polarVelocityAngle, 0, polarVelocityAmplitude, 0)
	End
	
	' Degrees
	Method SetPolarVelocity:Void(polarVelocityAngle:Float, polarVelocityAngleSpread:Float, polarVelocityAmplitude:Float, polarVelocityAmplitudeSpread:Float)
		SetPolarVelocityRadians(polarVelocityAngle*D2R, polarVelocityAngleSpread*D2R, polarVelocityAmplitude, polarVelocityAmplitudeSpread)
	End
	
	Method SetPolarVelocityRadians:Void(polarVelocityAngle:Float, polarVelocityAngleSpread:Float, polarVelocityAmplitude:Float, polarVelocityAmplitudeSpread:Float)
		usePolar = True
		Self.polarVelocityAngle = polarVelocityAngle
		Self.polarVelocityAngleSpread = polarVelocityAngleSpread
		Self.polarVelocityAmplitude = polarVelocityAmplitude
		Self.polarVelocityAmplitudeSpread = polarVelocityAmplitudeSpread
	End
	
	Method SetParticleRotation:Void(rotation:Float, rotationSpread:Float=0, rotationSpeed:Float=0, rotationSpeedSpread:Float=0)
		SetParticleRotationRadians(rotation * D2R, rotationSpread * D2R, rotationSpeed * D2R, rotationSpeedSpread * D2R)
	End
	
	Method SetParticleRotationRadians:Void(rotation:Float, rotationSpread:Float=0, rotationSpeed:Float=0, rotationSpeedSpread:Float=0)
		Self.rotation = rotation
		Self.rotationSpread = rotationSpread
		Self.rotationSpeed = rotationSpeed
		Self.rotationSpeedSpread = rotationSpeedSpread
	End
	
	Method SetParticleScale:Void(scale:Float, scaleSpread:Float = 0)
		Self.scale = scale
		Self.scaleSpread = scaleSpread
	End
	
' Death emitter methods
	Method AddDeathEmitter(emitter:Emitter, chance:Float)
		deathEmitters.Add(emitter)
		deathEmitterChances.AddFloat(chance)
	End
	
	Method RemoveDeathEmitter(emitter:Emitter)
		Local idx:Int = deathEmitters.IndexOf(emitter)
		If idx >= 0 Then
			deathEmitters.RemoveAt(idx)
			deathEmitterChances.RemoveAt(idx)
		End
	End
	
	Method SetDeathEmitterChance(emitter:Emitter, chance:Float)
		Local idx:Int = deathEmitters.IndexOf(emitter)
		If idx >= 0 Then
			deathEmitterChances.SetFloat(idx, chance)
		End
	End
	
' Emits	
	Method Emit:Void(amount:Int, group:ParticleGroup=Null)
		EmitAtAngleRadians(amount, x, y, angle, group)
	End
	
	Method EmitAt:Void(amount:Int, emitX:Float, emitY:Float, group:ParticleGroup=Null)
		EmitAtAngleRadians(amount, emitX, emitY, angle, group)
	End
	
	Method EmitAngle:Void(amount:Int, emitAngle:Float, emitAmplitude:Float, group:ParticleGroup=Null)
		'EmitAtAngleRadians(group, amount, x, y, emitAngle, group)
	End
	
	Method EmitAngleRadians:Void(amount:Int, emitAngle:Float, emitAmplitude:Float, group:ParticleGroup=Null)
		'EmitAtAngleRadians(group, amount, x, y, emitAngle, group)
	End
	
	Method EmitAtAngle:Void(amount:Int, emitX:Float, emitY:Float, emitAngle:Float, group:ParticleGroup=Null)
		EmitAtAngleRadians(amount, emitX, emitY, emitAngle * D2R, group)
	End
	
	Method EmitAtAngleRadians:Void(amount:Int, emitX:Float, emitY:Float, emitAngle:Float, group:ParticleGroup=Null)
		' if not passed a group, use the assigned one
		If group = Null Then group = Self.group
		' create "amount" number of particles
		For Local i:Int = 0 Until amount
			' get an index for a new particle
			Local index:Int = group.CreateParticle()
			' die if we're full
			If index < 0 Then Exit
			
			Local spawnAngle:Float = Rnd() * 2 * PI
			Local spawnDistance:Float = spawnMinRange + Rnd() * (spawnMaxRange-spawnMinRange)
			group.x[index] = emitX + Cosr(spawnAngle) * spawnDistance
			group.y[index] = emitY + Sinr(spawnAngle) * spawnDistance
			group.usePolar[index] = usePolar
			If usePolar Then
				' TODO: adjust for src speed
				group.polarVelocityAngle[index] = emitAngle + polarVelocityAngle - polarVelocityAngleSpread/2 + Rnd() * polarVelocityAngleSpread
				group.polarVelocityAmplitude[index] = polarVelocityAmplitude - polarVelocityAmplitudeSpread/2 + Rnd() * polarVelocityAmplitudeSpread
				group.UpdateCartesian(index)
			Else
				' TODO: adjust for src angle and speed
				group.velocityX[index] = velocityX - velocityXSpread/2 + Rnd() * velocityXSpread
				group.velocityY[index] = velocityY - velocityYSpread/2 + Rnd() * velocityYSpread
			End
			group.sourceEmitter[index] = Self
			group.alive[index] = True
			group.life[index] = life - lifeSpread/2 + Rnd() * lifeSpread
			group.rotation[index] = rotation - rotationSpread/2 + Rnd() * rotationSpread
			group.rotationSpeed[index] = rotationSpeed - rotationSpeedSpread/2 + Rnd() * rotationSpeedSpread
			group.scale[index] = scale - scaleSpread/2 + Rnd() * scaleSpread
			
			' image
			group.particleImage[index] = particleImage
			
			' start colours
			If minStartRed <> maxStartRed Then
				group.startRed[index] = Max(0,Min(255,Int(minStartRed + Rnd() * (maxStartRed-minStartRed))))
			Else
				group.startRed[index] = minStartRed
			End
			If minStartGreen <> maxStartGreen Then
				group.startGreen[index] = Max(0,Min(255,Int(minStartGreen + Rnd() * (maxStartRed-minStartGreen))))
			Else
				group.startGreen[index] = minStartGreen
			End
			If minStartBlue <> maxStartBlue Then
				group.startBlue[index] = Max(0,Min(255,Int(minStartBlue + Rnd() * (maxStartBlue-minStartBlue))))
			Else
				group.startBlue[index] = minStartBlue
			End
			If minStartAlpha <> maxStartAlpha Then
				group.startAlpha[index] = Max(0.0,Min(1.0,minStartAlpha + Rnd() * (maxStartAlpha-minStartAlpha)))
			Else
				group.startAlpha[index] = minStartAlpha
			End
			
			group.red[index] = group.startRed[index]
			group.green[index] = group.startGreen[index]
			group.blue[index] = group.startBlue[index]
			group.alpha[index] = group.startAlpha[index]
			
			' end colours
			If minEndRed <> maxEndRed Then
				group.endRed[index] = Max(0,Min(255,Int(minEndRed + Rnd() * (maxEndRed-minEndRed))))
			Else
				group.endRed[index] = minEndRed
			End
			If minEndGreen <> maxEndGreen Then
				group.endGreen[index] = Max(0,Min(255,Int(minEndGreen + Rnd() * (maxEndRed-minEndGreen))))
			Else
				group.endGreen[index] = minEndGreen
			End
			If minEndBlue <> maxEndBlue Then
				group.endBlue[index] = Max(0,Min(255,Int(minEndBlue + Rnd() * (maxEndBlue-minEndBlue))))
			Else
				group.endBlue[index] = minEndBlue
			End
			If minEndAlpha <> maxEndAlpha Then
				group.endAlpha[index] = Max(0.0,Min(1.0,minEndAlpha + Rnd() * (maxEndAlpha-minEndAlpha)))
			Else
				group.endAlpha[index] = minEndAlpha
			End
			
			' interpolation
			If group.startRed[index] = group.endRed[index] Then
				group.redInterpolation[index] = INTERPOLATION_NONE
			Else
				group.redInterpolation[index] = redInterpolation
				group.redInterpolationTime[index] = redInterpolationTime
				If group.redInterpolationTime[index] < 0 Then group.redInterpolationTime[index] = group.life[index]
			End
			If group.startGreen[index] = group.endGreen[index] Then
				group.greenInterpolation[index] = INTERPOLATION_NONE
			Else
				group.greenInterpolation[index] = greenInterpolation
				group.greenInterpolationTime[index] = greenInterpolationTime
				If group.greenInterpolationTime[index] < 0 Then group.greenInterpolationTime[index] = group.life[index]
			End
			If group.startBlue[index] = group.endBlue[index] Then
				group.blueInterpolation[index] = INTERPOLATION_NONE
			Else
				group.blueInterpolation[index] = blueInterpolation
				group.blueInterpolationTime[index] = blueInterpolationTime
				If group.blueInterpolationTime[index] < 0 Then group.blueInterpolationTime[index] = group.life[index]
			End
			If group.startAlpha[index] = group.endAlpha[index] Then
				group.alphaInterpolation[index] = INTERPOLATION_NONE
			Else
				group.alphaInterpolation[index] = alphaInterpolation
				group.alphaInterpolationTime[index] = alphaInterpolationTime
				If group.alphaInterpolationTime[index] < 0 Then group.alphaInterpolationTime[index] = group.life[index]
			End
		Next
	End
	
	' Reads attributes from an emitter node.  Note that properties are used so that
	' the convenience ones can can do their magic.
	Method ReadXML:Void(node:XMLElement)
		' convenience colour properties
		If node.HasAttribute("Red")        Then Red        = Float(node.GetAttribute("Red"))
		If node.HasAttribute("Green")      Then Green      = Float(node.GetAttribute("Green"))
		If node.HasAttribute("Blue")       Then Blue       = Float(node.GetAttribute("Blue"))
		If node.HasAttribute("Alpha")      Then Alpha      = Float(node.GetAttribute("Alpha"))
		If node.HasAttribute("StartRed")   Then StartRed   = Float(node.GetAttribute("StartRed"))
		If node.HasAttribute("StartGreen") Then StartGreen = Float(node.GetAttribute("StartGreen"))
		If node.HasAttribute("StartBlue")  Then StartBlue  = Float(node.GetAttribute("StartBlue"))
		If node.HasAttribute("StartAlpha") Then StartAlpha = Float(node.GetAttribute("StartAlpha"))
		If node.HasAttribute("EndRed")     Then EndRed     = Float(node.GetAttribute("EndRed"))
		If node.HasAttribute("EndGreen")   Then EndGreen   = Float(node.GetAttribute("EndGreen"))
		If node.HasAttribute("EndBlue")    Then EndBlue    = Float(node.GetAttribute("EndBlue"))
		If node.HasAttribute("EndAlpha")   Then EndAlpha   = Float(node.GetAttribute("EndAlpha"))
		' direct colour properties
		If node.HasAttribute("MinStartRed")   Then MinStartRed   = Float(node.GetAttribute("MinStartRed"))
		If node.HasAttribute("MaxStartRed")   Then MaxStartRed   = Float(node.GetAttribute("MaxStartRed"))
		If node.HasAttribute("MinEndRed")     Then MinEndRed     = Float(node.GetAttribute("MinEndRed"))
		If node.HasAttribute("MaxEndRed")     Then MaxEndRed     = Float(node.GetAttribute("MaxEndRed"))
		If node.HasAttribute("MinStartGreen") Then MinStartGreen = Float(node.GetAttribute("MinStartGreen"))
		If node.HasAttribute("MaxStartGreen") Then MaxStartGreen = Float(node.GetAttribute("MaxStartGreen"))
		If node.HasAttribute("MinEndGreen")   Then MinEndGreen   = Float(node.GetAttribute("MinEndGreen"))
		If node.HasAttribute("MaxEndGreen")   Then MaxEndGreen   = Float(node.GetAttribute("MaxEndGreen"))
		If node.HasAttribute("MinStartBlue")  Then MinStartBlue  = Float(node.GetAttribute("MinStartBlue"))
		If node.HasAttribute("MaxStartBlue")  Then MaxStartBlue  = Float(node.GetAttribute("MaxStartBlue"))
		If node.HasAttribute("MinEndBlue")    Then MinEndBlue    = Float(node.GetAttribute("MinEndBlue"))
		If node.HasAttribute("MaxEndBlue")    Then MaxEndBlue    = Float(node.GetAttribute("MaxEndBlue"))
		If node.HasAttribute("MinStartAlpha") Then MinStartAlpha = Float(node.GetAttribute("MinStartAlpha"))
		If node.HasAttribute("MaxStartAlpha") Then MaxStartAlpha = Float(node.GetAttribute("MaxStartAlpha"))
		If node.HasAttribute("MinEndAlpha")   Then MinEndAlpha   = Float(node.GetAttribute("MinEndAlpha"))
		If node.HasAttribute("MaxEndAlpha")   Then MaxEndAlpha   = Float(node.GetAttribute("MaxEndAlpha"))
		' interpolation
		If node.HasAttribute("RedInterpolation")       Then RedInterpolation       = InterpolationFromString(node.GetAttribute("RedInterpolation"))
		If node.HasAttribute("GreenInterpolation")     Then GreenInterpolation     = InterpolationFromString(node.GetAttribute("GreenInterpolation"))
		If node.HasAttribute("BlueInterpolation")      Then BlueInterpolation      = InterpolationFromString(node.GetAttribute("BlueInterpolation"))
		If node.HasAttribute("AlphaInterpolation")     Then AlphaInterpolation     = InterpolationFromString(node.GetAttribute("AlphaInterpolation"))
		If node.HasAttribute("RedInterpolationTime")   Then RedInterpolationTime   = Float(node.GetAttribute("RedInterpolationTime"))
		If node.HasAttribute("GreenInterpolationTime") Then GreenInterpolationTime = Float(node.GetAttribute("GreenInterpolationTime"))
		If node.HasAttribute("BlueInterpolationTime")  Then BlueInterpolationTime  = Float(node.GetAttribute("BlueInterpolationTime"))
		If node.HasAttribute("AlphaInterpolationTime") Then AlphaInterpolationTime = Float(node.GetAttribute("AlphaInterpolationTime"))
		' polar velocity
		If node.HasAttribute("PolarVelocityAngle")              Then PolarVelocityAngle              = Float(node.GetAttribute("PolarVelocityAngle"))
		If node.HasAttribute("PolarVelocityAngleRadians")       Then PolarVelocityAngleRadians       = Float(node.GetAttribute("PolarVelocityAngleRadians"))
		If node.HasAttribute("PolarVelocityAngleSpread")        Then PolarVelocityAngleSpread        = Float(node.GetAttribute("PolarVelocityAngleSpread"))
		If node.HasAttribute("PolarVelocityAngleSpreadRadians") Then PolarVelocityAngleSpreadRadians = Float(node.GetAttribute("PolarVelocityAngleSpreadRadians"))
		If node.HasAttribute("PolarVelocityAmplitude")          Then PolarVelocityAmplitude          = Float(node.GetAttribute("PolarVelocityAmplitude"))
		If node.HasAttribute("PolarVelocityAmplitudeSpread")    Then PolarVelocityAmplitudeSpread    = Float(node.GetAttribute("PolarVelocityAmplitudeSpread"))
		' cartesian velocity
		If node.HasAttribute("VelocityX")       Then VelocityX       = Float(node.GetAttribute("VelocityX"))
		If node.HasAttribute("VelocityXSpread") Then VelocityXSpread = Float(node.GetAttribute("VelocityXSpread"))
		If node.HasAttribute("VelocityY")       Then VelocityY       = Float(node.GetAttribute("VelocityY"))
		If node.HasAttribute("VelocityYSpread") Then VelocityYSpread = Float(node.GetAttribute("VelocityYSpread"))
		' emitter settings
		If node.HasAttribute("Name")         Then Name         = node.GetAttribute("Name")
		If node.HasAttribute("X")            Then X            = Float(node.GetAttribute("X"))
		If node.HasAttribute("Y")            Then Y            = Float(node.GetAttribute("Y"))
		If node.HasAttribute("Angle")        Then Angle        = Float(node.GetAttribute("Angle"))
		If node.HasAttribute("AngleRadians") Then AngleRadians = Float(node.GetAttribute("AngleRadians"))
		If node.HasAttribute("Group")        Then groupName    = node.GetAttribute("Group")
		
		If node.HasAttribute("SpawnMinRange") Then SpawnMinRange = Float(node.GetAttribute("SpawnMinRange"))
		If node.HasAttribute("SpawnMaxRange") Then SpawnMaxRange = Float(node.GetAttribute("SpawnMaxRange"))
		If node.HasAttribute("Life")          Then Life = Float(node.GetAttribute("Life"))
		If node.HasAttribute("LifeSpread")    Then LifeSpread = Float(node.GetAttribute("LifeSpread"))
		If node.HasAttribute("Scale")         Then Scale = Float(node.GetAttribute("Scale"))
		If node.HasAttribute("ScaleSpread")   Then ScaleSpread = Float(node.GetAttribute("ScaleSpread"))
		
		If node.HasAttribute("Rotation")                   Then Rotation = Float(node.GetAttribute("Rotation"))
		If node.HasAttribute("RotationRadians")            Then RotationRadians = Float(node.GetAttribute("RotationRadians"))
		If node.HasAttribute("RotationSpread")             Then RotationSpread = Float(node.GetAttribute("RotationSpread"))
		If node.HasAttribute("RotationSpreadRadians")      Then RotationSpreadRadians = Float(node.GetAttribute("RotationSpreadRadians"))
		If node.HasAttribute("RotationSpeed")              Then RotationSpeed = Float(node.GetAttribute("RotationSpeed"))
		If node.HasAttribute("RotationSpeedRadians")       Then RotationSpeedRadians = Float(node.GetAttribute("RotationSpeedRadians"))
		If node.HasAttribute("RotationSpeedSpread")        Then RotationSpeedSpread = Float(node.GetAttribute("RotationSpeedSpread"))
		If node.HasAttribute("RotationSpeedSpreadRadians") Then RotationSpeedSpreadRadians = Float(node.GetAttribute("RotationSpeedSpreadRadians"))
	End
End

Class ParticleGroup Implements IPSReader
Private
	' fields for each particle (more efficient to have multiple large arrays than incredible amounts of Particle objects
	Field x:Float[]
	Field y:Float[]
	Field velocityX:Float[]
	Field velocityY:Float[]
	Field polarVelocityAmplitude:Float[]
	Field polarVelocityAngle:Float[] ' radians
	Field usePolar:Bool[]
	Field mass:Float[]
	Field rotation:Float[]
	Field rotationSpeed:Float[]
	Field scale:Float[]

	Field red:Int[]
	Field green:Int[]
	Field blue:Int[]
	Field alpha:Float[]
	
	Field particleImage:Image[]
	
	Field startRed:Int[]
	Field startGreen:Int[]
	Field startBlue:Int[]
	Field startAlpha:Float[]
	
	Field endRed:Int[]
	Field endGreen:Int[]
	Field endBlue:Int[]
	Field endAlpha:Float[]
	
	Field redInterpolation:Int[]
	Field redInterpolationTime:Float[]
	Field greenInterpolation:Int[]
	Field greenInterpolationTime:Float[]
	Field blueInterpolation:Int[]
	Field blueInterpolationTime:Float[]
	Field alphaInterpolation:Int[]
	Field alphaInterpolationTime:Float[]
	
	Field life:Float[]
	Field alive:Bool[]
	Field reversePointer:Int[]
	Field sourceEmitter:Emitter[]
	
	Field maxParticles:Int ' read only property
	Field alivePointers:Int[]
	Field aliveParticles:Int ' read only property

	' acceleration, etc.
	Field accelerationX:Float
	Field accelerationY:Float
	
	' cached arrays for clearing out dead particles
	Field deadParticles:Int[]
	Field deadEmitters:Emitter[]
	Field deadX:Float[]
	Field deadY:Float[]
	Field deadVelocityX:Float[]
	Field deadVelocityY:Float[]
	Field deadCount:Int = 0
	
	' constants for the group
	Field forces:ArrayList<Force>
	Field forcesArray:Object[]
	
	Field name:String
	
	Method Init(maxParticles:Int)
		Self.maxParticles = maxParticles
		forces = New ArrayList<Force>
		
		x = New Float[maxParticles]
		y = New Float[maxParticles]
		velocityX = New Float[maxParticles]
		velocityY = New Float[maxParticles]
		polarVelocityAmplitude = New Float[maxParticles]
		polarVelocityAngle = New Float[maxParticles]
		usePolar = New Bool[maxParticles]
		sourceEmitter = New Emitter[maxParticles]
		life = New Float[maxParticles]
		alive = New Bool[maxParticles]
		mass = New Float[maxParticles]
		particleImage = New Image[maxParticles]
		rotation = New Float[maxParticles]
		rotationSpeed = New Float[maxParticles]
		scale = New Float[maxParticles]

		
		red = New Int[maxParticles]
		green = New Int[maxParticles]
		blue = New Int[maxParticles]
		alpha = New Float[maxParticles]
		
		startRed = New Int[maxParticles]
		startGreen = New Int[maxParticles]
		startBlue = New Int[maxParticles]
		startAlpha = New Float[maxParticles]
		
		endRed = New Int[maxParticles]
		endGreen = New Int[maxParticles]
		endBlue = New Int[maxParticles]
		endAlpha = New Float[maxParticles]
		
		redInterpolation = New Int[maxParticles]
		redInterpolationTime = New Float[maxParticles]
		greenInterpolation = New Int[maxParticles]
		greenInterpolationTime = New Float[maxParticles]
		blueInterpolation = New Int[maxParticles]
		blueInterpolationTime = New Float[maxParticles]
		alphaInterpolation = New Int[maxParticles]
		alphaInterpolationTime = New Float[maxParticles]
		
		reversePointer = New Int[maxParticles]
		alivePointers = New Int[maxParticles]
		
		' these are populated before a dead particle is cleared
		deadParticles = New Int[maxParticles]
		deadEmitters = New Emitter[maxParticles]
		deadX = New Float[maxParticles]
		deadY = New Float[maxParticles]
		deadVelocityX = New Float[maxParticles]
		deadVelocityY = New Float[maxParticles]
		
		ResetParticles()
	End
	
Public
' Properties
	Method AliveParticles:Int() Property
		Return aliveParticles
	End
	
	Method MaxParticles:Int() Property
		Return maxParticles
	End
	
	Method Forces:ArrayList<Force>() Property
		Return forces
	End
	
	Method Name:String() Property
		Return name
	End
	Method Name:Void(name:String) Property
		Self.name = name
	End

	Method GetForce:Force(name:String)
		For Local i:Int = 0 Until forces.Size
			If forces.Get(i).Name = name Then
				Return forces.Get(i)
			End
		Next
		Return Null
	End
	
' Constructors
	Method New(maxParticles:Int, name:String="")
		Self.name = name
		Init(maxParticles)
	End
	
	Method New(node:XMLElement)
		ReadXML(node)
	End

	Method Update:Void(delta:Float)
		' cache the force arraylist first
		Local forceCount:Int = 0
		If forcesArray.Length < forces.Size Then
			forcesArray = forces.ToArray()
			forceCount = forcesArray.Length
		Else
			forceCount = forces.FillArray(forcesArray)
		End
		' convert milliseconds to seconds
		delta = delta/1000
		deadCount = 0
		' loop through all living particles
		For Local i:Int = 0 Until aliveParticles
			Local index:Int = alivePointers[i]
			life[index] -= delta
			If life[index] > 0 Then
				' apply acceleration
				If forceCount > 0 Then
					' apply forces
					For Local fi:Int = 0 Until forceCount
						If Force(forcesArray[fi]).enabled Then
							Local f:Force = Force(forcesArray[fi])
							f.Calculate(x[index], y[index])
							velocityX[index] += f.outDX * delta
							velocityY[index] += f.outDY * delta
						End
					Next
					' TODO: terminal velocity
				End
				' update position
				x[index] += velocityX[index] * delta
				y[index] += velocityY[index] * delta
				' update rotation
				rotation[index] += rotationSpeed[index] * delta
				' clip rotation
				While rotation[index] > 2*PI
					rotation[index] -= 2*PI
				End
				While rotation[index] < 0
					rotation[index] += 2*PI
				End
				' interpolate colours
				If startRed[index] <> endRed[index] And life[index] < redInterpolationTime[index] Then
					red[index] = Int(Interpolate(redInterpolation[index], startRed[index], endRed[index], 1 - life[index]/redInterpolationTime[index]))
				End
				If startGreen[index] <> endGreen[index] And life[index] < greenInterpolationTime[index] Then
					green[index] = Int(Interpolate(greenInterpolation[index], startGreen[index], endGreen[index], 1 - life[index]/greenInterpolationTime[index]))
				End
				If startBlue[index] <> endBlue[index] And life[index] < blueInterpolationTime[index] Then
					blue[index] = Int(Interpolate(blueInterpolation[index], startBlue[index], endBlue[index], 1 - life[index]/blueInterpolationTime[index]))
				End
				If startAlpha[index] <> endAlpha[index] And life[index] < alphaInterpolationTime[index] Then
					alpha[index] = Interpolate(alphaInterpolation[index], startAlpha[index], endAlpha[index], 1 - life[index]/alphaInterpolationTime[index])
				End
			Else
				alive[index] = False
				' cache info from dead particle
				deadParticles[deadCount] = index
				deadEmitters[deadCount] = sourceEmitter[index]
				deadX[deadCount] = x[index]
				deadY[deadCount] = y[index]
				deadVelocityX[deadCount] = velocityX[index]
				deadVelocityY[deadCount] = velocityY[index]
				deadCount += 1
			End
		Next
		' remove all the dead particles from the pointer array
		For Local i:Int = 0 Until deadCount
			RemoveParticle(deadParticles[i])
		Next
		' now fire off any emitters
		For Local i:Int = 0 Until deadCount
			For Local j:Int = 0 Until deadEmitters[i].deathEmitterChances.Size
				Local c:Float = deadEmitters[i].deathEmitterChances.Get(j)
				If c = 1 Or c > 0 And Rnd() <= c Then
					Local e:Emitter = deadEmitters[i].deathEmitters.Get(j)
					' if the emitter has no group assigned, we use Self
					If e.group = Null Then
						e.EmitAtAngle(30, deadX[i], deadY[i], SafeATanr(deadVelocityX[i], deadVelocityY[i]), Self)
					Else
						e.EmitAtAngle(30, deadX[i], deadY[i], SafeATanr(deadVelocityX[i], deadVelocityY[i]))
					End
				End
			Next
			deadEmitters[i] = Null
		Next
	End
	
	Method UpdatePolar(index:Int)
		Local angle:Float = SafeATanr(velocityX[index], velocityY[index], polarVelocityAngle[index])
		polarVelocityAngle[index] = angle
		polarVelocityAmplitude[index] = Sqrt(velocityX[index]*velocityX[index] + velocityY[index]*velocityY[index])
	End
	
	Method UpdateCartesian(index:Int)
		velocityX[index] = Cosr(polarVelocityAngle[index]) * polarVelocityAmplitude[index]
		velocityY[index] = Sinr(polarVelocityAngle[index]) * polarVelocityAmplitude[index]
	End
	
	Method CreateParticle:Int()
		If aliveParticles >= maxParticles Then Return -1
		aliveParticles += 1
		ClearParticle(alivePointers[aliveParticles-1])
		Return alivePointers[aliveParticles-1]
	End
	
	Method ResetParticles:Void()
		aliveParticles = 0
		For Local i:Int = 0 Until maxParticles
			alivePointers[i] = i
			reversePointer[i] = i
			ClearParticle(i)
		Next
	End
	
	Method ClearParticle:Void(index:Int)
		x[index] = 0
		y[index] = 0
		velocityX[index] = 0
		velocityY[index] = 0
		polarVelocityAmplitude[index] = 0
		polarVelocityAngle[index] = 0
		usePolar[index] = False
		scale[index] = 1
		rotation[index] = 0
		rotationSpeed[index] = 0
		sourceEmitter[index] = Null
		alive[index] = False
	End

	' index points to the main particle arrays, not alivePointers[]
	Method RemoveParticle:Void(index:Int)
		Local indexOfLastParticle:Int = alivePointers[aliveParticles-1]
		' switch the alivePointers array
		alivePointers[reversePointer[index]] = indexOfLastParticle
		alivePointers[aliveParticles-1] = index
		' switch the reversePointer array
		reversePointer[indexOfLastParticle] = reversePointer[index]
		reversePointer[index] = aliveParticles-1
		' reduce alive pointers
		aliveParticles -= 1
	End
	
	Method Render:Void()
		For Local i:Int = 0 Until aliveParticles
			Local index:Int = alivePointers[i]
			SetColor(red[index], green[index], blue[index])
			SetAlpha(alpha[index])
			
			' scale should never be <=0, so we'll fix it here
			If scale[index] <= 0 Then scale[index] = 1
			
			If particleImage[index] <> Null Then
				If scale[index] <> 1 Or rotation[index] <> 0 Then
					DrawImage(particleImage[index], x[index], y[index], rotation[index]*R2D, scale[index], scale[index])
				Else
					DrawImage(particleImage[index], x[index], y[index])
				End
			Else
				If scale[index] <> 1 Or rotation[index] <> 0 Then
					PushMatrix
					Translate(x[index]-1, y[index]-1)
					If scale[index] <> 1 Then Scale(scale[index], scale[index])
					If rotation[index] <> 0 Then Rotate(rotation[index] * R2D)
					DrawRect(0, 0, 3, 3)
					PopMatrix
				Else
					DrawRect(x[index]-1, y[index]-1, 3, 3)
				End
			End
		Next
	End
	
	Method ReadXML:Void(node:XMLElement)
		' get the maximum number of particles
		Local maxParts:Int = 10000
		If node.HasAttribute("MaxParticles") Then maxParts = Int(node.GetAttribute("MaxParticles"))
		' call Init with the max particles
		Init(maxParts)
		' read the rest of the properties
		If node.HasAttribute("Name") Then Name = node.GetAttribute("Name")
		' read the forces
		Local children:ArrayList<XMLElement> = node.Children
		For Local i:Int = 0 Until children.Size
			'If children.Get(i).Name = "forces" Then
			'	For Local j:Int = 0 Until children.Get(i).Children.Size
					Local forceNode:XMLElement = children.Get(i)'.Children.Get(j)
					If forceNode.Name = "constantforce" Then
						' constant
						Local cf:ConstantForce = New ConstantForce(forceNode)
						forces.Add(cf)
					ElseIf forceNode.Name = "pointforce" Then
						' point
						Local pf:PointForce = New PointForce(forceNode)
						forces.Add(pf)
					End
			'	Next
			'End
		Next
	End
End

Class Force Implements IPSReader Abstract
Private
	Field enabled:Bool = True
	
	Field outDX:Float
	Field outDY:Float
	
	Field name:String
	
Public
' Properties
	Method Enabled:Bool() Property
		Return enabled
	End
	Method Enabled:Void(enabled:Bool) Property
		Self.enabled = enabled
	End
	
	Method Name:String() Property
		Return name
	End
	Method Name:Void(name:String) Property
		Self.name = name
	End
	
' Methods
	Method ReadXML:Void(node:XMLElement)
		If node.HasAttribute("Name") Then Name = node.GetAttribute("Name")
		If node.HasAttribute("Enabled") Then Enabled = Bool(node.GetAttribute("Enabled"))
	End
	
	Method Calculate:Void(x:Float, y:Float) Abstract
End

Class ConstantForce Extends Force
Private
	Field x:Float
	Field y:Float
	
Public
	Method X:Float() Property
		Return x
	End
	Method X:Void(x:Float) Property
		Self.x = x
		Self.outDX = x
	End
	
	Method Y:Float() Property
		Return y
	End
	Method Y:Void(y:Float) Property
		Self.y = y
		Self.outDY = y
	End
	
	Method New(x:Float, y:Float)
		Self.x = x
		Self.y = y
		Self.outDX = x
		Self.outDY = y
	End

	Method New(node:XMLElement)
		ReadXML(node)
	End
	
	Method Calculate:Void(x:Float, y:Float)
		' doesn't need to do anything
	End
	
	Method ReadXML:Void(node:XMLElement)
		Super.ReadXML(node)
		If node.HasAttribute("X") Then X = Float(node.GetAttribute("X"))
		If node.HasAttribute("Y") Then Y = Float(node.GetAttribute("Y"))
	End
End

Class PointForce Extends Force
Private
	Field x:Float
	Field y:Float
	Field acceleration:Float
	
Public
	Method X:Float() Property
		Return x
	End
	Method X:Void(x:Float) Property
		Self.x = x
	End
	
	Method Y:Float() Property
		Return y
	End
	Method Y:Void(y:Float) Property
		Self.y = y
	End
	
	Method Acceleration:Float() Property
		Return acceleration
	End
	Method Acceleration:Void(acceleration:Float) Property
		Self.acceleration = acceleration
	End

	Method New(x:Float, y:Float, acceleration:Float)
		Self.x = x
		Self.y = y
		Self.acceleration = acceleration
	End
	
	Method New(node:XMLElement)
		ReadXML(node)
	End
	
	Method Calculate:Void(x:Float, y:Float)
		' check if the particle is at the same point (yes, it happens, and the whole system dies due to div by 0)
		If x = Self.x And y = Self.y Then
			outDX = 0
			outDY = 0
			Return
		End
		Local length:Float = Sqrt((x-Self.x)*(x-Self.x) + (y-Self.y)*(y-Self.y))
		Local scale:Float = acceleration / length
		outDX = (Self.x-x) * scale
		outDY = (Self.y-y) * scale
	End
	
	Method ReadXML:Void(node:XMLElement)
		Super.ReadXML(node)
		If node.HasAttribute("X") Then X = Float(node.GetAttribute("X"))
		If node.HasAttribute("Y") Then Y = Float(node.GetAttribute("Y"))
		If node.HasAttribute("Acceleration") Then Acceleration = Float(node.GetAttribute("Acceleration"))
	End
End

Interface IPSReader
	Method ReadXML:Void(node:XMLElement)
End

Private

Const R2D:Float = 180/PI
Const D2R:Float = PI/180

Function SafeATanr:Float(dx:Float, dy:Float, def:Float=0)
	' technically a default angle shouldn't be necessary
	Local angle:Float = def
	If dy = 0 And dx >= 0 Then ' 0
		angle = 0
	ElseIf dy = 0 And dx < 0 Then ' 180
		angle = PI
	ElseIf dy > 0 And dx = 0 Then ' 90
		angle = PI/2
	ElseIf dy < 0 And dx = 0 Then ' 270
		angle = 3*PI / 2
	ElseIf dy > 0 And dx > 0 Then ' Acute
		angle = ATanr(dy / dx)
	ElseIf dy > 0 And dx < 0 Then ' Obtuse
		angle = PI - ATanr(dy / -dx)
	ElseIf dy < 0 And dx < 0 Then ' Reflex < 270
		angle = PI + ATanr(dy / dx)
	ElseIf dy < 0 And dx > 0 Then ' Reflex > 270
		angle = 2*PI - ATanr(-dy / dx)
	End
	Return angle
End
