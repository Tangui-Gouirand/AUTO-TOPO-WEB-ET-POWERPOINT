Attribute VB_Name = "CouleursTo"

Public Function HexToRGB(hexColor As String) As Long
    Dim r As Long, g As Long, b As Long
    hexColor = Replace(hexColor, "#", "")
    r = CLng("&H" & Mid(hexColor, 1, 2))
    g = CLng("&H" & Mid(hexColor, 3, 2))
    b = CLng("&H" & Mid(hexColor, 5, 2))
    HexToRGB = RGB(r, g, b)
End Function

Public Function RGBtoHex(RGBColor As Long) As String
    Dim r As Long, g As Long, b As Long
    r = (RGBColor Mod 256)
    g = (RGBColor \ 256) Mod 256
    b = (RGBColor \ 65536) Mod 256
    RGBtoHex = "#" & Right("00" & Hex(r), 2) & Right("00" & Hex(g), 2) & Right("00" & Hex(b), 2)
End Function