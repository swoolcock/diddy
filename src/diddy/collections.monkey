#Rem
Copyright (c) 2011 Steve Revill and Shane Woolcock
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#End

Strict

Import assert
Import exception
Import comparator
Import quicksort

#Rem
header: Monkey Collections Framework
Based loosely on the Java Collections Framework
#End

'''' Top level Collection stuff ''''

#Rem
	Summary: ICollection
	We use Object[] rather than E[] in many places so that it is easier to pass them into QuickSort.
#End
Class ICollection<E> Abstract
Private
	' A custom comparator to use for sorting and comparing items.
	Field comparator:IComparator = Null
	
Public
' Abstract
	Method Add:Bool(o:E) Abstract
	Method AddAll:Bool(c:ICollection<E>) Abstract
	Method Clear:Void() Abstract
	Method Contains:Bool(o:E) Abstract
	Method ContainsAll:Bool(c:ICollection<E>) Abstract
	Method Enumerator:IEnumerator<E>() Abstract ' should return an appropriate IEnumerator for the collection
	Method FillArray:Int(arr:Object[]) Abstract ' populates the passed array and returns the number of items filled. best used for android
	Method IsEmpty:Bool() Abstract
	Method Remove:Bool(o:E) Abstract
	Method RemoveAll:Bool(c:ICollection<E>) Abstract
	Method RetainAll:Bool(c:ICollection<E>) Abstract
	Method Size:Int() Property Abstract
	Method Sort:Void(reverse:Bool = False, comp:IComparator = Null) Abstract
	Method ToArray:Object[]() Abstract ' creates a new array of the correct size and returns it

' Methods
	'summary: due to a limitation in Monkey regarding ObjectEnumerator and inheritance, this simply calls Enumerator()
	Method ObjectEnumerator:IEnumerator<E>()
		Return Enumerator()
	End
	
' Properties
	'summary: Property to read comparator
	Method Comparator:IComparator() Property
		Return comparator
	End
	
	'summary: Property to write comparator
	Method Comparator:Void(comparator:IComparator) Property
		Self.comparator = comparator
	End
End



#Rem
	summary: IEnumerator
	Used in the ObjectEnumerator method for calls to EachIn.
	If retrieved and used manually, the HasPrevious/PreviousObject/Remove/First/Last methods can be called.
#End
Class IEnumerator<E>
' Abstract
	Method HasNext:Bool() Abstract
	Method HasPrevious:Bool() Abstract
	Method NextObject:E() Abstract
	Method PreviousObject:E() Abstract
	Method Remove:Void() Abstract
	Method First:Void() Abstract
	Method Last:Void() Abstract
	Method Reset:Void() Abstract
End

'''' List stuff ''''

#Rem
	summary: IList
	Extends ICollection to implement some of the abstract methods that apply to any kind of list.
#End
Class IList<E> Extends ICollection<E> Abstract
Private
	'summary: A counter for modifications to the list.  Used for concurrency checks.
	Field modCount:Int = 0
	
	'summary: Performs a range check.
	Method RangeCheck:Void(index:Int)
		Local size:Int = Self.Size()
		' range check doesn't use assert, for speed
		If index < 0 Or index >= size Then Throw New IndexOutOfBoundsException("IList.RangeCheck: Index out of bounds: " + index + " is not 0<=index<" + size)
	End
	
Public
' Abstract
	Method AddLast:Bool(o:E) Abstract
	Method RemoveLast:E() Abstract
	Method GetLast:E() Abstract
	Method AddFirst:Bool(o:E) Abstract
	Method RemoveFirst:E() Abstract
	Method GetFirst:E() Abstract
	Method Get:E(index:Int) Abstract
	Method Insert:Void(index:Int, o:E) Abstract
	Method InsertAll:Bool(index:Int, c:ICollection<E>) Abstract
	Method IndexOf:Int(o:E) Abstract
	Method LastIndexOf:Int(o:E) Abstract
	Method RemoveAt:E(index:Int) Abstract ' Can't overload Remove since it's an inherited method, and Monkey doesn't support that.
	Method RemoveRange:Void(fromIndex:Int, toIndex:Int) Abstract
	Method Set:E(index:Int, o:E) Abstract
	
' Methods
	'summary: Overrides ICollection
	Method Enumerator:IEnumerator<E>()
		Return New ListEnumerator<E>(Self)
	End
End



#Rem
	summary: ListEnumerator
	Extends IEnumerator to provide support for EachIn.  Blocks concurrent modification, but allows elements to be removed on the fly.
#End
Class ListEnumerator<E> Extends IEnumerator<E>
Private
	Field lst:IList<E>
	Field lastIndex:Int = 0
	Field index:Int = 0
	Field expectedModCount:Int = 0
	
	Method CheckConcurrency:Void()
		' for speed we don't use assert
		If lst.modCount <> expectedModCount Then Throw New ConcurrentModificationException("ListEnumerator.CheckConcurrency: Concurrent list modification")
	End

Public
' Constructors
	Method New(lst:IList<E>)
		Self.lst = lst
		expectedModCount = lst.modCount
	End

