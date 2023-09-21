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

' Returns whether or not passed value is valid
function isValid(input as dynamic) as boolean
  return input <> invalid
end function

function findNodesBySubtype(node, subtype)
  foundNodes = []

  for each child in node.getChildren(-1, 0)
    if lcase(child.subtype()) = "group"
      return findNodesBySubtype(child, subtype)
    end if

    if lcase(child.subtype()) = lcase(subtype)
      foundNodes.push(child)
    end if
  end for

  return foundNodes
end function

function findNodeBySubtype(parent, subtype)
  foundNodes = findNodesBySubtype(parent, subtype)
  if foundNodes.count() > 0
    return foundNodes[0]
  end if
  return invalid
end function

sub showErrorDialog(errorSource as string, errorCode as string)
  print "showErrorDialog()"
  errorMessage = m.global.utilities.callFunc("GetErrorMessage", { errorCode: errorCode, source: errorSource })
  print errorMessage

  font = createFont(24)

  m.dialog = createObject("roSGNode", "Dialog")
  m.dialog.title = recode("Ошибка")
  m.dialog.titleFont = font
  m.dialog.message = recode(errorMessage)
  m.dialog.messageFont = font
  m.top.dialog = m.dialog
end sub

function durationToString(durationSeconds as  Integer) as String
  second = durationSeconds MOD 60
  durationSeconds = durationSeconds \ 60
  minute = durationSeconds MOD 60
  durationSeconds = durationSeconds \ 60
  hour = durationSeconds MOD 60

  result = createObject("roString")
  if hour > 0
    if hour < 10
      AppendString(result, "0")
    end if

    hourString = hour.ToStr()
    AppendString(result, hourString)
  else
    AppendString(result, "00")
  end if

  AppendString(result, ":")

  if minute > 0
    if minute < 10
      AppendString(result, "0")
    end if
    minuteString = minute.ToStr()
    AppendString(result, minuteString)
  else
    AppendString(result, "00")
  end if

  AppendString(result, ":")

  if second > 0
    if second < 10
      AppendString(result, "0")
    end if
    secondString = second.ToStr()
    AppendString(result, secondString)
  else
    AppendString(result, "00")
  end if

  return result
end function
