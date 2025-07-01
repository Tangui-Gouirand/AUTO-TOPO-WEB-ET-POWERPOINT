Attribute VB_Name = "Module1"
Public EspacementVertical As Double
Public EspacementSousBlocs As Double
Public TypeOffrebloc As String
Public SiteData As Collection
Public TraiterDonnees As String
Public obj As MSForms.CommandButton

Public ButtonHandlers As Collection
Public handler As ButtonHandler

Public ButtonSpin As Collection
Public AddspinHandlers As ButtonSpin

Public ButtonAddSite As Collection
Public AddSiteHandlers As ButtonAddSite

Public ButtonDEBIT As Collection
Public DEBITHandlers As ButtonDEBIT

Public currentTime As String
Public selectedShape As Shape
Public compteurSite As Integer
Public I As Integer
Public b As Integer
Public TypeLienHex As String
Public YPosition As Double
Public XPosition As Double

Sub Legende()
    FormLegende.show
End Sub


Sub AjouterBlocsPersonnalises()
    Call ResetFormCouleurs
    Yposition = 0
    DoEvents
    currentTime = Format(Now, "yyyymmdd_hhnnss")
    Dim slide As slide
    Set slide = ActiveWindow.Selection.SlideRange(1)
    Dim isGroup As Boolean
    Dim blocDebitDictionnaire As Object
    Set blocDebitDictionnaire = CreateObject("Scripting.Dictionary")
    
    isGroup = False
    
    If ActiveWindow.Selection.Type = ppSelectionShapes Then
        Set selectedShape = ActiveWindow.Selection.ShapeRange(1)
        
        ' V�rification si c'est un groupe
        If selectedShape.Type = msoGroup Then
            isGroup = True
        End If
        
        If isGroup Then
            compteurSite = 0
            For Each groupShape In selectedShape.GroupItems
                If InStr(groupShape.Name, "blocOffre_") > 0 Then
                    TypeOffreBloc = groupShape.TextFrame.TextRange.Text
                    FormCouleurs.MultiPage1.Pages(0).Controls("TypeOffre").Text = TypeOffrebloc
                End If

                ' D�tection des blocs DEBIT et stockage des sous-blocs associ�s
                If InStr(groupShape.Name, "blocDEBIT_") > 0 Then
                    Dim pageIndex As Integer
                    pageIndex = Val(Split(groupShape.Name, "_")(1)) ' Extraction du num�ro de page
                    
                    ' Ajouter la page si elle n'existe pas d�j?
                    If Not blocDebitDictionnaire.Exists(pageIndex) Then
                        FormCouleurs.AddSITE pageIndex
                        blocDebitDictionnaire.Add pageIndex, CreateObject("Scripting.Dictionary")
                        TypeOffrebloc = groupShape.TextFrame.TextRange.Text

                        ' Utiliser une expression r�guli?re pour extraire le nombre et le texte
                        Dim regEx As Object
                        Set regEx = CreateObject("VBScript.RegExp")
                        regEx.IgnoreCase = True
                        regEx.Global = True
                        regEx.Pattern = "(\d+)([^\d]+)" ' Recherche d'un nombre suivi de texte
                        
                        Dim matches As Object
                        Set matches = regEx.Execute(TypeOffrebloc)
                        
                        If matches.Count > 0 Then
                            ' Si une correspondance est trouv�e
                            Debitbloc = matches(0).Submatches(0) ' Le chiffre
                            debitText = matches(0).Submatches(1) ' Le texte
                        Else
                            ' Si aucune correspondance n'est trouv�e, c'est que le texte est seul
                            Debitbloc = "" ' Pas de nombre
                            debitText = TypeOffrebloc ' Texte seul
                        End If
                        
                        ' Remplir les contr�les avec les valeurs extraites
                        FormCouleurs.MultiPage1.Pages(pageIndex).Controls("MultiPageSB" & pageIndex).Pages(0).Controls("txtDebit" & pageIndex).Text = Debitbloc
                        FormCouleurs.MultiPage1.Pages(pageIndex).Controls("MultiPageSB" & pageIndex).Pages(0).Controls("ComboBox" & pageIndex).Text = debitText
                    End If
                End If

                
                ' D�tection des sous-blocs associ�s ? un bloc DEBIT
                If InStr(groupShape.Name, "sousBloc1_") > 0 Then
                    Dim sousBlocInfo() As String
                    sousBlocInfo = Split(groupShape.Name, "_")
                    
                    Dim sousPageIndex As Integer
                    pageIndex = Val(sousBlocInfo(1))  ' Page du MultiPage principal
                    sousPageIndex = Val(sousBlocInfo(2))  ' Sous-page

                    ' Ajouter la sous-page si elle n'existe pas d�ja
                    If Not blocDebitDictionnaire(pageIndex).Exists(sousPageIndex) Then
                        FormCouleurs.AddSiteSB pageIndex
                        blocDebitDictionnaire(pageIndex).Add sousPageIndex, True
                        TypeOffrebloc = groupShape.TextFrame.TextRange.Text
                        FormCouleurs.MultiPage1.Pages(pageIndex).Controls("MultiPageSB" & pageIndex).Pages(sousPageIndex).Controls("txtSiteName" & pageIndex & "-" & sousPageIndex).Text = TypeOffrebloc
                        
                        TypeLienHex = RGBtoHex(groupShape.Fill.ForeColor.RGB)

                        On Error Resume Next
                        If TypeLienHex = "#D9C2F0" Then
                            FormCouleurs.MultiPage1.Pages(pageIndex).Controls("MultiPageSB" & pageIndex).Pages(sousPageIndex).Controls("BTFTTH" & pageIndex & "-" & sousPageIndex).Value = True
                        ElseIf TypeLienHex = "#FFF6B6" Then
                            FormCouleurs.MultiPage1.Pages(pageIndex).Controls("MultiPageSB" & pageIndex).Pages(sousPageIndex).Controls("BTFTTE" & pageIndex & "-" & sousPageIndex).Value = True
                        ElseIf TypeLienHex = "#B5E8F7" Then
                            FormCouleurs.MultiPage1.Pages(pageIndex).Controls("MultiPageSB" & pageIndex).Pages(sousPageIndex).Controls("BTFTTO" & pageIndex & "-" & sousPageIndex).Value = True
                        ElseIf TypeLienHex = "#FFB571" Then
                            FormCouleurs.MultiPage1.Pages(pageIndex).Controls("MultiPageSB" & pageIndex).Pages(sousPageIndex).Controls("BT4G" & pageIndex & "-" & sousPageIndex).Value = True
                        ElseIf TypeLienHex = "#FFE8F7" Then
                            FormCouleurs.MultiPage1.Pages(pageIndex).Controls("MultiPageSB" & pageIndex).Pages(sousPageIndex).Controls("BTFTTH4G" & pageIndex & "-" & sousPageIndex).Value = True
                        ElseIf TypeLienHex = "#B8EBD6" Then
                            FormCouleurs.MultiPage1.Pages(pageIndex).Controls("MultiPageSB" & pageIndex).Pages(sousPageIndex).Controls("BTCUIVRE" & pageIndex & "-" & sousPageIndex).Value = True
                        ElseIf TypeLienHex = "#E4E4E4" Then
                            FormCouleurs.MultiPage1.Pages(pageIndex).Controls("MultiPageSB" & pageIndex).Pages(sousPageIndex).Controls("BTNA" & pageIndex & "-" & sousPageIndex).Value = True
                        End If
                        On Error GoTo 0

                    End If
                End If
                If InStr(groupShape.Name, "sousBloc2_") > 0 Then
                    TypeOffrebloc = groupShape.TextFrame.TextRange.Text
                    FormCouleurs.MultiPage1.Pages(pageIndex).Controls("MultiPageSB" & pageIndex).Pages(sousPageIndex).Controls("txtRefSatin" & pageIndex & "-" & sousPageIndex).Text = TypeOffrebloc
                End If
                If InStr(groupShape.Name, "sousBloc3_") > 0 Then
                    TypeOffrebloc = groupShape.TextFrame.TextRange.Text
                    FormCouleurs.MultiPage1.Pages(pageIndex).Controls("MultiPageSB" & pageIndex).Pages(sousPageIndex).Controls("txtRefRouteur" & pageIndex & "-" & sousPageIndex).Text = TypeOffrebloc
                End If
            Next groupShape
        End If

        For i=1 To FormCouleurs.MultiPage1.Pages.Count - 1
            If FormCouleurs.MultiPage1.Pages(i).Controls("MultiPageSB" & i).Pages(0).Controls("txtDebit" & i).Text <> "" Then
                FormCouleurs.MultiPage1.Pages(i).Caption = FormCouleurs.MultiPage1.Pages(i).Controls("MultiPageSB" & i).Pages(0).Controls("txtDebit" & i).Text & FormCouleurs.MultiPage1.Pages(i).Controls("MultiPageSB" & i).Pages(0).Controls("ComboBox" & i).Text
            Else
                FormCouleurs.MultiPage1.Pages(i).Caption = "DEBIT " & i
            End If
        Next i
        
        ' Afficher FormCouleurs avec le bouton Modifier
        FormCouleurs.btnModifier.Visible = True
        FormCouleurs.Show

    Else
        ' Si aucune s�lection, afficher FormCouleurs en mode ajout par d�faut
        FormCouleurs.btnAjouter.Visible = True
        If FormCouleurs Is Nothing Then
            Load FormCouleurs
        End If
        Module1.YPosition = ConvertToPoints(1)
        Module1.XPosition = ConvertToPoints(1)

        Dim reponse As VbMsgBoxResult
        reponse = MsgBox("Voulez-vous importer un fichier de configuration ?", vbYesNo + vbQuestion, "Importer Configuration")
        If reponse = vbYes Then
            FormCouleurs.ImporterCodeConf
        ElseIf reponse = vbNo Then
            ' Call FormCouleurs.DefaultSITE
            FormCouleurs.Show
        End if
    End If
