#Rem
Copyright (c) 2011 Steve Revill and Shane Woolcock
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#End

#Rem
Header: Provides the DiddyMap class and associated utility classes.
#End

Strict
Private
Alias MapNode = monkey.map.Node

Import diddy.containers
Import diddy.exception

Public
#Rem
Summary: The DiddyMap class extends the official Monkey Map class.
#End
Class DiddyMap<K,V> Extends Map<K,V>
Public
#Rem
Summary: Constructor to create an empty DiddyMap.
#End
	Method New()
		Super.New()
	End

#Rem
Summary: Constructor to create a DiddyMap with the contents of the passed arrays.
Throws IllegalArgumentException if the arrays are different sizes.
#End
	Method New(keyArray:K[], valueArray:V[])
		If keyArray.Length <> valueArray.Length Then Throw New IllegalArgumentException("DiddyMap.New: Key and Value arrays must be the same length.")
		Self.SetAll(keyArray, valueArray)
	End

#Rem
Summary: Constructor to create a DiddyMap with the contents of the passed Map.
Throws IllegalArgumentException if src is Null.
#End
	Method New(src:Map<K,V>)
		If Not src Then Throw New IllegalArgumentException("DiddyMap.New: Source Map must not be null")
		Self.SetAll(src)
	End

#Rem
Summary: Adds/replaces all the mappings of the passed Map to the DiddyMap.
Returns the number of keys that were replaced, if any.
Throws IllegalArgumentException if src is Null.
#End
	Method SetAll:Int(src:Map<K,V>)
		If Not src Then Throw New IllegalArgumentException("DiddyMap.SetAll: Source Map must not be null")
		Local count:Int = 0
		Local node := src.FirstNode()
		While node
			If Self.Set(node.Key, node.Value) Then count += 1
			node = node.NextNode()
		End
		Return count
	End
	
#Rem
Summary: Adds/replaces all the mappings of the key/value arrays to the DiddyMap.
Returns the number of keys that were replaced, if any.
Throws IllegalArgumentException if the arrays are different sizes.
#End
	Method SetAll:Int(keyArray:K[], valueArray:V[])
		If keyArray.Length <> valueArray.Length Then Throw New IllegalArgumentException("DiddyMap.SetAll: Key and Value arrays must be the same length.")
		Local count:Int = 0
		For Local i:Int = 0 Until keyArray.Length
			If Self.Set(keyArray[i], valueArray[i]) Then count += 1
		Next
		Return count
	End
	
#Rem
Summary: Returns an array of all the values for keys in the passed List.
The returned array will always be the same size as the List, however if a key does not exist,
its corresponding array element will be Null.
Throws IllegalArgumentException if src is Null.
#End
	Method GetAll:V[](src:List<K>)
		If Not src Then Throw New IllegalArgumentException("DiddyMap.GetAll: Source List must not be null")
		Local rv:V[] = New V[src.Count()]
		Local i:Int = 0
		For Local key:K = Eachin src
			rv[i] = Self.Get(key)
			i += 1
		Next
		Return rv
	End
	
#Rem
Summary: Returns an array of all the values for keys in the passed Stack.
The returned array will always be the same size as the Stack, however if a key does not exist,
its corresponding array element will be Null.
Throws IllegalArgumentException if src is Null.
#End
	Method GetAll:V[](src:Stack<K>)
		If Not src Then Throw New IllegalArgumentException("DiddyMap.GetAll: Source Stack must not be null")
		Local rv:V[] = New V[src.Length]
		For Local i:Int = 0 Until rv.Length
			rv[i] = Self.Get(src.Get(i))
		Next
		Return rv
	End

#Rem
Summary: Returns an array of all the values for keys in the passed Set.
The returned array will always be the same size as the Set, however if a key does not exist,
its corresponding array element will be Null.
Throws IllegalArgumentException if src is Null.
#End
	Method GetAll:V[](src:Set<K>)
		If Not src Then Throw New IllegalArgumentException("DiddyMap.GetAll: Source Set must not be null")
		Local rv:V[] = New V[src.Count()]
		Local i:Int = 0
		For Local key:K = Eachin src
			rv[i] = Self.Get(key)
			i += 1
		Next
		Return rv
	End
	
