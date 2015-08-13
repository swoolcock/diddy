#Rem
Copyright (c) 2011 Steve Revill and Shane Woolcock
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#End

#Rem
Header: Provides the DiddyDeque class and associated utility classes.
#End

Strict
Private
Import diddy.containers
Import diddy.exception

Public
#Rem
Summary: The DiddyDeque class extends the official Monkey Deque class and implements Diddy's IContainer interface.
As with the other Diddy container classes, it simplifies mixing and matching of container types by sharing
common method names.  It also adds some missing functionality, such as sorting and element removal.
#End
Class DiddyDeque<T> Extends Deque<T> Implements IContainer<T>
Private
	Global NIL:T
	
	Method CheckRange:Void(index:Int, low:Int=0, high:Int=-1)
		If high < 0 Then high = Self.Count()
		If index < low Or index >= high Then
			Throw New IndexOutOfBoundsException("DiddyDeque.CheckRange: index " + index + " not in range " + low + " <= index < " + high)
		End
	End
	
Public
#Rem
Summary: Constructor to create an empty DiddyDeque.
#End
	Method New()
		Super.New()
	End

#Rem
Summary: Constructor to create a DiddyDeque with the contents of the passed array.
#End
	Method New(data:T[])
		Super.New(data)
	End
	
#Rem
Summary: Constructor to create a DiddyDeque with the contents of the passed Stack.
Throws IllegalArgumentException if src is Null.
#End
	Method New(src:Stack<T>, pred:IPredicate<T>=Null)
		If Not src Then Throw New IllegalArgumentException("DiddyDeque.New: Source Stack must not be null")
		AddAll(src, pred)
	End
	
#Rem
Summary: Constructor to create a DiddyDeque with the contents of the passed List.
Throws IllegalArgumentException if src is Null.
#End
	Method New(src:List<T>, pred:IPredicate<T>=Null)
		If Not src Then Throw New IllegalArgumentException("DiddyDeque.New: Source List must not be null")
		AddAll(src, pred)
	End
	
#Rem
Summary: Constructor to create a DiddyDeque with the contents of the passed Set.
Throws IllegalArgumentException if src is Null.
#End
	Method New(src:Set<T>, pred:IPredicate<T>=Null)
		If Not src Then Throw New IllegalArgumentException("DiddyDeque.New: Source Set must not be null")
		AddAll(src, pred)
	End
	
#Rem
Summary: Constructor to create a DiddyDeque with the contents of the passed Deque.
Throws IllegalArgumentException if src is Null.
#End
	Method New(src:Deque<T>, pred:IPredicate<T>=Null)
		If Not src Then Throw New IllegalArgumentException("DiddyDeque.New: Source Deque must not be null")
		AddAll(src, pred)
	End
	
#Rem
Summary: Adds the entire contents of the passed Stack to the DiddyDeque.
Throws IllegalArgumentException if src is Null.
#End
	Method AddAll:Void(src:Stack<T>) ' Implements IContainer
		If Not src Then Throw New IllegalArgumentException("DiddyDeque.AddAll: Source Stack must not be null")
		For Local val := EachIn src
			Self.PushLast(val)
		Next
	End

	Method AddAll:Void(src:Stack<T>, pred:IPredicate<T>) ' Implements IPredicateContainer
		If Not src Then Throw New IllegalArgumentException("DiddyDeque.AddAll: Source Stack must not be null")
		If Not pred Then Throw New IllegalArgumentException("DiddyDeque.AddAll: Predicate must not be null")
		For Local val := EachIn src
			If pred.Evaluate(val) Then Self.PushLast(val)
		Next
	End

#Rem
Summary: Adds the entire contents of the passed List to the DiddyDeque.
Throws IllegalArgumentException if src is Null.
#End
	Method AddAll:Void(src:List<T>) ' Implements IContainer
		If Not src Then Throw New IllegalArgumentException("DiddyDeque.AddAll: Source List must not be null")
		For Local val := EachIn src
			Self.PushLast(val)
		Next
	End
	
	Method AddAll:Void(src:List<T>, pred:IPredicate<T>) ' Implements IPredicateContainer
		If Not src Then Throw New IllegalArgumentException("DiddyDeque.AddAll: Source List must not be null")
		If Not pred Then Throw New IllegalArgumentException("DiddyDeque.AddAll: Predicate must not be null")
		For Local val := EachIn src
			If pred.Evaluate(val) Then Self.PushLast(val)
		Next
	End
	
