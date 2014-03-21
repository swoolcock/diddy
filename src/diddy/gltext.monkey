
#If TARGET<>"android"
#Error "The GLText module is only available on the Android"
#End

Import mojo
Import "native/GLText.java"

Extern

Class GLText Extends Null = "GLText"
	Function GetNewInstance:GLText()
	Method Load:bool(file:String, size:Int, padX:Int, padY:Int)
	Method Draw:Void(text:String, x:Float, y:Float)
	Method DrawTexture:Void(x:Float, y:Float)
End