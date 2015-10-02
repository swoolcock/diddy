# Containers #
The Containers module provides a wrapper around the official Monkey classes Stack, List, and Set.
It serves four main purposes:
  1. Complete interoperability with official Monkey classes
  1. Add advanced functionality such as bulk insert/remove and predicates
  1. Automatic comparator-based sorting
  1. All classes implement the common interface IContainer to ensure that Count() means the same thing for Stack, List, Set, and Deque.

## IContainer ##
IContainer is a common interface that allows the developer to ignore which of Stack, List, and Set require which methods (they're all different!).
Examples of different naming across Stack/List/Set/Deque, and the name supplied by IContainer that will call the matching one:

| **IContainer**   | **Stack**      | **List**         | **Set**         | **Deque**     | **Description**                                                   |
|:-----------------|:---------------|:-----------------|:----------------|:--------------|:------------------------------------------------------------------|
| AddItem()        | Push()         | AddLast()        | Insert()        | PushLast()    | Adds an item to the end of the container (Set is unordered).      |
| RemoveItem()     | RemoveEach()   | RemoveEach()     | Remove()        | _unsupported_ | Removes an item from the container.                               |
| InsertItem()     | Insert()       | InsertBefore()   | _N/A_           | _unsupported_ | Inserts an item before the specified index (Set is unordered).    |
| DeleteItem()     | Remove()       | _manual loop_    | _N/A_           | _unsupported_ | Deletes the item at the specified index (Set is unordered).       |
| GetItem()        | Get()          | _manual loop_    | _N/A_           | Get()         | Gets the item at the specified index (Set is unordered).          |
| SetItem()        | Set()          | _manual loop_    | _N/A_           | Set()         | Sets the item at the specified index (Set is unordered).          |
| FindItem()       | Find()         | _manual loop_    | _N/A_           | _unsupported_ | Finds the index of an item in the container (Set is unordered).   |
| Count()          | Length         | Count()          | Count()         | Length        | Returns the number of items in the container.                     |
| ToArray()        | ToArray()      | ToArray()        | _unsupported_   | ToArray()     | Converts the contents of the container to an array.               |
| IsEmpty()        | IsEmpty        | IsEmpty()        | IsEmpty()       | IsEmpty       | Returns True if there are no elements in the container.           |

_manual loop_ means that the developer would have to write their own loop to perform the operation.

_N/A_ means that the operation is not applicable for that type of container.

_unsupported_ means that the container does not normally support this method (but the Diddy version does).

## DiddyStack, DiddyList, DiddySet, DiddyDeque ##
DiddyStack extends monkey.stack.Stack, DiddyList extends monkey.list.List, DiddySet extends monkey.set.Set, and DiddyDeque extends monkey.deque.Deque.
All four classes also implement ICollection and provide all the functionality defined by that interface.

## DiddyPool ##
DiddyPool is an enhanced DiddyStack that also keeps track of an internal pool of reusable objects.
The developer can acquire objects by calling Allocate(), and release them by calling Free().
Calling Free() on an object that implements IPoolable will automatically call its Reset() method.

## DiddyMap ##
DiddyMap provides a way for developers to use arbitrary keys in a map without having to extend it.
Simply make your key class implement IComparable, or assign an instance of IComparator to the map.
It also provides a way of performing bulk Gets and Sets.

## Bulk Operations ##
The New(), AddAll(), RemoveAll(), RetainAll(), and ContainsAll() methods are bulk operations and accept a Stack, List, Set, or Deque as their argument.
Example:
```
Local s:DiddyStack<T>
s = New DiddyStack<T>(anotherStack) ' creates a DiddyStack with the same contents as the passed Stack
s = New DiddyStack<T>(anotherList) ' creates a DiddyStack with the same contents as the passed List
s = New DiddyStack<T>(anotherSet) ' creates a DiddyStack with the same contents as the passed Set
s = New DiddyStack<T>(anotherDeque) ' creates a DiddyStack with the same contents as the passed Deque

s.AddAll(anotherStack) ' adds the contents of the passed Stack to this DiddyStack
s.AddAll(anotherList) ' adds the contents of the passed List to this DiddyStack
s.AddAll(anotherSet) ' adds the contents of the passed Set to this DiddyStack
s.AddAll(anotherDeque) ' adds the contents of the passed Deque to this DiddyStack

s.RemoveAll(anotherStack) ' removes the contents of the passed Stack from this DiddyStack (if they exist)
s.RemoveAll(anotherList) ' removes the contents of the passed List from this DiddyStack (if they exist)
s.RemoveAll(anotherSet) ' removes the contents of the passed Set from this DiddyStack (if they exist)
s.RemoveAll(anotherDeque) ' removes the contents of the passed Deque from this DiddyStack (if they exist)

s.RetainAll(anotherStack) ' removes everything from this DiddyStack EXCEPT if it exists in the passed Stack
s.RetainAll(anotherList) ' removes everything from this DiddyStack EXCEPT if it exists in the passed List
s.RetainAll(anotherSet) ' removes everything from this DiddyStack EXCEPT if it exists in the passed Set
s.RetainAll(anotherDeque) ' removes everything from this DiddyStack EXCEPT if it exists in the passed Deque

s.ContainsAll(anotherStack) ' returns True if this DiddyStack contains ALL of the items in the passed Stack
s.ContainsAll(anotherList) ' returns True if this DiddyStack contains ALL of the items in the passed List
s.ContainsAll(anotherSet) ' returns True if this DiddyStack contains ALL of the items in the passed Set
s.ContainsAll(anotherDeque) ' returns True if this DiddyStack contains ALL of the items in the passed Deque
```
Each of these operations will work on any class that implements IContainer (DiddyStack, DiddyList, DiddySet, DiddyDeque, DiddyPool).

## Sorting ##
The developer can perform sorting in one of three ways.
  1. Make the class implement IComparable.
  1. Create a separate class that implements IComparator, and assign it to the DiddyStack, DiddyList, or DiddyDeque (Sets cannot be sorted).
  1. Override the Compare method in the DiddyStack or DiddyList as you would a normal Stack or List (the official Deque does not support sorting).

Example using IComparable:
```
Class Foo Implements IComparable
	Field x:Float, y:Float
	
	Method New(x:Float, y:Float)
		Self.x = x
		Self.y = y
	End
	
	Method CompareTo:Int(other:Object)
		Local o:Foo = Foo(other)
		If o Then
			' negative value means the other object is GREATER than this one
			' positive value means the other object is LESS than this one
			' zero means the other object is EQUAL to this one
			Return Self.y - o.y
		End
	End
End

Local s:DiddyStack<Foo> = New DiddyStack<Foo>
' TODO: insert items here
s.Sort()
```

Example using IComparator:
```
Class Foo
	Field x:Float, y:Float
	
	Method New(x:Float, y:Float)
		Self.x = x
		Self.y = y
	End
End

Class FooComparator Implements IComparator<Foo>
	Method Compare:Int(lhs:Foo, rhs:Foo)
		' both null means they are equal
		If Not lhs And Not rhs Then Return 0
		' only lhs is null means it is less than rhs
		If Not lhs And rhs Then Return -1
		' only rhs is null means it is greater than lhs
		If lhs And Not rhs Then Return 1
		' neither are null, so perform our calculation
		Return lhs.y - rhs.y
	End
End

Local s:DiddyStack<Foo> = New DiddyStack<Foo>
s.Comparator = New FooComparator
' TODO: insert items here
s.Sort()
```

Example using Compare:
```
Class Foo
	Field x:Float, y:Float
	
	Method New(x:Float, y:Float)
		Self.x = x
		Self.y = y
	End
End

Class FooStack Extends DiddyStack<Foo>
	Method Compare:Int(lhs:Foo, rhs:Foo)
		' both null means they are equal
		If Not lhs And Not rhs Then Return 0
		' only lhs is null means it is less than rhs
		If Not lhs And rhs Then Return -1
		' only rhs is null means it is greater than lhs
		If lhs And Not rhs Then Return 1
		' neither are null, so perform our calculation
		Return lhs.y - rhs.y
	End
End

Local s:FooStack = New FooStack
' TODO: insert items here
s.Sort()
```

## Predicates ##
Containers can be filtered using an instance of IPredicate.  This is a form of lambda or closure.
Example of predicate filtering:
```
Class TestPredicate Implements IPredicate<String>
	Method Evaluate:Bool(val:String)
		Return val.Contains("e")
	End
End

Local ds:DiddyStringStack = New DiddyStringStack
' adding some test values
ds.AddItem("the")
ds.AddItem("cake")
ds.AddItem("is")
ds.AddItem("a")
ds.AddItem("lie")

' looping only on items that contain an "e"
For Local s:String = EachIn ds.Items(New TestPredicate)
	Print s
Next
```

## Other Functions ##
  * Reverse(): Reverses the order of the items in the Stack, List, or Deque (Set is unordered).
  * Shuffle(): Shuffles the contents of the Stack, List, or Deque (useful for card games or music playlists).  Not applicable to Set.
  * SwapItems(): Swaps the items at two indices of a Stack, List, or Deque (Set is unordered).
  * Truncate(): Removes items from the end of the Stack, List, or Deque until the Count() is no more than the requested size.  If the Count() is already less than or equal to the requested size, nothing happens.
  * FillArray(): Similar to ToArray(), but it will fill an existing array and return the number of elements in the container.  If you keep a cached array, this has better performance than constantly calling ToArray().

## ArrayList Migration ##
It is recommended that developers migrate from ArrayList to the new containers framework.  Firstly, change all references to `ArrayList` with `DiddyStack`.  Stack/DiddyStack is array-based, like ArrayList, whereas DiddyList is a linked list.
The following is a table of ArrayList methods and their corresponding Stack and IContainer methods.  The IContainer methods will work on any Diddy container, whereas the Stack ones are inherited from the official Stack class and may optionally be used instead.

ArrayList | Stack      | IContainer
:-------- | :--------- | :---------
Add       | Push       | AddItem
Remove    | RemoveEach | RemoveItem
Insert    | Insert     | InsertItem
RemoveAt  | Remove     | DeleteItem
Clear     | Clear      | ClearAll
Contains  | Contains   | ContainsItem
Get       | Get        | GetItem
Set       | Set        | SetItem
IndexOf   | Find       | FindItem
Sort      | Sort       | SortItem
Size      | Length     | Count
