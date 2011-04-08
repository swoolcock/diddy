Strict

Import diddy.collections

Function Main:Int()
	TestArrayList()
	Return 0
End

Function TestArrayList:Void()
	Print("Adding 3 elements to l1...")
	Local l1:ArrayList<StringObject> = New ArrayList<StringObject>
	l1.Add("test3")
	l1.Add("test2")
	l1.Add("test1")
	Print("l1.Size="+l1.Size)
	
	Print("Adding 3 elements to l2...")
	Local l2:ArrayList<StringObject> = New ArrayList<StringObject>
	l2.Add("test6")
	l2.Add("test5")
	l2.Add("test4")
	Print("l2.Size="+l2.Size)
	
	Print("Adding contents of l2 to l1..")
	l1.AddAll(l2)
	Print("l1.Size="+l1.Size)

	Print("Calling l1.ToArray (creates a new array)...")
	Local arr:Object[] = l1.ToArray()
	Print("Array length="+arr.Length)
	Print("Looping on array with EachIn...")
	For Local o:Object = EachIn arr
		Print("value="+StringObject(o).value)
	Next
	
	Print("Calling l2.FillArray (reuses an existing array, and we know that the results will fit)...")
	Local len:Int = l2.FillArray(arr)
	Print("Returned value (size)="+len)
	Print("Looping on array with index...")
	For Local i:Int = 0 Until len
		Print("value["+i+"]="+StringObject(arr[i]).value)
	Next
	
	Print("Looping on l1 using EachIn...")
	For Local so:StringObject = EachIn l1
		Print("value="+so.value)
	Next
	
	Print("Looping on l1 manually with AbstractEnumerator...")
	Local oe:AbstractEnumerator<StringObject> = l1.ObjectEnumerator()
	While oe.HasNext()
		Local val:StringObject = oe.NextObject()
		Print("value="+val.value)
	End
	
	Print("Jumping to end of AbstractEnumerator and looping in reverse...")
	oe = l1.ObjectEnumerator()
	oe.Last()
	While oe.HasPrevious()
		Local val:StringObject = oe.PreviousObject()
		Print("value="+val.value)
	End
	Print("And now looping forward again...")
	While oe.HasNext()
		Local val:StringObject = oe.NextObject()
		Print("value="+val.value)
	End
	
	Print("Testing removing items with AbstractEnumerator (forward)...")
	Print("We'll remove the item 'test1'")
	oe = l1.ObjectEnumerator()
	While oe.HasNext()
		Local val:StringObject = oe.NextObject()
		Print("value="+val.value)
		If val.value = "test1" Then
			Print("Removing...")
			oe.Remove()
		End
	End
	
	Print("Now we'll loop back to make sure it worked...")
	oe.Last()
	While oe.HasPrevious()
		Local val:StringObject = oe.PreviousObject()
		Print("value="+val.value)
	End
	
	Print("Testing concurrency checks by removing within an EachIn loop (uncomment to test)...")
	#Rem
	For Local so:StringObject = EachIn l1
		Print("value="+so.value)
		Print("Manually removing it...")
		l1.RemoveAt(0)
		Print("Next call to HasNext should fail.")
	End
	#End
End


