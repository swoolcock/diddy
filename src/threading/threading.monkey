#Rem
Monkey threading module:
N/A = not applicable (don't need it)
N/S = not supported (can't do it natively)
TODO = not yet implemented (can do it, but not yet coded)
Yes = finished

Implemented: MonkeyMax  GLFW  stdcpp  Android  iOS  Flash  HTML5  XNA
Thread
.Start()     Yes        Yes   Yes     Yes      Yes  N/S    TODO   TODO
.Cancel()    TODO       TODO  TODO    Yes      TODO N/S    TODO   TODO
.Join()      Yes        Yes   Yes     Yes      Yes  N/S    TODO   TODO

Mutex
.Lock()      Yes        Yes   Yes     Yes      Yes  N/S    TODO   TODO
.TryLock()   Yes        Yes   Yes     Yes      Yes  N/S    TODO   TODO
.Unlock()    Yes        Yes   Yes     Yes      Yes  N/S    TODO   TODO

CondVar
.Wait()      Yes        Yes   Yes     Yes      Yes  N/S    TODO   TODO
.TimedWait() N/S        N/S   N/S     Yes      N/S  N/S    TODO   TODO
.Signal()    Yes        Yes   Yes     Yes      Yes  N/S    TODO   TODO
.Broadcast() Yes        Yes   Yes     Yes      Yes  N/S    TODO   TODO

Note that some features are not available on all targets.  I may try to find a workaround for these.

MonkeyMax requires a manual call to bmk.exe to add the -h flag.
C++ targets (GLFW, stdcpp, iOS) require the TinyThread++ header files to be copied to the build directory.
Flash does not support any kind of multithreading.
HTML5 supports multithreading using web workers, but I need to read up on them more.
XNA is not yet implemented because I need to read up on .NET threads.
Android mutexes are reentrant, for now.  Be aware of this!

Tested targets:
MonkeyMax (Windows)
GLFW (Windows and MacOSX)
iOS
Android
#End

' Check the availability of threading for the target
#If TARGET <> "ios" And TARGET <> "stdcpp" And TARGET <> "glfw" And TARGET <> "android" And TARGET <> "bmax" Then
#Error "Threading is not yet supported for target '${TARGET}'."
#End

Import thread
Import coroutine
