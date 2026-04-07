'============================================================
' 宏名称：FindAndMarkByConfig
' 功能说明：
'   根据“姓名表（Sheet1）”中的姓名，在多个工作表中进行查找，
'   并将匹配到的姓名写入对应的结果列。
'
'   支持：
'   1）多Sheet配置（通过Config表控制）
'   2）自动识别每个Sheet查找列的最后一行（无需手填结束行）
'   3）模糊匹配 / 精确匹配（可切换）
'   4）结果追加 / 覆盖（可切换）
'   5）跳过不存在的Sheet（防止报错中断）
'
'============================================================
' 一、使用步骤
'------------------------------------------------------------
' 1. 准备姓名表（默认：Sheet1）
'    - 姓名放在A列
'    - 从第1行开始
'
' 2. 新建一个工作表，命名为：Config
'
' 3. 在Config表中填写如下结构（从第1行开始）：
'
'    A列       B列       C列         D列       E列
'   ------------------------------------------------
'   Sheet名 | 查找列 | 查找起始行 | 结果列 | 是否启用
'
'   示例：
'   ------------------------------------------------
'   Sheet2 | B | 2 | C | 是
'   Sheet3 | D | 2 | E | 是
'   Sheet4 | F | 3 | G | 否
'
'   字段说明：
'   - Sheet名：要查找的工作表名称（必须存在）
'   - 查找列：在哪一列查找（如 B）
'   - 查找起始行：从哪一行开始（如 2）
'   - 结果列：匹配结果写入哪一列（如 C）
'   - 是否启用：写“是”才参与执行（支持：是 / Y / YES）
'
' 4. 运行宏：FindAndMarkByConfig
'
'============================================================
' 二、核心参数（代码中可修改）
'------------------------------------------------------------
' Set wsName = wb.Sheets("Sheet1")   ← 姓名来源表
' nameCol = "A"                      ← 姓名列
'
' matchMode = "FUZZY"
'   可选：
'   - "FUZZY"：模糊匹配（包含即匹配）
'   - "EXACT"：精确匹配（完全相同才匹配）
'
' writeMode = "APPEND"
'   可选：
'   - "APPEND"：追加（多个姓名会拼接：张三、李四）
'   - "OVERWRITE"：覆盖（后匹配覆盖前匹配）
'
' clearResultsFirst = True
'   - True：运行前清空结果列
'   - False：不清空，在原有基础上继续写
'
'============================================================
' 三、重要注意事项（务必看）
'------------------------------------------------------------
' 1. 模糊匹配风险：
'    查找“张三”时，会匹配：
'    - 张三丰
'    - 老张三组
'    如不希望误匹配，请使用 EXACT 模式
'
' 2. 精确匹配限制：
'    必须完全相同才匹配，例如：
'    - “张三 ”（带空格）→ 不匹配
'    - “张三（临时）” → 不匹配
'
' 3. 性能问题：
'    本代码为循环匹配：
'    姓名 × Sheet × 行
'    数据量较大时（如几千行 × 多Sheet）会变慢
'
' 4. 结果追加规则：
'    使用“、”作为分隔符去重
'    若手工写入使用其他符号（如逗号），可能失效
'
' 5. Config表错误：
'    - Sheet名写错 → 自动跳过
'    - 列字母写错 → 可能报错
'
'============================================================
' 四、适用场景
'------------------------------------------------------------
' ✔ 多个表结构不一致（列不同）
' ✔ 需要灵活开关不同Sheet
' ✔ 非技术人员通过Config即可控制
'
'============================================================
' 五、不适用场景（需要升级版本）
'------------------------------------------------------------
' ✘ 数据量特别大（建议改为数组版）
' ✘ 需要严格姓名识别（建议用正则/分词）
'
'============================================================
Option Explicit

