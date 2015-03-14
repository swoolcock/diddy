# Introduction #

A first draft of the proposed Diddy coding standards.
Most of the files will need to be cleaned up to match it.
If you think it's stupid, let me know. :)

# Details #

Case:
  * Fields, local variables, and method/function parameters should be **camelCase**.
  * Class/interface names, methods, functions, and properties should be **PascalCase**.
  * Constants should be **UPPER\_CASE\_WITH\_UNDERSCORES**.
  * Monkey keywords should be **Capitalised**, with **EachIn** being **PascalCase**.

Keywords:
  * **For** should end with **Next**.
  * All other code blocks should end with **End**.

Declaration:
  * Never use primitive type shortcuts except in declaration of loops (**"For Local i%=0 To 5"** is more concise than **"For Local i:Int = 0 To 5"**)
  * Try to use zero-based **For** loops with the **Until** keyword wherever possible, unless it makes more sense to use one-based with **To**.
  * Try to keep most important fields private with public properties.
  * Never reference fields by properties from within the same module, unless the functionality is required.
  * Properties should be the same name as the field, but in **PascalCase**.
  * If you are paranoid about speed and it actually makes a big difference to have one less method call, you can make important fields public instead.

Class/Interface Structure Example:
```
Class Foo Extends Bar Implements IFocusListener, IActionListener Abstract
Public
' Public constants
  Const MY_PUBLIC_CONST:Int = 3
  
' Public global fields
  Global myPublicGlobal:Int = 7
  
Private
' Private constants
  Const MY_PRIVATE_CONST:Int = 4

' Private global fields
  Global myPrivateGlobal:Int = 0
  
' Private fields
  Field one:Int
  Field two:Int
  
' Private methods
  Method BarOne:Void()
    ' code
  End
  
  Method BarTwo:Void()
    ' code
  End
  
' Private functions
  Function MyPrivateFunction:Void()
    ' code
  End

Public
' Public fields
  Field pubOne:Int
  Field pubTwo:Int
  
' Properties
  ' One is read/write
  Method One:Int() Property
    Return one
  End
  Method One:Void(one:Int) Property
    Self.one = one
  End
  
  ' Two is read only
  Method Two:Int() Property
    Return two
  End
  
' Constructors
  Method New()
    ' code
  End
  
  Method New(one:Int, two:Int)
    Self.one = one
	Self.two = two
  End
  
' Implements IFocusListener
  Method FocusGained:Void(source:Component, oldFocus:Component)
    ' code
  End
  
  Method FocusLost:Void(source:Component, newFocus:Component)
    ' code
  End
  
' Implements IActionListener
  Method ActionPerformed:Void(source:Component, action:String)
    ' code
  End
  
' Overrides Bar
  Method OverriddenMethod:Void()
    ' code
  End
  
' Public methods
  Method MyMethod:Void()
    ' code
  End
  
' Abstract methods
  Method MyAbstractOne:Void() Abstract
  Method MyAbstractTwo:Void() Abstract
  Method MyAbstractThree:Void() Abstract
  
' Public functions
  Function MyPublicFunction:Void()
    ' code
  End
End ' Class Foo

Interface MyInterface
  Method One:Void()
  Method Two:Void()
  Method Three:Void()
End ' Interface MyInterface
```