#Rem
Summary: Adds the entire contents of the passed Set to the DiddyDeque.
Throws IllegalArgumentException if src is Null.
#End
	Method AddAll:Void(src:Set<T>) ' Implements IContainer
		If Not src Then Throw New IllegalArgumentException("DiddyDeque.AddAll: Source Set must not be null")
		For Local val := Eachin src
			Self.PushLast(val)
		Next
	End
	
	Method AddAll:Void(src:Set<T>, pred:IPredicate<T>) ' Implements IPredicateContainer
		If Not src Then Throw New IllegalArgumentException("DiddyDeque.AddAll: Source Set must not be null")
		If Not pred Then Throw New IllegalArgumentException("DiddyDeque.AddAll: Predicate must not be null")
		For Local val := Eachin src
			If pred.Evaluate(val) Then Self.PushLast(val)
		Next
	End
	
#Rem
Summary: Adds the entire contents of the passed Deque to the DiddyDeque.
Throws IllegalArgumentException if src is Null.
#End
	Method AddAll:Void(src:Deque<T>)
		If Not src Then Throw New IllegalArgumentException("DiddyDeque.AddAll: Source Deque must not be null")
		For Local val := Eachin src
			Self.PushLast(val)
		Next
	End
	
	Method AddAll:Void(src:Deque<T>, pred:IPredicate<T>) ' Implements IPredicateContainer
		If Not src Then Throw New IllegalArgumentException("DiddyDeque.AddAll: Source Deque must not be null")
		If Not pred Then Throw New IllegalArgumentException("DiddyDeque.AddAll: Predicate must not be null")
		For Local val := Eachin src
			If pred.Evaluate(val) Then Self.PushLast(val)
		Next
	End
	
#Rem
Summary: Adds the entire contents of another container to this DiddyDeque.
Throws IllegalArgumentException if src is Null.
#End
	Method AddContainer:Void(src:IContainer<T>)
		If Not src Then Throw New IllegalArgumentException("DiddyDeque.AddContainer: Source IContainer must not be null")
		For Local val := EachIn src.Items()
			Self.PushLast(val)
		Next
	End
	
	Method AddContainer:Void(src:IContainer<T>, pred:IPredicate<T>) ' Implements IPredicateContainer
		If Not src Then Throw New IllegalArgumentException("DiddyDeque.AddContainer: Source IContainer must not be null")
		If Not pred Then Throw New IllegalArgumentException("DiddyDeque.AddContainer: Predicate must not be null")
		For Local val := EachIn src.Items()
			If pred.Evaluate(val) Then Self.PushLast(val)
		Next
	End
	
#Rem
Summary: Removes from this DiddyDeque anything that also exists in the passed Stack.
Throws IllegalArgumentException if src is Null.
#End
	Method RemoveAll:Void(src:Stack<T>)
		If Not src Then Throw New IllegalArgumentException("DiddyDeque.RemoveAll: Source Stack must not be null")
		For Local val := Eachin src
			Self._RemoveEach(val)
		Next
	End
	
	Method RemoveAll:Void(src:Stack<T>, pred:IPredicate<T>) ' Implements IPredicateContainer
		If Not src Then Throw New IllegalArgumentException("DiddyDeque.RemoveAll: Source Stack must not be null")
		If Not pred Then Throw New IllegalArgumentException("DiddyDeque.RemoveAll: Predicate must not be null")
		For Local val := Eachin src
			If pred.Evaluate(val) Then Self._RemoveEach(val)
		Next
	End
	
