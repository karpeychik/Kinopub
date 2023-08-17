sub init()
    loadFonts()
    m.itemContent = invalid

    m.loaded = false
end sub

sub showcontent()
    if m.loaded
        return
    end if

    itemContent = m.top.itemContent

    borderStroke = 2

    availableWidth = itemContent.itemWidth - (borderStroke * 2)
    availableHeight = itemContent.itemheight - (borderStroke * 2)

    widthHeight = availableWidth * 270 / 480
    heightWidth = availableHeight * 480 / 270

    if widthHeight <= availableHeight
        width = availableWidth
        height = widthHeight
    else
        height = availableHeight
        width = heightWidth
    end if

    left = itemContent.itemwidth / 2 - width / 2

    rectLeft = left - borderStroke
    rectWidth = width + (borderStroke * 2)
    rectHeight = height + (borderStroke * 2)

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
    poster.uri = itemContent.posterLink
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

    itemLabel = createObject("roSGNode", "Label")
    itemLabel.font = m.font12
    itemLabel.translation = [ left + 2, height + borderStroke - labelRectHeight ]
    itemLabel.horizAlign = "right"
    itemLabel.vertAlign = "center"
    itemLabel.width = width - 7
    itemLabel.height = labelRectHeight
    itemLabel.text = itemContent.itemTitle
    m.itemLabel = itemLabel
    m.top.appendChild(itemLabel)

    if itemContent.EpisodeWatched
        poster.opacity = 0.5
        itemLabel.color = "#80FF80"
    else
        itemLabel.color = "#DDDDFF"
    end if

    m.top.itemContent.observeField("episodeWatched", "watchedChange")
    m.loaded = true

end sub

sub watchedChange()
    ' print "EpisodeRowListComponent:watchedChange()"
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
