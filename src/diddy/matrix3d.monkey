#Rem
Copyright (c) 2011 Steve Revill and Shane Woolcock
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#End

#Rem
Header: Provides a simple 3D matrix.  Integrates with the [[Vector2D]] class.
#End

Strict

Private
Import diddy.vector2d

Public

#Rem
Summary: Provides a simple 3D matrix.  Integrates with the [[Vector2D]] class.
#End
Class Matrix3D
Public
	' +-           -+
	' | M00 M01 M02 |
	' | M10 M11 M12 |
	' | M20 M21 M22 |
	' +-           -+
	Const M00:Int = 0 ' row 0, column 0
	Const M01:Int = 3 ' row 0, column 1
	Const M02:Int = 6 ' row 0, column 2
	Const M10:Int = 1 ' row 1, column 0
	Const M11:Int = 4 ' row 1, column 1
	Const M12:Int = 7 ' row 1, column 2
	Const M20:Int = 2 ' row 2, column 0
	Const M21:Int = 5 ' row 2, column 1
	Const M22:Int = 8 ' row 2, column 2
	
Private
	Field tmp:Float[] = New Float[9]
	
Public
#Rem
Summary: Holds the values of the 3D matrix.  The constants M00 to M22 represent row and column.
The array is thus numbered: [M00, M10, M20, M01, M11, M21, M02, M12, M22]
#End
	Field val:Float[] = New Float[9]
	
#Rem
Summary: Creates a new Matrix3D, initialised to the identity matrix.
See [[Identity]].
#End
	Method New()
		Identity()
	End

#Rem
Summary: Creates a new Matrix3D that is a copy of the passed matrix.
#End
	Method New(matrix:Matrix3D)
		SetToMatrix(matrix)
	End

#Rem
Summary: Sets this matrix to be the identity matrix.
[code]
+-     -+
| 1 0 0 |
| 0 1 0 |
| 0 0 1 |
+-     -+
[/code]
#End
	Method Identity:Matrix3D()
		val[M00] = 1
		val[M10] = 0
		val[M20] = 0
		val[M01] = 0
		val[M11] = 1
		val[M21] = 0
		val[M02] = 0
		val[M12] = 0
		val[M22] = 1
		Return Self
	End

#Rem
Summary: Performs a cross multiplication of this matrix and the passed one.
#End
	Method CrossMultiply:Matrix3D(m:Matrix3D)
		Return CrossMultiply(m.val)
	End
	
#Rem
Summary: Performs a cross multiplication of this matrix and the passed array.
#End
	Method CrossMultiply:Matrix3D(arr:Float[])
		Local v00:Float = val[M00] * arr[M00] + val[M01] * arr[M10] + val[M02] * arr[M20]
		Local v01:Float = val[M00] * arr[M01] + val[M01] * arr[M11] + val[M02] * arr[M21]
		Local v02:Float = val[M00] * arr[M02] + val[M01] * arr[M12] + val[M02] * arr[M22]

		Local v10:Float = val[M10] * arr[M00] + val[M11] * arr[M10] + val[M12] * arr[M20]
		Local v11:Float = val[M10] * arr[M01] + val[M11] * arr[M11] + val[M12] * arr[M21]
		Local v12:Float = val[M10] * arr[M02] + val[M11] * arr[M12] + val[M12] * arr[M22]

		Local v20:Float = val[M20] * arr[M00] + val[M21] * arr[M10] + val[M22] * arr[M20]
		Local v21:Float = val[M20] * arr[M01] + val[M21] * arr[M11] + val[M22] * arr[M21]
		Local v22:Float = val[M20] * arr[M02] + val[M21] * arr[M12] + val[M22] * arr[M22]

		val[M00] = v00
		val[M10] = v10
		val[M20] = v20
		val[M01] = v01
		val[M11] = v11
		val[M21] = v21
		val[M02] = v02
		val[M12] = v12
		val[M22] = v22

		Return Self
	End

