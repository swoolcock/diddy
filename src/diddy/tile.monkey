#Rem
Copyright (c) 2011 Steve Revill and Shane Woolcock
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#End

Strict

Import diddy.base64
Import monkey.map
Import diddy.containers
Import diddy.framework
Import diddy.xml

' TileMapPropertyContainer
' Classes that extend this will automatically instantiate a property container and expose it.
Class TileMapPropertyContainer
Private
	Field properties:TileMapProperties = New TileMapProperties

Public
	Method Properties:TileMapProperties() Property
		Return properties
	End
End



' ITileMapPostLoad
' Classes that implement this interface will have PostLoad automatically called once the object has been created.
Interface ITileMapPostLoad
	Method PostLoad:Void()
End



' TileMapReader
' This can be extended to handle any map file format.
Class TileMapReader Abstract
	Field tileMap:TileMap
	Field graphicsPath:String
	
	Method LoadMap:TileMap(filename:String) Abstract
	
	' override this to create a custom tilemap class
	Method CreateMap:TileMap()
		Return New TileMap
	End
End



' TiledTileMapReader
' Extends TileMapReader to add support for the Tiled map editor.
Class TiledTileMapReader Extends TileMapReader
	Field doc:XMLDocument
	
	' Overrides TileMapReader
	Method LoadMap:TileMap(filename:String)
		' open file and get root node
		Local parser:XMLParser = New XMLParser
		Local xmlString:String = LoadString(filename)
		' error if we couldnt load the file
		If Not xmlString
			AssertError("Cannot load tile map file " + filename + ". Ensure you have TMX in the in the allowed #TEXT_FILES")
		End
		' look for the data encoding, if we cant find it assume its RAW XML and thats just too slow!
		Local findData:Int = xmlString.Find("<data encoding")
		If findData = -1
			AssertError("Tiled Raw XML is not supported!")
		End
		
		doc = parser.ParseString(xmlString)
		Return ReadMap(doc.Root)
	End
	
	Method ReadMap:TileMap(node:XMLElement)
		tileMap = CreateMap()
		ReadProperties(node, tileMap)
		
		' extract map properties
		If tileMap.properties.Has(PROP_MAP_WRAP_X) Then tileMap.wrapX = tileMap.properties.Get(PROP_MAP_WRAP_X).GetBool()
		If tileMap.properties.Has(PROP_MAP_WRAP_Y) Then tileMap.wrapY = tileMap.properties.Get(PROP_MAP_WRAP_Y).GetBool()
		
		' read root node's attributes
		If node.HasAttribute(ATTR_MAP_VERSION) Then tileMap.version = node.GetAttribute(ATTR_MAP_VERSION)
		If node.HasAttribute(ATTR_MAP_ORIENTATION) Then tileMap.orientation = node.GetAttribute(ATTR_MAP_ORIENTATION)
		If node.HasAttribute(ATTR_MAP_WIDTH) Then tileMap.width = Int(node.GetAttribute(ATTR_MAP_WIDTH))
		If node.HasAttribute(ATTR_MAP_HEIGHT) Then tileMap.height = Int(node.GetAttribute(ATTR_MAP_HEIGHT))
		If node.HasAttribute(ATTR_MAP_TILEWIDTH) Then tileMap.tileWidth = Int(node.GetAttribute(ATTR_MAP_TILEWIDTH))
		If node.HasAttribute(ATTR_MAP_TILEHEIGHT) Then tileMap.tileHeight = Int(node.GetAttribute(ATTR_MAP_TILEHEIGHT))
		
		tileMap.maxTileWidth = tileMap.tileWidth
		tileMap.maxTileHeight = tileMap.tileHeight
		
		' parse children
		If Not node.Children.IsEmpty() Then
			For Local mapchild:XMLElement = Eachin node.Children
				' tileset
				If mapchild.Name = NODE_TILESET Then
					Local ts:TileMapTileset = ReadTileset(mapchild)
					tileMap.tilesets.Set(ts.name, ts)
				
				' tile layer
				Elseif mapchild.Name = NODE_LAYER Then
					Local layer:TileMapLayer = ReadTileLayer(mapchild)
					tileMap.layers.Push(layer)
				
				' object layer
				Elseif mapchild.Name = NODE_OBJECTGROUP Then
					Local layer:TileMapLayer = ReadObjectLayer(mapchild)
					tileMap.layers.Push(layer)
				Endif
			Next
		Endif
		
		DoPostLoad(tileMap)
		
		Return tileMap
	End
	
	Method DoPostLoad:Void(obj:Object)
		If ITileMapPostLoad(obj) <> Null Then ITileMapPostLoad(obj).PostLoad()
	End
	
	Method ReadProperties:Void(node:XMLElement, obj:Object)
		Local cont:TileMapPropertyContainer = TileMapPropertyContainer(obj)
		If cont <> Null Then
			For Local propNode:XMLElement = Eachin node.Children
				If propNode.Name = NODE_PROPERTIES Then
					For Local child:XMLElement = Eachin propNode.Children
						If child.Name = NODE_PROPERTY Then
							Local prop:TileMapProperty = ReadProperty(child)
							cont.properties.props.Set(prop.name, prop)
						Endif
					Next
					Return
				End
			Next
		End
	End
	
	Method ReadProperty:TileMapProperty(node:XMLElement)
		Return New TileMapProperty(node.GetAttribute(ATTR_PROPERTY_NAME, "default"), node.GetAttribute(ATTR_PROPERTY_VALUE, ""))
	End
	
	Method ReadTileset:TileMapTileset(node:XMLElement, target:TileMapTileset=Null)
		Local rv:TileMapTileset = target
		ReadProperties(node, rv)
		If rv = Null Then rv = tileMap.CreateTileset()
		If node.HasAttribute(ATTR_TILESET_FIRSTGID) Then rv.firstGid = Int(node.GetAttribute(ATTR_TILESET_FIRSTGID))
		
		If node.HasAttribute(ATTR_TILESET_SOURCE) Then
			rv.source = node.GetAttribute(ATTR_TILESET_SOURCE)
			Local parser:XMLParser = New XMLParser
			Local tilesetdoc:XMLDocument = parser.ParseFile(rv.source)
			Return ReadTileset(tilesetdoc.Root, rv)
		Else
			If node.HasAttribute(ATTR_TILESET_NAME) Then rv.name = node.GetAttribute(ATTR_TILESET_NAME)
			If node.HasAttribute(ATTR_TILESET_TILEWIDTH) Then rv.tileWidth = Int(node.GetAttribute(ATTR_TILESET_TILEWIDTH))
			If node.HasAttribute(ATTR_TILESET_TILEHEIGHT) Then rv.tileHeight = Int(node.GetAttribute(ATTR_TILESET_TILEHEIGHT))
			If node.HasAttribute(ATTR_TILESET_SPACING) Then rv.spacing = Int(node.GetAttribute(ATTR_TILESET_SPACING))
			If node.HasAttribute(ATTR_TILESET_MARGIN) Then rv.margin = Int(node.GetAttribute(ATTR_TILESET_MARGIN))
		
			If Not node.Children.IsEmpty() Then
				For Local child:XMLElement = Eachin node.Children
					If child.Name = NODE_IMAGE Then
						rv.imageNode = ReadImage(child)
					Elseif child.Name = NODE_TILE Then
						rv.tileNodes.Push(ReadTile(child))
					End
				Next
			End
		End
		DoPostLoad(rv)
		Return rv
	End
	
	Method ReadLayerAttributes:Void(node:XMLElement, layer:TileMapLayer)
		If node.HasAttribute(ATTR_LAYER_NAME) Then layer.name = node.GetAttribute(ATTR_LAYER_NAME)
		If node.HasAttribute(ATTR_LAYER_WIDTH) Then layer.width = Int(node.GetAttribute(ATTR_LAYER_WIDTH))
		If node.HasAttribute(ATTR_LAYER_HEIGHT) Then layer.height = Int(node.GetAttribute(ATTR_LAYER_HEIGHT))
		layer.visible = Not node.HasAttribute(ATTR_LAYER_VISIBLE) Or Int(node.GetAttribute(ATTR_LAYER_VISIBLE)) <> 0
		If node.HasAttribute(ATTR_LAYER_OPACITY) Then layer.opacity = Float(node.GetAttribute(ATTR_LAYER_OPACITY))
	End
	
	Method ReadTileLayer:TileMapTileLayer(node:XMLElement)
		Local rv:TileMapTileLayer = tileMap.CreateTileLayer()
		ReadProperties(node, rv)
		ReadLayerAttributes(node, rv)
		
		If rv.properties.Has(PROP_LAYER_PARALLAX_OFFSET_X) Then rv.parallaxOffsetX = rv.properties.Get(PROP_LAYER_PARALLAX_OFFSET_X).GetFloat()
		If rv.properties.Has(PROP_LAYER_PARALLAX_OFFSET_Y) Then rv.parallaxOffsetY = rv.properties.Get(PROP_LAYER_PARALLAX_OFFSET_Y).GetFloat()
		If rv.properties.Has(PROP_LAYER_PARALLAX_SCALE_X) Then rv.parallaxScaleX = rv.properties.Get(PROP_LAYER_PARALLAX_SCALE_X).GetFloat()
		If rv.properties.Has(PROP_LAYER_PARALLAX_SCALE_Y) Then rv.parallaxScaleY = rv.properties.Get(PROP_LAYER_PARALLAX_SCALE_Y).GetFloat()
		If rv.properties.Has(PROP_MAP_WRAP_X) Then rv.wrapX = rv.properties.Get(PROP_MAP_WRAP_X).GetBool()
		If rv.properties.Has(PROP_MAP_WRAP_Y) Then rv.wrapY = rv.properties.Get(PROP_MAP_WRAP_Y).GetBool()
		
		For Local child:XMLElement = Eachin node.Children
			If child.Name = NODE_DATA Then
				rv.mapData = ReadTileData(child, rv)
			End
		Next
		
		DoPostLoad(rv)
		Return rv
	End
	
	Method ReadObjectLayer:TileMapObjectLayer(node:XMLElement)
		Local rv:TileMapObjectLayer = tileMap.CreateObjectLayer()
		ReadProperties(node, rv)
		ReadLayerAttributes(node, rv)
		
		If node.HasAttribute(ATTR_OBJECTGROUP_COLOR) Then rv.color = ColorToInt(node.GetAttribute(ATTR_OBJECTGROUP_COLOR))
		
		For Local child:XMLElement = Eachin node.Children
			If child.Name = NODE_OBJECT Then
				rv.objects.Push(ReadObject(child, rv))
			End
		Next
		
		DoPostLoad(rv)
		Return rv
	End
	
	Method ReadImage:TileMapImage(node:XMLElement)
		Local rv:TileMapImage = tileMap.CreateImage()
		ReadProperties(node, rv)
		
		If node.HasAttribute(ATTR_IMAGE_SOURCE) Then rv.source = graphicsPath + StripDir(node.GetAttribute(ATTR_IMAGE_SOURCE))
		If node.HasAttribute(ATTR_IMAGE_WIDTH) Then rv.width = Int(node.GetAttribute(ATTR_IMAGE_WIDTH))
		If node.HasAttribute(ATTR_IMAGE_HEIGHT) Then rv.height = Int(node.GetAttribute(ATTR_IMAGE_HEIGHT))
		If node.HasAttribute(ATTR_IMAGE_TRANS) Then rv.trans = node.GetAttribute(ATTR_IMAGE_TRANS)
		If rv.trans.Length > 0 Then
			rv.transR = HexToDec(rv.trans[0..2])
			rv.transG = HexToDec(rv.trans[2..4])
			rv.transB = HexToDec(rv.trans[4..6])
		Endif
		
		DoPostLoad(rv)
		Return rv
	End
	
	Method ReadTile:TileMapTile(node:XMLElement)
		Local id:Int = Int(node.GetAttribute(ATTR_TILE_ID, "0"))
		Local rv:TileMapTile = tileMap.CreateTile(id)
		ReadProperties(node, rv)
		DoPostLoad(rv)
		Return rv
	End
	
	Method ReadObject:TileMapObject(node:XMLElement, layer:TileMapObjectLayer)
		Local rv:TileMapObject = tileMap.CreateObject()
		ReadProperties(node, rv)
		If node.HasAttribute(ATTR_OBJECT_NAME) Then rv.name = node.GetAttribute(ATTR_OBJECT_NAME)
		If node.HasAttribute(ATTR_OBJECT_TYPE) Then rv.objectType = node.GetAttribute(ATTR_OBJECT_TYPE)
		If node.HasAttribute(ATTR_OBJECT_X) Then rv.x = Int(node.GetAttribute(ATTR_OBJECT_X))
		If node.HasAttribute(ATTR_OBJECT_Y) Then rv.y = Int(node.GetAttribute(ATTR_OBJECT_Y))
		If node.HasAttribute(ATTR_OBJECT_WIDTH) Then rv.width = Int(node.GetAttribute(ATTR_OBJECT_WIDTH))
		If node.HasAttribute(ATTR_OBJECT_HEIGHT) Then rv.height = Int(node.GetAttribute(ATTR_OBJECT_HEIGHT))
		DoPostLoad(rv)
		Return rv
	End
	
	Method ReadTileData:TileMapData(node:XMLElement, layer:TileMapTileLayer)
		Local rv:TileMapData = tileMap.CreateData(layer.width, layer.height)
		
		' default to raw xml (ugly)
		Local encoding$ = DATA_ENCODING_RAW
		If node.HasAttribute(ATTR_DATA_ENCODING) Then encoding = node.GetAttribute(ATTR_DATA_ENCODING)
		If encoding = DATA_ENCODING_RAW Then
			' TODO: raw xml
			AssertError("Raw xml is currently not supported")
		Elseif encoding = DATA_ENCODING_CSV Then
			Local csv:String[] = node.Value.Split(",")
			For Local i% = 0 Until csv.Length
				Local gid:Int = Int(csv[i].Trim())
				rv.tiles[i] = gid
				rv.cells[i] = tileMap.CreateCell(gid, i Mod rv.width, i / rv.width)
			Next
		Elseif encoding = DATA_ENCODING_BASE64 Then
			Local bytes:Int[] = DecodeBase64Bytes(node.Value)
			If node.HasAttribute(ATTR_DATA_COMPRESSION) Then
				' TODO: compression
				AssertError("Compression is currently not supported")
			End
			For Local i% = 0 Until bytes.Length Step 4
				' little endian
				Local gid% = bytes[i]
				gid += bytes[i + 1] Shl 8
				gid += bytes[i + 2] Shl 16
				gid += bytes[i + 3] Shl 24
				rv.tiles[i / 4] = gid
				rv.cells[i / 4] = tileMap.CreateCell(gid, (i / 4) Mod rv.width, (i / 4) / rv.width)
			Next
		End
		Return rv
	End