#Rem
Summary: Removes from this DiddyDeque anything that also exists in the passed List.
Throws IllegalArgumentException if src is Null.
#End
	Method RemoveAll:Void(src:List<T>)
		If Not src Then Throw New IllegalArgumentException("DiddyDeque.RemoveAll: Source List must not be null")
		For Local val := Eachin src
			Self._RemoveEach(val)
		Next
	End
	
	Method RemoveAll:Void(src:List<T>, pred:IPredicate<T>) ' Implements IPredicateContainer
		If Not src Then Throw New IllegalArgumentException("DiddyDeque.RemoveAll: Source List must not be null")
		If Not pred Then Throw New IllegalArgumentException("DiddyDeque.RemoveAll: Predicate must not be null")
		For Local val := Eachin src
			If pred.Evaluate(val) Then Self._RemoveEach(val)
		Next
	End
	
#Rem
Summary: Removes from this DiddyDeque anything that also exists in the passed Set.
Throws IllegalArgumentException if src is Null.
#End
	Method RemoveAll:Void(src:Set<T>)
		If Not src Then Throw New IllegalArgumentException("DiddyDeque.RemoveAll: Source Set must not be null")
		For Local val := Eachin src
			Self._RemoveEach(val)
		Next
	End
	
	Method RemoveAll:Void(src:Set<T>, pred:IPredicate<T>) ' Implements IPredicateContainer
		If Not src Then Throw New IllegalArgumentException("DiddyDeque.RemoveAll: Source Set must not be null")
		If Not pred Then Throw New IllegalArgumentException("DiddyDeque.RemoveAll: Predicate must not be null")
		For Local val := Eachin src
			If pred.Evaluate(val) Then Self._RemoveEach(val)
		Next
	End
	
#Rem
Summary: Removes from this DiddyDeque anything that also exists in the passed Deque.
Throws IllegalArgumentException if src is Null.
#End
	Method RemoveAll:Void(src:Deque<T>)
		If Not src Then Throw New IllegalArgumentException("DiddyDeque.RemoveAll: Source Deque must not be null")
		For Local val := Eachin src
			Self._RemoveEach(val)
		Next
	End
	
	Method RemoveAll:Void(src:Deque<T>, pred:IPredicate<T>) ' Implements IPredicateContainer
		If Not src Then Throw New IllegalArgumentException("DiddyDeque.RemoveAll: Source Deque must not be null")
		If Not pred Then Throw New IllegalArgumentException("DiddyDeque.RemoveAll: Predicate must not be null")
		For Local val := Eachin src
			If pred.Evaluate(val) Then Self._RemoveEach(val)
		Next
	End
	
#Rem
Summary: Removes from this DiddyDeque anything that also exists in the passed container.
Throws IllegalArgumentException if src is Null.
#End
	Method RemoveContainer:Void(src:IContainer<T>)
		If Not src Then Throw New IllegalArgumentException("DiddyDeque.RemoveContainer: Source IContainer must not be null")
		For Local val := Eachin src.Items()
			Self._RemoveEach(val)
		Next
	End
	
	Method RemoveContainer:Void(src:IContainer<T>, pred:IPredicate<T>) ' Implements IPredicateContainer
		If Not src Then Throw New IllegalArgumentException("DiddyDeque.RemoveContainer: Source IContainer must not be null")
		If Not pred Then Throw New IllegalArgumentException("DiddyDeque.RemoveContainer: Predicate must not be null")
		For Local val := Eachin src.Items()
			If pred.Evaluate(val) Then Self._RemoveEach(val)
		Next
	End
	
#Rem
Summary: Removes from this DiddyDeque anything that does NOT exist in the passed Stack.
Throws IllegalArgumentException if src is Null.
#End
	Method RetainAll:Void(src:Stack<T>)
		If Not src Then Throw New IllegalArgumentException("DiddyDeque.RetainAll: Source Stack must not be null")
		Local arr:T[] = Self.ToArray()
		For Local val := Eachin arr
			If Not src.Contains(val) Then
				Self._RemoveEach(val)
			End
		Next
	End
	
	Method RetainAll:Void(src:Stack<T>, pred:IPredicate<T>) ' Implements IPredicateContainer
		If Not src Then Throw New IllegalArgumentException("DiddyDeque.RetainAll: Source Stack must not be null")
		If Not pred Then Throw New IllegalArgumentException("DiddyDeque.RetainAll: Predicate must not be null")
		Local arr:T[] = Self.ToArray()
		For Local val := Eachin arr
			If pred.Evaluate(val) And Not src.Contains(val) Then
				Self._RemoveEach(val)
			End
		Next
	End
	
