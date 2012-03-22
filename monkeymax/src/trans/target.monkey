
Import trans.trans

Import reflection.reflector

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
Global OPT_ACTION
Global OPT_CLEAN
Global OPT_OUTPUT$
Global CASED_CONFIG$="Debug"

'from OPT_ACTION
Const ACTION_PARSE=1
Const ACTION_SEMANT=2
Const ACTION_TRANSLATE=3
Const ACTION_UPDATE=4
Const ACTION_BUILD=5
Const ACTION_RUN=6

Class Target

	Method Make( path$ )
	
		Begin
		
		srcPath=path
		
		Env.Set "HOST",ENV_HOST
		Env.Set "LANG",ENV_LANG
		Env.Set "TARGET",ENV_TARGET
		Env.Set "CONFIG",ENV_CONFIG
		
		Translate

		If OPT_ACTION>=ACTION_UPDATE
			Print "Building..."
		
			Local buildPath:=StripExt( srcPath )+".build"
			Local targetPath:=buildPath+"/"+ENV_TARGET

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

			Local cfgPath:=targetPath+"/CONFIG.TXT"
			If FileType( cfgPath )=FILETYPE_FILE LoadEnv cfgPath
			
			TEXT_FILES=Env.Get( "TEXT_FILES" )
			IMAGE_FILES=Env.Get( "IMAGE_FILES" )
			SOUND_FILES=Env.Get( "SOUND_FILES" )
			MUSIC_FILES=Env.Get( "MUSIC_FILES" )
			DATA_FILES=TEXT_FILES
			If IMAGE_FILES DATA_FILES+="|"+IMAGE_FILES
			If SOUND_FILES DATA_FILES+="|"+SOUND_FILES
			If MUSIC_FILES DATA_FILES+="|"+MUSIC_FILES
		
			Local cd:=CurrentDir

			ChangeDir targetPath
			
			MakeTarget
			
			ChangeDir cd
		Endif
	End
	
'***** Protected *****
	
	Field srcPath$		'Main .monkey file

	Field app:AppDecl	'The app
	Field transCode$	'translated output code
	
	'data file filters
	Field DATA_FILES$
	Field TEXT_FILES$
	Field IMAGE_FILES$
	Field SOUND_FILES$
	Field MUSIC_FILES$
	
	'actual data files
	'
	Field dataFiles:=New StringMap<String>	'maps real src path to virtual target path
	
	Method Begin() Abstract
	
	Method MakeTarget() Abstract

	Method AddTransCode( tcode$ )
		If transCode.Contains( "${CODE}" )
			transCode=transCode.Replace( "${CODE}",tcode )
		Else
			transCode+=tcode
		Endif
	End
	
	Method Translate()

		If OPT_ACTION>=ACTION_PARSE
			Print "Parsing..."
			
			app=parser.ParseApp( srcPath )
			
			If OPT_ACTION>=ACTION_SEMANT
				Print "Semanting..."
				
				If Env.Get("REFLECTION_FILTER")
					Local r:=New Reflector
					r.Semant app
				Else
					app.Semant
				Endif

				If OPT_ACTION>=ACTION_TRANSLATE
					Print "Translating..."
			
					For Local file$=Eachin app.fileImports
						If ExtractExt( file ).ToLower()=ENV_LANG
							AddTransCode LoadString( file )
						Endif
					Next
					
					AddTransCode _trans.TransApp( app )
					
				Endif
			Endif
		End
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

	Method CreateDataDir( dir$ )
		dir=RealPath( dir )
	
		DeleteDir dir,True
		CreateDir dir
		
		Local dataPath:=StripExt( srcPath )+".data"
		
		If FileType( dataPath )=FILETYPE_DIR
		
			Local srcs:=New StringStack
			srcs.Push dataPath
			
			While Not srcs.IsEmpty()
			
				Local src:=srcs.Pop()
				
				For Local f:=Eachin LoadDir( src )
					If f.StartsWith( "." ) Continue

					Local p:=src+"/"+f
					Local r:=p[dataPath.Length+1..]
					Local t:=dir+"/"+r
					
					Select FileType( p )
					Case FILETYPE_FILE
						If MatchPath( r,DATA_FILES )
							CopyFile p,t
							dataFiles.Set p,r
						Endif
					Case FILETYPE_DIR
						CreateDir t
						srcs.Push p
					End
				Next
			
			Wend
		
		Endif
		
		For Local p:=Eachin app.fileImports
			Local r:=StripDir( p )
			Local t:=dir+"/"+r
			If MatchPath( r,DATA_FILES )
				CopyFile p,t
				dataFiles.Set p,r
			Endif
		Next
		
	End
	
	'Execute a shell cmd
	'
	Method Execute( cmd$,failHard=True )
