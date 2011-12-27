' Example:
' Arrays<Int>.Join([1,2,3], [4,5]) returns a new array [1,2,3,4,5]
' Arrays<String>.Fill(["a","b","c"], "d") fills the existing array and returns it ["d","d","d"] (it doesn't create a new array)
' Arrays<Int>.Slice([1,3,5,7,9], 1, 3) returns a new array [3,5,7]
' Arrays<Float>.Copy([1.0,2.5,3.0]) returns a new array with the same contents [1.0,2.5,3.0]
' Join accepts up to 10 arrays.  Unused parameters are assumed to be empty arrays.
Class Arrays<T>
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
	
	Function Fill:T[](arr:T[], val:T)
		For Local i:Int = 0 Until arr.Length
			arr[i] = val
		Next
		Return arr
	End
	
	Function Copy:T[](arr:T[])
		Local rv:T[] = New T[arr.Length]
		For Local i:Int = 0 Until arr.Length
			rv[i] = arr[i]
		Next
		Return rv
	End
	
	Function Slice:T[](arr:T[], start:Int, length:Int)
		Local rv:T[] = New T[length]
		For Local i:Int = 0 Until length
			rv[i] = arr[start+i]
		Next
		Return rv
	End
End
