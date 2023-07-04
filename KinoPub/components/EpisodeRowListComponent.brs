sub init()
    print "EpisodeRowListComponent:init()"
    
    m.font18  = CreateObject("roSGNode", "Font")
    m.font18.uri = "pkg:/fonts/NotoSans-Regular-w1251-rename.ttf"
    m.font18.size = 12
    m.itemContent = invalid
    
    m.loaded = false
end sub

sub showcontent()
    print "EpisodeRowListComponent:showContent()"
    if m.loaded
        return
    end if
   
    itemcontent = m.top.itemContent 
    
    borderStroke = 2
    
    availableWidth = itemcontent.itemWidth - (borderStroke*2)
    availableHeight = itemcontent.itemheight - (borderStroke*2)
   
    widthHeight = availableWidth * 270 / 480
    heightWidth = availableHeight * 480 / 270
    
    if widthHeight <= availableHeight
        width = availableWidth
        height = widthHeight
    else
        height = availableHeight
        width = heightWidth
    end if
    
    left = itemcontent.itemwidth/2 - width/2
    
    rectLeft = left - borderStroke
    rectWidth = width + (borderStroke*2)
    rectHeight = height + (borderStroke*2)
    
    m.rectangleL = createObject("roSGNode", "Rectangle")
    m.rectangleL.width = borderStroke
    m.rectangleL.height = rectHeight
    m.rectangleL.translation = [rectLeft, 0]
    m.rectangleL.opacity = 0
    m.top.appendChild(m.rectangleL)
    
    m.rectangleR = createObject("roSGNode", "Rectangle")
    m.rectangleR.width = borderStroke
    m.rectangleR.height = rectHeight
    m.rectangleR.translation = [rectWidth, 0]
    m.rectangleR.opacity = 0
    m.top.appendChild(m.rectangleR)
    
    m.rectangleT = createObject("roSGNode", "Rectangle")
    m.rectangleT.width = rectWidth
    m.rectangleT.height = borderStroke
    m.rectangleT.translation = [rectLeft, 0]
    m.rectangleT.opacity = 0
    m.top.appendChild(m.rectangleT)
    
    m.rectangleB = createObject("roSGNode", "Rectangle")
    m.rectangleB.width = rectWidth
    m.rectangleB.height = borderStroke
    m.rectangleB.translation = [rectLeft, rectHeight - borderStroke]
    m.rectangleB.opacity = 0
    m.top.appendChild(m.rectangleB)
   
    poster = createObject("roSGNode", "Poster")
    poster.width = width
    poster.translation = [left, borderStroke ]
    poster.height = height
    poster.loadDisplayMode = "scaleToFit"
    poster.uri = itemcontent.posterLink
    m.poster = poster
    
    m.top.appendChild(poster)
    
    labelRectHeight = 30
    labelRect = createObject("roSGNode", "Rectangle")
    labelRect.width = width +1
    labelRect.height = labelRectHeight
    labelRect.translation = [left, height + borderStroke - labelRectHeight]
    labelRect.opacity = 1
    labelRect.color = "#222222"
    m.top.appendChild(labelRect)
    
    itemlabel = createObject("roSGNode", "Label")
    itemlabel.font = m.font18 
    itemlabel.translation = [ left + 2, height + borderStroke - labelRectHeight ]
    itemlabel.horizAlign = "right"
    itemlabel.vertAlign = "center"
    itemlabel.width = width - 7
    itemlabel.height = labelRectHeight
    itemlabel.text = itemcontent.itemTitle
    m.itemLabel = itemlabel
    m.top.appendChild(itemlabel)
    
    if itemcontent.EpisodeWatched
        poster.opacity = 0.5
        itemlabel.color = "#80FF80"
    else
        itemlabel.color = "#DDDDFF"
    end if
    
    m.top.itemContent.observeField("episodeWatched", "watchedChange")
    m.loaded = true
    
end sub

sub watchedChange()
    print "EpisodeRowListComponent:watchedChange()"
    if m.top.itemContent.episodeWatched
        m.poster.opacity = 0.5
        m.itemLabel.color = "#80FF80"
    else
        m.poster.opacity = 1
        m.itemLabel.color = "#DDDDFF"
    end if
end sub

sub showfocus()
    if m.top.focusPercent > 0.5
        m.rectangleL.opacity = 1
        m.rectangleR.opacity = 1
        m.rectangleT.opacity = 1
        m.rectangleB.opacity = 1
    else
        m.rectangleL.opacity = 0
        m.rectangleR.opacity = 0
        m.rectangleT.opacity = 0
        m.rectangleB.opacity = 0
    end if
end sub

sub showrowfocus()
end sub
