sub init()
      print "VideoNode:init()"
      
      m.top.isVideo = true
      m.top.seek = 0.0
      m.top.observeField("start", "startVideo")
      m.top.videoNumber = 0
      m.top.videoId = invalid
      m.top.seasonId = "invalid"
      m.statusTimer = createObject("roSGNode", "Timer")
      m.statusTimer.repeat = true
      m.statusTimer.observeField("fire", "timerFired")
      'TODO: how often do we update?
      m.statusTimer.duration = 60
      m.top.appendChild(m.statusTimer)
      m.watched = false
end sub

sub startVideo()
    print "VideoNode:startVideo()"
    videocontent = createObject("RoSGNode", "ContentNode")

    videocontent.title = ""
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

    m.video.observeField("state","stateChanged")
    
    m.video.control = "play"
    m.video.setFocus(true)
end sub

sub stateChanged()
    print "VideoNode:StateChanged: "
    print m.video.state
    if m.video.state = "playing"
        if m.top.videoId <> invalid and m.top.seasonId <> "invalid" and m.top.videoNumber <> 0
            m.statusTimer.control = "start"
        end if
    else
        if m.statusTimer <> invalid
            m.statusTimer.control = "stop"
         end if
         
         if m.video.state <> "error" and m.video.state <> "buffering"
            timerFired()
         end if
    end if
end sub

sub timerFired()
    print "VideoNode:timerFired"
    if m.video.position > 0 and (m.video.position / m.video.duration) < 0.85
        m.watched = false
        markTime()
    else if m.watched = false
        m.watched = true
        markwatched()
    end if    
end sub

sub markWatched()
    print "VideoNode:markWatched"
    m.updateStatusTask = createObject("roSGNode", "ContentReader")
    m.updateStatusTask.requestType = "GET"

    parameters = createObject("roArray", 8, false)
    
    parameters.Push("id")
    parameters.Push(m.top.videoId)
    
    parameters.Push("video")
    parameters.Push(m.top.videoNumber.ToStr())
    
    if(m.top.seasonId <> invalid)
        parameters.Push("season") 
        parameters.Push(m.top.seasonId)
    end if
    
    m.updateStatusTask.baseUrl = "https://api.service-kp.com/v1/watching/toggle"
    parameters.Push("watched")
    parameters.Push("1")
    
    m.updateStatusTask.parameters = parameters
    m.updateStatusTask.control = "RUN"
end sub

sub markTime()
    print "VideoNode:markTime"
    m.updateStatusTask = createObject("roSGNode", "ContentReader")
    m.updateStatusTask.requestType = "GET"

    parameters = createObject("roArray", 8, false)
    
    parameters.Push("id")
    parameters.Push(m.top.videoId)
    
    parameters.Push("video")
    parameters.Push(m.top.videoNumber.ToStr())
    
    if(m.top.seasonId <> invalid)
        parameters.Push("season") 
        parameters.Push(m.top.seasonId)
    end if
    
    m.updateStatusTask.baseUrl = "https://api.service-kp.com/v1/watching/marktime"
    parameters.Push("time")
    parameters.Push(m.video.position.ToStr())
    
    m.updateStatusTask.parameters = parameters
    m.updateStatusTask.control = "RUN"
end sub
