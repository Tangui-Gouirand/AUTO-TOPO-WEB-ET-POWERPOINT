VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "ButtonDEBIT"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Public WithEvents TESTTEXTBOX As MSForms.TextBox
Public WithEvents TESTTEXTBOXDEBIT As MSForms.ComboBox

Private Sub TESTTEXTBOX_Change()
    Dim pageIndex As Integer
    pageIndex = CInt(TESTTEXTBOX.Tag)
    FormCouleurs.MultiPage1.Pages(pageIndex).Caption = TESTTEXTBOX.Text & FormCouleurs.MultiPage1.Pages(pageIndex).Controls("ComboBox" & pageIndex).text
End Sub

Private Sub TESTTEXTBOXDEBIT_Change()
    Dim pageIndex As Integer
    pageIndex = CInt(TESTTEXTBOXDEBIT.Tag)
    FormCouleurs.MultiPage1.Pages(pageIndex).Caption = FormCouleurs.MultiPage1.Pages(pageIndex).Controls("txtDebit" & pageIndex).text & TESTTEXTBOXDEBIT.text
End Sub