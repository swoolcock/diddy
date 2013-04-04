Strict

Public
Import comparator

'summary: QuickSort
Function QuickSort:Void(arr:Object[], left:Int, right:Int, comp:IComparator, reverse:Bool = False)
	If right > left Then
		Local pivotIndex:Int = left + (right-left)/2
		Local pivotNewIndex:Int = QuickSortPartition(arr, left, right, pivotIndex, comp, reverse)
		QuickSort(arr, left, pivotNewIndex - 1, comp, reverse)
		QuickSort(arr, pivotNewIndex + 1, right, comp, reverse)
	End
End

'summary: QuickSortPartition
Function QuickSortPartition:Int(arr:Object[], left:Int, right:Int, pivotIndex:Int, comp:IComparator, reverse:Bool = False)
	Local pivotValue:Object = arr[pivotIndex]
	arr[pivotIndex] = arr[right]
	arr[right] = pivotValue
	Local storeIndex:Int = left, val:Object
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