' Methods
	'summary: Overrides IEnumerator
	Method HasNext:Bool()
		CheckConcurrency()
		Return index < lst.Size
	End
	
	'summary: Overrides IEnumerator
	Method HasPrevious:Bool()
		CheckConcurrency()
		Return index > 0
	End
	
	'summary: Overrides IEnumerator
	Method NextObject:E()
		CheckConcurrency()
		lastIndex = index
		index += 1
		Return lst.Get(lastIndex)
	End
	
	'summary: Overrides IEnumerator
	Method PreviousObject:E()
		CheckConcurrency()
		index -= 1
		lastIndex = index
		Return lst.Get(lastIndex)
	End
	
	'summary: Overrides IEnumerator
	Method Remove:Void()
		CheckConcurrency()
		lst.RemoveAt(lastIndex)
		If lastIndex < index Then index -= 1
		lastIndex = -1
		expectedModCount = lst.modCount
	End
	
	'summary: Overrides IEnumerator
	Method First:Void()
		CheckConcurrency()
		index = 0
	End
	
	'summary: Overrides IEnumerator
	Method Last:Void()
		CheckConcurrency()
		index = lst.Size
	End
	
	'summary: Overrides IEnumerator
	Method Reset:Void()
		index = 0
		expectedModCount = lst.modCount
	End
End

#Rem
	summary: ArrayListEnumerator
	Extends ListEnumerator to avoid some method calls.
#End
Class ArrayListEnumerator<E> Extends ListEnumerator<E>
Private
	Field alst:ArrayList<E>

Public
' Constructors
	Method New(lst:ArrayList<E>)
		Super.New(lst)
		Self.alst = lst
		expectedModCount = alst.modCount
	End
	
' Methods
	'summary: Overrides ListEnumerator
	Method HasNext:Bool()
		CheckConcurrency()
		Return index < alst.size
	End
	
	'summary: Overrides ListEnumerator
	Method NextObject:E()
		CheckConcurrency()
		lastIndex = index
		index += 1
		Return E(alst.elements[lastIndex])
	End
	
	'summary: Overrides ListEnumerator
	Method PreviousObject:E()
		CheckConcurrency()
		index -= 1
		lastIndex = index
		Return E(alst.elements[lastIndex])
	End
End

Class IntListEnumerator Extends ListEnumerator<IntObject>
' Constructors
	Method New(lst:IList<IntObject>)
		Super.New(lst)
	End

' Methods
	Method NextInt:Int()
		CheckConcurrency()
		lastIndex = index
		index += 1
		Return lst.Get(lastIndex).value
	End

	Method PreviousInt:Int()
		CheckConcurrency()
		index -= 1
		lastIndex = index
		Return lst.Get(lastIndex).value
	End
End

Class FloatListEnumerator Extends ListEnumerator<FloatObject>
' Constructors
	Method New(lst:IList<FloatObject>)
		Super.New(lst)
	End

' Methods
	Method NextFloat:Float()
		CheckConcurrency()
		lastIndex = index
		index += 1
		Return lst.Get(lastIndex).value
	End
	
	Method PreviousFloat:Float()
		CheckConcurrency()
		index -= 1
		lastIndex = index
		Return lst.Get(lastIndex).value
	End
End

Class StringListEnumerator Extends ListEnumerator<StringObject>
' Constructors
	Method New(lst:IList<StringObject>)
		Super.New(lst)
	End

' Methods
	Method NextString:String()
		CheckConcurrency()
		lastIndex = index
		index += 1
		Return lst.Get(lastIndex).value
	End
	
	Method PreviousString:String()
		CheckConcurrency()
		index -= 1
		lastIndex = index
		Return lst.Get(lastIndex).value
	End
End

#Rem
	summary: ArrayList
	Concrete implementation of IList that uses a dynamically sized array to store elements.
	Has best performance when it is initialised with a capacity large enough to hold the expected number of elements.
#End
Class ArrayList<E> Extends IList<E>
Private
	' fields
	Field elements:Object[]
	Field size:Int = 0

	'summary: resizes the elements array if necessary to ensure it can fit minCapacity elements
	Method EnsureCapacity:Void(minCapacity:Int)
		Local oldCapacity:Int = elements.Length
		If minCapacity > oldCapacity Then
			Local newCapacity:Int = (oldCapacity * 3) / 2 + 1
			If newCapacity < minCapacity Then newCapacity = minCapacity
			elements = elements.Resize(newCapacity)
			modCount += 1
		End
	End
	
	Method RangeCheck:Void(index:Int)
		If index < 0 Or index >= size Then Throw New IndexOutOfBoundsException("ArrayList.RangeCheck: Index out of bounds: " + index + " is not 0<=index<" + size)
	End

	Field tempArr:Object[] = New Object[128] ' temp array used for internal call to ToArray (so we don't create an object)
	
Public
' Constructors
	Method New()
		Self.elements = New Object[10]
	End

	Method New(initialCapacity:Int)
		If initialCapacity < 0 Then Throw New IllegalArgumentException("ArrayList.New: Capacity must be >= 0")
		Self.elements = New Object[initialCapacity]
	End

	Method New(c:ICollection<E>)
		If Not c Then Throw New IllegalArgumentException("ArrayList.New: Source collection must not be null")
		elements = c.ToArray()
		size = elements.Length
	End

