VERSION 5.00
Begin {C62A69F0-16DC-11CE-9E98-00AA00574A4F} FormLegende
    Caption         =   "Legende Topo"
    ClientHeight    =   5340
    ClientLeft      =   108
    ClientTop       =   456
    ClientWidth     =   3108
    OleObjectBlob   =   "FormLegende.frx":0000
    StartUpPosition =   1   'CenterOwner
End
Attribute VB_Name = "FormLegende"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False


Public Sub VALIDER_Click()

    Dim slide As Slide
    Dim formeNoire As Shape
    Dim nomOption As Variant
    Dim couleurHex As String
    Dim couleurRGB As Long
    Dim nouvelleForme As Shape
    Dim leftPosition As Single
    Dim topPosition As Single
    Dim largeurBloc As Single
    Dim hauteurBloc As Single
    Dim espaceEntreBlocs As Single
    Dim selections As Object
    Dim cle As Variant
    Dim nombreOptionsCochees As Integer
    Dim hauteurTotaleBlocs As Single
    Dim margeHautBas As Single
    Dim positionBasNoir As Single
    Dim positionHautNoir As Single

    Dim shapesToGroup As Collection
    Set shapesToGroup = New Collection

    Set slide = ActiveWindow.Selection.SlideRange(1)

    largeurBloc = ConvertToPoints(1.8)
    hauteurBloc = ConvertToPoints(0.6)
    espaceEntreBlocs = ConvertToPoints(0.1)
    margeHautBas = ConvertToPoints(0.1)

    positionBasNoir = ConvertToPoints(14)

    nombreOptionsCochees = 0
    For Each cle In Array("chkFTTH", "chkFTTE", "chkFTTO", "chk4G", "chkFTTH4G", "chkCUIVRE", "chkNA")
        If Me.Controls(cle).Value = True Then
            nombreOptionsCochees = nombreOptionsCochees + 1
        End If
    Next cle

    hauteurTotaleBlocs = (nombreOptionsCochees * hauteurBloc) + ((nombreOptionsCochees - 1) * espaceEntreBlocs)
    hauteurBlocNoir = hauteurTotaleBlocs + (2 * margeHautBas)
    positionHautNoir = positionBasNoir - hauteurBlocNoir
    largeurBlocNoir = ConvertToPoints(2)
    positionGaucheNoir = ConvertToPoints(23.10)

    Set formeNoire = slide.Shapes.AddShape(msoShapeRoundedRectangle, positionGaucheNoir, positionHautNoir, largeurBlocNoir, hauteurBlocNoir)
    With formeNoire
        .Fill.ForeColor.RGB = RGB(0, 0, 0)
        .Line.Weight = 1
        .Line.ForeColor.RGB = HexToRGB("#FF7900")
        .Adjustments.Item(1) = 0.06
        .Name = currentTime & "0"
    End With
    shapesToGroup.Add formeNoire

    leftPosition = positionGaucheNoir + ConvertToPoints(0.1)
    topPosition = positionHautNoir + margeHautBas

    Set selections = CreateObject("Scripting.Dictionary")
    selections.Add "chkFTTH", Array("FTTH", "#D9C2F0")
    selections.Add "chkFTTE", Array("FTTE", "#FFF6B6")
    selections.Add "chkFTTO", Array("FTTO", "#B5E8F7")
    selections.Add "chk4G", Array("4G", "#FFB571")
    selections.Add "chkFTTH4G", Array("FTTH4G", "#FFE8F7")
    selections.Add "chkCUIVRE", Array("CUIVRE", "#B8EBD6")
    selections.Add "chkNA", Array("NA", "#E4E4E4")

    For Each cle In selections.Keys
        If Me.Controls(cle).Value = True Then
            nomOption = selections(cle)(0)
            couleurHex = selections(cle)(1)
            couleurRGB = HexToRGB(couleurHex)
            Set nouvelleForme = slide.Shapes.AddShape(msoShapeRoundedRectangle, leftPosition, topPosition, largeurBloc, hauteurBloc)
            With nouvelleForme
                .Fill.ForeColor.RGB = couleurRGB
                .Line.Visible = msoFalse
                .Adjustments.Item(1) = 0.06
                .TextFrame2.AutoSize = msoAutoSizeTextToFitShape
                .TextFrame.TextRange.Text = nomOption
                .TextFrame.TextRange.Font.Name = "Helvetica 75 Bold"
                .Name = currentTime & couleurHex
            End With
            shapesToGroup.Add nouvelleForme
            topPosition = topPosition + hauteurBloc + espaceEntreBlocs
        End If
    Next cle

    If shapesToGroup.Count > 1 Then
        Dim j As Integer
        Dim shapeNames() As String
        ReDim shapeNames(1 To shapesToGroup.Count)

        For j = 1 To shapesToGroup.Count
            On Error Resume Next
            shapeNames(j) = shapesToGroup(j).Name
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
            EndIf
            On Error GoTo 0
        EndIf
    End If

    Me.Hide

End Sub