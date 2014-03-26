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
	The DiddyStack class extends the official Monkey Stack class and implements Diddy's IContainer interface.
	As with the other Diddy container classes, it simplifies mixing and matching of container types by sharing
	common method names.
#End
Class DiddyStack<T> Extends Stack<T> Implements IContainer<T>
Private
	Global NIL:T
	
	Method CheckRange:Void(index:Int, low:Int=0, high:Int=-1)
		If high < 0 Then high = Self.Count()
		If index < low Or index >= high Then
			Throw New IndexOutOfBoundsException("DiddyStack.CheckRange: index " + index + " not in range " + low + " <= index < " + high)
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
		If Not src Then Throw New IllegalArgumentException("DiddyStack.New: Source Stack must not be null")
		AddAll(src)
	End
	
	Method New(src:List<T>)
		If Not src Then Throw New IllegalArgumentException("DiddyStack.New: Source List must not be null")
		AddAll(src)
	End
	
	Method New(src:Set<T>)
		If Not src Then Throw New IllegalArgumentException("DiddyStack.New: Source Set must not be null")
		AddAll(src)
	End
	
	' AddAll
	Method AddAll:Void(src:Stack<T>)
		If Not src Then Throw New IllegalArgumentException("DiddyStack.AddAll: Source Stack must not be null")
		For Local val := EachIn src
			Self.Push(val)
		Next
	End

	Method AddAll:Void(src:List<T>)
		If Not src Then Throw New IllegalArgumentException("DiddyStack.AddAll: Source List must not be null")
		For Local val := EachIn src
			Self.Push(val)
		Next
	End
	
	Method AddAll:Void(src:Set<T>)
		If Not src Then Throw New IllegalArgumentException("DiddyStack.AddAll: Source Set must not be null")
		For Local val := EachIn src
			Self.Push(val)
		Next
	End
	
	Method AddContainer:Void(src:IContainer<T>)
		If Not src Then Throw New IllegalArgumentException("DiddyStack.AddContainer: Source IContainer must not be null")
		For Local val := EachIn src.Items()
			Self.Push(val)
		Next
	End
	
	' RemoveAll
	Method RemoveAll:Void(src:Stack<T>)
		If Not src Then Throw New IllegalArgumentException("DiddyStack.RemoveAll: Source Stack must not be null")
		For Local val := EachIn src
			Self.RemoveEach(val)
		Next
	End
	
	Method RemoveAll:Void(src:List<T>)
		If Not src Then Throw New IllegalArgumentException("DiddyStack.RemoveAll: Source List must not be null")
		For Local val := EachIn src
			Self.RemoveEach(val)
		Next
	End
	
	Method RemoveAll:Void(src:Set<T>)
		If Not src Then Throw New IllegalArgumentException("DiddyStack.RemoveAll: Source Set must not be null")
		For Local val := EachIn src
			Self.RemoveEach(val)
		Next
	End
	
	Method RemoveContainer:Void(src:IContainer<T>)
		If Not src Then Throw New IllegalArgumentException("DiddyStack.RemoveContainer: Source IContainer must not be null")
		For Local val := EachIn src.Items()
			Self.RemoveEach(val)
		Next
	End
	
	' RetainAll
	Method RetainAll:Void(src:Stack<T>)
		If Not src Then Throw New IllegalArgumentException("DiddyStack.RetainAll: Source Stack must not be null")
		Local arr:T[] = Self.ToArray()
		For Local val := EachIn arr
			If Not src.Contains(val) Then
				Self.RemoveEach(val)
			End
		Next
	End
	
	Method RetainAll:Void(src:List<T>)
		If Not src Then Throw New IllegalArgumentException("DiddyStack.RetainAll: Source List must not be null")
		Local arr:T[] = Self.ToArray()
		For Local val := EachIn arr
			If Not src.Contains(val) Then
				Self.RemoveEach(val)
			End
		Next
	End
	
	Method RetainAll:Void(src:Set<T>)
		If Not src Then Throw New IllegalArgumentException("DiddyStack.RetainAll: Source Set must not be null")
		Local arr:T[] = Self.ToArray()
		For Local val := EachIn arr
			If Not src.Contains(val) Then
				Self.RemoveEach(val)
			End
		Next
	End
	
	Method RetainContainer:Void(src:IContainer<T>)
		If Not src Then Throw New IllegalArgumentException("DiddyStack.RetainContainer: Source IContainer must not be null")
		Local arr:T[] = Self.ToArray()
		For Local val := EachIn arr
			If Not src.ContainsItem(val) Then
				Self.RemoveEach(val)
			End
		Next
	End
	
	' ContainsAll
	Method ContainsAll:Bool(src:Stack<T>)
		If Not src Then Throw New IllegalArgumentException("DiddyStack.ContainsAll: Source Stack must not be null")
		For Local val := EachIn src
			If Not Self.Contains(val) Return False
		Next
		Return True
	End
	
	Method ContainsAll:Bool(src:List<T>)
		If Not src Then Throw New IllegalArgumentException("DiddyStack.ContainsAll: Source List must not be null")
		For Local val := EachIn src
			If Not Self.Contains(val) Return False
		Next
		Return True
	End
	
	Method ContainsAll:Bool(src:Set<T>)
		If Not src Then Throw New IllegalArgumentException("DiddyStack.ContainsAll: Source Set must not be null")
		For Local val := EachIn src
			If Not Self.Contains(val) Return False
		Next
		Return True
	End
	
	Method ContainsContainer:Bool(src:IContainer<T>)
		If Not src Then Throw New IllegalArgumentException("DiddyStack.ContainsContainer: Source IContainer must not be null")
		For Local val := EachIn src.Items()
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
#If CONFIG="debug" Then
		CheckRange(index,,Self.Count()+1)
