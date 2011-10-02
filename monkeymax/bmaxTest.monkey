Strict
Const TITLE:String = "Monkey to BlitzMax"
Const MAJOR_VERSION:Int = 0
Const MINOR_VERSION:Int = 1
Global y:Int = 10

Function Main:Int()
	Print "~n"
	Print ">>> Testing "+ TITLE + " v" + MAJOR_VERSION + "." + MINOR_VERSION + " <<<"
	Print "~n"
	Print "~qTesting tilde q (quotes)~q"
	Print "~rTesting tilde r (return)~r"
	Print "~tTesting tilde t (tab)~t"
	Print "Global y="+y
	
	
	Loops()
	
	Objects()
	
	StringStuff()
	
	MathStuff(2)
	
	Types()
	
	Lists()
	
	Error "Testing Error!!"
	
	Return 1
End

Function Lists:Void()
	Print "*********** Lists ***********"

	Local myList:=New StringList
	
	'add a bunch of stuff
	myList.AddLast "Hello"
	myList.AddLast "BAM!"
	myList.AddLast "there"
	myList.AddLast "BAM!"
	myList.AddLast "this"
	myList.AddLast "BAM!"
	myList.AddLast "is"
	myList.AddLast "BAM!"
	myList.AddLast "a"
	myList.AddLast "BAM!"
	myList.AddLast "List"
	
	'removes all occurances of a value
	myList.RemoveEach "BAM!"

	'iterate through a list with an EachIn loop
	For Local item:=Eachin myList
		Print item
	Next
	
	Print ""

	'Iterate backwards through the list	
	For Local item:=Eachin myList.Backwards()
		Print item
	Next
	
	Print ""
	Local spriteList:List<Sprite> = New List<Sprite>
	For Local i% = 0 To 10
		spriteList.AddLast(New Sprite(Rnd(0,100), Rnd(0,10)))
	Next
	Print spriteList.Count()
	spriteList.Clear()
	Print spriteList.Count()
	If spriteList.IsEmpty()
		Print "EMPTY!!"
	End
	Print ""
	Print "Testing Stack.."
	Local stk:=New StringStack
	
	stk.Push "Hello"
	stk.Push "there"
	stk.Push "this"
	stk.Push "is"
	stk.Push "a"
	stk.Push "Stack"
	
	Print "Fowards:"
	For Local t$=Eachin stk
		Print t
	Next
	
	Print ""
	
	Print "Backwards:"
	For Local t$=Eachin stk.Backwards()
		Print t
	Next

	Print ""
	Print "Testing Map.."
	Local mtk:=New StringMap<Item>
	mtk.Set("1", New Item(1))
	mtk.Set("2", New Item(2))
	mtk.Set("3", New Item(3))
	mtk.Set("4", New Item(4))
	mtk.Set("5", New Item(5))
	
	For Local key:String = Eachin mtk.Keys()
		Print key + " is stored in the map."
	Next
	
End
Class Item
	Field value:Int
	Method New(v:Int)
		value=v
	End
End
Function Types:Void()
	Print "*********** Types***********"

	Local boolean:Bool = True
	Local integer:Int = 2
	Local floatt:Float = 4.2
	Local str:String = "Hello World   "
	' Arrays
	Local boolArray:Bool[]=[True,False,True,True,False,True]
	Local intArray:Int[]=[10,20,30]
	Local floatArray:Float[]=[1.5,-2.3,54.212]
	Local stringArray:String []=["Hello","There","World"]
	Local box:Int[]=[]
	Local thing:Int[][]
	
	Local ints:Int[]
	Local flo:Float[]
	Local blo:Bool[]
	Local strs:String[]
	
	ints = New Int[10]
	Print ints.Length
	flo= New Float[10]
	blo= New Bool[10]
	Print blo.Length
	strs = New String[10]

	If boolean
		Print "boolean = True"
	Else
		Print "boolean = False"
	End
	
	Print "str.Length="+str.Length()
	str = str.Trim()
	Print "str.Length after trim="+str.Length()
		
	Print "integer = "+integer
	Print "floatt = "+floatt
	Print "str = "+str
	Print "intArray.Length() = "+intArray.Length()
	For Local i:Int = 0 Until intArray.Length()
		Print "intArray Using ForUntil = "+intArray[i]
	Next
	For Local i:Int = Eachin intArray
		Print "intArray Using Eachin = "+i
	Next
	Print "boolArray.Length() = "+boolArray.Length()
	Print "floatArray.Length() = "+floatArray.Length()
	For Local i:Int = 0 Until floatArray.Length()
		Print "floatArray Using ForUntil = "+floatArray[i]
	Next
	Print "stringArray.Length() = "+stringArray.Length()
	For Local i:Int = 0 Until stringArray.Length()
		Print "stringArrayUsing ForUntil = "+stringArray[i]
	Next
	
	Local text:String[]=["Hello","There","World"]        'a comma separated sequence
	Local text1:=text.Resize(2)
	Print text.Length                
	Print text1.Length 'prints 2
	For Local i:Int = 0 Until text1.Length()
		Print "text1 Using ForUntil "+i+" = "+text1[i]
	Next
	floatArray.Resize(10)
	intArray.Resize(10)
	
	Local blah:Int[2][]
	
	Local arr1:Int[4]
	arr1 = [0,1,2,3]
	
	Local arr2:Int[4]
	For Local f:=0 To 3
		arr2[f] = (f+1)*10
	End
	
	blah[0] = arr1		
	blah[1] = arr2
	
	For Local f:= 0 To 1
		For Local f2:=0 To 3
			Print blah[f][f2]
		Next
	Next
	
	blah = blah.Resize(4)
	Print "after resize..."
	For Local f:= 0 To 1
		For Local f2:=0 To 3
			Print blah[f][f2]
		Next
	Next
	
	Local names:String[][] = [["Mr. ", "Mrs. ", "Ms. "] , ["Smith", "Jones"]]
	Print names.Length
	Print names[0][0] + names[1][0]
	Print names[0][2] + names[1][1]	
	names.Resize(0)
	Print names[0][0] + names[1][0]
	Print names[0][2] + names[1][1]
	
	Local floats:Float[][] = [[0.2, 0.3] , [1.2, 1.3]]
	Print floats[0][0] + " " + floats[1][1]
	For Local i:Int = 0 Until floats.Length
		For Local j:Int = 0 Until floats[1].Length
			Print "i = "+i
			Print "j = "+j
			Print "[i][j] = "+floats[i][j]
		Next
	Next
	floats.Resize(10)
	Local myArray:Int[][] = [  [0, 1, 2, 3], [3, 2, 1, 0], [3, 5, 6, 1], [3, 8, 3, 4, 5] ]
	
	Print myArray[3][1]
	
	Local sprite:Sprite[]
	
	Local sprites:Sprite[]
	sprites = New Sprite[10]

	For Local i%=0 To 9
		sprites[i] = New Sprite
	Next

