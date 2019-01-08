'TODO: This component relies heavily on the item only having a single Video array element. Is that safe?

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
    print "VideoDescriptionPanel:itemReceived"
    m.top.videoFormat = "hls2"
    m.top.videoTitle = "ExampleVideo"
    m.top.videoUri = m.readItemTask.content.item.videos[0].files[1].url.hls2
    
    if false
        nextpanel = createObject("roSGNode", "VideoNode")
        nextPanel.videoFormat = "hls2"
        nextPanel.videoUri = m.readItemTask.content.item.videos[0].files[1].url.hls2
        m.top.nextPanel = nextPanel
    else
        
        deviceInfo = createObject("roDeviceInfo")
    
        title = m.readItemTask.content.item.title
        imageUri = m.readItemTask.content.item.posters.big
        
        gridRect = m.top.boundingRect() 
        
        availableWidth = m.top.width/2 - 120
        availableHeight = m.top.height - 100
        
        widthHeight = availableWidth * 250 / 165
        heightWidth = availableHeight * 165 / 250
        
        if widthHeight <= availableHeight
            width = availableWidth
            height = widthHeight
        else
            height = availableHeight
            width = heightWidth
        end if
        
        left = availableWidth/2 - width/2
        print left
        
        poster = createObject("roSGNode", "Poster")
        poster.translation = [left, 0]
        poster.width = width
        poster.height = height 
        poster.loadDisplayMode = "scaleToFit"
        poster.uri = imageUri
        m.top.appendChild(poster)
        
        m.font24  = CreateObject("roSGNode", "Font")
        m.font24.uri = "pkg:/fonts/NotoSans-Regular-w1251-rename.ttf"
        m.font24.size = 24
        
        m.font18  = CreateObject("roSGNode", "Font")
        m.font18.uri = "pkg:/fonts/NotoSans-Regular-w1251-rename.ttf"
        m.font18.size = 18
        
        m.font16  = CreateObject("roSGNode", "Font")
        m.font16.uri = "pkg:/fonts/NotoSans-Regular-w1251-rename.ttf"
        m.font16.size = 16
        
        title = m.readItemTask.content.item.title
        year =  m.readItemTask.content.item.year.ToStr()
        title = getTitle(title, year)        
        
        duration = getDuration(m.readItemTask.content.item.duration.total)
        
        genreString = getGenres(m.readItemTask.content.item.genres)
        
        director = getDirector(m.readItemTask.content.item)
        
        cast = getCast(m.readItemTask.content.item)
        
        rate = getRate(m.readItemTask.content.item)
        
        plot = m.readItemTask.content.item.plot
        
        textLeft = left + width + 50
        
        'HACKHACK: the unusedSpace here is a total banana. There is unused space on the screen which doesn't belong
        'to the panel and is not accounted in m.top.width. I couldn't figure out how to calculate it so hack.
        unusedSpace = 135
        labelWidth = m.top.width - textLeft + unusedSpace
        
        group = createObject("roSGNode", "LayoutGroup")
        group.addItemSpacingAfterChild =  false
        group.translation = [textLeft, 0]
        addLabel(group, title, 1, m.font24, 0, 0, labelWidth)
        if(rate.Len() > 0)
            addLabel(group, rate, 1, m.font18, 0, 0, labelWidth)
        end if 
        
        addLabel(group, duration, 1, m.font18, 0, 0, labelWidth)
        addLabel(group, genreString, 2, m.font18, 0, 0, labelWidth)
        addLabel(group, director, 1, m.font18, 0, 0, labelWidth)
        addLabel(group, cast, 2, m.font18, 0, 0, labelWidth)
        
        addLabel(group, plot, 8, m.font16, 0, 0, labelWidth)
        
        groupSpacings = createObject("roArray", group.getChildCount(), false)
        for i=0 to group.getChildCount() - 2 step 1
            groupSpacings[i] = 5.0
        end for
        
        groupSpacings[group.getChildCount() - 1] = 12.0
        group.itemSpacings = groupSpacings                
        
        m.buttons = createObject("roArray", 5, false)
        buttonGroup = createObject("roSGNode", "LayoutGroup")
        buttonGroup.layoutDirection = "horiz"
        buttonGroup.width = labelWidth
        
        m.streamIndex = -1
        setQuality(m.readItemTask.content.item)
        
        setAudio(m.readItemTask.content.item)
        
        addButton(buttonGroup, "p", "playButton")
        
        'TODO: add subtitle and audio support
        'addButton(buttonGroup, "audio", "audioButton")
        'addButton(buttonGroup, "sub", "otherButton")
        addButton(buttonGroup, m.qualities[m.qualityIndex], "qualityButton")
        m.qualityButton = m.buttons[m.buttons.Count()-1]
        addButton(buttonGroup, m.streams[m.streamIndex], "streamButton")
        m.streamButton = m.buttons[m.buttons.Count()-1]
        
        m.currentButtonIndex = 0
        
        group.appendChild(buttonGroup)
        m.top.appendChild(group)
        
        m.buttons[0].setFocus(true)
   
   end if
