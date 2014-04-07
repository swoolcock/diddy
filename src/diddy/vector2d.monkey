#Rem
Copyright (c) 2011 Steve Revill and Shane Woolcock
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#End

#Rem
Header: Provides a class for handling vectors in 2D-space.
#End

Strict

Public

#Rem
Summary: The Vector2D class allows the developer to represent a position on direction in 2D-space, and to then perform translations and other operations.
#End
Class Vector2D

#Rem
Summary: The X coordinate of the Vector2D.
#End
	Field x:Float
	
#Rem
Summary: The Y coordinate of the Vector2D.
#End
	Field y:Float

#Rem
Summary: Creates a new instance of Vector2D with an optional value for x and y.  Default for both is 0.
[code]
New Vector2D ' x,y = 0,0
New Vector2D(10,-15) ' x,y = 10,-15
[/code]
#End
	Method New(x:Float = 0, y:Float = 0)
		Self.x = x
		Self.y = y
	End
	
#Rem
Summary: Sets the X and Y values of this Vector2D to be the same as the passed Vector2D.
[code]
Local v1:Vector2D = New Vector2D(10,20)
Local v2:Vector2D = New Vector2D(30,40)
v1.Set(v2) ' v1 is now (30,40)
[/code]
#End
	Method Set:Vector2D( vector2:Vector2D ) 
		Self.x = vector2.x
		Self.y = vector2.y 
		Return Self	
	End

#Rem
Summary: Sets the X and Y values of this Vector2D.
[code]
Local v:Vector2D = New Vector2D(10,20)
v.Set(30,40) ' v is now (30,40)
[/code]
#End
	Method Set:Vector2D(x:Float, y:Float ) 
		Self.x = x
		Self.y = y
		Return Self	
	End

#Rem
Summary: Creates a copy of this Vector2D having the same X and Y coordinates.
[code]
Local v1:Vector2D = New Vector2D(10,20)
Local v2:Vector2D = v1.CloneVector() ' v2 is a new instance of Vector2D with the values (10,20)
[/code]
#End
	Method CloneVector:Vector2D()
		Return New Vector2D(x, y)
	End
	
#Rem
Summary: Swaps the X and Y coordinates of this Vector2D.
[code]
Local v:Vector2D = New Vector2D(10,20)
v.SwapXY() ' v is now (20,10)
[/code]
#End
	Method SwapXY:Vector2D()
		Local tmp:Float = Self.x
		Self.x = Self.y
		Self.y = tmp
		Return Self
	End
	
#Rem
Summary: Sets the values of this Vector2D to be the zero vector (0,0).
[code]
Local v:Vector2D = New Vector2D(10,20)
v.ZeroVector() ' v is now (0,0)
[/code]
#End
	Method ZeroVector:Vector2D()
		Self.x = 0
		Self.y = 0
		Return Self
	End
	
#Rem
Summary: Returns True if this is the zero vector (0,0).
#End
	Method IsZero:Bool()
		If Self.x = 0 And Self.y = 0 Then
			Return True
		End
		Return False
	End
	
#Rem
Summary: Returns True if this Vector2D is normalized (it has a length of 1).
#End
	Method IsNormalized:Bool()
		If Length = 1.0 Then
			Return True
		End
		Return False
	End
	
#Rem
Summary: Returns True if this Vector2D has the same values as the passed one.
#End
	Method Equals:Bool(vector2d:Vector2D)
		If Self.x = vector2d.x And Self.y = vector2d.y Then
			Return True
		End
		Return False
	End
	
#Rem
Summary: Sets the length of this Vector2D.  This does not affect the angle returned by [[Angle]].
#End
	Method Length:Void(value:Float) Property
		Local angle:Float = Angle
		Self.x = Cos(angle) * value
		Self.y = Sin(angle) * value
		If Abs(Self.x) < 0.00000001 Then Self.x = 0
		If Abs(Self.y) < 0.00000001 Then Self.y = 0
	End
	
#Rem
Summary: Calculates the length of the Vector2D.
Note that if you need to perform any boolean logic on the length, it is more efficient to use the
squared length and compare against another squared value.  This is because the length is calculated
using Pythagoras' theorem, which requires a square root.  See [[LengthSquared]] for more information.
[code]
Local v:Vector2D = New Vector2D(3,4)
Print v.Length ' prints 5
[/code]
#End
	Method Length:Float() Property
		Return Sqrt(LengthSquared)
	End
	
#Rem
Summary: Calculates the squared length of the Vector2D.
This is the preferred method for performing boolean logic, as it does not require a square root
(which is an expensive operation).
[code]
' checking if a the vector's length is greater than or equal to 5
Local v:Vector2D = New Vector2D(3,4)
' using just Length (expensive)
If v.Length >= 5 Then
	' do something
End
' using LengthSquared instead (no square root)
If v.LengthSquared >= 5*5 Then
	' do something
End
[/code]
#End
	Method LengthSquared:Float() Property
		Return Self.x * Self.x + Self.y * Self.y
	End
	
#Rem
Summary: Sets the angle of this Vector2D from the origin, without altering its length.
[code]
Local v:Vector2D = New Vector2D(3,4) ' angle is 53.1 degrees, length is 5
v.Angle = 0 ' angle is 0, length is 5, coordinates are (5,0)
[/code]
#End
	Method Angle:Void(value:Float) Property
		Local len:Float = Length
		Self.x = Cos(value) * len
		Self.y = Sin(value) * len
	End
	
#Rem
Summary: Returns the angle of this Vector2D from the origin.
[code]
Local v:Vector2D = New Vector2D(3,4)
Print v.Angle ' prints 53.1
[/code]
#End
	Method Angle:Float() Property
		Return ATan2(Self.y, Self.x)
	End
	
