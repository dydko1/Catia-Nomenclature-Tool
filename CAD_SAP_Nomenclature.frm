VERSION 5.00
Begin {C62A69F0-16DC-11CE-9E98-00AA00574A4F} CAD_SAP_Nomenclature 
   Caption         =   "JLR Part Naming Nomenclature"
   ClientHeight    =   3540
   ClientLeft      =   45
   ClientTop       =   390
   ClientWidth     =   7170
   OleObjectBlob   =   "CAD_SAP_Nomenclature.frx":0000
   StartUpPosition =   1  'CenterOwner
End
Attribute VB_Name = "CAD_SAP_Nomenclature"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit
Dim x As Boolean
Dim oExcel As Excel.Application
Dim oWorkBook As Excel.Workbook
Dim oWorkSheet As Excel.Worksheet
Dim sExcelFilePath As String ' , fileName As String ' numbers od workbooks
Dim sPrefix As String, sBasePart As String, sSuffix As String, sJLRNumber As String, sSign As String
Dim sBasePartDesc As String, sYear As String, sVehicle As String, sYearDesc As String, sVehicleDesc As String, sVehicleDescTmp As String
Dim sDRCode As String, sDRCodeDesc As String, s3DCatiaDesc As String, sDocumDesc As String, sMaterialDesc As String
Dim bButton As Boolean

' copy to cliboard
Private Declare Function OpenClipboard Lib "user32.dll" (ByVal hWnd As Long) As Long
Private Declare Function EmptyClipboard Lib "user32.dll" () As Long
Private Declare Function CloseClipboard Lib "user32.dll" () As Long
Private Declare Function IsClipboardFormatAvailable Lib "user32.dll" (ByVal wFormat As Long) As Long
Private Declare Function GetClipboardData Lib "user32.dll" (ByVal wFormat As Long) As Long
Private Declare Function SetClipboardData Lib "user32.dll" (ByVal wFormat As Long, ByVal hMem As Long) As Long
Private Declare Function GlobalAlloc Lib "kernel32.dll" (ByVal wFlags As Long, ByVal dwBytes As Long) As Long
Private Declare Function GlobalLock Lib "kernel32.dll" (ByVal hMem As Long) As Long
Private Declare Function GlobalUnlock Lib "kernel32.dll" (ByVal hMem As Long) As Long
Private Declare Function GlobalSize Lib "kernel32" (ByVal hMem As Long) As Long
Private Declare Function lstrcpy Lib "kernel32.dll" Alias "lstrcpyW" (ByVal lpString1 As Long, ByVal lpString2 As Long) As Long
' end clipboad

Public Function LoadSetings()
    'sExcelFilePath = "Path change below"
    'sExcelFilePath = "\\taryb060\DR6\06_Personal\Dyduch_Miroslaw\JLR Exhaust base numbers_TEN_EXAMPLE.xlsx"
    sExcelFilePath = "D:\\Nomenclature Sheet.xlsx"
End Function

Private Sub ComboBox1_Change()
    'sDocumDesc = sBasePartDesc
    'sVehicleDesc = sVehiclesFillCombo(sVehicleDesc)
    TextBox3.Value = VBA.Mid(MaterialDesc, 1, 40)
End Sub

Private Sub CommandButton1_Click()
    Frame2.Visible = True
    Frame3.Visible = True
    Frame4.Visible = True
    Frame5.Visible = True
    Frame7.Visible = True
    Frame8.Visible = True
    Frame10.Visible = False
    TextBox5.Visible = False
    bButton = True
    sJLRNumber = "" ' musi byc
    TextBox6.Value = "" ' Pole SAPa puste
    
    On Error Resume Next
        x = ExtractJLRNo(sExcelFilePath, oExcel, oWorkBook, oWorkSheet)
    If Err.Number <> 0 Then
        MsgBox "Maybe some cells in Excel is locked", vbCritical, "Please check  Excel"
        End ' przerywa kod
    End If
    On Error GoTo 0
End Sub

