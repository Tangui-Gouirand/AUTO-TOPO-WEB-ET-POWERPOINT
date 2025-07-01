VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "ButtonHandler"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Public WithEvents Button As MSForms.CommandButton
Attribute Button.VB_VarHelpID = -1

Public Sub Button_Click()
    Dim ButtonTAG As String
    Dim pageIndex As Integer
    Dim sousPageIndex As Integer
    Dim parts() As String  ' Tableau pour stocker les parties du tag
    Dim PageAPRES As String
    Dim response As VbMsgBoxResult

    ButtonTAG = Button.Tag  ' RÃ©cupÃ©ration du Tag du bouton

    parts = Split(ButtonTAG, "-")

    If UBound(parts) >= 1 Then
        pageIndex = Val(parts(0))  ' Page du MultiPage principal
        sousPageIndex = Val(parts(1))  ' Sous-page
    End If


    If sousPageIndex > 0 Then
        response = MsgBox("Etes-vous sur de vouloir supprimer le site " & sousPageIndex & " du débit " & pageIndex & " ?", vbYesNo + vbQuestion, "Confirmation")
    Else
        response = MsgBox("Etes-vous sur de vouloir supprimer le débit " & pageIndex & " ?", vbYesNo + vbQuestion, "Confirmation")
    End If
    
    If response = vbNo Then Exit Sub

    If sousPageIndex > 0 Then
        Debug.Print "Je veux supprimer dans le debit " & pageIndex & " le site : " & sousPageIndex

        For i = sousPageIndex To FormCouleurs.MultiPage1.Pages(pageIndex).Controls("MultiPageSB" & pageIndex).Pages.Count - 1
            With FormCouleurs.MultiPage1.Pages(pageIndex).Controls("MultiPageSB" & pageIndex)
                ' Changer la légende de la page (caption)
                .Pages(i).Caption = "Site " & (i)

                ' S'assurer que l'on ne sort pas des limites du tableau de pages
                If i < .Pages.Count - 1 Then
                    ' Copie le texte du contréle suivant pour txtSiteName
                    PageAPRES = .Pages(i + 1).Controls("txtSiteName" & pageIndex & "-" & (i + 1)).Text
                    .Pages(i).Controls("txtSiteName" & pageIndex & "-" & i).Text = PageAPRES

                    ' Copie le texte du contréle suivant pour txtRefSatin
                    PageAPRES = .Pages(i + 1).Controls("txtRefSatin" & pageIndex & "-" & (i + 1)).Text
                    .Pages(i).Controls("txtRefSatin" & pageIndex & "-" & i).Text = PageAPRES

                    ' Copie le texte du contréle suivant pour txtRefRouteur
                    PageAPRES = .Pages(i + 1).Controls("txtRefRouteur" & pageIndex & "-" & (i + 1)).Text
                    .Pages(i).Controls("txtRefRouteur" & pageIndex & "-" & i).Text = PageAPRES

                    ' Déplacer l'état du bouton BTFTTH
                    If .Pages(i + 1).Controls("BTFTTH" & pageIndex & "-" & (i + 1)).Value = True Then
                        .Pages(i).Controls("BTFTTH" & pageIndex & "-" & i).Value = True
                    End If

                    ' Déplacer l'état du bouton BTFTTE
                    If .Pages(i + 1).Controls("BTFTTE" & pageIndex & "-" & (i + 1)).Value = True Then
                        .Pages(i).Controls("BTFTTE" & pageIndex & "-" & i).Value = True
                    End If

                    ' Déplacer l'état du bouton BTFTTO
                    If .Pages(i + 1).Controls("BTFTTO" & pageIndex & "-" & (i + 1)).Value = True Then
                        .Pages(i).Controls("BTFTTO" & pageIndex & "-" & i).Value = True
                    End If

                    ' Déplacer l'état du bouton BT4G
                    If .Pages(i + 1).Controls("BT4G" & pageIndex & "-" & (i + 1)).Value = True Then
                        .Pages(i).Controls("BT4G" & pageIndex & "-" & i).Value = True
                    End If

                    ' Déplacer l'état du bouton BTFTTH4G
                    If .Pages(i + 1).Controls("BTFTTH4G" & pageIndex & "-" & (i + 1)).Value = True Then
                        .Pages(i).Controls("BTFTTH4G" & pageIndex & "-" & i).Value = True
                    End If

                    ' Déplacer l'état du bouton BTCUIVRE
                    If .Pages(i + 1).Controls("BTCUIVRE" & pageIndex & "-" & (i + 1)).Value = True Then
                        .Pages(i).Controls("BTCUIVRE" & pageIndex & "-" & i).Value = True
                    End If

                    ' Déplacer l'état du bouton BTNA
                    If .Pages(i + 1).Controls("BTNA" & pageIndex & "-" & (i + 1)).Value = True Then
                        .Pages(i).Controls("BTNA" & pageIndex & "-" & i).Value = True
                    End If
                End If
            End With
        Next i

        ' Supprimer la derniere page
        With FormCouleurs.MultiPage1.Pages(pageIndex).Controls("MultiPageSB" & pageIndex)
            .Pages.Remove .Pages.Count - 1
        End With
    ElseIf sousPageIndex = 0 then
        Debug.Print "Je veux suprimmer le debit :" & pageIndex
        For i = 1 to FormCouleurs.MultiPage1.Pages(pageIndex).Controls("MultiPageSB" & pageIndex).Pages.Count - 1
            With FormCouleurs.MultiPage1.Pages(pageIndex).Controls("MultiPageSB" & pageIndex)
                .Pages.Remove 1
            End With
            DoEvents
        next i
        With FormCouleurs.MultiPage1
            .Pages.Remove pageIndex
        End With
    End If

    Dim topPosition As Double
    Dim leftPosition As Double
    For Each groupShape In selectedShape.GroupItems
        If InStr(groupShape.name, "blocOffre_") > 0 Then
            TypeOffrebloc = FormCouleurs.MultiPage1.Pages(0).Controls("TypeOffre").Text
            groupShape.TextFrame.TextRange.Text = TypeOffrebloc
            topPosition = groupShape.Top
            leftPosition = groupShape.Left
        End If
    Next groupShape
    
    If Not selectedShape Is Nothing Then
        selectedShape.Delete
    End If
    Module1.YPosition = topPosition + ConvertToPoints(0.2)
    Module1.XPosition = leftPosition
    Call Ajouter
End Sub

