sub init()
    print "Initializing poster"
    m.top.panelSize = "full"
    m.top.isFullScreen = true
    m.top.leftPosition = 130
    m.top.focusable = true
    m.top.hasNextPanel = false
    m.top.createNextPanelOnItemFocus = false
    m.top.grid = m.top.findNode("posterGrid")
end sub

sub loadCategoryPosters()
    print "loadCategoryPosters"
end sub