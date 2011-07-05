Import mojo
Import diddy

Class Font
Public
' Public globals

	Global fonts:StringMap<Font>
	
Private
' Private consts

	Const CHAR_COUNT:Int = 128
	
' Private fields

	Field name:String
	Field atlasName:String
	Field blackAtlasName:String
	Field atlas:GameImage
	Field blackAtlas:GameImage
	
	Field srcX:Int[]
	Field srcY:Int[]
	Field srcWidth:Int[]
	Field srcHeight:Int[]
	Field baseline:Float[]
	
Public
' Constructors

	Method New()
		srcX = New Int[CHAR_COUNT]
		srcY = New Int[CHAR_COUNT]
		srcWidth = New Int[CHAR_COUNT]
		srcHeight = New Int[CHAR_COUNT]
		baseline = New Float[CHAR_COUNT]
	End
	
' Public methods

	Method DrawString:Void(str:String, x:Int, y:Int, alignX:Float=0, alignY:Float=0, useBaseline:Bool=True,red:Int=255,green:Int=255,blue:Int=255)
		Local myAtlas:GameImage
		If red = 0 And green = 0 And blue = 0 Then
			SetColor(255,255,255)
			If blackAtlas = Null Then blackAtlas = game.images.Load(blackAtlasName,,False)
			myAtlas = blackAtlas
		Else
			SetColor(red,green,blue)
			If atlas = Null Then atlas = game.images.Load(atlasName,,False)
			myAtlas = atlas
		End
		Local strlen:Int = str.Length
		Local rx:Int = 0
		Local ry:Int = 0 ' TODO: newlines
		Local bl:Float = 0
		Local totalWidth:Int = 0
		Local totalHeight:Int = srcHeight[ASC_UPPER_A]
		For Local i:Int = 0 Until strlen
			If useBaseline Then bl = baseline[str[i]]
			Select str[i]
				Case ASC_SPACE
				Case ASC_LF
				Case ASC_CR
				Default
					
			End
			rx += srcWidth[str[i]]
			If rx > totalWidth Then totalWidth = rx
		Next
		rx = x-alignX*totalWidth
		ry = y-alignY*totalHeight
		For Local i:Int = 0 Until strlen
			If useBaseline Then bl = baseline[str[i]]
			Select str[i]
				Case ASC_SPACE
				Case ASC_LF
				Case ASC_CR
				Default
					myAtlas.DrawSubImage(rx, ry-bl, srcX[str[i]], srcY[str[i]], srcWidth[str[i]], srcHeight[str[i]])
			End
			rx += srcWidth[str[i]]
		Next
	End
	
' Public functions

	Function LoadFonts:Void(doc:XMLDocument)
		fonts = New StringMap<Font>
		Local fontNodes:ArrayList<XMLElement> = doc.Root.GetChildrenByName("font")
		For Local node:XMLElement = EachIn fontNodes
			Local f:Font = New Font
			f.name = node.GetAttribute("name")
			f.atlasName = node.GetAttribute("atlas")
			f.blackAtlasName = node.GetAttribute("blackAtlas")
			Local glyphNodes:ArrayList<XMLElement> = node.GetChildrenByName("glyph")
			For Local glyph:XMLElement = EachIn glyphNodes
				Local code:Int = Int(glyph.GetAttribute("code","0"))
				f.baseline[code] = Float(glyph.GetAttribute("baseline","0"))
				f.srcX[code] = Int(glyph.GetAttribute("srcX","0"))
				f.srcY[code] = Int(glyph.GetAttribute("srcY","0"))
				f.srcWidth[code] = Int(glyph.GetAttribute("srcWidth","0"))
				f.srcHeight[code] = Int(glyph.GetAttribute("srcHeight","0"))
			Next
			fonts.Set(f.name, f)
		Next
	End
End ' Class Font

