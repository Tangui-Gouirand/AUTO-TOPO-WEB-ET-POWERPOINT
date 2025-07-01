Attribute VB_Name = "Creation"


Public HauteurBlocPrincipal As Double

Public Sub Ajouter()
    Call FormCouleurs.btnAppliquer_Click
    DoEvents
    Dim slide As Slide
    Set slide = ActiveWindow.Selection.SlideRange(1)

    ' Constantes pour les espacements (plus lisible)
    Const EspacementVertical As Double = 0.2
    Const EspacementSousBlocs As Double = 0.1

    ' Calculer la hauteur du bloc principal (plus lisible)

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

    HauteurBlocPrincipal = (0.35 + (NombreDebits * 0.38) + (NombreDebits * EspacementSousBlocs)/2 + (NombreNoms * 0.6) + (NombreNoms * EspacementSousBlocs)/2 )

    Dim ListeFormes As Collection
    Set ListeFormes = New Collection


    ' Ajouter le bloc principal
    Dim blocPrincipal As Shape
    Set blocPrincipal = slide.Shapes.AddShape(msoShapeRoundedRectangle, XPosition - ConvertToPoints(0.1), YPosition, ConvertToPoints(4.2), ConvertToPoints(HauteurBlocPrincipal))
    With blocPrincipal
        .Fill.ForeColor.RGB = RGB(0, 0, 0)
        .Line.Weight = 1
        .Line.ForeColor.RGB = HexToRGB("#FF7900")
        .Adjustments.Item(1) = 0.04
        .Name = "blocPrincipal_" & currentTime
    End With
    ListeFormes.Add blocPrincipal

    ' Ajouter le bloc Offre
    Dim blocOffre As Shape
    Set blocOffre = slide.Shapes.AddShape(msoShapeRoundedRectangle, XPosition, YPosition - ConvertToPoints(0.15), ConvertToPoints(4), ConvertToPoints(0.38))
    With blocOffre
        .Fill.ForeColor.RGB = HexToRGB("#FF7900")
        .Line.Weight = 1
        .Line.ForeColor.RGB = RGB(0, 0, 0)
        .Adjustments.Item(1) = 0.15
        .TextFrame.TextRange.Text = TypeOffrebloc
        .TextFrame.TextRange.Font.Name = "Helvetica 75 Bold"
        .TextFrame.TextRange.Font.Size = 8
        .TextFrame2.AutoSize = msoAutoSizeTextToFitShape
        .TextFrame.MarginBottom = 0
        .TextFrame.MarginLeft = 0
        .TextFrame.MarginRight = 0
        .TextFrame.MarginTop = 0
        .TextFrame.TextRange.Font.Color.RGB = HexToRGB("#000000")
        .Name = "blocOffre_" & currentTime
    End With
    ListeFormes.Add blocOffre

    YPosition = YPosition + ConvertToPoints(0.3)
    
    Dim couleurParTypeLien As Object
    Set couleurParTypeLien = CreateObject("Scripting.Dictionary")

    couleurParTypeLien.Add "FTTH", "#D9C2F0"
    couleurParTypeLien.Add "FTTE", "#FFF6B6"
    couleurParTypeLien.Add "FTTO", "#B5E8F7"
    couleurParTypeLien.Add "4G", "#ffb571"
    couleurParTypeLien.Add "FTTH4G", "#FFE8F7"
    couleurParTypeLien.Add "CUIVRE", "#B8EBD6"
    couleurParTypeLien.Add "NA", "#E4E4E4"


    DIM NUMDEBIT AS Integer
    NUMDEBIT = 1
    DIM PAGESB AS Integer
     
    ' Ajouter les sous-blocs pour chaque site dans SiteData
    For i = 1 To SiteData.Count
        If SiteData(i).Exists("DEBIT") And SiteData(i)("DEBIT") <> "" Then
            Dim blocDEBIT As Shape
            Set blocDEBIT = slide.Shapes.AddShape(msoShapeRoundedRectangle, XPosition, YPosition, ConvertToPoints(4), ConvertToPoints(0.38))
            With blocDEBIT
                .Fill.ForeColor.RGB = RGB(0, 0, 0)
                .Line.Weight = 1
                .Line.ForeColor.RGB = HexToRGB("#FF7900")
                .Adjustments.Item(1) = 0.15
                .TextFrame.TextRange.Text = SiteData(i)("DEBIT")
                .TextFrame.TextRange.Font.Name = "Helvetica 75 Bold"
                .TextFrame.TextRange.Font.Size = 8
                .TextFrame2.AutoSize = msoAutoSizeTextToFitShape
                .TextFrame.MarginBottom = 0
                .TextFrame.MarginLeft = 0
                .TextFrame.MarginRight = 0
                .TextFrame.MarginTop = 0
                .TextFrame.TextRange.Font.Color.RGB = HexToRGB("#FF7900")
                .Name = "blocDEBIT_" & NUMDEBIT & "_" & currentTime
            End With
            PAGESB = 1
            NUMDEBIT = NUMDEBIT + 1
            ListeFormes.Add blocDEBIT
            YPosition = YPosition + ConvertToPoints(0.43)
        Else
            If SiteData(i).Exists("Nom") And SiteData(i)("Nom") <> "" Then
                Dim typeLien As String
                typeLien = SiteData(i)("TypeLien")
                Dim couleurSite As String
                If couleurParTypeLien.Exists(typeLien) Then
                    couleurSite = couleurParTypeLien(typeLien)
                Else
                    couleurSite = "#808080" ' Gris par d�faut si non d�fini
                End If

                Dim sousBloc1 As Shape
                Set sousBloc1 = slide.Shapes.AddShape(msoShapeRoundedRectangle, XPosition, YPosition, ConvertToPoints(2.5), ConvertToPoints(0.6))
                With sousBloc1
                    .Fill.ForeColor.RGB = HexToRGB(couleurSite)
                    .Adjustments.Item(1) = 0.15
                    .TextFrame.TextRange.Text = SiteData(i)("Nom")
                    .TextFrame.TextRange.Font.Name = "Helvetica 75 Bold"
                    .TextFrame.TextRange.Font.Size = 9
                    .TextFrame.TextRange.Font.Color.RGB = RGB(0, 0, 0)
                    .TextFrame.TextRange.ParagraphFormat.Alignment = msoAlignLeft
                    .TextFrame2.AutoSize = msoAutoSizeTextToFitShape
                    .TextFrame.MarginBottom = 0
                    .TextFrame.MarginTop = 0
                    .Line.Visible = msoFalse
                    .Name = "sousBloc1_" & NUMDEBIT-1 & "_" & PAGESB & "_" & currentTime
                End With
                Dim sousBloc2 As Shape
                Set sousBloc2 = slide.Shapes.AddShape(msoShapeRoundedRectangle, XPosition + ConvertToPoints(2.54), YPosition, ConvertToPoints(1.45), ConvertToPoints(0.28))
                With sousBloc2
                    .Fill.ForeColor.RGB = HexToRGB(couleurSite)
                    .Adjustments.Item(1) = 0.15
                    .TextFrame.TextRange.Text = SiteData(i)("RefSatin")
                    .TextFrame.TextRange.Font.Name = "Helvetica 75 Bold"
                    .TextFrame.TextRange.Font.Size = 6
                    .TextFrame.TextRange.Font.Color.RGB = RGB(0, 0, 0)
                    .TextFrame2.AutoSize = msoAutoSizeTextToFitShape
                    .TextFrame.MarginBottom = 0
                    .TextFrame.MarginLeft = 0
                    .TextFrame.MarginRight = 0
                    .TextFrame.MarginTop = 0
                    .TextFrame.WordWrap = False
                    .Line.Visible = msoFalse
                    .Name = "sousBloc2_" & NUMDEBIT-1 & "_" & PAGESB & "_" & currentTime
                End With
                Dim sousBloc3 As Shape
                Set sousBloc3 = slide.Shapes.AddShape(msoShapeRoundedRectangle, XPosition + ConvertToPoints(2.54), YPosition + ConvertToPoints(0.32), ConvertToPoints(1.45), ConvertToPoints(0.28))
                With sousBloc3
                    .Fill.ForeColor.RGB = HexToRGB(couleurSite)
                    .Adjustments.Item(1) = 0.15
                    .TextFrame.TextRange.Text = SiteData(i)("RefRouteur")
                    .TextFrame.TextRange.Font.Name = "Helvetica 75 Bold"
                    .TextFrame.TextRange.Font.Size = 6
                    .TextFrame.TextRange.Font.Color.RGB = RGB(0, 0, 0)
                    .TextFrame2.AutoSize = msoAutoSizeTextToFitShape
                    .TextFrame.MarginBottom = 0
                    .TextFrame.MarginLeft = 0
                    .TextFrame.MarginRight = 0
                    .TextFrame.MarginTop = 0
                    .TextFrame.WordWrap = False
                    .Line.Visible = msoFalse
                    .Name = "sousBloc3_" & NUMDEBIT-1 & "_" & PAGESB & "_" & currentTime
                End With
                ListeFormes.Add sousBloc1
                ListeFormes.Add sousBloc2
                ListeFormes.Add sousBloc3
                PAGESB =  PAGESB +1
                YPosition = YPosition + ConvertToPoints(0.65)
            End If
        End If
    Next i
    If ListeFormes.Count > 1 Then
        Dim j As Integer
        Dim shapeNames() As String
        ReDim shapeNames(1 To ListeFormes.Count)
        Debug.Print "Nombre de formes dans ListeFormes : " & ListeFormes.Count

        For j = 1 To ListeFormes.Count
            On Error Resume Next
            shapeNames(j) = ListeFormes(j).Name
            If Err.Number <> 0 Then
                Debug.Print "Erreur lors de la récupération du nom de la forme à l'index " & j & " : " & Err.Description
                Err.Clear
            End If
            On Error GoTo 0
        Next j

        If UBound(shapeNames) > 0 Then
            On Error Resume Next
            slide.Shapes.Range(shapeNames).Group
            If Err.Number <> 0 Then
                Debug.Print "Erreur lors du groupement des formes : " & Err.Description
                Dim k As Integer
                Dim invalidShapeName As Boolean
                invalidShapeName = False
                For k = LBound(shapeNames) To UBound(shapeNames)
                    If slide.Shapes.Item(shapeNames(k)) Is Nothing Then
                        Debug.Print "Nom de forme invalide trouvé : " & shapeNames(k)
                        invalidShapeName = True
                        Exit For
                    End If
                Next k
                If invalidShapeName Then
                    Debug.Print "Le groupement n'a pas pu être effectué en raison de noms de formes invalides."
                End If
                Err.Clear
            End If
            On Error GoTo 0
        Else
            Debug.Print "Avertissement : UBound(shapeNames) n'est pas supérieur à 0. Aucune forme à grouper."
        End If
    Else
        Debug.Print "Avertissement : ListeFormes contient " & ListeFormes.Count & " élément(s). Au moins 2 formes sont nécessaires pour le groupement."
    End If
End Sub