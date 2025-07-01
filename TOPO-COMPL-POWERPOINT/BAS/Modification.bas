Attribute VB_Name = "Modification"
Public Sub Modifier()
    Dim slide As slide
    Dim TypeOffreBloc As String
    Set slide = ActiveWindow.Selection.SlideRange(1)
    currentTime = Format(Now, "yyyymmdd_hhnnss")

    Dim isGroup As Boolean
    Dim blocDebitDictionnaire As Object
    Set blocDebitDictionnaire = CreateObject("Scripting.Dictionary")
    Dim DEBITBLOCCOUNT As Integer
    isGroup = False
    DEBITBLOCCOUNT = 0
    If ActiveWindow.Selection.Type = ppSelectionShapes Then
        Set selectedShape = ActiveWindow.Selection.ShapeRange(1)
        If selectedShape.Type = msoGroup Then
            isGroup = True
        End If
        If isGroup Then
            
            Dim NombreSite As Integer, i As Integer, NUMDEBIT As Integer, j As Integer, NumSite As Integer, NumSousPage As Integer
            NUMDEBIT = 0
            j = 1
            Dim DebitsETSite As Collection
            Set DebitsETSite = New Collection
            Dim siteInfo As Object

            For NumSite = 1 To FormCouleurs.MultiPage1.Pages.Count - 1
                ' Créer un dictionnaire pour chaque site
                Set siteInfo = CreateObject("Scripting.Dictionary")
                
                Debug.Print "Debit: " & SiteData(j)("DEBIT")
                j = j + 1

                ' Boucle à travers les pages du contrôle MultiPage
                For NumSousPage = 1 To FormCouleurs.MultiPage1.Pages(NumSite).Controls("MultiPageSB" & NumSite).Pages.Count - 1
                    If Trim(SiteData(j)("Nom")) <> "" Then
                        siteInfo.Add "SITE_" & NumSite & "_" & NumSousPage, SiteData(j)("Nom")
                        Debug.Print "SITE_" & NumSite & "_" & NumSousPage & " = " & SiteData(j)("Nom")
                        j = j + 1
                    End If
                Next NumSousPage

                DebitsETSite.Add siteInfo
            Next NumSite

            ' Afficher le contenu de la collection DebitsETSite après boucle
            Debug.Print "-------------------------"
            Debug.Print "Contenu final de DebitsETSite :"
            For Each siteInfo In DebitsETSite
                For Each Key In siteInfo.Keys
                    Debug.Print Key & " = " & siteInfo(Key)
                Next Key
            Next siteInfo

            Dim totalBlocsDebit As Integer
            totalBlocsDebit = 0
            Dim totalBlocsSite As Integer
            totalBlocsSite = 0
            Dim missingElements As String
            missingElements = ""

            Dim topPosition As Double
            Dim leftPosition As Double

            For Each groupShape In selectedShape.GroupItems
                If InStr(groupShape.Name, "blocOffre_") > 0 Then
                    TypeOffreBloc = FormCouleurs.MultiPage1.Pages(0).Controls("TypeOffre").Text
                    groupShape.TextFrame.TextRange.Text = TypeOffreBloc
                    topPosition = groupShape.Top
                    leftPosition = groupShape.Left
                End If

                If InStr(groupShape.Name, "blocDEBIT_") > 0 Then
                    Dim pageIndex As Integer
                    pageIndex = Val(Split(groupShape.Name, "_")(1))
                    DEBITBLOCCOUNT = DEBITBLOCCOUNT + 1
                    If Not blocDebitDictionnaire.Exists(pageIndex) Then
                        blocDebitDictionnaire.Add pageIndex, CreateObject("Scripting.Dictionary")
                        TypeOffreBloc = FormCouleurs.MultiPage1.Pages(pageIndex).Controls("MultiPageSB" & pageIndex).Pages(0).Controls("txtDebit" & pageIndex).Text
                        groupShape.TextFrame.TextRange.Text = TypeOffreBloc
                        totalBlocsDebit = totalBlocsDebit + 1
                    End If
                End If

                If InStr(groupShape.Name, "sousBloc1_") > 0 Then
                    Dim sousBlocInfo() As String
                    sousBlocInfo = Split(groupShape.Name, "_")

                    pageIndex = Val(sousBlocInfo(1))
                    sousPageIndex = Val(sousBlocInfo(2))

                    On Error Resume Next
                    Dim TypeLienHex As String
                    If FormCouleurs.MultiPage1.Pages(pageIndex).Controls("MultiPageSB" & pageIndex).Pages(sousPageIndex).Controls("BTFTTH" & pageIndex & "-" & sousPageIndex).Value = True Then
                        TypeLienHex = "#D9C2F0"
                    ElseIf FormCouleurs.MultiPage1.Pages(pageIndex).Controls("MultiPageSB" & pageIndex).Pages(sousPageIndex).Controls("BTFTTE" & pageIndex & "-" & sousPageIndex).Value = True Then
                        TypeLienHex = "#FFF6B6"
                    ElseIf FormCouleurs.MultiPage1.Pages(pageIndex).Controls("MultiPageSB" & pageIndex).Pages(sousPageIndex).Controls("BTFTTO" & pageIndex & "-" & sousPageIndex).Value = True Then
                        TypeLienHex = "#B5E8F7"
                    ElseIf FormCouleurs.MultiPage1.Pages(pageIndex).Controls("MultiPageSB" & pageIndex).Pages(sousPageIndex).Controls("BT4G" & pageIndex & "-" & sousPageIndex).Value = True Then
                        TypeLienHex = "#FFB571"
                    ElseIf FormCouleurs.MultiPage1.Pages(pageIndex).Controls("MultiPageSB" & pageIndex).Pages(sousPageIndex).Controls("BTFTTH4G" & pageIndex & "-" & sousPageIndex).Value = True Then
                        TypeLienHex = "#FFE8F7"
                    ElseIf FormCouleurs.MultiPage1.Pages(pageIndex).Controls("MultiPageSB" & pageIndex).Pages(sousPageIndex).Controls("BTCUIVRE" & pageIndex & "-" & sousPageIndex).Value = True Then
                        TypeLienHex = "#B8EBD6"
                    ElseIf FormCouleurs.MultiPage1.Pages(pageIndex).Controls("MultiPageSB" & pageIndex).Pages(sousPageIndex).Controls("BTNA" & pageIndex & "-" & sousPageIndex).Value = True Then
                        TypeLienHex = "#E4E4E4"
                    End If
                    On Error GoTo 0

                    If Not blocDebitDictionnaire(pageIndex).Exists(sousPageIndex) Then
                        TypeOffreBloc = FormCouleurs.MultiPage1.Pages(pageIndex).Controls("MultiPageSB" & pageIndex).Pages(sousPageIndex).Controls("txtSiteName" & pageIndex & "-" & sousPageIndex).Text
                        groupShape.TextFrame.TextRange.Text = TypeOffreBloc
                        groupShape.Fill.ForeColor.RGB = HexToRGB(TypeLienHex)
                        blocDebitDictionnaire(pageIndex).Add sousPageIndex, True
                    End If

                    totalBlocsSite = totalBlocsSite + 1
                End If

                If InStr(groupShape.Name, "sousBloc2_") > 0 Then
                    TypeOffreBloc = FormCouleurs.MultiPage1.Pages(pageIndex).Controls("MultiPageSB" & pageIndex).Pages(sousPageIndex).Controls("txtRefSatin" & pageIndex & "-" & sousPageIndex).Text
                    groupShape.TextFrame.TextRange.Text = TypeOffreBloc
                    groupShape.Fill.ForeColor.RGB = HexToRGB(TypeLienHex)
                End If

                If InStr(groupShape.Name, "sousBloc3_") > 0 Then
                    TypeOffreBloc = FormCouleurs.MultiPage1.Pages(pageIndex).Controls("MultiPageSB" & pageIndex).Pages(sousPageIndex).Controls("txtRefRouteur" & pageIndex & "-" & sousPageIndex).Text
                    groupShape.TextFrame.TextRange.Text = TypeOffreBloc
                    groupShape.Fill.ForeColor.RGB = HexToRGB(TypeLienHex)
                End If
            Next groupShape

            ' Vérifier les éléments manquants et les afficher
            For pageIndex = 1 To FormCouleurs.MultiPage1.Pages.Count - 1
                For sousPageIndex = 1 To FormCouleurs.MultiPage1.Pages(pageIndex).Controls("MultiPageSB" & pageIndex).Pages.Count - 1
                    On Error Resume Next
                    If  Not blocDebitDictionnaire(pageIndex).Exists(sousPageIndex) Then
                        missingElements = missingElements & "Manquant: SITE_" & pageIndex & "_" & sousPageIndex & vbCrLf
                        On Error GoTo 0
                    End If

                Next sousPageIndex
            Next pageIndex

                Module1.YPosition = topPosition + ConvertToPoints(0.2)
                Module1.XPosition = leftPosition
                selectedShape.Delete
                Call Ajouter

            If Len(missingElements) > 0 Then
                Debug.Print "-------------------------"
                Debug.Print "Éléments manquants :"
                Debug.Print missingElements
            End If
        End If
    End If
End Sub