End


' TileMapProperties
' Container for properties.
Class TileMapProperties
	Field props:StringMap<TileMapProperty> = New StringMap<TileMapProperty>
	
	Method Has:Bool(name:String)
		Return props.Contains(name)
	End
	
	Method Get:TileMapProperty(name:String)
		Return props.Get(name)
	End
	
	Method Set:Void(name:String, prop:TileMapProperty)
		props.Set(name, prop)
	End
End


' TileMap
' The main Map class.
Class TileMap Extends TileMapPropertyContainer Implements ITileMapPostLoad
	
	' attributes
	Field version:String = "1.0"
	Field orientation:String = MAP_ORIENTATION_ORTHOGONAL
	Field width:Int
	Field height:Int
	Field tileWidth:Int = 32
	Field tileHeight:Int = 32
	
	' children
	Field tilesets:StringMap<TileMapTileset> = New StringMap<TileMapTileset>
	Field layers:DiddyStack<TileMapLayer> = New DiddyStack<TileMapLayer>
	
	' post-load
	Field layerNames:StringMap<TileMapLayer> = New StringMap<TileMapLayer>
	Field tiles:TileMapTile[]
	Field maxTileWidth:Int
	Field maxTileHeight:Int
	Field wrapX:Bool = False
	Field wrapY:Bool = False
	
	' optimisation
	Field layerArray:TileMapLayer[] = []
	Field animatedTiles:TileMapTile[]
	
	' summary: override this to do something before a layer is rendered
	Method PreRenderLayer:Void(tileLayer:TileMapLayer)
		ConfigureLayer(tileLayer) ' call the deprecated one
	End
	
	' summary: override this to do something after a layer is rendered
	Method PostRenderLayer:Void(tileLayer:TileMapLayer)
	End
	
	' summary: override this to do something before the map is rendered
	Method PreRenderMap:Void()
	End
	
	' summary: override this to do something after the map is rendered
	Method PostRenderMap:Void()
	End
	
	' summary: override this to configure a layer (called on every render)
	' deprecated, override PreRenderLayer instead
	Method ConfigureLayer:Void(tileLayer:TileMapLayer)
	End
	
	' summary: override this to draw a tile
	Method DrawTile:Void(tileLayer:TileMapTileLayer, mapTile:TileMapTile, x:Int, y:Int)
		' default draw call
		If mapTile.image Then
			mapTile.image.DrawTile(x, y, mapTile.id, 0, 1, 1)
		ElseIf mapTile.rawImage Then
			DrawImageRect(mapTile.rawImage, x, y, mapTile.srcX, mapTile.srcY, mapTile.width, mapTile.height, 0, 1, 1)
		End
	End
	
	' summary: override this to create a custom tile class
	Method CreateTile:TileMapTile(id:Int)
		Return New TileMapTile(id)
	End
	
	' summary: override this to create a custom tileset class
	Method CreateTileset:TileMapTileset()
		Return New TileMapTileset
	End
	
	' summary: override this to create a custom tile layer class
	Method CreateTileLayer:TileMapTileLayer()
		Return New TileMapTileLayer
	End
	
	' summary: override this to create a custom object layer class
	Method CreateObjectLayer:TileMapObjectLayer()
		Return New TileMapObjectLayer
	End
	
	' summary: override this to create a custom image class
	Method CreateImage:TileMapImage()
		Return New TileMapImage
	End
	
	' summary: override this to create a custom object class
	Method CreateObject:TileMapObject()
		Return New TileMapObject
	End
	
	' summary: override this to create a custom cell class
	Method CreateCell:TileMapCell(gid:Int, x:Int, y:Int)
		Return New TileMapCell(gid, x, y)
	End
	
	' summary: override this to create a custom data class
	Method CreateData:TileMapData(width:Int, height:Int)
		Return New TileMapData(width, height)
	End
	
	' summary: override this to perform additional post-loading functionality (remember to call Super.PostLoad() first)
	Method PostLoad:Void()
		Local totaltiles% = 0, ts:TileMapTileset
		Local alltiles:DiddyStack<TileMapTile> = New DiddyStack<TileMapTile>
		For Local ts:TileMapTileset = Eachin tilesets.Values()
			' try to load the image from the image bank if we're using the framework
			If diddyGame Then ts.image = diddyGame.images.LoadTileset(ts.imageNode.source, ts.tileWidth, ts.tileHeight, ts.margin, ts.spacing, "", False, True)
			If ts.image Then
				' get the cell count
				ts.tileCount = ts.image.tileCount
				ts.tileCountX = ts.image.tileCountX
				ts.tileCountY = ts.image.tileCountY
			Else
				' if we couldn't get the image, load it with LoadImage
				ts.rawImage = LoadImage(ts.imageNode.source)
				If ts.rawImage Then
					ts.tileCountX = (ts.rawImage.Width() - ts.margin) / (ts.tileWidth + ts.spacing)
					ts.tileCountY = (ts.rawImage.Height() - ts.margin) / (ts.tileHeight + ts.spacing)
					ts.tileCount = ts.tileCountX * ts.tileCountY
				Else
					Print "Couldn't find tileset image: "+ts.imageNode.source
					Return
				End
			End
			
			' update max tile size
			If maxTileWidth < ts.tileWidth Then maxTileWidth = ts.tileWidth
			If maxTileHeight < ts.tileHeight Then maxTileHeight = ts.tileHeight
			
			' build tile list
			ts.tiles = New TileMapTile[ts.tileCount]
			For Local t:TileMapTile = Eachin ts.tileNodes
				ts.tiles[t.id] = t
			Next
			For Local i% = 0 Until ts.tiles.Length
				If ts.tiles[i] = Null Then
					ts.tiles[i] = CreateTile(i)
				End
				ts.tiles[i].gid = ts.firstGid + i
				ts.tiles[i].image = ts.image
				ts.tiles[i].rawImage = ts.rawImage
				ts.tiles[i].width = ts.tileWidth
				ts.tiles[i].height = ts.tileHeight
				' if we're using the raw image we need to precache some stuff
				If ts.rawImage Then
					ts.tiles[i].srcX = ts.margin + (ts.tileWidth + ts.spacing) * (i Mod ts.tileCountX)
					ts.tiles[i].srcY = ts.margin + (ts.tileHeight + ts.spacing) * (i / ts.tileCountX)
				End
				alltiles.Push(ts.tiles[i])
			Next
			' update total tiles
			totaltiles += ts.tileCount
		Next
		
		' make our cache
		tiles = New TileMapTile[totaltiles]
		For Local t:TileMapTile = Eachin alltiles
			tiles[t.gid - 1] = t
		Next
		
		' calculate the max tile size per layer
		For Local l:TileMapLayer = Eachin layers
			If TileMapTileLayer(l) <> Null Then
				Local tl:TileMapTileLayer = TileMapTileLayer(l)
				For Local i% = 0 Until tl.mapData.tiles.Length
					If tl.mapData.tiles[i] > 0 Then
						If tl.maxTileWidth < tiles[tl.mapData.tiles[i] - 1].width Then tl.maxTileWidth = tiles[tl.mapData.tiles[i] - 1].width
						If tl.maxTileHeight < tiles[tl.mapData.tiles[i] - 1].height Then tl.maxTileHeight = tiles[tl.mapData.tiles[i] - 1].height
					End
				Next
			End
		Next
	End
	
	Method GetAllObjects:DiddyStack<TileMapObject>()
		Local rv:DiddyStack<TileMapObject> = New DiddyStack<TileMapObject>
		For Local layer:TileMapLayer = Eachin layers
			If TileMapObjectLayer(layer) <> Null Then
				For Local obj:TileMapObject = Eachin TileMapObjectLayer(layer).objects
					rv.Push(obj)
				Next
			End
		Next
		Return rv
	End
	
	Method FindObjectByName:TileMapObject(name:String)
		For Local layer:TileMapLayer = Eachin layers
			If TileMapObjectLayer(layer) <> Null Then
				For Local obj:TileMapObject = Eachin TileMapObjectLayer(layer).objects
					If obj.name = name Then Return obj
				Next
			Endif
		Next
		Return Null
	End
	
	Method RenderLayer:Void(layerName:String, bx:Int, by:Int, bw:Int, bh:Int, sx:Float = 1, sy:Float = 1, offsetX:Float=0, offsetY:Float=0)
		Local layer:TileMapLayer
		For Local l:TileMapLayer = Eachin layers
			If l.name.ToUpper() = layerName.ToUpper()
				layer = l
				Exit
			End
		End
		RenderLayer(layer, bx, by, bw, bh, sx, sy, offsetX, offsetY)
	End
	
	' bx,by: top-left corner of the viewport
	' bw,bh: dimensions of the viewport
	' sx,xy: scale when rendering tiles
	' offsetX,offsetY: the point in the UNSCALED map that should appear in the top-left corner
	' tiles will be rendered as if the target location were 0,0 in the viewport, and the scaling handle is at offsetX, offsetY
	Method RenderLayer:Void(layer:TileMapLayer, bx:Int, by:Int, bw:Int, bh:Int, sx:Float = 1, sy:Float = 1, offsetX:Float=0, offsetY:Float=0)
		If layer.visible And TileMapTileLayer(layer) <> Null Then
			Local tl:TileMapTileLayer = TileMapTileLayer(layer)
			Local mapTile:TileMapTile, gid%
			PreRenderLayer(layer)
			PushMatrix
			Translate bx, by
			Scale sx, sy
			' ortho
			If orientation = MAP_ORIENTATION_ORTHOGONAL Then
				' size of the scaled tiles
				Local scaledTileWidth:Float = tl.maxTileWidth * sx
				Local scaledTileHeight:Float = tl.maxTileHeight * sy
				' the range of tiles that are visible, based on the scale and parallax
				Local startMapX:Int = (offsetX * tl.parallaxScaleX / tl.maxTileWidth) - 1
				Local startMapY:Int = (offsetY * tl.parallaxScaleY / tl.maxTileHeight) - 1
				Local endMapX:Int = startMapX + (bw / scaledTileWidth) + 2
				Local endMapY:Int = startMapY + (bh / scaledTileHeight) + 2
				'Print "x,y,x,y="+startMapX+","+startMapY+","+endMapX+","+endMapY
				' loop on potentially visible tiles (y direction)
				For Local my:Int = startMapY To endMapY
					Local my2:Int = my
					' wrap y direction if necessary
					If wrapY Or tl.wrapY Then
						While my2 < 0; my2 += height; End
						While my2 >= height; my2 -= height; End
					End
					' loop on potentially visible tiles (x direction)
					For Local mx:Int = startMapX To endMapX
						Local mx2:Int = mx
						' wrap x direction if necessary
						If wrapX Or tl.wrapX Then
							While mx2 < 0; mx2 += width; End
							While mx2 >= width; mx2 -= width; End
						End
						' check the range
						If mx2 >= 0 And mx2 < width And my2 >= 0 And my2 < height Then
							' get the global id
							Local gid:Int = tl.mapData.cells[mx2 + my2*tl.mapData.width].gid
							' if we have an id
							If gid > 0 Then
								' get the tile
								Local mapTile:TileMapTile = tiles[gid-1]
								' work out the render position based on tile sizes, parallax, and offset
								' rendering scale is handled automatically by the transformation matrix
								Local rx:Int = mx * tl.maxTileWidth - offsetX * tl.parallaxScaleX
								Local ry:Int = my * tl.maxTileHeight - offsetY * tl.parallaxScaleY
								DrawTile(tl, mapTile, rx, ry)
							End
						End
					Next
				Next
			
			' iso
			Elseif orientation = MAP_ORIENTATION_ISOMETRIC Then
				' TODO: wrapping
				For Local y:Int = 0 Until tl.width + tl.height
					Local ry:Int = y
					Local rx:Int = 0
					While ry >= tl.height
						ry -= 1
						rx += 1
					Wend
					While ry >= 0 And rx < tl.width
						Local gid:Int = tl.mapData.cells[rx + ry*tl.mapData.width].gid
						If gid > 0 Then
							Local mapTile:TileMapTile = tiles[gid - 1]
							DrawTile(tl, mapTile, (rx - ry - 1) * tileWidth / 2 - bx, (rx + ry + 2) * tileHeight / 2 - mapTile.height - by)
						Endif
						ry -= 1
						rx += 1
					End
				Next
			End
			PopMatrix
			PostRenderLayer(layer)
		End
	End
	
	' bx,by,bw,bh = render bounds (screen)
	' sx,sy = scale x/y (float, defaults to 1) i'll do this later
	' wx,wy = wrap x/y (boolean, defaults to false)
	Method RenderMap:Void(bx:Int, by:Int, bw:Int, bh:Int, sx:Float = 1, sy:Float = 1, offsetX:Float=0, offsetY:Float=0, layerName:String = "ALL", scissor:Bool=True)
		PreRenderMap()
		
		If scissor Then
			If diddyGame Then
				SetScissor(bx*SCREENX_RATIO, by*SCREENY_RATIO, bw*SCREENX_RATIO, bh*SCREENY_RATIO)
			Else
				Local matrix:Float[] = GetMatrix()
				SetScissor(bx * matrix[0] + matrix[4], by * matrix[3] + matrix[5], bw * matrix[0], bh * matrix[3])
			End
		End
		
		If layerName = "ALL" Then
			For Local layer:TileMapLayer = Eachin layers
				RenderLayer(layer, bx, by, bw, bh, sx, sy, offsetX, offsetY)
			Next
		Else
			Local layer:TileMapLayer
			For Local l:TileMapLayer = Eachin layers
				If l.name.ToUpper() = layerName.ToUpper()
					layer = l
					Exit
				End
			End
			RenderLayer(layer, bx, by, bw, bh, sx, sy, offsetX, offsetY)
		End
		
		If scissor Then SetScissor(0, 0, DeviceWidth(), DeviceHeight())
		
		PostRenderMap()
	End
	
	Method GetBounds:TileMapRect()
		Local rv:TileMapRect = New TileMapRect
		If orientation = MAP_ORIENTATION_ORTHOGONAL Then
			rv.x = 0
			rv.y = tileHeight - maxTileHeight
			rv.w = (width - 1) * tileWidth + maxTileWidth
			rv.h = (height - 1) * tileHeight + maxTileHeight
		Elseif orientation = MAP_ORIENTATION_ISOMETRIC Then
			rv.x = -height * tileWidth / 2
			rv.y = tileHeight - maxTileHeight
			rv.w = (width - 2) * tileWidth / 2 + maxTileWidth - rv.x
			rv.h = (width + height) * tileHeight / 2 - rv.y
		Endif
		Return rv
	End
	
	Method UpdateAnimation:Void(timePassed:Int)
		Local layer:TileMapLayer, tl:TileMapTileLayer, cell:TileMapCell, t:TileMapTile
		Local cellCount:Int, i:Int, j:Int
		
		' get the layers as an array
		Local layerCount:Int = layers.Count()
		If layerArray.Length < layerCount Then
			layerArray = layers.ToArray()
			layerCount = layerArray.Length
		Else
			layerCount = layers.FillArray(layerArray)
		End
		
		' loop on each layer
		For i = 0 Until layerCount
			' cast
			tl = TileMapTileLayer(layerArray[i])
			
			' if the layer is a tile layer
			If tl <> Null Then
				' loop on each cell
				cellCount = tl.mapData.cells.Length
				For j = 0 Until cellCount
					cell = tl.mapData.cells[j]
					' if the cell exists and has a value
					If cell <> Null And cell.gid > 0 Then
						' get the tile
						t = tiles[cell.gid-1]
						
						' if the direction is 0 (paused), do nothing
						If t <> Null And cell.direction <> 0 Then
							' add our time to the time passed for the cell
							cell.timePassed += timePassed
							
							' if this tile has animation information
							If t.animated Then
								' get the new direction if we have one
								If t.hasAnimDirection Then cell.direction = t.animDirection
								
								' while it's not paused and we're not up to the current frame
								While cell.direction <> 0 And cell.timePassed >= t.animDelay
									' move to the next frame
									cell.timePassed -= t.animDelay
									cell.gid += cell.direction * t.animNext
									
									' get the tile for the new frame
									t = tiles[cell.gid-1]
									
									' if there's animation information, get it
									If t <> Null And t.animated Then
										' if the tile has a direction assigned to it, use it (we might be turning around)
										If t.hasAnimDirection Then cell.direction = t.animDirection
										
									' otherwise, pause and die
									Else
										cell.direction = 0
										Exit
									End
								End
								
							' no animation information, so pause
							Else
								cell.direction = 0
							End
						End
					End
				Next
			End
		Next
	End
	
	'summary: Check a collision using ray casting
	Method CheckCollision:TileCollisionData(startX:Float, startY:Float, endX:Float, endY:Float, layerName:String)
		Local layer:TileMapTileLayer = FindLayerByName(layerName)
		Local x1:Int = startX
		Local y1:Int = startY
		Local x2:Int = endX
		Local y2:Int = endY

		Local deltax:Int = Abs(x2 - x1)
		Local deltay:Int = Abs(y2 - y1)
		
		Local numpixels:Int, d:Int, dinc1:Int, dinc2:Int, xinc1:Int, xinc2:Int, yinc1:Int, yinc2:Int, x:Int, y:Int, i:Int
		Local xx:Int, cx:Int
		Local yy:Int, cy:Int
		Local tile:Int
		
		If deltax >= deltay 
			numpixels = deltax + 1
			d = (2 * deltay) - deltax
			dinc1 = deltay Shl 1
			dinc2 = (deltay - deltax) Shl 1
			xinc1 = 1
			xinc2 = 1
			yinc1 = 0
			yinc2 = 1
		Else 
			numpixels = deltay + 1
			d = (2 * deltax) - deltay
			dinc1 = deltax Shl 1
			dinc2 = (deltax - deltay) Shl 1
			xinc1 = 0
			xinc2 = 1
			yinc1 = 1
			yinc2 = 1
		End
		
		If x1 > x2
			xinc1 = -xinc1
			xinc2 = -xinc2
		End
		
		If y1 > y2 
			yinc1 = -yinc1
			yinc2 = -yinc2
		End
		
		x = x1
		y = y1

		For i = 1 To numpixels
			xx = Floor(x / tileWidth)
			yy = Floor(y / tileHeight)
			tile = layer.mapData.Get(xx, yy)
			' exit when we have a collision
			if tile <> 0 Then
				cx = x
				cy = y
				Exit
			End
			
			If d < 0 
				d = d + dinc1
				x = x + xinc1
				y = y + yinc1
			Else
				d = d + dinc2
				x = x + xinc2
				y = y + yinc2
			End
		
		Next
		Return New TileCollisionData(cx, cy, tile, xx, yy)
	End
		
	'summary:Return the layer for a set name
	Method FindLayerByName:TileMapTileLayer(layerName:String)
		Local layer:TileMapTileLayer
		For Local tl:TileMapLayer = Eachin layers
			If TileMapTileLayer(tl)
				If tl.name = layerName Then layer = TileMapTileLayer(tl); Exit
			End
		Next
		AssertNotNull(layer, "Cannot find layer " + layerName)
		Return layer
	End
	
	'summary: Check to see if a tile is under x and y on layername
	Method CollisionTile:Int(x:Float, y:Float, layerName:String, sx:Float=1, sy:Float=1)
		Local layer:TileMapTileLayer = FindLayerByName(layerName)
		If layer.name <> layerName Then Return 0
		x /= sx; y /= sy
		If x < 0 Or x >= layer.width * tileWidth Or y < 0 Or y >= layer.height * tileHeight Then Return 0
		
		local xx:Int = (Floor(x / tileWidth))
		local yy:Int = (Floor(y / tileHeight))
		
		Return layer.mapData.Get(xx, yy)
	End
	
	'summary: Set a tile cell
	Method SetTile:Void(x:Float, y:Float, tile:Int, layerName:String, sx:Float=1, sy:Float=1)
		Local layer:TileMapTileLayer = FindLayerByName(layerName)
		If layer.name <> layerName Then Return
		x /= sx; y /= sy
		If x < 0 Or x >= layer.width * tileWidth Or y < 0 Or y >= layer.height * tileHeight Then Return
		Local xx:Int = (Floor(x / tileWidth))
		Local yy:Int = (Floor(y / tileHeight))
		layer.mapData.Set(xx, yy, tile)
	End
	
	'summary: Change a tile cell and its frame image
	Method ChangeTile:Void(x:Float, y:Float, tile:Int, layerName:String, sx:Float=1, sy:Float=1)
		Local layer:TileMapTileLayer = FindLayerByName(layerName)

		If layer.name <> layerName Then Return
		x /= sx; y /= sy
		If x < 0 Or x >= layer.width * tileWidth Or y < 0 Or y >= layer.height * tileHeight Then Return
		Local xx:Int = (Floor(x / tileWidth))
		Local yy:Int = (Floor(y / tileHeight))
		layer.mapData.Set(xx, yy, tile)
		Local tmc:TileMapCell = layer.mapData.GetCell(xx, yy)
		tmc.gid = tile
	End	
	
	'summary: Scrolls the map based on the changeX and changeY
	Method Scroll:Void(changeX:Float, changeY:Float)
		If diddyGame Then
			diddyGame.scrollX += changeX
			diddyGame.scrollY += changeY
			
			If diddyGame.scrollX < 0 Then
				diddyGame.scrollX = 0
			Else
				Local maxX:Int = width * tileWidth - SCREEN_WIDTH
				If diddyGame.scrollX > maxX Then diddyGame.scrollX = maxX
			End
			
			If diddyGame.scrollY < 0 Then
				diddyGame.scrollY = 0
			Else
				Local maxY:Int = height * tileHeight - SCREEN_HEIGHT
				If diddyGame.scrollY > maxY Then diddyGame.scrollY = maxY
			End
		End
	End
