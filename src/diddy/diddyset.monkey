#Rem
Copyright (c) 2011 Steve Revill and Shane Woolcock
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#End

#Rem
Header: Provides the DiddySet class and associated utility classes.
#End

Strict
Private
Import diddy.containers
Import diddy.exception

Public
#Rem
Summary: The DiddySet class extends the official Monkey Set class and implements Diddy's IContainer interface.
As with the other Diddy container classes, it simplifies mixing and matching of container types by sharing
common method names.
Note that since Set is unordered, many of the IContainer methods are non-applicable or have undefined results.
#End
Class DiddySet<T> Extends Set<T> Implements IContainer<T>
Private
	Global NIL:T
	
Public
#Rem
Summary: Constructor to create an empty DiddySet.
#End
	Method New()
		Super.New()
	End

#Rem
Summary: Constructor to create a DiddySet with the contents of the passed Map.
#End
	Method New(m:Map<T,Object>)
		Super.New(m)
	End
	
#Rem
Summary: Constructor to create a DiddySet with the contents of the passed Stack.
Throws IllegalArgumentException if src is Null.
#End
	Method New(src:Stack<T>)
		If Not src Then Throw New IllegalArgumentException("DiddySet.New: Source Stack must not be null")
		AddAll(src)
	End
	
#Rem
Summary: Constructor to create a DiddySet with the contents of the passed List.
Throws IllegalArgumentException if src is Null.
#End
	Method New(src:List<T>)
		If Not src Then Throw New IllegalArgumentException("DiddySet.New: Source List must not be null")
		AddAll(src)
	End
	
#Rem
Summary: Constructor to create a DiddySet with the contents of the passed Set.
Throws IllegalArgumentException if src is Null.
#End
	Method New(src:Set<T>)
		If Not src Then Throw New IllegalArgumentException("DiddySet.New: Source Set must not be null")
		AddAll(src)
	End
	
#Rem
Summary: Adds the entire contents of the passed Stack to the DiddySet.
Throws IllegalArgumentException if src is Null.
#End
	Method AddAll:Void(src:Stack<T>)
		If Not src Then Throw New IllegalArgumentException("DiddySet.AddAll: Source Stack must not be null")
		For Local val := EachIn src
			Self.Insert(val)
		Next
	End

#Rem
Summary: Adds the entire contents of the passed List to the DiddySet.
Throws IllegalArgumentException if src is Null.
#End
	Method AddAll:Void(src:List<T>)
		If Not src Then Throw New IllegalArgumentException("DiddySet.AddAll: Source List must not be null")
		For Local val := EachIn src
			Self.Insert(val)
		Next
	End
	
#Rem
Summary: Adds the entire contents of the passed Set to the DiddySet.
Throws IllegalArgumentException if src is Null.
#End
	Method AddAll:Void(src:Set<T>)
		If Not src Then Throw New IllegalArgumentException("DiddySet.AddAll: Source Set must not be null")
		For Local val := EachIn src
			Self.Insert(val)
		Next
	End
	
#Rem
Summary: Adds the entire contents of the passed container to the DiddySet.
Throws IllegalArgumentException if src is Null.
#End
	Method AddContainer:Void(src:IContainer<T>)
		If Not src Then Throw New IllegalArgumentException("DiddySet.AddContainer: Source IContainer must not be null")
		For Local val := EachIn src.Items()
			Self.Insert(val)
		Next
	End
	
#Rem
Summary: Removes from this DiddySet anything that also exists in the passed Stack.
Throws IllegalArgumentException if src is Null.
#End
	Method RemoveAll:Void(src:Stack<T>)
		If Not src Then Throw New IllegalArgumentException("DiddySet.RemoveAll: Source Stack must not be null")
		For Local val := EachIn src
			Self.Remove(val)
		Next
	End
	
#Rem
Summary: Removes from this DiddySet anything that also exists in the passed List.
Throws IllegalArgumentException if src is Null.
#End
	Method RemoveAll:Void(src:List<T>)
		If Not src Then Throw New IllegalArgumentException("DiddySet.RemoveAll: Source List must not be null")
		For Local val := EachIn src
			Self.Remove(val)
		Next
	End
	
#Rem
Summary: Removes from this DiddySet anything that also exists in the passed Set.
Throws IllegalArgumentException if src is Null.
#End
	Method RemoveAll:Void(src:Set<T>)
		If Not src Then Throw New IllegalArgumentException("DiddySet.RemoveAll: Source Set must not be null")
		For Local val := EachIn src
			Self.Remove(val)
		Next
	End
	
