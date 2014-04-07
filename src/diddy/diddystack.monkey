#Rem
Copyright (c) 2011 Steve Revill and Shane Woolcock
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#End

#Rem
Header: Provides the DiddyStack class and associated utility classes.
#End

Strict
Private
Import diddy.containers
Import diddy.exception

Public
#Rem
Summary: The DiddyStack class extends the official Monkey Stack class and implements Diddy's IContainer interface.
As with the other Diddy container classes, it simplifies mixing and matching of container types by sharing
common method names.
#End
Class DiddyStack<T> Extends Stack<T> Implements IContainer<T>
Private
	Global NIL:T
	
	Method CheckRange:Void(index:Int, low:Int=0, high:Int=-1)
		If high < 0 Then high = Self.Count()
		If index < low Or index >= high Then
			Throw New IndexOutOfBoundsException("DiddyStack.CheckRange: index " + index + " not in range " + low + " <= index < " + high)
		End
	End
	
Public
#Rem
Summary: Constructor to create an empty DiddyStack.
#End
	Method New()
		Super.New()
	End

#Rem
Summary: Constructor to create a DiddyStack with the contents of the passed array.
#End
	Method New(data:T[])
		Super.New(data)
	End
	
#Rem
Summary: Constructor to create a DiddyStack with the contents of the passed Stack.
Throws IllegalArgumentException if src is Null.
#End
	Method New(src:Stack<T>)
		If Not src Then Throw New IllegalArgumentException("DiddyStack.New: Source Stack must not be null")
		AddAll(src)
	End
	
#Rem
Summary: Constructor to create a DiddyStack with the contents of the passed List.
Throws IllegalArgumentException if src is Null.
#End
	Method New(src:List<T>)
		If Not src Then Throw New IllegalArgumentException("DiddyStack.New: Source List must not be null")
		AddAll(src)
	End
	
#Rem
Summary: Constructor to create a DiddyStack with the contents of the passed Set.
Throws IllegalArgumentException if src is Null.
#End
	Method New(src:Set<T>)
		If Not src Then Throw New IllegalArgumentException("DiddyStack.New: Source Set must not be null")
		AddAll(src)
	End
	
#Rem
Summary: Adds the entire contents of the passed Stack to the DiddyStack.
Throws IllegalArgumentException if src is Null.
#End
	Method AddAll:Void(src:Stack<T>)
		If Not src Then Throw New IllegalArgumentException("DiddyStack.AddAll: Source Stack must not be null")
		For Local val := EachIn src
			Self.Push(val)
		Next
	End

#Rem
Summary: Adds the entire contents of the passed List to the DiddyStack.
Throws IllegalArgumentException if src is Null.
#End
	Method AddAll:Void(src:List<T>)
		If Not src Then Throw New IllegalArgumentException("DiddyStack.AddAll: Source List must not be null")
		For Local val := EachIn src
			Self.Push(val)
		Next
	End
	
#Rem
Summary: Adds the entire contents of the passed Set to the DiddyStack.
Throws IllegalArgumentException if src is Null.
#End
	Method AddAll:Void(src:Set<T>)
		If Not src Then Throw New IllegalArgumentException("DiddyStack.AddAll: Source Set must not be null")
		For Local val := EachIn src
			Self.Push(val)
		Next
	End
	
#Rem
Summary: Adds the entire contents of another container to this DiddyStack.
Throws IllegalArgumentException if src is Null.
#End
	Method AddContainer:Void(src:IContainer<T>)
		If Not src Then Throw New IllegalArgumentException("DiddyStack.AddContainer: Source IContainer must not be null")
		For Local val := EachIn src.Items()
			Self.Push(val)
		Next
	End
	
#Rem
Summary: Removes from this DiddyStack anything that also exists in the passed Stack.
Throws IllegalArgumentException if src is Null.
#End
	Method RemoveAll:Void(src:Stack<T>)
		If Not src Then Throw New IllegalArgumentException("DiddyStack.RemoveAll: Source Stack must not be null")
		For Local val := EachIn src
			Self.RemoveEach(val)
		Next
	End
	
#Rem
Summary: Removes from this DiddyStack anything that also exists in the passed List.
Throws IllegalArgumentException if src is Null.
#End
	Method RemoveAll:Void(src:List<T>)
		If Not src Then Throw New IllegalArgumentException("DiddyStack.RemoveAll: Source List must not be null")
		For Local val := EachIn src
			Self.RemoveEach(val)
		Next
	End
	
#Rem
Summary: Removes from this DiddyStack anything that also exists in the passed Set.
Throws IllegalArgumentException if src is Null.
#End
	Method RemoveAll:Void(src:Set<T>)
		If Not src Then Throw New IllegalArgumentException("DiddyStack.RemoveAll: Source Set must not be null")
		For Local val := EachIn src
			Self.RemoveEach(val)
		Next
	End
	