Private Sub CommandButton2_Click()
    Dim iSign As Integer
    TextBox5.Visible = True
    bButton = False
    sJLRNumber = "" ' musi by�
    TextBox6.Value = "" ' Pole SAPa puste
    iSign = 0
    
    If VBA.Len(TextBox5.Value) > 5 Then
        iSign = SignOccurrence(TextBox5.Value, "-")
    End If
    
    If (iSign >= 2) Then
        sJLRNumber = TextBox5.Value
        On Error Resume Next
            x = ExtractJLRNo(sExcelFilePath, oExcel, oWorkBook, oWorkSheet)
        If Err.Number <> 0 Then
            MsgBox "Maybe some cells in Excel is locked", vbCritical, "Please check  Excel"
            End ' przerywa kod
        End If
        On Error GoTo 0
        Frame2.Visible = True
        Frame3.Visible = True
        Frame4.Visible = True
        Frame5.Visible = True
        Frame7.Visible = True
        Frame8.Visible = True
        Frame10.Visible = False
    Else
        Frame2.Visible = False
        Frame3.Visible = False
        Frame4.Visible = False
        Frame5.Visible = False
        Frame7.Visible = False
        Frame8.Visible = False
        Frame10.Visible = False
    End If
    
End Sub

Private Sub CommandButton3_Click()
    GetParNumber (True)
End Sub

Private Sub CommandButton4_Click()
    If (Len(TextBox3.Value) > 5) Then
        SetClipboard (TextBox3.Value)
    End If
End Sub

Private Sub CommandButton5_Click()
    If (Len(TextBox2.Value) > 0) Then
        SetClipboard (TextBox2.Value)
    End If
End Sub

Private Sub CommandButton6_Click()
    Dim bExcelRun As Boolean
    Dim fileName As String
    fileName = GetFileName(sExcelFilePath)
    'Debug.Print ("2xxx " & oWorkBook)
    If (CheckBox1.Value) Then
        On Error Resume Next
        Set oExcel = GetObject(, "Excel.Application")
        Set oWorkBook = oExcel.Workbooks(fileName)
        oWorkBook.Close False, fileName
    End If
    ReleaseExcelObjects
    On Error GoTo 0
    Unload Me
End Sub

Private Sub CommandButton7_Click()
    If (Len(TextBox2.Value) > 0) Then
        CommandButton5_Click
        CATIA.StartCommand "cad-view"
    End If
End Sub

Private Sub CommandButton8_Click()
    If (Len(TextBox3.Value) > 0) Then
        CommandButton4_Click
        CATIA.StartCommand "cad-view"
    End If
End Sub

Private Sub CommandButton9_Click()
    MsgBox "Author.:" + vbTab + "Miroslaw Dyduch " & vbCrLf & "e-mail.:" + vbTab + "MDyduch@Tenneco.com", vbInformation, "Contact..."
End Sub

Private Sub TextBox1_Change()
    TextBox1.Value = VBA.UCase(TextBox1.Value)
End Sub

Private Sub TextBox2_Change()
    If (VBA.Len(TextBox2.Value) >= 40) Then
        MsgBox "Max document description 40 signs", vbInformation, "Log description"
    End If
    TextBox2.Value = VBA.UCase(TextBox2.Value)
End Sub

Private Sub TextBox3_Change()
    If (VBA.Len(TextBox3.Value) >= 40) Then
        MsgBox "Max meterial description 40 signs", vbInformation, "Log description"
    End If
    TextBox3.Value = VBA.UCase(TextBox3.Value)
End Sub

Private Sub TextBox4_Change()
    TextBox3.Value = MaterialDesc
End Sub

Private Sub TextBox5_Change()
    'Dim iSign As Integer
    'iSign = SignOccurrence(TextBox5.Value, sSign)
    'SignCheck2and3Sign TextBox5.Value, iSign
    CommandButton2_Click
End Sub

Private Sub TextBox6_Change()
    TextBox1.Value = Catia3dDesc
End Sub

Private Sub UserForm_Initialize()
    LoadSetings
    Frame2.Visible = False
    Frame3.Visible = False
    Frame4.Visible = False
    Frame5.Visible = False
    Frame7.Visible = False
    Frame8.Visible = False
    Frame10.Visible = True
    TextBox5.Visible = False
End Sub

' ***** MY FUNNCTIONS *****

