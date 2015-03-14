# Warning: ArrayList has been deprecated in favour of DiddyStack and the new Containers module #

To continue using ArrayList, you will need to:
  * Change IEnumerator to IDepEnumerator
  * Change IComparable to IDepComparable
  * Change IComparator to IDepComparator
  * If you are using the old QuickSort function, change it to DepQuickSort

---

## ArrayList ##
ArrayList is a feature-rich collection type, based on the Java ArrayList class.  Features include:
  * Array-indexed for speed
  * Dynamically sized to save memory
  * ForEach concurrency checks
  * Get and Set to index individual elements
  * Bulk add and remove
  * Cloning
  * Customisable sorting using a quicksort algorithm

## Array Indexing ##
ArrayList uses an internal dynamically-sized array to store elements, rather than nodes (hence "Array"List).
This makes reads very fast, and results in fewer objects created on the heap.

## Concurrency ##
When using ForEach on an ArrayList, it will check for list modification on each loop.  If it detects that the list has been modified, an error will be thrown.  This is a safety feature to prevent strange bugs appearing in your application.

So why do we need concurrency checking?
```
' assume we have the following class
Class MyClass
  Field myfield:String
  
  Method New(myfield:String)
    Self.myfield = myfield
  End
End

' and the following list
Local list:ArrayList<MyClass> = New ArrayList<MyClass>
list.Add(New MyClass("a"))
list.Add(New MyClass("b"))
list.Add(New MyClass("c"))
list.Add(New MyClass("d"))
list.Add(New MyClass("e"))
```
Here's an example of deleting an element within a standard For loop.
In this code, we are hoping to remove the first element, then continue with the rest.
```
For Local i% = 0 Until list.Size
  Print list.Get(i).myfield
  If i = 0 Then list.RemoveAt(i)
Next
```
Here's the output:
```
Loop 1: i = 0, Size = 5: Prints "a"
We remove index 0, shuffling 1-4 forward to 0-3
Loop 2: i = 1, Size = 4: Prints "c"
Loop 3: i = 2, Size = 4: Prints "d"
Loop 4: i = 3, Size = 4: Prints "e"
```
Because we deleted "a" in the first loop, we've now skipped over "b"!  The same happens when inserting an item.
In this code, we are hoping to insert an element at the start, then continue with the rest.
```
' assume list still contains "a" to "e"
For Local i% = 0 Until list.Size
  Print list.Get(i).myfield
  If i = 0 Then list.Insert(0, New MyClass("foo"))
Next
```
Here's the output:
```
Loop 1: i = 0, Size = 5: Prints "a"
We insert a new item at index 0, shuffling 0-4 back to 1-5
Loop 2: i = 1, Size = 6: Prints "a"
Loop 3: i = 2, Size = 6: Prints "b"
Loop 4: i = 3, Size = 6: Prints "c"
Loop 5: i = 4, Size = 6: Prints "d"
Loop 6: i = 5, Size = 6: Prints "e"
```
Because we inserted an item in the first loop, we've missed "foo", and looped on "a" twice!

Using a ForEach will throw an error rather than having strange side effects like this.  If you want to delete an item within a ForEach loop, you should manually retrieve the enumerator, like so:
```
Local en:IDepEnumerator<MyClass> = list.Enumerator()
While en.HasNext()
  Local item:MyClass = en.NextObject()
  ' if you want to delete this item, do the following line
  en.Remove()
End
```

This will remove the current item from the list, but keeps the enumerator synchronized with the list so that you can continue to use it without fear of skipping or repeating elements.
Rather than adding individual items within a loop, it is better practice to do a bulk insert.

```
Local itemsToAdd:ArrayList<MyClass> = New ArrayList<MyClass>
For Local item:MyClass = EachIn list
  ' if we want to add an item in this pass of the loop, put it in the temp list
  itemsToAdd.Add(someNewItem)
Next
' and do a bulk add
list.AddAll(itemsToAdd)
```

In the future I may add support to Enumerator for inserting elements, but for now this is the safest way to do it.

## Get/Set ##
Unlike the default List class in Monkey, you can retrieve and replace individual elements in an ArrayList by their index.

## Bulk Modifications / Cloning ##
You can add and remove multiple items at once by passing in another ArrayList containing the items you wish to add/remove.  This makes it very easy to merge and split lists.  Lists can be cloned by passing an existing ArrayList into the constructor of a new one.

## Sorting ##
For lists containing primitive types (such as Int, Float, and String), sorting is as easy as:
```
list.Sort()
```
If you're using an ArrayList to store instances of your own class, you first need to tell the ArrayList how it should sort the items.  Just because you're using it to store sprites doesn't mean that it automatically knows you want to sort by its Y location!

There are two ways to do this.  You can either create your own IComparator class, or make the class itself implement the IComparable interface.  Using IComparable is arguably easier, but using IComparator allows you to change the sorting method at runtime.  For example, to change the property it sorts by you could declare multiple IComparators and choose which one you want at any point in your program's lifecycle.

By IDepComparator:
```
Class Sprite
  Field x:Int
  Field y:Int
End

Class SpriteComparator Extends IDepComparator
  ' return 0 if the objects are equal, a negative number if o1 < o2, and a positive number if o1 > o2
  Method Compare:Int(o1:Object, o2:Object)
    Return Sprite(o1).y - Sprite(o2).y
  End

  ' return true if it's the same object, or if Compare(o1, o2) would normally return 0
  Method Equals:Bool(o1:Object, o2:Object)
    Return o1 = o2 Or Sprite(o1).y = Sprite(o2).y
  End
End

Local list:ArrayList<Sprite> = New ArrayList<Sprite>
' add items here
list.Comparator = New SpriteComparator
list.Sort()
```

By IDepComparable:
```
Class Sprite Implements IDepComparable
  Field x:Int
  Field y:Int
  
  ' return 0 if Self is equal to o, a negative number if Self < o, and a positive number if Self > o
  Method Compare:Int(o:Object)
    Return y - Sprite(o).y
  End

  ' return true if o is Self, or if Compare(o) would normally return 0
  Method Equals:Bool(o:Object)
    Return o = Self Or y = Sprite(o).y
  End
End

Local list:ArrayList<Sprite> = New ArrayList<Sprite>
' add items here
list.Sort()
```

You can pass the argument True to Sort if you wish to sort in reverse, and you can manually pass in an IDepComparator if you want to override the assigned one.