End Sub

Public Function ConvertToPoints(cm As Double) As Double
    ConvertToPoints = cm * 28.35
End Function

Public Sub RedimensionnerBlocPrincipal()
    Dim nbSites As Integer
    nbSites = SiteData.Count
    Dim hauteurBloc As Double
    Dim groupShape As Shape
    Dim NombreDebits As Integer, NombreNoms As Integer, i As Integer
    NombreDebits = 0
    NombreNoms = 0

    For i = 1 To SiteData.Count
        If Trim(SiteData(i)("DEBIT")) <> "" Then
            NombreDebits = NombreDebits + 1
        End If
        If Trim(SiteData(i)("Nom")) <> "" Then
            NombreNoms = NombreNoms + 1
        End If
    Next i
    
    For Each groupShape In selectedShape.GroupItems
        If InStr(groupShape.Name, "blocPrincipal_") > 0 Then
            hauteurBloc = (NombreDebits * 0.4) + (NombreNoms * 1.6) + (nbSites * 0.2) + 0.2
            groupShape.Height = ConvertToPoints(hauteurBloc)
            Exit For
        End If
    Next groupShape
End Sub

Sub ResetFormCouleurs()
    FormCouleurs.TypeOffre.Value = ""
    Dim i As Integer
    With FormCouleurs.MultiPage1
        For i = .Pages.Count - 1 To 1 Step -1
            .Pages.Remove i
        Next i
    End With
    FormCouleurs.btnModifier.Visible = False
    FormCouleurs.btnAjouter.Visible = False
    DoEvents
