sub init()
    print "Init VideoDescriptionPanel"
    m.top.panelSize = "full"
    m.top.isFullScreen = true
    m.top.leftPosition = 130
    m.top.focusable = true
    m.top.hasNextPanel = false
    m.top.createNextPanelOnItemFocus = false
    
    m.top.observeField("start","showVideoDetails")
    m.top.isVideo = false
end sub

sub showVideoDetails()
    print "showVideoDetails"
    m.readItemTask = createObject("roSGNode", "ContentReader")
    m.readItemTask.baseUrl = m.top.itemUri
    m.readItemTask.parameters = m.top.itemUriParameters
    m.readItemTask.observeField("content", "itemReceived")
    m.readItemTask.control = "RUN"
end sub

sub itemReceived()
    print "itemReceived"
    m.top.videoFormat = "hls2"
    m.top.videoTitle = "ExampleVideo"
    m.top.videoUri = m.readItemTask.content.item.videos[0].files[1].url.hls2
    
    nextpanel = createObject("roSGNode", "VideoNode")
    nextPanel.videoFormat = "hls2"
    nextPanel.videoUri = m.readItemTask.content.item.videos[0].files[1].url.hls2
    m.top.nextPanel = nextPanel
end sub