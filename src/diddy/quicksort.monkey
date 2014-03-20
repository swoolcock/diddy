#Rem
Copyright (c) 2011 Steve Revill and Shane Woolcock
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#End

Strict

Private
Import diddy.functions
Import diddy.containers

Public
Class SortUtil<T>
	'summary: QuickSort
	Function QuickSort:Void(arr:T[], comp:IComparator<T> = Null, reverse:Bool = False)
		QuickSort(arr, 0, arr.Length-1, comp, reverse)
	End
	
	Function QuickSort:Void(arr:T[], left:Int, right:Int, comp:IComparator<T> = Null, reverse:Bool = False)
		If right > left Then
			Local pivotIndex:Int = left + (right-left)/2
			Local pivotNewIndex:Int = QuickSortPartition(arr, left, right, pivotIndex, comp, reverse)
			QuickSort(arr, left, pivotNewIndex - 1, comp, reverse)
			QuickSort(arr, pivotNewIndex + 1, right, comp, reverse)
		End
	End
	
	Function QuickSortContainer:Void(cnt:IContainer<T>, comp:IComparator<T> = Null, reverse:Bool = False)
		QuickSortContainer(cnt, 0, cnt.Count()-1, comp, reverse)
	End
	
	Function QuickSortContainer:Void(cnt:IContainer<T>, left:Int, right:Int, comp:IComparator<T> = Null, reverse:Bool = False)
		If right > left Then
			Local pivotIndex:Int = left + (right-left)/2
			Local pivotNewIndex:Int = QuickSortContainerPartition(cnt, left, right, pivotIndex, comp, reverse)
			QuickSortContainer(cnt, left, pivotNewIndex - 1, comp, reverse)
			QuickSortContainer(cnt, pivotNewIndex + 1, right, comp, reverse)
		End
	End
	
	'summary: QuickSortPartition
	Function QuickSortPartition:Int(arr:T[], left:Int, right:Int, pivotIndex:Int, comp:IComparator<T> = Null, reverse:Bool = False)
		Local pivotValue:Object = arr[pivotIndex]
		arr[pivotIndex] = arr[right]
		arr[right] = pivotValue
		Local storeIndex:Int = left, val:T
		For Local i:Int = left Until right
			If IComparableWrapper.IsComparable(lhs) Or IComparableWrapper.IsComparable(rhs) Then
				If Not reverse And IComparableWrapper.Compare(arr[i], pivotValue) <= 0 Or reverse And IComparableWrapper.Compare(arr[i], pivotValue) >= 0 Then
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
	
	Function QuickSortContainerPartition:Int(cnt:IContainer<T>, left:Int, right:Int, pivotIndex:Int, comp:IComparator<T> = Null, reverse:Bool = False)
		Local pivotValue:Object = cnt.GetItem(pivotIndex)
		cnt.SetItem(pivotIndex, cnt.GetItem(right))
		cnt.SetItem(right, pivotValue)
		Local storeIndex:Int = left, val:T
		For Local i:Int = left Until right
			Local cnti:T = cnt.GetItem(i)
			If IComparableWrapper.IsComparable(lhs) Or IComparableWrapper.IsComparable(rhs) Then
				If Not reverse And IComparableWrapper.Compare(cnti, pivotValue) <= 0 Or reverse And IComparableWrapper.Compare(cnti, pivotValue) >= 0 Then
					val = cnti
					cnt.SetItem(i, cnt.GetItem(storeIndex))
					cnt.SetItem(storeIndex, val)
					storeIndex += 1
End
			Else
				If Not reverse And comp.Compare(cnti, pivotValue) <= 0 Or reverse And comp.Compare(cnti, pivotValue) >= 0 Then
					val = cnti
					cnt.SetItem(i, cnt.GetItem(storeIndex))
					cnt.SetItem(storeIndex, val)
					storeIndex += 1
				End
			End
		Next
		val = cnt.GetItem(storeIndex)
		cnt.SetItem(storeIndex, cnt.GetItem(right))
		cnt.SetItem(right, val)
		Return storeIndex
	End
End