#Rem
Summary: Returns an array of all the values for keys in the passed Deque.
The returned array will always be the same size as the Deque, however if a key does not exist,
its corresponding array element will be Null.
Throws IllegalArgumentException if src is Null.
#End
	Method GetAll:V[](src:Deque<K>)
		If Not src Then Throw New IllegalArgumentException("DiddyMap.GetAll: Source Deque must not be null")
		Local rv:V[] = New V[src.Length]
		For Local i:Int = 0 Until rv.Length
			rv[i] = Self.Get(src.Get(i))
		Next
		Return rv
	End
	
#Rem
Summary: Returns an array of all the values for keys in the passed array.
The returned array will always be the same size as the passed array, however if a key does not exist,
its corresponding array element will be Null.
#End
	Method GetAll:V[](keyArray:K[])
		Local rv:V[] = New V[keyArray.Length]
		For Local i:Int = 0 Until rv.Length
			rv[i] = Self.Get(keyArray[i])
		Next
		Return rv
	End
	
#Rem
Summary: Removes from this DiddyMap any keys that also exist in the passed Map.
The keys do not necessarily have to map to the same values in both Maps.
Returns the number of keys that were removed, if any.
Throws IllegalArgumentException if src is Null.
#End
	Method RemoveKeys:Int(src:Map<K,V>)
		If Not src Then Throw New IllegalArgumentException("DiddyMap.RemoveKeys: Source Map must not be null")
		Local count:Int = 0
		Local node := src.FirstNode()
		While node
			If Self.Remove(node.Key) Then count += 1
			node = node.NextNode()
		End
		Return count
	End
	
#Rem
Summary: Removes from this DiddyMap any keys that exist in the passed List.
Returns the number of keys that were removed, if any.
Throws IllegalArgumentException if src is Null.
#End
	Method RemoveKeys:Int(src:List<K>)
		If Not src Then Throw New IllegalArgumentException("DiddyMap.RemoveKeys: Source List must not be null")
		Local count:Int = 0
		For Local key:K = Eachin src
			If Self.Remove(key) Then count += 1
		Next
		Return count
	End
	
#Rem
Summary: Removes from this DiddyMap any keys that exist in the passed Stack.
Returns the number of keys that were removed, if any.
Throws IllegalArgumentException if src is Null.
#End
	Method RemoveKeys:Int(src:Stack<K>)
		If Not src Then Throw New IllegalArgumentException("DiddyMap.RemoveKeys: Source Stack must not be null")
		Local count:Int = 0
		For Local i:Int = 0 Until src.Length
			If Self.Remove(src.Get(i)) Then count += 1
		Next
		Return count
	End

#Rem
Summary: Removes from this DiddyMap any keys that exist in the passed Set.
Returns the number of keys that were removed, if any.
Throws IllegalArgumentException if src is Null.
#End
	Method RemoveKeys:Int(src:Set<K>)
		If Not src Then Throw New IllegalArgumentException("DiddyMap.RemoveKeys: Source Set must not be null")
		Local count:Int = 0
		For Local key:K = Eachin src
			If Self.Remove(key) Then count += 1
		Next
		Return count
	End
	
#Rem
Summary: Removes from this DiddyMap any keys that exist in the passed Deque.
Returns the number of keys that were removed, if any.
Throws IllegalArgumentException if src is Null.
#End
	Method RemoveKeys:Int(src:Deque<K>)
		If Not src Then Throw New IllegalArgumentException("DiddyMap.RemoveKeys: Source Deque must not be null")
		Local count:Int = 0
		For Local i:Int = 0 Until src.Length
			If Self.Remove(src.Get(i)) Then count += 1
		Next
		Return count
	End
	
#Rem
Summary: Removes from this DiddyMap any keys that exist in the passed array.
Returns the number of keys that were removed, if any.
#End
	Method RemoveKeys:Int(keyArray:K[])
		Local count:Int = 0
		For Local i:Int = 0 Until keyArray.Length
			If Self.Remove(keyArray[i]) Then count += 1
		Next
		Return count
	End
	
