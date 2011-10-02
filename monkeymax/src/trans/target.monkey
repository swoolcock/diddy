
Import trans.trans

'from config file
Global ANDROID_PATH$
Global ANT_PATH$
Global JDK_PATH$
Global FLEX_PATH$
Global MINGW_PATH$
Global MSBUILD_PATH$
Global HTML_PLAYER$
Global FLASH_PLAYER$
Global BMAX_PATH$

'from trans options
Global OPT_CLEAN=False
Global OPT_UPDATE=False
Global OPT_BUILD=False
Global OPT_RUN=False
Global OPT_OUTPUT$
Global CASED_CONFIG$="Debug"

Class Target

	Method Make( path$ )
		Begin
		SetSourcePath path
		Translate
		CreateTargetDir
		Local cd$=CurrentDir
		ChangeDir targetPath
		MakeTarget
		ChangeDir cd
	End
	
'***** Protected *****
	
	Field srcPath$		'Main .monkey file
	Field dataPath$		'The app .data dir
	Field buildPath$	'The app .build dir
	Field targetPath$	'The app .build/target dir
	
	Field metaData$		'meta data string created by CreateDataDir
	Field textFiles$	'text files string create by CreateDataDir
	
	Field app:AppDecl	'The app
	Field transCode$	'translated output code

	Method Begin() Abstract
	
	Method MakeTarget() Abstract

	Method SetSourcePath( path$ )
		srcPath=path
		dataPath=StripExt( srcPath )+".data"
		buildPath=StripExt( srcPath )+".build"
		targetPath=buildPath+"/"+ENV_TARGET
	End
	
	Method AddTransCode( tcode$ )
		If transCode.Contains( "${CODE}" )
			transCode=transCode.Replace( "${CODE}",tcode )
		Else
			transCode+=tcode
		Endif
	End
	
	Method Translate()

		Print "Parsing..."
	
		app=parser.ParseApp( srcPath )

		Print "Semanting..."
		
		app.Semant
		
		Print "Translating..."

		For Local file$=Eachin app.fileImports
			If ExtractExt( file ).ToLower()=ENV_LANG
				AddTransCode LoadString( file )
			Endif
		Next

		AddTransCode _trans.TransApp( app )
		
		transCode=_trans.PostProcess( transCode )
		
		Print "Building..."
	End
	
	Method ImportedFiles:StringList( exts$[] )
		Local files:=New StringList	
		
		For Local file$=Eachin app.fileImports
			Local ext$=ExtractExt( file ).ToLower()
			For Local t$=Eachin exts
				If t=ext
					files.AddLast file
					Exit
				Endif
			Next
		Next
		
		Return files
	End

	'create '.build/target' directory and copy in project template
	'
	Method CreateTargetDir()

		If OPT_CLEAN
			DeleteDir targetPath,True
			If FileType( targetPath )<>FILETYPE_NONE Die "Failed to clean target dir"
		Endif

		If FileType( targetPath )=FILETYPE_NONE
			If FileType( buildPath )=FILETYPE_NONE CreateDir buildPath
			If FileType( buildPath )<>FILETYPE_DIR Die "Failed to create build dir: "+buildPath
			If Not CopyDir( ExtractDir( AppPath )+"/../targets/"+ENV_TARGET,targetPath,True,False ) Die "Failed to copy target dir"
		Endif

		If FileType( targetPath )<>FILETYPE_DIR Die "Failed to create target dir: "+targetPath
	End

	'Copy files from '.data' directory to target content directory. Creates metaData$ and textFiles$ strings
	'
	'If embedTextFiles is false, textfiles are also copied, else textFiles$ string is created.
	'
	Method CreateDataDir( dir$,embedTextFiles?=True )
		dir=RealPath( dir )
		
		DeleteDir dir,True
		CreateDir dir

		If FileType( dataPath )=FILETYPE_DIR
			CopyDir dataPath,dir,True,False
		Endif
		
		For Local file$=Eachin app.fileImports
			Select ExtractExt( file ).ToLower()
			Case "txt","xml","json"
				If Not embedTextFiles 
					CopyFile file,dir+"/"+StripDir( file )
				Endif
				
			'graphic file formats
			Case "png","jpg","bmp","wav","mp3","ogg"

				CopyFile file,dir+"/"+StripDir( file )
				
			'audio file formats
			Case "wav","ogg","aac","m4a","mp4","aif","caf","mp3","wma"

				CopyFile file,dir+"/"+StripDir( file )

			End Select
		Next
		
		Local mfile$=ExtractDir( AppPath )+"/meta.txt",meta$
		Execute "~q"+ExtractDir( AppPath )+"/makemeta_"+HostOS+"~q ~q"+dir+"~q ~q"+mfile+"~q"
		
		metaData=LoadString( mfile )
		metaData=metaData.Replace( "~n","\n" )
		
		textFiles=""
		
		If Not embedTextFiles Return
		
		For Local f$=Eachin LoadDir( dir,True,False )

			Local p$=dir+"/"+f
			If FileType(p)<>FILETYPE_FILE Continue
			
			Local ext$=ExtractExt(p).ToLower()
			Select ext
			Case "txt","xml","json"
				Local text$=LoadString( p )
				If text.Length>1024
					Local bits:=New StringList
					While text.Length>1024
						bits.AddLast LangEnquote( text[..1024] )
						text=text[1024..]
					Wend
					bits.AddLast LangEnquote( text )
					If ENV_LANG="cpp"
						text=bits.Join( "~n" )
					Else
						text=bits.Join( "+~n" )
					Endif
				Else
					text=LangEnquote( text )
				Endif
				
				If ENV_LANG="java"
					textFiles+="~t~telse if( path.compareTo(~q"+f+"~q)==0 ) return "+text+";~n"
				Else
					textFiles+="~t~telse if( path=="+LangEnquote(f)+" ) return "+text+";~n"
				Endif

				DeleteFile p
			End
		Next

		textFiles+="~t~treturn "+LangEnquote( "" )+";~n"
		
	End

	'Execute a shell cmd
	'
	Method Execute( cmd$,failHard=True )
		Local r=os.Execute( cmd )
		If Not r Return True
		If failHard Die "TRANS Failed to execute '"+cmd+"', return code="+r
		Return False
	End