End

'summary: Simple Collision Data Class
Class TileCollisionData
	Field x:Float, y:Float
	Field tileX:Float, tileY:Float
	Field tile:Int
	
	Method New(x:Float, y:Float, t:Int, tx:Float, ty:Float)
		Self.x = x
		Self.y = y
		Self.tile = t
		Self.tileX = tx
		Self.tileY = ty
	End
End

Class TileMapTileset Implements ITileMapPostLoad
	' attributes
	Field firstGid:Int
	Field name:String
	Field tileWidth:Int
	Field tileHeight:Int
	Field spacing:Int
	Field margin:Int
	Field source:String
	
	' children
	Field imageNode:TileMapImage
	Field tileNodes:DiddyStack<TileMapTile> = New DiddyStack<TileMapTile>
	
	' post load
	Field tiles:TileMapTile[]
	Field image:GameImage
	Field rawImage:Image
	Field tileCount:Int
	Field tileCountX:Int
	Field tileCountY:Int
	
	Method PostLoad:Void()
	End
End


Class TileMapImage Implements ITileMapPostLoad
	' attributes
	Field source$
	Field width%
	Field height%
	Field trans$ = ""
	
	' post-load
	Field transR%, transG%, transB%

	Method PostLoad:Void()
	End
End

'<layer> and <objectgroup>
Class TileMapLayer Extends TileMapPropertyContainer Implements ITileMapPostLoad Abstract
	' attributes
	Field name$
	Field width%
	Field height%
	Field visible% = True
	Field opacity:Float = 1
	
	Method PostLoad:Void()
	End