' Methods
	'summary: Overrides ICollection
	Method Add:Bool(o:E)
		If size+1 > elements.Length Then EnsureCapacity(size+1)
		elements[size] = o
		size+=1
		modCount += 1
		Return True
	End
	
	'summary: Overrides ICollection
	Method AddAll:Bool(c:ICollection<E>)
		If Not c Then Throw New IllegalArgumentException("ArrayList.AddAll: Source collection must not be null")
		If c.IsEmpty() Then Return False
		Local newItemCount:Int = c.Size
		If size + newItemCount > elements.Length Then EnsureCapacity(size+newItemCount)
		If tempArr.Length < newItemCount Then tempArr = tempArr.Resize(newItemCount)
		Local len:Int = c.FillArray(tempArr)
		For Local i:Int = 0 Until len
			elements[size] = tempArr[i]
			size+=1
		End
		modCount += 1
		Return newItemCount <> 0
	End
	
	'summary: Overrides ICollection
	Method Clear:Void()
		For Local i:Int = 0 Until size
			elements[i] = Null
		Next
		modCount += 1
		size = 0
	End
	
	'summary: Overrides ICollection
	Method Contains:Bool(o:E)
		For Local i:Int = 0 Until size
			If elements[i] = o Then Return True
		Next
		Return False
	End
	
	'summary: Overrides ICollection
	Method ContainsAll:Bool(c:ICollection<E>)
		If Not c Then Throw New IllegalArgumentException("ArrayList.ContainsAll: Source collection must not be null")
		If c.IsEmpty() Then Return True
		If tempArr.Length < c.Size Then tempArr = tempArr.Resize(c.Size)
		Local len:Int = c.FillArray(tempArr)
		For Local i:Int = 0 Until len
			If Not Self.Contains(E(tempArr[i])) Then Return False
		Next
		Return True
	End
	
	'summary: Overrides ICollection
	Method Enumerator:IEnumerator<E>()
		Return New ArrayListEnumerator<E>(Self)
	End
	
	'summary: Overrides ICollection
	Method FillArray:Int(arr:Object[])
		If arr.Length < size Then Throw New IllegalArgumentException("ArrayList.FillArray: Array length too small ("+arr.Length+"<"+size+")")
		For Local i:Int = 0 Until size
			arr[i] = elements[i]
		Next
		Return size
	End
	
	'summary: Overrides ICollection
	Method IsEmpty:Bool()
		Return size = 0
	End
	
	'summary: Overrides ICollection
	Method Remove:Bool(o:E)
		For Local i:Int = 0 Until size
			If elements[i] = o Then
				RemoveAt(i)
				modCount += 1
				Return True
			End
		Next
		Return False
	End
	
	'summary: Overrides ICollection
	Method RemoveAll:Bool(c:ICollection<E>)
		If Not c Then Throw New IllegalArgumentException("ArrayList.RemoveAll: Source collection must not be null")
		If c.IsEmpty() Then Return False
		Local modified:Bool = False
		If tempArr.Length < c.Size Then tempArr = tempArr.Resize(c.Size)
		Local len:Int = c.FillArray(tempArr)
		For Local i:Int = 0 Until len
			If Self.Contains(E(tempArr[i])) Then
				Self.Remove(E(tempArr[i]))
			End
		Next
		If modified Then modCount += 1
		Return modified
	End
	
	'summary: Overrides ICollection
	Method RetainAll:Bool(c:ICollection<E>)
		If Not c Then Throw New IllegalArgumentException("ArrayList.RetainAll: Source collection must not be null")
		Local modified:Bool = False
		If tempArr.Length < c.Size Then tempArr = tempArr.Resize(c.Size)
		Local len:Int = c.FillArray(tempArr)
		For Local i:Int = 0 Until len
			If Not Self.Contains(E(tempArr[i])) Then
				Self.Remove(E(tempArr[i]))
				modified = True
			End
		Next
		If modified Then modCount += 1
		Return modified
	End
	
	'summary: Overrides ICollection
	Method Size:Int() Property
		Return size
	End
	
	'summary: Overrides ICollection
	Method Sort:Void(reverse:Bool = False, comp:IComparator = Null)
		If size <= 1 Then Return ' can't sort 0 or 1 elements
		If comp = Null Then comp = Self.Comparator
		If comp = Null Then comp = DEFAULT_COMPARATOR
		QuickSort(elements, 0, size-1, comp, reverse)
		modCount += 1
	End
	
	'summary: Overrides ICollection
	Method ToArray:Object[]()
		Local arr:Object[] = New Object[size]
		For Local i:Int = 0 Until size
			arr[i] = elements[i]
		Next
		Return arr
	End
	
	'summary: Overrides IList
	Method AddLast:Bool(o:E)
		Return Add(o)
	End
	
	'summary: Overrides IList
	Method RemoveLast:E()
		Return RemoveAt(size-1)
	End
	
	'summary: Overrides IList
	Method GetLast:E()
		Return Get(size-1)
	End
	
	'summary: Overrides IList
	Method AddFirst:Bool(o:E)
		Insert(0, o)
		Return True
	End
	
	'summary: Overrides IList
	Method RemoveFirst:E()
		Return RemoveAt(0)
	End
	
	'summary: Overrides IList
	Method GetFirst:E()
		Return Get(0)
	End
	
	'summary: Overrides IList
	Method Get:E(index:Int)
		RangeCheck(index)
		Return E(elements[index])
	End
	
	'summary: Overrides IList
	Method Insert:Void(index:Int, o:E)
		If index <> size Then RangeCheck(index)
		If size+1 > elements.Length Then EnsureCapacity(size+1)
		For Local i:Int = size Until index Step -1
			elements[i] = elements[i-1]
		Next
		elements[index] = o
		size+=1
		modCount += 1
	End
	
	'summary: Overrides IList
	Method InsertAll:Bool(index:Int, c:ICollection<E>)
		Local newItemCount:Int = c.Size
		If newItemCount = 0 Then Return False
		If size + newItemCount > elements.Length Then EnsureCapacity(size+newItemCount)
		If tempArr.Length < newItemCount Then tempArr = tempArr.Resize(newItemCount)
		Local len:Int = c.FillArray(tempArr)
		For Local i:Int = size - 1 To index Step -1
			elements[i+newItemCount] = elements[i]
		Next
		For Local i:Int = 0 Until newItemCount
			elements[index+i] = tempArr[i]
		End
		size += newItemCount
		modCount += 1
		Return newItemCount <> 0
	End
	
	'summary: Overrides IList
	Method IndexOf:Int(o:E)
		For Local i:Int = 0 Until size
			If elements[i] = o Then Return i
		Next
		Return -1
	End
	
	'summary: Overrides IList
	Method LastIndexOf:Int(o:E)
		For Local i:Int = size-1 To 0 Step -1
			If elements[i] = o Then Return i
		Next
		Return -1
	End
	
	'summary: Overrides IList
	Method RemoveAt:E(index:Int)
		RangeCheck(index)
		Local oldValue:E = E(elements[index])
		For Local i:Int = index Until size-1
			elements[i] = elements[i+1]
		Next
		elements[size-1] = Null
		size-=1
		modCount += 1
		Return oldValue
	End

	'summary: Overrides IList
	Method RemoveRange:Void(fromIndex:Int, toIndex:Int)
		If fromIndex > toIndex Then Throw New IllegalArgumentException("ArrayList.RemoveRange: fromIndex ("+fromIndex+") must be <= toIndex ("+toIndex+")")
		RangeCheck(fromIndex)
		RangeCheck(toIndex)
		For Local i:Int = 0 Until toIndex - fromIndex
			RemoveAt(fromIndex)
		Next
	End
	
	'summary: Overrides IList
	Method Set:E(index:Int, o:E)
		RangeCheck(index)
		Local oldValue:E = E(elements[index])
		elements[index] = o
		modCount += 1
		Return oldValue
	End
