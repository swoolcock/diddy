#Rem
Copyright (c) 2011 Steve Revill and Shane Woolcock
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#End

Strict

Import diddy.framework
Import diddy.functions
Import diddy.collections

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
		
		If diddyGame.debugOn
			Print "screenWidth    = " + sw
			Print "screenHeight   = " + sh
			Print "useAspectRatio = " + useAspect
		End

		diddyGame.SetScreenSize(Int(sw), Int(sh), useAspectBool)
		Local globalElement:XMLElement = rootElement.GetFirstChildByName("global")
		
		Local resourcesElement:XMLElement = globalElement.GetFirstChildByName("resources")
		
		' read the images
		LoadXMLImages(resourcesElement)
		
		'read the sounds
		LoadXMLSounds(resourcesElement)
				
		Local screenElement:XMLElement = rootElement.GetFirstChildByName("screens")
		If screenElement
			For Local node:XMLElement = EachIn screenElement.GetChildrenByName("screen")
				Local name:String = node.GetAttribute("name").Trim()
				Local clazz:String = node.GetAttribute("class").Trim()
				
				If diddyGame.debugOn
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
						Local musicFlag:Int = Int(musicNode.GetAttribute("flag", "0").Trim())
						scr.SetMusic(musicPath, Int(musicFlag))
					End
				Next
				
				Local layersNode:XMLElement = node.GetFirstChildByName("layers")
				If layersNode Then
					For Local layerNode:XMLElement = Eachin layersNode.GetChildrenByName("layer")
						If Not scr.layers Then scr.layers = New DiddyDataLayers
						Local layer:DiddyDataLayer = New DiddyDataLayer
						scr.layers.Add(layer)
						layer.InitFromXML(layerNode)
					Next
				End
				
				If scr.layers Then scr.layers.Sort()
				
				diddyGame.screens.Add(name.ToUpper(), scr)
			Next
		End
	End
	
	Method LoadXMLImages:Void(xmlElement:XMLElement, preLoad:Bool = False, screenName:String = "")
		Local imagesElement:XMLElement = xmlElement.GetFirstChildByName("images")
		If imagesElement <> null Then
			For Local node:XMLElement = Eachin imagesElement.GetChildrenByName("image")
				Local name:String = node.GetAttribute("name").Trim()
				Local path:String = node.GetAttribute("path").Trim()
				Local frames:Int = Int(node.GetAttribute("frames", "0").Trim())
				Local width:Int = Int(node.GetAttribute("width", "0").Trim())
				Local height:Int = Int(node.GetAttribute("height", "0").Trim())
				Local midhandle:String = node.GetAttribute("midhandle").Trim()
				Local ignoreCache:String = node.GetAttribute("ignoreCache").Trim()
				Local readPixels:String = node.GetAttribute("readPixels").Trim()
				Local maskRed:Int = Int(node.GetAttribute("maskRed", "255").Trim())
				Local maskGreen:Int = Int(node.GetAttribute("maskGreen", "0").Trim())
				Local maskBlue:Int = Int(node.GetAttribute("maskBlue", "255").Trim())
				
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
				
				If diddyGame.debugOn
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
					diddyGame.images.LoadAnim(path, width, height, frames, Null, midhandleBool, ignoreCacheBool, name, readPixelsBool, maskRed, maskGreen, maskBlue, preLoad, screenName)
				Else
					diddyGame.images.Load(path, name, midhandleBool, ignoreCacheBool, readPixelsBool, maskRed, maskGreen, maskBlue, preLoad, screenName)
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
				Local soundDelay:String = node.GetAttribute("soundDelay", "0").Trim()
				
				If diddyGame.debugOn
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
				
				diddyGame.sounds.Load(path, name, ignoreCacheBool, Int(soundDelay), preLoad, screenName)
			Next
		End
	End
End

Class DiddyDataLayers Extends ArrayList<DiddyDataLayer>
	Method Find:DiddyDataLayer(name:String)
		name = name.ToLower()
		For Local i:Int = 0 Until Size
			Local layer:DiddyDataLayer = Get(i)
			If layer.name.ToLower() = name Then Return layer
		Next
		Return Null
	End
	
	Method Find:DiddyDataLayer(index:Int)
		For Local i:Int = 0 Until Size
			Local layer:DiddyDataLayer = Get(i)
			If layer.index = index Then Return layer
		Next
		Return Null
	End
	
	Method FindObject:DiddyDataObject(name:String)
		name = name.ToLower()
		For Local i:Int = 0 Until Size
			Local layer:DiddyDataLayer = Get(i)
			Local obj:DiddyDataObject = layer.objects.Find(name)
			If obj Then Return obj
		Next
		Return Null
	End
