#Rem
Copyright (c) 2011 Steve Revill and Shane Woolcock
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#End

#Rem
Header: The main module for Diddy.
Diddy includes various features:
* External functions
* Screen Based Framework
* Input Cache
* Tweening
* Collections
* Assertions
* Skinned GUI
* Simple GUI
* Serialization
* XML Parser
* Base64 Encoding/Decoding
* IO
* Tiled Loader
* Filesystem Wrapper
* i18n
* Particle System
* String Builder
* Storyboarding
* Vector2d
#End
Import mojo

Import diddy.arrays
Import diddy.assert
Import diddy.base64
Import diddy.collections
Import diddy.constants
Import diddy.containers
Import diddy.diddydata
Import diddy.diddylist
Import diddy.diddypool
Import diddy.diddyset
Import diddy.diddystack
Import diddy.exception
Import diddy.externfunctions
Import diddy.filesystem
Import diddy.font
Import diddy.format
Import diddy.framework
Import diddy.functions
Import diddy.globalpool
Import diddy.gui
Import diddy.i18n
Import diddy.inputcache
Import diddy.io
Import diddy.math
Import diddy.matrix3d
Import diddy.pathFind
Import diddy.psystem
Import diddy.quicksort
Import diddy.serialization
Import diddy.simplegui
Import diddy.singleton
Import diddy.storyboard
Import diddy.stringbuilder
Import diddy.tile
Import diddy.tween
Import diddy.vector2d
Import diddy.xml

#Rem
Summary: The name constant contains the library's name, "Diddy".
#End
Const name:String = "Diddy"