#Rem
Summary: Adjusts the coordinates of this Vector2D such that its length is 1.  The angle does not change.
[code]
Local v:Vector2D = New Vector2D(3,4) ' angle is 53.1 degrees, length is 5
v.Normalize() ' angle is 53.1 degrees, length is 1, coordinates are (0.6,0.8)
[/code]
#End
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
	
#Rem
Summary: Adjusts the coordinates of this Vector2D such that its length is equal to the passed value.  The angle does not change.
This is the same as the [[Length]] property.
#End
	Method Normalize:Vector2D(len:Float)
		Length = len
		Return Self
	End
	
#Rem
Summary: Adjusts the length to be no longer than the passed value.  If the current length is already less, the vector is not modified.
#End
	Method Truncate:Vector2D(max:Float)
		Length = Min(max, Length)
		Return Self
	End
	
#Rem
Summary: Inverts the X and Y coordinates so that vector points the opposite way.
[code]
Local v:Vector2D = New Vector2D(10,20)
v.Reverse() ' v is now (-10,-20)
[/code]
#End
	Method Reverse:Vector2D()
		Self.x = -Self.x
		Self.y = -Self.y
		Return Self
	End
	
#Rem
Summary: Calculate the dot product of this vector and another.
#End
	Method DotProduct:Float(vector2D:Vector2D)
		Return Self.x * vector2D.x + Self.y * vector2D.y
	End

#Rem
Summary: Calculate the cross product of this and another vector.
#End
	Method CrossProd:Float(vector2D:Vector2D)
		Return Self.x * vector2D.y - Self.y * vector2D.x
	End
	
#Rem
Summary: Calculate the angle between any two vectors.
#End
	Function AngleBetween:Float(vector1:Vector2D, vector2:Vector2D)
		If (Not vector1.IsNormalized()) Then vector1 = vector1.CloneVector().Normalize()
		If (Not vector2.IsNormalized()) Then vector2 = vector2.CloneVector().Normalize()
		Return ACos(vector1.DotProduct(vector2))
	End

#Rem
Summary: Returns 1 if the passed vector is "to the right" of this one, and -1 if it is "to the left".
#End
	Method Sign:Int(vector2:Vector2D)
		If Perpendicular.DotProduct(vector2) < 0
			Return -1
		End
		Return 1
	End

#Rem
Summary: Returns a new Vector2D that is perpendicular to this one.
By default it will always be "to the right" of this one.  See [[Sign]].
#End
	Method Perpendicular:Vector2D() Property
		Return New Vector2D(-y, x)
	End

#Rem
Summary: Returns the distance between this point and another.
[code]
Local v1:Vector2D = New Vector2D(1,2)
Local v2:Vector2D = New Vector2D(4,6)
Print v1.Distance(v2) ' prints 5
[/code]
#End
	Method Distance:Float(vector2:Vector2D)
		Return Sqrt(DistSQ(vector2))
	End

#Rem
Summary: Returns the squared distance between this point and another.
See [[Length]] and [[LengthSquared]] as to why this method may sometimes be preferable to [[Distance]].
#End
	Method DistSQ:Float(vector2:Vector2D)
		Local dx:Float = vector2.x - Self.x
		Local dy:Float = vector2.y - Self.y
		Return dx * dx + dy * dy
	End

#Rem
Summary: Performs a vector addition on this vector, using the passed value as the other operand.
[code]
Local v1:Vector2D = New Vector2D(10,20)
Local v2:Vector2D = New Vector2D(30,40)
v1.Add(v2) ' v1 is now (40,60)
[/code]
#End
	Method Add:Vector2D(vector2:Vector2D)
		Self.x += vector2.x
		Self.y += vector2.y
		Return Self
	End
	
#Rem
Summary: Performs a vector subtraction on this vector, using the passed value as the other operand.
[code]
Local v1:Vector2D = New Vector2D(10,20)
Local v2:Vector2D = New Vector2D(30,40)
v1.Subtract(v2) ' v1 is now (-20,-20)
[/code]
#End
	Method Subtract:Vector2D(vector2:Vector2D)
		Self.x -= vector2.x
		Self.y -= vector2.y
		Return Self
	End
	
#Rem
Summary: Performs a scalar multiplication on this vector, using the passed value as the other operand.
[code]
Local v:Vector2D = New Vector2D(10,20)
v.Multiply(10) ' v is now (100,200)
[/code]
#End
	Method Multiply:Vector2D(scalar:Float)
		Self.x *= scalar
		Self.y *= scalar
		Return Self
	End
	
#Rem
Summary: Performs a scalar division on this vector, using the passed value as the other operand.
[code]
Local v:Vector2D = New Vector2D(10,20)
v.Divide(2) ' v is now (5,10)
[/code]
#End
	Method Divide:Vector2D(scalar:Float)
		Self.x /= scalar
		Self.y /= scalar
		Return Self
	End
	
#Rem
Summary: Returns a String representation of this Vector2D's coordinates, useful for debugging.
[code]
Local v:Vector2D = New Vector2D(10,20)
Print v.ToString() ' prints "Vector2D x:10, y:20"
Print v ' Monkey automatically calls ToString if an object is passed to Print
[/code]
#End
	Method ToString:String()
		Return "Vector2D x:" + Self.x + ", y:" + Self.y
	End
	
#Rem
Summary: Returns the distance between this point and the passed X and Y coordinates.
[code]
Local v:Vector2D = New Vector2D(1,2)
Print v.Distance(4,6) ' prints 5
[/code]
#End
	Method Distance:Float(x:float, y:float)
		Return Sqrt((Self.x-x) * (Self.x-x) + (Self.y-y) * (Self.y-y))
	End
End
