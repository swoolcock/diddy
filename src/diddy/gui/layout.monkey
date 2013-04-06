#Rem
Copyright (c) 2011 Steve Revill and Shane Woolcock
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#End

Strict

Import core

Interface ILayoutManager
	Method LayoutMinimum:Point(parent:Component, point:Point=Null)
	Method Layout:Point(parent:Component, point:Point=Null)
End

Interface ILayoutData
End

' Based on SWT GridLayout
Class GridLayout Implements ILayoutManager
Private
' Private Constants
	Const DYNAMIC_MAX:Int = 100
	
' Private fields

	Field columns:Int
	Field rows:Int
	Field calculatedRows:Int
	Field calculatedColumns:Int	
	
	' cached stuff
	Field compArray:Object[] = []
	Field rowNums:Int[] = []
	Field colNums:Int[] = []
	Field cellTaken:Bool[] = []
	
Public
' Public constants

	Const FILLTYPE_FILL:Int = 0
	Const FILLTYPE_PREFERRED:Int = 1
	Const FILLTYPE_STATIC:Int = 2
	
	Const DEFAULT_HORIZONTAL_MARGIN:Int = 5
	Const DEFAULT_VERTICAL_MARGIN:Int = 5
	Const DEFAULT_HORIZONTAL_SPACING:Int = 5
	Const DEFAULT_VERTICAL_SPACING:Int = 5
	
' Public fields

	Field colWidthTypes:Int[]
	Field rowHeightTypes:Int[]
	Field colWidthValues:Int[]
	Field rowHeightValues:Int[]
	
	Field leftMargin:Int
	Field rightMargin:Int
	Field topMargin:Int
	Field bottomMargin:Int
	Field horizontalSpacing:Int
	Field verticalSpacing:Int
	
' Constructors

	Method New(rows:Int=0, columns:Int=1,
			leftMargin:Int=DEFAULT_HORIZONTAL_MARGIN, rightMargin:Int=DEFAULT_HORIZONTAL_MARGIN,
			topMargin:Int=DEFAULT_VERTICAL_MARGIN, bottomMargin:Int=DEFAULT_VERTICAL_MARGIN,
			horizontalSpacing:Int=DEFAULT_HORIZONTAL_SPACING, verticalSpacing:Int=DEFAULT_VERTICAL_SPACING)
		If rows <= 0 And columns <= 0 Then AssertError("Only one of rows/columns may be dynamic.")
		Self.rows = rows
		Self.columns = columns
		Self.leftMargin = leftMargin
		Self.rightMargin = rightMargin
		Self.topMargin = topMargin
		Self.bottomMargin = bottomMargin
		Self.horizontalSpacing = horizontalSpacing
		Self.verticalSpacing = verticalSpacing
		
		If rows = 0 Then
			rowHeightTypes = New Int[DYNAMIC_MAX]
			rowHeightValues = New Int[DYNAMIC_MAX]
		Else
			rowHeightTypes = New Int[rows]
			rowHeightValues = New Int[rows]
		End
		
		If columns = 0 Then
			colWidthTypes = New Int[DYNAMIC_MAX]
			colWidthValues = New Int[DYNAMIC_MAX]
		Else
			colWidthTypes = New Int[columns]
			colWidthValues = New Int[columns]
		End
		
		For Local i:Int = 0 Until rowHeightValues.Length
			rowHeightValues[i] = -1
			rowHeightTypes[i] = FILLTYPE_FILL
		Next
		
		For Local i:Int = 0 Until colWidthValues.Length
			colWidthValues[i] = -1
			colWidthTypes[i] = FILLTYPE_FILL
		Next
	End
	
' Implements ILayoutManager

	Method Layout:Point(parent:Component, point:Point=Null)
		Return LayoutDelegate(parent, False, point)
	End
	
	Method LayoutMinimum:Point(parent:Component, point:Point=Null)
		Return LayoutDelegate(parent, True, point)
	End
	
