#Rem
Copyright (c) 2011 Steve Revill and Shane Woolcock
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#End

#Rem
Header: Monkey Containers Framework
The Containers framework supersedes the old Collections framework and allows cross-compatibility
with the official Monkey data structures (Stack, List, and Set).
#End

Strict
Public

' Need to alias some of the official classes since Enumerator exists in both the monkey.stack and monkey.list modules
Alias MapValueEnumerator = monkey.map.ValueEnumerator
Alias MapKeyEnumerator = monkey.map.KeyEnumerator
Alias StackEnumerator = monkey.stack.Enumerator
Alias ListEnumerator = monkey.list.Enumerator

' Importing containers will give you all the container classes
Import diddystack
Import diddyset
Import diddylist
Import diddypool

#Rem
Summary: Indicates that an object of this class should be able to compare itself with another instance, primarily for sorting.
IComparable can't be generic at this point, because it's likely the developer would want to declare a cyclic declaration.
Cyclic declarations are currently unsupported by Monkey.
#End
Interface IComparable
#Rem
Summary: Compares this instance of the class with another instance.
Return 0 if the objects are equal, a negative value if the passed object is "less than" this object,
or a positive value if the passed object is "greater than" this object.
#End
	Method CompareTo:Int(other:Object)
End

#Rem
Summary: Indicates that this class is able to compare two instances of the generic type, T.
The comparison contract is identical to that of IComparable, as if lhs.CompareTo(rhs)
#End
Interface IComparator<T>
#Rem
Summary: Compares two instances of the generic type, T.
Return 0 if the objects are equal, a negative value if rhs is "less than" lhs,
or a positive value if rhs is "greater than" lhs.
#End
	Method Compare:Int(lhs:T, rhs:T)
End

#Rem
Summary: Provides the HasNext() and NextObject() methods that the EachIn operator expects.
#End
Interface IEnumerator<T>
#Rem
Summary: Called once every EachIn loop to check if there are more objects available.
Returns False if the next call to NextObject() will fail.
#End
	Method HasNext:Bool()
	
#Rem
Summary: Called once every EachIn loop to retrieve the next available object.
#End
	Method NextObject:T()
End

#Rem
Summary: Indicates that the class can be used in an EachIn loop.
When the Monkey compiler reaches an EachIn statement such as:
[code]
For Local val := EachIn lst
	' your code
Next
[/code]
It will internally convert it to:
[code]
Local oe:=lst.ObjectEnumerator()
While oe.HasNext()
	Local val:=oe.NextObject()
	' your code
End
[/code]
#End
Interface IEnumerable<T>
#Rem
Summary: Returns an instance of IEnumerator that the EachIn operator can loop with.
#End
	Method ObjectEnumerator:IEnumerator<T>()
End

#Rem
Summary: A class that implements IPredicate should act as a pseudo-lambda for predicate operations on the Container classes.
#End
Interface IPredicate<T>
	Method Evaluate:Bool(arg:T)
End

#Rem
Summary: If a class implements IPoolable, Reset() will be called when it is freed within a DiddyPool or GlobalPool.
#End
Interface IPoolable
	Method Reset:Void()
End

#Rem
Summary: A class that implements IContainer<T> must be able to interact with all of Stack, List, and Set.
#End
Interface IContainer<T>
#Rem
Summary: Getter for the current sorting comparator.
Allows sorting without implementing IComparable.
Unsupported in Set.
#End
	Method Comparator:IComparator<T>() Property
	
#Rem
Summary: Setter for the current sorting comparator.
Allows sorting without implementing IComparable.
Unsupported in Set.
#End
	Method Comparator:Void(comparator:IComparator<T>) Property

#Rem
Summary: Adds the entire contents of the passed Stack to the container.
AddAll should throw an IllegalArgumentException if src is Null.
#End
	Method AddAll:Void(src:Stack<T>)
	
#Rem
Summary: Adds the entire contents of the passed List to the container.
AddAll should throw an IllegalArgumentException if src is Null.
#End
	Method AddAll:Void(src:List<T>)
	
#Rem
Summary: Adds the entire contents of the passed Set to the container.
AddAll should throw an IllegalArgumentException if src is Null.
#End
	Method AddAll:Void(src:Set<T>)
	
#Rem
Summary: Adds the entire contents of another container to this container.
AddContainer should throw an IllegalArgumentException if src is Null.
#End
	Method AddContainer:Void(src:IContainer<T>)
	
#Rem
Summary: Removes from this container any objects that also appear in the passed Stack.
RemoveAll should throw an IllegalArgumentException if src is Null.
#End
	Method RemoveAll:Void(src:Stack<T>)
	
