Import diddy

Class ParticleSystem
Private
' Private fields
	Field groups:ArrayList<ParticleGroup>
	
Public
' Properties
	Method Groups:ArrayList<ParticleGroup>() Property
		Return groups
	End
	
' Constructors
	Method New()
		groups = New ArrayList<ParticleGroup>
	End
	
' Public methods
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
End

Class Emitter
Private
' Property fields
	Field velocityX:Float                       ' the default X velocity
	Field velocityXSpread:Float                 ' the X velocity random spread
	Field velocityY:Float                       ' the default Y velocity
	Field velocityYSpread:Float                 ' the Y velocity random spread
	Field polarVelocityAmplitude:Float          ' the default polar velocity amplitude
	Field polarVelocityAmplitudeSpread:Float    ' the polar velocity amplitude random spread
	Field polarVelocityAngle:Float              ' the default polar velocity angle
	Field polarVelocityAngleSpread:Float        ' the polar velocity angle random spread
	Field usePolar:Bool                         ' whether we should use a polar velocity
	Field spawnMinRange:Float                   ' the minimum distance to spawn from the emit point
	Field spawnMaxRange:Float                   ' the maximum distance to spawn from the emit point
	Field life:Float                            ' the default life of the particle in seconds
	Field lifeSpread:Float                      ' the life spread in seconds
	
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
	
