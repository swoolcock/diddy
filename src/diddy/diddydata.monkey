Strict

Import framework
Import collections

Class DiddyData
	Method New(filename:String="diddydata.xml")
		Local str:String = LoadString(filename)
		If Not str Then
			Throw New DiddyException("Cannot load diddydata file: "+filename)
		End
		
		' parse the xml
		Local parser:XMLParser = New XMLParser
		Local doc:XMLDocument = parser.ParseString(str)
		Local rootElement:XMLElement = doc.Root
		
		Local sw:String = rootElement.GetAttribute("screenWidth").Trim()
		If not sw Then sw = 640

		Local sh:String = rootElement.GetAttribute("screenHeight").Trim()
		If not sh Then sh = 480

		Local useAspect:String = rootElement.GetAttribute("useAspectRatio").Trim()
		Local useAspectBool:Bool = useAspect And useAspect.ToLower() = "true"
		
		If game.debugOn
			Print "screenWidth    = " + sw
			Print "screenHeight   = " + sh
			Print "useAspectRatio = " + useAspect
		End

		game.SetScreenSize(Int(sw), Int(sh), useAspectBool)
		Local globalElement:XMLElement = rootElement.GetFirstChildByName("global")
		
		Local resourcesElement:XMLElement = globalElement.GetFirstChildByName("resources")
		
		' read the images
		LoadXMLImages(resourcesElement)
		
		'read the sounds
		LoadXMLSounds(resourcesElement)
				
		Local screenElement:XMLElement = rootElement.GetFirstChildByName("screens")
		For Local node:XMLElement = EachIn screenElement.GetChildrenByName("screen")
			Local name:String = node.GetAttribute("name").Trim()
			Local clazz:String = node.GetAttribute("class").Trim()
			
			If game.debugOn
				Print "name  = " + name
				Print "class = " + clazz
			End
			Local ci:ClassInfo = GetClass(clazz)
			Local scr:Screen = Screen(ci.NewInstance())
			scr.name = name
			
			For Local resourcesNode:XMLElement = Eachin node.GetChildrenByName("resources")
				LoadXMLImages(resourcesNode, True, scr.name)
				LoadXMLSounds(resourcesNode, True, scr.name)
				
				Local musicNode:XMLElement = resourcesNode.GetFirstChildByName("music")
				If musicNode <> Null Then
					Local musicPath:String = musicNode.GetAttribute("path").Trim()
					Local musicFlag:Int = Int(musicNode.GetAttribute("flag").Trim())
					scr.SetMusic(musicPath, Int(musicFlag))
				End
			Next
			
			For Local layerNode:XMLElement = Eachin node.GetChildrenByName("layers")
				If Not scr.layers Then scr.layers = New ArrayList<DiddyDataLayer>
				Local layer:DiddyDataLayer = New DiddyDataLayer
				layer.name = layerNode.GetAttribute("name").Trim()
				layer.index = Int(layerNode.GetAttribute("index", "0").Trim())
				scr.layers.Add(layer)
			Next
			
			If scr.layers Then scr.layers.Sort()
			
			game.screens.Add(name.ToUpper(), scr)
		Next
	End
	
	Method LoadXMLImages:Void(xmlElement:XMLElement, preLoad:Bool = False, screenName:String = "")
		Local imagesElement:XMLElement = xmlElement.GetFirstChildByName("images")
		If imagesElement <> null Then
			Local tmpImage:Image
			For Local node:XMLElement = Eachin imagesElement.GetChildrenByName("image")
				Local name:String = node.GetAttribute("name").Trim()
				Local path:String = node.GetAttribute("path").Trim()
				Local frames:Int = Int(node.GetAttribute("frames").Trim())
				Local width:Int = Int(node.GetAttribute("width").Trim())
				Local height:Int = Int(node.GetAttribute("height").Trim())
				Local midhandle:String = node.GetAttribute("midhandle").Trim()
				Local ignoreCache:String = node.GetAttribute("ignoreCache").Trim()
				Local readPixels:String = node.GetAttribute("readPixels").Trim()
				Local maskRed:Int = Int(node.GetAttribute("maskRed").Trim())
				Local maskGreen:Int = Int(node.GetAttribute("maskGreen").Trim())
				Local maskBlue:Int = Int(node.GetAttribute("maskBlue").Trim())
				
				Local midhandleBool:Bool
				If midhandle
					If midhandle.ToUpper() = "TRUE" Then midhandleBool = True Else midhandleBool = False
				Else
					midhandleBool = True
				End
				
				Local ignoreCacheBool:Bool
				If ignoreCache
					If ignoreCache.ToUpper() = "TRUE" Then ignoreCacheBool = True Else ignoreCacheBool = False
				Else
					ignoreCacheBool = False
				End
				
				Local readPixelsBool:Bool
				If readPixels
					If readPixels.ToUpper() = "TRUE" Then readPixelsBool = True Else readPixelsBool = False
				Else
					readPixelsBool = False
				End
				
				If game.debugOn
					Print "name 		= " + name
					Print "path 		= " + path
					Print "frames		= " + frames
					Print "width 		= " + width
					Print "height 		= " + height
					Print "midhandle 	= " + midhandle
					Print "ignoreCache	= " + ignoreCache
				End
				
				' if frames > 1 assume its an animation image
				If frames > 1
					game.images.LoadAnim(path, width, height, frames, tmpImage, midhandleBool, ignoreCacheBool, name, readPixelsBool, maskRed, maskGreen, maskBlue, preLoad, screenName)
				Else
					game.images.Load(path, name, midhandleBool, ignoreCacheBool, readPixelsBool, maskRed, maskGreen, maskBlue, preLoad, screenName)
				End
			Next
		End
	End
	
	Method LoadXMLSounds:Void(xmlElement:XMLElement, preLoad:Bool = False, screenName:String = "")
		Local soundsElement:XMLElement = xmlElement.GetFirstChildByName("sounds")
		If soundsElement <> null Then
			For Local node:XMLElement = EachIn soundsElement.GetChildrenByName("sound")
				Local name:String = node.GetAttribute("name").Trim()
				Local path:String = node.GetAttribute("path").Trim()
				Local ignoreCache:String = node.GetAttribute("ignoreCache").Trim()
				Local soundDelay:String = node.GetAttribute("soundDelay").Trim()
				
				If game.debugOn
					Print "name 		= " + name
					Print "path 		= " + path
					Print "ignoreCache	= " + ignoreCache
					Print "soundDelay	= " + soundDelay
				End
				
				Local ignoreCacheBool:Bool
				If ignoreCache
					If ignoreCache.ToUpper() = "TRUE" Then ignoreCacheBool = True Else ignoreCacheBool = False
				Else
					ignoreCacheBool = False
				End
				
				game.sounds.Load(path, name, ignoreCacheBool, Int(soundDelay), preLoad, screenName)
			Next
		End
	End
End

Class DiddyDataLayer Implements IComparable
	Field name:String
	Field index:Int
	
	Method Compare:Int(other:Object)
		Local ol:DiddyDataLayer = DiddyDataLayer(other)
		If Not ol Or ol = Self Or ol.index = Self.index Then Return 0
		If ol.index < Self.index Then Return 1
		Return -1
	End
	
	Method Equals:Bool(other:Object)
		Return other = Self Or DiddyDataLayer(other) And DiddyDataLayer(other).index = Self.index
	End
	
	Method Render:Void()
		' TODO: render objects
	End
End

Class DiddyDataObject
	Field name:String
	
	Field image:GameImage
	Field imageName:String
End