#Rem
Summary: Set the matrix to be a pure rotation matrix (no scale or translation).
#End
	Method SetToRotation:Matrix3D(degrees:Float)
		Local cos:Float = Cos(degrees)
		Local sin:Float = Sin(degrees)

		val[M00] = cos
		val[M10] = sin
		val[M20] = 0

		val[M01] = -sin
		val[M11] = cos
		val[M21] = 0

		val[M02] = 0
		val[M12] = 0
		val[M22] = 1

		Return Self
	End

#Rem
Summary: Set the matrix to be a pure translation matrix (no scale or rotation).
#End
	Method SetToTranslation:Matrix3D(x:Float, y:Float)
		val[M00] = 1
		val[M10] = 0
		val[M20] = 0

		val[M01] = 0
		val[M11] = 1
		val[M21] = 0

		val[M02] = x
		val[M12] = y
		val[M22] = 1

		Return Self
	End

#Rem
Summary: Set the matrix to be a pure translation matrix (no scale or rotation).
#End
	Method SetToTranslation:Matrix3D(translation:Vector2D)
		val[M00] = 1
		val[M10] = 0
		val[M20] = 0

		val[M01] = 0
		val[M11] = 1
		val[M21] = 0

		val[M02] = translation.x
		val[M12] = translation.y
		val[M22] = 1

		Return Self
	End

#Rem
Summary: Set the matrix to be a pure scale matrix (no rotation or translation).
#End
	Method SetToScaling:Matrix3D(scaleX:Float, scaleY:Float)
		val[M00] = scaleX
		val[M10] = 0
		val[M20] = 0
		val[M01] = 0
		val[M11] = scaleY
		val[M21] = 0
		val[M02] = 0
		val[M12] = 0
		val[M22] = 1
		Return Self
	End

#Rem
Summary: Calculates and returns the determinant of this matrix.
#End
	Method Determinant:Float()
		Return val[M00] * val[M11] * val[M22] + val[M01] * val[M12] * val[M20] + val[M02] * val[M10] * val[M21] - val[M00] * val[M12] * val[M21] - val[M01] * val[M10] * val[M22] - val[M02] * val[M11] * val[M20]
	End

#Rem
Summary: Inverts the matrix.  Note: The cross product of a matrix and its inverse is the identity matrix.
#End
	Method Inverse:Matrix3D()
		Local d:Float = Determinant()
		If d = 0 Then Return Self
		
		Local inv_det:Float = 1.0 / d

		tmp[M00] = val[M11] * val[M22] - val[M21] * val[M12]
		tmp[M10] = val[M20] * val[M12] - val[M10] * val[M22]
		tmp[M20] = val[M10] * val[M21] - val[M20] * val[M11]
		tmp[M01] = val[M21] * val[M02] - val[M01] * val[M22]
		tmp[M11] = val[M00] * val[M22] - val[M20] * val[M02]
		tmp[M21] = val[M20] * val[M01] - val[M00] * val[M21]
		tmp[M02] = val[M01] * val[M12] - val[M11] * val[M02]
		tmp[M12] = val[M10] * val[M02] - val[M00] * val[M12]
		tmp[M22] = val[M00] * val[M11] - val[M10] * val[M01]

		val[M00] = inv_det * tmp[M00]
		val[M10] = inv_det * tmp[M10]
		val[M20] = inv_det * tmp[M20]
		val[M01] = inv_det * tmp[M01]
		val[M11] = inv_det * tmp[M11]
		val[M21] = inv_det * tmp[M21]
		val[M02] = inv_det * tmp[M02]
		val[M12] = inv_det * tmp[M12]
		val[M22] = inv_det * tmp[M22]

		Return Self
	End

#Rem
Summary: Sets this matrix to be the same as the passed one.
#End
	Method SetToMatrix:Matrix3D(mat:Matrix3D)
		For Local i:Int = 0 Until val.Length
			val[i] = mat.val[i]
		Next
		Return Self
	End

