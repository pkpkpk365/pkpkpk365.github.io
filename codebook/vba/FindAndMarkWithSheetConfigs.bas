Sub FindAndMarkWithSheetConfigs()

    Dim wsName As Worksheet
    Dim wsTarget As Worksheet
    Dim i As Long, j As Long, k As Long
    Dim nameFirstRow As Long, nameLastRow As Long
    Dim nameCol As String
    Dim nameToFind As String
    
    Dim sheetConfigs As Variant
    Dim targetSheetName As String
    Dim searchCol As String
    Dim searchFirstRow As Long, searchLastRow As Long
    Dim resultCol As Long
    
    Dim oldValue As String
    
    '========================
    ' 1. 姓名来源表配置
    '========================
    Set wsName = ThisWorkbook.Sheets("Sheet1")
    
    nameCol = "A"          ' 姓名所在列
    nameFirstRow = 1       ' 姓名起始行
    nameLastRow = 100      ' 姓名结束行
    
    '========================
    ' 2. 目标Sheet配置
    ' 每一项格式：
    ' Array("Sheet名称", "查找列", 查找起始行, 查找结束行, 结果列号)
    ' 例如：
    ' Array("Sheet2", "B", 2, 1000, 3)
    ' 表示在 Sheet2 的 B2:B1000 查找，结果写入第3列(C列)
    '========================
    sheetConfigs = Array( _
        Array("Sheet2", "B", 2, 1000, 3), _
        Array("Sheet3", "D", 2, 800, 5), _
        Array("Sheet4", "F", 3, 1200, 7) _
    )
    
    '========================
    ' 3. 先清空各目标Sheet结果列
    '========================
    On Error GoTo SheetError
    
    For k = LBound(sheetConfigs) To UBound(sheetConfigs)
        targetSheetName = sheetConfigs(k)(0)
        searchFirstRow = sheetConfigs(k)(2)
        searchLastRow = sheetConfigs(k)(3)
        resultCol = sheetConfigs(k)(4)
        
        Set wsTarget = ThisWorkbook.Sheets(targetSheetName)
        
        wsTarget.Range(wsTarget.Cells(searchFirstRow, resultCol), _
                       wsTarget.Cells(searchLastRow, resultCol)).ClearContents
    Next k
    
    '========================
    ' 4. 开始查找并标记
    '========================
    For i = nameFirstRow To nameLastRow
        
        nameToFind = Trim(CStr(wsName.Cells(i, nameCol).Value))
        
        If nameToFind <> "" Then
            
            For k = LBound(sheetConfigs) To UBound(sheetConfigs)
                
                targetSheetName = sheetConfigs(k)(0)
                searchCol = sheetConfigs(k)(1)
                searchFirstRow = sheetConfigs(k)(2)
                searchLastRow = sheetConfigs(k)(3)
                resultCol = sheetConfigs(k)(4)
                
                Set wsTarget = ThisWorkbook.Sheets(targetSheetName)
                
                For j = searchFirstRow To searchLastRow
                    
                    If InStr(1, CStr(wsTarget.Cells(j, searchCol).Value), nameToFind, vbTextCompare) > 0 Then
                        
                        oldValue = Trim(CStr(wsTarget.Cells(j, resultCol).Value))
                        
                        ' 如果结果单元格为空，直接写入
                        If oldValue = "" Then
                            wsTarget.Cells(j, resultCol).Value = nameToFind
                        
                        ' 如果已有相同姓名，不重复追加
                        ElseIf InStr(1, "、" & oldValue & "、", "、" & nameToFind & "、", vbTextCompare) = 0 Then
                            wsTarget.Cells(j, resultCol).Value = oldValue & "、" & nameToFind
                        End If
                        
                    End If
                    
                Next j
                
            Next k
            
        End If
        
    Next i
    
    MsgBox "多Sheet查找并标记完成！", vbInformation
    Exit Sub

SheetError:
    MsgBox "发生错误，可能是目标Sheet名称写错了：" & vbCrLf & targetSheetName, vbExclamation

End Sub
