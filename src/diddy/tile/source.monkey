Strict

Global tilesetSource:ITilesetSource

Interface ITilesetSource
	Method LoadTilesetImage:ITilesetImage(name:String, tileWidth%, tileHeight%, tileMargin% = 0, tileSpacing% = 0, nameoverride:String = "", midhandle:Bool=False, ignoreCache:Bool=False, readPixels:Bool = False, maskRed:Int = 0, maskGreen:Int = 0, maskBlue:Int = 0)
End

Interface ITilesetImage
	Method TileWidth:Int() Property
	Method TileWidth:Void(value:Int) Property
	Method TileHeight:Int() Property
	Method TileHeight:Void(value:Int) Property
	Method TileCountX:Int() Property
	Method TileCountX:Void(value:Int) Property
	Method TileCountY:Int() Property
	Method TileCountY:Void(value:Int) Property
	Method TileCount:Int() Property
	Method TileCount:Void(value:Int) Property
	Method TileSpacing:Int() Property
	Method TileSpacing:Void(value:Int) Property
	Method TileMargin:Int() Property
	Method TileMargin:Void(value:Int) Property
	Method DrawTile:Void(x:Float, y:Float, tile:Int = 0, rotation:Float = 0, scaleX:Float = 1, scaleY:Float = 1)
End
