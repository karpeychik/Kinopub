sub init()
    ' print "VideoNode:init()"

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
    ' print "VideoNode:startVideo()"
    currentMedia = m.top.playlist.getChild(0)

    content = getContentPlaylist(invalid, 0, currentMedia.seek.ToStr(), currentMedia.title)

    m.video = createObject("roSGNode", "Video")
    m.top.appendChild(m.video)
    m.video.content = content
    m.firstPlaylistVideo = 0
    m.video.contentIsPlaylist = true

    m.video.observeField("state", "stateChanged")

    m.video.control = "play"
    m.video.observeField("audioTrack", "audioStreamUpdate")
    m.video.setFocus(true)
end sub

sub stateChanged()
    ' print "VideoNode:StateChanged: "
    ' print m.video.state
    contentIndex = m.video.contentIndex
    if m.video.state = "playing"
        playlist = m.top.playlist
        if playlist.getChild(contentIndex).videoId <> invalid and playlist.getChild(contentIndex).seasonId <> "invalid" and playlist.getChild(contentIndex).videoNumber <> 0
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
    ' print "VideoNode:timerFired"
    if m.video.position > 0 and (m.video.position / m.video.duration) < 0.85
        m.watched = false
        markTime()
    else if m.watched = false
        m.watched = true
        markwatched()
    end if
end sub

sub markWatched()
    contentIndex = m.video.contentIndex
    m.updateStatusTask = createObject("roSGNode", "ContentReader")
    m.updateStatusTask.requestType = "GET"

    parameters = createObject("roArray", 8, false)

    parameters.Push("id")
    parameters.Push(m.top.playlist.getChild(contentIndex).videoId)

    parameters.Push("video")
    parameters.Push(m.top.playlist.getChild(contentIndex).videoNumber.ToStr())

    if m.top.playlist.getChild(contentIndex).seasonId <> invalid
        parameters.Push("season")
        parameters.Push(m.top.playlist.getChild(contentIndex).seasonId)
    end if

    m.updateStatusTask.baseUrl = "https://api.service-kp.com/v1/watching/toggle"
    parameters.Push("watched")
    parameters.Push("1")

    m.updateStatusTask.parameters = parameters
    m.updateStatusTask.control = "RUN"

    playlistIndex = m.firstPlaylistVideo + contentIndex
    m.top.playList.getChild(playlistIndex).watched = true
end sub

sub markTime()
    contentIndex = m.video.contentIndex
    m.updateStatusTask = createObject("roSGNode", "ContentReader")
    m.updateStatusTask.requestType = "GET"

    parameters = createObject("roArray", 8, false)

    parameters.Push("id")
    parameters.Push(m.top.playlist.getChild(contentIndex).videoId)

    parameters.Push("video")
    parameters.Push(m.top.playlist.getChild(contentIndex).videoNumber.ToStr())

    if m.top.playlist.getChild(contentIndex).seasonId <> invalid
        parameters.Push("season")
        parameters.Push(m.top.playlist.getChild(contentIndex).seasonId)
    end if

    m.updateStatusTask.baseUrl = "https://api.service-kp.com/v1/watching/marktime"
    parameters.Push("time")
    parameters.Push(m.video.position.ToStr())

    m.updateStatusTask.parameters = parameters
    m.updateStatusTask.control = "RUN"

    playlistIndex = m.firstPlaylistVideo + contentIndex
    m.top.playList.getChild(playlistIndex).watched = false
end sub

sub audioStreamUpdate()
    if m.top.playlist.getChildCount() = 0
        return
    end if

    videoTrackIndex = m.video.audioTrack
    currentVideo    = m.video.contentIndex
    currentTime     = m.video.position

    currentMedia = m.top.playlist.getChild(0)

    newContent = getContentPlaylist(videoTrackIndex, currentVideo, currentTime.ToStr(), currentMedia.title)

    m.video.content = newContent
    m.firstPlaylistVideo = currentVideo
    m.video.control = "play"
end sub

function getContentPlaylist(preferredAudio as Object, firstVideo as Integer, firstSeek as String, title as String) as Object
    content = createObject("roSGNode", "ContentNode")
    for i = firstVideo to m.top.playList.getChildCount() - 1
        item = m.top.playList.getChild(i)
        videoContent = createObject("roSGNode", "ContentNode")
        videoContent.streamformat = item.videoFormat
        videoContent.url = item.videoUri
        if preferredAudio = invalid
            videoContent.TrackIdAudio = item.audioTrack
        else
            videoContent.TrackIdAudio = preferredAudio
        end if

        if item.subtitleUrl <> invalid
            videoContent.srt = item.subtitleUrl
        end if
        videoContent.title = title
        videoContent.PlayStart = item.seek
        content.appendChild(videoContent)
    end for
    return content
end function

function onKeyEvent(key as String, press as Boolean) as Boolean
    if press AND key = "back" AND m.video <> invalid
        markTime()
        m.video.control = "pause"
        return false
    end if

    return false
 end function
