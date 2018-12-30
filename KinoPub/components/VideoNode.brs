sub init()
      print "VideoNode:init()"

      m.videoNode = m.top.findNode("exampleVideo")
      
      m.top.isVideo = true
      m.top.observeField("start", "startVideo")
end sub

sub startVideo()
    print "VideoNode:startVideo()"
    videocontent = createObject("RoSGNode", "ContentNode")

    videocontent.title = "Example Video"
    videocontent.streamformat = m.top.uriFormat
    videocontent.url = m.top.videoUri

    video = m.top.findNode("exampleVideo")
    video.content = videocontent

    video.control = "play"
    video.setFocus(true)
end sub
