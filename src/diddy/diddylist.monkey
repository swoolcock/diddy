#Rem
Copyright (c) 2011 Steve Revill and Shane Woolcock
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#End

#Rem
Header: Provides the DiddyList class and associated utility classes.
#End

Strict
Private
Import diddy.containers
Import diddy.exception

Public
#Rem
Summary: The DiddyList class extends the official Monkey List class and implements Diddy's IContainer interface.
As with the other Diddy container classes, it simplifies mixing and matching of container types by sharing
common method names.
#End
Class DiddyList<T> Extends List<T> Implements IContainer<T>
Private
	Global NIL:T
	
	Method CheckRange:Void(index:Int, low:Int=0, high:Int=-1)
		If high < 0 Then high = Self.Count()
		If index < low Or index >= high Then
			Throw New IndexOutOfBoundsException("DiddyList.CheckRange: index " + index + " not in range " + low + " <= index < " + high)
		End
	End
	
Public
#Rem
Summary: Constructor to create an empty DiddyList.
#End
	Method New()
		Super.New()
	End

#Rem
Summary: Constructor to create a DiddyList with the contents of the passed array.
#End
	Method New(data:T[])
		Super.New(data)
	End
	
#Rem
Summary: Constructor to create a DiddyList with the contents of the passed Stack.
Throws IllegalArgumentException if src is Null.
#End
	Method New(src:Stack<T>)
		If Not src Then Throw New IllegalArgumentException("DiddyList.New: Source Stack must not be null")
		AddAll(src)
	End
	
#Rem
Summary: Constructor to create a DiddyList with the contents of the passed List.
Throws IllegalArgumentException if src is Null.
#End
	Method New(src:List<T>)
		If Not src Then Throw New IllegalArgumentException("DiddyList.New: Source List must not be null")
		AddAll(src)
	End
	
#Rem
Summary: Constructor to create a DiddyList with the contents of the passed Set.
Throws IllegalArgumentException if src is Null.
#End
	Method New(src:Set<T>)
		If Not src Then Throw New IllegalArgumentException("DiddyList.New: Source Set must not be null")
		AddAll(src)
	End
	
#Rem
Summary: Adds the entire contents of the passed Stack to the DiddyList.
Throws IllegalArgumentException if src is Null.
#End
	Method AddAll:Void(src:Stack<T>)
		If Not src Then Throw New IllegalArgumentException("DiddyList.AddAll: Source Stack must not be null")
		For Local val := EachIn src
			Self.AddLast(val)
		Next
	End

#Rem
Summary: Adds the entire contents of the passed List to the DiddyList.
Throws IllegalArgumentException if src is Null.
#End
	Method AddAll:Void(src:List<T>)
		If Not src Then Throw New IllegalArgumentException("DiddyList.AddAll: Source List must not be null")
		For Local val := EachIn src
			Self.AddLast(val)
		Next
	End
	
#Rem
Summary: Adds the entire contents of the passed Set to the DiddyList.
Throws IllegalArgumentException if src is Null.
#End
	Method AddAll:Void(src:Set<T>)
		If Not src Then Throw New IllegalArgumentException("DiddyList.AddAll: Source Set must not be null")
		For Local val := EachIn src
			Self.AddLast(val)
		Next
	End
	
#Rem
Summary: Adds the entire contents of another container to this DiddyList.
Throws IllegalArgumentException if src is Null.
#End
	Method AddContainer:Void(src:IContainer<T>)
		If Not src Then Throw New IllegalArgumentException("DiddyList.AddContainer: Source IContainer must not be null")
		For Local val := EachIn src.Items()
			Self.AddLast(val)
		Next
	End
	
#Rem
Summary: Removes from this DiddyList anything that also exists in the passed Stack.
Throws IllegalArgumentException if src is Null.
#End
	Method RemoveAll:Void(src:Stack<T>)
		If Not src Then Throw New IllegalArgumentException("DiddyList.RemoveAll: Source Stack must not be null")
		For Local val := EachIn src
			Self.RemoveEach(val)
		Next
	End
	
#Rem
Summary: Removes from this DiddyList anything that also exists in the passed List.
Throws IllegalArgumentException if src is Null.
#End
	Method RemoveAll:Void(src:List<T>)
		If Not src Then Throw New IllegalArgumentException("DiddyList.RemoveAll: Source List must not be null")
		For Local val := EachIn src
			Self.RemoveEach(val)
		Next
	End
	
#Rem
Summary: Removes from this DiddyList anything that also exists in the passed Set.
Throws IllegalArgumentException if src is Null.
#End
	Method RemoveAll:Void(src:Set<T>)
		If Not src Then Throw New IllegalArgumentException("DiddyList.RemoveAll: Source Set must not be null")
		For Local val := EachIn src
			Self.RemoveEach(val)
		Next
	End
	
