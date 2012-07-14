Import diddy

Class MyTiledTileMapReader Extends TiledTileMapReader
	Method CreateMap:TileMap()
		Return New MyTileMap
	End
End

Class MyTileMap Extends TileMap
	Const GRAVITY:Float = 0.5
	
	Method ConfigureLayer:Void(tileLayer:TileMapLayer)
		SetAlpha(tileLayer.opacity)
	End
	
	Method DrawTile:Void(tileLayer:TileMapTileLayer, mapTile:TileMapTile, x:Int, y:Int)
		mapTile.image.DrawTile(x, y, mapTile.id, 0, 1, 1)
	End
End