#Rem
Summary: Removes from this container any objects that also appear in the passed List.
RemoveAll should throw an IllegalArgumentException if src is Null.
#End
	Method RemoveAll:Void(src:List<T>)
	
#Rem
Summary: Removes from this container any objects that also appear in the passed Set.
RemoveAll should throw an IllegalArgumentException if src is Null.
#End
	Method RemoveAll:Void(src:Set<T>)
	
#Rem
Summary: Removes from this container any objects that also appear in the passed container.
RemoveContainer should throw an IllegalArgumentException if src is Null.
#End
	Method RemoveContainer:Void(src:IContainer<T>)
	
#Rem
Summary: Removes from this container any objects that DON'T appear in the passed Stack.
RetainAll should throw an IllegalArgumentException if src is Null.
#End
	Method RetainAll:Void(src:Stack<T>)
	
#Rem
Summary: Removes from this container any objects that DON'T appear in the passed List.
RetainAll should throw an IllegalArgumentException if src is Null.
#End
	Method RetainAll:Void(src:List<T>)
	
#Rem
Summary: Removes from this container any objects that DON'T appear in the passed Set.
RetainAll should throw an IllegalArgumentException if src is Null.
#End
	Method RetainAll:Void(src:Set<T>)
	
#Rem
Summary: Removes from this container any objects that DON'T appear in the passed container.
RetainContainer should throw an IllegalArgumentException if src is Null.
#End
	Method RetainContainer:Void(src:IContainer<T>)
	
#Rem
Summary: Returns True if this container contains ALL of the elements in the passed Stack.
ContainsAll should throw an IllegalArgumentException if src is Null.
#End
	Method ContainsAll:Bool(src:Stack<T>)
	
#Rem
Summary: Returns True if this container contains ALL of the elements in the passed List.
ContainsAll should throw an IllegalArgumentException if src is Null.
#End
	Method ContainsAll:Bool(src:List<T>)
	
#Rem
Summary: Returns True if this container contains ALL of the elements in the passed Set.
ContainsAll should throw an IllegalArgumentException if src is Null.
#End
	Method ContainsAll:Bool(src:Set<T>)
	
#Rem
Summary: Returns True if this container contains ALL of the elements in the passed container.
ContainsContainer should throw an IllegalArgumentException if src is Null.
#End
	Method ContainsContainer:Bool(src:IContainer<T>)
	
#Rem
Summary: Adds the passed item to the container.
No error should be thrown if the item already exists since Lists and Stacks allow duplicates.
Sets should do nothing if the item already exists.
A passed value of Null is implementation-dependent.
#End
	Method AddItem:Void(val:T)
	
#Rem
Summary: Removes the passed item from the container, if it exists.
No error should be thrown if the item does not exist.
A passed value of Null is implementation-dependent.
#End
	Method RemoveItem:Void(val:T)
	
#Rem
Summary: Adds the passed item to the container at the requested index.
No error should be thrown if the item already exists since Lists and Stacks allow duplicates.
Sets are unordered and should throw an UnsupportedOperationException.
A passed value of Null is implementation-dependent.
If building with debug, an IllegalArgumentException should be thrown if the index is outside the range 0 <= index <= Count()
#End
	Method InsertItem:Void(index:Int, val:T)
	
#Rem
Summary: Deletes the item from the container at the requested index.
No error should be thrown if the item already exists since Lists and Stacks allow duplicates.
Sets are unordered and should throw an UnsupportedOperationException.
If building with debug, an IllegalArgumentException should be thrown if the index is outside the range 0 <= index < Count()
#End
	Method DeleteItem:T(index:Int)
	
#Rem
Summary: Removes all items from the container.
#End
	Method ClearAll:Void()
	
#Rem
Summary: Returns True if the container contains the passed value.
A passed value of Null is implementation-dependent.
#End
	Method ContainsItem:Bool(val:T)
	
#Rem
Summary: Gets the item at the given index.
Sets are unordered and should throw an UnsupportedOperationException.
If building with debug, an IllegalArgumentException should be thrown if the index is outside the range 0 <= index < Count()
#End
	Method GetItem:T(index:Int)
	
#Rem
Summary: Sets the item at a given index to be the passed value.
A passed value of Null is implementation-dependent.
Sets are unordered and should throw an UnsupportedOperationException.
If building with debug, an IllegalArgumentException should be thrown if the index is outside the range 0 <= index < Count()
#End
	Method SetItem:Void(index:Int, value:T)
	