End



Class TileMapData
	Field width%
	Field height%
	Field tiles:Int[]
	Field cells:TileMapCell[]
	
	Method New(width%, height%)
		Self.width = width
		Self.height = height 
		Self.tiles = New Int[width * height]
		Self.cells = New TileMapCell[width * height]
	End Method
	
	Method Get%(x%, y%)
		Return tiles[x + y * width]
	End
	
	Method Set:Void(x%, y%, gid%)
		tiles[x + y * width] = gid
	End
	
	Method GetCell:TileMapCell(x%, y%)
		Return cells[x + y * width]
	End
	
	Method SetCell:Void(x%, y%, cell:TileMapCell)
		cells[x + y * width] = cell
	End
End



Class TileMapTileLayer Extends TileMapLayer
	Field mapData:TileMapData
	Field maxTileWidth%
	Field maxTileHeight%
	Field parallaxOffsetX# = 0
	Field parallaxOffsetY# = 0
	Field parallaxScaleX# = 1
	Field parallaxScaleY# = 1

	Field wrapX:Bool, wrapY:Bool
End



Class TileMapObjectLayer Extends TileMapLayer
	' attributes
	Field color%
	' children
	Field objects:DiddyStack<TileMapObject> = New DiddyStack<TileMapObject>
End



Class TileMapObject Extends TileMapPropertyContainer
	' attributes
	Field name:String
	Field objectType:String
	Field x:Int
	Field y:Int
	Field width:Int
	Field height:Int