#Rem
Summary: Removes from this DiddyStack anything that also exists in the passed container.
Throws IllegalArgumentException if src is Null.
#End
	Method RemoveContainer:Void(src:IContainer<T>)
		If Not src Then Throw New IllegalArgumentException("DiddyStack.RemoveContainer: Source IContainer must not be null")
		For Local val := EachIn src.Items()
			Self.RemoveEach(val)
		Next
	End
	
#Rem
Summary: Removes from this DiddyStack anything that does NOT exist in the passed Stack.
Throws IllegalArgumentException if src is Null.
#End
	Method RetainAll:Void(src:Stack<T>)
		If Not src Then Throw New IllegalArgumentException("DiddyStack.RetainAll: Source Stack must not be null")
		Local arr:T[] = Self.ToArray()
		For Local val := EachIn arr
			If Not src.Contains(val) Then
				Self.RemoveEach(val)
			End
		Next
	End
	
#Rem
Summary: Removes from this DiddyStack anything that does NOT exist in the passed List.
Throws IllegalArgumentException if src is Null.
#End
	Method RetainAll:Void(src:List<T>)
		If Not src Then Throw New IllegalArgumentException("DiddyStack.RetainAll: Source List must not be null")
		Local arr:T[] = Self.ToArray()
		For Local val := EachIn arr
			If Not src.Contains(val) Then
				Self.RemoveEach(val)
			End
		Next
	End
	
#Rem
Summary: Removes from this DiddyStack anything that does NOT exist in the passed Set.
Throws IllegalArgumentException if src is Null.
#End
	Method RetainAll:Void(src:Set<T>)
		If Not src Then Throw New IllegalArgumentException("DiddyStack.RetainAll: Source Set must not be null")
		Local arr:T[] = Self.ToArray()
		For Local val := EachIn arr
			If Not src.Contains(val) Then
				Self.RemoveEach(val)
			End
		Next
	End
	
#Rem
Summary: Removes from this DiddyStack anything that does NOT exist in the passed container.
Throws IllegalArgumentException if src is Null.
#End
	Method RetainContainer:Void(src:IContainer<T>)
		If Not src Then Throw New IllegalArgumentException("DiddyStack.RetainContainer: Source IContainer must not be null")
		Local arr:T[] = Self.ToArray()
		For Local val := EachIn arr
			If Not src.ContainsItem(val) Then
				Self.RemoveEach(val)
			End
		Next
	End
	
#Rem
Summary: Returns True if this DiddyStack contains ALL of the items in the passed Stack.
Throws IllegalArgumentException if src is Null.
#End
	Method ContainsAll:Bool(src:Stack<T>)
		If Not src Then Throw New IllegalArgumentException("DiddyStack.ContainsAll: Source Stack must not be null")
		For Local val := EachIn src
			If Not Self.Contains(val) Return False
		Next
		Return True
	End
	
#Rem
Summary: Returns True if this DiddyStack contains ALL of the items in the passed List.
Throws IllegalArgumentException if src is Null.
#End
	Method ContainsAll:Bool(src:List<T>)
		If Not src Then Throw New IllegalArgumentException("DiddyStack.ContainsAll: Source List must not be null")
		For Local val := EachIn src
			If Not Self.Contains(val) Return False
		Next
		Return True
	End
	
#Rem
Summary: Returns True if this DiddyStack contains ALL of the items in the passed Set.
Throws IllegalArgumentException if src is Null.
#End
	Method ContainsAll:Bool(src:Set<T>)
		If Not src Then Throw New IllegalArgumentException("DiddyStack.ContainsAll: Source Set must not be null")
		For Local val := EachIn src
			If Not Self.Contains(val) Return False
		Next
		Return True
	End
	
#Rem
Summary: Returns True if this DiddyStack contains ALL of the items in the passed container.
Throws IllegalArgumentException if src is Null.
#End
	Method ContainsContainer:Bool(src:IContainer<T>)
		If Not src Then Throw New IllegalArgumentException("DiddyStack.ContainsContainer: Source IContainer must not be null")
		For Local val := EachIn src.Items()
			If Not Self.Contains(val) Return False
		Next
		Return True
	End
	
#Rem
Summary: Adds the passed value to the DiddyStack.
#End
	Method AddItem:Void(val:T)
		Self.Push(val)
	End
	
#Rem
Summary: Removes the passed value from the DiddyStack if it exists.
#End
	Method RemoveItem:Void(val:T)
		Self.RemoveEach(val)
	End
	
#Rem
Summary: Adds the passed value to the DiddyStack, before the requested index.
If the index is the same as Count(), it will be added to the end of the DiddyStack.
Debug build will throw an IndexOutOfBoundsException if the index is not in the range 0 <= index <= Count().
#End
	Method InsertItem:Void(index:Int, val:T)
#If CONFIG="debug" Then
		CheckRange(index,,Self.Count()+1)