#Rem
Summary: Finds the first reference to the passed item and returns the index.
A value of -1 should be returned if the item is not found.
A passed value of Null is implementation-dependent.
Sets are unordered and should throw an UnsupportedOperationException.
#End
	Method FindItem:Int(value:T)
	
#Rem
Summary: Sorts the items based on the current Comparator or T's implementation of IComparable.
Sets are unordered and should throw an UnsupportedOperationException.
#End
	Method SortItems:Void(ascending:Bool = True) ' unsupported in Set
	
#Rem
Summary: Reverses the order of elements in the container.
Sets are unordered and should throw an UnsupportedOperationException.
#End
	Method Reverse:Void()
	
#Rem
Summary: Randomises the order of elements in the container.
Sets are unordered and should throw an UnsupportedOperationException.
#End
	Method Shuffle:Void()
	
#Rem
Summary: Returns a custom IEnumerable that optionally supports a predicate.
#End
	Method Items:IEnumerable<T>(pred:IPredicate<T>=Null)
	
#Rem
Summary: Swaps the values of two given indices.
Sets are unordered and should throw an UnsupportedOperationException.
If building with debug, an IllegalArgumentException should be thrown if either index is outside the range 0 <= index < Count()
#End
	Method SwapItems:Void(index1:Int, index2:Int)
	
#Rem
Summary: Reduces the number of items in the container to be no more than the passed size.
If there are less or equal elements in the container than the passed size, nothing happens.
If there are more elements in the container than the passed size, elements should be removed from the end
until Count() = the requested size.
Sets are unordered and should throw an UnsupportedOperationException.
If building with debug, an IllegalArgumentException should be thrown if the requested size < 0.
#End
	Method Truncate:Void(size:Int)
	
#Rem
Summary: Returns the number of items in the container.
#End
	Method Count:Int()
	
#Rem
Summary: Returns a new array containing all the items in the container.
The array length will be equal to Count().
Sets are unordered, therefore the order of the elements in the array will be undefined.
#End
	Method ToArray:T[]()
	
#Rem
Summary: Fills the passed array with the items in the container, if there is space.
If the array length is < Count(), an IllegalArgumentException should be thrown.
The first Count() items will contain the elements of the container, and any elements after that should be set to Null.
The method returns the number of elements actually filled.
Sets are unordered, therefore the order of the elements in the array will be undefined.
#End
	Method FillArray:Int(arr:T[]) ' undefined order in Set
	
#Rem
Summary: Compares two instances of the generic type, T.
Return 0 if the objects are equal, a negative value if rhs is "less than" lhs,
or a positive value if rhs is "greater than" lhs.
A Null value should always be considered "less than" a non-Null value.
Sets are unordered and cannot be sorted, so they should throw an UnsupportedOperationException.
#End
	Method Compare:Int(lhs:T, rhs:T)
	
#Rem
Summary: Performs an equality test of lhs and rhs.
Returns True if they are logically equal, otherwise False.
#End
	Method Equals:Bool(lhs:T, rhs:T)
	
#Rem
Summary: Returns True if there are no elements in the container, otherwise False.
#End
	Method IsEmpty:Bool()
End

#Rem
Summary: IComparableWrapper is essentially a hack to get around Monkey's inability to cast primitives to objects.
#End
Class IComparableWrapper
#Rem
Summary: Returns True if the passed object implements the IComparable interface.
#End
	Function IsComparable:Bool(src:Object)
		Return IComparable(src) <> Null
	End

#Rem
Summary: Returns False, because an Int can never implement an interface.
#End
	Function IsComparable:Bool(src:Int)
		Return False
	End

#Rem
Summary: Returns False, because a Float can never implement an interface.
#End
	Function IsComparable:Bool(src:Float)
		Return False
	End
	
#Rem
Summary: Returns False, because a String can never implement an interface.
#End
	Function IsComparable:Bool(src:String)
		Return False
	End
	
#Rem
Summary: Performs a comparison on the passed objects.
If both objects are Null, returns 0.
If either object does not implement IComparable, returns 0.
Otherwise, IComparable.CompareTo() is called.
#End
	Function Compare:Int(lhs:Object, rhs:Object)
		' we check both lhs and rhs because we always want to compare if at least one value is non-null
		If IComparable(lhs) Then
			' normal comparison if lhs is not null
			Return IComparable(lhs).CompareTo(rhs)
		ElseIf IComparable(rhs) Then
			' reverse comparison if lhs is null but rhs is not
			Return -IComparable(rhs).CompareTo(lhs)
		End
		Return 0
	End
	
