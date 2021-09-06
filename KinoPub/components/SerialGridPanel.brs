'TODO: store fonts in fontregistry
'TODO: extract base class from this and video description?

sub init()
    print "SerialGridPanel:init()"
    m.top.panelSize = "full"
    m.top.isFullScreen = true
    m.top.leftPosition = 130
    m.top.focusable = true
    m.top.hasNextPanel = false
    m.top.createNextPanelOnItemFocus = false
    
    m.top.isVideo = false
    m.top.observeField("start", "loadSerial")
end sub

sub loadSerial()
    print "SerialGridPanel:loadSerial()"
    m.top.overhangTitle = "Kino.pub"
    
    m.progressDialog = createObject("roSGNode", "ProgressDialog")
    
    m.readSerialTask = createObject("roSGNode", "ContentReader")
    m.readSerialTask.baseUrl = m.top.serialBaseUri
    m.readSerialTask.parameters = m.top.serialUriParameters
    m.readSerialTask.observeField("content", "showSerial")
    m.readSerialTask.observeField("error", "error")
    m.readSerialTask.control = "RUN"
    
    m.top.dialog = m.progressDialog
    m.top.updateFocus = false
    m.top.panelSet.observeField("isGoingBack", "slideBack")
end sub

sub error()
    print "SerialGridPanel:error()"
    source = "SerialGridPanel:"
    errorMessage = m.global.utilities.callFunc("GetErrorMessage", {errorCode: m.readSerialTask.error, source: source})
    print errorMessage
    font  = CreateObject("roSGNode", "Font")
    font.uri = "pkg:/fonts/NotoSans-Regular-w1251-rename.ttf"
    font.size = 24

    m.dialog = createObject("roSGNode", "Dialog")
    m.dialog.title = recode("ÐžÑˆÐ¸Ð±ÐºÐ°")
    m.dialog.titleFont = font
    m.dialog.message = recode(errorMessage)
    m.dialog.messageFont = font
    m.top.dialog = m.dialog
end sub

sub slideBack()
    if m.top.isInFocusChain() and false = m.top.panelSet.isGoingBack
        print "SerialGridPanel:slideBack"
        for i=0 to m.rowList.content.getChild(0).getChildCount()-1
            season = m.rowList.content.getChild(0).getChild(i)
            seasonWatched = true
            for j=season.getChildCount()-1 to 0 step -1
                episode = season.getChild(j)
                
                if i = 1
                    print episode
                end if
                
                if 1 <> episode.watched
                    seasonWatched = false
                    exit for
                end if
            end for
            
            season.seasonWatched = seasonWatched
        end for
        
        m.rowList.setFocus(true)
    end if
end sub

sub showSerial()
    print "SerialGridPanel:showSerial()"
    
    imageUri = m.readSerialTask.content.item.posters.medium
    
    availableWidth = m.top.width / 3
    availableHeight = m.top.height * 7 / 12
    
    widthHeight = availableWidth * 250 / 165
    heightWidth = availableHeight * 165 / 250
    
    if widthHeight <= availableHeight
        width = availableWidth
        height = widthHeight
    else
        height = availableHeight
        width = heightWidth
    end if
    
    left = 0
    
    m.font24  = CreateObject("roSGNode", "Font")
    m.font24.uri = "pkg:/fonts/NotoSans-Regular-w1251-rename.ttf"
    m.font24.size = 24
    
    m.font18  = CreateObject("roSGNode", "Font")
    m.font18.uri = "pkg:/fonts/NotoSans-Regular-w1251-rename.ttf"
    m.font18.size = 18
    
    m.font16  = CreateObject("roSGNode", "Font")
    m.font16.uri = "pkg:/fonts/NotoSans-Regular-w1251-rename.ttf"
    m.font16.size = 16
    
    vGroup = createObject("roSGNode", "LayoutGroup")
    vGroup.addItemSpacingAfterChild =  true
    vGroup.translation = [left, 0]
    vGroup.itemSpacings = [ 25.0 ]
    
    group = createObject("roSGNode", "LayoutGroup")
    group.addItemSpacingAfterChild =  true
    group.translation = [left, 0]
    group.layoutDirection = "horiz"
    group.itemSpacings = [ 50.0 ]
    
    poster = createObject("roSGNode", "Poster")
    poster.focusable = false
    poster.translation = [0, 0]
    poster.width = width
    poster.height = height 
    poster.loadDisplayMode = "scaleToFit"
    poster.uri = imageUri
    
    group.appendChild(poster)
    
    labelGroup = createObject("roSGNode", "LayoutGroup")
    labelGroup.addItemSpacingAfterChild =  false
    labelGroup.translation = [left, 0]
    labelGroup.focusable = false
    
    'HACKHACK: the unusedSpace here is a total banana. There is unused space on the screen which doesn't belong
    'to the panel and is not accounted in m.top.width. I couldn't figure out how to calculate it so hack.
    unusedSpace = 135
    
    textLeft = left + width + 50
    labelWidth = m.top.width - textLeft + unusedSpace
    
    title = m.readSerialTask.content.item.title
    genreString = getGenres(m.readSerialTask.content.item.genres)
    director = getDirector(m.readSerialTask.content.item)
    cast = getCast(m.readSerialTask.content.item)
    rate = getRate(m.readSerialTask.content.item)
    plot = m.readSerialTask.content.item.plot
    
    addLabel(labelGroup, title, 1, m.font24, 0, 0, labelWidth)
    if(rate.Len() > 0)
        addLabel(labelGroup, rate, 1, m.font18, 0, 0, labelWidth)
    end if 
    
    addLabel(labelGroup, genreString, 2, m.font18, 0, 0, labelWidth)
    addLabel(labelGroup, director, 1, m.font18, 0, 0, labelWidth)
    addLabel(labelGroup, cast, 2, m.font18, 0, 0, labelWidth)
    
    addLabel(labelGroup, plot, 7, m.font16, 0, 0, labelWidth)
    
    groupSpacings = createObject("roArray", labelGroup.getChildCount(), false)
    for i=0 to labelGroup.getChildCount() - 2 step 1
        groupSpacings[i] = 5.0
    end for
    
    labelGroup.itemSpacings = groupSpacings
    
    group.appendChild(labelGroup)
    
    vGroup.appendChild(group)
    
    rowList = createObject("roSGNode", "RowList")
    rowList.itemComponentName = "SeasonRowListComponent"
    rowList.numRows = 1
    rowList.rowItemSize = [ [100, 200] ]
    rowList.rowItemSpacing = [[ 40, 0 ]]
    rowList.showRowLabel = [ true ]
    rowlist.itemSize = [ 1000, 200 ]
    rowList.showRowLabel = false
    rowList.drawFocusFeedback = false
    rowList.vertFocusAnimationStyle = "fixedFocusWrap" 
    rowList.rowFocusAnimationStyle = "floatingFocus"
    rowList.observeField("rowItemSelected", "rowItemSelected")
    m.rowList = rowList
    
    content = createObject("roSGNode", "ContentNode")
    row = createObject("roSGNode", "ContentNode")
    row.title = "Seasons"
    
    for i=0 to m.readSerialTask.content.item.seasons.Count()-1 step 1
        seasonWatched = true
        for each episode in m.readSerialTask.content.item.seasons[i].episodes
            if episode.watched <> 1
                seasonWatched = false
                exit for
            end if
        end for
        
        
        itemContent = buildSeasonNode(i)
        itemContent.title = recode("Сезон " + m.readSerialTask.content.item.seasons[i].number.ToStr())
        itemContent.HDPosterUrl = m.readSerialTask.content.item.posters.small
        itemContent.addFields({itemWidth: 100, itemHeight: 200, seasonWatched: seasonWatched, scale: true })
        row.appendChild(itemContent)
    end for 
    
    content.appendChild(row)
    
    print content
    
    rowList.content = content
    
    vGroup.appendChild(rowList)
    
    m.top.appendChild(vGroup)
    
    rowList.setFocus(true)
    m.progressDialog.close = true