Sub FindAndMarkByConfig()

    Dim wb As Workbook
    Dim wsName As Worksheet
    Dim wsConfig As Worksheet
    Dim wsTarget As Worksheet
    
    Dim nameCol As String
    Dim nameFirstRow As Long
    Dim nameLastRow As Long
    
    Dim configLastRow As Long
    Dim i As Long, j As Long, k As Long
    
    Dim targetSheetName As String
    Dim searchCol As String
    Dim resultCol As String
    Dim searchFirstRow As Long
    Dim searchLastRow As Long
    Dim enabledFlag As String
    
    Dim nameToFind As String
    Dim cellText As String
    Dim oldValue As String
    
    Dim matchMode As String      ' "FUZZY" 或 "EXACT"
    Dim writeMode As String      ' "APPEND" 或 "OVERWRITE"
    Dim clearResultsFirst As Boolean
    
    Dim matchedCount As Long
    Dim skippedSheetCount As Long
    Dim processedSheetCount As Long
    
    Set wb = ThisWorkbook
    
    '========================
    ' 1. 基础配置
    '========================
    Set wsName = wb.Sheets("Sheet1")     ' 姓名来源表
    Set wsConfig = wb.Sheets("Config")   ' 配置表
    
    nameCol = "A"                        ' 姓名列
    nameFirstRow = 1                     ' 姓名起始行
    nameLastRow = wsName.Cells(wsName.Rows.Count, nameCol).End(xlUp).Row   ' 自动识别姓名最后行
    
    '========================
    ' 2. 运行模式配置
    '========================
    matchMode = "FUZZY"          ' 可选：FUZZY=模糊匹配，EXACT=精确匹配
    writeMode = "APPEND"         ' 可选：APPEND=追加，OVERWRITE=覆盖
    clearResultsFirst = True     ' 是否先清空结果列
    
    '========================
    ' 3. 读取Config最后一行
    '========================
    configLastRow = wsConfig.Cells(wsConfig.Rows.Count, "A").End(xlUp).Row
    
    If configLastRow < 2 Then
        MsgBox "Config表没有可用配置。", vbExclamation
        Exit Sub
    End If
    
    Application.ScreenUpdating = False
    Application.Calculation = xlCalculationManual
    Application.EnableEvents = False
    
    On Error GoTo SafeExit
    
    '========================
    ' 4. 先清空结果列
    '========================
    If clearResultsFirst Then
        For k = 2 To configLastRow
            
            targetSheetName = Trim(CStr(wsConfig.Cells(k, "A").Value))
            searchCol = UCase(Trim(CStr(wsConfig.Cells(k, "B").Value)))
            searchFirstRow = Val(wsConfig.Cells(k, "C").Value)
            resultCol = UCase(Trim(CStr(wsConfig.Cells(k, "D").Value)))
            enabledFlag = Trim(CStr(wsConfig.Cells(k, "E").Value))
            
            If targetSheetName <> "" And searchCol <> "" And resultCol <> "" Then
                If enabledFlag = "" Or UCase(enabledFlag) = "是" Or UCase(enabledFlag) = "Y" Or UCase(enabledFlag) = "YES" Then
                    
                    If SheetExists(targetSheetName, wb) Then
                        Set wsTarget = wb.Sheets(targetSheetName)
                        
                        If searchFirstRow < 1 Then searchFirstRow = 1
                        
                        searchLastRow = wsTarget.Cells(wsTarget.Rows.Count, searchCol).End(xlUp).Row
                        If searchLastRow >= searchFirstRow Then
                            wsTarget.Range(resultCol & searchFirstRow & ":" & resultCol & searchLastRow).ClearContents
                        End If
                    End If
                    
                End If
            End If
        Next k
    End If
    
    '========================
    ' 5. 开始查找
    '========================
    For i = nameFirstRow To nameLastRow
        
        nameToFind = Trim(CStr(wsName.Cells(i, nameCol).Value))
        
        If nameToFind <> "" Then
            
            For k = 2 To configLastRow
                
                targetSheetName = Trim(CStr(wsConfig.Cells(k, "A").Value))
                searchCol = UCase(Trim(CStr(wsConfig.Cells(k, "B").Value)))
                searchFirstRow = Val(wsConfig.Cells(k, "C").Value)
                resultCol = UCase(Trim(CStr(wsConfig.Cells(k, "D").Value)))
                enabledFlag = Trim(CStr(wsConfig.Cells(k, "E").Value))
                
                If targetSheetName = "" Or searchCol = "" Or resultCol = "" Then
                    GoTo NextConfig
                End If
                
                If Not (enabledFlag = "" Or UCase(enabledFlag) = "是" Or UCase(enabledFlag) = "Y" Or UCase(enabledFlag) = "YES") Then
                    GoTo NextConfig
                End If
                
                If Not SheetExists(targetSheetName, wb) Then
                    skippedSheetCount = skippedSheetCount + 1
                    GoTo NextConfig
                End If
                
                Set wsTarget = wb.Sheets(targetSheetName)
                processedSheetCount = processedSheetCount + 1
                
                If searchFirstRow < 1 Then searchFirstRow = 1
                
                searchLastRow = wsTarget.Cells(wsTarget.Rows.Count, searchCol).End(xlUp).Row
                If searchLastRow < searchFirstRow Then GoTo NextConfig
                
                For j = searchFirstRow To searchLastRow
                    
                    cellText = Trim(CStr(wsTarget.Cells(j, searchCol).Value))
                    
                    If cellText <> "" Then
                        
                        If IsMatched(cellText, nameToFind, matchMode) Then
                            
                            If UCase(writeMode) = "OVERWRITE" Then
                                wsTarget.Cells(j, resultCol).Value = nameToFind
                            Else
                                oldValue = Trim(CStr(wsTarget.Cells(j, resultCol).Value))
                                
                                If oldValue = "" Then
                                    wsTarget.Cells(j, resultCol).Value = nameToFind
                                ElseIf Not ExistsInDelimitedText(oldValue, nameToFind, "、") Then
                                    wsTarget.Cells(j, resultCol).Value = oldValue & "、" & nameToFind
                                End If
                            End If
                            
                            matchedCount = matchedCount + 1
                        End If
                        
                    End If
                    
                Next j
                
