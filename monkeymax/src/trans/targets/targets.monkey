
Import target

Import html5
Import flash
Import android
Import glfw
Import xna
Import ios
Import stdcpp
Import bmax

Function ValidTargets$()

	Local valid:=New StringStack

	Local cd$=CurrentDir()
	ChangeDir ExtractDir( AppPath )+"/../targets"
	
	If Html5Target.IsValid() valid.Push "html5"
	If FlashTarget.IsValid() valid.Push "flash"
	If AndroidTarget.IsValid() valid.Push "android"
	If GlfwTarget.IsValid() valid.Push "glfw"
	If XnaTarget.IsValid() valid.Push "xna"
	If IosTarget.IsValid() valid.Push "ios"
	If StdcppTarget.IsValid() valid.Push "stdcpp"
	If BmaxTarget.IsValid() valid.Push "bmax"
	
	ChangeDir cd
	
	Return valid.Join( " " )
End

Function SelectTarget:Target( target$ )

	If Not (" "+ValidTargets()+" ").Contains( " "+target+" " ) Die "'"+target+"' is not a valid target."
	
	Select target
	Case "html5"
		Return New Html5Target
	Case "flash"
		Return New FlashTarget
	Case "android"
		Return New AndroidTarget
	Case "glfw"
		Return New GlfwTarget
	Case "xna"
		Return New XnaTarget
	Case "ios"
		Return New IosTarget
	Case "stdcpp"
		Return New StdcppTarget
	Case "bmax"
		Return New BmaxTarget
	Default
		Die "Unknown target '"+target+"'"
	End

End