End



Class TileMapProperty
Private
	Field valueType% = 0 ' 0=int, 1=float, 2=bool, 3=string
	Field name$ = ""
	Field rawValue$ = ""

Public
	Method New(name:String="default", value:String="")
		Self.name = name
		Self.rawValue = value
		Self.valueType = 3
	End
	
	Method Set:Void(value:Int)
		rawValue = value
		valueType = 0
	End
	
	Method Set:Void(value:Float)
		rawValue = value
		valueType = 1
	End
	
	Method Set:Void(value:Bool)
		If value Then
			rawValue = "true"
		Else
			rawValue = "false"
		Endif
		valueType = 2
	End
	
	Method Set:Void(value:String)
		rawValue = value
		valueType = 3
	End
	
	Method GetInt:Int()
		Return Int(rawValue)
	End
	
	Method GetFloat:Float()
		Return Float(rawValue)
	End
	
	Method GetBool:Bool()
		Local val:String = rawValue.ToLower()
		If val = "true" Or val = "t" Or val = "y" Then Return True
		Return False
	End
	
	Method GetString:String()
		Return rawValue
	End
End



Class TileMapTile Extends TileMapPropertyContainer Implements ITileMapPostLoad
	Field id%
	Field width:Int
	Field height:Int
	Field gid:Int
	
	Field animDelay:Int
	Field animNext:Int
	Field animDirection:Int
	Field hasAnimDirection:Bool
	Field animated:Bool
	
	' assigned from the tileset
	Field image:GameImage
	Field rawImage:Image
	Field srcX:Int
	Field srcY:Int
	
	Method New(id:Int)
		Self.id = id
	End
	
	Method PostLoad:Void()
		If properties.Has(PROP_TILE_ANIM_DELAY) Then
			If diddyGame Then
				animDelay = diddyGame.CalcAnimLength(properties.Get(PROP_TILE_ANIM_DELAY).GetInt())
			Else
				animDelay = properties.Get(PROP_TILE_ANIM_DELAY).GetInt()
			End
			animated = True
		End
		If properties.Has(PROP_TILE_ANIM_NEXT) Then animNext = properties.Get(PROP_TILE_ANIM_NEXT).GetInt()
		If properties.Has(PROP_TILE_ANIM_DIRECTION) Then
			animDirection = properties.Get(PROP_TILE_ANIM_DIRECTION).GetInt()
			hasAnimDirection = True
		End
	End
