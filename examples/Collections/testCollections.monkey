Strict

Import diddy.collections
Import monkey.list

Function Main:Int()
	TestArrayList()
	'TestArrayListSorting()
	'SpeedComparison()
	'ArrayListSortingSpeed(10000)
	Return 0
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

Function TestArrayListSorting:Void()
	Local al:ArrayList<IntObject> = New ArrayList<IntObject>()
	Print("Adding 8 ints")
	al.Add(New IntObject(5))
	al.Add(New IntObject(7))
	al.Add(New IntObject(5))
	al.Add(New IntObject(2))
	al.Add(New IntObject(10))
	al.Add(New IntObject(1))
	al.Add(New IntObject(11))
	al.Add(New IntObject(8))
	
	Print("Printing them pre-sort")
	For Local o:IntObject = EachIn(al)
		Print("o="+o.value)
	Next
	
	Print("Sorting ascending")
	al.Sort()
	Print("Printing them post-sort")
	For Local o:IntObject = EachIn(al)
		Print("o="+o.value)
	Next
	
	Print("Sorting Descending")
	al.Sort(True)
	Print("Printing them post-sort")
	For Local o:IntObject = EachIn(al)
		Print("o="+o.value)
	Next
End

Function SpeedComparison:Void()
	Local al:ArrayList<StringObject> = New ArrayList<StringObject>(1000000)
	Local lst:List<StringObject> = New List<StringObject>()
	
	Local startTime:Int
	
	Print("Testing adding 1000000 items to an ArrayList")
	startTime = RealMillisecs()
	For Local i:Int = 0 Until 1000000
		al.Add("test")'+i)
	Next
	Print("Took: "+(RealMillisecs()-startTime))
	
	Print("Testing adding 1000000 items to a List")
	startTime = RealMillisecs()
	For Local i:Int = 0 Until 1000000
		lst.AddLast("test")'+i)
	Next
	Print("Took: "+(RealMillisecs()-startTime))
	
	Print("Testing looping through an ArrayList with EachIn")
	startTime = RealMillisecs()
	For Local so:StringObject = EachIn al
		' do nothing
	Next
	Print("Took: "+(RealMillisecs()-startTime))
	
	Print("Testing looping through a List with EachIn")
	startTime = RealMillisecs()
	For Local so:StringObject = EachIn lst
		' do nothing
	Next
	Print("Took: "+(RealMillisecs()-startTime))
	
	Print("Testing looping through an ArrayList manually")
	startTime = RealMillisecs()
	For Local i:Int = 0 Until al.Size
		Local so:StringObject = al.Get(i)
		' do nothing
	Next
	Print("Took: "+(RealMillisecs()-startTime))
	
	Print("Testing ToArray")
	startTime = RealMillisecs()
	Local arr:Object[] = al.ToArray()
	Print("Took: "+(RealMillisecs()-startTime))
	
	Print("Testing looping through an ArrayList ToArray ("+arr.Length+" elements)")
	startTime = RealMillisecs()
	For Local i:Int = 0 Until arr.Length
		' do nothing
	Next
	Print("Took: "+(RealMillisecs()-startTime))
End

Function ArrayListSortingSpeed:Void(numToTest:Int=1000)
	Local startTime:Int
	
	Local al:ArrayList<IntObject> = New ArrayList<IntObject>(numToTest+10)
	Print("Seeding with: " + RealMillisecs())
	Print("Adding "+numToTest+" random ints")
	startTime = RealMillisecs()
	For Local i%=1 To numToTest
		al.Add(New IntObject(Int(Rnd()*1000)))
	Next
	Print("Took: "+(RealMillisecs()-startTime))
	Print("Size: "+al.Size)
	Print("First 10:")
	For Local i%=0 To 9
		Print(al.Get(i).value)
	Next
	
	Print("Sorting ascending")
	startTime = RealMillisecs()
	al.Sort()
	Print("Took: "+(RealMillisecs()-startTime))
	Print("First 10:")
	For Local i%=0 To 9
		Print(al.Get(i).value)
	Next
	
	Print("Clearing")
	startTime = RealMillisecs()
	al.Clear()
	Print("Took: "+(RealMillisecs()-startTime))
	
	Print("Adding "+numToTest+" random ints again")
	startTime = RealMillisecs()
	For Local i%=1 To numToTest
		al.Add(New IntObject(Int(Rnd()*1000)))
	Next
	Print("Took: "+(RealMillisecs()-startTime))
	Print("Size: "+al.Size)
	Print("First 10:")
	For Local i%=0 To 9
		Print(al.Get(i).value)
	Next
	
	Print("Sorting descending")
	startTime = RealMillisecs()
	al.Sort(True)
	Print("Took: "+(RealMillisecs()-startTime))
	Print("First 10:")
	For Local i%=0 To 9
		Print(al.Get(i).value)
	Next
	
	Print("Trying floats")
	Local fal:ArrayList<FloatObject> = New ArrayList<FloatObject>(numToTest+10)
	Print("Adding "+numToTest+" random floats")
	startTime = RealMillisecs()
	For Local i%=1 To numToTest
		fal.Add(New FloatObject(Rnd()*1000))
	Next
	Print("Took: "+(RealMillisecs()-startTime))
	Print("Size: "+fal.Size)
	Print("First 10:")
	For Local i%=0 To 9
		Print(fal.Get(i).value)
	Next
	
	Print("Sorting ascending")
	startTime = RealMillisecs()
	fal.Sort()
	Print("Took: "+(RealMillisecs()-startTime))
	Print("First 10:")
	For Local i%=0 To 9
		Print(fal.Get(i).value)
	Next
	
	Print("Clearing")
	startTime = RealMillisecs()
	fal.Clear()
	Print("Took: "+(RealMillisecs()-startTime))
	
	Print("Adding "+numToTest+" random floats again")
	startTime = RealMillisecs()
	For Local i%=1 To numToTest
		fal.Add(New FloatObject(Rnd()*1000))
	Next
	Print("Took: "+(RealMillisecs()-startTime))
	Print("Size: "+al.Size)
	Print("First 10:")
	For Local i%=0 To 9
		Print(fal.Get(i).value)
	Next
	
	Print("Sorting descending")
	startTime = RealMillisecs()
	fal.Sort(True)
	Print("Took: "+(RealMillisecs()-startTime))
	Print("First 10:")
	For Local i%=0 To 9
		Print(fal.Get(i).value)
	Next
End




