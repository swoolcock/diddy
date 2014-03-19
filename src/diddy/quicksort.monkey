#Rem
Copyright (c) 2011 Steve Revill and Shane Woolcock
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#End

Strict

Private
Import diddy.functions
Import diddy.comparator

Public
Class SortUtil<T>
	'summary: QuickSort
	Function QuickSort:Void(arr:T[], left:Int, right:Int, comp:IComparator, reverse:Bool = False)
		If right > left Then
			Local pivotIndex:Int = left + (right-left)/2
			Local pivotNewIndex:Int = SortUtil<T>.QuickSortPartition(arr, left, right, pivotIndex, comp, reverse)
			QuickSort(arr, left, pivotNewIndex - 1, comp, reverse)
			QuickSort(arr, pivotNewIndex + 1, right, comp, reverse)
		End
	End
	
	'summary: QuickSortPartition
	Function QuickSortPartition:Int(arr:T[], left:Int, right:Int, pivotIndex:Int, comp:IComparator, reverse:Bool = False)
		Local pivotValue:Object = arr[pivotIndex]
		arr[pivotIndex] = arr[right]
		arr[right] = pivotValue
		Local storeIndex:Int = left, val:Object
		For Local i:Int = left Until right
			Local cmprbl:IComparable = CastUtil<IComparable>.Cast(arr[i])
			If cmprbl Then
				If Not reverse And cmprbl.Compare(pivotValue) <= 0 Or reverse And cmprbl.Compare(pivotValue) >= 0 Then
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
