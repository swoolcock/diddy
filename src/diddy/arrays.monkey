#Rem
header:
Example:
Arrays<Int>.Join([1,2,3], [4,5]) returns a new array [1,2,3,4,5]
Arrays<String>.Fill(["a","b","c"], "d") fills the existing array and returns it ["d","d","d"] (it doesn't create a new array)
Arrays<Int>.Slice([1,3,5,7,9], 1, 4) returns a new array [3,5,7] which is from 1 (inclusive) to 4 (exclusive)
Arrays<Float>.Clone([1.0,2.5,3.0]) returns a new array with the same contents [1.0,2.5,3.0]
Arrays<Int>.Copy([1,2,3,4], 1, [5,6,7,8], 2, 2) copies 2 characters from index 1 in src to index 3 in dest. dest now contains [5,6,2,3]
Join accepts up to 10 arrays.  Unused parameters are assumed to be empty arrays.
#End

#Rem
	Summary: The Arrays class
#End
Class Arrays<T>
	'summary: Join returns a new array
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
	
	'summary: Fills the existing array and returns it ["d","d","d"] (it doesn't create a new array)
	Function Fill:T[](arr:T[], val:T)
		For Local i:Int = 0 Until arr.Length
			arr[i] = val
		Next
		Return arr
	End
	
	'summary: returns a new array with the same contents
	Function Clone:T[](arr:T[])
		Local rv:T[] = New T[arr.Length]
		For Local i:Int = 0 Until arr.Length
			rv[i] = arr[i]
		Next
		Return rv
	End
	
	'summary: Arrays<Int>.Copy([1,2,3,4], 1, [5,6,7,8], 2, 2) copies 2 characters from index 1 in src to index 3 in dest. dest now contains [5,6,2,3]
	Function Copy:Void(src:T[], srcPos:Int, dest:T[], destPos:Int, length:Int)
		If length = 0 Then Return
		If length < 0 Then Error("Arrays.Copy: length < 0")
		If srcPos < 0 Then Error("Arrays.Copy: srcPos < 0")
		If destPos < 0 Then Error("Arrays.Copy: destPos < 0")
		If srcPos >= src.Length Then Error("Arrays.Copy: srcPos ("+srcPos+") >= src.Length ("+src.Length+")")
		If destPos >= dest.Length Then Error("Arrays.Copy: destPos ("+destPos+") >= dest.Length ("+dest.Length+")")
		If srcPos + length > src.Length Then Error("Arrays.Copy: srcPos ("+srcPos+") + length ("+length+") > src.Length ("+src.Length+")")
		If destPos + length > dest.Length Then Error("Arrays.Copy: destPos ("+destPos+") + length ("+length+") > dest.Length ("+dest.Length+")")
		
		' since we can't compare array object references, we must never assume that src and dest are different objects
		' as such, we'll copy the src values into a temp array (wasted cycles, but oh well)
		Local temp:T[] = New T[length]
		For Local i:Int = 0 Until length
			temp[i] = src[srcPos+i]
		Next
		For Local i:Int = 0 Until length
			dest[destPos+i] = temp[i]
		Next
	End
	
	'summary: Slice returns a new array [3,5,7] which is from 1 (inclusive) to 4 (exclusive)
	Function Slice:T[](arr:T[], startIndex:Int, endIndex:Int)
		Local length:Int = endIndex-startIndex
		Local rv:T[] = New T[length]
		For Local i:Int = 0 Until length
			rv[i] = arr[startIndex+i]
		Next
		Return rv
	End
	
	'summary: returns a new array that is reversed
	Function Reverse:Void(arr:T[])
		For Local i:Int = 0 Until arr.Length/2
			Local tmp:T = arr[i]
			arr[i] = arr[arr.Length-i-1]
			arr[arr.Length-i-1] = tmp
		Next
	End
	
	'summary: compare arrays
	Function Equals:Bool(arr1:T[], arr2:T[])
		If arr1.Length <> arr2.Length Then Return False
		For Local i:Int = 0 Until arr1.Length
			If arr1[i] <> arr2[i] Then Return False
		Next
		Return True
	End
End
