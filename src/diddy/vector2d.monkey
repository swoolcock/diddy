#Rem
Copyright (c) 2011 Steve Revill and Shane Woolcock
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#End

Strict

Public

'Summary: 2D Vector Class
Class Vector2D
	Field x:Float
	Field y:Float

	'summary: Constructor
	Method New(x:Float = 0, y:Float = 0)
		Self.x = x
		Self.y = y
	End
	
	'summary: Sets the vector by another vector
	Method Set:Vector2D( vector2:Vector2D ) 
		Self.x = vector2.x
		Self.y = vector2.y 
		Return Self	
	End

	'summary: Sets the vector by the supplied x and y
	Method Set:Vector2D(x:Float, y:Float ) 
		Self.x = x
		Self.y = y
		Return Self	
	End

	'summary: Creates a copy of the Vector2D
	Method CloneVector:Vector2D()
		Return New Vector2D(x, y)
	End
	
	'summary: Swaps x and y around
	Method SwapXY:Vector2D()
		Local tmp:Float = Self.x
		Self.x = Self.y
		Self.y = tmp
		Return Self
	End
	
	'summary: Makes x and y zero
	Method ZeroVector:Vector2D()
		Self.x = 0
		Self.y = 0
		Return Self
	End
	
	'summary: Is this vector zeroed?
	Method IsZero:Bool()
		If Self.x = 0 And Self.y = 0 Then
			Return True
		End
		Return False
	End
	
	'summary: Is the vector's length one?
	Method IsNormalized:Bool()
		If Length = 1.0 Then
			Return True
		End
		Return False
	End
	
	'summary: Does this vector have the same location as another?
	Method Equals:Bool(vector2d:Vector2D)
		If Self.x = vector2d.x And Self.y = vector2d.y Then
			Return True
		End
		Return False
	End
	
	'summary: Sets the length, which will change x and y but not the angle
	Method Length:Void(value:Float) Property
		Local angle:Float = Angle
		Self.x = Cos(angle) * value
		Self.y = Sin(angle) * value
		If Abs(Self.x) < 0.00000001 Then Self.x = 0
		If Abs(Self.y) < 0.00000001 Then Self.y = 0
	End
	
	'summary: Gets the length
	Method Length:Float() Property
		Return Sqrt(LengthSquared)
	End
	
	'summary: Gets the length squared
	Method LengthSquared:Float() Property
		Return Self.x * Self.x + Self.y * Self.y
	End
	
	'summary: Sets the angle
	Method Angle:Void(value:Float) Property
		Local len:Float = Length
		Self.x = Cos(value) * len
		Self.y = Sin(value) * len
	End
	
	'summary: Gets the angle
	Method Angle:Float() Property
		Return ATan2(Self.y, Self.x)
	End
	
	'summary: Set the vector's length to one
	Method Normalize:Vector2D()
		If Length = 0 Then
			Self.x = 1
			Return Self
		End
		Local len:Float = Length
		Self.x /= len
		Self.y /= len
		Return Self
	End
	
	'summary: Sets the vector's length to len
	Method Normalize:Vector2D(len:Float)
		Length = len
		Return Self
	End
	
	'summary: Sets the length under the given value
	Method Truncate:Vector2D(max:Float)
		Length = Min(max, Length)
		Return Self
	End
	
	'summary: Makes the vector face the opposite way
	Method Reverse:Vector2D()
		Self.x = -Self.x
		Self.y = -Self.y
		Return Self
	End
	
	'summary: Calculate the dot product of this vector and another
	Method DotProduct:Float(vector2D:Vector2D)
		Return Self.x * vector2D.x + Self.y * vector2D.y
	End

	'summary: Calculate the cross product of this and another vector
	Method CrossProd:Float(vector2D:Vector2D)
		Return Self.x * vector2D.y - Self.y * vector2D.x
	End
	
	'summary: Calculate angle between any two vectors.
	Function AngleBetween:Float(vector1:Vector2D, vector2:Vector2D)
		If (Not vector1.IsNormalized()) Then vector1 = vector1.CloneVector().Normalize()
		If (Not vector2.IsNormalized()) Then vector2 = vector2.CloneVector().Normalize()
		Return ACos(vector1.DotProduct(vector2))
	End

	'summary: Is the vector to the right or left of this one?
	Method Sign:Int(vector2:Vector2D)
		If Perpendicular.DotProduct(vector2) < 0
			Return -1
		End
		Return 1
	End

	'summary: Get the vector that is perpendicular
	Method Perpendicular:Vector2D() Property
		Return New Vector2D(-y, x)
	End

	'summary: Calculate between two vectors
	Method Distance:Float(vector2:Vector2D)
		Return Sqrt(DistSQ(vector2))
	End

	'summary: Calculate squared distance between vectors. Faster than distance.
	Method DistSQ:Float(vector2:Vector2D)
		Local dx:Float = vector2.x - Self.x
		Local dy:Float = vector2.y - Self.y
		Return dx * dx + dy * dy
	End

	'summary: Add a vector to this vector.
	Method Add:Vector2D(vector2:Vector2D)
		Self.x += vector2.x
		Self.y += vector2.y
		Return Self
	End
	
	'summary: Subtract a vector from this one.
	Method Subtract:Vector2D(vector2:Vector2D)
		Self.x -= vector2.x
		Self.y -= vector2.y
		Return Self
	End
	
	'summary: Mutiplies this vector by a scalar
	Method Multiply:Vector2D(scalar:Float)
		Self.x *= scalar
		Self.y *= scalar
		Return Self
	End
	
	'summary: Divide this vector by a scalar
	Method Divide:Vector2D(scalar:Float)
		Self.x /= scalar
		Self.y /= scalar
		Return Self
	End
	
	'summary: Turn this vector into a string.
	Method ToString:String()
		Return "Vector2D x:" + Self.x + ", y:" + Self.y
	End
	
	'summary: Calculate distance between two points - overload using x,y
	Method Distance:Float(x:float, y:float)
		Return Sqrt((Self.x-x) * (Self.x-x) + (Self.y-y) * (Self.y-y))
	End
End