end sub

sub addButton(group as Object, text as String, callback as String)
    button = createObject("roSGNode", "Button")
    'button.width = "10"
    button.maxWidth = "100"
    button.minWidth = "100"
    button.focusable = true
    button.focusBitmapUri = ""
    button.focusFootprintBitmapUri = ""
    button.iconUri = ""
    button.focusedIconUri = ""
    button.showFocusFootprint = false 
    button.textFont = m.font16
    button.focusedTextFont = m.font16
    button.height = 40
    button.text = text
    button.observeField("buttonSelected", callback)
    m.buttons.Push(button)
    group.appendChild(button)
end sub

sub playButton()
    print "VideoDescriptionPanel:playButton"
    nextpanel = createObject("roSGNode", "VideoNode")
    
    for each video in m.readItemTask.content.item.videos[0].files
        if video.quality = m.qualities[m.qualityIndex]
            videoUri = video.url[m.streams[m.streamIndex]]
        end if
    end for
    
    print videoUri
    print m.streams[m.streamIndex]
    
    'TODO: what if we couldn't find the correct video? Should handle and not crash
    nextPanel.videoFormat = m.streams[m.streamIndex]
    nextPanel.videoUri = videoUri
    m.top.nextPanel = nextPanel
end sub

sub audioButton()
    print "VideoDescriptionPanel:audioButton"
end sub

sub streamButton()
    print "VideoDescriptionPanel:streamButton"
    m.dialog = createObject("roSGNode", "Dialog")
    m.dialog.buttons = m.streams
    m.dialog.observeField("buttonSelected", "streamSelected")
    m.top.dialog = m.dialog
end sub

sub qualityButton()
    print "VideoDescriptionPanel:qualityButton"
    m.dialog = createObject("roSGNode", "Dialog")
    m.dialog.buttons = m.qualities
    m.dialog.observeField("buttonSelected", "qualitySelected")
    m.top.dialog = m.dialog
end sub

sub qualitySelected()
    print "VideoDescriptionPanel:qualitySelected"
    m.qualityIndex = m.dialog.buttonSelected
    m.dialog.close = true
    setStreams(m.readItemTask.content.item)
    m.qualityButton.text = m.qualities[m.qualityIndex]
    m.streamButton.text = m.streams[m.streamIndex]
end sub

sub streamSelected()
    print "VideoDescriptionPanel:streamSelected"
    m.streamIndex = m.dialog.buttonSelected
    m.dialog.close = true
    m.streamButton.text = m.streams[m.streamIndex]
end sub

sub setQuality(item as Object)
    print "VideoDescriptionPanel:setQuality"
    qualityCount = item.videos[0].files.Count()
    m.qualities = createObject("roArray", qualityCount, false)
    m.qualityIndex = -1
    for i=0 to item.videos[0].files.Count()-1  step 1
        m.qualities.push(item.videos[0].files[i].quality)
        if item.videos[0].files[i].quality = "1080p"
            m.qualityIndex = i
        end if
    end for
    
    if(m.qualityIndex = -1)
        m.qualityIndex = m.qualities.Count() - 1
    end if
    
    setStreams(item)
end sub

sub setStreams(item as Object)
    print "VideoDescriptionPanel:setStreams"
    
    preferredStream = "hls2"
    if(m.streamIndex >= 0)
        preferredStream = m.streams[m.streamIndex]
    end if
    
    m.streams =  item.videos[0].files[m.qualityIndex].url.Keys()
    m.streams.Sort("")
    
    m.streamIndex = -1
    for i=0 to m.streams.Count()-1  step 1
        if m.streams[i] = preferredStream
            m.streamIndex = i
        end if
    end for
    
    if m.streamIndex = -1
        m.streamIndex = 0
    end if
end sub

sub setAudio(item as Object)
    for each track in item.videos[0].audios
    end for
end sub