#End
		Self.Insert(index, val)
	End
	
	Method DeleteItem:T(index:Int)
#If CONFIG="debug" Then
		CheckRange(index)
#End
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
#If CONFIG="debug" Then
		CheckRange(index)
#End
		Return Self.Get(index)
	End
	
	Method SetItem:Void(index:Int, value:T)
#If CONFIG="debug" Then
		CheckRange(index)
#End
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
	
	Method Reverse:Void()
		For Local i:Int = 0 Until Count()/2
			SwapItems(i, Count()-i-1)
		Next
	End
	
	Method SwapItems:Void(index1:Int, index2:Int)
#If CONFIG="debug" Then
		CheckRange(index1)
		CheckRange(index2)
#End
		Local temp:T = Self.Get(index1)
		Self.Set(index1, Self.Get(index2))
		Self.Set(index2, temp)
	End
	
	Method Shuffle:Void()
		For Local i:Int = Count() - 1 To 0 Step -1
			SwapItems(i, Rnd(i))
		Next
	End
	
	Method Truncate:Void(size:Int)
		While Count() > size
			Pop()
		End
	End
	
	Method Items:IEnumerable<T>(pred:IPredicate<T>=Null)
		Return New WrappedStackEnumerable<T>(Self, pred)
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
	
	Method Equals:Bool(lhs:Int, rhs:Int)
		Return lhs=rhs
	End
	
	Method Compare:Int(lhs:Int, rhs:Int)
		If Self.Comparator Then Return Self.Comparator.Compare(lhs, rhs)
		Return lhs-rhs
	End
End

#Rem monkeydoc
	DiddyFloatStack extends DiddyStack with the primitive Float.
#End
Class DiddyFloatStack Extends DiddyStack<Float>
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
	
	Method Equals:Bool(lhs:String, rhs:String)
		Return lhs=rhs
End

	Method Compare:Int(lhs:String, rhs:String)
		If Self.Comparator Then Return Self.Comparator.Compare(lhs, rhs)
		Return lhs.Compare(rhs)
	End
End