#Rem
Summary: Removes from this DiddyDeque anything that does NOT exist in the passed List.
Throws IllegalArgumentException if src is Null.
#End
	Method RetainAll:Void(src:List<T>)
		If Not src Then Throw New IllegalArgumentException("DiddyDeque.RetainAll: Source List must not be null")
		Local arr:T[] = Self.ToArray()
		For Local val := Eachin arr
			If Not src.Contains(val) Then
				Self._RemoveEach(val)
			End
		Next
	End
	
	Method RetainAll:Void(src:List<T>, pred:IPredicate<T>) ' Implements IPredicateContainer
		If Not src Then Throw New IllegalArgumentException("DiddyDeque.RetainAll: Source List must not be null")
		If Not pred Then Throw New IllegalArgumentException("DiddyDeque.RetainAll: Predicate must not be null")
		Local arr:T[] = Self.ToArray()
		For Local val := Eachin arr
			If pred.Evaluate(val) And Not src.Contains(val) Then
				Self._RemoveEach(val)
			End
		Next
	End
	
#Rem
Summary: Removes from this DiddyDeque anything that does NOT exist in the passed Set.
Throws IllegalArgumentException if src is Null.
#End
	Method RetainAll:Void(src:Set<T>)
		If Not src Then Throw New IllegalArgumentException("DiddyDeque.RetainAll: Source Set must not be null")
		Local arr:T[] = Self.ToArray()
		For Local val := Eachin arr
			If Not src.Contains(val) Then
				Self._RemoveEach(val)
			End
		Next
	End
	
	Method RetainAll:Void(src:Set<T>, pred:IPredicate<T>) ' Implements IPredicateContainer
		If Not src Then Throw New IllegalArgumentException("DiddyDeque.RetainAll: Source Set must not be null")
		If Not pred Then Throw New IllegalArgumentException("DiddyDeque.RetainAll: Predicate must not be null")
		Local arr:T[] = Self.ToArray()
		For Local val := Eachin arr
			If pred.Evaluate(val) And Not src.Contains(val) Then
				Self._RemoveEach(val)
			End
		Next
	End
	
#Rem
Summary: Removes from this DiddyDeque anything that does NOT exist in the passed Deque.
Throws IllegalArgumentException if src is Null.
#End
	Method RetainAll:Void(src:Deque<T>)
		If Not src Then Throw New IllegalArgumentException("DiddyDeque.RetainAll: Source Deque must not be null")
		Local arr:T[] = Self.ToArray()
		For Local val := Eachin arr
			If Not ContainerUtil<T>.DequeContains(src, val) Then
				Self._RemoveEach(val)
			End
		Next
	End
	
	Method RetainAll:Void(src:Deque<T>, pred:IPredicate<T>) ' Implements IPredicateContainer
		If Not src Then Throw New IllegalArgumentException("DiddyDeque.RetainAll: Source Deque must not be null")
		If Not pred Then Throw New IllegalArgumentException("DiddyDeque.RetainAll: Predicate must not be null")
		Local arr:T[] = Self.ToArray()
		For Local val := Eachin arr
			If pred.Evaluate(val) And Not ContainerUtil<T>.DequeContains(src, val) Then
				Self._RemoveEach(val)
			End
		Next
	End
	
#Rem
Summary: Removes from this DiddyDeque anything that does NOT exist in the passed container.
Throws IllegalArgumentException if src is Null.
#End
	Method RetainContainer:Void(src:IContainer<T>)
		If Not src Then Throw New IllegalArgumentException("DiddyDeque.RetainContainer: Source IContainer must not be null")
		Local arr:T[] = Self.ToArray()
		For Local val := Eachin arr
			If Not src.ContainsItem(val) Then
				Self._RemoveEach(val)
			End
		Next
	End
	
	Method RetainContainer:Void(src:IContainer<T>, pred:IPredicate<T>) ' Implements IPredicateContainer
		If Not src Then Throw New IllegalArgumentException("DiddyDeque.RetainContainer: Source IContainer must not be null")
		If Not pred Then Throw New IllegalArgumentException("DiddyDeque.RetainContainer: Predicate must not be null")
		Local arr:T[] = Self.ToArray()
		For Local val := Eachin arr
			If pred.Evaluate(val) And Not src.ContainsItem(val) Then
				Self._RemoveEach(val)
			End
		Next
	End
	
