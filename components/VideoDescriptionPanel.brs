'TODO: This component relies heavily on the item only having a single Video array element. Is that safe?

sub init()
    m.top.panelSize = "full"
    m.top.isFullScreen = true
    m.top.leftPosition = 130
    m.top.focusable = true
    m.top.hasNextPanel = false

    m.top.updateFocus = false
    m.top.observeField("updateFocus", updateFocus)
    m.top.observeField("start", "showVideoDetails")
    m.top.isVideo = false
end sub

sub showVideoDetails()
    m.readItemTask = createObject("roSGNode", "ContentReader")
    m.readItemTask.baseUrl = m.top.itemUri
    m.readItemTask.parameters = m.top.itemUriParameters
    m.readItemTask.observeField("content", "itemReceived")
    m.readItemTask.observeField("error", "error")
    m.readItemTask.control = "RUN"
end sub

sub error()
    showErrorDialog("VideoDescriptionPanel:" + m.top.pType, m.readItemTask.error)
end sub

sub itemReceived()
    ' deviceInfo = createObject("roDeviceInfo")

    loadSettings()

    contentItem = m.readItemTask.content.item

    imageUri = contentItem.posters.big

    availableWidth  = m.top.width / 2 - 120
    availableHeight = m.top.height - 100

    widthHeight = availableWidth  * 250 / 165
    heightWidth = availableHeight * 165 / 250

    if widthHeight <= availableHeight
        width  = availableWidth
        height = widthHeight
    else
        height = availableHeight
        width  = heightWidth
    end if

    left = availableWidth / 2 - width / 2

    poster = createObject("roSGNode", "Poster")
    poster.translation = [left, 0]
    poster.width = width
    poster.height = height
    poster.loadDisplayMode = "scaleToFit"
    poster.uri = imageUri
    m.top.appendChild(poster)

    loadFonts()

    year        = contentItem.year.ToStr()
    title       = getTitle(contentItem.title, year)
    duration    = getDuration(contentItem.duration.total)
    genreString = getGenres(contentItem.genres)
    director    = getDirector(contentItem)
    cast        = getCast(contentItem)
    rate        = getRate(contentItem)

    plot = contentItem.plot

    textLeft = left + width + 50

    'HACKHACK: the unusedSpace here is a total banana. There is unused space on the screen which doesn't belong
    'to the panel and is not accounted in m.top.width. I couldn't figure out how to calculate it so hack.
    unusedSpace = 135
    labelWidth  = m.top.width - textLeft + unusedSpace

    group = createObject("roSGNode", "LayoutGroup")
    group.addItemSpacingAfterChild = false
    group.translation = [textLeft, 0]
    addLabel(group, title, 1, m.font24, 0, 0, labelWidth)
    if rate.Len() > 0
        addLabel(group, rate, 1, m.font18, 0, 0, labelWidth)
    end if

    addLabel(group, duration,    1, m.font18, 0, 0, labelWidth)
    addLabel(group, genreString, 2, m.font18, 0, 0, labelWidth)
    addLabel(group, director,    1, m.font18, 0, 0, labelWidth)
    addLabel(group, cast,        2, m.font18, 0, 0, labelWidth)
    addLabel(group, plot,        8, m.font16, 0, 0, labelWidth)

    groupSpacings = createObject("roArray", group.getChildCount(), false)
    for i = 0 to group.getChildCount() - 2 step 1
        groupSpacings[i] = 5.0
    end for

    groupSpacings[group.getChildCount() - 1] = 12.0
    group.itemSpacings = groupSpacings

    m.buttons = createObject("roArray", 5, false)
    buttonGroup = createObject("roSGNode", "LayoutGroup")
    buttonGroup.layoutDirection = "horiz"
    buttonGroup.width = labelWidth

    setQuality(contentItem)
    setAudio(contentItem)

    m.playButton    = addButton(buttonGroup, "play",  "playButton")
    m.audioButton   = addButton(buttonGroup, "audio", "audioButton")
    m.qualityButton = addButton(buttonGroup, m.qualities[m.qualityIndex], "qualityButton")
    m.streamButton  = addButton(buttonGroup, m.streams[m.streamIndex],    "streamButton")

    m.currentButtonIndex = 0

    group.appendChild(buttonGroup)
    m.top.appendChild(group)

    m.playButton.setFocus(true)
end sub

function addButton(group as Object, text as String, callback as String)
    button = createObject("roSGNode", "Button")
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
    return button
end function

