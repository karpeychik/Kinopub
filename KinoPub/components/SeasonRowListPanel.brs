sub init()
    print "SeasonRowListPanel:init()"
    m.top.panelSize = "full"
    m.top.isFullScreen = true
    m.top.leftPosition = 130
    m.top.focusable = true
    m.top.hasNextPanel = false
    m.top.isVideo = false
    m.top.observeField("start","start")
    
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
    season = m.top.serial.seasons[m.top.seasonIndex]
    columnCount = 0
    row = createObject("roSGNode", "ContentNode")
    for each item in season.episodes            
        print "Adding item"
        
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
        
        title = m.global.utilities.callFunc("Encode", {str: title})
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

sub rowItemSelected()
    print "SeasonRowListPanel:rowItemSelected()"
    
    episodeIndex = m.rowList.rowItemSelected[0] * m.numColumns + m.rowList.rowItemSelected[1] 
    
    episode = m.top.serial.seasons[m.top.seasonIndex].episodes[episodeIndex]
    quality = getPreferredQuality(episode)
    
    nPanel = invalid
    for each item in episode.files
        if item.quality = quality
            stream = getPreferredStream(item)
            nPanel = createObject("roSGNode", "VideoNode")
            nPanel.videoFormat = stream
            nPanel.videoUri = item.url[stream]
            nPanel.audioTrack = episode.audios[0].index.ToStr()
            exit for
        end if
    end for
    
    if nPanel <> invalid
        print "SeasonListPanel:PanelSelected"
        m.top.nPanel = nPanel
    end if
    
end sub

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