#Rem
Summary: Returns True if this DiddyDeque contains ALL of the items in the passed Stack.
Throws IllegalArgumentException if src is Null.
#End
	Method ContainsAll:Bool(src:Stack<T>)
		If Not src Then Throw New IllegalArgumentException("DiddyDeque.ContainsAll: Source Stack must not be null")
		For Local val := Eachin src
			If Not Self.ContainsItem(val) Return False
		Next
		Return True
	End
	
	Method ContainsAll:Bool(src:Stack<T>, pred:IPredicate<T>) ' Implements IPredicateContainer
		If Not src Then Throw New IllegalArgumentException("DiddyDeque.ContainsAll: Source Stack must not be null")
		If Not pred Then Throw New IllegalArgumentException("DiddyDeque.ContainsAll: Predicate must not be null")
		For Local val := Eachin src
			If pred.Evaluate(val) And Not Self.ContainsItem(val) Return False
		Next
		Return True
	End
	
#Rem
Summary: Returns True if this DiddyDeque contains ALL of the items in the passed List.
Throws IllegalArgumentException if src is Null.
#End
	Method ContainsAll:Bool(src:List<T>)
		If Not src Then Throw New IllegalArgumentException("DiddyDeque.ContainsAll: Source List must not be null")
		For Local val := Eachin src
			If Not Self.ContainsItem(val) Return False
		Next
		Return True
	End
	
	Method ContainsAll:Bool(src:List<T>, pred:IPredicate<T>) ' Implements IPredicateContainer
		If Not src Then Throw New IllegalArgumentException("DiddyDeque.ContainsAll: Source List must not be null")
		If Not pred Then Throw New IllegalArgumentException("DiddyDeque.ContainsAll: Predicate must not be null")
		For Local val := Eachin src
			If pred.Evaluate(val) And Not Self.ContainsItem(val) Return False
		Next
		Return True
	End
	
#Rem
Summary: Returns True if this DiddyDeque contains ALL of the items in the passed Set.
Throws IllegalArgumentException if src is Null.
#End
	Method ContainsAll:Bool(src:Set<T>)
		If Not src Then Throw New IllegalArgumentException("DiddyDeque.ContainsAll: Source Set must not be null")
		For Local val := Eachin src
			If Not Self.ContainsItem(val) Return False
		Next
		Return True
	End
	
	Method ContainsAll:Bool(src:Set<T>, pred:IPredicate<T>) ' Implements IPredicateContainer
		If Not src Then Throw New IllegalArgumentException("DiddyDeque.ContainsAll: Source Set must not be null")
		If Not pred Then Throw New IllegalArgumentException("DiddyDeque.ContainsAll: Predicate must not be null")
		For Local val := Eachin src
			If pred.Evaluate(val) And Not Self.ContainsItem(val) Return False
		Next
		Return True
	End
	
#Rem
Summary: Returns True if this DiddyDeque contains ALL of the items in the passed Deque.
Throws IllegalArgumentException if src is Null.
#End
	Method ContainsAll:Bool(src:Deque<T>)
		If Not src Then Throw New IllegalArgumentException("DiddyDeque.ContainsAll: Source Deque must not be null")
		For Local val := Eachin src
			If Not Self.ContainsItem(val) Return False
		Next
		Return True
	End
	
	Method ContainsAll:Bool(src:Deque<T>, pred:IPredicate<T>) ' Implements IPredicateContainer
		If Not src Then Throw New IllegalArgumentException("DiddyDeque.ContainsAll: Source Deque must not be null")
		If Not pred Then Throw New IllegalArgumentException("DiddyDeque.ContainsAll: Predicate must not be null")
		For Local val := Eachin src
			If pred.Evaluate(val) And Not Self.ContainsItem(val) Return False
		Next
		Return True
	End
	
