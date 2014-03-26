#Rem
Copyright (c) 2011 Steve Revill and Shane Woolcock
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#End

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
	
	Method CheckRange:Void(index:Int, low:Int=0, high:Int=-1)
		If high < 0 Then high = Self.Count()
		If index < low Or index >= high Then
			Throw New IndexOutOfBoundsException("DiddyList.CheckRange: index " + index + " not in range " + low + " <= index < " + high)
		End
	End
	
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
		For Local val := EachIn src
			Self.AddLast(val)
		Next
	End
	
	Method AddContainer:Void(src:IContainer<T>)
		If Not src Then Throw New IllegalArgumentException("DiddyList.AddContainer: Source IContainer must not be null")
		For Local val := EachIn src.Items()
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
		For Local val := EachIn src
			Self.RemoveEach(val)
		Next
	End
	
	Method RemoveContainer:Void(src:IContainer<T>)
		If Not src Then Throw New IllegalArgumentException("DiddyList.RemoveContainer: Source IContainer must not be null")
		For Local val := EachIn src.Items()
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
		Local arr:T[] = Self.ToArray()
		For Local val := EachIn arr
			If Not src.ContainsItem(val) Then
				Self.RemoveEach(val)
			End
		Next
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
		For Local val := EachIn src.Items()
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
#If CONFIG="debug" Then
		CheckRange(index,,Self.Count()+1)
#End
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
		End
	End
	
	Method DeleteItem:T(index:Int)
		If Self.IsEmpty() Then Return NIL
#If CONFIG="debug" Then
		CheckRange(index)
#End
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
#If CONFIG="debug" Then
		CheckRange(index)
#End
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
#If CONFIG="debug" Then
		CheckRange(index)
#End
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
		If Self.comparator Then Return Self.comparator.Compare(lhs, rhs)
		If IComparableWrapper.IsComparable(lhs) Or IComparableWrapper.IsComparable(rhs) Then Return IComparableWrapper.Compare(lhs, rhs)
		Return Super.Compare(lhs, rhs)
	End
	
	Method Equals:Bool(lhs:T, rhs:T)
		Return lhs = rhs
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
	
	Method Reverse:Void()
		For Local i:Int = 0 Until Count()/2
			SwapItems(i, Count()-i-1)
		Next
	End
	
	Method SwapItems:Void(index1:Int, index2:Int)
		Local temp:T = GetItem(index1)
		SetItem(index1, GetItem(index2))
		SetItem(index2, temp)
	End
	
	Method Shuffle:Void()
		For Local i:Int = Count() - 1 To 0 Step -1
			SwapItems(i, Rnd(i))
		Next
	End
	
	Method Items:IEnumerable<T>(pred:IPredicate<T>=Null)
		Return New WrappedListEnumerable<T>(Self, pred)
	End
	
	Method Truncate:Void(size:Int)
		While Count() > size
			RemoveLast()
		End
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
	
	Method Equals:Bool(lhs:Int, rhs:Int)
		Return lhs=rhs
	End
	
	Method Compare:Int(lhs:Int, rhs:Int)
		If Self.Comparator Then Return Self.Comparator.Compare(lhs, rhs)
		Return lhs-rhs
	End
End

Class DiddyFloatList Extends DiddyList<Float>
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

Class DiddyStringList Extends DiddyList<String>
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