sub playButton()
    episode = m.readItemTask.content.item.videos[0]
    if episode.doesExist("watching") and episode.watching <> invalid and episode.watching.doesExist("status") and episode.watching.doesExist("time") and episode.watching.status = 0 and episode.watching.time <> invalid
        m.dialog = createObject("roSGNode", "Dialog")

        font = createFont(24)

        title = createObject("roString")
        appStr = "Вы хотите продолжить c "
        AppendString(title, appStr)
        durationStr = durationToString(episode.watching.time)
        AppendString(title, durationStr)

        m.dialog.buttons = [ recode("Да"), recode("Нет")]
        m.dialog.title = recode(title)
        m.dialog.titleFont = font
        m.dialog.buttonGroup.textFont = font
        m.dialog.buttonGroup.focusedTextFont = font
        m.dialog.observeField("buttonSelected", "watchingDialogResponse")
        m.top.dialog = m.dialog
    else
        'There is no existing status to continue, start from scratch
        gotoVideo(0.0)
    end if
end sub

sub watchingDialogResponse()
    button = m.dialog.buttonSelected
    m.dialog.close = true
    seekTo = 0.0
    if button = 0
        seekTo = m.readItemTask.content.item.videos[0].watching.time
    end if

    gotoVideo(seekTo)
end sub

function findMatchingVideoUri()
    for each video in m.readItemTask.content.item.videos[0].files
        if video.quality = m.qualities[m.qualityIndex]
            videoUri = video.url[m.streams[m.streamIndex]]
            if videoUri <> invalid
                return videoUri
            end if
        end if
    end for

    return invalid
end function

sub gotoVideo(seek as Float)
    nPanel = createObject("roSGNode", "VideoNode")

    videoUri = findMatchingVideoUri()
    if videoUri = invalid
        print "VideoDescriptionPanel:gotoVideo: videoUri is invalid"
        return
    end if

    'TODO: what if we couldn't find the correct video? Should handle and not crash
    playlist = createObject("roSGNode", "ContentNode")
    episodeEntry = createObject("roSGNode", "ContentNode")
    episodeEntry.addFields({
        videoFormat: m.streams[m.streamIndex],
        videoUri: videoUri,
        audioTrack: m.audioIndexes[m.audioIndex],
        videoId: m.readItemTask.content.item.id.ToStr(),
        title: getTitle(m.readItemTask.content.item.title, m.readItemTask.content.item.year.ToStr()),
        videoNumber: 1,
        seasonId: invalid,
        seek: seek,
        watched: false
    })
    playlist.appendChild(episodeEntry)

    nPanel.playlist = playlist
    m.top.nPanel = nPanel
end sub

sub showDialog(list as Object, index as Integer, callback as String, font as Object, title as String)
    m.dialog = createObject("roSGNode", "StandardMessageDialog")
    m.dialog.title   = title
    m.dialog.buttons = list
    m.dialog.observeField("buttonSelected", callback)
    m.top.dialog = m.dialog

    ' Set focus on proper button
    buttonArea = findNodeBySubtype(m.dialog, "StdDlgButtonArea")
    buttons = findNodesBySubtype(buttonArea, "StdDlgButton")
    buttons[index].setFocus(true)
end sub

sub audioButton()
    showDialog(m.audioTitles, m.audioIndex, "audioSelected", m.font18, "Аудио")
end sub

sub streamButton()
    showDialog(m.streams, m.streamIndex, "streamSelected", m.font24, "Стрим")
end sub

sub qualityButton()
    showDialog(m.qualities, m.qualityIndex, "qualitySelected", m.font24, "Качество")
end sub

function settingsKey() as String
    return "video-%d-settings".Format(m.readItemTask.content.item.id)
end function

sub saveSettings()
    sec = createObject("roRegistrySection", settingsKey())
    sec.Write("quality", m.qualities[m.qualityIndex])
    sec.Write("stream",  m.streams[m.streamIndex])
    sec.Write("audio",   m.audioTitles[m.audioIndex])
    sec.Flush()
end sub

function loadSetting(section as Object, key as String, defaultValue as String) as String
    value = section.Read(key)
    if value = invalid or value = ""
        value = defaultValue
    end if
    return value
end function

sub loadSettings()
    sec = createObject("roRegistrySection", settingsKey())

    m.quality = loadSetting(sec, "quality", "1080p")
    m.stream  = loadSetting(sec, "stream",  "hls4")
    m.audio   = loadSetting(sec, "audio",   "audio")
end sub

sub qualitySelected()
    m.qualityIndex = m.dialog.buttonSelected
    m.dialog.close = true
    setStreams(m.readItemTask.content.item)
    m.qualityButton.text = m.qualities[m.qualityIndex]
    saveSettings()
