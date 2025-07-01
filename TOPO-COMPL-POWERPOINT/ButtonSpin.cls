VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "ButtonSpin"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Public WithEvents Toupie  As MSForms.SpinButton

Private Sub Toupie_SpinUp()
    Dim ButtonTAG As String
    Dim pageIndex As Integer
    Dim sousPageIndex As Integer
    Dim parts() As String
    Dim tempCaption As String
    Dim activeButtonPage1 As String
    Dim activeButtonPage2 As String
    
    ButtonTAG = Toupie.Tag
    parts = Split(ButtonTAG, "-")
    If UBound(parts) >= 1 Then
        pageIndex = Val(parts(0))
        sousPageIndex = Val(parts(1))
    End If
    Debug.Print "SousPage=" & sousPageIndex & " Page=" & pageIndex

    With FormCouleurs.MultiPage1.Pages(pageIndex).Controls("MultiPageSB" & pageIndex)
        If sousPageIndex < .Pages.Count Then
            On Error Resume Next
            
            tempCaption = .Pages(sousPageIndex).Caption
            .Pages(sousPageIndex).Caption = .Pages(sousPageIndex + 1).Caption
            .Pages(sousPageIndex + 1).Caption = tempCaption
            
            tempCaption = .Pages(sousPageIndex).Controls("txtSiteName" & pageIndex & "-" & sousPageIndex).Text
            .Pages(sousPageIndex).Controls("txtSiteName" & pageIndex & "-" & sousPageIndex).Text = .Pages(sousPageIndex + 1).Controls("txtSiteName" & pageIndex & "-" & (sousPageIndex + 1)).Text
            .Pages(sousPageIndex + 1).Controls("txtSiteName" & pageIndex & "-" & (sousPageIndex + 1)).Text = tempCaption
            
            tempCaption = .Pages(sousPageIndex).Controls("txtRefSatin" & pageIndex & "-" & sousPageIndex).Text
            .Pages(sousPageIndex).Controls("txtRefSatin" & pageIndex & "-" & sousPageIndex).Text = .Pages(sousPageIndex + 1).Controls("txtRefSatin" & pageIndex & "-" & (sousPageIndex + 1)).Text
            .Pages(sousPageIndex + 1).Controls("txtRefSatin" & pageIndex & "-" & (sousPageIndex + 1)).Text = tempCaption
            
            tempCaption = .Pages(sousPageIndex).Controls("txtRefRouteur" & pageIndex & "-" & sousPageIndex).Text
            .Pages(sousPageIndex).Controls("txtRefRouteur" & pageIndex & "-" & sousPageIndex).Text = .Pages(sousPageIndex + 1).Controls("txtRefRouteur" & pageIndex & "-" & (sousPageIndex + 1)).Text
            .Pages(sousPageIndex + 1).Controls("txtRefRouteur" & pageIndex & "-" & (sousPageIndex + 1)).Text = tempCaption
            
            activeButtonPage1 = TrouverBoutonActif(.Pages(sousPageIndex), pageIndex, sousPageIndex)
            activeButtonPage2 = TrouverBoutonActif(.Pages(sousPageIndex + 1), pageIndex, sousPageIndex + 1)
            
            Call ActiverBouton(.Pages(sousPageIndex), pageIndex, sousPageIndex, activeButtonPage2)
            Call ActiverBouton(.Pages(sousPageIndex + 1), pageIndex, sousPageIndex + 1, activeButtonPage1)
            
            On Error GoTo 0
        End If
    End With
End Sub