#Rem
Summary: Removes from this DiddyList anything that also exists in the passed container.
Throws IllegalArgumentException if src is Null.
#End
	Method RemoveContainer:Void(src:IContainer<T>)
		If Not src Then Throw New IllegalArgumentException("DiddyList.RemoveContainer: Source IContainer must not be null")
		For Local val := EachIn src.Items()
			Self.RemoveEach(val)
		Next
	End
	
#Rem
Summary: Removes from this DiddyList anything that does NOT exist in the passed Stack.
Throws IllegalArgumentException if src is Null.
#End
	Method RetainAll:Void(src:Stack<T>)
		If Not src Then Throw New IllegalArgumentException("DiddyList.RetainAll: Source Stack must not be null")
		Local arr:T[] = Self.ToArray()
		For Local val := EachIn arr
			If Not src.Contains(val) Then
				Self.RemoveEach(val)
			End
		Next
	End
	
#Rem
Summary: Removes from this DiddyList anything that does NOT exist in the passed List.
Throws IllegalArgumentException if src is Null.
#End
	Method RetainAll:Void(src:List<T>)
		If Not src Then Throw New IllegalArgumentException("DiddyList.RetainAll: Source List must not be null")
		Local arr:T[] = Self.ToArray()
		For Local val := EachIn arr
			If Not src.Contains(val) Then
				Self.RemoveEach(val)
			End
		Next
	End
	
#Rem
Summary: Removes from this DiddyList anything that does NOT exist in the passed Set.
Throws IllegalArgumentException if src is Null.
#End
	Method RetainAll:Void(src:Set<T>)
		If Not src Then Throw New IllegalArgumentException("DiddyList.RetainAll: Source Set must not be null")
		Local arr:T[] = Self.ToArray()
		For Local val := EachIn arr
			If Not src.Contains(val) Then
				Self.RemoveEach(val)
			End
		Next
	End
	
#Rem
Summary: Removes from this DiddyList anything that does NOT exist in the passed container.
Throws IllegalArgumentException if src is Null.
#End
	Method RetainContainer:Void(src:IContainer<T>)
		If Not src Then Throw New IllegalArgumentException("DiddyList.RetainContainer: Source Container must not be null")
		Local arr:T[] = Self.ToArray()
		For Local val := EachIn arr
			If Not src.ContainsItem(val) Then
				Self.RemoveEach(val)
			End
		Next
	End
	
#Rem
Summary: Returns True if this DiddyList contains ALL of the items in the passed Stack.
Throws IllegalArgumentException if src is Null.
#End
	Method ContainsAll:Bool(src:Stack<T>)
		If Not src Then Throw New IllegalArgumentException("DiddyList.ContainsAll: Source Stack must not be null")
		For Local val := EachIn src
			If Not Self.Contains(val) Return False
		Next
		Return True
	End
	
#Rem
Summary: Returns True if this DiddyList contains ALL of the items in the passed List.
Throws IllegalArgumentException if src is Null.
#End
	Method ContainsAll:Bool(src:List<T>)
		If Not src Then Throw New IllegalArgumentException("DiddyList.ContainsAll: Source List must not be null")
		For Local val := EachIn src
			If Not Self.Contains(val) Return False
		Next
		Return True
	End
	
#Rem
Summary: Returns True if this DiddyList contains ALL of the items in the passed Set.
Throws IllegalArgumentException if src is Null.
#End
	Method ContainsAll:Bool(src:Set<T>)
		If Not src Then Throw New IllegalArgumentException("DiddyList.ContainsAll: Source Set must not be null")
		For Local val := EachIn src
			If Not Self.Contains(val) Return False
		Next
		Return True
	End
	
#Rem
Summary: Returns True if this DiddyList contains ALL of the items in the passed container.
Throws IllegalArgumentException if src is Null.
#End
	Method ContainsContainer:Bool(src:IContainer<T>)
		If Not src Then Throw New IllegalArgumentException("DiddyList.ContainsContainer: Source IContainer must not be null")
		For Local val := EachIn src.Items()
			If Not Self.Contains(val) Return False
		Next
		Return True
	End
	
#Rem
Summary: Adds the passed value to the DiddyList.
#End
	Method AddItem:Void(val:T)
		Self.AddLast(val)
	End
	
#Rem
Summary: Removes the passed value from the DiddyList if it exists.
#End
	Method RemoveItem:Void(val:T)
		Self.RemoveEach(val)
	End
	