sub otherButton()
end sub

function getDirector(item as Object)
    result = createObject("roString")
    directorString = "Режиссер: "
    result.AppendString(directorString, directorString.Len())
    result.AppendString(item.director, item.director.Len())
    return result
end function

function getRate(item as Object)
    result = createObject("roString")
    
    if(item.DoesExist("imdb_rating"))
        iString = "imbd: "
        result.AppendString(iString,iString.Len())
        
        rate = item.imdb_rating.ToStr()
        if rate.Len() > 3
            rate = rate.Left(3)
        end if
        result.AppendString(rate, rate.Len())
        result.AppendString("    ", 4)
    end if
    
    if(item.DoesExist("kinopoisk_rating"))
        iString = "Кинопоиск: "
        result.AppendString(iString,iString.Len())
        
        rate = item.kinopoisk_rating.ToStr()
        if rate.Len() > 3
            rate = rate.Left(3)
        end if
        result.AppendString(rate, rate.Len())
    end if
    
    return result
end function

function getCast(item as Object)
    result = createObject("roString")
    cString = "В ролях: "
    result.AppendString(cString, cString.Len())
    result.AppendString(item.cast, item.cast.Len())
    return result
end function

function getDuration(durationSeconds as  Integer) as String
    second = durationSeconds MOD 60
    durationSeconds = durationSeconds \ 60
    minute = durationSeconds MOD 60
    durationSeconds = durationSeconds \ 60
    hour = durationSeconds MOD 60
    
    result = createObject("roString")
    dString = "Длительность: "
    result.AppendString(dString,dString.Len())
    if(hour > 0)
        if(hour < 10)
            result.AppendString("0",1)
        end if
        hourString = hour.ToStr()
        result.AppendString(hourString, hourString.Len())
    end if
    
    result.AppendString(":", 1)
    
    if(minute > 0)
        if(minute < 10)
            result.AppendString("0",1)
        end if
        minuteString = minute.ToStr()
        result.AppendString(minuteString, minuteString.Len())
    end if
    
    result.AppendString(":", 1)
    
    if(second > 0)
        if(second < 10)
            result.AppendString("0",1)
        end if
        secondString = second.ToStr()
        result.AppendString(secondString, secondString.Len())
    end if
    
    return result
end function

sub addLabel(group as Object, text as String, maxLines as Integer, fnt as Object, x as Integer, y as Integer, labelWidth as Integer)
    print "VideoDescriptionPanel:addLabel"
    label = createObject("roSGNode", "Label")
    label.height = 0
    label.numLines = 0
    label.maxLines = maxLines
    label.font = fnt
    label.translation = [x, y]
    label.wrap = true
    label.width = labelWidth
    label.lineSpacing = 1
    label.wordBreakChars = " ,-:."
    label.text = recode(text)
    group.appendChild(label) 
end sub

function getTitle(title as String, year as String) as String
    print "VideoDescriptionPanel:getTitle"
    newTitle = createObject("roString")
    
    newTitle.AppendString(title, title.Len())
    if year.Len() > 0
        newTitle.AppendString(" (", 2)
        newTitle.AppendString(year, year.Len())
        newTitle.AppendString(")", 1)
    end if
    
    return newTitle
end function

function getGenres(genres as Object) as String
    print "VideoDescriptionPanel:getGenres"
    genreString = createObject("roString")
    gString = "Жанр: "
    genreString.AppendString(gString,gString.Len())
    for i=0 To genres.Count() - 1 Step 1
        if i>0
            genreString.AppendString(", ", 2)
        end if
        
        genreString.AppendString(genres[i].title, genres[i].title.Len())
    end for
    
    return genreString
end function

function onKeyEvent(key as String, press as Boolean) as Boolean
print "VideoDescriptionPanel:onKeyEvent"
    if press
        if key = "right" and m.currentButtonIndex < m.buttons.Count() - 1
            m.currentButtonIndex = m.currentButtonIndex + 1
            m.buttons[m.currentButtonIndex].setFocus(true)
            return true
        end if
        
        if key = "left" and m.currentButtonIndex > 0
            m.currentButtonIndex = m.currentButtonIndex - 1
            m.buttons[m.currentButtonIndex].setFocus(true)
            return true
        end if
    end if
    
    return false
end function

sub recode(str as string) as string
    str = str.Replace("&#151;", "-")
    str = str.Replace("&#133;", "...")
    return m.global.utilities.callFunc("Encode", {str: str})
end sub