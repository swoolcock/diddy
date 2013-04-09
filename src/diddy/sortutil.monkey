#Rem
Copyright (c) 2011 Steve Revill and Shane Woolcock
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#End

Strict

Public
Import comparator

Class SortUtil<T>
Public
	Function QuickSort:Void(arr:T[], reverse:Bool=False)
		QuickSort(arr, 0, arr.Length-1, reverse)
	End
	
	Function QuickSort:Void(arr:T[], left:Int, right:Int, reverse:Bool=False)
		If right > left Then
			Local pivotIndex:Int = left + (right-left)/2
			Local pivotNewIndex:Int = QuickSortPartition(arr, left, right, pivotIndex, reverse)
			QuickSort(arr, left, pivotNewIndex - 1, reverse)
			QuickSort(arr, pivotNewIndex + 1, right, reverse)
		End
	End
	
	Function QuickSortObject:Void(arr:T[], comp:IComparator=Null, reverse:Bool=False)
		QuickSortObject(arr, 0, arr.Length-1, comp, reverse)
	End
	
	Function QuickSortObject:Void(arr:T[], left:Int, right:Int, comp:IComparator=Null, reverse:Bool=False)
		If right > left Then
			Local pivotIndex:Int = left + (right-left)/2
			Local pivotNewIndex:Int = QuickSortObjectPartition(arr, left, right, pivotIndex, comp, reverse)
			QuickSortObject(arr, left, pivotNewIndex - 1, comp, reverse)
			QuickSortObject(arr, pivotNewIndex + 1, right, comp, reverse)
		End
	End

Private
	Function QuickSortPartition:Int(arr:T[], left:Int, right:Int, pivotIndex:Int, reverse:Bool)
		Local pivotValue:T = arr[pivotIndex]
		arr[pivotIndex] = arr[right]
		arr[right] = pivotValue
		Local storeIndex:Int = left, val:T
		For Local i:Int = left Until right
			If Not reverse And arr[i] <= pivotValue Or reverse And arr[i] >= pivotValue Then
				val = arr[i]
				arr[i] = arr[storeIndex]
				arr[storeIndex] = val
				storeIndex += 1
			End
		Next
		val = arr[storeIndex]
		arr[storeIndex] = arr[right]
		arr[right] = val
		Return storeIndex
	End
	
	Function QuickSortObjectPartition:Int(arr:T[], left:Int, right:Int, pivotIndex:Int, comp:IComparator, reverse:Bool)
		Local pivotValue:T = arr[pivotIndex]
		arr[pivotIndex] = arr[right]
		arr[right] = pivotValue
		Local storeIndex:Int = left, val:T
		For Local i:Int = left Until right
			If IComparable(arr[i]) <> Null Then
				If Not reverse And IComparable(arr[i]).Compare(pivotValue) <= 0 Or reverse And IComparable(arr[i]).Compare(pivotValue) >= 0 Then
					val = arr[i]
					arr[i] = arr[storeIndex]
					arr[storeIndex] = val
					storeIndex += 1
				End
			Else
				If Not reverse And comp.Compare(arr[i], pivotValue) <= 0 Or reverse And comp.Compare(arr[i], pivotValue) >= 0 Then
					val = arr[i]
					arr[i] = arr[storeIndex]
					arr[storeIndex] = val
					storeIndex += 1
				End
			End
		Next
		val = arr[storeIndex]
		arr[storeIndex] = arr[right]
		arr[right] = val
		Return storeIndex
	End
End

'summary: QuickSort wrapper for backward compatibility
Function QuickSort:Void(arr:Object[], left:Int, right:Int, comp:IComparator, reverse:Bool = False)
	SortUtil<Object>.QuickSort(arr, reverse)
End

'summary: QuickSortPartition wrapper for backward compatibility
Function QuickSortPartition:Int(arr:Object[], left:Int, right:Int, pivotIndex:Int, comp:IComparator, reverse:Bool = False)
	Return SortUtil<Object>.QuickSortPartition(arr, left, right, pivotIndex, comp, reverse)
End
