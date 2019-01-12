sub init()
    print "SeasonListPanel:init()"
    
    m.top.panelSize = "full"
    m.top.isFullScreen = true
    m.top.leftPosition = 130
    m.top.focusable = true
    m.top.hasNextPanel = false
    m.top.createNextPanelOnItemFocus = false
    m.top.grid = m.top.findNode("posterGrid")
    m.grid = m.top.grid
    
    m.top.isVideo = false
    m.top.observeField("start","start")
    m.grid.observeField("itemSelected","itemSelected")
    m.grid.numRows = 100
    
    'HACKHACK: These are expected thumbnail dimensions. How can we make sure that this is always the case?
    thumbWidth = 480
    thumbHeight = 270
    
    posterWidth = 200
    posterHeight = posterWidth*thumbHeight/thumbWidth
    
    gridRect = m.top.boundingRect()
    numColumns = Fix(gridRect.width / posterWidth)
    m.grid.numColumns = numColumns
    
    m.grid.basePosterSize = [posterWidth, posterHeight]
    
end sub

sub start()
    print "SeasonListPanel:start()"
    season = m.top.serial.seasons[m.top.seasonIndex]
    
    content = createObject("roSGNode", "ContentNode")
    for each item in season.episodes
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
        
        itemContent = createObject("roSGNode", "ContentNode")
        itemContent.setField("shortdescriptionline1", m.global.utilities.callFunc("Encode", {str: title}))
        itemContent.setField("hdgridposterurl", item.thumbnail)
        itemContent.addFields({link: "https://cdn.streambox.in/hls4/kinopub/aWQ9MjE3Njg0OzQwMzc4MzM5ODs0NDU1ODI7MTU0NzAxMzQ4NSZoPTFlaEdXODJSdHVFMzBWRU1TTHdFcncmZT0xNTQ3MDk5ODg1/88774.m3u8?loc=de"})
        content.appendChild(itemContent)
    end for
    
    m.grid.setFocus(true)
    m.grid.visible = true
    m.grid.content = content
    m.grid.width = 100
end sub

sub itemSelected()
    print "SeasonListPanel:itemSelected()"
    episode = m.top.serial.seasons[m.top.seasonIndex].episodes[m.grid.itemSelected]
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