#Rem
Copyright (c) 2011 Steve Revill and Shane Woolcock
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#End

#Rem
Monkey threading module:
N/A = not applicable (don't need it)
N/S = not supported (can't do it natively)
TODO = not yet implemented (can do it, but not yet coded)
Yes = finished

Implemented: MonkeyMax  GLFW  stdcpp  Android  iOS  Flash  WinRT  HTML5  XNA
Thread
.Start()     Yes        Yes   Yes     Yes      Yes  N/S    TODO   N/S    Yes
.Cancel()    TODO       TODO  TODO    Yes      TODO N/S    TODO   N/S    TODO
.Join()      Yes        Yes   Yes     Yes      Yes  N/S    TODO   N/S    TODO

Mutex
.Lock()      Yes        Yes   Yes     Yes      Yes  N/S    TODO   N/S    Yes
.TryLock()   Yes        Yes   Yes     Yes      Yes  N/S    TODO   N/S    Yes
.Unlock()    Yes        Yes   Yes     Yes      Yes  N/S    TODO   N/S    Yes

CondVar
.Wait()      Yes        Yes   Yes     Yes      Yes  N/S    TODO   N/S    Yes
.TimedWait() N/S        N/S   N/S     Yes      N/S  N/S    TODO   N/S    Yes
.Signal()    Yes        Yes   Yes     Yes      Yes  N/S    TODO   N/S    Yes
.Broadcast() Yes        Yes   Yes     Yes      Yes  N/S    TODO   N/S    Yes

Note that some features are not available on all targets.  I may try to find a workaround for these.

MonkeyMax requires a manual call to bmk.exe to add the -h flag.
C++ targets (GLFW, stdcpp, iOS, WinRT) require the TinyThread++ header files to be copied to the build directory.
Flash does not support any kind of multithreading.
HTML5 "threading" would have to use a hack of web workers, and I'm not sure if I could even get it to work.  Marking as N/S.
XNA is partially implemented using a stripped version of Spring.Threading.
Android and XNA mutexes are reentrant, for now.  Be aware of this!

Tested targets:
stdcpp (Windows)
MonkeyMax (Windows)
GLFW (Windows and MacOSX)
iOS
Android
XNA

Stripped Spring.Threading taken from netconcurrent Google Code project:
https://code.google.com/p/netconcurrent/

C# currently requires a hack to trans to move the "using" statements to the top of the file in the same way it handles Java's imports.
Hack is forthcoming.

Be aware that the developer of Monkey (Mark Sibly) has expressed concerns that true multithreading may affect Monkey's garbage collection.

#End

' Check the availability of threading for the target
#If TARGET <> "ios" And TARGET <> "stdcpp" And TARGET <> "glfw" And TARGET <> "android" And TARGET <> "bmax" And TARGET <> "xna" Then
#Error "Threading is not yet supported for target '${TARGET}'."
#End

Import thread
Import coroutine
