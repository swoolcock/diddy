Import diddy.math

Function Main()
	' NextInt() ' returns a random value within the entire 32-bit signed integer range (-2147483648 to +2147483647)
	' NextInt(n) ' returns a random integer value from 0 (inclusive) to n (exclusive)
	' NextInt(low,high) ' returns a random integer value from low (inclusive) to high (inclusive)
	' NextFloat() ' returns a random float value from 0 (inclusive) to 1 (exclusive) - this is essentially the same as Rnd()
	' NextBool() ' returns true or false with an approximately 50/50 spread
	
	' create a RandomSource - you could store the seed in your savegame
	Local one:RandomSource = New RandomSource(12345)
	Print "First"
	Print "a "+one.NextInt(1,10) ' a
	Print "b "+one.NextInt(5) ' b
	Print "c "+one.NextFloat() ' c
	
	' create another one with a different seed
	Local two:RandomSource = New RandomSource(67890)
	Print "d "+two.NextInt() ' d
	If two.NextBool() Print "e true" Else Print "e false" ' e
	Print "f "+two.NextInt(7) ' f
	
	' recreate them
	one = New RandomSource(12345)
	two = New RandomSource(67890)
	
	' as long as the calls are in the same order within each source, you can mix and match them with no conflicts
	' these will give you the same values as before, even though the calls for one and two are mixed together
	Print "Second"
	Print "a "+one.NextInt(1,10) ' a
	Print "d "+two.NextInt() ' d
	If two.NextBool() Print "e true" Else Print "e false" ' e
	Print "b "+one.NextInt(5) ' b
	Print "f "+two.NextInt(7) ' f
	Print "c "+one.NextFloat() ' c
	
	' test calling the default Rnd() function with the system seed
	one = RandomSource.SystemSource
	Print one.NextFloat()
	Print one.NextFloat()
	Print one.NextFloat()
	Print one.NextFloat()
End

#Rem
First
a 1
b 0
c 0.5431557893753052
d -1945622467
e true
f 4
Second
a 1
d -1945622467
e true
b 0
f 4
c 0.5431557893753052
0.7143076658248901
0.2070130705833435
0.7495418190956116
0.34606242179870605
#End
