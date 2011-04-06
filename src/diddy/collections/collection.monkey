Strict

#Rem
	Collection
	Contains some inefficient implementations of collection-based operations.
	These should be overridden by subclasses To be more efficient For whatever storage Method they use.
	They are here To allow developers To make their own collection types without needing To implement every Method.
	Due To limitations with generics in Monkey, ToArray cannot work with an array of type E.  We must Return Object[] instead.
#End
Class AbstractCollection<E> Abstract
Private
	' A custom comparator to use for sorting and comparing items.
	Field comparator:AbstractComparator<E>
	
Public
	' Property to read comparator
	Method Comparator:AbstractComparator<E>() Property
		Return comparator
	End
	' Property to write comparator
	Method Comparator:Void(comparator:AbstractComparator<E>) Property
		Self.comparator = comparator
	End
	
	' Compares two elements of the type within this collection.  This can be overridden instead
	' of assigning a Comparator.
	Method Compare:Int(o1:E, o2:E)
		If IntObject(o1) <> Null And IntObject(o2) <> Null Then
			If IntObject(o1).value < IntObject(o2).value Then Return -1
			If IntObject(o1).value > IntObject(o2).value Then Return 1
			Return 0
		ElseIf FloatObject(o1) <> Null And FloatObject(o2) <> Null Then
			If FloatObject(o1).value < FloatObject(o2).value Then Return -1
			If FloatObject(o1).value > FloatObject(o2).value Then Return 1
			Return 0
		ElseIf StringObject(o1) <> Null And StringObject(o2) <> Null Then
			' TODO: string comparison
			'If StringObject(o1).value < StringObject(o2).value Then Return -1
			'If StringObject(o1).value > StringObject(o2).value Then Return 1
			Return 0
		End
		If o1 = o2 Then Return 0
		Return 1 ' don't know what to do!
	End
	
	' Compares two elements of the type within this collection.  This can be overridden instead
	' of assigning a Comparator.
	Method CompareBool:Bool(o1:E, o2:E)
		If IntObject(o1) <> Null And IntObject(o2) <> Null Then
			Return IntObject(o1).value = IntObject(o2).value
		ElseIf FloatObject(o1) <> Null And FloatObject(o2) <> Null Then
			Return FloatObject(o1).value = FloatObject(o2).value
		ElseIf StringObject(o1) <> Null And StringObject(o2) <> Null Then
			Return StringObject(o1).value = StringObject(o2).value
		End
		Return o1 = o2
	End
	
	' Calculates a hashcode for the an element of the type within this collection.  This can be
	' overridden instead of assigning a Comparator.
	Method HashCode:Int(o:E)
		Return 0 ' TODO: hashcodes
	End
	
	Method Add:Bool(o:E) Abstract
	Method AddAll:Bool(c:AbstractCollection<E>) Abstract
	Method Clear:Void() Abstract
	Method Contains:Bool(o:E) Abstract
	Method ContainsAll:Bool(c:AbstractCollection<E>) Abstract
	'Method Equals:Bool(c:AbstractCollection<E>) Abstract
	Method FillArray:Int(arr:Object[]) Abstract ' populates the passed array and returns the number of items filled. best used for android
	Method IsEmpty:Bool() Abstract
	Method ObjectEnumerator:AbstractEnumerator<E>() Abstract
	Method Remove:Bool(o:E) Abstract
	Method RemoveAll:Bool(c:AbstractCollection<E>) Abstract
	Method RetainAll:Bool(c:AbstractCollection<E>) Abstract
	Method Size:Int() Property Abstract
	Method Sort:Void(comp:Comparator<E> = Null, reverse:Bool = False) Abstract
	Method ToArray:Object[]() Abstract ' creates a new array of the correct size and returns it
End



#Rem
	AbstractEnumerator
	Used in the ObjectEnumerator method for calls to EachIn.
	If retrieved and used manually, the HasPrevious/PreviousObject/Remove/First/Last methods can be called.
#End
Class AbstractEnumerator<E>
Public
	Method HasNext:Bool() Abstract
	Method HasPrevious:Bool() Abstract
	Method NextObject:E() Abstract
	Method PreviousObject:E() Abstract
	Method Remove:Void() Abstract
	Method First:Void() Abstract
	Method Last:Void() Abstract
End


#Rem
	Comparator
	This is a way For developers To provide a custom comparison Method For sorting lists, without having To override it.
	It's sort of like a function pointer.
#End
Class AbstractComparator<T> Abstract
	Method Compare:Int(o1:T, o2:T) Abstract
	Method CompareBool:Bool(o1:T, o2:T) Abstract
	Method HashCode:Int(o:T) Abstract
End



#Rem
	ReadOnlyCollection
	A wrapper for a collection that prevents modification.
	FIXME: incomplete
#End
Class ReadOnlyCollection<E> Extends AbstractCollection
Private
	Field src:AbstractCollection<E>
	
Public
	Method New(src:AbstractCollection<E>)
		Self.src = src
	End
	
	Method Add:Bool(o:E)
		Error("Collection is read-only")
		Return False
	End
	
	Method Remove:Bool(o:E)
		Error("Collection is read-only")
		Return False
	End
	
	Method AddAll:Bool(c:AbstractCollection<E>)
		Error("Collection is read-only")
		Return False
	End
	
	Method Clear:Void()
		Error("Collection is read-only")
	End
	
	Method RemoveAll:Bool(c:AbstractCollection<E>)
		Error("Collection is read-only")
	End
	
	Method RetainAll:Bool(c:AbstractCollection<E>)
		Error("Collection is read-only")
	End
	
	Method Contains:Bool(o:E)
		Return src.Contains(o)
	End
	
	Method ContainsAll:Bool(c:AbstractCollection<E>)
		Return src.ContainsAll(c)
	End
	
	Method IsEmpty:Bool()
		Return src.IsEmpty()
	End
	
	Method Size:Int() Property
		Return src.Size
	End
	
	Method ObjectEnumerator:AbstractEnumerator<E>()
		Return src.ObjectEnumerator()
	End
	
	Method Equals:Bool(c:AbstractCollection<E>)
		Return src.Equals(c)
	End
End





