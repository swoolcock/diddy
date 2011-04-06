Strict

Import collection

#rem
	AbstractList
	Extends AbstractCollection to implement some of the abstract methods that apply to any kind of list.
#End
Class AbstractList<E> Extends AbstractCollection<E> Abstract
Private
	' If true, bounds checking should be performed.
	Field rangeChecking:Bool = True
	
	' A counter for modifications to the list.  Used for concurrency checks.
	Field modCount:Int = 0
	
	' Performs a range check.
	Method RangeCheck:Void(index:Int)
		Local size:Int = Self.Size()
		If index < 0 Or index >= size Then Error("Index out of bounds: Index: " + index + ", Size: " + size)
	End
	
Public
	' Property to read rangeChecking
	Method RangeChecking:Bool() Property
		Return rangeChecking
	End
	' Property to write rangeChecking
	Method RangeChecking:Void(rangeChecking:Bool) Property
		Self.rangeChecking = rangeChecking
	End
	
	Method ObjectEnumerator:AbstractEnumerator<E>()
		Return New ListEnumerator<E>(Self)
	End
	
	Method Get:E(index:Int) Abstract
	Method Insert:Void(index:Int, o:E) Abstract
	Method InsertAll:Bool(index:Int, c:AbstractCollection<E>) Abstract
	Method IndexOf:Int(o:E) Abstract
	Method LastIndexOf:Int(o:E) Abstract
	Method RemoveAt:E(index:Int) Abstract ' can't overload Remove since it's an inherited method
	Method RemoveRange:Void(fromIndex:Int, toIndex:Int) Abstract
	Method Set:E(index:Int, o:E) Abstract
End



#Rem
	ListEnumerator
	Extends AbstractEnumerator to provide support for EachIn.  Blocks concurrent modification, but allows elements to be removed on the fly.
#End
Class ListEnumerator<E> Extends AbstractEnumerator<E>
Private
	Field lst:AbstractList<E>
	Field lastIndex:Int = 0
	Field index:Int = 0
	Field expectedModCount:Int = 0
Public
	Method New(lst:AbstractList<E>)
		Self.lst = lst
		expectedModCount = lst.modCount
	End
	
	Method HasNext:Bool()
		If lst.modCount <> expectedModCount Then Error("Concurrent list modification")
		Return index < lst.Size
	End
	
	Method HasPrevious:Bool()
		If lst.modCount <> expectedModCount Then Error("Concurrent list modification")
		Return index > 0
	End
	
	Method NextObject:E()
		If lst.modCount <> expectedModCount Then Error("Concurrent list modification")
		lastIndex = index		
		index += 1		
		Return lst.Get(lastIndex)
	End
	
	Method PreviousObject:E()
		If lst.modCount <> expectedModCount Then Error("Concurrent list modification")
		index -= 1
		lastIndex = index
		Return lst.Get(lastIndex)
	End
	
	Method Remove:Void()
		If lst.modCount <> expectedModCount Then Error("Concurrent list modification")
		lst.RemoveAt(lastIndex)
		If lastIndex < index Then index -= 1
		lastIndex = -1
		expectedModCount = lst.modCount
	End
	
	Method First:Void()
		If lst.modCount <> expectedModCount Then Error("Concurrent list modification")
		index = 0
	End
	
	Method Last:Void()
		If lst.modCount <> expectedModCount Then Error("Concurrent list modification")
		index = lst.Size
	End
End



#rem
	ArrayList
	Concrete implementation of AbstractList that uses a dynamically sized array to store elements.
#End
Class ArrayList<E> Extends AbstractList<E>
Private
	' fields
	Field elements:Object[]
	Field size:Int = 0

	' resizes the elements array If necessary To ensure it can fit minCapacity elements
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
		If index >= size Or index < 0 Then Error("Index out of bounds: Index: "+index+", Size: "+size)
	End

	Field tempArr:Object[] = New Object[128] ' temp array used for internal call to ToArray
	
