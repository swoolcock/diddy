Strict

#Rem
	AbstractCollection
	Due to limitations with generics in Monkey, ToArray cannot work with an array of type E.  We must return Object[] instead.
#End
Class AbstractCollection<E> Abstract
Private
	' A custom comparator to use for sorting and comparing items.
	Field comparator:AbstractComparator = Null
	
Public
	' Property to read comparator
	Method Comparator:AbstractComparator() Property
		Return comparator
	End
	' Property to write comparator
	Method Comparator:Void(comparator:AbstractComparator) Property
		Self.comparator = comparator
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
	Method Sort:Void(reverse:Bool = False, comp:AbstractComparator = Null) Abstract
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
	AbstractComparator
	This is a way For developers to provide a custom comparison method for sorting lists.
	It's sort of like a function pointer.
#End
Class AbstractComparator Abstract
	Method Compare:Int(o1:Object, o2:Object) Abstract
	Method CompareBool:Bool(o1:Object, o2:Object) Abstract
	Method HashCode:Int(o:Object) Abstract
End



Global DEFAULT_COMPARATOR:DefaultComparator = New DefaultComparator
Class DefaultComparator Extends AbstractComparator
	Method Compare:Int(o1:Object, o2:Object)
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
	
	Method CompareBool:Bool(o1:Object, o2:Object)
		If IntObject(o1) <> Null And IntObject(o2) <> Null Then
			Return IntObject(o1).value = IntObject(o2).value
		ElseIf FloatObject(o1) <> Null And FloatObject(o2) <> Null Then
			Return FloatObject(o1).value = FloatObject(o2).value
		ElseIf StringObject(o1) <> Null And StringObject(o2) <> Null Then
			Return StringObject(o1).value = StringObject(o2).value
		End
		Return o1 = o2
	End
	
	Method HashCode:Int(o:Object)
		Return 0 ' TODO: hashcodes
	End
End