#Rem
Summary: Removes from this DiddyMap any keys that do NOT exist in the passed Map.
The keys do not necessarily have to map to the same values in both Maps.
Returns the number of keys that were removed, if any.
Throws IllegalArgumentException if src is Null.
#End
	Method RetainKeys:Int(src:Map<K,V>)
		If Not src Then Throw New IllegalArgumentException("DiddyMap.RetainKeys: Source Map must not be null")
		Local count:Int = 0
		Local toRemove:DiddyStack<K>
		
		' first, find the keys that need to be removed
		Local node := Self.FirstNode()
		While node
			Local nextNode := node.NextNode()
			If Not src.Contains(node.Key) Then
				If Not toRemove Then toRemove = New DiddyStack<K>
				toRemove.Push(node.Key)
				count += 1
			End
			node = nextNode
		End
		
		' now remove them
		If toRemove Then Self.RemoveKeys(toRemove)
		
		Return count
	End
	
#Rem
Summary: Removes from this DiddyMap any keys that do NOT exist in the passed List.
Returns the number of keys that were removed, if any.
Throws IllegalArgumentException if src is Null.
#End
	Method RetainKeys:Int(src:List<K>)
		If Not src Then Throw New IllegalArgumentException("DiddyMap.RetainKeys: Source List must not be null")
		Local count:Int = 0
		Local toRemove:DiddyStack<K>
		
		' first, find the keys that need to be removed
		Local node := Self.FirstNode()
		While node
			Local nextNode := node.NextNode()
			If Not src.Contains(node.Key) Then
				If Not toRemove Then toRemove = New DiddyStack<K>
				toRemove.Push(node.Key)
				count += 1
			End
			node = nextNode
		End
		
		' now remove them
		If toRemove Then Self.RemoveKeys(toRemove)
		
		Return count
	End
	
#Rem
Summary: Removes from this DiddyMap any keys that do NOT exist in the passed Stack.
Returns the number of keys that were removed, if any.
Throws IllegalArgumentException if src is Null.
#End
	Method RetainKeys:Int(src:Stack<K>)
		If Not src Then Throw New IllegalArgumentException("DiddyMap.RetainKeys: Source Stack must not be null")
		Local count:Int = 0
		Local toRemove:DiddyStack<K>
		
		' first, find the keys that need to be removed
		Local node := Self.FirstNode()
		While node
			Local nextNode := node.NextNode()
			If Not src.Contains(node.Key) Then
				If Not toRemove Then toRemove = New DiddyStack<K>
				toRemove.Push(node.Key)
				count += 1
			End
			node = nextNode
		End
		
		' now remove them
		If toRemove Then Self.RemoveKeys(toRemove)
		
		Return count
	End

#Rem
Summary: Removes from this DiddyMap any keys that do NOT exist in the passed Set.
Returns the number of keys that were removed, if any.
Throws IllegalArgumentException if src is Null.
#End
	Method RetainKeys:Int(src:Set<K>)
		If Not src Then Throw New IllegalArgumentException("DiddyMap.RetainKeys: Source Set must not be null")
		Local count:Int = 0
		Local toRemove:DiddyStack<K>
		
		' first, find the keys that need to be removed
		Local node := Self.FirstNode()
		While node
			Local nextNode := node.NextNode()
			If Not src.Contains(node.Key) Then
				If Not toRemove Then toRemove = New DiddyStack<K>
				toRemove.Push(node.Key)
				count += 1
			End
			node = nextNode
		End
		
		' now remove them
		If toRemove Then Self.RemoveKeys(toRemove)
		
		Return count
	End
	
#Rem
Summary: Removes from this DiddyMap any keys that do NOT exist in the passed Deque.
Returns the number of keys that were removed, if any.
Throws IllegalArgumentException if src is Null.
#End
	Method RetainKeys:Int(src:Deque<K>)
		If Not src Then Throw New IllegalArgumentException("DiddyMap.RetainKeys: Source Deque must not be null")
		Local count:Int = 0
		Local toRemove:DiddyStack<K>
		
		' first, find the keys that need to be removed
		Local node := Self.FirstNode()
		While node
			Local nextNode := node.NextNode()
			If Not ContainerUtil<K>.DequeContains(src, node.Key) Then
				If Not toRemove Then toRemove = New DiddyStack<K>
				toRemove.Push(node.Key)
				count += 1
			End
			node = nextNode
		End
		
		' now remove them
		If toRemove Then Self.RemoveKeys(toRemove)
		
		Return count
	End
	