End




'summary: ArrayList wrapper classes
Class IntArrayList Extends ArrayList<IntObject>
' Methods
	Method AddInt:Bool(o:Int)
		If size+1 > elements.Length Then EnsureCapacity(size+1)
		elements[size] = BoxInt(o)
		size+=1
		modCount += 1
		Return True
	End
	
	Method ContainsInt:Bool(o:Int)
		For Local i:Int = 0 Until size
			If UnboxInt(elements[i]) = o Then Return True
		Next
		Return False
	End
	
	'summary: Overrides ArrayList
	Method Enumerator:IEnumerator<IntObject>()
		Return New IntListEnumerator(Self)
	End
	
	Method RemoveInt:Bool(o:Int)
		For Local i:Int = 0 Until size
			If UnboxInt(elements[i]) = o Then
				RemoveAt(i)
				modCount += 1
				Return True
			End
		Next
		Return False
	End
	
	Method ToIntArray:Int[]()
		Local arr:Int[] = New Int[size]
		For Local i:Int = 0 Until size
			arr[i] = UnboxInt(elements[i])
		Next
		Return arr
	End
	
	Method GetInt:Int(index:Int)
		RangeCheck(index)
		Return UnboxInt(elements[index])
	End
	
	Method InsertInt:Void(index:Int, o:Int)
		RangeCheck(index)
		If size+1 > elements.Length Then EnsureCapacity(size+1)
		For Local i:Int = size Until index Step -1
			elements[i] = elements[i-1]
		Next
		elements[index] = BoxInt(o)
		size+=1
		modCount += 1
	End
	
	Method IndexOfInt:Int(o:Int)
		For Local i:Int = 0 Until size
			If UnboxInt(elements[i]) = o Then Return i
		Next
		Return -1
	End
	
	Method LastIndexOfInt:Int(o:E)
		For Local i:Int = size-1 To 0 Step -1
			If UnboxInt(elements[i]) = o Then Return i
		Next
		Return -1
	End

	Method SetInt:Int(index:Int, o:Int)
		RangeCheck(index)
		Local oldValue:Int = UnboxInt(elements[index])
		elements[index] = BoxInt(o)
		modCount += 1
		Return oldValue
	End

	Method FillIntArray:Int(arr:Int[])
		If arr.Length < size Then Throw New IllegalArgumentException("IntArrayList.FillIntArray: Array length too small ("+arr.Length+"<"+size+")")
		For Local i:Int = 0 Until size
			arr[i] = UnboxInt(elements[i])
		Next
		Return size
	End
End
	