#Rem
Summary: Returns 0, because an Int can never implement an interface.
#End
	Function Compare:Int(lhs:Int, rhs:Int)
		Return 0
	End

#Rem
Summary: Returns 0, because a Float can never implement an interface.
#End
	Function Compare:Int(lhs:Float, rhs:Float)
		Return 0
	End
	
#Rem
Summary: Returns 0, because a String can never implement an interface.
#End
	Function Compare:Int(lhs:String, rhs:String)
		Return 0
	End
End

#Rem
Summary: Abstract class to provide predicate support to subclassed enumerators.
#End
Class PredicateEnumerator<T> Implements IEnumerator<T> Abstract
Private
	Global NIL:T

	Field pred:IPredicate<T>
	Field atEnd:Bool = False
	Field peeked:Bool = False
	Field nextVal:T = NIL
	Field nextValSet:Bool = False
	
Public
#Rem
Summary: Constructor with an optional predicate.
#End
	Method New(pred:IPredicate<T>=Null)
		Self.pred = pred
	End
	
#Rem
Summary: Implements IEnumerator<T>.HasNext().
If no predicate is assigned, it immediately delegates to CallHasNext()
If there is a predicate, it delegates to CallHasNext() and CallNextObject() as required.
#End
	Method HasNext:Bool()
		If Not pred Then Return CallHasNext()
		If atEnd Then Return False
		If nextValSet Then Return True
		peeked = True
		While CallHasNext()
			Local n:T = CallNextObject()
			If pred.Evaluate(n) Then
				nextVal = n
				nextValSet = True
				Return True
			End
		End
		atEnd = True
		Return False
	End
	
#Rem
Summary: Implements IEnumerator<T>.NextObject().
If no predicate is assigned, it immediately delegates to CallNextObject()
If there is a predicate, it delegates to HasNext() and CallNextObject() as required.
#End
	Method NextObject:T()
		If Not pred Then Return CallNextObject()
		If Not nextValSet And Not HasNext() Then Return NIL
		Local result:T = nextVal
		nextVal = NIL
		nextValSet = False
		peeked = False
		Return result
	End
	
#Rem
Summary: Abstract method that should delegate to the child enumerator's HasNext() method.
#End
	Method CallHasNext:Bool() Abstract
	
#Rem
Summary: Abstract method that should delegate to the child enumerator's NextObject() method.
#End
	Method CallNextObject:T() Abstract
End

#Rem
Summary: Extends PredicateEnumerator<T> to wrap MapValueEnumerator<String,T> as an IEnumerator<T>.
#End
Class WrappedMapValueEnumerator<T> Extends PredicateEnumerator<T>
Private
	Field en:MapValueEnumerator<String,T>
	
Public
#Rem
Summary: Constructor to wrap a MapValueEnumerator<String,T> with an optional IPredicate<T>.
#End
	Method New(en:MapValueEnumerator<String,T>, pred:IPredicate<T>=Null)
		Super.New(pred)
		Self.en = en
	End
	
#Rem
Summary: Delegates to MapValueEnumerator.NextObject().
#End
	Method CallNextObject:T()
		Return en.NextObject()
	End
	
#Rem
Summary: Delegates to MapValueEnumerator.HasNext().
#End
	Method CallHasNext:Bool()
		Return en.HasNext()
	End
End

#Rem
Summary: Wraps Map and the ObjectEnumerator() method to provide access to a PredicateEnumerator<T>.
#End
Class WrappedMapValueEnumerable<K,V> Implements IEnumerable<V>
Private
	Field m:Map<K,V>
	Field pred:IPredicate<V>
	
Public
#Rem
Summary: Constructor to wrap a Map<K,V> enumerator as an IEnumerable<V> with an optional IPredicate<V>.
#End
	Method New(m:Map<K,V>, pred:IPredicate<V>=Null)
		Self.m = m
		Self.pred = pred
	End
	
#Rem
Summary: Returns a WrappedMapValueEnumerator with the optional predicate.
#End
	Method ObjectEnumerator:IEnumerator<V>()
		Return New WrappedMapValueEnumerator<V>(m.ObjectEnumerator(), pred)
	End
End

#Rem
Summary: Extends PredicateEnumerator<T> to wrap StackEnumerator<T> as an IEnumerator<T>.
#End
Class WrappedStackEnumerator<T> Extends PredicateEnumerator<T>
Private
	Field en:StackEnumerator<T>
	
Public
#Rem
Summary: Constructor to wrap a StackEnumerator<T> with an optional IPredicate<T>.
#End
	Method New(en:StackEnumerator<T>, pred:IPredicate<T>=Null)
		Super.New(pred)
		Self.en = en
	End
	
