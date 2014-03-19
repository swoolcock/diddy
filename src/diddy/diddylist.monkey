Strict
Private
Import diddy.containers
Import diddy.exception

Public
#Rem monkeydoc
	The DiddyList class extends the official Monkey List class and implements Diddy's IContainer interface.
	As with the other Diddy container classes, it simplifies mixing and matching of container types by sharing
	common method names.
#End
Class DiddyList<T> Extends List<T> Implements IContainer<T>
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
		If Not src Then Throw New IllegalArgumentException("DiddyList.New: Source Stack must not be null")
		AddAll(src)
	End
	
	Method New(src:List<T>)
		If Not src Then Throw New IllegalArgumentException("DiddyList.New: Source List must not be null")
		AddAll(src)
	End
	
	Method New(src:Set<T>)
		If Not src Then Throw New IllegalArgumentException("DiddyList.New: Source Set must not be null")
		AddAll(src)
	End
	
	' AddAll
	Method AddAll:Void(src:Stack<T>)
		If Not src Then Throw New IllegalArgumentException("DiddyList.AddAll: Source Stack must not be null")
		For Local val := EachIn src
			Self.AddLast(val)
		Next
	End

	Method AddAll:Void(src:List<T>)
		If Not src Then Throw New IllegalArgumentException("DiddyList.AddAll: Source List must not be null")
		For Local val := EachIn src
			Self.AddLast(val)
		Next
	End
	
	Method AddAll:Void(src:Set<T>)
		If Not src Then Throw New IllegalArgumentException("DiddyList.AddAll: Source Set must not be null")
		For Local val := Eachin src
			Self.AddLast(val)
		Next
	End
	
	Method AddContainer:Void(src:IContainer<T>)
		If Not src Then Throw New IllegalArgumentException("DiddyList.AddContainer: Source IContainer must not be null")
		For Local val := Eachin src.Items
			Self.AddLast(val)
		Next
	End
	
	' RemoveAll
	Method RemoveAll:Void(src:Stack<T>)
		If Not src Then Throw New IllegalArgumentException("DiddyList.RemoveAll: Source Stack must not be null")
		For Local val := EachIn src
			Self.RemoveEach(val)
		Next
	End
	
	Method RemoveAll:Void(src:List<T>)
		If Not src Then Throw New IllegalArgumentException("DiddyList.RemoveAll: Source List must not be null")
		For Local val := EachIn src
			Self.RemoveEach(val)
		Next
	End
	
	Method RemoveAll:Void(src:Set<T>)
		If Not src Then Throw New IllegalArgumentException("DiddyList.RemoveAll: Source Set must not be null")
		For Local val := Eachin src
			Self.RemoveEach(val)
		Next
	End
	
	Method RemoveContainer:Void(src:IContainer<T>)
		If Not src Then Throw New IllegalArgumentException("DiddyList.RemoveContainer: Source IContainer must not be null")
		For Local val := Eachin src.Items
			Self.RemoveEach(val)
		Next
	End
	
	' RetainAll
	Method RetainAll:Void(src:Stack<T>)
		If Not src Then Throw New IllegalArgumentException("DiddyList.RetainAll: Source Stack must not be null")
		Local arr:T[] = Self.ToArray()
		For Local val := EachIn arr
			If Not src.Contains(val) Then
				Self.RemoveEach(val)
			End
		Next
	End
	
	Method RetainAll:Void(src:List<T>)
		If Not src Then Throw New IllegalArgumentException("DiddyList.RetainAll: Source List must not be null")
		Local arr:T[] = Self.ToArray()
		For Local val := EachIn arr
			If Not src.Contains(val) Then
				Self.RemoveEach(val)
			End
		Next
	End
	
	Method RetainAll:Void(src:Set<T>)
		If Not src Then Throw New IllegalArgumentException("DiddyList.RetainAll: Source Set must not be null")
		Local arr:T[] = Self.ToArray()
		For Local val := EachIn arr
			If Not src.Contains(val) Then
				Self.RemoveEach(val)
			End
		Next
	End
	
	Method RetainContainer:Void(src:IContainer<T>)
		If Not src Then Throw New IllegalArgumentException("DiddyList.RetainContainer: Source Container must not be null")
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
		If Not src Then Throw New IllegalArgumentException("DiddyList.ContainsAll: Source Stack must not be null")
		For Local val := EachIn src
			If Not Self.Contains(val) Return False
		Next
		Return True
	End
	
	Method ContainsAll:Bool(src:List<T>)
		If Not src Then Throw New IllegalArgumentException("DiddyList.ContainsAll: Source List must not be null")
		For Local val := EachIn src
			If Not Self.Contains(val) Return False
		Next
		Return True
	End
	
	Method ContainsAll:Bool(src:Set<T>)
		If Not src Then Throw New IllegalArgumentException("DiddyList.ContainsAll: Source Set must not be null")
		For Local val := EachIn src
			If Not Self.Contains(val) Return False
		Next
		Return True
	End
	
	Method ContainsContainer:Bool(src:IContainer<T>)
		If Not src Then Throw New IllegalArgumentException("DiddyList.ContainsContainer: Source IContainer must not be null")
		For Local val := Eachin src.Items
			If Not Self.Contains(val) Return False
		Next
		Return True
	End
	
	' General
	Method AddItem:Void(val:T)
		Self.AddLast(val)
	End
	
	Method RemoveItem:Void(val:T)
		Self.RemoveEach(val)
	End
	
	Method InsertItem:Void(index:Int, val:T)
		If index = 0 Or Self.IsEmpty() Then
			Self.AddFirst(val)
		ElseIf index >= Self.Count() Then
			Self.AddLast(val)
		Else
			' Somehow Mark made Node<T> constructor accept Node instance with no type parameter, so we have to search twice (once in GetItem, once in InsertBefore)
			Local item:T = Self.GetItem(index)
			If item Then
				Self.InsertBefore(item, val)
			End
			#Rem
			Local node:list.Node<T> = Self.FirstNode()
			While node
				If Self.Equals(node.Value(), val) Then
					New list.Node<T>(node, node.PrevNode())
					Exit
				End
				node = node.NextNode()
			End
			#End
		End
	End
	
	Method DeleteItem:T(index:Int)
		If Self.IsEmpty() Then Return NIL
		Local i:Int = 0
		Local node:list.Node<T> = Self.FirstNode()
		While node
			If i = index Then
				Local rv:T = node.Value()
				node.Remove()
				Return rv
			End
			node = node.NextNode()
			i += 1
		End
		Return NIL
	End
	
	Method ClearAll:Void()
		Self.Clear()
	End
	
	Method ContainsItem:Bool(value:T)
		Return Self.Contains(value)
	End
	
	Method GetItem:T(index:Int)
		If Self.IsEmpty() Then Return NIL
		Local i:Int = 0
		Local node:list.Node<T> = Self.FirstNode()
		While node
			If i = index Then Return node.Value()
			node = node.NextNode()
			i += 1
		End
		Return NIL
	End
	
	Method SetItem:Void(index:Int, value:T)
		If Self.IsEmpty() Then Return
		Local i:Int = 0
		Local node:list.Node<T> = Self.FirstNode()
		While node
			If i = index Then
				Self.InsertBefore(node.Value(), value)
				node.Remove()
				Return
			End
			i += 1
		End
	End
	
	Method FindItem:Int(value:T)
		If Self.IsEmpty() Then Return -1
		Local i:Int = 0
		Local node:list.Node<T> = Self.FirstNode()
		While node
			If Self.Equals(node.Value(), value) Then Return i
			node = node.NextNode()
			i += 1
		End
		Return -1
	End
	
	Method SortItems:Void(ascending:Bool = True)
		Sort(ascending)
	End
	
	' overridden and implemented methods
	Method Count:Int()
		Return Super.Count()
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
		Local cnt:Int = Self.Count()
		If arr.Length < cnt Then Throw New IllegalArgumentException("DiddyList.FillArray: Array length too small ("+arr.Length+"<"+cnt+")")
		Local i:Int = 0
		For Local v:T = EachIn Self
			arr[i] = v
			i += 1
		Next
		Return i
	End
	
	Method IsEmpty:Bool()
		Return Super.IsEmpty()
	End
	
	Method Sort:Int(ascending:Int = True)
		If Self.comparator Then
			' TODO
			Return 0
		Else
			Return Super.Sort(ascending)
		End
	End
	
	Method Items:IEnumerable<T>() Property
		Return New WrappedListEnumerable<T>(Self)
	End
	
Private
	Field comparator:IComparator<T>

Public
	Method Comparator:IComparator<T>() Property; Return Self.comparator; End
	Method Comparator:Void(comparator:IComparator<T>) Property; Self.comparator = comparator; End
End

Class DiddyIntList Extends DiddyList<Int>
	Method New(data:Int[])
		Super.New(data)
	End
End

Class DiddyFloatList Extends DiddyList<Float>
	Method New(data:Float[])
		Super.New(data)
	End
End

Class DiddyStringList Extends DiddyList<String>
	Method New(data:String[])
		Super.New(data)
	End
	
	Method Join:String(separator:String = "")
		Return separator.Join(ToArray())
	End
End
