VERSION 5.00
Begin {C62A69F0-16DC-11CE-9E98-00AA00574A4F} FormCouleurs 
   Caption         =   "R�glages topo"
   ClientHeight    =   4152
   ClientLeft      =   168
   ClientTop       =   516
   ClientWidth     =   6096
   OleObjectBlob   =   "FormCouleurs.frx":0000
   StartUpPosition =   2  'CenterScreen
End
Attribute VB_Name = "FormCouleurs"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False



Private Sub UserForm_Initialize()
    Dim i As Integer
    Set ButtonHandlers = New Collection
    Set ButtonAddSite = New Collection
    Set ButtonSpin = New Collection
    Set ButtonDEBIT = New Collection
    Me.MultiPage1.Width = 312
    Me.MultiPage1.Style = 1
    Me.Width = 313
    Me.Height = 234
    With MultiPage1.Pages(0).Controls("TypeOffre")
        .Text = "Offre"
        .BorderStyle = 1
        .BorderColor = RGB(200, 200, 200)
        .Font.name = "Segoe UI"
        .Font.Size = 14
        .SpecialEffect = fmSpecialEffectFlat
        .TextAlign = 2
        .ForeColor = RGB(0, 0, 0)
        .BackColor = RGB(245, 245, 245)
    End With
End Sub


Public Function btnAppliquer_Click() As Boolean
    On Error Resume Next
    Dim i As Integer
    Set SiteData = New Collection
    
    TypeOffrebloc = TypeOffre.Text
    If TypeOffrebloc = "" Then
        MsgBox "Offre manquante", vbExclamation
        btnAppliquer_Click = False
        Exit Function
    End If
    Dim PageindexValide As Integer
    PageindexValide = 0
    For i = 1 To MultiPage1.Pages.Count - 1
        PageindexValide = i
        Dim multiPageSB As MSForms.MultiPage
        Do While True
            Set multiPageSB = Nothing
            On Error Resume Next
            Set multiPageSB = Me.Controls("MultiPageSB" & PageindexValide)
            On Error GoTo 0

            If multiPageSB Is Nothing Then
                PageindexValide = PageindexValide + 1
            Else
                Exit Do
            End If
        Loop

        ' Enregistrer le d�bit une seule fois
        Dim siteInfo As Object
        Set siteInfo = CreateObject("Scripting.Dictionary")
        Dim debit As String
        debit = multiPageSB.Pages(0).Controls("txtDebit" & PageindexValide).Text & multiPageSB.Pages(0).Controls("ComboBox" & PageindexValide).Text
        
        If debit = "" Then
            MsgBox "Debit manquant pour debit " & i, vbExclamation
            btnAppliquer_Click = False
            Exit Function
        End If

        siteInfo.Add "DEBIT", debit
        SiteData.Add siteInfo

        Dim X As Integer
        For X = 1 To multiPageSB.Pages.Count - 1
            Dim typeLien As String
            Dim nomSite As String
            Dim ReferenceSatin As String
            Dim NumeroRouteur As String
            Dim siteDetail As Object
            Set siteDetail = CreateObject("Scripting.Dictionary")
            
            With multiPageSB.Pages(X)

                nomSite = .Controls("txtSiteName" & PageindexValide & "-" & X).Text
                ReferenceSatin = .Controls("txtRefSatin" & PageindexValide & "-" & X).Text
                NumeroRouteur = .Controls("txtRefRouteur" & PageindexValide & "-" & X).Text

                If .Controls("BTFTTH" & PageindexValide & "-" & X).Value Then
                    typeLien = "FTTH"
                ElseIf .Controls("BTFTTE" & PageindexValide & "-" & X).Value Then
                    typeLien = "FTTE"
                ElseIf .Controls("BTFTTO" & PageindexValide & "-" & X).Value Then
                    typeLien = "FTTO"
                ElseIf .Controls("BT4G" & PageindexValide & "-" & X).Value Then
                    typeLien = "4G"
                ElseIf .Controls("BTFTTH4G" & PageindexValide & "-" & X).Value Then
                    typeLien = "FTTH4G"
                ElseIf .Controls("BTCUIVRE" & PageindexValide & "-" & X).Value Then
                    typeLien = "CUIVRE"
                ElseIf .Controls("BTNA" & PageindexValide & "-" & X).Value Then
                    typeLien = "NA"
                Else
                    MsgBox "Type de lien manquant pour site " & X & " du d�bit " & PageindexValide, vbExclamation
                    btnAppliquer_Click = False
                    Exit Function
                End If

                btnAppliquer_Click = True
 
            End With

            siteDetail.Add "Nom", nomSite
            siteDetail.Add "RefSatin", ReferenceSatin
            siteDetail.Add "RefRouteur", NumeroRouteur
            siteDetail.Add "TypeLien", typeLien
            SiteData.Add siteDetail
        Next X
    Next i
    Me.Hide
    On Error GoTo 0