Class FloatArrayList Extends ArrayList<FloatObject>
' Methods
	Method AddFloat:Bool(o:Float)
		If size + 1 > elements.Length Then EnsureCapacity(size + 1)
		elements[size] = BoxFloat(o)
		size += 1
		modCount += 1
		Return True
	End
	
	Method ContainsFloat:Bool(o:Float)
		For Local i:Int = 0 Until size
			If UnboxFloat(elements[i]) = o Then Return True
		Next
		Return False
	End
	
	'summary: Overrides ArrayList
	Method Enumerator:IEnumerator<FloatObject>()
		Return New FloatListEnumerator(Self)
	End
	
	Method RemoveFloat:Bool(o:Float)
		For Local i:Int = 0 Until size
			If UnboxFloat(elements[i]) = o Then
				RemoveAt(i)
				modCount += 1
				Return True
			End
		Next
		Return False
	End

	Method ToFloatArray:Float[]()
		Local arr:Float[] = New Float[size]
		For Local i:Int = 0 Until size
			arr[i] = UnboxFloat(elements[i])
		Next
		Return arr
	End
	
	Method GetFloat:Float(index:Int)
		RangeCheck(index)
		Return UnboxFloat(elements[index])
	End
	
	Method InsertFloat:Void(index:Int, o:Float)
		RangeCheck(index)
		If size+1 > elements.Length Then EnsureCapacity(size+1)
		For Local i:Int = size Until index Step -1
			elements[i] = elements[i-1]
		Next
		elements[index] = BoxFloat(o)
		size+=1
		modCount += 1
	End
	
	Method IndexOfFloat:Int(o:Float)
		For Local i:Int = 0 Until size
			If UnboxFloat(elements[i]) = o Then Return i
		Next
		Return -1
	End
	
	Method LastIndexOfFloat:Int(o:Float)
		For Local i:Int = size-1 To 0 Step -1
			If UnboxFloat(elements[i]) = o Then Return i
		Next
		Return -1
	End
  
	Method SetFloat:Float(index:Int, o:Float)
		RangeCheck(index)
		Local oldValue:Float = UnboxFloat(elements[index])
		elements[index] = BoxFloat(o)
		modCount += 1
		Return oldValue
	End
	
	Method FillFloatArray:Int(arr:Float[])
		If arr.Length < size Then Throw New IllegalArgumentException("FloatArrayList.FillFloatArray: Array length too small ("+arr.Length+"<"+size+")")
		For Local i:Int = 0 Until size
			arr[i] = UnboxFloat(elements[i])
		Next
		Return size
	End
End

Class StringArrayList Extends ArrayList<StringObject>
' Methods
	Method AddString:Bool(o:String)
		If size+1 > elements.Length Then EnsureCapacity(size+1)
		elements[size] = BoxString(o)
		size+=1
		modCount += 1
		Return True
	End
  
	Method ContainsString:Bool(o:String)
		For Local i:Int = 0 Until size
			If UnboxString(elements[i]) = o Then Return True
		Next
		Return False
	End

	'summary: Overrides ArrayList
	Method Enumerator:IEnumerator<StringObject>()
		Return New StringListEnumerator(Self)
	End
	
	Method RemoveString:Bool(o:String)
		For Local i:Int = 0 Until size
			If UnboxString(elements[i]) = o Then
				RemoveAt(i)
				modCount += 1
				Return True
			End
		Next
		Return False
	End

	Method ToStringArray:String[]()
		Local arr:String[] = New String[size]
		For Local i:Int = 0 Until size
			arr[i] = UnboxString(elements[i])
		Next
		Return arr
	End
	
	Method GetString:String(index:Int)
		RangeCheck(index)
		Return UnboxString(elements[index])
	End
	
	Method InsertString:Void(index:Int, o:String)
		RangeCheck(index)
		If size+1 > elements.Length Then EnsureCapacity(size+1)
		For Local i:Int = size Until index Step -1
			elements[i] = elements[i-1]
		Next
		elements[index] = BoxString(o)
		size+=1
		modCount += 1
	End
	
	Method IndexOfString:Int(o:String)
		For Local i:Int = 0 Until size
			If UnboxString(elements[i]) = o Then Return i
		Next
		Return -1
	End
	
	Method LastIndexOfString:Int(o:String)
		For Local i:Int = size-1 To 0 Step -1
			If UnboxString(elements[i]) = o Then Return i
		Next
		Return -1
	End
  
	Method SetString:String(index:Int, o:String)
		RangeCheck(index)
		Local oldValue:String = UnboxString(elements[index])
		elements[index] = BoxString(o)
		modCount += 1
		Return oldValue
	End

	Method FillStringArray:Int(arr:String[])
		If arr.Length < size Then Throw New IllegalArgumentException("StringArrayList.FillStringArray: Array length too small ("+arr.Length+"<"+size+")")
		For Local i:Int = 0 Until size
			arr[i] = UnboxString(elements[i])
		Next
		Return size
	End
End


'summary: SparseArray
Class SparseArray<E>
Private
	Field elements:Object[]
	Field indices:Int[]
	Field size:Int
	Field arraySize:Int
	Field defaultValue:E
	
	'summary: resizes the arrays if necessary to ensure they can fit minCapacity elements
	Method EnsureCapacity:Void(minCapacity:Int)
		Local oldCapacity:Int = elements.Length
		If minCapacity > oldCapacity Then
			Local newCapacity:Int = (oldCapacity * 3) / 2 + 1
			If newCapacity < minCapacity Then newCapacity = minCapacity
			elements = elements.Resize(newCapacity)
			indices = indices.Resize(newCapacity)
		End
	End
	