' Emitter info
	Field x:Float
	Field y:Float
	Field amplitude:Float = 10
	Field angle:Float
	
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
	End
	
	' velocityXSpread
	Method VelocityXSpread:Float() Property
		Return velocityXSpread
	End
	Method VelocityX:Void(velocityXSpread:Float) Property
		Self.velocityXSpread = velocityXSpread
	End
	
	' velocityY
	Method VelocityY:Float() Property
		Return velocityY
	End
	Method VelocityY:Void(velocityY:Float) Property
		Self.velocityY = velocityY
	End
	
	' velocityYSpread
	Method VelocityYSpread:Float() Property
		Return velocityYSpread
	End
	Method VelocityY:Void(velocityYSpread:Float) Property
		Self.velocityYSpread = velocityYSpread
	End
	
	' polarVelocityAmplitude
	Method PolarVelocityAmplitude:Float() Property
		Return polarVelocityAmplitude
	End
	Method PolarVelocityAmplitude:Void(polarVelocityAmplitude:Float) Property
		Self.polarVelocityAmplitude = polarVelocityAmplitude
	End
	
	' polarVelocityAmplitudeSpread
	Method PolarVelocityAmplitudeSpread:Float() Property
		Return polarVelocityAmplitudeSpread
	End
	Method PolarVelocityAmplitudeSpread:Void(polarVelocityAmplitudeSpread:Float) Property
		Self.polarVelocityAmplitudeSpread = polarVelocityAmplitudeSpread
	End
	
	' polarVelocityAngle
	Method PolarVelocityAngle:Float() Property
		Return polarVelocityAngle
	End
	Method PolarVelocityAngle:Void(polarVelocityAngle:Float) Property
		Self.polarVelocityAngle = polarVelocityAngle
	End
	
	' polarVelocityAngleSpread
	Method PolarVelocityAngleSpread:Float() Property
		Return polarVelocityAngleSpread
	End
	Method PolarVelocityAngleSpread:Void(polarVelocityAngleSpread:Float) Property
		Self.polarVelocityAngleSpread = polarVelocityAngleSpread
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
		Self.minStartRed = minStartRed
	End
	
	' maxStartRed
	Method MaxStartRed:Int() Property
		Return maxStartRed
	End
	Method MaxStartRed:Void(maxStartRed:Int) Property
		Self.maxStartRed = maxStartRed
	End
	
	' minStartGreen
	Method MinStartGreen:Int() Property
		Return minStartGreen
	End
	Method MinStartGreen:Void(minStartGreen:Int) Property
		Self.minStartGreen = minStartGreen
	End
	
	' maxStartGreen
	Method MaxStartGreen:Int() Property
		Return maxStartGreen
	End
	Method MaxStartGreen:Void(maxStartGreen:Int) Property
		Self.maxStartGreen = maxStartGreen
	End
	
	' minStartBlue
	Method MinStartBlue:Int() Property
		Return minStartBlue
	End
	Method MinStartBlue:Void(minStartBlue:Int) Property
		Self.minStartBlue = minStartBlue
	End
	
	' maxStartBlue
	Method MaxStartBlue:Int() Property
		Return maxStartBlue
	End
	Method MaxStartBlue:Void(maxStartBlue:Int) Property
		Self.maxStartBlue = maxStartBlue
	End
	
	' minStartAlpha
	Method MinStartAlpha:Float() Property
		Return minStartAlpha
	End
	Method MinStartAlpha:Void(minStartAlpha:Float) Property
		Self.minStartAlpha = minStartAlpha
	End
	
	' maxStartAlpha
	Method MaxStartAlpha:Float() Property
		Return maxStartAlpha
	End
	Method MaxStartAlpha:Void(maxStartAlpha:Float) Property
		Self.maxStartAlpha = maxStartAlpha
	End
	
	' minEndRed
	Method MinEndRed:Int() Property
		Return minEndRed
	End
	Method MinEndRed:Void(minEndRed:Int) Property
		Self.minEndRed = minEndRed
	End
	
	' maxEndRed
	Method MaxEndRed:Int() Property
		Return maxEndRed
	End
	Method MaxEndRed:Void(maxEndRed:Int) Property
		Self.maxEndRed = maxEndRed
	End
	
	' minEndGreen
	Method MinEndGreen:Int() Property
		Return minEndGreen
	End
	Method MinEndGreen:Void(minEndGreen:Int) Property
		Self.minEndGreen = minEndGreen
	End
	
	' maxEndGreen
	Method MaxEndGreen:Int() Property
		Return maxEndGreen
	End
	Method MaxEndGreen:Void(maxEndGreen:Int) Property
		Self.maxEndGreen = maxEndGreen
	End
	
	' minEndBlue
	Method MinEndBlue:Int() Property
		Return minEndBlue
	End
	Method MinEndBlue:Void(minEndBlue:Int) Property
		Self.minEndBlue = minEndBlue
	End
	
	' maxEndBlue
	Method MaxEndBlue:Int() Property
		Return maxEndBlue
	End
	Method MaxEndBlue:Void(maxEndBlue:Int) Property
		Self.maxEndBlue = maxEndBlue
	End
	
	' minEndAlpha
	Method MinEndAlpha:Float() Property
		Return minEndAlpha
	End
	Method MinEndAlpha:Void(minEndAlpha:Float) Property
		Self.minEndAlpha = minEndAlpha
	End
	
	' maxEndAlpha
	Method MaxEndAlpha:Float() Property
		Return maxEndAlpha
	End
	Method MaxEndAlpha:Void(maxEndAlpha:Float) Property
		Self.maxEndAlpha = maxEndAlpha
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
	
	' angle
	Method Angle:Float() Property
		Return angle
	End
	Method Angle:Void(angle:Float) Property
		Self.angle = angle
	End
	
	' amplitude
	Method Amplitude:Float() Property
		Return amplitude
	End
	Method Amplitude:Void(amplitude:Float) Property
		Self.amplitude = amplitude
	End
	
' Constructors
	Method New()
		deathEmitters = New ArrayList<Emitter>
		deathEmitterChances = New FloatArrayList
	End

