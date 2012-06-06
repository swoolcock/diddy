
' Module mojo.mojo
'
' Copyright 2011 Mark Sibly, all rights reserved.
' No warranty implied; use at your own risk.

'#If TARGET<>"html5" And TARGET<>"flash" And TARGET<>"glfw" And TARGET<>"xna" And TARGET<>"ios" And TARGET<>"android" And TARGET<>"pss" And TARGET<>"bmax"
'#Error "Mojo is not currently available for target '${TARGET}'."
'#End

#If TARGET="stdcpp"
#Error "Mojo is not currently available for target '${TARGET}'."
#End

Import app
Import audio
Import graphics
Import input