Public
	Method New(arraySize:Int=-1, defaultCapacity:Int=100, defaultValue:E=Null)
		If defaultCapacity < 0 Then Throw New IllegalArgumentException("SparseArray.New: Capacity must be >= 0")
		elements = New Object[defaultCapacity]
		indices = New Int[defaultCapacity]
		Self.arraySize = arraySize
		Self.defaultValue = defaultValue
	End
	
	Method Size:Int() Property
		Return size
	End
	
	Method ArraySize:Int() Property
		Return arraySize
	End
	
	Method ArraySize:Void(arraySize:Int) Property
		If arraySize < size Then Throw New IllegalArgumentException("SparseArray.ArraySize: The SparseArray contains more mappings than the requested size.")
		Self.arraySize = arraySize
	End
	
	Method DefaultValue:E() Property
		Return defaultValue
	End
	
	Method DefaultValue:Void(defaultValue:E) Property
		Self.defaultValue = defaultValue
	End
	
	Method Get:E(index:Int)
		If index < 0 Or arraySize >= 0 And index >= arraySize Then Throw New IndexOutOfBoundsException("SparseArray.Get: Array index out of bounds.")
		For Local i% = 0 Until size
			If indices[i] = index Then Return E(elements[i])
		Next
		Return defaultValue
	End
	
	Method Set:E(index:Int, value:E)
		If index < 0 Or arraySize >= 0 And index >= arraySize Then Throw New IndexOutOfBoundsException("SparseArray.Set: Array index out of bounds.")
		For Local i% = 0 Until size
			If indices[i] = index Then
				Local oldVal:Object = elements[i]
				elements[i] = value
				Return E(oldVal)
			End
		Next
		ResizeArrays()
		indices[size] = index
		elements[size] = value
		size += 1
		Return defaultValue
	End
	
	Method Clear:Int()
		For Local i% = 0 Until size
			elements[i] = Null
		Next
		Local oldSize:Int = size
		size = 0
		Return oldSize
	End
End

'summary: SparseIntArray
Class SparseIntArray
Private
	Field elements:Int[]
	Field indices:Int[]
	Field size:Int
	Field arraySize:Int
	Field defaultValue:Int
	
	' resizes the arrays if necessary to ensure they can fit minCapacity elements
	Method EnsureCapacity:Void(minCapacity:Int)
		Local oldCapacity:Int = elements.Length
		If minCapacity > oldCapacity Then
			Local newCapacity:Int = (oldCapacity * 3) / 2 + 1
			If newCapacity < minCapacity Then newCapacity = minCapacity
			elements = elements.Resize(newCapacity)
			indices = indices.Resize(newCapacity)
		End
	End
	
Public
	Method New(arraySize:Int=-1, defaultCapacity:Int=100, defaultValue:Int=0)
		If defaultCapacity < 0 Then Throw New IllegalArgumentException("SparseIntArray.New: Capacity must be >= 0")
		elements = New Int[defaultCapacity]
		indices = New Int[defaultCapacity]
		Self.arraySize = arraySize
		Self.defaultValue = defaultValue
	End
	
	Method Size:Int() Property
		Return size
	End
	
	Method ArraySize:Int() Property
		Return arraySize
	End
	
	Method ArraySize:Void(arraySize:Int) Property
		If arraySize < size Then Throw New IllegalArgumentException("SparseIntArray.ArraySize: The SparseIntArray contains more mappings than the requested size.")
		Self.arraySize = arraySize
	End
	
	Method DefaultValue:Int() Property
		Return defaultValue
	End
	
	Method DefaultValue:Void(defaultValue:Int) Property
		Self.defaultValue = defaultValue
	End
	
	Method Get:Int(index:Int)
		If index < 0 Or arraySize >= 0 And index >= arraySize Then Throw New IndexOutOfBoundsException("SparseIntArray.Get: Array index out of bounds.")
		For Local i% = 0 Until size
			If indices[i] = index Then Return elements[i]
		Next
		Return defaultValue
	End
	
	Method Set:Int(index:Int, value:Int)
		If index < 0 Or arraySize >= 0 And index >= arraySize Then Throw New IndexOutOfBoundsException("SparseIntArray.Set: Array index out of bounds.")
		For Local i% = 0 Until size
			If indices[i] = index Then
				Local oldVal:Int = elements[i]
				elements[i] = value
				Return oldVal
			End
		Next
		EnsureCapacity(size+1)
		indices[size] = index
		elements[size] = value
		size += 1
		Return defaultValue
	End
	
	Method Clear:Int()
		For Local i% = 0 Until size
			elements[i] = 0
		Next
		Local oldSize:Int = size
		size = 0
		Return oldSize
	End
End

'summary: SparseStringArray
Class SparseStringArray
Private
	Field elements:String[]
	Field indices:Int[]
	Field size:Int
	Field arraySize:Int
	Field defaultValue:String
	
	'summary: resizes the arrays if necessary to ensure they can fit minCapacity elements
	Method EnsureCapacity:Void(minCapacity:Int)
		Local oldCapacity:Int = elements.Length
		If minCapacity > oldCapacity Then
			Local newCapacity:Int = (oldCapacity * 3) / 2 + 1
			If newCapacity < minCapacity Then newCapacity = minCapacity
			elements = elements.Resize(newCapacity)
			indices = indices.Resize(newCapacity)
		End
	End
	
