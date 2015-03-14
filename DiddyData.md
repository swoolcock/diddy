## Intro ##

DiddyData uses a simple command (LoadDiddyData) to load an xml file (diddydata.xml), which sets up your screen size, loads your resources (images and sounds) into the banks and instantiates screens for you.

The diddydata.xml must be stored in the root of your data folder.

## Example ##
```
Strict

#REFLECTION_FILTER="yourfile;diddy.framework"

Import reflection
Import diddy

Function Main:Int()
	New MyGame()
	Return 0
End

Class MyGame Extends DiddyApp
	Method Create:Void()
		debugOn = True
		LoadDiddyData()
		Start(screens.Find("Title"))
	End	
End

Class TitleScreen Extends Screen
	Method Start:Void()
	End

	Method Render:Void()
		Cls
		DrawText("Press SPACE to Play", SCREEN_WIDTH2, SCREEN_HEIGHT2, 0.5, 0.5)
	End
	
	Method Update:Void()
		If KeyHit(KEY_SPACE)
			FadeToScreen(diddyGame.screens.Find("Game"))
		End
	End
End

Class GameScreen Extends Screen
	Field sprite:Sprite
	Field background:GameImage
	Field sound:GameSound
	
	Method Start:Void()
		sprite = New Sprite(diddyGame.images.Find("Ship"), SCREEN_WIDTH2, SCREEN_HEIGHT2)
		background = diddyGame.images.Find("bg_1_1")
		sound = diddyGame.sounds.Find("fire")
	End
	
	Method Render:Void()
		Cls
		background.Draw(0, 0)
		sprite.Draw()
	End
	
	Method Update:Void()
		If KeyDown(KEY_SPACE)
			sound.Play()
		End
		If KeyHit(KEY_ESCAPE)
			FadeToScreen(diddyGame.screens.Find("Title"))
		End
	End
End
```

diddydata.xml
```
<diddy screenWidth="800" screenHeight="600" useAspectRatio="true">
	<resources>
		<images>
			<image path="sprites/Ship1.png" name="Ship" width="64" height="64" frames="7" />
			<image path="backgrounds/bg_1_1.png" midhandle="false" />
		</images>
		<sounds>
			<sound path="Firelaser" name="fire" soundDelay="100" ignoreCache="false" />
		</sounds>
	</resources>
	<screens>
		<screen class="TitleScreen" name="Title" />
		<screen class="GameScreen" name="Game" />
	</screens>
</diddy>
```

## XML ##

### diddy tag ###
  * screenWidth
  * screenHeight
  * userAspectRatio

### image tag ###
  * name
  * path
  * frames
  * width
  * height
  * midhandle
  * ignoreCache
  * readPixels
  * maskRed
  * maskGreen
  * maskBlue

### sound tag ###
  * name
  * path
  * ignoreCache
  * soundDelay

### screen tag ###
  * name
  * class