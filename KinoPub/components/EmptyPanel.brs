sub init()
    print "EmptyPanel:init()"
    m.top.panelSize = "medium"
    m.top.focusable = true
    m.top.hasNextPanel = true

    m.infolabel = m.top.findNode("infoLabel")
      
    m.top.isVideo = false
    
    m.currentCategory = ""
      
end sub