Public
	Method New(arraySize:Int=-1, defaultCapacity:Int=100, defaultValue:String="")
		If defaultCapacity < 0 Then Throw New IllegalArgumentException("SparseStringArray.New: Capacity must be >= 0")
		elements = New String[defaultCapacity]
		indices = New Int[defaultCapacity]
		Self.arraySize = arraySize
		Self.defaultValue = defaultValue
	End
	
	Method Size:Int() Property
		Return size
	End
	
	Method ArraySize:Int() Property
		Return arraySize
	End
	
	Method ArraySize:Void(arraySize:Int) Property
		If arraySize < size Then Throw New IllegalArgumentException("SparseStringArray.ArraySize: The SparseStringArray contains more mappings than the requested size.")
		Self.arraySize = arraySize
	End
	
	Method DefaultValue:String() Property
		Return defaultValue
	End
	
	Method DefaultValue:Void(defaultValue:String) Property
		Self.defaultValue = defaultValue
	End
	
	Method Get:String(index:Int)
		If index < 0 Or arraySize >= 0 And index >= arraySize Then Throw New IndexOutOfBoundsException("SparseStringArray.Get: Array index out of bounds.")
		For Local i% = 0 Until size
			If indices[i] = index Then Return elements[i]
		Next
		Return defaultValue
	End
	
	Method Set:String(index:Int, value:String)
		If index < 0 Or arraySize >= 0 And index >= arraySize Then Throw New IndexOutOfBoundsException("SparseStringArray.Set: Array index out of bounds.")
		For Local i% = 0 Until size
			If indices[i] = index Then
				Local oldVal:String = elements[i]
				elements[i] = value
				Return oldVal
			End
		Next
		EnsureCapacity(size+1)
		indices[size] = index
		elements[size] = value
		size += 1
		Return defaultValue
	End
	
	Method Clear:Int()
		For Local i% = 0 Until size
			elements[i] = ""
		Next
		Local oldSize:Int = size
		size = 0
		Return oldSize
	End
End

'summary: SparseFloatArray
Class SparseFloatArray
Private
	Field elements:Float[]
	Field indices:Int[]
	Field size:Int
	Field arraySize:Int
	Field defaultValue:Float
	
	' resizes the arrays if necessary to ensure they can fit minCapacity elements
	Method EnsureCapacity:Void(minCapacity:Int)
		Local oldCapacity:Int = elements.Length
		If minCapacity > oldCapacity Then
			Local newCapacity:Int = (oldCapacity * 3) / 2 + 1
			If newCapacity < minCapacity Then newCapacity = minCapacity
			elements = elements.Resize(newCapacity)
			indices = indices.Resize(newCapacity)
		End
	End
	
Public
	Method New(arraySize:Int=-1, defaultCapacity:Int=100, defaultValue:Float=0)
		If defaultCapacity < 0 Then Throw New IllegalArgumentException("SparseFloatArray.New: Capacity must be >= 0")
		elements = New Float[defaultCapacity]
		indices = New Int[defaultCapacity]
		Self.arraySize = arraySize
		Self.defaultValue = defaultValue
	End
	
	Method Size:Int() Property
		Return size
	End
	
	Method ArraySize:Int() Property
		Return arraySize
	End
	
	Method ArraySize:Void(arraySize:Int) Property
		If arraySize < size Then Throw New IllegalArgumentException("SparseFloatArray.ArraySize: The SparseFloatArray contains more mappings than the requested size.")
		Self.arraySize = arraySize
	End
	
	Method DefaultValue:Float() Property
		Return defaultValue
	End
	
	Method DefaultValue:Void(defaultValue:Float) Property
		Self.defaultValue = defaultValue
	End
	
	Method Get:Float(index:Int)
		If index < 0 Or arraySize >= 0 And index >= arraySize Then Throw New IndexOutOfBoundsException("SparseFloatArray.Get: Array index out of bounds.")
		For Local i% = 0 Until size
			If indices[i] = index Then Return elements[i]
		Next
		Return defaultValue
	End
	
	Method Set:Float(index:Int, value:Float)
		If index < 0 Or arraySize >= 0 And index >= arraySize Then Throw New IndexOutOfBoundsException("SparseFloatArray.Set: Array index out of bounds.")
		For Local i% = 0 Until size
			If indices[i] = index Then
				Local oldVal:Float = elements[i]
				elements[i] = value
				Return oldVal
			End
		Next
		EnsureCapacity(size+1)
		indices[size] = index
		elements[size] = value
		size += 1
		Return defaultValue
	End
	
	Method Clear:Int()
		For Local i% = 0 Until size
			elements[i] = 0
		Next
		Local oldSize:Int = size
		size = 0
		Return oldSize
	End
End

'summary: See the commented code for an example of what your class should look like.
' Poolable objects need to retain a field that indicates whether or not they are active.  Since
' IArrayPoolable is an interface, it cannot provide that field automatically.  You must create the field
' yourself and implement the properties to access it.
Interface IArrayPoolable
'	Field activeInPool:Bool = False

	Method ActiveInPool:Bool() Property
'		Return activeInPool
'	End

	Method ActiveInPool:Void(activeInPool:Bool) Property
'		Self.activeInPool = activeInPool
'	End

	Method InitFromPool:Void(arg:Object = Null)
'		' This is like the constructor, it gets called when you call GetObject(arg)
'	End

	Method PurgedFromPool:Void()
'		' This is like the destructor, it gets called when the object is purged.
'	End
End