end sub

sub rowItemSelected()
    print "SerialGridPanel:rowItemSelected"
    print m.rowList.rowItemSelected
    
    seasonIndex = m.rowList.rowItemSelected[1]
    seasonNode = m.rowList.content.getChild(0).getChild(seasonIndex)
    
    'nPanel = createObject("roSGNode", "SeasonListPanel")
    nPanel = createObject("roSGNode", "SeasonRowListPanel")
    nPanel.serial = m.readSerialTask.content.item
    nPanel.seasonIndex = seasonIndex
    nPanel.seasonNode = seasonNode
    
    m.top.nPanel = nPanel
end sub

function buildSeasonNode(seasonIndex as Integer)
    print "SerialGridPanel:buildContentNode"
    content = createObject("roSGNode", "ContentNode")
    serial = m.readSerialTask.content.item
    
    content.addFields({
        serialName: serial.title, 
        videoId: serial.id.ToStr(), 
        seasonIndex: seasonIndex})
        
    season = serial.seasons[seasonIndex]
    
    for each episode in season.episodes
        episodeNode = createObject("roSGNode", "ContentNode")
        episodeNode.addFields({
            title: episode.title,
            thumbnail: episode.thumbnail,
            number: episode.number,
            audios: episode.audios,
            watched: episode.watched
            watchedTime: episode.watching.time,
            watchingStatus: episode.watching.status
            subtitles: episode.subtitles,
            files: episode.files})
            
        content.appendChild(episodeNode)
    end for
    
    return content
end function

function getGenres(genres as Object) as String
    print "SerialGridPanel:getGenres"
    genreString = createObject("roString")
    gString = "Жанры: "
    genreString.AppendString(gString,gString.Len())
    for i=0 To genres.Count() - 1 Step 1
        if i>0
            genreString.AppendString(", ", 2)
        end if
        
        genreString.AppendString(genres[i].title, genres[i].title.Len())
    end for
    
    return genreString
end function

function getDirector(item as Object)
    result = createObject("roString")
    directorString = "Режиссер: "
    result.AppendString(directorString, directorString.Len())
    result.AppendString(item.director, item.director.Len())
    return result
end function

function getRate(item as Object)
    result = createObject("roString")
    
    if item.DoesExist("imdb_rating") and item.imdb_rating <> invalid
        iString = "imbd: "
        result.AppendString(iString,iString.Len())
        
        print type(item.imdb_rating)
        print item.imdb_rating
        rate = item.imdb_rating.ToStr()
        if rate.Len() > 3
            rate = rate.Left(3)
        end if
        result.AppendString(rate, rate.Len())
        result.AppendString("    ", 4)
    end if
    
    if item.DoesExist("kinopoisk_rating") and item.kinopoisk_rating <> invalid
        iString = "КиноПоиск: "
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

sub recode(str as string) as string
    str = str.Replace("&#151;", "-")
    str = str.Replace("&#133;", "...")
    return m.global.utilities.callFunc("Encode", {str: str})
end sub