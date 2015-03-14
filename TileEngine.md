# Introduction #

Diddy's tile engine format is based on the Tiled editor:

http://www.mapeditor.org/

# Instructions #

## Create your map ##

  1. Download, install and run the Tiled Editor
  1. Click New, then click OK
  1. Import your tile images by clicking Map > New Tileset and select your images
  1. Create your map
  1. Click Edit > Preferences
    * Select Base64(uncompressed) or CSV
    * Click Close
  1. Save your map into your MonkeyProject.data\maps folder
  1. Rename the file from tmx to xml (map.tmx to map.xml)
  1. Copy your tile images to your MonkeyProject.data\graphics

## Monkey Code ##

```
Strict

Import mojo
Import diddy

Function Main:Int()
	game = New MyGame
	Return 0
End

Global gameScreen:GameScreen

Class MyGame Extends DiddyApp
	Method OnCreate:Int()
		Super.OnCreate()
		gameScreen = new GameScreen
		gameScreen.PreStart()
		Return 0
	End
End

Class GameScreen Extends Screen
	Field tilemap:MyTileMap
	Field offsetX:Int, offsetY:Int
	Field str$
	
	Method New()
		name = "Game"
	End

	Method Start:Void()
		Local reader:MyTiledTileMapReader = New MyTiledTileMapReader
		Local tm:TileMap = reader.LoadMap("maps/map.xml")
		tilemap = MyTileMap(tm)
		game.screenFade.Start(50, false)
	End
	
	Method Render:Void()
		Cls
		tilemap.RenderMap(offsetX, offsetY, SCREEN_WIDTH, SCREEN_HEIGHT)
		
		FPSCounter.Draw(0,0)
	End
	
	Method Update:Void()
		If KeyHit(KEY_ESCAPE)
			game.screenFade.Start(50, True)
			game.nextScreen = game.exitScreen
		End
		If KeyDown(KEY_UP) Then offsetY -= 4
		If KeyDown(KEY_DOWN) Then offsetY += 4
		If KeyDown(KEY_LEFT) Then offsetX -= 4
		If KeyDown(KEY_RIGHT) Then offsetX += 4
		
		tilemap.UpdateAnimation(dt.frametime)
	End
End


Class MyTiledTileMapReader Extends TiledTileMapReader
	Method CreateMap:TileMap()
		Return New MyTileMap
	End
End

Class MyTileMap Extends TileMap
	Method ConfigureLayer:Void(tileLayer:TileMapLayer)
		SetAlpha(tileLayer.opacity)
	End
	
	Method DrawTile:Void(tileLayer:TileMapTileLayer, mapTile:TileMapTile, x:Int, y:Int)
		mapTile.image.DrawTile(x, y, mapTile.id, 0, 1, 1)
	End
End


```

## Advanced Properties ##
Tiled allows you to set custom properties to your map, layers, and/or individual tiles in a tileset.  The following properties will affect how the map is rendered in Diddy.

### Map Properties ###
  * wrap\_x
> Expects "true" or "false" (defaults to false).
> If true, the map will wrap along the X axis.
  * wrap\_y
> Expects "true" or "false" (defaults to false).
> If true, the map will wrap along the Y axis.

### Layer Properties ###
  * parallax\_scale\_x
> Expects a float value (defaults to 1).
> When rendering this layer, its final X coordinate will be multiplied by this amount.
> A value of one means that it will "move" at the same speed as your viewport (use this for the main layers).
> A value less than one means that it will "move" slower than your viewport (use this for background layers).
> A value greater than one means that it will "move" faster than your viewport (use this for foreground layers).
> A value of zero means that this layer will not "move" in the X direction.
  * parallax\_scale\_y
> Expects a float value (defaults to 1).
> When rendering this layer, its final Y coordinate will be multiplied by this amount.
> A value of one means that it will "move" at the same speed as your viewport (use this for the main layers).
> A value less than one means that it will "move" slower than your viewport (use this for background layers).
> A value greater than one means that it will "move" faster than your viewport (use this for foreground layers).
> A value of zero means that this layer will not "move" in the Y direction.
  * parallax\_offset\_x
> Expects a float value (defaults to 0).
> When rendering this layer, its final X coordinate will be offset by this many pixels (after scaling).
  * parallax\_offset\_y
> Expects a float value (defaults to 0).
> When rendering this layer, its final Y coordinate will be offset by this many pixels (after scaling).

### Tile Properties ###
  * anim\_delay
> Expects a non-negative integer value (defaults to 0).
> If this tile is animating, it will wait this many milliseconds before advancing to the next frame.
  * anim\_next
> Expects an integer value (defaults to 0).
> If this tile is animating, when it comes time to move to the next frame, this number will be added to the index.
> A positive value means that it will move forward in the tileset.  A negative value means that it will move backward in the tileset.
> This number will be automatically multiplied by -1 if the animation is playing backward.
  * anim\_direction
> Expects 0, 1, or -1 (defaults to 0).
> If this tile is animating, when it first reaches this frame, the anim\_direction will be applied to the animation's current direction.
> If anim\_direction is 0, the animation will stop.
> If anim\_direction is -1 and the current direction is forward, the animation will "bounce" and all subsequent "anim\_next" reads will be inverted.
> If anim\_direction is 1 and the current direction is backward, the animation will "bounce" and all subsequent "anim\_next" reads will be used non-inverted.
> In any other case, this value is ignored.