#Rem
Summary: Adds the passed value to the DiddyList, before the requested index.
If the index is the same as Count(), it will be added to the end of the DiddyList.
Debug build will throw an IndexOutOfBoundsException if the index is not in the range 0 <= index <= Count().
#End
	Method InsertItem:Void(index:Int, val:T)
#If CONFIG="debug" Then
		CheckRange(index,,Self.Count()+1)
#End
		If index = 0 Or Self.IsEmpty() Then
			Self.AddFirst(val)
		ElseIf index >= Self.Count() Then
			Self.AddLast(val)
		Else
			' Somehow Mark made Node<T> constructor accept Node instance with no type parameter, so we have to search twice (once in GetItem, once in InsertBefore)
			Local item:T = Self.GetItem(index)
			If item Then
				Self.InsertBefore(item, val)
			End
		End
	End
	
#Rem
Summary: Removes the item from the DiddyList that exists at the requested index.
Debug build will throw an IndexOutOfBoundsException if the index is not in the range 0 <= index < Count().
#End
	Method DeleteItem:T(index:Int)
		If Self.IsEmpty() Then Return NIL
#If CONFIG="debug" Then
		CheckRange(index)
#End
		Local i:Int = 0
		Local node:list.Node<T> = Self.FirstNode()
		While node
			If i = index Then
				Local rv:T = node.Value()
				node.Remove()
				Return rv
			End
			node = node.NextNode()
			i += 1
		End
		Return NIL
	End
	
#Rem
Summary: Removes all items from the DiddyList.
#End
	Method ClearAll:Void()
		Self.Clear()
	End
	
#Rem
Summary: Returns True if the DiddyList contains the passed value.
#End
	Method ContainsItem:Bool(value:T)
		Return Self.Contains(value)
	End
	
#Rem
Summary: Returns the item that exists at the requested index.
If the list is empty or the index is out of bounds, the default value for T will be returned.
Debug build will throw an IndexOutOfBoundsException if the index is not in the range 0 <= index < Count().
#End
	Method GetItem:T(index:Int)
		If Self.IsEmpty() Then Return NIL
#If CONFIG="debug" Then
		CheckRange(index)
#End
		Local i:Int = 0
		Local node:list.Node<T> = Self.FirstNode()
		While node
			If i = index Then Return node.Value()
			node = node.NextNode()
			i += 1
		End
		Return NIL
	End
	
#Rem
Summary: Changes the item at the requested index to be the passed one instead.
If the list is empty or the index is out of bounds, nothing happens.
Debug build will throw an IndexOutOfBoundsException if the index is not in the range 0 <= index < Count().
#End
	Method SetItem:Void(index:Int, value:T)
		If Self.IsEmpty() Then Return
#If CONFIG="debug" Then
		CheckRange(index)
#End
		Local i:Int = 0
		Local node:list.Node<T> = Self.FirstNode()
		While node
			If i = index Then
				Self.InsertBefore(node.Value(), value)
				node.Remove()
				Return
			End
			i += 1
		End
	End
	
#Rem
Summary: Attempts to find the index of the first occurrence of the passed item.
If the list is empty or the item could not be found, -1 is returned.
#End
	Method FindItem:Int(value:T)
		If Self.IsEmpty() Then Return -1
		Local i:Int = 0
		Local node:list.Node<T> = Self.FirstNode()
		While node
			If Self.Equals(node.Value(), value) Then Return i
			node = node.NextNode()
			i += 1
		End
		Return -1
	End
	
#Rem
Summary: Sorts the DiddyList using the default Monkey sorting algorithm, comparing items with an IComparator or IComparable.
#End
	Method SortItems:Void(ascending:Bool = True)
		Sort(ascending)
	End
	
#Rem
Summary: Returns the number items in the DiddyList.
#End
	Method Count:Int()
		Return Super.Count()
	End
	
#Rem
Summary: Compares two values of the generic type T, for sorting.
Called automatically by Monkey's sorting algorithm, it first attempts to use an IComparator if it exists.
If not it will attempt to use the IComparable CompareTo method if T implements it.
Finally, it will simply call the Super version of Compare.
#End
	Method Compare:Int(lhs:T, rhs:T)
		If Self.comparator Then Return Self.comparator.Compare(lhs, rhs)
		If IComparableWrapper.IsComparable(lhs) Or IComparableWrapper.IsComparable(rhs) Then Return IComparableWrapper.Compare(lhs, rhs)
		Return Super.Compare(lhs, rhs)
	End
	
#Rem
Summary: Returns True if the items are referentially equal (for Objects) or equal by value (for primitives).
#End
	Method Equals:Bool(lhs:T, rhs:T)
		Return lhs = rhs
	End
	