#Rem
Summary: Removes from this DiddySet anything that also exists in the passed container.
Throws IllegalArgumentException if src is Null.
#End
	Method RemoveContainer:Void(src:IContainer<T>)
		If Not src Then Throw New IllegalArgumentException("DiddySet.RemoveContainer: Source IContainer must not be null")
		For Local val := EachIn src.Items()
			Self.Remove(val)
		Next
	End
	
#Rem
Summary: Removes from this DiddySet anything that does NOT exist in the passed Stack.
Throws IllegalArgumentException if src is Null.
#End
	Method RetainAll:Void(src:Stack<T>)
		If Not src Then Throw New IllegalArgumentException("DiddySet.RetainAll: Source Stack must not be null")
		Local arr:T[] = Self.ToArray()
		For Local val := EachIn arr
			If Not src.Contains(val) Then
				Self.Remove(val)
			End
		Next
	End
	
#Rem
Summary: Removes from this DiddySet anything that does NOT exist in the passed List.
Throws IllegalArgumentException if src is Null.
#End
	Method RetainAll:Void(src:List<T>)
		If Not src Then Throw New IllegalArgumentException("DiddySet.RetainAll: Source List must not be null")
		Local arr:T[] = Self.ToArray()
		For Local val := EachIn arr
			If Not src.Contains(val) Then
				Self.Remove(val)
			End
		Next
	End
	
#Rem
Summary: Removes from this DiddySet anything that does NOT exist in the passed Set.
Throws IllegalArgumentException if src is Null.
#End
	Method RetainAll:Void(src:Set<T>)
		If Not src Then Throw New IllegalArgumentException("DiddySet.RetainAll: Source Set must not be null")
		Local arr:T[] = Self.ToArray()
		For Local val := EachIn arr
			If Not src.Contains(val) Then
				Self.Remove(val)
			End
		Next
	End
	
#Rem
Summary: Removes from this DiddySet anything that does NOT exist in the passed container.
Throws IllegalArgumentException if src is Null.
#End
	Method RetainContainer:Void(src:IContainer<T>)
		If Not src Then Throw New IllegalArgumentException("DiddySet.RetainContainer: Source IContainer must not be null")
		Local arr:T[] = Self.ToArray()
		For Local val := EachIn arr
			If Not src.ContainsItem(val) Then
				Self.Remove(val)
			End
		Next
	End
	
#Rem
Summary: Returns True if this DiddySet contains ALL of the items in the passed Stack.
Throws IllegalArgumentException if src is Null.
#End
	Method ContainsAll:Bool(src:Stack<T>)
		If Not src Then Throw New IllegalArgumentException("DiddySet.ContainsAll: Source Stack must not be null")
		For Local val := EachIn src
			If Not Self.Contains(val) Return False
		Next
		Return True
	End
	
#Rem
Summary: Returns True if this DiddySet contains ALL of the items in the passed List.
Throws IllegalArgumentException if src is Null.
#End
	Method ContainsAll:Bool(src:List<T>)
		If Not src Then Throw New IllegalArgumentException("DiddySet.ContainsAll: Source List must not be null")
		For Local val := EachIn src
			If Not Self.Contains(val) Return False
		Next
		Return True
	End
	
#Rem
Summary: Returns True if this DiddySet contains ALL of the items in the passed Set.
Throws IllegalArgumentException if src is Null.
#End
	Method ContainsAll:Bool(src:Set<T>)
		If Not src Then Throw New IllegalArgumentException("DiddySet.ContainsAll: Source Set must not be null")
		For Local val := EachIn src
			If Not Self.Contains(val) Return False
		Next
		Return True
	End
	
#Rem
Summary: Returns True if this DiddySet contains ALL of the items in the passed container.
Throws IllegalArgumentException if src is Null.
#End
	Method ContainsContainer:Bool(src:IContainer<T>)
		If Not src Then Throw New IllegalArgumentException("DiddySet.ContainsContainer: Source IContainer must not be null")
		For Local val := EachIn src.Items()
			If Not Self.Contains(val) Return False
		Next
		Return True
	End
	
#Rem
Summary: Adds the passed value to the DiddySet.
#End
	Method AddItem:Void(val:T)
		Self.Insert(val)
	End
	
#Rem
Summary: Removes the passed value from the DiddySet if it exists.
#End
	Method RemoveItem:Void(val:T)
		Self.Remove(val)
	End
	
#Rem
Summary: Throws an UnsupportedOperationException, since Set is unordered and it does not make sense to index it.
#End
	Method InsertItem:Void(index:Int, val:T)
		Throw New UnsupportedOperationException
	End
	
#Rem
Summary: Throws an UnsupportedOperationException, since Set is unordered and it does not make sense to index it.
#End
	Method DeleteItem:T(index:Int)
		Throw New UnsupportedOperationException
	End
	