#Rem
Summary: Returns True if this DiddyDeque contains ALL of the items in the passed container.
Throws IllegalArgumentException if src is Null.
#End
	Method ContainsContainer:Bool(src:IContainer<T>)
		If Not src Then Throw New IllegalArgumentException("DiddyDeque.ContainsContainer: Source IContainer must not be null")
		For Local val := Eachin src.Items()
			If Not Self.ContainsItem(val) Return False
		Next
		Return True
	End
	
	Method ContainsContainer:Bool(src:IContainer<T>, pred:IPredicate<T>) ' Implements IPredicateContainer
		If Not src Then Throw New IllegalArgumentException("DiddyDeque.ContainsContainer: Source IContainer must not be null")
		If Not pred Then Throw New IllegalArgumentException("DiddyDeque.ContainsContainer: Predicate must not be null")
		For Local val := Eachin src.Items()
			If pred.Evaluate(val) And Not Self.ContainsItem(val) Return False
		Next
		Return True
	End
	
#Rem
Summary: Adds the passed value to the DiddyDeque.
#End
	Method AddItem:Void(val:T)
		Self.PushLast(val)
	End
	
#Rem
Summary: Removes the passed value from the DiddyDeque if it exists.
#End
	Method RemoveItem:Bool(val:T)
		Local cnt:Int = Count()
		Self._RemoveEach(val)
		Return cnt <> Count()
	End
	
#Rem
Summary: Adds the passed value to the DiddyDeque, before the requested index.
If the index is the same as Count(), it will be added to the end of the DiddyDeque.
Debug build will throw an IndexOutOfBoundsException if the index is not in the range 0 <= index <= Count().
#End
	Method InsertItem:Void(index:Int, val:T)
#If CONFIG="debug" Then
		CheckRange(index,,Self.Count()+1)
#End
		Self._Insert(index, val)
	End
	
#Rem
Summary: Removes the item from the DiddyDeque that exists at the requested index.
Debug build will throw an IndexOutOfBoundsException if the index is not in the range 0 <= index < Count().
#End
	Method DeleteItem:T(index:Int)
#If CONFIG="debug" Then
		CheckRange(index)
#End
		Local rv:T = Self.Get(index)
		Self._Remove(index)
		Return rv
	End
	
#Rem
Summary: Removes all items from the DiddyDeque.
#End
	Method ClearAll:Void()
		Self.Clear()
	End
	
	Method ClearFiltered:Void(pred:IPredicate<T>)
		If Not pred Then Throw New IllegalArgumentException("DiddyDeque.ClearFiltered: Predicate must not be null")
		Local tmp:Stack<T> = New Stack<T>
		For Local val := Eachin Self
			If Not pred.Evaluate(val) Then tmp.Push(val)
		End
		Self.Clear()
		Self.AddAll(tmp)
	End
	
#Rem
Summary: Returns True if the DiddyDeque contains the passed value.
#End
	Method ContainsItem:Bool(value:T)
		Return ContainerUtil<T>.DequeContains(Self, value)
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
If the deque is empty or the item could not be found, -1 is returned.
We must perform our own implementation of Find, since it is not provided by the official class.
#End
	Method FindItem:Int(value:T)
		For Local i:Int = 0 Until Count()
			If Get(i) = value Then Return i
		Next
		Return -1
	End
	
#Rem
Summary: Sorts the DiddyDeque using the default Monkey sorting algorithm (copied from Stack),
comparing items with an IComparator or IComparable.  Since we do not have direct access to the
deque's internal array, this requires many method calls and performance may be less than optimal.
#End
	Method SortItems:Void(ascending:Bool = True)
		' die if the deque is empty
		If IsEmpty() Then Return
		Local t:Int = 1
		If Not ascending Then t = -1
		_Sort(0, Count()-1, t)
	End
	
#Rem
Summary: Returns the number items in the DiddyDeque.
#End
	Method Count:Int()
		Return Self.Length
	End
	
	Method FilteredCount:Int(pred:IPredicate<T>)
		Return ToFilteredArray(pred).Length
	End
	
