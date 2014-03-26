Strict
Public
Alias MapValueEnumerator = monkey.map.ValueEnumerator
Alias MapKeyEnumerator = monkey.map.KeyEnumerator
Alias StackEnumerator = monkey.stack.Enumerator
Alias ListEnumerator = monkey.list.Enumerator

Import diddystack
Import diddyset
Import diddylist

' IComparable can't be generic because it's likely the developer will want to do a cyclic declaration
Interface IComparable
	Method CompareTo:Int(other:Object)
End

Interface IComparator<T>
	Method Compare:Int(lhs:T, rhs:T)
End

Interface IEnumerator<T>
	Method HasNext:Bool()
	Method NextObject:T()
End

Interface IEnumerable<T>
	Method ObjectEnumerator:IEnumerator<T>()
End

Interface IPredicate<T>
	Method Evaluate:Bool(arg:T)
End

Interface IPoolable
	Method Reset:Void()
End

Interface IContainer<T>
	' custom properties
	Method Comparator:IComparator<T>() Property ' unsupported in Set
	Method Comparator:Void(comparator:IComparator<T>) Property ' unsupported in Set

	' custom methods
	Method AddAll:Void(src:Stack<T>)
	Method AddAll:Void(src:List<T>)
	Method AddAll:Void(src:Set<T>)
	Method AddContainer:Void(src:IContainer<T>)
	
	Method RemoveAll:Void(src:Stack<T>)
	Method RemoveAll:Void(src:List<T>)
	Method RemoveAll:Void(src:Set<T>)
	Method RemoveContainer:Void(src:IContainer<T>)
	
	Method RetainAll:Void(src:Stack<T>)
	Method RetainAll:Void(src:List<T>)
	Method RetainAll:Void(src:Set<T>)
	Method RetainContainer:Void(src:IContainer<T>)
	
	Method ContainsAll:Bool(src:Stack<T>)
	Method ContainsAll:Bool(src:List<T>)
	Method ContainsAll:Bool(src:Set<T>)
	Method ContainsContainer:Bool(src:IContainer<T>)
	
	Method AddItem:Void(val:T)
	Method RemoveItem:Void(val:T)
	Method InsertItem:Void(index:Int, val:T) ' unsupported in Set
	Method DeleteItem:T(index:Int) ' unsupported in Set
	Method ClearAll:Void()
	Method ContainsItem:Bool(val:T)
	Method GetItem:T(index:Int) ' unsupported in Set
	Method SetItem:Void(index:Int, value:T) ' unsupported in Set
	Method FindItem:Int(value:T) ' unsupported in Set
	Method SortItems:Void(ascending:Bool = True) ' unsupported in Set
	
	Method Reverse:Void() ' unsupported in Set
	Method Shuffle:Void() ' unsupported in Set
	Method Items:IEnumerable<T>(pred:IPredicate<T>=Null)
	Method SwapItems:Void(index1:Int, index2:Int) ' unsupported in Set
	Method Truncate:Void(size:Int) ' unsupported in Set
	
	' overridden or implemented methods
	Method Count:Int()
	Method ToArray:T[]() ' undefined order in Set
	Method FillArray:Int(arr:T[]) ' undefined order in Set
	Method Compare:Int(lhs:T, rhs:T) ' unsupported in Set
	Method Equals:Bool(lhs:T, rhs:T)
	Method IsEmpty:Bool() ' implemented as a property in Stack
End

' hack to get around Monkey's inability to cast primitives to objects
Class IComparableWrapper
	Function IsComparable:Bool(src:Object)
		Return IComparable(src) <> Null
	End
	
	Function IsComparable:Bool(src:Int)
		Return False
	End
	
	Function IsComparable:Bool(src:Float)
		Return False
	End
	
	Function IsComparable:Bool(src:String)
		Return False
	End
	
	Function Compare:Int(lhs:Object, rhs:Object)
		' we check both lhs and rhs because we always want to compare if at least one value is non-null
		If IComparable(lhs) Then
			' normal comparison if lhs is not null
			Return IComparable(lhs).CompareTo(rhs)
		ElseIf IComparable(rhs) Then
			' reverse comparison if lhs is null but rhs is not
			Return -IComparable(rhs).CompareTo(lhs)
		End
		Return 0
	End
	
	Function Compare:Int(lhs:Int, rhs:Int)
		Return 0
	End
	
	Function Compare:Int(lhs:Float, rhs:Float)
		Return 0
	End
	
	Function Compare:Int(lhs:String, rhs:String)
		Return 0
	End
End