#Rem
Summary: Removes all items from the DiddySet.
#End
	Method ClearAll:Void()
		Self.Clear()
	End
	
#Rem
Summary: Returns True if the DiddySet contains the passed value.
#End
	Method ContainsItem:Bool(value:T)
		Return Self.Contains(value)
	End
	
#Rem
Summary: Throws an UnsupportedOperationException, since Set is unordered and it does not make sense to index it.
#End
	Method GetItem:T(index:Int)
		Throw New UnsupportedOperationException
	End
	
#Rem
Summary: Throws an UnsupportedOperationException, since Set is unordered and it does not make sense to index it.
#End
	Method SetItem:Void(index:Int, value:T)
		Throw New UnsupportedOperationException
	End
	
#Rem
Summary: Throws an UnsupportedOperationException, since Set is unordered and items will have no fixed index.
#End
	Method FindItem:Int(value:T)
		Throw New UnsupportedOperationException
	End
	
#Rem
Summary: Throws an UnsupportedOperationException, since Set is unordered and it does not make sense to sort it.
#End
	Method SortItems:Void(ascending:Bool = True)
		Throw New UnsupportedOperationException
	End
	
#Rem
Summary: Returns the number items in the DiddySet.
#End
	Method Count:Int()
		Return Super.Count()
	End
	
#Rem
Summary: Throws an UnsupportedOperationException, since Set is unordered and it does not make sense to sort it.
#End
	Method Compare:Int(lhs:T, rhs:T)
		Throw New UnsupportedOperationException
	End
	
#Rem
Summary: Returns True if the items are referentially equal (for Objects) or equal by value (for primitives).
#End
	Method Equals:Bool(lhs:T, rhs:T)
		Return lhs = rhs
	End
	
#Rem
Summary: Returns a new T[] array of length Count(), containing all the items in the DiddySet.
Note that since Set is unordered, the order of items in the array is undefined.
#End
	Method ToArray:T[]()
		Local arr:T[] = New T[Self.Count()]
		Local i:Int = 0
		For Local v := EachIn Self
			arr[i] = v
			i += 1
		Next
		Return arr
	End
	
#Rem
Summary: Populates the passed T[] array with all the elements in the DiddySet.
If the array is too small to fit the entire set, an IllegalArgumentException is thrown.
The number of values successfully filled is returned.
Note that since Set is unordered, the order of items in the array is undefined.
#End
	Method FillArray:Int(arr:T[])
		Local cnt:Int = Self.Count()
		If arr.Length < cnt Then Throw New IllegalArgumentException("DiddySet.FillArray: Array length too small ("+arr.Length+"<"+cnt+")")
		Local i:Int = 0
		For Local v:T = EachIn Self
			arr[i] = v
			i += 1
		Next
		Return i
	End
	
#Rem
Summary: Returns True if the DiddySet is empty.
#End
	Method IsEmpty:Bool()
		Return Super.IsEmpty()
	End
	
#Rem
Summary: Throws an UnsupportedOperationException, since Set is unordered and it does not make sense to reverse it.
#End
	Method Reverse:Void()
		Throw New UnsupportedOperationException
	End
	
#Rem
Summary: Throws an UnsupportedOperationException, since Set is unordered and it does not make sense to index it.
#End
	Method SwapItems:Void(index1:Int, index2:Int)
		Throw New UnsupportedOperationException
	End
	
#Rem
Summary: Throws an UnsupportedOperationException, since Set is unordered and it does not make sense to shuffle it.
#End
	Method Shuffle:Void()
		Throw New UnsupportedOperationException
	End
	
	Method Items:IEnumerable<T>(pred:IPredicate<T>=Null)
		Return New WrappedSetEnumerable<T>(Self, pred)
	End
	
#Rem
Summary: Throws an UnsupportedOperationException, since Set is unordered and the resulting elements would be undefined.
#End
	Method Truncate:Void(size:Int)
		Throw New UnsupportedOperationException
	End
	
#Rem
Summary: Returns Null, since Set can never have a comparator.
#End
	Method Comparator:IComparator<T>() Property
		Return Null
	End
	
#Rem
Summary: Throws an UnsupportedOperationException, since Set is unordered and it does not make sense to sort it.
#End
	Method Comparator:Void(comparator:IComparator<T>) Property
		Throw New UnsupportedOperationException
	End
End

Class DiddyIntSet Extends DiddySet<Int>
	Method New()
		Super.New(New IntMap<Object>)
	End
End

Class DiddyFloatSet Extends DiddySet<Float>
	Method New()
		Super.New(New FloatMap<Object>)
	End
End

Class DiddyStringSet Extends DiddySet<String>
	Method New()
		Super.New(New StringMap<Object>)
	End
End