#Rem
Summary: Compares two values of the generic type T, for sorting.
Called automatically by Monkey's sorting algorithm, it first attempts to use an IComparator if it exists.
If not it will attempt to use the IComparable CompareTo method if T implements it.
Finally, it will throw an exception, as there is no default comparison method for Deques.
#End
	Method Compare:Int(lhs:T, rhs:T)
		If Self.comparator Then Return Self.comparator.Compare(lhs, rhs)
		If IComparableWrapper.IsComparable(lhs) Or IComparableWrapper.IsComparable(rhs) Then Return IComparableWrapper.Compare(lhs, rhs)
		Throw New UnsupportedOperationException("DiddyDeque.Compare: Generic type has does not implement IComparable and there is no comparator assigned to this DiddyDeque.")
	End
	
#Rem
Summary: Returns True if the items are referentially equal (for Objects) or equal by value (for primitives).
#End
	Method Equals:Bool(lhs:T, rhs:T)
		Return lhs = rhs
	End
	
#Rem
Summary: Returns a new T[] array of length Count(), containing all the items in the DiddyDeque, in order.
#End
	Method ToArray:T[]()
		Return Super.ToArray()
	End
	
	Method ToFilteredArray:T[](pred:IPredicate<T>)
		Local tmp:IContainer<T> = New DiddyDeque<T>(Self, pred)
		Return tmp.ToArray()
	End
	
#Rem
Summary: Populates the passed T[] array with all the elements in the DiddyDeque.
If the array is too small to fit the entire stack, an IllegalArgumentException is thrown.
The number of values successfully filled is returned.
#End
	Method FillArray:Int(arr:T[])
		Local cnt:Int = Count()
		If arr.Length < cnt Then Throw New IllegalArgumentException("DiddyDeque.FillArray: Array length too small ("+arr.Length+"<"+cnt+")")
		For Local i:Int = 0 Until Count()
			arr[i] = Get(i)
		Next
		Return cnt
	End
	
	Method FillFilteredArray:Int(arr:T[], pred:IPredicate<T>)
		Local tmp:IContainer<T> = New DiddyDeque<T>(Self, pred)
		Local cnt:Int = tmp.Count()
		If arr.Length < cnt Then Throw New IllegalArgumentException("DiddyDeque.FillArray: Array length too small ("+arr.Length+"<"+cnt+")")
		Return tmp.FillArray(arr)
	End
	
#Rem
Summary: Returns True if the DiddyDeque is empty.
#End
	Method IsEmpty:Bool()
		Return Super.IsEmpty()
	End
	
#Rem
Summary: Reverses the order of elements in the deque.
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
		_Swap(index1, index2)
	End
	
#Rem
Summary: Randomises the order of elements in the deque.
#End
	Method Shuffle:Void()
		For Local i:Int = Count() - 1 To 0 Step -1
			SwapItems(i, Rnd(i))
		Next
	End
	
#Rem
Summary: Reduces the number of items in the deque to be no more than the passed size.
If there are less or equal elements in the deque than the passed size, nothing happens.
If there are more elements in the deque than the passed size, elements are removed from the end
until Count() = the requested size.
If building with debug, an IllegalArgumentException is thrown if the requested size < 0.
#End
	Method Truncate:Void(size:Int)
		While Count() > size
			PopLast()
		End
	End
	
#Rem
Summary: Returns a custom IEnumerable that optionally supports a predicate.
#End
	Method Items:IEnumerable<T>()
		Return New WrappedDequeEnumerable<T>(Self)
	End
	
	Method FilteredItems:IEnumerable<T>(pred:IPredicate<T>)
		Return New WrappedDequeEnumerable<T>(Self, pred)
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
	
#Rem
Summary: Returns a read-only wrapper on this container.
#End
	Method ReadOnly:ReadOnlyContainer<T>(snapshot:Bool=False)
		Return New ReadOnlyContainer<T>(Self, snapshot)
	End
	