#Rem
Summary: Removes from this DiddyMap any keys that do NOT exist in the passed array.
Returns the number of keys that were removed, if any.
#End
	Method RetainKeys:Int(keyArray:K[])
		Local count:Int = 0
		Local toRemove:DiddyStack<K>
		
		' first, find the keys that need to be removed
		Local node := Self.FirstNode()
		While node
			Local nextNode := node.NextNode()
			For Local i:Int = 0 Until keyArray.Length
				If keyArray[i] And Self.Compare(node.Key, keyArray[i]) = 0 Then
					If Not toRemove Then toRemove = New DiddyStack<K>
					toRemove.Push(keyArray[i])
					count += 1
					Exit
				End
			Next
			node = nextNode
		End
		
		' now remove them
		If toRemove Then Self.RemoveKeys(toRemove)
		
		Return count
	End
	
#Rem
Summary: Returns True if this DiddyMap contains ALL of the EXACT mappings of the passed Map.
Throws IllegalArgumentException if src is Null.
#End
	Method ContainsAllMappings:Bool(src:Map<K,V>)
		If Not src Then Throw New IllegalArgumentException("DiddyMap.ContainsAllMappings: Source Map must not be null")
		Local node := src.FirstNode()
		While node
			Local mynode := Self._FindNode(node.Key)
			If Not mynode Or mynode.Value <> node.Value Then Return False
			node = node.NextNode()
		End
		Return True
	End
	
#Rem
Summary: Returns True if this DiddyMap contains ALL of the EXACT mappings of the passed arrays.
Throws IllegalArgumentException if the arrays are different sizes.
#End
	Method ContainsAllMappings:Bool(keyArray:K[], valueArray:V[])
		If keyArray.Length <> valueArray.Length Then Throw New IllegalArgumentException("DiddyMap.ContainsAllMappings: Key and Value arrays must be the same length.")
		For Local i:Int = 0 Until keyArray.Length
			Local mynode := Self._FindNode(keyArray[i])
			If Not mynode Or mynode.Value <> valueArray[i] Then Return False
		End
		Return True
	End

#Rem
Summary: Returns True if this DiddyMap contains ALL of the keys in the passed Map.
The keys do not necessarily have to map to the same values, they just need to exist.
Throws IllegalArgumentException if src is Null.
#End
	Method ContainsAllKeys:Bool(src:Map<K,V>)
		If Not src Then Throw New IllegalArgumentException("DiddyMap.ContainsAllKeys: Source Map must not be null")
		Local node := src.FirstNode()
		While node
			If Not Self.Contains(node.Key) Then Return False
			node = node.NextNode()
		End
		Return True
	End

#Rem
Summary: Returns True if this DiddyMap contains ALL of the keys in the passed List.
Throws IllegalArgumentException if src is Null.
#End
	Method ContainsAllKeys:Bool(src:List<K>)
		If Not src Then Throw New IllegalArgumentException("DiddyMap.ContainsAllKeys: Source List must not be null")
		For Local key:K = Eachin src
			If Not Self.Contains(key) Then Return False
		Next
		Return True
	End

#Rem
Summary: Returns True if this DiddyMap contains ALL of the keys in the passed Stack.
Throws IllegalArgumentException if src is Null.
#End
	Method ContainsAllKeys:Bool(src:Stack<K>)
		If Not src Then Throw New IllegalArgumentException("DiddyMap.ContainsAllKeys: Source Stack must not be null")
		For Local i:Int = 0 Until src.Length
			If Not Self.Contains(src.Get(i)) Then Return False
		Next
		Return True
	End
	
#Rem
Summary: Returns True if this DiddyMap contains ALL of the keys in the passed Set.
Throws IllegalArgumentException if src is Null.
#End
	Method ContainsAllKeys:Bool(src:Set<K>)
		If Not src Then Throw New IllegalArgumentException("DiddyMap.ContainsAllKeys: Source Set must not be null")
		For Local key:K = Eachin src
			If Not Self.Contains(key) Then Return False
		Next
		Return True
	End
	
#Rem
Summary: Returns True if this DiddyMap contains ALL of the keys in the passed Deque.
Throws IllegalArgumentException if src is Null.
#End
	Method ContainsAllKeys:Bool(src:Deque<K>)
		If Not src Then Throw New IllegalArgumentException("DiddyMap.ContainsAllKeys: Source Deque must not be null")
		For Local i:Int = 0 Until src.Length
			If Not Self.Contains(src.Get(i)) Then Return False
		Next
		Return True
	End
	