#Rem
Summary: Adjusts the absolute translation of the matrix by the passed vector.
#End
	Method ScalarTranslate:Matrix3D(vector:Vector2D)
		val[M02] += vector.x
		val[M12] += vector.y
		Return Self
	End

#Rem
Summary: Adjusts the absolute translation of the matrix by the passed values.
#End
	Method ScalarTranslate:Matrix3D(x:Float, y:Float)
		val[M02] += x
		val[M12] += y
		Return Self
	End

#Rem
Summary: Translates the matrix by the passed values.
#End
	Method Translate:Matrix3D(x:Float, y:Float)
		tmp[M00] = 1
		tmp[M10] = 0
		tmp[M20] = 0

		tmp[M01] = 0
		tmp[M11] = 1
		tmp[M21] = 0

		tmp[M02] = x
		tmp[M12] = y
		tmp[M22] = 1
		CrossMultiply(tmp)
		Return Self
	End

#Rem
Summary: Translates the matrix by the passed vector.
#End
	Method Translate:Matrix3D(translation:Vector2D)
		tmp[M00] = 1
		tmp[M10] = 0
		tmp[M20] = 0

		tmp[M01] = 0
		tmp[M11] = 1
		tmp[M21] = 0

		tmp[M02] = translation.x
		tmp[M12] = translation.y
		tmp[M22] = 1
		CrossMultiply(tmp)
		Return Self
	End

#Rem
Summary: Rotates the matrix by the passed angle (degrees).
#End
	Method Rotate:Matrix3D(angle:Float)
		If angle = 0 Then Return Self
		Local cos:Float = Cos(angle)
		Local sin:Float = Sin(angle)

		tmp[M00] = cos
		tmp[M10] = sin
		tmp[M20] = 0

		tmp[M01] = -sin
		tmp[M11] = cos
		tmp[M21] = 0

		tmp[M02] = 0
		tmp[M12] = 0
		tmp[M22] = 1
		CrossMultiply(tmp)
		Return Self
	End

#Rem
Summary: Scales the matrix by the passed values.
#End
	Method Scale:Matrix3D(scaleX:Float, scaleY:Float)
		tmp[M00] = scaleX
		tmp[M10] = 0
		tmp[M20] = 0
		tmp[M01] = 0
		tmp[M11] = scaleY
		tmp[M21] = 0
		tmp[M02] = 0
		tmp[M12] = 0
		tmp[M22] = 1
		CrossMultiply(tmp)
		Return Self
	End

#Rem
Summary: Scales the matrix by the passed vector.
#End
	Method Scale:Matrix3D(v:Vector2D)
		tmp[M00] = v.x
		tmp[M10] = 0
		tmp[M20] = 0
		tmp[M01] = 0
		tmp[M11] = v.y
		tmp[M21] = 0
		tmp[M02] = 0
		tmp[M12] = 0
		tmp[M22] = 1
		CrossMultiply(tmp)
		Return Self
	End

#Rem
Summary: Scales the matrix by a scalar value.
#End
	Method ScalarScale:Matrix3D(s:Float)
		val[M00] *= s
		val[M11] *= s
		Return Self
	End

#Rem
Summary: Scales the matrix by a scalar value.
#End
	Method ScalarScale:Matrix3D(v:Vector2D)
		val[M00] *= v.x
		val[M11] *= v.y
		Return Self
	End

#Rem
Summary: Transposes the matrix (values flipped about the diagonal).
#End
	Method Transpose:Matrix3D()
		Local v01:Float = val[M10]
		Local v02:Float = val[M20]
		Local v10:Float = val[M01]
		Local v12:Float = val[M21]
		Local v20:Float = val[M02]
		Local v21:Float = val[M12]
		val[M01] = v01
		val[M02] = v02
		val[M10] = v10
		val[M12] = v12
		val[M20] = v20
		val[M21] = v21
		Return Self
	End
End
