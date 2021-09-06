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
    
    content = getContentPlaylist(invalid, 0, m.top.playlist.getChild(0).seek.ToStr())
    
    print content

    m.video = createObject("roSGNode", "Video")
    m.top.appendChild(m.video)
    m.video.content = content
    m.firstPlaylistVideo = 0
    m.video.contentIsPlaylist = true

    m.video.observeField("state","stateChanged")
    
    m.video.control = "play"
    m.video.observeField("audioTrack","audioStreamUpdate")
    m.video.observeField("contentIndex","trackUpdate")
    m.video.setFocus(true)
end sub

sub stateChanged()
    print "VideoNode:StateChanged: "
    print m.video.state
    contentIndex = m.video.contentIndex
    if m.video.state = "playing"
        if m.top.playlist.getChild(contentIndex).videoId <> invalid and m.top.playlist.getChild(contentIndex).seasonId <> "invalid" and m.top.playlist.getChild(contentIndex).videoNumber <> 0
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
    contentIndex = m.video.contentIndex
    m.updateStatusTask = createObject("roSGNode", "ContentReader")
    m.updateStatusTask.requestType = "GET"

    parameters = createObject("roArray", 8, false)
    
    parameters.Push("id")
    parameters.Push(m.top.playlist.getChild(contentIndex).videoId)
    
    parameters.Push("video")
    parameters.Push(m.top.playlist.getChild(contentIndex).videoNumber.ToStr())
    
    if(m.top.playlist.getChild(contentIndex).seasonId <> invalid)
        parameters.Push("season") 
        parameters.Push(m.top.playlist.getChild(contentIndex).seasonId)
    end if
    
    m.updateStatusTask.baseUrl = "https://api.service-kp.com/v1/watching/toggle"
    parameters.Push("watched")
    parameters.Push("1")
    
    m.updateStatusTask.parameters = parameters
    m.updateStatusTask.control = "RUN"
    
    print "Marking watched"
    playlistIndex = m.firstPlaylistVideo + contentIndex
    m.top.playList.getChild(playListIndex).watched = true
    print m.top.playList.getChild(playListIndex)
end sub

sub markTime()
    print "VideoNode:markTime"
    contentIndex = m.video.contentIndex
    m.updateStatusTask = createObject("roSGNode", "ContentReader")
    m.updateStatusTask.requestType = "GET"

    parameters = createObject("roArray", 8, false)
    
    parameters.Push("id")
    parameters.Push(m.top.playlist.getChild(contentIndex).videoId)
    
    parameters.Push("video")
    parameters.Push(m.top.playlist.getChild(contentIndex).videoNumber.ToStr())
    
    if(m.top.playlist.getChild(contentIndex).seasonId <> invalid)
        parameters.Push("season") 
        parameters.Push(m.top.playlist.getChild(contentIndex).seasonId)
    end if
    
    m.updateStatusTask.baseUrl = "https://api.service-kp.com/v1/watching/marktime"
    parameters.Push("time")
    parameters.Push(m.video.position.ToStr())
    
    m.updateStatusTask.parameters = parameters
    m.updateStatusTask.control = "RUN"
    
    print "Marking unwatched"
    playlistIndex = m.firstPlaylistVideo + contentIndex
    m.top.playList.getChild(playListIndex).watched = false
    print m.top.playList.getChild(playListIndex)
end sub

sub audioStreamUpdate()
    print "VideoNode:audioStreamUpdate"
    print m.video.audioTrack
    
    videoTrackIndex = m.video.audioTrack
    currentVideo = m.video.contentIndex
    currentTime = m.video.position
    
    'm.video.control = "stop"
    if m.top.playlist.getChildCount() > 1
        newContent = getContentPlaylist(videoTrackIndex, currentVideo, currentTime.ToStr())
        
        m.video.content = newContent
        m.firstPlaylistVideo = currentVideo
        m.video.control = "play"
    end if
end sub

function getContentPlaylist(preferredAudio as Object, firstVideo as Integer, firstSeek as String) as Object
    content = createObject("roSGNode", "ContentNode")
    for i=firstVideo to m.top.playList.getChildCount()-1
        item = m.top.playList.getChild(i)
        videocontent = createObject("roSGNode", "ContentNode")
        videocontent.streamformat = item.videoFormat
        videocontent.url = item.videoUri
        if preferredAudio = invalid
            videocontent.TrackIdAudio = item.audioTrack
        else 
            videocontent.TrackIdAudio = preferredAudio
        end if
        videocontent.title = ""
        videocontent.PlayStart = item.seek
        content.appendChild(videoContent)
        print videocontent
    end for
    print "Here is content!"
    print content
    return content
end function

sub trackUpdate()
    print m.video.content.getChild(m.video.contentIndex)
end sub
