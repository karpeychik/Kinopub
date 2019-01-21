sub init()
    print "SeasonRowListPanel:init()"
    m.top.panelSize = "full"
    m.top.isFullScreen = true
    m.top.leftPosition = 130
    m.top.focusable = true
    m.top.hasNextPanel = false
    m.top.isVideo = false
    
    m.top.updateFocus = false
    
    m.top.observeField("start","start")
    m.top.observeField("updateFocus","updateFocus")
    
    'HACKHACK: These are expected thumbnail dimensions. How can we make sure that this is always the case?
    thumbWidth = 480
    thumbHeight = 270
    
    m.panelWidth = 1280 - m.top.leftPosition
    
    m.posterWidth = 200
    m.posterHeight = m.posterWidth*thumbHeight/thumbWidth
    
    m.separ = 0
    
    gridRect = m.top.boundingRect()
    m.numColumns = Fix(m.panelWidth / (m.posterWidth + m.separ))
end sub

sub start()
    print "SeasonRowListPanel:init()"
    
    m.rowList = createObject("roSGNode", "RowList")
    rowList = m.rowList
    rowList.itemComponentName = "EpisodeRowListComponent"
    rowList.numRows = 100
    rowList.rowItemSize = [ [m.posterWidth, m.posterHeight] ]
    rowList.rowItemSpacing = [[ m.separ, m.separ ]]
    rowList.showRowLabel = [ true ]
    rowlist.itemSize = [ m.panelWidth, m.posterHeight ]
    rowList.showRowLabel = false
    rowList.drawFocusFeedback = false
    rowList.vertFocusAnimationStyle = "floatingFocus" 
    rowList.rowFocusAnimationStyle = "floatingFocus"
    rowList.observeField("rowItemSelected", "rowItemSelected")
    
    content = createObject("roSGNode", "ContentNode")
    columnCount = 0
    row = createObject("roSGNode", "ContentNode")
    for i=0 to m.top.seasonNode.getChildCount()-1            
        item = m.top.seasonNode.getChild(i)
        if columnCount = m.numColumns 
            columnCount = 0
            content.appendChild(row)
            row = createObject("roSGNode", "ContentNode")
        end if
         
        title = createObject("roString")
    
        if item.doesExist("number")
            if item.number < 9
                title.AppendString("0",1)
                title.AppendString(item.number.ToStr(), 1)
            else
                str = item.number.ToStr()
                title.AppendString(str, str.Len())
            end if
            
            title.AppendString(": ", 2)
        end if
        
        title.appendString(item.title, item.title.Len())
        
        title = recode(title)
        episodeWatched = false
        if item.watched = 1
            episodeWatched = true
        end if
        
        itemContent = createObject("roSGNode", "ContentNode")
        itemContent.addFields({itemTitle: title, itemWidth: m.posterWidth, itemHeight: m.posterHeight, episodeWatched: episodeWatched, posterLink: item.thumbnail })
        
        row.appendChild(itemContent)
        columnCount = columnCount + 1
    end for
    
    if row.getChildCount() > 0
        content.appendChild(row)
    end if
    
    print  content.getChildCount()
    print content.getChild(0).getChildCount()
    rowList.content = content
    
    m.top.appendChild(rowList)
    
    rowList.setFocus(true)

end sub

sub updateFocus()
    print "SeasonRowListPanel:updateFocus()"
    if m.top.updateFocus
        if m.playlist <> invalid            
            for i = 0 to m.playlist.getChildCount()-1 step 1
                'episodeIndex is 1 based
                episodeIndex = m.playListFirstIndex + i
                rowIndex = episodeIndex \ m.numColumns
                columnIndex = episodeIndex MOD m.numColumns
                row = m.rowList.content.getChild(rowIndex)
                item = row.getChild(columnIndex)
                item.episodeWatched = m.playlist.getChild(i).watched
            end for 
        end if
        
        m.rowList.setFocus(true)
    end if
end sub

sub rowItemSelected()
    print "SeasonRowListPanel:rowItemSelected()"
    episodeIndex = m.rowList.rowItemSelected[0] * m.numColumns + m.rowList.rowItemSelected[1]
    m.episodeIndex = episodeIndex 
    episode = m.top.seasonNode.getChild(episodeIndex)
    if episode.doesExist("watchingStatus") and episode.doesExist("watchedTime") and episode.watchingStatus = 0 and episode.watchedTime <> invalid
        m.dialog = createObject("roSGNode", "Dialog")
        
        font  = CreateObject("roSGNode", "Font")
        font.uri = "pkg:/fonts/NotoSans-Regular-w1251-rename.ttf"
        font.size = 24
        
        title = createObject("roString")
        appStr = "Вы хотите продолжить c "
        title.appendString(appStr, appStr.Len())
        durationStr = getDuration(episode.watchedTime)
        title.AppendString(durationStr,durationStr.Len())
        
        m.dialog.buttons = [ recode("Да"), recode("Нет")]
        m.dialog.title = recode(title)
        m.dialog.titleFont = font
        m.dialog.buttonGroup.textFont = font
        m.dialog.buttonGroup.focusedTextFont = font
        m.dialog.observeField("buttonSelected","watchingDialogResponse")
        m.top.dialog = m.dialog
    else 
        'There is no existing status to continue, start from scratch
        gotoVideo(episodeIndex, 0.0)
    end if
    