Private
	Method _Insert:Void(index:Int, item:T)
		' clamp index from 0 to Count()
		If index < 0 Then index = 0 ElseIf index > Count() Then index = Count()
		' if the index is less than halfway, we work from the start
		If index < Count()/2 Then
			' move elements from front to back, until the index
			For Local i:Int = 0 Until index
				Self.PushLast(Self.PopFirst())
			Next
			' insert the new one
			Self.PushFirst(item)
			' move elements back
			For Local i:Int = 0 Until index
				Self.PushFirst(Self.PopLast())
			Next
		' else if the index is over halfway, we work from the end
		Else
			' move elements from front to back, until the index
			For Local i:Int = 0 Until index
				Self.PushFirst(Self.PopLast())
			Next
			' insert the new one
			Self.PushLast(item)
			' move elements back
			For Local i:Int = 0 Until index
				Self.PushLast(Self.PopFirst())
			Next
		End
	End
	
	Method _Remove:Void(index:Int)
		' clamp index from 0 to Count()-1
		If index < 0 Then index = 0 ElseIf index >= Count() Then index = Count()-1
		' if the index is less than halfway, we work from the start
		If index < Count()/2 Then
			' move elements from front to back, until the index
			For Local i:Int = 0 Until index
				Self.PushLast(Self.PopFirst())
			Next
			' pop an extra one
			Self.PopFirst()
			' move elements back
			For Local i:Int = 0 Until index
				Self.PushFirst(Self.PopLast())
			Next
			' else if the index is over halfway, we work from the end
		Else
			' move elements from front to back, until the index
			For Local i:Int = 0 Until index
				Self.PushFirst(Self.PopLast())
			Next
			' pop an extra one
			Self.PopLast()
			' move elements back
			For Local i:Int = 0 Until index
				Self.PushLast(Self.PopFirst())
			Next
		End
	End
	
	Method _RemoveEach:Void(item:T)
		' get the count BEFORE removing
		Local count:Int = Self.Count()
		' loop through, popping and optionally pushing
		For Local i:Int = 0 Until count
			Local it:T = Self.PopLast()
			If it <> item Then Self.PushFirst(it)
		Next
	End
	
	Method _Swap:Void(x:Int, y:Int) Final
		Local t := Get(x)
		Set(x, Get(y))
		Set(y, t)
	End
	
	Method _LessIndexIndex:Bool(x:Int, y:Int, ascending:Int) Final
		Return Compare(Get(x), Get(y)) * ascending < 0
	End
	
	Method _LessIndexItem:Bool(x:Int, y:T, ascending:Int) Final
		Return Compare(Get(x), y) * ascending < 0
	End
	
	Method _LessItemIndex:Bool(x:T, y:Int, ascending:Int) Final
		Return Compare(x, Get(y)) * ascending < 0
	End
	
	Method _Sort:Void(lo:Int, hi:Int, ascending:Int) Final
		If hi <= lo Then Return
		If lo + 1 = hi Then
			If _LessIndexIndex(hi, lo, ascending) Then _Swap(hi, lo)
			Return
		End
		Local i:Int = (hi - lo) / 2 + lo
		If _LessIndexIndex(i, lo, ascending) Then _Swap(i, lo)
		If _LessIndexIndex(hi, i, ascending) Then
			_Swap(hi, i)
			If _LessIndexIndex(i, lo, ascending) Then _Swap(i, lo)
		End
		Local x:Int = lo + 1
		Local y:Int = hi - 1
		Repeat
			Local p:T = Get(i)
			While _LessIndexItem(x, p, ascending)
				x += 1
			End
			While _LessItemIndex(p, y, ascending)
				y -= 1
			End
			If x > y Then Exit
			If x < y Then
				_Swap(x, y)
				If i = x Then
					i = y
				Elseif i = y Then
					i = x
				End
			Endif
			x += 1
			y -= 1
		Until x > y
		_Sort(lo, y, ascending)
		_Sort(x, hi, ascending)
	End
End

#Rem
Summary: Extends DiddyDeque to provide Int-specific equality and comparison (to avoid the IComparable check).
Similar to IntDeque.
#End
Class DiddyIntDeque Extends DiddyDeque<Int>
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
Summary: Extends DiddyDeque to provide Float-specific equality and comparison (to avoid the IComparable check).
Similar to FloatDeque.
#End
Class DiddyFloatDeque Extends DiddyDeque<Float>
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
Summary: Extends DiddyDeque to provide String-specific equality and comparison (to avoid the IComparable check).
Similar to StringDeque.
#End
Class DiddyStringDeque Extends DiddyDeque<String>
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