NextConfig:
            Next k
            
        End If
        
    Next i
    
    MsgBox "处理完成！" & vbCrLf & _
           "姓名总行数：" & (nameLastRow - nameFirstRow + 1) & vbCrLf & _
           "配置行数：" & (configLastRow - 1) & vbCrLf & _
           "匹配次数：" & matchedCount & vbCrLf & _
           "跳过的不存在Sheet次数：" & skippedSheetCount, vbInformation

SafeExit:
    Application.ScreenUpdating = True
    Application.Calculation = xlCalculationAutomatic
    Application.EnableEvents = True

    If Err.Number <> 0 Then
        MsgBox "运行出错：" & vbCrLf & Err.Description, vbExclamation
    End If

End Sub


Private Function SheetExists(ByVal sheetName As String, ByVal wb As Workbook) As Boolean
    Dim ws As Worksheet
    On Error Resume Next
    Set ws = wb.Sheets(sheetName)
    SheetExists = Not ws Is Nothing
    Set ws = Nothing
    On Error GoTo 0
End Function


Private Function IsMatched(ByVal sourceText As String, ByVal keyword As String, ByVal matchMode As String) As Boolean
    
    Dim s1 As String
    Dim s2 As String
    
    s1 = Trim(CStr(sourceText))
    s2 = Trim(CStr(keyword))
    
    If s1 = "" Or s2 = "" Then
        IsMatched = False
        Exit Function
    End If
    
    Select Case UCase(matchMode)
        Case "EXACT"
            IsMatched = (StrComp(s1, s2, vbTextCompare) = 0)
        Case Else
            IsMatched = (InStr(1, s1, s2, vbTextCompare) > 0)
    End Select
    
End Function


Private Function ExistsInDelimitedText(ByVal fullText As String, ByVal oneItem As String, ByVal delimiter As String) As Boolean
    
    Dim wrappedFull As String
    Dim wrappedItem As String
    
    wrappedFull = delimiter & Trim(CStr(fullText)) & delimiter
    wrappedItem = delimiter & Trim(CStr(oneItem)) & delimiter
    
    ExistsInDelimitedText = (InStr(1, wrappedFull, wrappedItem, vbTextCompare) > 0)
    
End Function
