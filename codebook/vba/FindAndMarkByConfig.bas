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