Private Sub Toupie_SpinDown()
    Dim ButtonTAG As String
    Dim pageIndex As Integer
    Dim sousPageIndex As Integer
    Dim parts() As String
    Dim tempCaption As String
    Dim activeButtonPage1 As String
    Dim activeButtonPage2 As String
    
    ButtonTAG = Toupie.Tag
    parts = Split(ButtonTAG, "-")
    If UBound(parts) >= 1 Then
        pageIndex = Val(parts(0))
        sousPageIndex = Val(parts(1))
    End If
    Debug.Print "SousPage=" & sousPageIndex & " Page=" & pageIndex

    If sousPageIndex > 1 Then
        On Error Resume Next
        With FormCouleurs.MultiPage1.Pages(pageIndex).Controls("MultiPageSB" & pageIndex)
            tempCaption = .Pages(sousPageIndex).Caption
            .Pages(sousPageIndex).Caption = .Pages(sousPageIndex - 1).Caption
            .Pages(sousPageIndex - 1).Caption = tempCaption

            tempCaption = .Pages(sousPageIndex).Controls("txtSiteName" & pageIndex & "-" & sousPageIndex).Text
            .Pages(sousPageIndex).Controls("txtSiteName" & pageIndex & "-" & sousPageIndex).Text = .Pages(sousPageIndex - 1).Controls("txtSiteName" & pageIndex & "-" & (sousPageIndex - 1)).Text
            .Pages(sousPageIndex - 1).Controls("txtSiteName" & pageIndex & "-" & (sousPageIndex - 1)).Text = tempCaption

            tempCaption = .Pages(sousPageIndex).Controls("txtRefSatin" & pageIndex & "-" & sousPageIndex).Text
            .Pages(sousPageIndex).Controls("txtRefSatin" & pageIndex & "-" & sousPageIndex).Text = .Pages(sousPageIndex - 1).Controls("txtRefSatin" & pageIndex & "-" & (sousPageIndex - 1)).Text
            .Pages(sousPageIndex - 1).Controls("txtRefSatin" & pageIndex & "-" & (sousPageIndex - 1)).Text = tempCaption

            tempCaption = .Pages(sousPageIndex).Controls("txtRefRouteur" & pageIndex & "-" & sousPageIndex).Text
            .Pages(sousPageIndex).Controls("txtRefRouteur" & pageIndex & "-" & sousPageIndex).Text = .Pages(sousPageIndex - 1).Controls("txtRefRouteur" & pageIndex & "-" & (sousPageIndex - 1)).Text
            .Pages(sousPageIndex - 1).Controls("txtRefRouteur" & pageIndex & "-" & (sousPageIndex - 1)).Text = tempCaption
            activeButtonPage1 = TrouverBoutonActif(.Pages(sousPageIndex - 1), pageIndex, sousPageIndex - 1)
            activeButtonPage2 = TrouverBoutonActif(.Pages(sousPageIndex), pageIndex, sousPageIndex)
            
            call ActiverBouton(.Pages(sousPageIndex - 1), pageIndex, sousPageIndex - 1, activeButtonPage2)
            call ActiverBouton(.Pages(sousPageIndex), pageIndex, sousPageIndex, activeButtonPage1)
            
        End With
        On Error GoTo 0
    End If
End Sub

Private Function TrouverBoutonActif(page As Object, pageIndex As Integer, sousPageIndex As Integer) As String
    If page.Controls("BTFTTH" & pageIndex & "-" & sousPageIndex).Value Then
        TrouverBoutonActif = "BTFTTH"
    ElseIf page.Controls("BTFTTE" & pageIndex & "-" & sousPageIndex).Value Then
        TrouverBoutonActif = "BTFTTE"
    ElseIf page.Controls("BTFTTO" & pageIndex & "-" & sousPageIndex).Value Then
        TrouverBoutonActif = "BTFTTO"
    ElseIf page.Controls("BT4G" & pageIndex & "-" & sousPageIndex).Value Then
        TrouverBoutonActif = "BT4G"
    ElseIf page.Controls("BTFTTH4G" & pageIndex & "-" & sousPageIndex).Value Then
        TrouverBoutonActif = "BTFTTH4G"
    ElseIf page.Controls("BTCUIVRE" & pageIndex & "-" & sousPageIndex).Value Then
        TrouverBoutonActif = "BTCUIVRE"
    ElseIf page.Controls("BTNA" & pageIndex & "-" & sousPageIndex).Value Then
        TrouverBoutonActif = "BTNA"
    Else
        TrouverBoutonActif = ""
    End If
End Function

Private Sub ActiverBouton(page As Object, pageIndex As Integer, sousPageIndex As Integer, bouton As String)
    ' D�sactiver tous les boutons d'abord
    page.Controls("BTFTTH" & pageIndex & "-" & sousPageIndex).Value = False
    page.Controls("BTFTTE" & pageIndex & "-" & sousPageIndex).Value = False
    page.Controls("BTFTTO" & pageIndex & "-" & sousPageIndex).Value = False
    page.Controls("BT4G" & pageIndex & "-" & sousPageIndex).Value = False
    page.Controls("BTFTTH4G" & pageIndex & "-" & sousPageIndex).Value = False
    page.Controls("BTCUIVRE" & pageIndex & "-" & sousPageIndex).Value = False
    page.Controls("BTNA" & pageIndex & "-" & sousPageIndex).Value = False
    
    If bouton <> "" Then
        page.Controls(bouton & pageIndex & "-" & sousPageIndex).Value = True
    End If
End Sub