End Function


Public Sub btnAddSB_Click()
    Dim newPage As MSForms.page
    Dim newMultiPage As MSForms.MultiPage
    Dim subPage As MSForms.page
    Dim pageIndex As Integer
    Dim optKbps As MSForms.OptionButton
    Dim optMbps As MSForms.OptionButton
    Dim optGbps As MSForms.OptionButton
    Dim obj As MSForms.CommandButton
    Dim obj2 As MSForms.CommandButton
    Dim debitbox As MSForms.TEXTBOX

    pageIndex = Me.MultiPage1.Pages.Count

    Set newPage = Me.MultiPage1.Pages.Add
    newPage.Caption = "DEBIT " & pageIndex


    Set newMultiPage = newPage.Controls.Add("Forms.MultiPage.1", "MultiPageSB" & pageIndex, True)
    With newMultiPage
        .Top = 0
        .Left = 0
        .Width = 258
        .Height = 180
        .BackColor = CouleurAleatoire()
        .Style = 1
    End With

    
    Do While newMultiPage.Pages.Count > 0
        newMultiPage.Pages.Remove (0)
    Loop

    Set subPage = newMultiPage.Pages.Add
    subPage.Caption = "CONF DEBIT" & pageIndex

    Set debitbox = subPage.Controls.Add("Forms.TextBox.1", "txtDebit" & pageIndex, True)
    With debitbox
        .Top = 70
        .Left = 20
        .Width = 70
        .Height = 25
        .BorderStyle = 1
        .BorderColor = RGB(200, 200, 200)
        .Font.name = "Segoe UI"
        .Font.Size = 13
        .SpecialEffect = fmSpecialEffectFlat
        .TextAlign = 3
        .ForeColor = RGB(0, 0, 0)
        .BackColor = RGB(245, 245, 245)
        .Tag = pageIndex
    End With

    Set DEBITHandlers = New ButtonDEBIT
    Set DEBITHandlers.TESTTEXTBOX = debitbox
    ButtonDEBIT.Add DEBITHandlers

    'Call CreateOptionButtons(subPage, pageIndex)

    Set ComboBox = subPage.Controls.Add("Forms.ComboBox.1", "ComboBox" & pageIndex, True)
    With ComboBox
        .Top = 70
        .Left = 100
        .Width = 100
        .Height = 25
        .Font.name = "Segoe UI"
        .Font.Size = 13
        .Font.Bold = True
        .ForeColor = RGB(0, 0, 0)
        .SpecialEffect = fmSpecialEffectFlat
        .AddItem "Kb/s"
        .AddItem "Mb/s"
        .AddItem "Gb/s"
        .AddItem ""
        .Tag = pageIndex
    End With
    Set DEBITHandlers = New ButtonDEBIT
    Set DEBITHandlers.TESTTEXTBOXDEBIT = ComboBox
    ButtonDEBIT.Add DEBITHandlers

    Set obj = subPage.Controls.Add("Forms.CommandButton.1", "BTAddSite" & pageIndex, True)
    With obj
        .Top = 0
        .Left = 0
        .Height = 20
        .Width = 255
        .Caption = "Ajouter Site"
        .BackColor = &H8000000F
        .Font.name = "Segoe UI"
        .Font.Size = 10
        .Font.Bold = True
        .Tag = pageIndex
    End With

    Set obj2 = subPage.Controls.Add("Forms.CommandButton.1", "BTSupprimer" & pageIndex & "-" & "0", True)
    With obj2
        .Top = 130
        .Left = 165
        .Width = 80
        .Caption = "Supprimer Debit"
        .BackColor = &HC0C0FF
        .Font.name = "Segoe UI"
        .Font.Size = 8
        .Font.Bold = True
        .Tag = pageIndex & "-" & "0"
    End With

    Set handler = New ButtonHandler
    Set handler.Button = obj2
    ButtonHandlers.Add handler


    Set AddSiteHandlers = New ButtonAddSite
    Set AddSiteHandlers.Button = obj
    ButtonAddSite.Add AddSiteHandlers