End


' TO-DO
Interface Bob
	Const animal:String ="ANIMAL"
	
	Method Cat:Void()
	
	Method Dog:Void()
End

Class Sprite 'Implements Bob ' TO-DO: Interfaces
	Field x:Float, y:Float
	
	Function Test:Void()
		Print "Sprite Test"
	End
	
	Method Cat:Void()
		Print "Cat"
	End
	
	Method New(x#, y#)
		Print "New Sprite x="+x+" y="+y
		Self.x = 100
		Self.y = 100
	End
	
	Method New()
		Print "New Sprite"
		x = 100
		y = 100
	End
	
	Method Draw:Void()
		Print "Draw"		
	End

	Method Draw:Void(x:Int, y:Int)
		Print "Draw2"
	End
End

Class Screen Abstract
	Method Update:Void() Abstract
	Method Draw:Void() Abstract
	Method Pop:Void()
		Print "Pop"
	End
End

Class Gamescreen Extends Screen
	Method Update:Void()
		Print "Update"
	End
	Method Draw:Void()
		Print "Draw"
	End
	Method Pop:Void()
		Print "GS Pop"
	End
End

Function Objects:Void()
	Print "*********** Objects ***********"
	Local s:Sprite = New Sprite
	s.Draw()
	s.Draw(1,1)
	s.Test()
	s.x = 10
	s.Cat()
	Print "sprite x="+s.x
	Print "sprite y="+s.y
	
	Local gs:Gamescreen = New Gamescreen
	gs.Draw()
	gs.Pop()
End

Function StringStuff:Void()
	Print "*********** Strings ***********"

	Local str:String = "bob"
	Print str
	Print "str.Length="+str.Length
	str = str.ToUpper()
	Print str
	str = str.ToLower()
	
	If str.Contains("bob")
		Print "Yep it's Bob!"
	End
	
	Local compareStr:String = "comp"
	If str.Compare(compareStr)
		Print "comparing..."
	End
	If str.Find("o", 0)
		Print "O Find!"
	End
	If str.Find("o")
		Print "h1"
	End
'	str.Join(compareStr)
	Local strreplace:String = str.Replace("o","a")
	Print strreplace
	strreplace = "If blah then"
	If strreplace.StartsWith("If")
		Print "Yep its an If"
	End
	If strreplace.EndsWith("then")
		Print "Yep its an then"
	End
	If strreplace.EndsWith("xxxx")
		Print "Yep its an xxxx"
	End
	Print str
End

Function MathStuff:Int(x:Int)
	Print "*********** Maths ***********"
	Print "x = x + 10"
	x = x + 10
	Print x
	Print "x += 20"
	x += 20
	Print x
	Print "5 Mod 10 = "+5 Mod 10
	x = 5 Mod 10
	Print x
	x = x*2+10/2
	Print x
	Local angle:Float = 360
	Local sinAngle# = Sin(angle)
	Local cosAngle# = Cos(angle)	
	Local tanAngle# = Tan(angle)
	Local asinAngle# = ASin(angle)
	Local acosAngle# = ACos(angle)	
	Local atanAngle# = ATan(angle)
	Local atan2Angle# = ATan2(angle, 180)	
	Print sinAngle
	Print cosAngle 
	Print tanAngle 
	Print asinAngle
	Print acosAngle 
	Print atanAngle 
	Print atan2Angle	
	Print angle
	
	Local cosRAngle# = ACosr(angle)
	Print cosRAngle 
		
	Print "Power to the People!"
	Local po:Int = Pow(2,10)
	Print po
	Local sq# = 81
	sq = Sqrt(sq)
	Print sq
	Print Abs(-100)
	
	Print HALFPI
	Print PI
	Print TWOPI
	
	Return 1
End

Function Loops:Void()
	Print "*********** Loops ***********"
	Print "For Loop using To"
	For Local i:Int = -2 To 2
		Print "i="+i
	Next

	Print "For Loop using Until"
	For Local j:Int = -2 Until 2
		Print "j="+j
	Next
	
	Print "For Loop using To and Step 2"
	For Local a:Int = -4 To 4 Step 2
		Print "a="+a
	Next
	Print "While Loop"
	y = 0
	While y<4
		y+=2
		Print "y="+y
	Wend
	Print "Repeat Loop"
	Repeat
		y-=1
		Print "y="+y
	Until y = 0
End