End

Class DiddyDataLayer Implements IComparable
	Field name:String
	Field index:Int
	Field objects:DiddyDataObjects = New DiddyDataObjects
	
	Method InitFromXML:Void(node:XMLElement)
		name = node.GetAttribute("name", "").Trim()
		index = Int(node.GetAttribute("index", "0").Trim())
		For Local child:XMLElement = Eachin node.GetChildrenByName("object")
			Local obj:DiddyDataObject = New DiddyDataObject
			objects.Add(obj)
			obj.InitFromXML(child)
		Next
	End
	
	Method Compare:Int(other:Object)
		Local ol:DiddyDataLayer = DiddyDataLayer(other)
		If Not ol Or ol = Self Or ol.index = Self.index Then Return 0
		If ol.index < Self.index Then Return 1
		Return -1
	End
	
	Method Equals:Bool(other:Object)
		Return other = Self Or DiddyDataLayer(other) And DiddyDataLayer(other).index = Self.index
	End
	
	Method Render:Void(xoffset:Float=0, yoffset:Float=0)
		For Local obj:DiddyDataObject = EachIn objects
			If obj.visible Then
				obj.Render(xoffset, yoffset)
			End
		Next
	End
End

Class DiddyDataObjects Extends ArrayList<DiddyDataObject>
	Method Find:DiddyDataObject(name:String)
		name = name.ToLower()
		For Local i:Int = 0 Until Size
			Local obj:DiddyDataObject = Get(i)
			If obj.name.ToLower() = name Then Return obj
		Next
		Return Null
	End
End

Class DiddyDataObject
	Field name:String
	
	Field image:GameImage
	Field imageName:String
	
	Field x:Float
	Field y:Float
	Field scaleX:Float
	Field scaleY:Float
	Field rotation:Float
	
	Field visible:Bool = True
	Field alpha:Float = 1
	
	Field red:Int = 255
	Field green:Int = 255
	Field blue:Int = 255
	Field hue:Float = 1
	Field saturation:Float = 1
	Field luminance:Float = 0.5
	Field useHSL:Bool = False
	
	Global rgbArray:Int[] = New Int[3]
	Method InitFromXML:Void(node:XMLElement)
		name = node.GetAttribute("name","").Trim()
		imageName = node.GetAttribute("image","").Trim()
		x = Float(node.GetAttribute("x","0").Trim())
		y = Float(node.GetAttribute("y","0").Trim())
		scaleX = Float(node.GetAttribute("scaleX","1").Trim())
		scaleY = Float(node.GetAttribute("scaleY","1").Trim())
		rotation = Float(node.GetAttribute("rotation","0").Trim())
		
		visible = (node.GetAttribute("visible","true").Trim().ToLower() = "true")
		alpha = Float(node.GetAttribute("alpha","1").Trim())
		
		If node.HasAttribute("hue") Or node.HasAttribute("saturation") Or node.HasAttribute("luminance") Then
			hue = Float(node.GetAttribute("hue","0").Trim())
			saturation = Float(node.GetAttribute("saturation","1").Trim())
			luminance = Float(node.GetAttribute("luminance","0.5").Trim())
			HSLtoRGB(hue, saturation, luminance, rgbArray)
			red = rgbArray[0]
			green = rgbArray[1]
			blue = rgbArray[2]
			useHSL = True
		Else
			red = Int(node.GetAttribute("red","255").Trim())
			green = Int(node.GetAttribute("green","255").Trim())
			blue = Int(node.GetAttribute("blue","255").Trim())
			useHSL = False
		End
	End
	
	Method Render:Void(xoffset:Float=0, yoffset:Float=0)
		If imageName And visible And alpha > 0 Then
			If Not image Then image = diddyGame.images.Find(imageName)
			If image Then
				SetColor(red, green, blue)
				SetAlpha(alpha)
				image.Draw(x+xoffset, y+yoffset, rotation, scaleX, scaleY)
			End
		End
	End
End

