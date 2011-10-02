
' stdcpp app 'trans' - driver program for the Monkey translator.
'
' Placed into the public domain 24/02/2011.
' No warranty implied; use at your own risk.

Import targets

Const VERSION$="1.21"

Global CONFIG_FILE$

Function StripQuotes$( str$ )
	If str.StartsWith( "~q" ) And str.EndsWith( "~q" ) Return str[1..-1]
	Return str
End

Function LoadConfig()

	Local cfgpath$=ExtractDir( AppPath )+"/"
	If CONFIG_FILE
		cfgpath+=CONFIG_FILE
	Else
		cfgpath+="config."+HostOS+".txt"
	Endif
	
	If FileType( cfgpath )<>FILETYPE_FILE Die "Failed to open config file"

	Local cfg$=LoadString( cfgpath )
	
	For Local line$=Eachin cfg.Split( "~n" )
	
		line=line.Trim()
		If Not line Or line.StartsWith( "'" ) Continue
		
		Local i=line.Find( "=" )
		If i=-1 Die "Error in config file, line="+line
		
		Local lhs$=line[..i].Trim()
		Local rhs$=line[i+1..].Trim()
		
		rhs=ReplaceEnv( rhs )
		
		Local path$=StripQuotes( rhs )

		While path.EndsWith( "/" ) Or path.EndsWith( "\" )
			path=path[..-1]
		Wend
		
		Select lhs
		Case "ANDROID_PATH"
			If Not ANDROID_PATH And FileType( path )=FILETYPE_DIR
				ANDROID_PATH=path
			Endif
		Case "JDK_PATH" 
			If Not JDK_PATH And FileType( path )=FILETYPE_DIR
				JDK_PATH=path
			Endif
		Case "ANT_PATH"
			If Not ANT_PATH And FileType( path )=FILETYPE_DIR
				ANT_PATH=path
			Endif
		Case "FLEX_PATH"
			If Not FLEX_PATH And FileType( path )=FILETYPE_DIR
				FLEX_PATH=path
			Endif
		Case "MINGW_PATH"
			If Not MINGW_PATH And FileType( path )=FILETYPE_DIR
				MINGW_PATH=path
			Endif
		Case "MSBUILD_PATH"
			If Not MSBUILD_PATH And FileType( path )=FILETYPE_FILE
				MSBUILD_PATH=path
			Endif
		Case "HTML_PLAYER" 
			HTML_PLAYER=rhs
		Case "FLASH_PLAYER" 
			FLASH_PLAYER=rhs
		Case "BMAX_PATH"
			Print "BMAX_PATH"
			If Not BMAX_PATH
				Print "NOT BMAX_PATH"
			End
			Print "FileType( path )="+FileType( path )
			Print "FILETYPE_FILE    ="+FILETYPE_FILE
			Print "FILETYPE_DIR    ="+FILETYPE_DIR
			If Not BMAX_PATH And FileType( path )=FILETYPE_FILE
				BMAX_PATH=path
			Endif
		Default 
			Die "Unrecognized config var: "+lhs
		End

	Next
	
	Select HostOS
	Case "winnt"
		Local path$=GetEnv( "PATH" )
		
		If ANDROID_PATH path+=";"+ANDROID_PATH+"/tools"
		If ANDROID_PATH path+=";"+ANDROID_PATH+"/platform-tools"
		If JDK_PATH path+=";"+JDK_PATH+"/bin"
		If ANT_PATH path+=";"+ANT_PATH+"/bin"
		If FLEX_PATH path+=";"+FLEX_PATH+"/bin"
		If MINGW_PATH path+=";"+MINGW_PATH+"/bin"

		SetEnv "PATH",path
		
		If JDK_PATH SetEnv "JAVA_HOME",JDK_PATH

	Case "macos"
		Local path$=GetEnv( "PATH" )
		
		If ANDROID_PATH path+=":"+ANDROID_PATH+"/tools"
		If ANDROID_PATH path+=":"+ANDROID_PATH+"/platform-tools"
		If FLEX_PATH path+=":"+FLEX_PATH+"/bin"
		
		SetEnv "PATH",path
		
		'If Not HTML_PLAYER HTML_PLAYER="open "
		'If Not FLASH_PLAYER FLASH_PLAYER="open "
		
	End

	Return True
End

Function Main()

	Print "TRANS monkey compiler V"+VERSION
	
	For Local i=1 Until AppArgs.Length
		If AppArgs[i].ToLower().StartsWith( "-cfgfile=" )
			CONFIG_FILE=AppArgs[i][9..]
			Exit
		Endif
	Next
	
	SetEnv "TRANSDIR",ExtractDir( AppPath )

	LoadConfig
	
	Local valid$=ValidTargets()
	
	If AppArgs.Length<2 Or AppArgs.Length=2 And CONFIG_FILE
		Print "TRANS Usage: trans [-update] [-build] [-run] [-clean] [-config=...] [-target=...] [-cfgfile=...] [-modpath=...] <main_monkey_source_file>"
		Print "Valid targets: "+valid
		Print "Valid configs: debug release"
		If AppArgs.Length=1 ExitApp 0
		ExitApp -1
	Endif

	Local srcpath$=StripQuotes( AppArgs[AppArgs.Length-1].Trim() )
	If FileType( srcpath )<>FILETYPE_FILE Die "Invalid source file"
	srcpath=RealPath( srcpath )
	
	ENV_HOST=HostOS
	ENV_MODPATH=".;"+ExtractDir( srcpath )+";"+RealPath( ExtractDir( AppPath )+"/../modules" )

	Local target:Target

	For Local i=1 Until AppArgs.Length-1

		Local arg$=AppArgs[i].Trim()

		If Not arg.StartsWith( "-" )
			Die "Command line Die"
		Endif
		
		Local j=arg.Find( "=" )

		If j=-1
			Local lhs$=arg[1..]
			Select lhs.ToLower()
			Case "safe"
				ENV_SAFEMODE=True
			Case "clean"
				OPT_CLEAN=True
			Case "update"
				OPT_UPDATE=True
			Case "build"
				OPT_BUILD=True
			Case "run"
				OPT_RUN=True
			Default
				Die "Command line Die"
			End
		Else
			Local lhs$=arg[1..j].Trim()
			Local rhs$=arg[j+1..].Trim()
			Select lhs.ToLower()
			Case "cfgfile"
			Case "output"
				OPT_OUTPUT=rhs
			Case "config"
				Select rhs.ToLower()
				Case "debug"
					CASED_CONFIG="Debug"
				Case "release"
					CASED_CONFIG="Release"
				Case "profile"
					CASED_CONFIG="Profile"
				Default
					Die "Unrecognized config: "+rhs
				End
			Case "target"
				target=SelectTarget( rhs.ToLower() )
			Case "modpath"
				ENV_MODPATH=StripQuotes( rhs )
			Default
				Die "Command line Die"
			End
		Endif
	Next
	
	If Not target Die "No target specified"
	
	ENV_CONFIG=CASED_CONFIG.ToLower()
	
	CONFIG_DEBUG=(ENV_CONFIG="debug")
	CONFIG_RELEASE=(ENV_CONFIG="release")
	CONFIG_PROFILE=(ENV_CONFIG="profile")

	If OPT_RUN OPT_BUILD=True
	If OPT_BUILD OPT_UPDATE=True
	
	'Default to OPT_BUILD...
	If Not OPT_UPDATE
		OPT_UPDATE=True
		OPT_BUILD=True
	Endif
	
	target.Make srcpath

End
