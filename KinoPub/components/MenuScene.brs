'TODO: Make this async
'TODO: custom overhang

sub init()
    print "MenuScene: Init"

    utilities = createObject("roSGNode", "Utilities")
    m.global.addFields({utilities: utilities})

    m.top.overhang.visible = false
    m.top.panelset.visible = false
    m.top.panelSet.observeField("isGoingBack","slideBack")

    start()

end sub

sub start()
    date = createObject("roDateTime")
    print "CurrentTime: " + date.AsSeconds().ToStr()

    sec = createObject("roRegistrySection", "Authentication")
    if sec.Exists("AuthenticationToken") and sec.Exists("RefreshToken") and sec.Exists("TokenExpiration") and sec.Exists("TokenType")
        authToken = sec.Read("AuthenticationToken")
        refreshToken = sec.Read("RefreshToken")
        expiry = sec.Read("TokenExpiration")
        tokenType = sec.Read("TokenType")

        m.global.addFields({accessToken: authToken, refreshToken: refreshToken, tokenExpiration: expiry.ToInt()})

        print "Current auth:"
        print "AuthToken: " + authToken
        print "RefreshToken: " + refreshToken
        print "Expiration:" + expiry
        print "TokenType:" + tokenType
        deviceNotify()
    else
        print "Auth not found..."
        showAuthentication()
    end if

end sub

sub showAuthentication()
    m.authenticator = m.top.createChild("Authenticator")
    m.authenticator.observeField("access_token", "authenticated")
end sub

sub authenticated()
    print "MenuScene:authenticated()"
    sec = createObject("roRegistrySection", "Authentication")
    sec.Write("AuthenticationToken", m.authenticator.access_token)
    sec.Write("RefreshToken", m.authenticator.refresh_token)
    sec.Write("TokenExpiration", m.authenticator.token_expiration.ToStr())
    sec.Write("TokenType", m.authenticator.token_type)
    sec.Flush()
    m.top.removeChild(m.authenticator)

    m.global.addFields({accessToken: m.authenticator.access_token, refreshToken: m.authenticator.refresh_token, tokenExpiration: m.authenticator.token_expiration})

    deviceNotify()
end sub

sub startPanels()
    print "MenuScene:startPanels()"

    m.top.overhang.visible = true
    m.top.panelset.visible = true

    panel = m.top.panelSet.createChild("CategoriesListPanel")

    m.panelArray = createObject("roArray", 14, false)
    m.panelArray[0] = panel

    m.panelArray[0].panelSet = m.top.panelSet
    m.panelArray[0].pType = ""
    m.panelArray[0].nPanel = invalid
    m.panelArray[0].observeField("nPanel","nPanelAdded")
    m.panelArray[0].observeField("dialog","dialogAdded")
    m.panelArray[0].start = true
end sub

sub deviceNotify()
    print "MenuScene:deviceNotify()"

    deviceInfo = createObject("roDeviceInfo")

    m.deviceNotifyTask = createObject("roSGNode", "ContentReader")
    m.deviceNotifyTask.baseUrl = "https://api.service-kp.com/v1/device/notify"
    m.deviceNotifyTask.requestType = "POST"
    m.deviceNotifyTask.observeField("content", "onDeviceNotify")
    m.deviceNotifyTask.observeField("authFailure", "onDeviceNotify")
    m.deviceNotifyTask.parameters = ["access_token", m.global.accessToken, "title", deviceInfo.GetFriendlyName().EncodeUriComponent(), "hardware", deviceInfo.GetModel(), "software", deviceInfo.GetVersion()]
    m.deviceNotifyTask.control = "RUN"
end sub

sub onDeviceNotify()
    print "MenuScene:onDeviceNotify"
    if m.deviceNotifyTask.authFailure
        print "Auth failed"
        showAuthentication()
    else
        startPanels()
    end if
end sub

sub slideBack()
    print "MenuScene:slideBack"
    print m.top.panelSet.isGoingBack
end sub

sub nPanelAdded()
    print "MenuScene:nPanelAdded"

    index = 0
    while m.panelArray[index] <> invalid and m.panelArray[index].nPanel = invalid
        index = index + 1
    end while

    if m.panelArray[index] = invalid
        return
    end if

    currentPanel = m.panelArray[index]
    nPanel = currentPanel.nPanel
    currentPanel.unobserveField("nPanel")
    currentPanel.nPanel = invalid
    currentPanel.observeField("nPanel", "nPanelAdded")

    nextIndex = index + 1
    while(m.panelArray[nextIndex] <> invalid)
        m.panelArray[nextIndex].unobserveField("nPanel")
        m.panelArray[nextIndex].unobserveField("dialog")
        m.panelArray[nextIndex] = invalid
        nextIndex = nextIndex + 1
    end while

    m.panelArray[index+1] = nPanel
    nPanel.observeField("nPanel", "nPanelAdded")
    nPanel.observeField("dialog","dialogAdded")

    if nPanel.isVideo
        print "MenuScene:nPanelAdded:video"
        m.top.overhang.visible = false
        m.top.panelset.visible = false
        m.video = nPanel
        m.video.previousPanel = m.panelArray[index]
        nPanel.start = true
        m.top.appendChild(nPanel)
        nPanel.setFocus(true)
    else
        print "MenuScene:nPanelAdded:panel"
        m.top.panelSet.appendChild(nPanel)
        nPanel.panelSet = m.top.panelSet
        nPanel.start = true
    end if

    print "MenuScene:nPanelAdded:end"
end sub

sub dialogAdded()
    print "MenuScene:dialogAdded"
    index = 0
    while m.panelArray[index] <> invalid and m.panelArray[index].dialog = invalid
        index = index + 1
    end while

    if m.panelArray[index] = invalid
        return
    end if

    m.panelArray[index].unobserveField("dialog")
    dialog = m.panelArray[index].dialog
    m.panelArray[index].dialog = invalid
    m.panelArray[index].observeField("dialog", "dialogAdded")
    m.top.dialog = dialog
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    print "MenuScene:onKeyEvent"
      if press then
        if key = "back"

          if (m.video <> invalid)
            m.top.removeChild(m.video)
            previousPanel = m.video.previousPanel
            m.video = invalid

            m.top.overhang.visible = true
            m.top.panelset.visible = true

            m.currentPanel = previousPanel
            previousPanel.setFocus(true)
            previousPanel.updateFocus = true
            previousPanel.updateFocus = false

            return true
          end if
        end if
      end if

      return false
 end function

sub recode(str as string) as string
    return m.global.utilities.callFunc("Encode", {str: str})
end sub