' utility classes
Class PredicateEnumerator<T> Implements IEnumerator<T> Abstract
	Global NIL:T

	Field pred:IPredicate<T>
	Field atEnd:Bool = False
	Field peeked:Bool = False
	Field nextVal:T = NIL
	Field nextValSet:Bool = False
	
	Method New(pred:IPredicate<T>=Null)
		Self.pred = pred
	End
	
	Method HasNext:Bool()
		If Not pred Then Return CallHasNext()
		If atEnd Then Return False
		If nextValSet Then Return True
		peeked = True
		While CallHasNext()
			Local n:T = CallNextObject()
			If pred.Evaluate(n) Then
				nextVal = n
				nextValSet = True
				Return True
			End
		End
		atEnd = True
		Return False
	End
	
	Method NextObject:T()
		If Not pred Then Return CallNextObject()
		If Not nextValSet And Not HasNext() Then Return NIL
		Local result:T = nextVal
		nextVal = NIL
		nextValSet = False
		peeked = False
		Return result
	End
	
	Method CallHasNext:Bool() Abstract
	Method CallNextObject:T() Abstract
End

Class WrappedMapValueEnumerator<T> Extends PredicateEnumerator<T>
	Field en:MapValueEnumerator<String,T>
	
	Method New(en:MapValueEnumerator<String,T>, pred:IPredicate<T>=Null)
		Super.New(pred)
		Self.en = en
	End
	
	Method CallNextObject:T()
		Return en.NextObject()
	End
	
	Method CallHasNext:Bool()
		Return en.HasNext()
	End
End

Class WrappedMapValueEnumerable<K,V> Implements IEnumerable<V>
	Field m:Map<K,V>
	Field pred:IPredicate<T>
	
	Method New(m:Map<K,V>, pred:IPredicate<T>=Null)
		Self.m = m
		Self.pred = pred
	End
	
	Method ObjectEnumerator:IEnumerator<V>()
		Return New WrappedMapValueEnumerator<V>(m.ObjectEnumerator(), pred)
	End
End

Class WrappedStackEnumerator<T> Extends PredicateEnumerator<T>
	Field en:StackEnumerator<T>
	
	Method New(en:StackEnumerator<T>, pred:IPredicate<T>=Null)
		Super.New(pred)
		Self.en = en
	End
	
	Method CallNextObject:T()
		Return en.NextObject()
	End
	
	Method CallHasNext:Bool()
		Return en.HasNext()
	End
End

Class WrappedStackEnumerable<T> Implements IEnumerable<T>
	Field s:Stack<T>
	Field pred:IPredicate<T>
	
	Method New(s:Stack<T>, pred:IPredicate<T>=Null)
		Self.s = s
		Self.pred = pred
	End
	
	Method ObjectEnumerator:IEnumerator<T>()
		Return New WrappedStackEnumerator<T>(s.ObjectEnumerator(), pred)
	End
End

Class WrappedListEnumerator<T> Extends PredicateEnumerator<T>
	Field en:ListEnumerator<T>
	
	Method New(en:ListEnumerator<T>, pred:IPredicate<T>=Null)
		Super.New(pred)
		Self.en = en
	End
	
	Method CallNextObject:T()
		Return en.NextObject()
	End
	
	Method CallHasNext:Bool()
		Return en.HasNext()
	End
End

Class WrappedListEnumerable<T> Implements IEnumerable<T>
	Field l:List<T>
	Field pred:IPredicate<T>
	
	Method New(l:List<T>, pred:IPredicate<T>=Null)
		Self.l = l
		Self.pred = pred
	End
	
	Method ObjectEnumerator:IEnumerator<T>()
		Return New WrappedListEnumerator<T>(l.ObjectEnumerator(), pred)
	End
End

Class WrappedSetEnumerator<T> Extends PredicateEnumerator<T>
	Field en:MapKeyEnumerator<T,Object>
	
	Method New(en:MapKeyEnumerator<T,Object>, pred:IPredicate<T>=Null)
		Super.New(pred)
		Self.en = en
	End
	
	Method CallNextObject:T()
		Return en.NextObject()
	End
	
	Method CallHasNext:Bool()
		Return en.HasNext()
	End
End

Class WrappedSetEnumerable<T> Implements IEnumerable<T>
	Field s:Set<T>
	Field pred:IPredicate<T>
	
	Method New(s:Set<T>, pred:IPredicate<T>)
		Self.s = s
		Self.pred = pred
	End
	
	Method ObjectEnumerator:IEnumerator<T>()
		Return New WrappedSetEnumerator<T>(s.ObjectEnumerator(), pred)
	End
End
