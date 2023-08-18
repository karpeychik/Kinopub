sub loadFonts()
  m.font24 = createFont(24)
  m.font16 = createFont(16)
  m.font12 = createFont(12)
end sub

function createFont(size as integer) as object
  font = CreateObject("roSGNode", "Font")
  font.uri = "pkg:/fonts/NotoSans-Regular-w1251-rename.ttf"
  font.size = size
  return font
end function

sub AppendString(str as string, addition as string)
  str.AppendString(addition, addition.Len())
end sub

function recode(str as string) as string
  str = str.Replace("&#151;", "-")
  str = str.Replace("&#133;", "...")
  return m.global.utilities.callFunc("Encode", {str: str})
end function