Public Function ExtractJLRNo(sExcelFilePath As String, oExcel As Excel.Application, oWorkBook As Excel.Workbook, oWorkSheet As Excel.Worksheet) As Boolean
    Dim bExcelRun As Boolean, bActive As Boolean
    bExcelRun = False ' check if Excel run, moze w przyszlosci bedzie potrzebne
    Dim column As String
    'Dim sJLRNumber As String
    ' ******************************
    ' sJLRNumber = "Mw92-5K254-aa1"
    sSign = "-"
    'If sJLRNumber = "" Then
    '    bButton = True
    'End If
        
    ' opisac co jest co
    ' -----------------------
    Set oExcel = ConnectToExcel(bExcelRun)
    Set oWorkBook = ConnectToWorkbook(sExcelFilePath, oExcel)
    
    ' Check if Excel is locked and oExcel.Visible = True
    bActive = WorksheetActivate(oExcel)
    
     ' Decoding section
    Set oWorkSheet = oWorkBook.Sheets(1)

    sJLRNumber = InitExtractPartNo(sJLRNumber, sSign, bButton) ' ! extract JLR No using GetParnumber() if true
    
    sBasePart = ExtractBasePart(1, 2, sSign, sJLRNumber, False, True) ' False wtedy ostni znak nie musi byc -
    column = "C:C" ' search in column
    sBasePartDesc = SearchInExcel(oWorkSheet, column, sBasePart, 1) ' offset +1
    ' JLR number
    Set oWorkSheet = oWorkBook.Sheets(3)
    sPrefix = ExtractBasePart(0, 1, sSign, sJLRNumber, False, True)
    ' Prefix
    sYear = VBA.Mid(sPrefix, 1, 1)
    column = "B:B"
    sYearDesc = SearchInExcel(oWorkSheet, column, sYear, -1)
    sYearDesc = VBA.Mid(sYearDesc, 3, 2)
    ' Vehicle
    sVehicle = VBA.Mid(sPrefix, 2, 2)
    column = "D:D"
    sVehicleDesc = SearchInExcel(oWorkSheet, column, sVehicle, 1)
    ' Design Responsibility Code
    ' nie usuwa�, moze sie przydac
    sDRCode = VBA.Mid(sPrefix, 4, 1)
    ' column = "G:G"
    ' sDRCodeDesc = SearchInExcel(oWorkSheet, column, sDRCode, 1)
    ' sSuffx for Example AA1
    sSuffix = ExtractBasePart(2, 3, sSign, sJLRNumber, False, False)
    ' End of decoding section
    ' ******************************
    ' MsgBox sYearDesc + "+" & sVehicleDesc & "+" & sDRCodeDesc & "+" & sBasePart, vbInformation, sYear + "+" & sVehicle & "+" & sDRCode & "+" & sBasePart

    TextBox1.Value = Catia3dDesc
    
    sDocumDesc = sBasePartDesc
    TextBox2.Value = VBA.Mid(sDocumDesc, 1, 40)
    
    sVehicleDescTmp = sVehiclesFillCombo(sVehicleDesc)
    
    'sMaterialDesc = sYearDesc + "MY " + sVehicleDesc + " ??? " + sBasePartDesc
    
    ' MsgBox "Catia 3d.: " + vbTab + s3DCatiaDesc + vbCrLf + "Document.: " + vbTab + sDocumDesc + vbCrLf + "Material.: " + vbTab + sMaterialDesc
    ' sMaterialDesc = ExtractBasePart(0, 3, "/", sMaterialDesc, False, False)
    ' Debug.Print (sMaterialDesc)
    ' Debug.Print ("Catia 3d.: " + s3DCatiaDesc + vbCrLf + "Document.: " + sDocumDesc + vbCrLf + "Material.: " + sMaterialDesc)
    ExtractJLRNo = True
End Function

' Connection to Excel instance
Private Function ConnectToExcel(ByRef bExcelRun As Boolean) As Excel.Application
    
    On Error Resume Next
    ' Podpiecie do Excela
    ' if Excel is already running, then get the Excel object
        bExcelRun = True ' Excel uruchomiony
        Set ConnectToExcel = GetObject(, "Excel.Application")
    If Err.Number <> 0 Then
    ' If Excel is not already running, then create a new session of Excel
        bExcelRun = False ' Excel uruchamiany- zalaczany
        Set ConnectToExcel = CreateObject("Excel.Application")
    End If
    On Error GoTo 0 ' ???
End Function

' Connection to Workbook
Private Function ConnectToWorkbook(sExcelFilePath As String, oExcel As Excel.Application) As Excel.Workbook
    Dim fileName As String
    
    fileName = GetFileName(sExcelFilePath)
    On Error Resume Next
        Set ConnectToWorkbook = oExcel.Workbooks(fileName)
    If Err.Number <> 0 Then
        Set ConnectToWorkbook = oExcel.Workbooks.Open(sExcelFilePath, ReadOnly:=True)
    End If