Public
	' constructors
	Method New()
		Self.elements = New Object[10]
	End

	Method New(initialCapacity:Int)
		If initialCapacity < 0 Then Error("Illegal Capacity: "+initialCapacity)
		Self.elements = New Object[initialCapacity]
	End

	Method New(c:AbstractCollection<E>)
		elements = c.ToArray()
		size = elements.Length
	End

	'implements AbstractCollection
	
	Method Add:Bool(o:E)
		If size+1 > elements.Length Then EnsureCapacity(size+1)
		elements[size] = o
		size+=1
		modCount += 1
		Return True
	End
	
	Method AddAll:Bool(c:AbstractCollection<E>)
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
	
	Method Clear:Void()
		For Local i:Int = 0 Until size
			elements[i] = Null
		Next
		modCount += 1
		size = 0
	End
	
	Method Contains:Bool(o:E)
		For Local i:Int = 0 Until size
			If elements[i] = o Then Return True
		Next
		Return False
	End
	
	Method ContainsAll:Bool(c:AbstractCollection<E>)
		If tempArr.Length < c.Size Then tempArr = tempArr.Resize(c.Size)
		Local len:Int = c.FillArray(tempArr)
		For Local i:Int = 0 Until len
			If Not Self.Contains(E(tempArr[i])) Then Return False
		Next
		Return True
	End
	
	'Method Equals:Bool(c:AbstractCollection<E>)
	'	Return c.Size = size And Self.ContainsAll(c)
	'End
	
	Method FillArray:Int(arr:Object[])
		If arr.Length < size Then Error("Array too small")
		For Local i:Int = 0 Until size
			arr[i] = elements[i]
		Next
		Return size
	End
	
	Method IsEmpty:Bool()
		Return size = 0
	End
	
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
	
	Method RemoveAll:Bool(c:AbstractCollection<E>)
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
	
	Method RetainAll:Bool(c:AbstractCollection<E>)
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
	
	Method Size:Int() Property
		Return size
	End
	
	Method Sort:Void(comp:AbstractComparator<E> = Null, reverse:Bool = False)
		If comp = Null Then comp = Self.Comparator
		' TODO: sort arraylist
	End
	
	Method ToArray:Object[]()
		Local arr:Object[] = New Object[size]
		For Local i:Int = 0 Until size
			arr[i] = elements[i]
		Next
		Return arr
	End
	
	' implements AbstractList
	
	Method Get:E(index:Int)
		If rangeChecking Then RangeCheck(index)
		Return E(elements[index])
	End
	
	Method Insert:Void(index:Int, o:E)
		If rangeChecking Then RangeCheck(index)
		If size+1 > elements.Length Then EnsureCapacity(size+1)
		For Local i:Int = size Until index Step -1
			elements[i] = elements[i-1]
		Next
		elements[index] = o
		size+=1
		modCount += 1
	End
	
	Method InsertAll:Bool(index:Int, c:AbstractCollection<E>)
		Local newItemCount:Int = c.Size
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
	
	Method IndexOf:Int(o:E)
		For Local i:Int = 0 Until size
			If elements[i] = o Then Return i
		Next
		Return -1
	End
	
	Method LastIndexOf:Int(o:E)
		For Local i:Int = size-1 To 0 Step -1
			If elements[i] = o Then Return i
		Next
		Return -1
	End
	
	Method RemoveAt:E(index:Int)
		If rangeChecking Then RangeCheck(index)
		Local oldValue:E = E(elements[index])
		For Local i:Int = index Until size-1
			elements[i] = elements[i+1]
		Next
		elements[size-1] = Null
		size-=1
		modCount += 1
		Return oldValue
	End

	Method RemoveRange:Void(fromIndex:Int, toIndex:Int)
		If fromIndex > toIndex Then Error("fromIndex > toIndex")
		If rangeChecking Then
			RangeCheck(fromIndex)
			RangeCheck(toIndex)
		End
		For Local i:Int = 0 Until toIndex - fromIndex
			RemoveAt(fromIndex)
		Next
	End
	
	Method Set:E(index:Int, o:E)
		If rangeChecking Then RangeCheck(index)
		Local oldValue:E = E(elements[index])
		elements[index] = o
		modCount += 1
		Return oldValue
	End
End



' TODO: complete wrapper classes
Class IntArrayList Extends ArrayList<IntObject>
Public
	Method ToIntArray:Int[]()
		Local arr:Int[] = New Int[size]
		For Local i:Int = 0 Until size
			arr[i] = IntObject(elements[i]).value
		Next
		Return arr
	End
	
	Method AddInt:Bool(val:Int)
		If size + 1 > elements.Length Then EnsureCapacity(size + 1)
		elements[size] = New IntObject(val)
		size += 1
		modCount += 1
		Return True
	End
	
	Method GetInt:Int(index:Int)
		If rangeChecking Then RangeCheck(index)
		Return IntObject(elements[index]).value
	End
	
	Method RemoveInt:Bool(value:Int)
		For Local i:Int = 0 Until size
			If IntObject(elements[i]).value = value Then
				Remove(elements[i])
				modCount += 1
				Return True
			End
		Next
		Return False
	End
End

Class FloatArrayList Extends ArrayList<FloatObject>
Public
	Method ToFloatArray:Float[]()
		Local arr:Float[] = New Float[size]
		For Local i:Float = 0 Until size
			arr[i] = FloatObject(elements[i]).value
		Next
		Return arr
	End
	
	Method AddFloat:Bool(val:Float)
		If size+1 > elements.Length Then EnsureCapacity(size+1)
		elements[size] = New FloatObject(val)
		size+=1
		modCount += 1
		Return True
	End
	
	Method GetFloat:Float(index:Int)
		If rangeChecking Then RangeCheck(index)
		Return FloatObject(elements[index]).value
	End
	
	Method RemoveFloat:Bool(value:Float)
		For Local i:Int = 0 Until size
			If FloatObject(elements[i]).value = value Then
				Remove(elements[i])
				modCount += 1
				Return True
			End
		Next
		Return False
	End
End

Class StringArrayList Extends ArrayList<StringObject>
Public
	Method ToStringArray:String[]()
		Local arr:String[] = New String[size]
		For Local i:Int = 0 Until size
			arr[i] = StringObject(elements[i]).value
		Next
		Return arr
	End
	
	Method AddString:Bool(val:String)
		If size+1 > elements.Length Then EnsureCapacity(size+1)
		elements[size] = New StringObject(val)
		size+=1
		modCount += 1
		Return True
	End
	
	Method GetString:String(index:Int)
		If rangeChecking Then RangeCheck(index)
		Return StringObject(elements[index]).value
	End
	
	Method RemoveString:Bool(value:String)
		If rangeChecking Then RangeCheck(index)
		For Local i:Int = 0 Until size
			If StringObject(elements[i]).value = value Then
				Remove(elements[i])
				modCount += 1
				Return True
			End
		Next
		Return False
	End
End