'		Print "Execute: "+cmd
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
	Print "TRANS FAILED: "+msg
	ExitApp -1
End

'Replace GetEnv tags in a string
'
Function ReplaceEnv$( str$ )

	Local bits:=New StringStack

	Repeat
	
		Local i=str.Find( "${" )
		If i=-1 Exit
		
		Local e=str.Find( "}",i+2 ) 
		If e=-1 Exit
		
		If i>=2 And str[i-2..i]="//"
			bits.Push str[..e+1]
			str=str[e+1..]
			Continue
		Endif
		
		Local t:=str[i+2..e]
		Local v:=Env.Get(t)
		If Not v v=GetEnv(t)
		v=v.Replace( "~q","" )
		
		bits.Push str[..i]
		bits.Push v
		
		str=str[e+1..]
	Forever
	
	If bits.IsEmpty() Return str
	
	bits.Push str
	
	Return bits.Join( "" )
	
End

'read a text file into env
'
Function LoadEnv( path$ )

	Local cfg$=LoadString( path )

	For Local line$=Eachin cfg.Split( "~n" )
	
		line=line.Trim()
		If Not line Or line.StartsWith( "'" ) Continue
		
		Local i=line.Find( "=" )
		If i=-1 Die "Error in config file, path="+path+", line="+line
		
		Local lhs$=line[..i].Trim()
		
		If Not Env.Contains( lhs )
			Local rhs$=line[i+1..].Trim()
			Env.Set lhs,ReplaceEnv( rhs )
		Endif
		
	Next
End

Function ReplaceBlock$( text$,tag$,repText$,mark$="~n//" )

	'find begin tag
	Local beginTag:=mark+"${"+tag+"_BEGIN}"

'	Print( "Trying to find " + beginTag + " in " + text )

	Local i=text.Find( beginTag )
	If i=-1 Die "Error updating target project - can't find block begin tag '"+tag+"'. You may need to delete target .build directory."
	i+=beginTag.Length
	While i<text.Length And text[i-1]<>10
		i+=1
	Wend
	
	'find end tag
	Local endTag:=mark+"${"+tag+"_END}"
	Local i2=text.Find( endTag,i-1 )
	If i2=-1 Die "Error updating target project - can't find block end tag '"+tag+"'."
	If Not repText Or repText[repText.Length-1]=10 i2+=1
	
	Return text[..i]+repText+text[i2..]

End

Function MatchPath?( text$,pattern$ )

	text="/"+text

	Local alts:=pattern.Split( "|" )

	For Local alt:=Eachin alts
	
		Local bits:=alt.Split( "*" )
		
		If bits.Length=1
			If bits[0]=text Return True
			Continue
		Endif
		
		If Not text.StartsWith( bits[0] ) Continue

		Local i:=bits[0].Length
		For Local j=1 Until bits.Length-1
			Local bit:=bits[j]
			i=text.Find( bit,i )
			If i=-1 Exit
			i+=bit.Length
		Next

		If i<>-1 And text[i..].EndsWith( bits[bits.Length-1] ) Return True
	Next

	Return False
End
