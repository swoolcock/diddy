
Import target

Class BmaxTarget Extends Target

	Function IsValid()
		Print "IsValid bmx"
		Print FileType( "bmax" )
		Print FILETYPE_DIR
		Print "BMAX_PATH = "+BMAX_PATH
		'If BMAX_PATH Return True
		If FileType( "bmax" )<>FILETYPE_DIR Return False
		Return True
	End

	Method Begin()
		ENV_TARGET="bmax"
		ENV_LANG="bmx"
		_trans=New BmxTranslator
	End
	
	Method MakeTarget()
	
		'app data
		CreateDataDir ("data", false)

		Local meta$="var META_DATA=~q"+metaData+"~q;~n"
		
		'app code
		Local main$=LoadString( "MonkeyGame.bmx" )
		
		main=ReplaceBlock( main,"${TRANSCODE_BEGIN}","${TRANSCODE_END}",transCode )
		
		SaveString main,"MonkeyGame.bmx"
		
		If OPT_BUILD
		
			Select ENV_CONFIG
				Case "release"
					Execute BMAX_PATH+" makeapp -r MonkeyGame.bmx"
				Case "debug"
					Execute BMAX_PATH+" makeapp -d MonkeyGame.bmx"
			End

			If OPT_RUN
				Execute "MonkeyGame.exe",False
			Endif
		Endif
	End
	
End
