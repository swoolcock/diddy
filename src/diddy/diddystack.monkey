Strict
Private
Import diddy.containers
Import diddy.exception

Public
#Rem monkeydoc
	The DiddyStack class extends the official Monkey Stack class and implements Diddy's IContainer interface.
	As with the other Diddy container classes, it simplifies mixing and matching of container types by sharing
	common method names.
#End
Class DiddyStack<T> Extends Stack<T> Implements IContainer<T>
Private
	Global NIL:T
	
Public
	Method New()
		Super.New()
	End

	Method New(data:T[])
		Super.New(data)
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
			Self.Push(val)
		Next
	End

	Method AddAll:Void(src:List<T>)
		For Local val := EachIn src
			Self.Push(val)
		Next
	End
	
	Method AddAll:Void(src:Set<T>)
		For Local val := EachIn src
			Self.Push(val)
		Next
	End
	
	Method AddContainer:Void(src:IContainer<T>)
		For Local val := Eachin src.Items
			Self.Push(val)
		Next
	End
	
	' RemoveAll
	Method RemoveAll:Void(src:Stack<T>)
		For Local val := EachIn src
			Self.RemoveEach(val)
		Next
	End
	
	Method RemoveAll:Void(src:List<T>)
		For Local val := EachIn src
			Self.RemoveEach(val)
		Next
	End
	
	Method RemoveAll:Void(src:Set<T>)
		For Local val := Eachin src
			Self.RemoveEach(val)
		Next
	End
	
	Method RemoveContainer:Void(src:IContainer<T>)
		For Local val := Eachin src.Items
			Self.RemoveEach(val)
		Next
	End
	
	' RetainAll
	Method RetainAll:Void(src:Stack<T>)
		Local arr:T[] = Self.ToArray()
		For Local val := Eachin arr
			If Not src.Contains(val) Then
				Self.RemoveEach(val)
			End
		Next
	End
	
	Method RetainAll:Void(src:List<T>)
		Local arr:T[] = Self.ToArray()
		For Local val := EachIn arr
			If Not src.Contains(val) Then
				Self.RemoveEach(val)
			End
		Next
	End
	
	Method RetainAll:Void(src:Set<T>)
		Local arr:T[] = Self.ToArray()
		For Local val := EachIn arr
			If Not src.Contains(val) Then
				Self.RemoveEach(val)
			End
		Next
	End
	
	Method RetainContainer:Void(src:IContainer<T>)
		#Rem FIXME
		Local arr:T[] = Self.ToArray()
		For Local val := Eachin arr
			If Not src.Contains(val) Then
				Self.RemoveEach(val)
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
		Self.Push(val)
	End
	
	Method RemoveItem:Void(val:T)
		Self.RemoveEach(val)
	End
	
	Method InsertItem:Void(index:Int, val:T)
		Self.Insert(index, val)
	End
	
	Method DeleteItem:T(index:Int)
		Local rv:T = Self.Get(index)
		Self.Remove(index)
		Return rv
	End
	
	Method ClearAll:Void()
		Self.Clear()
	End
	
	Method ContainsItem:Bool(value:T)
		Return Self.Contains(value)
	End
	
	Method GetItem:T(index:Int)
		Return Self.Get(index)
	End
	
	Method SetItem:Void(index:Int, value:T)
		Self.Set(index, value)
	End
	
	Method FindItem:Int(value:T)
		Return Self.Find(value)
	End
	
	Method SortItems:Void(ascending:Bool = True)
		Sort(ascending)
	End
	
	' overridden and implemented methods
	Method Count:Int()
		Return Self.Length
	End
	
	Method Compare:Int(lhs:T, rhs:T)
		Return Super.Compare(lhs,rhs)'Self.CompareImpl(lhs, rhs)
	End
	
	Method Equals:Bool(lhs:T, rhs:T)
		Return Self.Compare(lhs, rhs) = 0
	End
	
	Method ToArray:T[]()
		Return Super.ToArray()
	End
	
	Method FillArray:Int(arr:T[])
		Local cnt:Int = Count()
		If arr.Length < cnt Then Throw New IllegalArgumentException("DiddyStack.FillArray: Array length too small ("+arr.Length+"<"+cnt+")")
		For Local i:Int = 0 Until Count()
			arr[i] = Get(i)
		Next
		Return cnt
	End
	
	Method IsEmpty:Bool()
		Return Super.IsEmpty()
	End
	
	Method Sort:Void(ascending:Bool = True)
		If Self.comparator Then
			' TODO
		Else
			Super.Sort(ascending)
		End
	End
	
	Method Items:IEnumerable<T>() Property
		Return New WrappedStackEnumerable<T>(Self)
	End
	
Private
	Field comparator:IComparator<T>
	
Public
	Method Comparator:IComparator<T>() Property; Return Self.comparator; End
	Method Comparator:Void(comparator:IComparator<T>) Property; Self.comparator = comparator; End
End

#Rem monkeydoc
	DiddyIntStack extends DiddyStack with the primitive Int.
#End
Class DiddyIntStack Extends DiddyStack<Int>
	Method New(data:Int[])
		Super.New(data)
	End
End

#Rem monkeydoc
	DiddyFloatStack extends DiddyStack with the primitive Float.
#End
Class DiddyFloatStack Extends DiddyStack<Float>
	Method New(data:Float[])
		Super.New(data)
	End
End

#Rem monkeydoc
	DiddyStringStack extends DiddyStack with the primitive String.
	As per Monkey's StringStack, it provides the ability to join all the stack elements as a single string.
#End
Class DiddyStringStack Extends DiddyStack<String>
	Method New(data:String[])
		Super.New(data)
	End
	
	Method Join:String(separator:String = "")
		Return separator.Join(ToArray())
	End
End
