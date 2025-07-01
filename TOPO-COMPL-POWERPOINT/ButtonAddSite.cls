VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "ButtonAddSite"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Public WithEvents Button As MSForms.CommandButton
Attribute Button.VB_VarHelpID = -1

Public Sub Button_Click()
    Dim pageIndex As Integer
    Dim multiPageSBindex As String
    Dim newPage As MSForms.Page
    Dim SBpageIndex As Integer

    pageIndex = CInt(Button.Tag)

    multiPageSBindex = "MultiPageSB" & pageIndex

    Set multiPageSB = FormCouleurs.Controls(multiPageSBindex)
    'With multiPageSB
    '    .BackColor = &H00E0E0E0&
    'End With
    Set newPage = multiPageSB.Pages.Add

    SBpageIndex = multiPageSB.Pages.Count - 1
    newPage.Caption = "Site " & SBpageIndex

    Call AddTextBox(newPage, "txtSiteName" & pageIndex & "-" & SBpageIndex, 30, "Nom du site")
    Call AddTextBox(newPage, "txtRefSatin" & pageIndex & "-" & SBpageIndex, 60, "")
    Call AddTextBox(newPage, "txtRefRouteur" & pageIndex & "-" & SBpageIndex, 90, "Ref routeur")
    
    Set obj = newPage.Controls.Add("Forms.CommandButton.1", "BTSupprimer" & pageIndex & "-" & SBpageIndex, True)
    With obj
        .Top = 130
        .Left = 165
        .Width = 80
        .Caption = "Supprimer Site"
        .BackColor = &H00C0C0FF&
        .Font.name = "Segoe UI"
        .Font.Size = 8
        .Font.Bold = True
        .Tag = pageIndex & "-" & SBpageIndex
    End With

    Dim objFrame As MSForms.Frame
    Set objFrame = newPage.Controls.Add("Forms.Frame.1", "FrameTypeLien" & pageIndex, True)
    ' Paramétrage du cadre
    With objFrame
        .Top = 30
        .Left =  120
        .Width = 109
        .Height = 90
        .Caption = "Type de lien"
        .BackColor = &H8000000A&
        .BorderStyle = 1
        .BorderColor = RGB(200, 200, 200)
        .Font.Name = "Segoe UI"
        .Font.Size = 10
        .Font.Bold = True
        .ForeColor = RGB(0, 0, 0) ' Texte noir
    End With

    Dim toupie As MSForms.SpinButton
    Set toupie = newPage.Controls.Add("Forms.SpinButton.1", "Toupie" & pageIndex & "-" & SBpageIndex, True)
    With toupie
        .Top = 135
        .Left = 10
        .Width = 66
        .Height = 18
        .Min = 0
        .Max = 100
        .Value = SBpageIndex
        .Tag = pageIndex & "-" & SBpageIndex
        .orientation = 1
    End With

    Set AddspinHandlers = New ButtonSpin
    Set AddspinHandlers.Toupie = toupie
    ButtonSpin.Add AddspinHandlers

    ' Ajout des boutons radio DANS le cadre (et non directement dans la page)
    Call AddOptionButton(objFrame, "BTFTTH" & pageIndex & "-" & SBpageIndex, 10, 3, "FTTH", "#D9C2F0")
    Call AddOptionButton(objFrame, "BTFTTE" & pageIndex & "-" & SBpageIndex, 28, 3, "FTTE", "#FFF6B6")
    Call AddOptionButton(objFrame, "BTFTTO" & pageIndex & "-" & SBpageIndex, 46, 3, "FTTO", "#B5E8F7")
    Call AddOptionButton(objFrame, "BT4G" & pageIndex & "-" & SBpageIndex, 10, 56, "4G", "#FFB571")
    Call AddOptionButton(objFrame, "BTFTTH4G" & pageIndex & "-" & SBpageIndex, 28, 56, "FTTH/4G", "#FFE8F7")
    Call AddOptionButton(objFrame, "BTCUIVRE" & pageIndex & "-" & SBpageIndex, 46, 56, "CUIVRE", "#B8EBD6")
    Call AddOptionButton(objFrame, "BTNA" & pageIndex & "-" & SBpageIndex, 64, 56, "N/A", "#E4E4E4")

    Set handler = New ButtonHandler
    Set handler.Button = obj
    ButtonHandlers.Add handler

    Dim objBTADD As MSForms.CommandButton
    Set objBTADD = newPage.Controls.Add("Forms.CommandButton.1", "BTAddSite" & pageIndex & "_" & SBpageIndex , True)
    With objBTADD
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

    Set AddSiteHandlers = New ButtonAddSite
    Set AddSiteHandlers.Button = objBTADD
    ButtonAddSite.Add AddSiteHandlers
End Sub

Private Sub AddTextBox(targetPage As MSForms.Page, name As String, topOffset As Integer, defaultText As String)
    Dim txt As MSForms.TextBox
    Set txt = targetPage.Controls.Add("Forms.TextBox.1", name, True)
    With txt
        .Top = topOffset
        .Left = 5
        .Width = 100
        .Text = defaultText
        .BackColor = RGB(255, 255, 255) 
        .BorderStyle = 1 
        .BorderColor = RGB(200, 200, 200)
        .Font.name = "Segoe UI" 
        .Font.Size = 12 
        .SpecialEffect = fmSpecialEffectFlat 
        .TextAlign = 2 
        .ForeColor = RGB(0, 0, 0)
        .BackColor = RGB(245, 245, 245)
    End With
End Sub

Private Sub AddOptionButton(targetFrame As MSForms.Frame, name As String, topOffset As Integer, leftOffset As Integer, captionText As String, couleurtext As String)
    Dim opt As MSForms.OptionButton
    Set opt = targetFrame.Controls.Add("Forms.OptionButton.1", name, True) ' On ajoute dans le Frame

    With opt
        .Top = topOffset
        .Left = leftOffset
        .Width = 50
        .Height = 15
        .Caption = captionText
        .Font.name = "Segoe UI"
        .Font.Size = 8
        .Font.Bold = True
        .BackColor = HexToRGB(couleurtext)
        .ForeColor = RGB(0, 0, 0)
        .SpecialEffect = fmSpecialEffectFlat
    End With
End Sub