end sub

sub watchingDialogResponse()
    button = m.dialog.buttonSelected
    m.dialog.close = true
    seekTo = 0.0
    if button = 0
        seekTo = m.top.seasonNode.getChild(m.episodeIndex).watchedTime
    end if
    
    gotoVideo(m.episodeIndex, seekTo)
end sub

sub gotoVideo(episodeIndex as Integer, seekTo as Float)
    print "SeasonRowListPanel:gotoVideo()"
    
    serial = m.top.serial
    episode = m.top.seasonNode.getChild(m.episodeIndex)
    quality = getPreferredQuality(episode)
    
    nPanel = invalid
    
    playlist = createObject("roSGNode", "ContentNode")
    for i=episodeIndex to m.top.seasonNode.getChildCount()-1
        episode = m.top.seasonNode.getChild(i)
        quality = getPreferredQuality(episode)
        
        for each item in episode.files
            if item.quality = quality
                stream = getPreferredStream(item)
                
                videoFormat = stream
                videoUri = item.url[stream]
                audioTrack = episode.audios[0].index.ToStr()
                videoId = m.top.seasonNode.videoId
                videoNumber = i + 1
                seasonId = (m.top.seasonNode.seasonIndex + 1).ToStr()
                
                if i = episodeIndex
                    seek = seekTo
                else seek = 0
                end if
                
                exit for
            end if
        end for
        
        if episode.watched = 1
            episodeWatched = true
        else
            episodeWatched = false
        end if
        
        episodeEntry = createObject("roSGNode", "ContentNode")
        episodeEntry.addFields({
            videoFormat: videoFormat, 
            videoUri : videoUri,
            audioTrack : audioTrack,
            videoId : videoId,
            videoNumber : videoNumber,
            seasonId : seasonId,
            seek : seek,
            watched : episodeWatched})
        playlist.appendChild(episodeEntry)
    end for
    
    m.playlist = playlist
    m.playListFirstIndex = episodeIndex
    m.focusedIndex = episodeIndex
    
    nPanel = createObject("roSGNode", "VideoNode")
    nPanel.playlist = playlist
    
    if nPanel <> invalid
        print "SeasonListPanel:PanelSelected"
        m.top.nPanel = nPanel
    end if
end sub

function getDuration(durationSeconds as  Integer) as String
    second = durationSeconds MOD 60
    durationSeconds = durationSeconds \ 60
    minute = durationSeconds MOD 60
    durationSeconds = durationSeconds \ 60
    hour = durationSeconds MOD 60
    
    result = createObject("roString")
    if(hour > 0)
        if(hour < 10)
            result.AppendString("0",1)
        end if
        
        hourString = hour.ToStr()
        result.AppendString(hourString,hourString.Len())
    else 
        result.AppendString("00", 2)
    end if
    
    result.AppendString(":", 1)
    
    if(minute > 0)
        if(minute < 10)
            result.AppendString("0",1)
        end if
        minuteString = minute.ToStr()
        result.AppendString(minuteString, minuteString.Len())
    else
        result.AppendString("00", 2)
    end if
    
    result.AppendString(":", 1)
    
    if(second > 0)
        if(second < 10)
            result.AppendString("0",1)
        end if
        secondString = second.ToStr()
        result.AppendString(secondString, secondString.Len())
    else
        result.AppendString("00", 2)
    end if
    
    return result
end function

function getPreferredQuality(episode as Object) as Object
    print "SeasonListPanel:getPreferredQuality()"
    qualityCount = episode.files.Count()
    qualities = createObject("roArray", qualityCount, false)
    qualityIndex = -1
    for i=0 to episode.files.Count()-1  step 1
        qualities.push(episode.files[i].quality)
        if episode.files[i].quality = "1080p"
            qualityIndex = i
        end if
    end for
    
    if(qualityIndex = -1)
        qualityIndex = qualities.Count() - 1
    end if
    
    return qualities[qualityIndex]
end function

function getPreferredStream(file as Object) as Object
    preferredStream = "hls4"
    
    streams =  file.url.Keys()
    streams.Sort("")
    
    streamIndex = -1
    for i=0 to streams.Count()-1  step 1
        if streams[i] = preferredStream
            streamIndex = i
        end if
    end for
    
    if streamIndex = -1
        streamIndex = 0
    end if
    
    return streams[streamIndex]
end function

function recode(str as String)
    return m.global.utilities.callFunc("Encode", {str: str})
end function