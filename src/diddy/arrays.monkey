#Rem
Copyright (c) 2011 Steve Revill and Shane Woolcock
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#End

#Rem
Header: The diddy.arrays module provides access to the Arrays utility class.
#End

Strict
Public

#Rem
Summary: The Arrays class provides utility functions for manipulating Monkey arrays.
For example, you could clone the contents of an array, or join multiple arrays into one.
Note: Any functions that copy values are a "shallow copy".  This means that for arrays of objects, only the object *reference* is copied to the new array.  It is still the same object.
#End
Class Arrays<T>

#Rem
Summary: The Join function allows the developer to concatenate up to ten arrays of the same type (but any size) into a single array.
Unused parameters are assumed to be empty arrays.
[code]
' returns a new array [1,2,3,4,5]
Arrays<Int>.Join([1,2,3], [4,5])
[/code]
#End
	Function Join:T[](arr1:T[], arr2:T[], arr3:T[]=[], arr4:T[]=[], arr5:T[]=[], arr6:T[]=[], arr7:T[]=[], arr8:T[]=[], arr9:T[]=[], arr10:T[]=[])
		Local rv:T[] = New T[arr1.Length + arr2.Length + arr3.Length + arr4.Length + arr5.Length + arr6.Length + arr7.Length + arr8.Length + arr9.Length + arr10.Length]
		Local ptr:Int = 0
		If arr1.Length > 0 Then
			For Local i:Int = 0 Until arr1.Length
				rv[i] = arr1[i]
			Next
			ptr += arr1.Length
		End
		If arr2.Length > 0 Then
			For Local i:Int = 0 Until arr2.Length
				rv[i+ptr] = arr2[i]
			Next
			ptr += arr2.Length
		End
		If arr3.Length > 0 Then
			For Local i:Int = 0 Until arr3.Length
				rv[i+ptr] = arr3[i]
			Next
			ptr += arr3.Length
		End
		If arr4.Length > 0 Then
			For Local i:Int = 0 Until arr4.Length
				rv[i+ptr] = arr4[i]
			Next
			ptr += arr4.Length
		End
		If arr5.Length > 0 Then
			For Local i:Int = 0 Until arr5.Length
				rv[i+ptr] = arr5[i]
			Next
			ptr += arr5.Length
		End
		If arr6.Length > 0 Then
			For Local i:Int = 0 Until arr6.Length
				rv[i+ptr] = arr6[i]
			Next
			ptr += arr6.Length
		End
		If arr7.Length > 0 Then
			For Local i:Int = 0 Until arr7.Length
				rv[i+ptr] = arr7[i]
			Next
			ptr += arr7.Length
		End
		If arr8.Length > 0 Then
			For Local i:Int = 0 Until arr8.Length
				rv[i+ptr] = arr8[i]
			Next
			ptr += arr8.Length
		End
		If arr9.Length > 0 Then
			For Local i:Int = 0 Until arr9.Length
				rv[i+ptr] = arr9[i]
			Next
			ptr += arr9.Length
		End
		If arr10.Length > 0 Then
			For Local i:Int = 0 Until arr10.Length
				rv[i+ptr] = arr10[i]
			Next
			ptr += arr10.Length
		End
		Return rv
	End
	
#Rem
Summary: The Fill function will set every element of the passed array to the specified value, then returns the array.
Note that this does not create a new array.  The return value will reference the same array that was passed in.
[code]
' fills the existing array and returns it ["d","d","d"] (it doesn't create a new array)
Arrays<String>.Fill(["a","b","c"], "d")
[/code]
#End
	Function Fill:T[](arr:T[], val:T)
		For Local i:Int = 0 Until arr.Length
			arr[i] = val
		Next
		Return arr
	End
	
#Rem
Summary: The Clone function will create a new array with the same dimensions as the passed array, and copies each value from the old array to the new array.
Note that this is a shallow copy, so objects in the array will not be duplicated.
Only their references will be copied.
[code]
' returns a new array with the same contents [1,2,3]
Arrays<Int>.Clone([1,2,3])
[/code]
#End
	Function Clone:T[](arr:T[])
		Local rv:T[] = New T[arr.Length]
		For Local i:Int = 0 Until arr.Length
			rv[i] = arr[i]
		Next
		Return rv
	End
	
