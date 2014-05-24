#Rem
Copyright (c) 2011 Dave Kirk, Steve Revill and Shane Woolcock
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#End

Strict
Import mojo

Class FileSystem Extends DataConversion
'Private
	Field delimiter:String
	Field _header:String = "MKYDATA"
	Field fileData:String
	Field index:StringMap<FileStream>
'Public
	
	Function Create:FileSystem(delimiter:String = String.FromChar(9)) 'tab-delimited by default
		Local t:FileSystem = New FileSystem
		t.delimiter = delimiter
		t.LoadAll()
		Return t
	End
	
	Method WriteFile:FileStream(filename:String)
		Local f:FileStream = new FileStream
		f.filename = filename.ToLower()
		f.ptr = 0
		f.delimiter = Self.delimiter
		Self.index.Insert(f.filename.ToLower(),f)
		Return f	
	End
	
	Method ReadFile:FileStream(filename:String)
		filename = filename.ToLower()
		
		' Check existence
		if Not Self.index.Contains(filename) Then Return Null
		
		Local f:FileStream
		f = Self.index.ValueForKey(filename)
		f.ptr = 0
		f.arr = f.data.Split(f.delimiter)
		Return f
	End
	
	Method FileExists:Bool(filename:String)
		filename = filename.ToLower()
		if Self.index.Contains(filename)
			Return True
		Else
			Return False
		End
		Return False
	End
	
	Method ListDir:Void()
		Local filename:String
		Local stream:FileStream
		Print "Directory Listing:"
		For filename = EachIn Self.index.Keys()
			stream = Self.index.ValueForKey(filename)
			Print filename + "   " + stream.data.Length()+" byte(s)."
		Next
	End
	
	Method DeleteFile:Void(filename:String)
		filename = filename.ToLower()
		if Self.index.Contains(filename)
			Self.index.Remove(filename)
		End
	End
	
	Method SaveAll:Void()
		Local f:FileStream
		Self.fileData = Self._header'header
		Self.fileData+= Self.delimiter
		self.fileData+= Self.IntToString(Self.index.Count())'number of files in index
		if Self.index.Count() > 0
			For f = EachIn Self.index.Values()
				'store filename
				Self.fileData+=Self.delimiter
				Self.fileData+= f.filename
				'store data
				Self.fileData+=Self.delimiter
				Self.fileData+= Self.IntToString(f.numElements)
				if f.numElements > 0
					Self.fileData+=Self.delimiter
					Self.fileData+=f.data
				End
			Next
		End
		SaveState(Self.fileData)
	End
	
	Method LoadAll:Void()
		Local numFiles:Int
		Local numElements:Int
		Local stream:FileStream
		Local len:Int
		Local ptr:Int
		Local elementCounter:Int
		Local arr:String[]
		Self.fileData = LoadState()
		self.index = New StringMap<FileStream>
		if Self.fileData.Length() > 0
			arr = Self.fileData.Split(Self.delimiter)
			if arr[ptr] = Self._header
				Self.index.Clear()
				ptr+=1
				numFiles = Self.StringToInt(arr[ptr])
				ptr+=1
				if numFiles > 0				
					For Local n:Int = 1 to numFiles
						stream = New FileStream
						'filename
						stream.delimiter = Self.delimiter
						stream.filename = arr[ptr] ; ptr+=1
						'data
						stream.numElements = Int(arr[ptr]) ; ptr+=1
						if stream.numElements > 0
							elementCounter = 0
							Repeat
								stream.data+=arr[ptr]
								elementCounter+=1
								if elementCounter < stream.numElements
									stream.data+=Self.delimiter
								EndIf
								ptr+=1
							Until elementCounter = stream.numElements
						End
						Self.index.Insert(stream.filename,stream)
					Next
				End
			End
		Else
			SaveState("")'save empty file and indicate no files stored
		End
	End
End



Class FileStream Extends DataConversion
	Field filename:String
	Field ptr:Int
'Private
	Field data:String
	Field arr:String[]
	Field delimiter:String
	Field numElements:Int
	Field errStr:String
'Public

	Method HadError:Bool()
		Return errStr.Length() > 0
	End
	
	Method GetLastError:String()
		Return errStr
	End

	Method AtEOF:Bool()
		Return Self.ptr >= Self.arr.Length()
	End
	
	Method ReadInt:Int()
		Local result:Int
		if Self.ptr >= Self.arr.Length()
			Self.EofError()
			Return 0
		EndIf

		result = Int(Self.arr[Self.ptr])
		Self.ptr+=1
		Return result
	End
	
	Method WriteInt:Void(val:Int)
		If Self.data.Length() > 0
			Self.data+=Self.delimiter
		EndIf
		Self.data+=Self.IntToString(val)
		Self.numElements+=1
	End
	
	Method ReadString:String()
		Local result:String
		if Self.ptr >= Self.arr.Length()
			Self.EofError()
			Return ""
		EndIf
		result = Self.arr[Self.ptr]
		Self.ptr+=1
		Return result
	End
	
	Method WriteString:Void(val:String)
		If Self.data.Length() > 0
			Self.data+=Self.delimiter
		EndIf
		Self.data+=val
		Self.numElements+=1		
	End
	
	Method ReadFloat:Float()
		Local result:float
		if Self.ptr >= Self.arr.Length()
			Self.EofError()
			Return 0.0
		EndIf

		result = Float(Self.arr[Self.ptr])
		Self.ptr+=1
		Return result
	End
	
	Method WriteFloat:Void(val:Float)
		Local s:String = self.FloatToString(val)
		If Self.data.Length() > 0
			Self.data+=Self.delimiter
		EndIf
		Self.data+=s
		Self.numElements+=1
	End
	
	Method ReadBool:Bool()
		Local result:Bool
		if Self.ptr >= Self.arr.Length()
			Self.EofError()
			Return False
		EndIf

		if Self.arr[Self.ptr] = "0"
			result = False
		Else
			result = True
		EndIf
		
		Self.ptr+=1
		Return result
	End Method
	
	Method WriteBool:Void(val:Bool)
		Local txt:String
		If Self.data.Length() > 0
			Self.data+=Self.delimiter
		EndIf
		If val
			txt = "1"
		Else
			txt = "0"
		EndIf
		Self.data+=txt
		Self.numElements+=1
	End Method
	
	Method EofError:Void()
		errStr = "End of file: " + Self.filename
		
		#If CONFIG="debug"
    	' how can we recover from an error if you stop the program?
			Print errStr
		#End
	End Method
End

Class DataConversion
	Method LittleEndianIntToString:String(val:Int)
		Local result:String
		result = String.FromChar((val) & $FF)
		result+= String.FromChar((val Shr 8) & $FF)
		result+= String.FromChar((val Shr 16) & $FF)
		result+= String.FromChar((val Shr 24) & $FF)
		Return result
	End

	Method StringToLittleEndianInt:Int(val:String)
		Local result:Int
		result = (val[0])
		result|= (val[1] Shl 8)
		result|= (val[2] Shl 16)
		result|= (val[3] Shl 24)
		Return result
	End	
	
    Method IntToString:String(val:Int)
		Return String(val)
    End
        
    Method StringToInt:Int(val:String)
		Return Int(val)
    End


	Method FloatToString:String(val:Float)
		Return String(val)
	End		
	
	Method StringToFloat:Float(val:String)
		Return Float(val)
	End		
End