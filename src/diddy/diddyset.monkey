Strict
Private
Import diddy.containers
Import diddy.exception

Public
Class DiddySet<T> Extends Set<T> Implements IContainer<T>
Private
	Global NIL:T
	
Public
	Method New()
		Super.New()
	End

	Method New(m:Map<T,Object>)
		Super.New(m)
	End
	
	Method New(src:Stack<T>)
		AddAll(src)
	End
	
	Method New(src:List<T>)
		AddAll(src)
	End
	
	Method New(src:Set<T>)
		AddAll(src)
	End
	
	' AddAll
	Method AddAll:Void(src:Stack<T>)
		For Local val := EachIn src
			Self.Insert(val)
		Next
	End

	Method AddAll:Void(src:List<T>)
		For Local val := EachIn src
			Self.Insert(val)
		Next
	End
	
	Method AddAll:Void(src:Set<T>)
		For Local val := Eachin src
			Self.Insert(val)
		Next
	End
	
	Method AddContainer:Void(src:IContainer<T>)
		For Local val := Eachin src.Items
			Self.Insert(val)
		Next
	End
	
	' RemoveAll
	Method RemoveAll:Void(src:Stack<T>)
		For Local val := EachIn src
			Self.Remove(val)
		Next
	End
	
	Method RemoveAll:Void(src:List<T>)
		For Local val := EachIn src
			Self.Remove(val)
		Next
	End
	
	Method RemoveAll:Void(src:Set<T>)
		For Local val := Eachin src
			Self.Remove(val)
		Next
	End
	
	Method RemoveContainer:Void(src:IContainer<T>)
		For Local val := Eachin src.Items
			Self.Remove(val)
		Next
	End
	
	' RetainAll
	Method RetainAll:Void(src:Stack<T>)
		Local arr:T[] = Self.ToArray()
		For Local val := EachIn arr
			If Not src.Contains(val) Then
				Self.Remove(val)
			End
		Next
	End
	
	Method RetainAll:Void(src:List<T>)
		Local arr:T[] = Self.ToArray()
		For Local val := EachIn arr
			If Not src.Contains(val) Then
				Self.Remove(val)
			End
		Next
	End
	
	Method RetainAll:Void(src:Set<T>)
		Local arr:T[] = Self.ToArray()
		For Local val := Eachin arr
			If Not src.Contains(val) Then
				Self.Remove(val)
			End
		Next
	End
	
	Method RetainContainer:Void(src:IContainer<T>)
		#Rem
		Local arr:T[] = Self.ToArray()
		For Local val := Eachin arr
			If Not src.Contains(val) Then
				Self.Remove(val)
			End
		Next
		#End
	End
	
	' ContainsAll
	Method ContainsAll:Bool(src:Stack<T>)
		For Local val := Eachin src
			If Not Self.Contains(val) Return False
		Next
		Return True
	End
	
	Method ContainsAll:Bool(src:List<T>)
		For Local val := Eachin src
			If Not Self.Contains(val) Return False
		Next
		Return True
	End
	
	Method ContainsAll:Bool(src:Set<T>)
		For Local val := Eachin src
			If Not Self.Contains(val) Return False
		Next
		Return True
	End
	
	Method ContainsContainer:Bool(src:IContainer<T>)
		For Local val := Eachin src.Items
			If Not Self.Contains(val) Return False
		Next
		Return True
	End
	
	' General
	Method AddItem:Void(val:T)
		Self.Insert(val)
	End
	
	Method RemoveItem:Void(val:T)
		Self.Remove(val)
	End
	
	Method InsertItem:Void(index:Int, val:T)
		Throw New UnsupportedOperationException
	End
	
	Method DeleteItem:T(index:Int)
		Throw New UnsupportedOperationException
	End
	
	Method ClearAll:Void()
		Self.Clear()
	End
	
	Method ContainsItem:Bool(value:T)
		Return Self.Contains(value)
	End
	
	Method GetItem:T(index:Int)
		Throw New UnsupportedOperationException
	End
	
	Method SetItem:Void(index:Int, value:T)
		Throw New UnsupportedOperationException
	End
	
	Method FindItem:Int(value:T)
		Throw New UnsupportedOperationException
	End
	
	Method SortItems:Void(ascending:Bool = True)
		Throw New UnsupportedOperationException
	End
	
	' overridden and implemented methods
	Method Count:Int()
		Return Super.Count()
	End
	
	Method Compare:Int(lhs:T, rhs:T)
		Throw New UnsupportedOperationException
	End
	
	Method Equals:Bool(lhs:T, rhs:T)
		Throw New UnsupportedOperationException
	End
	
	Method ToArray:T[]()
		Local arr:T[] = New T[Self.Count()]
		Local i:Int = 0
		For Local v := EachIn Self
			arr[i] = v
			i += 1
		Next
		Return arr
	End
	
	Method FillArray:Int(arr:T[])
		' TODO: FillArray
		'Return Super.ToArray()
		Return 0
	End
	
	Method IsEmpty:Bool()
		Return Super.IsEmpty()
	End
	
	Method Items:IEnumerable<T>() Property
		Return New WrappedSetEnumerable<T>(Self)
	End
	
Private
	Field comparator:IComparator<T>
	
Public
	Method Comparator:IComparator<T>() Property; Return Self.comparator; End
	Method Comparator:Void(comparator:IComparator<T>) Property; Self.comparator = comparator; End
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