end sub

sub streamSelected()
    m.streamIndex = m.dialog.buttonSelected
    m.dialog.close = true
    m.streamButton.text = m.streams[m.streamIndex]
    saveSettings()
end sub

sub audioSelected()
    m.audioIndex = m.dialog.buttonSelected
    m.dialog.close = true
    saveSettings()
end sub

sub setQuality(item as Object)
    files = item.videos[0].files
    qualityCount = files.Count()
    m.qualities = createObject("roArray", qualityCount, false)
    m.qualityIndex = -1
    for i = 0 to files.Count() - 1 step 1
        m.qualities.push(files[i].quality)
        if files[i].quality = m.quality
            m.qualityIndex = i
        end if
    end for

    if m.qualityIndex = -1
        m.qualityIndex = m.qualities.Count() - 1
    end if

    setStreams(item)
end sub

sub setStreams(item as Object)
    if m.streamIndex <> invalid and m.streamIndex >= 0
        preferredStream = m.streams[m.streamIndex]
    else
        preferredStream = "hls4"
    end if

    m.streams = item.videos[0].files[m.qualityIndex].url.Keys()
    m.streams.Sort("")

    m.streamIndex = -1
    for i = 0 to m.streams.Count() - 1 step 1
        if m.streams[i] = preferredStream
            m.streamIndex = i
        end if
    end for

    if m.streamIndex = -1
        m.streamIndex = 0
    end if
end sub

sub setAudio(item as Object)
    audios = item.videos[0].audios
    m.audioTitles  = createObject("roArray", audios.Count(), false)
    m.audioIndexes = createObject("roArray", audios.Count(), false)
    m.audioIndex = 0
    index = 1
    for each track in audios
        m.audioIndexes.push(track.index.ToStr())
        if track.type = invalid
            title = createObject("roString")
            title.AppendString("Track ", 6)
            str = index.ToStr()
            AppendString(title, str)
        else
            title = track.type.title
            if track.lang <> invalid
                title = title + " (" + track.lang + ")"
            end if
            if track.author <> invalid AND track.author.title <> invalid
                title = title + " - " + track.author.title
            end if
            if track.codec <> invalid
                title = title + " - " + UCase(track.codec)
            end if
        end if
        if title = m.audio
            m.audioIndex = index - 1 ' index starts from 1, audioIndex from 0
        end if
        m.audioTitles.push(title)
        index = index + 1
    end for
end sub

function getDirector(item as Object)
    result = createObject("roString")
    directorString = "Режиссер: "
    AppendString(result, directorString)
    AppendString(result, item.director)
    return result
end function

function getRate(item as Object)
    result = createObject("roString")

    if item.DoesExist("imdb_rating") and item.imdb_rating <> invalid
        iString = "imbd: "
        AppendString(result, iString)

        rate = item.imdb_rating.ToStr()
        if rate.Len() > 3
            rate = rate.Left(3)
        end if
        AppendString(result, rate)
        result.AppendString("    ", 4)
    end if

    if item.DoesExist("kinopoisk_rating") and item.kinopoisk_rating <> invalid
        iString = "Кинопоиск: "
        AppendString(result, iString)

        rate = item.kinopoisk_rating.ToStr()
        if rate.Len() > 3
            rate = rate.Left(3)
        end if
        AppendString(result, rate)
    end if

    return result
end function

function getCast(item as Object)
    result = createObject("roString")
    cString = "В ролях: "
    AppendString(result, cString)
    AppendString(result, item.cast)
    return result
end function

function getDuration(durationSeconds as  Integer) as String
    durationString = durationToString(durationSeconds)

    result = createObject("roString")
    dString = "Длительность: "
    AppendString(result, dString)
    AppendString(result, durationString)

    return result
end function

sub addLabel(group as Object, text as String, maxLines as Integer, fnt as Object, x as Integer, y as Integer, labelWidth as Integer)
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
    newTitle = createObject("roString")

    AppendString(newTitle, title)
    if year.Len() > 0
        AppendString(newTitle, " (")
        AppendString(newTitle, year)
        AppendString(newTitle, ")")
    end if

    return newTitle
end function

function getGenres(genres as Object) as string
    genreString = createObject("roString")
    gString = "Жанры: "
    AppendString(genreString, gString)
    for i = 0 To genres.Count() - 1 Step 1
        if i > 0
            AppendString(genreString, ", ")
        end if

        AppendString(genreString, genres[i].title)
    end for

    return genreString
end function

sub updateFocus()
    if m.top.updateFocus
        m.buttons[0].setFocus(true)
    end if
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
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