#Rem
Summary: Returns a new T[] array of length Count(), containing all the items in the DiddyList, in order.
#End
	Method ToArray:T[]()
		Return Super.ToArray()
	End
	
#Rem
Summary: Populates the passed T[] array with all the elements in the DiddyList.
If the array is too small to fit the entire list, an IllegalArgumentException is thrown.
The number of values successfully filled is returned.
#End
	Method FillArray:Int(arr:T[])
		Local cnt:Int = Self.Count()
		If arr.Length < cnt Then Throw New IllegalArgumentException("DiddyList.FillArray: Array length too small ("+arr.Length+"<"+cnt+")")
		Local i:Int = 0
		For Local v:T = EachIn Self
			arr[i] = v
			i += 1
		Next
		Return i
	End
	
#Rem
Summary: Returns True if the DiddyList is empty.
#End
	Method IsEmpty:Bool()
		Return Super.IsEmpty()
	End
	
#Rem
Summary: Reverses the order of elements in the list.
#End
	Method Reverse:Void()
		For Local i:Int = 0 Until Count()/2
			SwapItems(i, Count()-i-1)
		Next
	End
	
#Rem
Summary: Swaps the elements at two given indices.
Debug build will throw an IndexOutOfBoundsException if either index is not in the range 0 <= index < Count().
#End
	Method SwapItems:Void(index1:Int, index2:Int)
		Local temp:T = GetItem(index1)
		SetItem(index1, GetItem(index2))
		SetItem(index2, temp)
	End
	
#Rem
Summary: Randomises the order of elements in the list.
#End
	Method Shuffle:Void()
		For Local i:Int = Count() - 1 To 0 Step -1
			SwapItems(i, Rnd(i))
		Next
	End
	
#Rem
Summary: Reduces the number of items in the list to be no more than the passed size.
If there are less or equal elements in the list than the passed size, nothing happens.
If there are more elements in the list than the passed size, elements are removed from the end
until Count() = the requested size.
If building with debug, an IllegalArgumentException is thrown if the requested size < 0.
#End
	Method Truncate:Void(size:Int)
		While Count() > size
			RemoveLast()
		End
	End
	
#Rem
Summary: Returns a custom IEnumerable that optionally supports a predicate.
#End
	Method Items:IEnumerable<T>(pred:IPredicate<T>=Null)
		Return New WrappedListEnumerable<T>(Self, pred)
	End
	
Private
	Field comparator:IComparator<T>

Public
#Rem
Summary: Getter for the current sorting comparator.
Allows sorting without implementing IComparable.
#End
	Method Comparator:IComparator<T>() Property; Return Self.comparator; End
	
#Rem
Summary: Setter for the current sorting comparator.
Allows sorting without implementing IComparable.
#End
	Method Comparator:Void(comparator:IComparator<T>) Property; Self.comparator = comparator; End
End

#Rem
Summary: Extends DiddyList to provide Int-specific equality and comparison (to avoid the IComparable check).
Similar to IntList.
#End
Class DiddyIntList Extends DiddyList<Int>
	Method New(data:Int[])
		Super.New(data)
	End
	
	Method Equals:Bool(lhs:Int, rhs:Int)
		Return lhs=rhs
	End
	
	Method Compare:Int(lhs:Int, rhs:Int)
		If Self.Comparator Then Return Self.Comparator.Compare(lhs, rhs)
		Return lhs-rhs
	End
End

#Rem
Summary: Extends DiddyList to provide Float-specific equality and comparison (to avoid the IComparable check).
Similar to FloatList.
#End
Class DiddyFloatList Extends DiddyList<Float>
	Method New(data:Float[])
		Super.New(data)
	End
	
	Method Equals:Bool(lhs:Float, rhs:Float)
		Return lhs=rhs
	End
	
	Method Compare:Int(lhs:Float, rhs:Float)
		If Self.Comparator Then Return Self.Comparator.Compare(lhs, rhs)
		If lhs<rhs Return -1
		Return lhs>rhs
	End
End

#Rem
Summary: Extends DiddyList to provide String-specific equality and comparison (to avoid the IComparable check).
Similar to StringList.
#End
Class DiddyStringList Extends DiddyList<String>
	Method New(data:String[])
		Super.New(data)
	End
	
	Method Join:String(separator:String = "")
		Return separator.Join(ToArray())
	End
	
	Method Equals:Bool(lhs:String, rhs:String)
		Return lhs=rhs
End

	Method Compare:Int(lhs:String, rhs:String)
		If Self.Comparator Then Return Self.Comparator.Compare(lhs, rhs)
		Return lhs.Compare(rhs)
	End
End
