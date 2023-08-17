sub loadFonts()
  m.font24  = CreateObject("roSGNode", "Font")
  m.font24.uri = "pkg:/fonts/NotoSans-Regular-w1251-rename.ttf"
  m.font24.size = 24

  m.font18  = CreateObject("roSGNode", "Font")
  m.font18.uri = "pkg:/fonts/NotoSans-Regular-w1251-rename.ttf"
  m.font18.size = 18

  m.font16  = CreateObject("roSGNode", "Font")
  m.font16.uri = "pkg:/fonts/NotoSans-Regular-w1251-rename.ttf"
  m.font16.size = 16

  m.font12  = CreateObject("roSGNode", "Font")
  m.font12.uri = "pkg:/fonts/NotoSans-Regular-w1251-rename.ttf"
  m.font12.size = 12
end sub

function recode(str as string) as string
  str = str.Replace("&#151;", "-")
  str = str.Replace("&#133;", "...")
  return m.global.utilities.callFunc("Encode", {str: str})
end function
