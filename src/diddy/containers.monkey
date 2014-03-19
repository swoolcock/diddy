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
	
	' overridden or implemented methods
	Method Count:Int()
	Method ToArray:T[]() ' undefined order in Set
	Method FillArray:Int(arr:T[]) ' undefined order in Set
	Method Compare:Int(lhs:T, rhs:T) ' unsupported in Set
	Method Equals:Bool(lhs:T, rhs:T) ' unsupported in Set
	Method IsEmpty:Bool() ' implemented as a property in Stack
	Method Items:IEnumerable<T>() Property
End

' utility classes
Class WrappedMapValueEnumerator<T> Implements IEnumerator<T>
	Field en:MapValueEnumerator<String,T>
	
	Method New(en:MapValueEnumerator<String,T>)
		Self.en = en
	End
	
	Method NextObject:T()
		Return en.NextObject()
	End
	
	Method HasNext:Bool()
		Return en.HasNext()
	End
End

Class WrappedMapValueEnumerable<K,V> Implements IEnumerable<V>
	Field m:Map<K,V>
	
	Method New(m:Map<K,V>)
		Self.m = m
	End
	
	Method ObjectEnumerator:IEnumerator<V>()
		Return New WrappedMapValueEnumerator<V>(m.ObjectEnumerator())
	End
End

Class WrappedStackEnumerator<T> Implements IEnumerator<T>
	Field en:StackEnumerator<T>
	
	Method New(en:StackEnumerator<T>)
		Self.en = en
	End
	
	Method NextObject:T()
		Return en.NextObject()
	End
	
	Method HasNext:Bool()
		Return en.HasNext()
	End
End

Class WrappedStackEnumerable<T> Implements IEnumerable<T>
	Field s:Stack<T>
	
	Method New(s:Stack<T>)
		Self.s = s
	End
	
	Method ObjectEnumerator:IEnumerator<T>()
		Return New WrappedStackEnumerator<T>(s.ObjectEnumerator())
	End
End

Class WrappedListEnumerator<T> Implements IEnumerator<T>
	Field en:ListEnumerator<T>
	
	Method New(en:ListEnumerator<T>)
		Self.en = en
	End
	
	Method NextObject:T()
		Return en.NextObject()
	End
	
	Method HasNext:Bool()
		Return en.HasNext()
	End
End

Class WrappedListEnumerable<T> Implements IEnumerable<T>
	Field l:List<T>
	
	Method New(l:List<T>)
		Self.l = l
	End
	
	Method ObjectEnumerator:IEnumerator<T>()
		Return New WrappedListEnumerator<T>(l.ObjectEnumerator())
	End
End

Class WrappedSetEnumerator<T> Implements IEnumerator<T>
	Field en:MapKeyEnumerator<T,Object>
	
	Method New(en:MapKeyEnumerator<T,Object>)
		Self.en = en
	End
	
	Method NextObject:T()
		Return en.NextObject()
	End
	
	Method HasNext:Bool()
		Return en.HasNext()
	End
End

Class WrappedSetEnumerable<T> Implements IEnumerable<T>
	Field s:Set<T>
	
	Method New(s:Set<T>)
		Self.s = s
	End
	
	Method ObjectEnumerator:IEnumerator<T>()
		Return New WrappedSetEnumerator<T>(s.ObjectEnumerator())
	End
End
