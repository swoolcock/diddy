#Rem
Copyright (c) 2011 Steve Revill and Shane Woolcock
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#End

Strict
Private
Import diddy.containers
Import diddy.diddystack
Import monkey.list

Public
Class Test Implements IComparable
	Field a:Int
	
	Method New(a:Int)
		Self.a = a
	End
	
	Method CompareTo:Int(other:Object)
		Return a - Test(other).a
	End
End

Function Main:Int()
	TestDiddyStackSorting()
	Return 0
End

Function TestDiddyStackSorting:Void()
	Local dis:DiddyIntStack = New DiddyIntStack()
	Print("Adding 5 ints")
	dis.AddItem(5)
	dis.AddItem(7)
	dis.AddItem(5)
	dis.AddItem(2)
	dis.AddItem(10)
	
	Print("Printing them pre-sort")
	For Local i:Int = EachIn(dis)
		Print("i="+i)
	Next
	
	Print("Sorting ascending")
	dis.SortItems()
	Print("Printing them post-sort")
	For Local i:Int = EachIn(dis)
		Print("i="+i)
	Next
	
	Print("Sorting descending")
	dis.SortItems(False)
	Print("Printing them post-sort")
	For Local i:Int = EachIn(dis)
		Print("i="+i)
	Next

	Local dss:DiddyStringStack = New DiddyStringStack()
	Print("Adding 5 strings")
	dss.AddItem("banana")
	dss.AddItem("egg")
	dss.AddItem("cat")
	dss.AddItem("apple")
	dss.AddItem("dog")

	Print("Printing them pre-sort")
	For Local s:String = EachIn(dss)
		Print("s="+s)
	Next
	
	Print("Sorting ascending")
	dss.SortItems()
	Print("Printing them post-sort")
	For Local s:String = EachIn(dss)
		Print("s="+s)
	Next
	
	Print("Sorting descending")
	dss.SortItems(False)
	Print("Printing them post-sort")
	For Local s:String = EachIn(dss)
		Print("s="+s)
	Next
	
	Local ds:DiddyStack<Test> = New DiddyStack<Test>
	Print("Adding 5 instances of Test")
	ds.AddItem(New Test(5))
	ds.AddItem(New Test(1))
	ds.AddItem(New Test(3))
	ds.AddItem(New Test(4))
	ds.AddItem(New Test(2))
	
	Print("Printing them pre-sort")
	For Local t:Test = EachIn(ds)
		Print("t.a="+t.a)
	Next
	
	Print("Sorting ascending")
	ds.SortItems()
	Print("Printing them post-sort")
	For Local t:Test = EachIn(ds)
		Print("t.a="+t.a)
	Next
	
	Print("Sorting descending")
	ds.SortItems(False)
	Print("Printing them post-sort")
	For Local t:Test = EachIn(ds)
		Print("t.a="+t.a)
	Next
End
