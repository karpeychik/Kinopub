sub init()
    print "Authenticator:init"
    
    m.readContentTask = createObject("roSGNode", "ContentReader")
    m.readContentTask.observeField("content", "codeReceived")
    m.readContentTask.baseUrl = "https://api.service-kp.com/v1/types"
    m.readContentTask.requestType = "POST"
    
    m.readContentTask.parameters = ["grant_type", "device_code", "client_id", "xbmc", "client_secret", "cgg3gtifu46urtfp2zp1nqtba0k2ezxh"]
    m.readContentTask.control = "RUN"
    
end sub

sub codeReceived()
    print m.readContentTask.content
    
    m.code = m.readContentTask.content.code
    userCode = m.readContentTask.content.user_code
    verificationUrl = m.readContentTask.content.verification_uri
    interval = m.readContentTask.content.interval
    
    deviceInfo = CreateObject("roDeviceInfo")
    resolution = deviceInfo.GetDisplaySize()
    
    m.largeFont  = CreateObject("roSGNode", "Font")
    m.largeFont.uri = "pkg:/fonts/NotoSans-Regular-w1251-rename.ttf"
    m.largeFont.size = 40
    
    m.mediumFont  = CreateObject("roSGNode", "Font")
    m.mediumFont.uri = "pkg:/fonts/NotoSans-Regular-w1251-rename.ttf"
    m.mediumFont.size = 18
    
    m.mLFont  = CreateObject("roSGNode", "Font")
    m.mLFont.uri = "pkg:/fonts/NotoSans-Regular-w1251-rename.ttf"
    m.mLFont.size = 25
    
    m.veryLargeFont  = CreateObject("roSGNode", "Font")
    m.veryLargeFont.uri = "pkg:/fonts/NotoSans-Regular-w1251-rename.ttf"
    m.veryLargeFont.size = 70
    
    fullWidth = resolution.w
    fullHeight = resolution.h
    
    rectWidth = fullWidth * 0.6
    rectHeight = fullHeight * 0.6
    
    rect = createObject("roSGNode", "Rectangle")
    rect.translation = [fullWidth/2 - rectWidth/2, fullHeight/2 - rectHeight/2]
    rect.width = rectWidth
    rect.height = rectHeight
    rect.opacity = 0.4
    rect.color = "#000000"
    
    group = createObject("roSGNode", "LayoutGroup")
    group.addItemSpacingAfterChild =  false
    group.translation = rect.translation
    group.itemSpacings = [ 20, 30, 30, 30 ]
    group.horizAlignment = "custom"
    
    addLabel(group, "Регистрация устройства", 1, m.largeFont, 0, 0, rectWidth)
    addLabel(group, "В браузере перейдите на "+verificationUrl+" и добавьте устройство, используя код:", 3, m.mediumFont, 0, 0, rectWidth - 40)
    addLabel(group, userCode, 1, m.veryLargeFont, 0, 0, rectWidth)
    
    buttonWidth = rectWidth / 2
    buttonHeight = 55
    
    button = createObject("roSGNode", "Button")
    button.minWidth = buttonWidth
    button.maxWidth = buttonWidth
    button.height = buttonHeight
    button.showFocusFootprint = false
    button.focusBitmapUri = ""
    button.focusFootprintBitmapUri = ""
    button.iconUri = ""
    button.focusedIconUri = ""
    
    buttonLabel = createObject("roSGNode", "Label")
    buttonLabel.text = recode("Получить новый код")
    buttonLabel.font = m.mLFont
    buttonLabel.width = buttonWidth
    buttonLabel.height = buttonHeight
    buttonLabel.color = "#000000"
    buttonLabel.horizAlign = "center"
    buttonLabel.vertAlign = "center"
    button.appendChild(buttonLabel)
    
    group.appendChild(button)
    button.translation = [rectWidth/2 - buttonWidth/2, 0]
    
    m.top.appendChild(rect)
    m.top.appendChild(group)
    
    button.setFocus(true)
end sub

sub addLabel(group as Object, text as String, maxLines as Integer, fnt as Object, x as Integer, y as Integer, labelWidth as Integer)
    print "Authenticator:addLabel"
    label = createObject("roSGNode", "Label")
    label.height = 0
    label.numLines = 0
    label.maxLines = maxLines
    label.font = fnt
    label.translation = [x, y]
    label.wrap = true
    label.width = labelWidth
    label.color = "#FFFFFF"
    label.lineSpacing = 1
    label.wordBreakChars = " ,-:."
    label.text = recode(text)
    label.horizAlign = "center"
    group.appendChild(label) 
end sub

sub recode(str as string) as string
    str = str.Replace("&#151;", "-")
    str = str.Replace("&#133;", "...")
    return m.global.utilities.callFunc("Encode", {str: str})
end sub