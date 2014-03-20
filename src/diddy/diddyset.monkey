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
	The DiddySet class extends the official Monkey Set class and implements Diddy's IContainer interface.
	As with the other Diddy container classes, it simplifies mixing and matching of container types by sharing
	common method names.
#End
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
		If Not src Then Throw New IllegalArgumentException("DiddySet.New: Source Stack must not be null")
		AddAll(src)
	End
	
	Method New(src:List<T>)
		If Not src Then Throw New IllegalArgumentException("DiddySet.New: Source List must not be null")
		AddAll(src)
	End
	
	Method New(src:Set<T>)
		If Not src Then Throw New IllegalArgumentException("DiddySet.New: Source Set must not be null")
		AddAll(src)
	End
	
	' AddAll
	Method AddAll:Void(src:Stack<T>)
		If Not src Then Throw New IllegalArgumentException("DiddySet.AddAll: Source Stack must not be null")
		For Local val := EachIn src
			Self.Insert(val)
		Next
	End

	Method AddAll:Void(src:List<T>)
		If Not src Then Throw New IllegalArgumentException("DiddySet.AddAll: Source List must not be null")
		For Local val := EachIn src
			Self.Insert(val)
		Next
	End
	
	Method AddAll:Void(src:Set<T>)
		If Not src Then Throw New IllegalArgumentException("DiddySet.AddAll: Source Set must not be null")
		For Local val := Eachin src
			Self.Insert(val)
		Next
	End
	
	Method AddContainer:Void(src:IContainer<T>)
		If Not src Then Throw New IllegalArgumentException("DiddySet.AddContainer: Source IContainer must not be null")
		For Local val := Eachin src.Items
			Self.Insert(val)
		Next
	End
	
	' RemoveAll
	Method RemoveAll:Void(src:Stack<T>)
		If Not src Then Throw New IllegalArgumentException("DiddySet.RemoveAll: Source Stack must not be null")
		For Local val := EachIn src
			Self.Remove(val)
		Next
	End
	
	Method RemoveAll:Void(src:List<T>)
		If Not src Then Throw New IllegalArgumentException("DiddySet.RemoveAll: Source List must not be null")
		For Local val := EachIn src
			Self.Remove(val)
		Next
	End
	
	Method RemoveAll:Void(src:Set<T>)
		If Not src Then Throw New IllegalArgumentException("DiddySet.RemoveAll: Source Set must not be null")
		For Local val := Eachin src
			Self.Remove(val)
		Next
	End
	
	Method RemoveContainer:Void(src:IContainer<T>)
		If Not src Then Throw New IllegalArgumentException("DiddySet.RemoveContainer: Source IContainer must not be null")
		For Local val := Eachin src.Items
			Self.Remove(val)
		Next
	End
	
	' RetainAll
	Method RetainAll:Void(src:Stack<T>)
		If Not src Then Throw New IllegalArgumentException("DiddySet.RetainAll: Source Stack must not be null")
		Local arr:T[] = Self.ToArray()
		For Local val := EachIn arr
			If Not src.Contains(val) Then
				Self.Remove(val)
			End
		Next
	End
	
	Method RetainAll:Void(src:List<T>)
		If Not src Then Throw New IllegalArgumentException("DiddySet.RetainAll: Source List must not be null")
		Local arr:T[] = Self.ToArray()
		For Local val := EachIn arr
			If Not src.Contains(val) Then
				Self.Remove(val)
			End
		Next
	End
	
	Method RetainAll:Void(src:Set<T>)
		If Not src Then Throw New IllegalArgumentException("DiddySet.RetainAll: Source Set must not be null")
		Local arr:T[] = Self.ToArray()
		For Local val := Eachin arr
			If Not src.Contains(val) Then
				Self.Remove(val)
			End
		Next
	End
	
	Method RetainContainer:Void(src:IContainer<T>)
		If Not src Then Throw New IllegalArgumentException("DiddySet.RetainContainer: Source IContainer must not be null")
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
		If Not src Then Throw New IllegalArgumentException("DiddySet.ContainsAll: Source Stack must not be null")
		For Local val := Eachin src
			If Not Self.Contains(val) Return False
		Next
		Return True
	End
	
	Method ContainsAll:Bool(src:List<T>)
		If Not src Then Throw New IllegalArgumentException("DiddySet.ContainsAll: Source List must not be null")
		For Local val := Eachin src
			If Not Self.Contains(val) Return False
		Next
		Return True
	End
	
	Method ContainsAll:Bool(src:Set<T>)
		If Not src Then Throw New IllegalArgumentException("DiddySet.ContainsAll: Source Set must not be null")
		For Local val := Eachin src
			If Not Self.Contains(val) Return False
		Next
		Return True
	End
	
	Method ContainsContainer:Bool(src:IContainer<T>)
		If Not src Then Throw New IllegalArgumentException("DiddySet.ContainsContainer: Source IContainer must not be null")
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
		Return lhs = rhs
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
		Local cnt:Int = Self.Count()
		If arr.Length < cnt Then Throw New IllegalArgumentException("DiddySet.FillArray: Array length too small ("+arr.Length+"<"+cnt+")")
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
	
	Method Items:IEnumerable<T>() Property
		Return New WrappedSetEnumerable<T>(Self)
	End
	
	Method Comparator:IComparator<T>() Property
		Throw New UnsupportedOperationException
	End
	
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