End

'***** Target utility functions *****

'outta here!
'
Function Die( msg$ )
	Print msg
	ExitApp -1
End

'Replace GetEnv tags in a string
'
Function ReplaceEnv$( str$ )
	Local i=0
	
	Repeat
		i=str.Find( "${",i )
		If i=-1 Return str
		Local e=str.Find( "}",i+2 )
		If e=-1 Return str

		Local v$=GetEnv( str[i+2..e]  )
		str=str[..i]+v+str[e+1..]
		i+=v.Length
	Forever
End

'Load a tag map from a file - simply a key/value map.
'
Function LoadTags:StringMap<StringObject>( path$ )
	Local tags:=New StringMap<StringObject>
	Local cfg$=LoadString( path )

	For Local line$=Eachin cfg.Split( "~n" )
		line=line.Trim()
		If Not line Or line.StartsWith( "'" ) Continue
		
		Local i=line.Find( "=" )
		If i=-1 Die "Error in config file, path="+path+", line="+line
		
		Local lhs$=line[..i].Trim()
		Local rhs$=line[i+1..].Trim()
		rhs=ReplaceEnv( rhs )
		tags.Set lhs,rhs
	Next
	Return tags
End

'Replace all tags in a string.
'
Function ReplaceTags$( str$,tags:StringMap<StringObject> )
	Local i
	Repeat
		i=str.Find( "${",i )
		If i=-1 Return str
		Local e=str.Find( "}",i+2 )
		If e=-1 Return str
		
		Local v:=tags.Get( str[i+2..e] )
		If v
			Local t$=v.ToString()
			str=str[..i]+t+str[e+1..]
			i+=t.Length
		Else
			i=e+1
		Endif
		
	Forever
End

'Replace block of lines starting with ${startTag} and ending with ${endTtag}, leaving tags in place.
'
Function ReplaceBlock$( text$,startTag$,endTag$,repText$ )

	'Find *first* start tag
	Local i=text.Find( startTag )
	If i=-1
		Die "Error modifying target file - can't find block start tag: "+startTag+". You may need to delete target .build directory."
'		If dieHard Fail "Error replacing block, can't find startTag: "+startTag
'		Return
	Endif
	i+=startTag.Length
	While i<text.Length And text[i-1]<>10
		i+=1
	Wend

	'Find *last* end tag
	Local i2=text.Find( endTag,i )
	If i2=-1
		Die "Error modifying target file - can't find block end tag: "+endTag+"."
	Endif
	Repeat
		Local i3=text.Find( endTag,i2+endTag.Length )
		If i3=-1 Exit
		i2=i3
	Forever
	While i2>0 And text[i2]<>10
		i2-=1
	Wend

	'replace text!
	Return text[..i]+repText+text[i2..]
End

'Replace a single tag in a file
'
Function ReplaceFileTag( path$,tag$,rep$ )
	Local str$=LoadString( path )
	str=str.Replace( tag,rep )
	SaveString str,path
End

'Replace all tags in a file.
'
Function ReplaceFileTags( path$,tags:StringMap<StringObject> )
	Local str$=LoadString( path )
	str=ReplaceTags( str,tags )
	SaveString str,path
End

'Replace a block in a file.
'
Function ReplaceFileBlock( path$,startTag$,endTag$,repText$ )
	Local str$=LoadString( path )
	str=ReplaceBlock( str,startTag,endTag,repText )
	SaveString str,path
End