#Rem
Summary: The Copy function will copy a range of values between two arrays (or within the same array).
[code]
' copies 2 values from index 1 in src to index 2 in dest. dest now contains [5,6,2,3]
Arrays<Int>.Copy([1,2,3,4], 1, [5,6,7,8], 2, 2)
[/code]
#End
	Function Copy:Void(src:T[], srcPos:Int, dest:T[], destPos:Int, length:Int)
		If length = 0 Then Return
		If length < 0 Then Error("Arrays.Copy: length < 0")
		If srcPos < 0 Then Error("Arrays.Copy: srcPos < 0")
		If destPos < 0 Then Error("Arrays.Copy: destPos < 0")
		If srcPos >= src.Length Then Error("Arrays.Copy: srcPos ("+srcPos+") >= src.Length ("+src.Length+")")
		If destPos >= dest.Length Then Error("Arrays.Copy: destPos ("+destPos+") >= dest.Length ("+dest.Length+")")
		If srcPos + length > src.Length Then Error("Arrays.Copy: srcPos ("+srcPos+") + length ("+length+") > src.Length ("+src.Length+")")
		If destPos + length > dest.Length Then Error("Arrays.Copy: destPos ("+destPos+") + length ("+length+") > dest.Length ("+dest.Length+")")
		
		' if dest is after src, copy in reverse to avoid overwriting if it's the same array
		If destPos > srcPos Then
			For Local i:Int = length-1 To 0 Step -1
				dest[destPos+i] = src[srcPos+i]
			Next
		Else
			For Local i:Int = 0 Until length
				dest[destPos+i] = src[srcPos+i]
			Next
		End
	End
	
#Rem
Summary: The Slice function will return a new array which contains some or all of the passed array.
[code]
' returns a new array [3,5,7] which is from 1 (inclusive) to 4 (exclusive)
Arrays<Int>.Slice([1,3,5,7,9], 1, 4)
[/code]
#End
	Function Slice:T[](arr:T[], startIndex:Int, endIndex:Int)
		Local length:Int = endIndex-startIndex
		Local rv:T[] = New T[length]
		For Local i:Int = 0 Until length
			rv[i] = arr[startIndex+i]
		Next
		Return rv
	End
	
#Rem
Summary: The Reverse function will do an in-place rearrangement of array values such that its contents has been reversed.
[code]
' alters the passed array to have the contents [5,4,3,2,1]
Arrays<Int>.Reverse([1,2,3,4,5])
[/code]
#End
	Function Reverse:Void(arr:T[], startIndex:Int=0, endIndex:Int=-1)
		If startIndex < 0 Then startIndex = 0
		If endIndex < 0 Or endIndex > arr.Length Then endIndex = arr.Length
		If startIndex >= endIndex Then Return
		For Local i:Int = 0 Until (endIndex-startIndex)/2
			Local tmp:T = arr[i+startIndex]
			arr[i+startIndex] = arr[endIndex-i-1]
			arr[endIndex-i-1] = tmp
		Next
	End
	
#Rem
Summary: The Equals function will perform an equality comparison on every element in the two passed arrays.
It returns False if the arrays are of different length, or when it finds the first non-match.
Otherwise, it returns True.
[code]
' returns False, because arrays are different length
Arrays<Int>.Equals([1,2,3], [1,2])

' returns False, because arrays contain different values
Arrays<Int>.Equals([1,2,3], [4,5,6])

' returns True, because arrays contain the same values
Arrays<Int>.Equals([1,2,3], [1,2,3])
[/code]
#End
	Function Equals:Bool(arr1:T[], arr2:T[])
		If arr1.Length <> arr2.Length Then Return False
		For Local i:Int = 0 Until arr1.Length
			If arr1[i] <> arr2[i] Then Return False
		Next
		Return True
	End
	
#Rem
Summary: The CreateArray function will create an array of arrays (sometimes called a multi-dimension array),
ensuring that the sub-arrays are also created (prevents null references).  Note that the actual values of
the sub-arrays are left as the default value for its type (null for objects).
[code]
' returns [[0,0,0,0],
'          [0,0,0,0],
'          [0,0,0,0]]
Arrays<Int>.CreateArray(3, 4)
[/code]
#End
	Function CreateArray:T[][](rows:Int, cols:Int)
		Local a:T[][] = New T[rows][]
		For Local i:Int = 0 Until rows
			a[i] = New T[cols]
		End
		Return a
	End
End