End



Class TileMapCell
	' mandatory fields
	Field gid%
	Field x%
	Field y%
	
	' animation stuff
	Field originalGid%
	Field timePassed:Int = 0 ' the time that has passed since the last frame change
	Field direction% = 1 ' >0 = forward, <0 = backward, 0 = paused

	Method New(gid%, x%, y%)
		Self.gid = gid
		Self.x = x
		Self.y = y
		originalGid = gid
	End
End



Class TileMapRect
	Field x%, y%, w%, h%
End

Function ColorToInt%(str$)
	' TODO: convert a hex color string #rrggbb to a number
	Return 0
End



Function HexToDec%(hexstr$)
	Local chars$ = "0123456789abcdef"
	Local rv% = 0
	hexstr = hexstr.ToLower()
	For Local i% = 0 To hexstr.Length - 1
		rv = rv Shl 4
		Local idx% = chars.Find(hexstr[i])
		If idx >= 0 Then rv += idx
	Next
	Return rv
End

Const PROP_MAP_WRAP_X$ = "wrap_x"
Const PROP_MAP_WRAP_Y$ = "wrap_y"

Const PROP_LAYER_PARALLAX_OFFSET_X$ = "parallax_offset_x"
Const PROP_LAYER_PARALLAX_OFFSET_Y$ = "parallax_offset_y"
Const PROP_LAYER_PARALLAX_SCALE_X$  = "parallax_scale_x"
Const PROP_LAYER_PARALLAX_SCALE_Y$  = "parallax_scale_y"

