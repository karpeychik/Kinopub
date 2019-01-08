sub init()
    print "MenuScene: Init"
    print m.global.accessToken

    utilities = createObject("roSGNode", "Utilities")
    m.global.addFields({utilities: utilities})
    
    panel = m.top.panelSet.createChild("CategoriesListPanel")
    
    m.panelArray = createObject("roArray", 10, false)    
    m.panelArray[0] = panel
        
    m.panelArray[0].panelSet = m.top.panelSet
    m.panelArray[0].pType = ""
    m.panelArray[0].nextPanel = invalid
    m.panelArray[0].observeField("nextPanel","nextPanelAdded")
    m.panelArray[0].start = true
end sub

sub nextPanelAdded()
    print "MenuScene:nextPanelAdded"
    
    index = 0
    while m.panelArray[index] <> invalid and m.panelArray[index].nextPanel = invalid
        index = index + 1
    end while
    
    if m.panelArray[index] = invalid
        return
    end if
    
    currentPanel = m.panelArray[index]
    nextPanel = currentPanel.nextPanel
    currentPanel.unobserveField("nextPanel")
    currentPanel.nextPanel = invalid 
    currentPanel.observeField("nextPanel", "nextPanelAdded")
    
    nextIndex = index + 1
    while(m.panelArray[nextIndex] <> invalid)
        m.panelArray[nextIndex].unobserveField("nextPanel")
        m.panelArray[nextIndex].unobserveField("dialog")
        m.panelArray[nextIndex] = invalid
        nextIndex = nextIndex + 1
    end while
    
    m.panelArray[index+1] = nextPanel
    nextPanel.observeField("nextPanel", "nextPanelAdded")
    nextPanel.observeField("dialog","dialogAdded")
    
    if nextPanel.isVideo
        print "MenuScene:nextPanelAdded:video"
        m.top.overhang.visible = false
        m.top.panelset.visible = false
        m.video = nextPanel
        m.video.previousPanel = m.panelArray[index]
        nextPanel.start = true
        m.top.appendChild(nextPanel)
        nextPanel.setFocus(true)
    else
        print "MenuScene:nextPanelAdded:panel"
        m.top.panelSet.appendChild(nextPanel)
        nextPanel.start = true
    end if
    
    print "MenuScene:nextPanelAdded:end"    
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