#Rem
Summary: Delegates to StackEnumerator.NextObject().
#End
	Method CallNextObject:T()
		Return en.NextObject()
	End
	
#Rem
Summary: Delegates to StackEnumerator.HasNext().
#End
	Method CallHasNext:Bool()
		Return en.HasNext()
	End
End

#Rem
Summary: Wraps Stack and the ObjectEnumerator() method to provide access to a PredicateEnumerator<T>.
#End
Class WrappedStackEnumerable<T> Implements IEnumerable<T>
Private
	Field s:Stack<T>
	Field pred:IPredicate<T>
	
Public
#Rem
Summary: Constructor to wrap a Stack<T> enumerator as an IEnumerable<T> with an optional IPredicate<T>.
#End
	Method New(s:Stack<T>, pred:IPredicate<T>=Null)
		Self.s = s
		Self.pred = pred
	End

#Rem
Summary: Returns a WrappedStackEnumerator with the optional predicate.
#End
	Method ObjectEnumerator:IEnumerator<T>()
		Return New WrappedStackEnumerator<T>(s.ObjectEnumerator(), pred)
	End
End

#Rem
Summary: Extends PredicateEnumerator<T> to wrap ListEnumerator<T> as an IEnumerator<T>.
#End
Class WrappedListEnumerator<T> Extends PredicateEnumerator<T>
Private
	Field en:ListEnumerator<T>
	
Public
#Rem
Summary: Constructor to wrap a ListEnumerator<T> with an optional IPredicate<T>.
#End
	Method New(en:ListEnumerator<T>, pred:IPredicate<T>=Null)
		Super.New(pred)
		Self.en = en
	End
	
#Rem
Summary: Delegates to ListEnumerator.NextObject().
#End
	Method CallNextObject:T()
		Return en.NextObject()
	End
	
#Rem
Summary: Delegates to ListEnumerator.HasNext().
#End
	Method CallHasNext:Bool()
		Return en.HasNext()
	End
End

#Rem
Summary: Wraps List and the ObjectEnumerator() method to provide access to a PredicateEnumerator<T>.
#End
Class WrappedListEnumerable<T> Implements IEnumerable<T>
Private
	Field l:List<T>
	Field pred:IPredicate<T>
	
Public
#Rem
Summary: Constructor to wrap a List<T> enumerator as an IEnumerable<T> with an optional IPredicate<T>.
#End
	Method New(l:List<T>, pred:IPredicate<T>=Null)
		Self.l = l
		Self.pred = pred
	End
	
#Rem
Summary: Returns a WrappedListEnumerator with the optional predicate.
#End
	Method ObjectEnumerator:IEnumerator<T>()
		Return New WrappedListEnumerator<T>(l.ObjectEnumerator(), pred)
	End
End

#Rem
Summary: Extends PredicateEnumerator<T> to wrap MapKeyEnumerator<T,Object> as an IEnumerator<T>.
#End
Class WrappedSetEnumerator<T> Extends PredicateEnumerator<T>
Private
	Field en:MapKeyEnumerator<T,Object>
	
Public
#Rem
Summary: Constructor to wrap a MapKeyEnumerator<T,Object> with an optional IPredicate<T>.
#End
	Method New(en:MapKeyEnumerator<T,Object>, pred:IPredicate<T>=Null)
		Super.New(pred)
		Self.en = en
	End
	
#Rem
Summary: Delegates to MapKeyEnumerator.NextObject().
#End
	Method CallNextObject:T()
		Return en.NextObject()
	End
	
#Rem
Summary: Delegates to MapKeyEnumerator.HasNext().
#End
	Method CallHasNext:Bool()
		Return en.HasNext()
	End
End

#Rem
Summary: Wraps Set and the ObjectEnumerator() method to provide access to a PredicateEnumerator<T>.
#End
Class WrappedSetEnumerable<T> Implements IEnumerable<T>
Private
	Field s:Set<T>
	Field pred:IPredicate<T>
	
Public
#Rem
Summary: Constructor to wrap a Set<T> enumerator as an IEnumerable<T> with an optional IPredicate<T>.
#End
	Method New(s:Set<T>, pred:IPredicate<T>)
		Self.s = s
		Self.pred = pred
	End
	
#Rem
Summary: Returns a WrappedSetEnumerator with the optional predicate.
#End
	Method ObjectEnumerator:IEnumerator<T>()
		Return New WrappedSetEnumerator<T>(s.ObjectEnumerator(), pred)
	End
End