Const PROP_TILE_ANIM_DELAY$     = "anim_delay"
Const PROP_TILE_ANIM_NEXT$      = "anim_next"
Const PROP_TILE_ANIM_DIRECTION$ = "anim_direction"

Const DATA_ENCODING_RAW$    = ""
Const DATA_ENCODING_CSV$    = "csv"
Const DATA_ENCODING_BASE64$ = "base64"

Const MAP_ORIENTATION_ORTHOGONAL$   = "orthogonal"
Const MAP_ORIENTATION_ISOMETRIC$    = "isometric"

Const ATTR_MAP_VERSION$         = "version"
Const ATTR_MAP_ORIENTATION$     = "orientation"
Const ATTR_MAP_WIDTH$           = "width"
Const ATTR_MAP_HEIGHT$          = "height"
Const ATTR_MAP_TILEWIDTH$       = "tilewidth"
Const ATTR_MAP_TILEHEIGHT$      = "tileheight"
Const ATTR_TILESET_FIRSTGID$    = "firstgid"
Const ATTR_TILESET_NAME$        = "name"
Const ATTR_TILESET_TILEWIDTH$   = "tilewidth"
Const ATTR_TILESET_TILEHEIGHT$  = "tileheight"
Const ATTR_TILESET_SPACING$     = "spacing"
Const ATTR_TILESET_MARGIN$      = "margin"
Const ATTR_TILESET_SOURCE$      = "source"
Const ATTR_IMAGE_SOURCE$        = "source"
Const ATTR_IMAGE_WIDTH$         = "width"
Const ATTR_IMAGE_HEIGHT$        = "height"
Const ATTR_IMAGE_TRANS$         = "trans"
Const ATTR_TILE_ID$             = "id"
Const ATTR_LAYER_NAME$          = "name"
Const ATTR_LAYER_WIDTH$         = "width"
Const ATTR_LAYER_HEIGHT$        = "height"
Const ATTR_LAYER_VISIBLE$       = "visible"
Const ATTR_LAYER_OPACITY$       = "opacity"
Const ATTR_DATA_ENCODING$       = "encoding"
Const ATTR_DATA_COMPRESSION$    = "compression"
Const ATTR_PROPERTY_NAME$       = "name"
Const ATTR_PROPERTY_VALUE$      = "value"
Const ATTR_OBJECTGROUP_COLOR$   = "color"
Const ATTR_OBJECTGROUP_NAME$    = "name"
Const ATTR_OBJECTGROUP_WIDTH$   = "width"
Const ATTR_OBJECTGROUP_HEIGHT$  = "height"
Const ATTR_OBJECT_NAME$         = "name"
Const ATTR_OBJECT_TYPE$         = "type"
Const ATTR_OBJECT_X$            = "x"
Const ATTR_OBJECT_Y$            = "y"
Const ATTR_OBJECT_WIDTH$        = "width"
Const ATTR_OBJECT_HEIGHT$       = "height"

Const NODE_MAP$                 = "map"
Const NODE_TILESET$             = "tileset"
Const NODE_IMAGE$               = "image"
Const NODE_TILE$                = "tile"
Const NODE_LAYER$               = "layer"
Const NODE_DATA$                = "data"
Const NODE_PROPERTIES$          = "properties"
Const NODE_PROPERTY$            = "property"
Const NODE_OBJECTGROUP$         = "objectgroup"
Const NODE_OBJECT$              = "object"