End Sub


Function CouleurAleatoire() As Long
  Dim rouge As Integer
  Dim vert As Integer
  Dim bleu As Integer
  rouge = Int(Rnd() * 256)
  vert = Int(Rnd() * 256)
  bleu = Int(Rnd() * 256)
  CouleurAleatoire = RGB(rouge, vert, bleu)
End Function

Private Sub btnModifier_Click()
    If Not FormCouleurs.btnAppliquer_Click Then
            Exit Sub
    End If
    DoEvents
    Call Modifier
    Me.Hide
End Sub

Private Sub btnAjouter_Click()
    Call Ajouter
    Me.Hide
End Sub

' Ajouter une nouvelle page principale (bloc DEBIT)
Public Sub AddSITE(pageIndex As Integer)
    Call btnAddSB_Click
End Sub

Public Sub AddSiteSB(pageIndex As Integer)
    Dim btn As MSForms.CommandButton
    Set btn = Me.MultiPage1.Pages(pageIndex).Controls("MultiPageSB" & pageIndex).Pages(0).Controls("BTAddSite" & pageIndex)
    If Not btn Is Nothing Then
        btn.Value = True
        DoEvents
    End If
End Sub


Public Sub txtDebit1_Change()
    Debug.Print "La valeur de txtDebit1 a chang�. Nouvelle valeur : " & FormCouleurs.MultiPage1.Pages(1).Controls("MultiPageSB" & 1).Pages(0).Controls("txtDebit" & 1).Text
End Sub


Sub CreateOptionButtons(subPage As Object, pageIndex As Integer)
    Dim options As Variant
    options = Array("Kb/s", "Mb/s", "Gb/s", "")

    Dim i As Integer
    Dim optButton As Object
    Dim topPosition As Integer

    topPosition = 42
    
    For i = LBound(options) To UBound(options)
        Set optButton = subPage.Controls.Add("Forms.OptionButton.1", "opt" & options(i) & pageIndex, True)

        With optButton
            .Top = topPosition
            .Left = 130
            .Width = 100
            .Height = 24
            .Caption = options(i)
            .Font.name = "Segoe UI"
            .Font.Size = 10
            .Font.Bold = True
            .ForeColor = RGB(0, 0, 0)
            .SpecialEffect = fmSpecialEffectFlat
        End With

        topPosition = topPosition + 18
    Next i
End Sub


