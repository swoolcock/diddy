#Rem
Copyright (c) 2011 Steve Revill and Shane Woolcock
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#End

#Rem
Header: Provides the DiddyPool class.
#End

Strict
Private
Import diddy.containers
Import diddy.exception

Public
#Rem
Summary: The DiddyPool class extends DiddyStack to provide functionality similar to the official Pool class.
	As with the other Diddy container classes, it simplifies mixing and matching of container types by sharing
	common method names.
#End
Class DiddyPool<T> Extends DiddyStack<T>
Private
	Global NIL:T
	Field freeObjects:DiddyStack<T> = New DiddyStack<T>
	
	Method CheckRange:Void(index:Int, low:Int=0, high:Int=-1)
		If high < 0 Then high = Self.Count()
		If index < low Or index >= high Then
			Throw New IndexOutOfBoundsException("DiddyPool.CheckRange: index " + index + " not in range " + low + " <= index < " + high)
		End
	End
	
	Method Prepopulate:Void(amount:Int)
		For Local i:Int = 0 Until amount
			freeObjects.Push(New T)
		Next
	End

Public
#Rem
Summary: Constructor to create an empty DiddyPool.
The "free objects" stack may optionally be prepopulated.
#End
	Method New(initialCapacity:Int=0)
		Super.New()
		Prepopulate(initialCapacity)
	End
	
#Rem
Summary: Constructor to create a DiddyPool with the contents of the passed array.
The "free objects" stack may optionally be prepopulated.
#End
	Method New(data:T[], initialCapacity:Int=0)
		Super.New(data)
		Prepopulate(initialCapacity)
	End
	
#Rem
Summary: Constructor to create a DiddyPool with the contents of the passed Stack.
The "free objects" stack may optionally be prepopulated.
#End
	Method New(src:Stack<T>, initialCapacity:Int=0)
		Super.New(src)
		Prepopulate(initialCapacity)
	End
	
#Rem
Summary: Constructor to create a DiddyPool with the contents of the passed List.
The "free objects" stack may optionally be prepopulated.
#End	
	Method New(src:List<T>, initialCapacity:Int=0)
		Super.New(src)
		Prepopulate(initialCapacity)
	End
	
#Rem
Summary: Constructor to create a DiddyPool with the contents of the passed Set.
The "free objects" stack may optionally be prepopulated.
#End
	Method New(src:Set<T>, initialCapacity:Int=0)
		Super.New(src)
		Prepopulate(initialCapacity)
	End
	
#Rem
Summary: Creates or reuses one or more instances of T and puts them at the end of the DiddyPool.
The final instance of T to be added to the DiddyPool will be returned.
#End
	Method Allocate:T(count:Int=1)
		Local obj:T = Null
		For Local i:Int = 0 Until count
			If freeObjects.IsEmpty() Then
				obj = New T
			Else
				obj = freeObjects.Pop()
			End
			Self.Push(obj)
		Next
		Return obj
	End
	
#Rem
Summary: Removes the passed value from the DiddyPool if it exists, and puts it on the end of the "free objects" stack.
If T implements the IPoolable interface, IPoolable.Reset() will be called on that object.
#End
	Method Free:Void(val:T)
		If val Then
			Self.RemoveItem(val)
			freeObjects.Push(val)
			If IPoolable(val) Then IPoolable(val).Reset()
		End
	End
	
#Rem
Summary: Deletes the element at the given index and puts it on the end of the "free objects" stack.
If T implements the IPoolable interface, IPoolable.Reset() will be called on that object.
#End
	Method FreeIndex:Void(index:Int)
#If CONFIG="debug" Then
		CheckRange(index)
#End
		Local val:T = Self.DeleteItem(index)
		If val Then
			freeObjects.Push(val)
			If IPoolable(val) Then IPoolable(val).Reset()
		End
	End
	
#Rem
Summary: Removes all objects from the DiddyPool and puts them on the end of the "free objects" stack.
If T implements the IPoolable interface, IPoolable.Reset() will be called on each object in turn.
#End
	Method FreeAll:Void()
		For Local obj:T = EachIn Self
			freeObjects.Push(obj)
			If IPoolable(obj) Then IPoolable(obj).Reset()
		Next
		Self.Clear()
	End
	
#Rem
Summary: Allows the developer to enumerate on the "free object" stack.
#End
	Method FreeItems:IEnumerable<T>() Property
		Return New WrappedStackEnumerable<T>(freeObjects)
	End
	
#Rem
Summary: Returns the number of objects currently available on the "free object" stack.
#End
	Method FreeCount:Int()
		Return freeObjects.Count()
	End
	
#Rem
Summary: Clears the contents of the "free object" stack.
#End
	Method ClearFree:Void()
		freeObjects.Clear()
	End
End