#Rem
Summary: Returns True if this DiddyMap contains ALL of the keys in the passed array.
#End
	Method ContainsAllKeys:Bool(keyArray:K[])
		For Local i:Int = 0 Until keyArray.Length
			If Not Self.Contains(keyArray[i]) Then Return False
		End
		Return True
	End
	
#Rem
Summary: Compares two values of the generic type K, for sorting.
Called automatically by Monkey's mapping algorithm, it first attempts to use an IComparator if it exists.
If not it will attempt to use the IComparable CompareTo method if T implements it.
Finally, it will throw an exception.
#End
	Method Compare:Int(lhs:K, rhs:K)
		If Self.comparator Then Return Self.comparator.Compare(lhs, rhs)
		If IComparableWrapper.IsComparable(lhs) Or IComparableWrapper.IsComparable(rhs) Then Return IComparableWrapper.Compare(lhs, rhs)
		Throw New IllegalArgumentException("DiddyMap.Compare: The key class does not implement IComparable, and there is no comparator assigned.")
	End
	
#Rem
Summary: Populates the passed K[] and V[] arrays with all the mappings in the DiddyMap.
If the arrays are too small to fit all the mappings, an IllegalArgumentException is thrown.
The number of key/value pairs successfully mapped is returned.
#End
	Method FillArrays:Int(keyArray:K[], valueArray:V[])
		Local cnt:Int = Count()
		If keyArray.Length < cnt Then Throw New IllegalArgumentException("DiddyMap.FillArrays: keyArray length too small ("+keyArray.Length+"<"+cnt+")")
		If valueArray.Length < cnt Then Throw New IllegalArgumentException("DiddyMap.FillArrays: valueArray length too small ("+valueArray.Length+"<"+cnt+")")
		
		Local node := FirstNode()
		Local idx:Int = 0
		While node
			keyArray[idx] = node.Key
			valueArray[idx] = node.Value
			node = node.NextNode()
			idx += 1
		End
		Return idx
	End
	
Private
	Field comparator:IComparator<K>
	
Public
#Rem
Summary: Getter for the current sorting comparator.
Allows sorting without implementing IComparable.
#End
	Method Comparator:IComparator<K>() Property; Return Self.comparator; End
	
#Rem
Summary: Setter for the current sorting comparator.
Allows sorting without implementing IComparable.
#End
	Method Comparator:Void(comparator:IComparator<K>) Property; Self.comparator = comparator; End
	
#Rem
Summary: Finds the node for a given key.
For some reason, the API version of this method is private, so we've had to make our own.
#End
	Method _FindNode:MapNode<K,V>(key:K)
		Local node := FirstNode()
		While node
			If Compare(key, node.Key) = 0 Then Return node
			node = node.NextNode()
		Wend
		Return Null
	End
End

#Rem
Summary: Extends DiddyMap to provide Int-specific comparison (to avoid the IComparable check).
Similar to IntMap.
#End
Class DiddyIntMap<V> Extends DiddyMap<Int,V>
	Method New(keyArray:Int[], valueArray:V[])
		Super.New(keyArray, valueArray)
	End
	
	Method Compare:Int(lhs:Int, rhs:Int)
		If Self.Comparator Then Return Self.Comparator.Compare(lhs, rhs)
		Return lhs-rhs
	End
End

#Rem
Summary: Extends DiddyMap to provide Float-specific comparison (to avoid the IComparable check).
Similar to FloatMap.
#End
Class DiddyFloatMap<V> Extends DiddyMap<Float,V>
	Method New(keyArray:Float[], valueArray:V[])
		Super.New(keyArray, valueArray)
	End
	
	Method Compare:Int(lhs:Float, rhs:Float)
		If Self.Comparator Then Return Self.Comparator.Compare(lhs, rhs)
		If lhs<rhs Return -1
		Return lhs>rhs
	End
End

#Rem
Summary: Extends DiddyMap to provide String-specific comparison (to avoid the IComparable check).
Similar to StringMap.
#End
Class DiddyStringMap<V> Extends DiddyMap<String,V>
	Method New(keyArray:String[], valueArray:V[])
		Super.New(keyArray, valueArray)
	End
	
	Method Compare:Int(lhs:String, rhs:String)
		If Self.Comparator Then Return Self.Comparator.Compare(lhs, rhs)
		Return lhs.Compare(rhs)
	End
End
