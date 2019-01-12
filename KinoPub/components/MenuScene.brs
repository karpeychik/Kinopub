sub init()
    print "MenuScene: Init"
    print m.global.accessToken

    utilities = createObject("roSGNode", "Utilities")
    m.global.addFields({utilities: utilities})
    
    m.top.overhang.visible = false
    m.top.panelset.visible = false
    
    start()
    
end sub

sub start()
    sec = createObject("roRegistrySection", "Authentication")
    if sec.Exists("AuthenticationToken") and sec.Exists("RefreshToken") and sec.Exists("TokenExpiration")
        authToken = sec.Read("AuthenticationToken")
        refreshToken = sec.Read("RefreshToken")
        expiry = sec.Read("TokenExpiration")
        
        print "Current auth:"
        print "AuthToken: " + authToken
        print "RefreshToken: " + refreshToken
        print "Expiration:" + expiry
        startPanels()
    else
        print "Auth not found..."
        if false
            showAuthentication()
        else
            startPanels()
        end if
    end if
    
    'startPanels()
end sub

sub showAuthentication()
    authenticator = m.top.createChild("Authenticator") 'createObject("roSGNode", "Authenticator")
    'm.top.appendChild(authenticator)
end sub

sub startPanels()
    m.top.overhang.visible = true
    m.top.panelset.visible = true
    
    panel = m.top.panelSet.createChild("CategoriesListPanel")
    
    m.panelArray = createObject("roArray", 14, false)    
    m.panelArray[0] = panel
        
    m.panelArray[0].panelSet = m.top.panelSet
    m.panelArray[0].pType = ""
    m.panelArray[0].nPanel = invalid
    m.panelArray[0].observeField("nPanel","nPanelAdded")
    m.panelArray[0].start = true
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
            
            return true
          end if
        end if
      end if

      return false
 end function

sub recode(str as string) as string
    return m.global.utilities.callFunc("Encode", {str: str})
end sub