Sub ImporterCodeConf()
    Dim fd As FileDialog
    Dim filePath As String
    Dim fso As Object
    Dim ts As Object
    Dim fileContent As String
    Const ForReading As Long = 1

    Dim nombreSiteDebit As Object
    Set nombreSiteDebit = CreateObject("Scripting.Dictionary")

    Dim valeurDebit As Object
    Set valeurDebit = CreateObject("Scripting.Dictionary")
    Dim NomClient As String
    Dim nombreDebit As Integer
    Dim i As Integer
    Dim k As Integer
    Dim n As Integer
    Dim currentItem As String
    Dim offreName As String
    Dim parts As Variant
    Dim debitInfo As Variant
    Dim siteDetails As Variant
    Dim debitIndexSite As Integer
    Dim debitIndex As Integer
    Dim NombreSite As Integer
    Dim valeur As String
    Dim NomSiteAuto As String
    Dim TypeSiteAuto As String
    Dim IDSiteAuto As String
    Dim TechSiteAuto As String
    Dim NumSite As Integer
    Dim nombreTableaux As Integer
    Dim tableauIndex As Integer
    Dim NumSitePrecedent As Integer
    Dim TabXPostion As Double
    Dim TabYPostion As Double

    Dim technologiesUniques As Object
    Set technologiesUniques = CreateObject("Scripting.Dictionary")

    Dim btn As MSForms.CommandButton
    Set fd = Application.FileDialog(msoFileDialogFilePicker)
    With fd
        .Title = "Selectionnez le .txt contenant votre fichier de configuration"
        .AllowMultiSelect = False
        .Filters.Clear
        .Filters.Add "Fichiers texte", "*.txt"
        If .Show <> -1 Then Exit Sub
        filePath = .SelectedItems(1)
        Debug.Print "Fichier selectionne : " & filePath
    End With

    Set fso = CreateObject("Scripting.FileSystemObject")
    Set ts = fso.OpenTextFile(filePath, ForReading)
    fileContent = ts.ReadAll
    ts.Close

    items = Split(fileContent, ";")

    For i = LBound(items) To UBound(items)
        currentItem = Trim(items(i))
        If InStr(currentItem, "NomClient :") > 0 Then
            NomClient = Replace(currentItem, "NomClient :", "")
            Debug.Print "Nom Client: " & NomClient
            Call Module1.AjouterNomClient(NomClient)
            Exit For
        End If
    Next i
    For i = LBound(items) To UBound(items)
        currentItem = Trim(items(i))
        If InStr(currentItem, "NombreTableaux :") > 0 Then
            nombreTableaux = CLng(Replace(currentItem, "NombreTableaux :", ""))
            Debug.Print "Nombre total de tableaux : " & nombreTableaux
            Exit For
        End If
    Next i
    TabYPostion = 0
    NumSitePrecedent = 0
    For n = 1 To nombreTableaux
        tableauIndex = n
        Debug.Print "Tableau :"; tableauIndex
        Debug.Print LBound(items) & "-" & UBound(items)
        For i = LBound(items) To UBound(items)
            currentItem = Trim(items(i))
            If InStr(currentItem, "Tab&" & tableauIndex & "&Nom&offre :") > 0 Then
                parts = Split(currentItem, "&")
                If UBound(parts) >= 3 Then
                    debitInfo = Split(parts(3), " : ")
                    If UBound(debitInfo) >= 1 Then
                    offreName = Trim(debitInfo(1))
                    End If
                End If
                Me.MultiPage1.Pages(0).Controls("TypeOffre").Text = offreName
                Debug.Print "Nom de l'offre : " & offreName
            ElseIf InStr(currentItem, "Tab&" & tableauIndex & "&Nombre&DEBITS :") > 0 Then
                nombreDebit = CLng(Replace(currentItem, "Tab&" & tableauIndex & "&Nombre&DEBITS :", ""))
                Debug.Print "Nombre total de debits pour le tableau " & tableauIndex & " : " & nombreDebit
                For k = 1 To nombreDebit
                    btnAddSB_Click
                    DoEvents
                Next k
            ElseIf InStr(currentItem, "Tab&" & tableauIndex & "&Nombre&Site&DEBIT&") > 0 Then
                parts = Split(currentItem, "&")
                If UBound(parts) >= 5 Then
                    debitInfo = Split(parts(5), " : ")
                    If UBound(debitInfo) >= 1 Then
                        debitIndex = CLng(debitInfo(0))
                        NombreSite = CLng(Trim(debitInfo(1)))
                        If Not nombreSiteDebit.Exists(debitIndex) Then
                            nombreSiteDebit.Add debitIndex, NombreSite
                            Debug.Print "Debit " & debitIndex & " aura " & NombreSite & " sites (Tableau " & tableauIndex & ")."
                            For k = 1 To NombreSite
                                On Error Resume Next
                                Set btn = Me.MultiPage1.Pages(debitIndex).Controls("MultiPageSB" & debitIndex).Pages(0).Controls("BTAddSite" & debitIndex)
                                On Error GoTo 0
                                If Not btn Is Nothing Then
                                    btn.Value = True
                                    btn.Value = False
                                    DoEvents
                                End If
                            Next k
                            DoEvents
                        Else
                            Debug.Print "Avertissement : La cle pour le debit " & debitIndex & " (nombre de sites) existe deja (Tableau " & tableauIndex & ")."
                        End If
                    End If
                End If
            ElseIf InStr(currentItem, "Tab&" & tableauIndex & "&Valeur&DEBIT&") > 0 Then
                parts = Split(currentItem, "&")
                If UBound(parts) >= 4 Then
                    debitInfo = Split(parts(4), " : ")
                    If UBound(debitInfo) >= 1 Then
                        debitIndex = CLng(debitInfo(0))
                        valeur = Trim(debitInfo(1))
                        If Not valeurDebit.Exists(debitIndex) Then
                            valeurDebit.Add debitIndex, valeur
                            Debug.Print "La valeur du debit " & debitIndex & " est : " & valeur & " (Tableau " & tableauIndex & ")."
                            ' Assurez-vous que le controle existe sur la page correspondante
                            On Error Resume Next
                            Me.MultiPage1.Pages(debitIndex).Controls("MultiPageSB" & debitIndex).Pages(0).Controls("txtDebit" & debitIndex).Text = valeur
                            On Error GoTo 0
                        Else
                            Debug.Print "Avertissement : La cle pour le debit " & debitIndex & " (valeur) existe deja (Tableau " & tableauIndex & ")."
                        End If
                    End If
                End If
            ElseIf InStr(currentItem, "Tab&" & tableauIndex & "&SITE&") > 0 Then
                parts = Split(currentItem, "&")
                If UBound(parts) >= 5 Then
                    NumSite = CLng(Split(parts(3), "&")(0))
                    If UBound(Split(currentItem, "&DEBIT&")) > 0 Then
                        Dim debitPart As Variant
                        debitPart = Split(currentItem, "&DEBIT&")(1)
                        If InStr(debitPart, " :") > 0 Then
                            debitIndexSite = CLng(Split(debitPart, " :")(0))
                        ElseIf IsNumeric(Split(debitPart, "&")(0)) Then
                            debitIndexSite = CLng(Split(debitPart, "&")(0))
                        Else
                            Debug.Print "Avertissement : Index de debit non numerique dans : " & currentItem
                        End If

                        siteDetails = Split(Split(currentItem, ":")(1), "*")
                        If UBound(siteDetails) >= 3 Then
                            NomSiteAuto = Trim(siteDetails(0))
                            TypeSiteAuto = Trim(siteDetails(1))
                            IDSiteAuto = Trim(siteDetails(2))
                            TechSiteAuto = Trim(siteDetails(3))
                            Debug.Print "Tableau " & tableauIndex & ", Debit " & debitIndexSite & ", Site " & NumSite & " : Nom=" & NomSiteAuto & ", Type=" & TypeSiteAuto & ", ID=" & IDSiteAuto & ", Tech=" & TechSiteAuto

                            If TechSiteAuto = "N/A" Then
                                TechSiteAuto = "NA"
                                Debug.Print TechSiteAuto
                            End If



                            If Not technologiesUniques.Exists(TechSiteAuto) Then
                                technologiesUniques.Add TechSiteAuto, True
                            End If

                            On Error Resume Next
                            Me.MultiPage1.Pages(debitIndexSite).Controls("MultiPageSB" & debitIndexSite).Pages(NumSite).Controls("txtSiteName" & debitIndexSite & "-" & NumSite).Text = NomSiteAuto
                            Me.MultiPage1.Pages(debitIndexSite).Controls("MultiPageSB" & debitIndexSite).Pages(NumSite).Controls("txtRefSatin" & debitIndexSite & "-" & NumSite).Text = TypeSiteAuto
                            Me.MultiPage1.Pages(debitIndexSite).Controls("MultiPageSB" & debitIndexSite).Pages(NumSite).Controls("txtRefRouteur" & debitIndexSite & "-" & NumSite).Text = IDSiteAuto
                            DoEvents
                            Me.MultiPage1.Pages(debitIndexSite).Controls("MultiPageSB" & debitIndexSite).Pages(NumSite).Controls("BT" & TechSiteAuto & debitIndexSite & "-" & NumSite).Value = True
                            DoEvents
                            On Error GoTo 0
                        Else
                            Debug.Print "Avertissement : Informations de site incompletes pour : " & currentItem
                        End If
                    Else
                        Debug.Print "Avertissement : Format de ligne SITE incorrect (pas de &DEBIT&) dans : " & currentItem
                    End If
                End If
            End If
        Next i

        Call Module1.GenererLegendeAutomatiquement(technologiesUniques)

        Debug.Print "NumSitePrecedent: " & NumSitePrecedent & "  NumSite : " & NumSite
        If tableauIndex = 1 Then
            Debug.Print " je suis dans Tab 1"
            TabYPostion = 1
            TabXPostion = 1
            Module1.XPosition = Module1.ConvertToPoints(CDbl(4.2 * (TabXPostion - 1) + 0.2))
            Module1.YPosition = Module1.ConvertToPoints(TabYPostion)
            NumSitePrecedent = NumSitePrecedent + NumSite + debitIndex
        ElseIf (NumSitePrecedent + NumSite + debitIndex) < 18 And tableauIndex <> 1 Then
            Debug.Print " je suis dans <, " & (NumSitePrecedent + NumSite + debitIndex)
            TabYPostion = TabYPostion + Creation.HauteurBlocPrincipal + 0.4
            Module1.YPosition = Module1.ConvertToPoints(TabYPostion)
            NumSitePrecedent = NumSitePrecedent + NumSite + 1 + debitIndex
        ElseIf (NumSitePrecedent + NumSite + debitIndex) >= 18 And tableauIndex <> 1 Then
            Debug.Print " je suis dans >=" & (NumSitePrecedent + NumSite + debitIndex)
            TabYPostion = 1
            TabXPostion = TabXPostion + 1
            Module1.XPosition = Module1.ConvertToPoints(CDbl(4.2 * (TabXPostion - 1) + (TabXPostion * 0.2)))
            Module1.YPosition = ConvertToPoints(TabYPostion)
            NumSitePrecedent = NumSite
        End If


        Dim positionSeparateur As Integer
        positionSeparateur = InStrRev(X, "_")
        Module1.currentTime = Left(Module1.currentTime, positionSeparateur + 4)
        Module1.currentTime = Module1.currentTime & tableauIndex
        DoEvents
        Call Ajouter
        DoEvents
        Call Module1.ResetFormCouleurs
        DoEvents
        Call DeselectionnerTout
        DoEvents
        nombreSiteDebit.RemoveAll
        valeurDebit.RemoveAll
        DoEvents
    Next n
End Sub

Sub DeselectionnerTout()
    If ActiveWindow.Selection.Type = ppSelectionShapes Then
        ActiveWindow.Selection.Unselect
    End If
End Sub