Private
' Private methods
	Method LayoutDelegate:Point(parent:Component, calculateMinimum:Bool, point:Point=Null)
		' get the children (reuse the array)
		Local compCount:Int = 0
		If compArray.Length < parent.Children.Size Then
			compArray = parent.Children.ToArray()
			compCount = compArray.Length
		Else
			compCount = parent.Children.FillArray(compArray)
		End

		' create or clear rowNums array
		If rowNums.Length < compCount Then rowNums = New Int[compCount]
		For Local i:Int = 0 Until rowNums.Length
			rowNums[i] = 0
		Next

		' create or clear colNums array
		If colNums.Length < compCount Then colNums = New Int[compCount]
		For Local i:Int = 0 Until colNums.Length
			colNums[i] = 0
		Next

		' create or clear cellTaken array
		Local cellTakenCols:Int = columns
		Local cellTakenRows:Int = rows
		If cellTakenCols = 0 Then cellTakenCols = DYNAMIC_MAX
		If cellTakenRows = 0 Then cellTakenRows = DYNAMIC_MAX
		If cellTaken.Length < cellTakenCols*cellTakenRows Then cellTaken = New Bool[cellTakenCols*cellTakenRows]
		For Local i:Int = 0 Until cellTaken.Length
			cellTaken[i] = False
		Next

		' loop on components
		Local currentRow:Int = 0, currentColumn:Int = 0
		Local maxRow:Int = rows - 1, maxColumn:Int = columns - 1
		Local colSpan:Int = 1, rowSpan:Int = 1
		For Local i:Int = 0 Until compCount
			' get the data object
			Local data:GridData = Null
			If GridData(Component(compArray[i]).LayoutData) <> Null Then
				data = GridData(Component(compArray[i]).LayoutData)
				colSpan = data.colSpan
				rowSpan = data.rowSpan
			Else
				colSpan = 1
				rowSpan = 1
			End
			
			' reset current row/col to last found spot
			If i > 0 Then
				currentRow = rowNums[i-1]
				currentColumn = colNums[i-1]
			End
			
			' find the next available spot
			If cellTaken[currentColumn+currentRow*cellTakenCols] Then
				Repeat
					' if columns are dynamic, top to bottom then left to right
					If columns <= 0 Then
						currentRow += 1
						If currentRow >= rows Then
							currentRow = 0
							currentColumn += 1
							maxColumn = Max(maxColumn,currentColumn)
						End
					' if rows are dynamic, or the grid is fixed, left to right then top to bottom
					Else
						currentColumn += 1
						If currentColumn >= columns Then
							currentColumn = 0
							currentRow += 1
							maxRow = Max(maxRow,currentRow)
						End
					End
				Until Not cellTaken[currentColumn+currentRow*cellTakenCols]
			End
			' set the component's location to that
			rowNums[i] = currentRow
			colNums[i] = currentColumn
			If data <> Null Then
				data.startRow = currentRow
				data.startCol = currentColumn
			End
			
			' fill in the boolean array
			For Local fillCol:Int = currentColumn Until currentColumn + colSpan
				For Local fillRow:Int = currentRow Until currentRow + rowSpan
					cellTaken[fillCol + fillRow*cellTakenCols] = True
				Next
			Next
		Next
		
		' fix the dynamic one (if there is one)
		If maxRow < 0 Then maxRow = currentRow + rowSpan
		If maxColumn < 0 Then maxColumn = currentColumn + colSpan
		
		' store last
		calculatedRows = maxRow + 1
		calculatedColumns = maxColumn + 1
		
		' reset rows and columns marked as preferred
		For Local i:Int = 0 Until calculatedRows
			If rowHeightTypes[i] = FILLTYPE_PREFERRED Then rowHeightValues[i] = 0
		Next
		For Local i:Int = 0 Until calculatedColumns
			If colWidthTypes[i] = FILLTYPE_PREFERRED Then colWidthValues[i] = 0
		Next
		
		' now set the preferred sizes of each row and column based on component
		For Local i:Int = 0 Until compCount
			' get the data object
			Local data:GridData = Null
			If GridData(Component(compArray[i]).LayoutData) <> Null Then
				data = GridData(Component(compArray[i]).LayoutData)
				colSpan = data.colSpan
				rowSpan = data.rowSpan
			Else
				colSpan = 1
				rowSpan = 1
			End
			
			' if the row for this component is preferred, store the max of the heights
			If rowHeightTypes[rowNums[i]] = FILLTYPE_PREFERRED Then
				' only continue if the component consumes a single row
				If rowSpan = 1 Then
					Local y:Int = Component(compArray[i]).PreferredHeight
					If y <= 0 Then y = Component(compArray[i]).MinimumHeight
					rowHeightValues[rowNums[i]] = Max(rowHeightValues[rowNums[i]], y)
				End
			End
			
			' if the column for this component is preferred, store the max of the widths
			If colWidthTypes[colNums[i]] = FILLTYPE_PREFERRED Then
				' only continue if the component consumes a single column
				If colSpan = 1 Then
					Local x:Int = Component(compArray[i]).PreferredWidth
					If x <= 0 Then x = Component(compArray[i]).MinimumWidth
					colWidthValues[colNums[i]] = Max(colWidthValues[colNums[i]], x)
				End
			End
		Next
		
		' calculate the available fill space
		Local colFillCount:Int = 0
		Local rowFillCount:Int = 0
		Local fillWidth:Int = parent.Width - leftMargin - rightMargin - horizontalSpacing * (calculatedColumns - 1)
		Local fillHeight:Int = parent.Height - topMargin - bottomMargin - verticalSpacing * (calculatedRows - 1)
		For Local i:Int = 0 Until calculatedColumns
			If colWidthTypes[i] = FILLTYPE_FILL Then
				colFillCount += 1
			Else
				fillWidth -= colWidthValues[i]
			End
		Next
		For Local i:Int = 0 Until calculatedRows
			If rowHeightTypes[i] = FILLTYPE_FILL Then
				rowFillCount += 1
			Else
				fillHeight -= rowHeightValues[i]
			End
		Next
		
		' set the fill sizes
		For Local i:Int = 0 Until calculatedColumns
			If colWidthTypes[i] = FILLTYPE_FILL Then
				If calculateMinimum Then colWidthValues[i] = 0 Else colWidthValues[i] = fillWidth / colFillCount
			End
		Next
		For Local i:Int = 0 Until calculatedRows
			If rowHeightTypes[i] = FILLTYPE_FILL Then
				If calculateMinimum Then rowHeightValues[i] = 0 Else rowHeightValues[i] = fillHeight / rowFillCount
			End
		Next
		
		' if not getting minimum, do the layout
		If Not calculateMinimum Then
			For Local i:Int = 0 Until compCount
				' get the data object
				Local data:GridData = Null
				If GridData(Component(compArray[i]).LayoutData) <> Null Then
					data = GridData(Component(compArray[i]).LayoutData)
					colSpan = data.colSpan
					rowSpan = data.rowSpan
				Else
					colSpan = 1
					rowSpan = 1
				End
				
				Local x:Int = leftMargin
				Local y:Int = topMargin
				For Local j:Int = 0 Until colNums[i]
					x += colWidthValues[j] + horizontalSpacing
				Next
				For Local j:Int = 0 Until rowNums[i]
					y += rowHeightValues[j] + verticalSpacing
				Next
				
				Local width:Int = colWidthValues[colNums[i]]
				Local height:Int = rowHeightValues[rowNums[i]]
				For Local j:Int = 1 Until colSpan
					AssertLessThanInt(i, colNums.Length)
					AssertLessThanInt(colNums[i]+j, colWidthValues.Length)
					width += colWidthValues[colNums[i]+j] + horizontalSpacing
				Next
				For Local j:Int = 1 Until rowSpan
					AssertLessThanInt(i, rowNums.Length)
					AssertLessThanInt(rowNums[i]+j, rowHeightValues.Length)
					height += rowHeightValues[rowNums[i]+j] + verticalSpacing
				Next
				
				Component(compArray[i]).SetBounds(x, y, width, height)
			Next
		End
		
		' calculate the total size of the laid-out container
		If point = Null Then point = New Point
		For Local i:Int = 0 Until calculatedColumns
			If i = 0 Then point.x = leftMargin Else point.x += horizontalSpacing
			point.x += colWidthValues[i]
		Next
		point.x += rightMargin
		
		For Local i:Int = 0 Until calculatedRows
			If i = 0 Then point.y = topMargin Else point.y += verticalSpacing
			point.y += rowHeightValues[i]
		Next
		point.y += bottomMargin
		
		For Local i:Int = 0 Until compArray.Length
			compArray[i] = Null
		Next
		
		Return point
	End
End ' Class GridLayout

Class GridData Implements ILayoutData
Public
' Public fields

	Field startRow:Int = -1
	Field startCol:Int = -1
	Field rowSpan:Int = 1
	Field colSpan:Int = 1
	Field topBorder:Int = 0
	Field bottomBorder:Int = 0
	Field leftBorder:Int = 0
	Field rightBorder:Int = 0
	
' Constructors

	Method New(rowSpan:Int=1,colSpan:Int=1, border:Int=0)
		Self.rowSpan = rowSpan
		Self.colSpan = colSpan
		Self.topBorder = border
		Self.bottomBorder = border
		Self.leftBorder = border
		Self.rightBorder = border
	End
End ' Class GridData