#End
		Self.Insert(index, val)
	End
	
#Rem
Summary: Removes the item from the DiddyStack that exists at the requested index.
Debug build will throw an IndexOutOfBoundsException if the index is not in the range 0 <= index < Count().
#End
	Method DeleteItem:T(index:Int)
#If CONFIG="debug" Then
		CheckRange(index)
#End
		Local rv:T = Self.Get(index)
		Self.Remove(index)
		Return rv
	End
	
#Rem
Summary: Removes all items from the DiddyStack.
#End
	Method ClearAll:Void()
		Self.Clear()
	End
	
#Rem
Summary: Returns True if the DiddyStack contains the passed value.
#End
	Method ContainsItem:Bool(value:T)
		Return Self.Contains(value)
	End
	
#Rem
Summary: Returns the item that exists at the requested index.
If the stack is empty or the index is out of bounds, the default value for T will be returned.
Debug build will throw an IndexOutOfBoundsException if the index is not in the range 0 <= index < Count().
#End
	Method GetItem:T(index:Int)
#If CONFIG="debug" Then
		CheckRange(index)
#End
		Return Self.Get(index)
	End
	
#Rem
Summary: Changes the item at the requested index to be the passed one instead.
If the stack is empty or the index is out of bounds, nothing happens.
Debug build will throw an IndexOutOfBoundsException if the index is not in the range 0 <= index < Count().
#End
	Method SetItem:Void(index:Int, value:T)
#If CONFIG="debug" Then
		CheckRange(index)
#End
		Self.Set(index, value)
	End
	
#Rem
Summary: Attempts to find the index of the first occurrence of the passed item.
If the stack is empty or the item could not be found, -1 is returned.
#End
	Method FindItem:Int(value:T)
		Return Self.Find(value)
	End
	
#Rem
Summary: Sorts the DiddyStack using the default Monkey sorting algorithm, comparing items with an IComparator or IComparable.
#End
	Method SortItems:Void(ascending:Bool = True)
		Sort(ascending)
	End
	
#Rem
Summary: Returns the number items in the DiddyStack.
#End
	Method Count:Int()
		Return Self.Length
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
Summary: Returns a new T[] array of length Count(), containing all the items in the DiddyStack, in order.
#End
	Method ToArray:T[]()
		Return Super.ToArray()
	End
	
#Rem
Summary: Populates the passed T[] array with all the elements in the DiddyStack.
If the array is too small to fit the entire stack, an IllegalArgumentException is thrown.
The number of values successfully filled is returned.
#End
	Method FillArray:Int(arr:T[])
		Local cnt:Int = Count()
		If arr.Length < cnt Then Throw New IllegalArgumentException("DiddyStack.FillArray: Array length too small ("+arr.Length+"<"+cnt+")")
		For Local i:Int = 0 Until Count()
			arr[i] = Get(i)
		Next
		Return cnt
	End
	
#Rem
Summary: Returns True if the DiddyStack is empty.
#End
	Method IsEmpty:Bool()
		Return Super.IsEmpty()
	End
	
#Rem
Summary: Reverses the order of elements in the stack.
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
#If CONFIG="debug" Then
		CheckRange(index1)
		CheckRange(index2)
#End
		Local temp:T = Self.Get(index1)
		Self.Set(index1, Self.Get(index2))
		Self.Set(index2, temp)
	End
	
#Rem
Summary: Randomises the order of elements in the stack.
#End
	Method Shuffle:Void()
		For Local i:Int = Count() - 1 To 0 Step -1
			SwapItems(i, Rnd(i))
		Next
	End
	
#Rem
Summary: Reduces the number of items in the stack to be no more than the passed size.
If there are less or equal elements in the stack than the passed size, nothing happens.
If there are more elements in the stack than the passed size, elements are removed from the end
until Count() = the requested size.
If building with debug, an IllegalArgumentException is thrown if the requested size < 0.
#End
	Method Truncate:Void(size:Int)
		While Count() > size
			Pop()
		End
	End
	
#Rem
Summary: Returns a custom IEnumerable that optionally supports a predicate.
#End
	Method Items:IEnumerable<T>(pred:IPredicate<T>=Null)
		Return New WrappedStackEnumerable<T>(Self, pred)
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
Summary: Extends DiddyStack to provide Int-specific equality and comparison (to avoid the IComparable check).
Similar to IntStack.
#End
Class DiddyIntStack Extends DiddyStack<Int>
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
Summary: Extends DiddyStack to provide Float-specific equality and comparison (to avoid the IComparable check).
Similar to FloatStack.
#End
Class DiddyFloatStack Extends DiddyStack<Float>
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
Summary: Extends DiddyStack to provide String-specific equality and comparison (to avoid the IComparable check).
Similar to StringStack.
#End
Class DiddyStringStack Extends DiddyStack<String>
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
