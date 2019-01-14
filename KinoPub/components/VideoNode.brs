sub init()
      print "VideoNode:init()"
      
      m.top.isVideo = true
      m.top.seek = 0.0
      m.top.observeField("start", "startVideo")
end sub

sub startVideo()
    print "VideoNode:startVideo()"
    videocontent = createObject("RoSGNode", "ContentNode")

    videocontent.title = "Example Video"
    videocontent.streamformat = m.top.videoFormat
    videocontent.url = m.top.videoUri
    videocontent.TrackIdAudio = m.top.audioTrack
    
    print videocontent
    print m.top.audioTrack

    m.video = createObject("roSGNode", "Video")
    m.top.appendChild(m.video)
    m.video.content = videocontent
    m.video.audioTrack = m.top.audioTrack
    m.video.seek = m.top.seek

    m.video.control = "play"
    m.video.setFocus(true)
end sub