End Function

Private Function GetFileName(sExcelFilePath As String) As String
    Dim dirReturn, fileName As String
    
    If Len(sExcelFilePath) < 6 Then
        MsgBox "File doesn't exist. File path to short- wrong path!!!", vbCritical, "Please file path check  !!!"
        End ' przerywa kod
    End If
    ' Here's the code I used to fix this by putting spaces in the place of the tab characters:
    ' filePath = Replace(filePath, Chr(9), " ") ' nie dziala w Tennenco, cos inaczej ustawione
    ' Catch all Errors
    On Error Resume Next
        dirReturn = Dir(sExcelFilePath)
    If Err.Number <> 0 Then
        MsgBox "File doesn't exist. Rare path errors- wrong path!!!", vbCritical, "Please file path check  !!!"
        End ' przerywa kod
    End If
    On Error GoTo 0
    ' If file doesn't exist
    If dirReturn = "" Then
        MsgBox "File doesn't exist. Please path check!", vbCritical, "Please file path check !!!"
        End ' przerywa kod
    End If
    ' skracamy nazwe pliku
    GetFileName = VBA.Right(sExcelFilePath, Len(sExcelFilePath) - InStrRev(sExcelFilePath, "\"))
End Function

Private Function WorksheetActivate(oExcel As Excel.Application) As Boolean
    
    On Error Resume Next
        oExcel.Visible = True ' przeniesione
    If Err.Number <> 0 Then
        MsgBox "Excel not ready yet. Maybe some Excel is block by another POP-UP window or cursor.", vbCritical, "Please check !"
        End ' przerywa kod
    End If
    On Error GoTo 0
    
        If oExcel.Application.Ready = False Then ' work not work as I want
        MsgBox "Excel not ready yet. Maybe some Excel is block by another POP-UP window.", vbCritical, "Please check !"
        End
    End If
End Function

Private Function SearchInExcel(ows As Worksheet, column As String, basepart As String, offsetColumn As Integer) As String

    Dim FindRow As Range, FindRow2 As Range
    
    ' Nie dziala w Cati. Zbyt du�o zachodu by uporac sie z missingami
    ' nazwa, wartosci, kompletny pasujacy tekst, wielkosc liter
    ' "Missing References In VBA" ISSUE Szuka dokladnego dopasowania
    ' Dopytac chlopakow z KBME
    Set FindRow = ows.Range(column).Find(What:=basepart) ' dopasowanie moze byc bledne
    ' Set FindRow = ows.Range(column).Find(What:=basepart, LookIn:=xlValues, LookAt:=xlWhole, MatchCase:=True)
    Set FindRow2 = FindRow
    
    ows.Range(column).FindNext
    If FindRow Is Nothing Then
        MsgBox "Please use 'UPPER CASE' or check in Excel code '" & basepart & "' in column.: '" & column & "' on sheet name.: '" & ows.Name & "'. Pattern matching is incorrect.", vbCritical, "Macro can't find pattern matching"
        SearchInExcel = "!WrongSectionNumber!"
        Exit Function
    Else
    ' to rozwinac w petli while in EXCEL, zbedne
        Set FindRow2 = ows.Range(column).FindNext(FindRow)
        If FindRow.Row <> FindRow2.Row Then
            MsgBox "Columnn " & column & " contain more than one JLR numbers", vbInformation, "Be carrefull"
        End If
    End If
    
    SearchInExcel = ows.Cells(FindRow.Row, FindRow.column + offsetColumn).MergeArea(1, 1).Value
End Function

Public Function ExtractBasePart(ByVal pos1 As Integer, ByVal pos2 As Integer, sSign As String, sJLRNumber As String, bGetPartNo As Boolean, bExtractString As Boolean) As String
    '2018.07.28
    ' Dim sPartNum As String
    'Dim iArrPartNumSepPos As Integer, i As Integer  ' tablica
    If (sJLRNumber = "" And bGetPartNo) Then
        sJLRNumber = GetParNumber(False)
    End If
    'Debug.Print SignOccurrence(sPartNum, sSign)
    ExtractBasePart = ExtractString(sJLRNumber, pos1, pos2, sSign, bExtractString)
    'iPartNumberLength = Len(sPartNumber)
    'Debug.Print SignOccurrence(sPartNumber, sSign)
    'Debug.Print GetArray(1)
End Function

Public Function InitExtractPartNo(sJLRNumber As String, sSign As String, bButton As Boolean) As String
    Dim iSign As Integer
    sJLRNumber = ExtractBasePart(0, 0, sSign, sJLRNumber, bButton, False)
    iSign = SignOccurrence(sJLRNumber, sSign)
    ' ****
    If (VBA.Mid(sJLRNumber, 1, 1) = " ") Then
        MsgBox "First sign is space!", vbCritical, "Please check JLR number!"
    End If
    
    If (iSign >= 2) Then
        SignCheck2and3Sign sJLRNumber, iSign
    End If
    
    iSign = SignOccurrence(sJLRNumber, sSign)
    
    ' ****
    If (iSign = 2) Then
        InitExtractPartNo = ExtractBasePart(0, 0, sSign, sJLRNumber, False, False)
    ElseIf (iSign >= 3) Then
        InitExtractPartNo = ExtractBasePart(0, 3, sSign, sJLRNumber, False, True)
    Else
        MsgBox "Plese check Part name. Wrong JLR number.", vbCritical, "Please check Part name !!"
        End
    End If
End Function

Private Function GetParNumber(bRename As Boolean) As String
    Dim oDoc As Document
    
    On Error Resume Next
        Set oDoc = CATIA.ActiveDocument
    If Err.Number <> 0 Then
        MsgBox "Catia file is close !!", vbCritical, "Please open file !!"
        End ' przerywa kod
    End If
    
    ' Oblsluga tylko 2 typow plikow
    If (Not bRename) Then
        If TypeName(oDoc) = "PartDocument" Or TypeName(oDoc) = "ProductDocument" Then
            GetParNumber = oDoc.Product.PartNumber
        Else
             MsgBox "Only CATPart and CATProduct are support !!" & vbCrLf & "Active document is: " & TypeName(oDoc), vbCritical, "Please active correct file !!"
             End
        End If
    Else
        If TypeName(oDoc) = "PartDocument" Or TypeName(oDoc) = "ProductDocument" Then
            oDoc.Product.PartNumber = TextBox1.Value
        Else
             MsgBox "Only CATPart and CATProduct are support !!" & vbCrLf & "Active document is: " & TypeName(oDoc), vbCritical, "Please active correct file !!"
             End
        End If
    End If
    
End Function

Private Function SignOccurrence(sPartNum As String, sSign As String) As Integer
    Dim i As Integer, iCount As Integer
    
    For i = 1 To Len(sPartNum)
        If VBA.Mid(sPartNum, i, 1) = sSign Then
            iCount = iCount + 1
        End If
    Next i
    SignOccurrence = iCount
End Function

Private Function GetSignPosition(sPartNum As String, ByVal iPosition As Integer, sSign As String, bExtractString As Boolean) As Integer
    Dim i, iCount As Integer
    
    If (SignOccurrence(sPartNum, sSign) < iPosition Or iPosition < 0) And bExtractString Then
         MsgBox "Plese check Part name. Wrong separator '" & sSign & "' in the text. ", vbCritical, "Please check Part name !!"
         End
    End If
    
    For i = 1 To Len(sPartNum)
        If VBA.Mid(sPartNum, i, 1) = sSign Then
            iCount = iCount + 1
            If iCount = iPosition Then
                iPosition = i
                Exit For
            End If
        End If
    Next i
    
    If bExtractString Then
        GetSignPosition = iPosition
    Else
        GetSignPosition = Len(sPartNum) + 1
    End If
End Function

Private Function ExtractString(sPartNum As String, ByVal iPosBegin As Integer, ByVal iPosEnd As Integer, sSign As String, bExtractString As Boolean) As String
    iPosBegin = GetSignPosition(sPartNum, iPosBegin, sSign, True) + 1
    iPosEnd = GetSignPosition(sPartNum, iPosEnd, sSign, bExtractString) - iPosBegin
    ExtractString = VBA.Mid(sPartNum, iPosBegin, iPosEnd)
End Function

Private Function sVehiclesFillCombo(sVehicles As String) As String
    Dim i, iSign As Integer
    
    iSign = SignOccurrence(sVehicles, "/")
    
    If (sVehicleDesc <> sVehicleDescTmp) Then
        ComboBox1.Clear
        
        For i = 0 To iSign
            If (iSign = 0 Or iSign = i) Then
                ComboBox1.AddItem (ExtractString(sVehicles, i, i + 1, "/", False))
            Else
                ComboBox1.AddItem (ExtractString(sVehicles, i, i + 1, "/", True))
            End If
        Next
        
        If iSign = 0 Then
            ComboBox1.BackColor = vbWhite
        Else
            ComboBox1.BackColor = RGB(250, 218, 94) ' by nie zminiac za kazdym razem, dlatego tutaj
        End If
    End If
    
    ComboBox1.ListIndex = 0
    sVehiclesFillCombo = sVehicles
End Function

Private Function MaterialDesc() As String
    If (TextBox4.Value = "") Then
        MaterialDesc = VBA.UCase(sYearDesc + "MY " + ComboBox1.Value + " " + sBasePartDesc)
    Else
        MaterialDesc = VBA.UCase(sYearDesc + "MY " + ComboBox1.Value + " " + TextBox4.Value + " " + sBasePartDesc)
    End If
End Function

Private Function Catia3dDesc() As String

    If (TextBox6.Value = "") Then
        Catia3dDesc = VBA.UCase(sYear + sVehicle + sDRCode + "-" + sBasePart + "-" + sSuffix + "-INS-01 " + sBasePartDesc)
    Else
        Catia3dDesc = VBA.UCase(sYear + sVehicle + sDRCode + "-" + sBasePart + "-" + sSuffix + "-INS-01 " + sBasePartDesc + " (" + TextBox6.Value + ")")
    End If
End Function

'cliboard
Public Sub SetClipboard(sUniText As String)
    Dim iStrPtr As Long
    Dim iLen As Long
    Dim iLock As Long
    Const GMEM_MOVEABLE As Long = &H2
    Const GMEM_ZEROINIT As Long = &H40
    Const CF_UNICODETEXT As Long = &HD
    OpenClipboard 0&
    EmptyClipboard
    iLen = LenB(sUniText) + 2&
    iStrPtr = GlobalAlloc(GMEM_MOVEABLE Or GMEM_ZEROINIT, iLen)
    iLock = GlobalLock(iStrPtr)
    lstrcpy iLock, StrPtr(sUniText)
    GlobalUnlock iStrPtr
    SetClipboardData CF_UNICODETEXT, iStrPtr
    CloseClipboard
End Sub

Public Function GetClipboard() As String
    Dim iStrPtr As Long
    Dim iLen As Long
    Dim iLock As Long
    Dim sUniText As String
    Const CF_UNICODETEXT As Long = 13&
    OpenClipboard 0&
    If IsClipboardFormatAvailable(CF_UNICODETEXT) Then
        iStrPtr = GetClipboardData(CF_UNICODETEXT)
        If iStrPtr Then
            iLock = GlobalLock(iStrPtr)
            iLen = GlobalSize(iStrPtr)
            sUniText = String$(iLen \ 2& - 1&, vbNullChar)
            lstrcpy StrPtr(sUniText), iLock
            GlobalUnlock iStrPtr
        End If
        GetClipboard = sUniText
    End If
    CloseClipboard
End Function

Private Sub SignCheck2and3Sign(sTmp As String, iSign)
    Dim iTmp, iInsPos As Integer
    
    sJLRNumber = VBA.UCase(Replace(sTmp, " ", ""))
    sJLRNumber = VBA.UCase(Replace(sJLRNumber, "_", ""))
    iInsPos = VBA.InStr(sJLRNumber, "INS")
    If iInsPos > 10 Then
        sJLRNumber = VBA.Mid(sJLRNumber, 1, iInsPos - 1)
    End If
    
    If (iSign = 2 Or iSign = 3) Then
            iTmp = VBA.Len(sTmp)
            'Debug.Print (sTmp)
            If (VBA.Mid(sTmp, iTmp, iTmp) = "-") Then
                MsgBox "Incorrect JLR No. (too short/incorrect suffix/Last sign is '-')", vbInformation, "Plese correct JLR No."
            End If
    End If
End Sub

' Release the object variable.
Private Sub ReleaseExcelObjects()
    Set oExcel = Nothing
    Set oWorkBook = Nothing
    Set oWorkSheet = Nothing
    sExcelFilePath = ""
    'Unload Me ' chyba to zly pomysl
End Sub

' ***** END FUNCTION  *****

Private Sub UserForm_Terminate()
    ReleaseExcelObjects
End Sub