'summary: A pool will instantiate "capacity" number of "T" objects, then make those available to the GetObject() method.
' The type of these objects can NEVER change, so don't try to downcast it.  The point of pooling is to reduce the need for runtime
' object instantiation.
' To use the pool, instantiate it with your object type and the maximum number of objects in the pool.  The default constructor for
' your type will be used to fill the pool.  Your object must implement the IArrayPoolable interface.
' To retrieve an object from the pool, use the GetObject() method.  To release it, simply set the ActiveInPool property on your
' object to false, and it will be released on the next purge.  Automatic purges happen in two cases; before an EachIn, and before
' a Sort().  If you purge the pool during an EachIn, it will throw a ConcurrentModificationException to prevent you from looping on
' objects twice.  It is still possible to retrieve free objects during an EachIn, as the modifications to the pool will occur after the
' snapshot count, and will not affect the loop.
' When looping, it is still a good idea to check the active state of the object, in case you have released it at some point in your
' code.
' Note that if the pool is full, a call to GetObject() will return Null.
Class ArrayPool<T> ' <T implements IArrayPoolable>
Private
	Field comparator:IComparator = Null
	Field objects:Object[] ' we use Object[] instead of T[] so that we can pass it into QuickSort()
	Field activeCount:Int = 0
	Field capacity:Int
	Field modCount:Int = 0
	
	Method InitPool:Void(capacity:Int)
		If capacity <= 0 Then Throw New IllegalArgumentException("ArrayPool.InitPool: Capacity must be > 0")
		Self.capacity = capacity
		objects = New Object[capacity]
		For Local i:Int = 0 Until capacity
			objects[i] = New T
			If i = 0 And Not IArrayPoolable(objects[i]) Then Throw New IllegalArgumentException("ArrayPool.InitPool: Pool generic parameter must implement IArrayPoolable!")
		Next
	End
	
Public
	'summary: Property to read comparator
	Method Comparator:IComparator() Property
		Return comparator
	End
	
	'summary: Property to write comparator
	Method Comparator:Void(comparator:IComparator) Property
		Self.comparator = comparator
	End
	
	'summary: Property to read capacity (read only)
	Method Capacity:Int() Property
		Return capacity
	End
	
	'summary: Property to read active count (read only)
	Method ActiveCount:Int() Property
		Return activeCount
	End
	
	'summary: Constructor that initialises to a capacity
	Method New(capacity:Int = 100)
		InitPool(capacity)
	End
	
	'summary: Retrieves the next free pooled object, optionally passing the arg to InitFromPool.
	'This is a good way to use template objects (copy fields manually).
	Method GetObject:T(arg:Object = Null)
		If activeCount >= capacity Then Return Null
		Local rv:T = T(objects[activeCount])
		activeCount += 1
		IArrayPoolable(rv).ActiveInPool = True
		IArrayPoolable(rv).InitFromPool(arg)
		Return rv
	End
	
	'summary: Shuffles object references so that they are contiguous (optimisation), and updates the active count.
	Method Purge:Void()
		Local current:Int = 0
		While current < activeCount
			' if the low index is active
			If IArrayPoolable(objects[current]).ActiveInPool Then
				' move to the next index
				current += 1
			Else
				' else, reduce the active count until we find one to swap with
				While current < activeCount And Not IArrayPoolable(objects[activeCount-1]).ActiveInPool
					modCount += 1
					activeCount -= 1
					IArrayPoolable(objects[activeCount]).PurgedFromPool()
				End
				' if we have an active to swap, do it
				If current < activeCount Then
					modCount += 1
					Local oldObject:Object = objects[current]
					objects[current] = objects[activeCount-1]
					objects[activeCount-1] = oldObject
					IArrayPoolable(oldObject).PurgedFromPool()
					activeCount -= 1
				End
			End
		End
	End
	
	'summary: Resets all objects (the Purge() call will ensure that PurgedFromPool() is called for each).
	Method Clear:Void()
		For Local i% = 0 Until activeCount
			IArrayPoolable(objects[i]).ActiveInPool = False
		Next
		Purge()
	End
	
	'summary: Returns a Monkey-style enumerator for EachIn.
	Method ObjectEnumerator:ArrayPoolEnumerator<T>()
		Return New ArrayPoolEnumerator<T>(Self)
	End
	
	'summary: Performs a quicksort on the pool, doing a purge first.
	'Due to the way purging works, the pool will most likely become unsorted when items are purged.
	Method Sort:Void(reverse:Bool = False, comp:IComparator = Null)
		Purge()
		If activeCount <= 1 Then Return ' can't sort 0 or 1 elements
		If comp = Null Then comp = Self.Comparator
		If comp = Null Then comp = DEFAULT_COMPARATOR
		QuickSort(objects, 0, activeCount-1, comp, reverse)
		modCount += 1
	End
End

'summary: Monkey-style enumerator class for EachIn
'When you call EachIn, the pool is purged.  If you wish to loop on a sorted pool, call Sort() first (which also purges).
Class ArrayPoolEnumerator<T>
Private
	Field pool:ArrayPool<T>
	Field snapshotActiveCount:Int
	Field currentIndex:Int
	Field modCount:Int
	
	Method New(pool:ArrayPool<T>)
		Self.pool = pool
		Reset()
	End
	
	Method CheckConcurrency:Void()
		If modCount <> pool.modCount Then Throw New ConcurrentModificationException("ArrayPoolEnumerator.CheckConcurrency: Concurrent pool modification.")
	End
	
Public
	Method Reset:Void()
		pool.Purge()
		Self.currentIndex = 0
		Self.modCount = pool.modCount
		Self.snapshotActiveCount = pool.activeCount
	End
	
	Method HasNext:Bool()
		CheckConcurrency()
		Return currentIndex < snapshotActiveCount
	End

	Method NextObject:T()
		CheckConcurrency()
		If Not HasNext() Then Throw New IndexOutOfBoundsException("ArrayPoolEnumerator.NextObject: Couldn't get next object, index "+currentIndex+" >= "+snapshotActiveCount)
		currentIndex += 1
		Return T(pool.objects[currentIndex-1])
	End
End
