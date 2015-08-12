#Rem
Copyright (c) 2011 Steve Revill and Shane Woolcock
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#End

Strict
Private
Import diddy.tile.renderer
Import xml ' skn3's xml parser has no parent module

Public
Class Skn3TiledTileMapReader Extends TileMapReader
	Field doc:XMLDoc
	
	' Overrides TileMapReader
	Method LoadMap:TileMap(xmlString:String)
		' look for the data encoding, if we cant find it assume its RAW XML and thats just too slow!
		Local findData:Int = xmlString.Find("<data encoding")
		If findData = -1
			Error("Tiled Raw XML is not supported!")
		End
		
		doc = ParseXML(xmlString)
		Return ReadMap(doc)
	End
	
	Method ReadMap:TileMap(node:XMLNode)
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
		If Not node.children.IsEmpty() Then
			For Local mapchild:XMLNode = Eachin node.children
				' tileset
				If mapchild.name = NODE_TILESET Then
					Local ts:TileMapTileset = ReadTileset(mapchild)
					tileMap.tilesets.Set(ts.name, ts)
				
				' tile layer
				Elseif mapchild.name = NODE_LAYER Then
					Local layer:TileMapLayer = ReadTileLayer(mapchild)
					tileMap.layers.Push(layer)
				
				' object layer
				Elseif mapchild.name = NODE_OBJECTGROUP Then
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
	
	Method ReadProperties:Void(node:XMLNode, obj:Object)
		Local cont:TileMapPropertyContainer = TileMapPropertyContainer(obj)
		If cont <> Null Then
			For Local propNode:XMLNode = Eachin node.children
				If propNode.name = NODE_PROPERTIES Then
					For Local child:XMLNode = Eachin propNode.children
						If child.name = NODE_PROPERTY Then
							Local prop:TileMapProperty = ReadProperty(child)
							cont.properties.props.Set(prop.name, prop)
						Endif
					Next
					Return
				End
			Next
		End
	End
	
	Method ReadProperty:TileMapProperty(node:XMLNode)
		Return New TileMapProperty(node.GetAttribute(ATTR_PROPERTY_NAME, "default"), node.GetAttribute(ATTR_PROPERTY_VALUE, ""))
	End
	
	Method ReadTileset:TileMapTileset(node:XMLNode, target:TileMapTileset=Null)
		Local rv:TileMapTileset = target
		ReadProperties(node, rv)
		If rv = Null Then rv = tileMap.CreateTileset()
		If node.HasAttribute(ATTR_TILESET_FIRSTGID) Then rv.firstGid = Int(node.GetAttribute(ATTR_TILESET_FIRSTGID))
		
		If node.HasAttribute(ATTR_TILESET_SOURCE) Then
			rv.source = node.GetAttribute(ATTR_TILESET_SOURCE)
			Local parser:XMLParser = New XMLParser
			Local tilesetdoc:XMLDoc = ParseXML(rv.source)
			Return ReadTileset(tilesetdoc, rv)
		Else
			If node.HasAttribute(ATTR_TILESET_NAME) Then rv.name = node.GetAttribute(ATTR_TILESET_NAME)
			If node.HasAttribute(ATTR_TILESET_TILEWIDTH) Then rv.tileWidth = Int(node.GetAttribute(ATTR_TILESET_TILEWIDTH))
			If node.HasAttribute(ATTR_TILESET_TILEHEIGHT) Then rv.tileHeight = Int(node.GetAttribute(ATTR_TILESET_TILEHEIGHT))
			If node.HasAttribute(ATTR_TILESET_SPACING) Then rv.spacing = Int(node.GetAttribute(ATTR_TILESET_SPACING))
			If node.HasAttribute(ATTR_TILESET_MARGIN) Then rv.margin = Int(node.GetAttribute(ATTR_TILESET_MARGIN))
		
			If Not node.children.IsEmpty() Then
				For Local child:XMLNode = Eachin node.children
					If child.name = NODE_IMAGE Then
						rv.imageNode = ReadImage(child)
					Elseif child.name = NODE_TILE Then
						rv.tileNodes.Push(ReadTile(child))
					End
				Next
			End
		End
		DoPostLoad(rv)
		Return rv
	End
	
	Method ReadLayerAttributes:Void(node:XMLNode, layer:TileMapLayer)
		If node.HasAttribute(ATTR_LAYER_NAME) Then layer.name = node.GetAttribute(ATTR_LAYER_NAME)
		If node.HasAttribute(ATTR_LAYER_WIDTH) Then layer.width = Int(node.GetAttribute(ATTR_LAYER_WIDTH))
		If node.HasAttribute(ATTR_LAYER_HEIGHT) Then layer.height = Int(node.GetAttribute(ATTR_LAYER_HEIGHT))
		layer.visible = Not node.HasAttribute(ATTR_LAYER_VISIBLE) Or Int(node.GetAttribute(ATTR_LAYER_VISIBLE)) <> 0
		If node.HasAttribute(ATTR_LAYER_OPACITY) Then layer.opacity = Float(node.GetAttribute(ATTR_LAYER_OPACITY))
	End
	
	Method ReadTileLayer:TileMapTileLayer(node:XMLNode)
		Local rv:TileMapTileLayer = tileMap.CreateTileLayer()
		ReadProperties(node, rv)
		ReadLayerAttributes(node, rv)
		
		If rv.properties.Has(PROP_LAYER_PARALLAX_OFFSET_X) Then rv.parallaxOffsetX = rv.properties.Get(PROP_LAYER_PARALLAX_OFFSET_X).GetFloat()
		If rv.properties.Has(PROP_LAYER_PARALLAX_OFFSET_Y) Then rv.parallaxOffsetY = rv.properties.Get(PROP_LAYER_PARALLAX_OFFSET_Y).GetFloat()
		If rv.properties.Has(PROP_LAYER_PARALLAX_SCALE_X) Then rv.parallaxScaleX = rv.properties.Get(PROP_LAYER_PARALLAX_SCALE_X).GetFloat()
		If rv.properties.Has(PROP_LAYER_PARALLAX_SCALE_Y) Then rv.parallaxScaleY = rv.properties.Get(PROP_LAYER_PARALLAX_SCALE_Y).GetFloat()
		If rv.properties.Has(PROP_MAP_WRAP_X) Then rv.wrapX = rv.properties.Get(PROP_MAP_WRAP_X).GetBool()
		If rv.properties.Has(PROP_MAP_WRAP_Y) Then rv.wrapY = rv.properties.Get(PROP_MAP_WRAP_Y).GetBool()
		
		For Local child:XMLNode = Eachin node.children
			If child.name = NODE_DATA Then
				rv.mapData = ReadTileData(child, rv)
			End
		Next
		
		DoPostLoad(rv)
		Return rv
	End
	
	Method ReadObjectLayer:TileMapObjectLayer(node:XMLNode)
		Local rv:TileMapObjectLayer = tileMap.CreateObjectLayer()
		ReadProperties(node, rv)
		ReadLayerAttributes(node, rv)
		
		If node.HasAttribute(ATTR_OBJECTGROUP_COLOR) Then rv.color = ColorToInt(node.GetAttribute(ATTR_OBJECTGROUP_COLOR))
		
		For Local child:XMLNode = Eachin node.children
			If child.name = NODE_OBJECT Then
				rv.objects.Push(ReadObject(child, rv))
			End
		Next
		
		DoPostLoad(rv)
		Return rv
	End
	
	Method ReadImage:TileMapImage(node:XMLNode)
		Local rv:TileMapImage = tileMap.CreateImage()
		ReadProperties(node, rv)
		
		If node.HasAttribute(ATTR_IMAGE_SOURCE) Then rv.source = graphicsPath + _StripDir(node.GetAttribute(ATTR_IMAGE_SOURCE))
		If node.HasAttribute(ATTR_IMAGE_WIDTH) Then rv.width = Int(node.GetAttribute(ATTR_IMAGE_WIDTH))
		If node.HasAttribute(ATTR_IMAGE_HEIGHT) Then rv.height = Int(node.GetAttribute(ATTR_IMAGE_HEIGHT))
		If node.HasAttribute(ATTR_IMAGE_TRANS) Then rv.trans = node.GetAttribute(ATTR_IMAGE_TRANS)
		If rv.trans.Length > 0 Then
			rv.transR = _HexToDec(rv.trans[0..2])
			rv.transG = _HexToDec(rv.trans[2..4])
			rv.transB = _HexToDec(rv.trans[4..6])
		Endif
		
		DoPostLoad(rv)
		Return rv
	End
	
	Method ReadTile:TileMapTile(node:XMLNode)
		Local id:Int = Int(node.GetAttribute(ATTR_TILE_ID, "0"))
		Local rv:TileMapTile = tileMap.CreateTile(id)
		ReadProperties(node, rv)
		DoPostLoad(rv)
		Return rv
	End
	
	Method ReadObject:TileMapObject(node:XMLNode, layer:TileMapObjectLayer)
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
	
	Method ReadTileData:TileMapData(node:XMLNode, layer:TileMapTileLayer)
		Local rv:TileMapData = tileMap.CreateData(layer.width, layer.height)
		
		' default to raw xml (ugly)
		Local encoding$ = node.GetAttribute(ATTR_DATA_ENCODING, DATA_ENCODING_RAW)
		If encoding = DATA_ENCODING_RAW Then
			' TODO: raw xml
			Print("Raw xml is currently not supported")
		Elseif encoding = DATA_ENCODING_CSV Then
			Local csv:String[] = node.value.Split(",")
			For Local i% = 0 Until csv.Length
				Local gid:Int = Int(csv[i].Trim())
				rv.tiles[i] = gid
				rv.cells[i] = tileMap.CreateCell(gid, i Mod rv.width, i / rv.width)
			Next
		Elseif encoding = DATA_ENCODING_BASE64 Then
			Local bytes:Int[] = DecodeBase64Bytes(node.value)
			If node.HasAttribute(ATTR_DATA_COMPRESSION) Then
				' TODO: compression
				Print("Compression is currently not supported")
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

Private
' taken from os.monkey to avoid the import
Function _StripDir$( path$ )
	Local i%=path.FindLast( "/" )
	If i=-1 i=path.FindLast( "\" )
	If i<>-1 Return path[i+1..]
	Return path
End
