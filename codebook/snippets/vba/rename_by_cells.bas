Sub RenameWorkbookByCells()
    Dim bankName As String
    Dim personName As String
    Dim accountNo As String
    Dim newFileName As String
    Dim targetFolder As String

    bankName = Trim(Range("A3").Value)
    personName = Trim(Range("C3").Value)
    accountNo = Trim(Range("F3").Value)

    targetFolder = ThisWorkbook.Path & "\\Rename\\"
    If Dir(targetFolder, vbDirectory) = "" Then MkDir targetFolder

    newFileName = bankName & "_" & personName & "_" & accountNo & ".xlsx"

    ThisWorkbook.SaveCopyAs targetFolder & newFileName
    MsgBox "已生成：" & targetFolder & newFileName
End Sub