End Sub

Function ExtraireNumeroBloc(blocName As String) As Integer
    Dim matches As Object
    Dim regex As Object
    Set regex = CreateObject("VBScript.RegExp")
    
    regex.Pattern = "blocDEBIT_(\d+)_\d{8}_\d{6}"
    regex.Global = False
    
    If regex.Test(blocName) Then
        Set matches = regex.Execute(blocName)
        ExtraireNumeroBloc = CInt(matches(0).SubMatches(0))
    Else
        ExtraireNumeroBloc = 0
    End If
End Function

Function ExtraireNumeroPageSousBloc(sousBlocName As String) As Integer
    Dim matches As Object
    Dim regex As Object
    Set regex = CreateObject("VBScript.RegExp")
    
    regex.Pattern = "sousBloc(\d+)_(\d+)_\d{8}_\d{6}"
    regex.Global = False
    
    If regex.Test(sousBlocName) Then
        Set matches = regex.Execute(sousBlocName)
        ExtraireNumeroPageSousBloc = CInt(matches(0).SubMatches(0))
    Else
        ExtraireNumeroPageSousBloc = 0
    End If
End Function

Function ExtraireNumeroSousBloc(sousBlocName As String) As Integer
    Dim matches As Object
    Dim regex As Object
    Set regex = CreateObject("VBScript.RegExp")
    
    regex.Pattern = "sousBloc\d+_(\d+)_\d{8}_\d{6}"
    regex.Global = False
    
    If regex.Test(sousBlocName) Then
        Set matches = regex.Execute(sousBlocName)
        ExtraireNumeroSousBloc = CInt(matches(0).SubMatches(0))
    Else
        ExtraireNumeroSousBloc = 0
    End If
End Function


Public Sub AjouterNomClient(ByVal nomClientText As String)
    Dim sld As Slide
    Dim shp As Shape

    If ActiveWindow Is Nothing Then Exit Sub

    Set sld = ActiveWindow.Selection.SlideRange(1)
    Set shp = sld.Shapes.AddTextbox(msoTextOrientationHorizontal, _
                                     Left:=ConvertToPoints(22.87), _
                                     Top:=ConvertToPoints(0.5), _
                                     Width:=ConvertToPoints(10), _
                                     Height:=ConvertToPoints(1))
    shp.TextFrame.TextRange.Text = nomClientText
    With shp.TextFrame.TextRange.Font
        .Name = "Helvetica 75 Bold"
        .Size = 18
        .Bold = True
        .Color.RGB = RGB(0, 0, 0)
    End With
    shp.Name = "NomClientShape"
End Sub



Public Sub GenererLegendeAutomatiquement(technologies As Object)
    Dim cleTechno As Variant
    Dim nomCheckbox As String

    If technologies.Count = 0 Then Exit Sub

    For Each cleTechno In technologies.Keys
        nomCheckbox = ""
        
        Select Case UCase(CStr(cleTechno))
            Case "FTTH"
                nomCheckbox = "chkFTTH"
            Case "FTTE"
                nomCheckbox = "chkFTTE"
            Case "FTTO"
                nomCheckbox = "chkFTTO"
            Case "4G"
                nomCheckbox = "chk4G"
            Case "FTTH4G"
                nomCheckbox = "chkFTTH4G"
            Case "CUIVRE"
                nomCheckbox = "chkCUIVRE"
            Case "NA"
                nomCheckbox = "chkNA"
        End Select

        If nomCheckbox <> "" Then
            FormLegende.Controls(nomCheckbox).Value = True
        End If
    Next cleTechno

    Call FormLegende.VALIDER_Click
End Sub