' Convenience setters
	Method SetParticleRGBInterpolated:Void(startRed:Int, startGreen:Int, startBlue:Int, endRed:Int, endGreen:Int, endBlue:Int)
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
	
	Method SetPolarVelocity:Void(polarVelocityAngle:Float, polarVelocityAmplitude:Float)
		SetPolarVelocity(polarVelocityAngle, 0, polarVelocityAmplitude, 0)
	End
	
	Method SetPolarVelocity:Void(polarVelocityAngle:Float, polarVelocityAngleSpread:Float, polarVelocityAmplitude:Float, polarVelocityAmplitudeSpread:Float)
		usePolar = True
		Self.polarVelocityAngle = polarVelocityAngle
		Self.polarVelocityAngleSpread = polarVelocityAngleSpread
		Self.polarVelocityAmplitude = polarVelocityAmplitude
		Self.polarVelocityAmplitudeSpread = polarVelocityAmplitudeSpread
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
	Method Emit:Void(group:ParticleGroup, amount:Int)
		EmitAtAngle(group, amount, x, y, angle)
	End
	
	Method EmitAt:Void(group:ParticleGroup, amount:Int, emitX:Float, emitY:Float)
		EmitAtAngle(group, amount, emitX, emitY, angle)
	End
	
	Method EmitAngle:Void(group:ParticleGroup, amount:Int, emitAngle:Float)', emitAmplitude:Float)
		EmitAtAngle(group, amount, x, y, emitAngle)
	End
	
	Method EmitAtAngle:Void(group:ParticleGroup, amount:Int, emitX:Float, emitY:Float, emitAngle:Float)
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
				group.velocityX[index] = Cosr(group.polarVelocityAngle[index]) * group.polarVelocityAmplitude[index]
				group.velocityY[index] = Sinr(group.polarVelocityAngle[index]) * group.polarVelocityAmplitude[index]
			Else
				' TODO: adjust for src angle and speed
				group.velocityX[index] = velocityX - velocityXSpread/2 + Rnd() * velocityXSpread
				group.velocityY[index] = velocityY - velocityYSpread/2 + Rnd() * velocityYSpread
			End
			group.sourceEmitter[index] = Self
			group.alive[index] = True
			group.life[index] = life - lifeSpread/2 + Rnd() * lifeSpread
			
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
End

Class ParticleGroup
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
	
	Field red:Int[]
	Field green:Int[]
	Field blue:Int[]
	Field alpha:Float[]
	
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
	
' Constructors
	Method New(maxParticles:Int)
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

	Method Update:Void(delta:Float)
		' convert milliseconds to seconds
		delta = delta/1000
		deadCount = 0
		' loop through all living particles
		For Local i:Int = 0 Until aliveParticles
			Local index:Int = alivePointers[i]
			life[index] -= delta
			If life[index] > 0 Then
				' apply acceleration
				If Not forces.IsEmpty() Then
					' update cartesian velocity
					If usePolar[index] Then
						velocityX[index] = Cosr(polarVelocityAngle[index]) * polarVelocityAmplitude[index]
						velocityY[index] = Sinr(polarVelocityAngle[index]) * polarVelocityAmplitude[index]
					End
					' apply forces
					For Local fi:Int = 0 Until forces.Size
						Local f:Force = forces.Get(fi)
						velocityX[index] += f.ApplyX(velocityX[index], mass[index]) * delta
						velocityY[index] += f.ApplyY(velocityY[index], mass[index]) * delta
					Next
					' TODO: terminal velocity
					' update polar velocity
					If usePolar[index] Then
						Local angle:Float = SafeATanr(velocityX[index], velocityY[index], polarVelocityAngle[index])
						polarVelocityAngle[index] = angle
						polarVelocityAmplitude[index] = Sqrt(velocityX[index]*velocityX[index] + velocityY[index]*velocityY[index])
					End
				End
				' update position
				x[index] += velocityX[index] * delta
				y[index] += velocityY[index] * delta
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
					e.EmitAtAngle(Self, 30, deadX[i], deadY[i], SafeATanr(deadVelocityX[i], deadVelocityY[i]))
				End
			Next
			deadEmitters[i] = Null
		Next
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
			DrawRect(x[index]-1, SCREEN_HEIGHT-y[index]-1, 3, 3)
		Next
	End
End

Interface Force
	Method ApplyX:Float(x:Float, mass:Float=-1)
	Method ApplyY:Float(y:Float, mass:Float=-1)
End

Class ConstantForce Implements Force
Private
	Field x:Float
	Field y:Float
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
	
	Method New(x:Float, y:Float)
		Self.x = x
		Self.y = y
	End
	
	Method ApplyX:Float(x:Float, mass:Float=-1)
		Return Self.x
	End
	
	Method ApplyY:Float(y:Float, mass:Float=-1)
		Return Self.y
	End
End

Private

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
