sub init()
    'm.itemposter = m.top.findNode("itemPoster")
    
    m.font18  = CreateObject("roSGNode", "Font")
    m.font18.uri = "pkg:/fonts/NotoSans-Regular-w1251-rename.ttf"
    m.font18.size = 18
    m.firstLoad = true
end sub

sub showcontent()
    if false = m.firstLoad
        return
    end if

    m.firstLoad = false
    itemcontent = m.top.itemContent 
    
    borderStroke = 2
    left = borderStroke
    top = borderStroke
    rectleft = 0
    rectTop = 0
    rectWidth = itemContent.itemWidth
    rectHeight = itemContent.itemheight
    height =itemContent.itemheight - borderStroke*2
    width = itemContent.itemWidth - borderStroke*2 
    textTop = height - 18
    
    if itemContent.scale
        availableWidth = itemContent.itemWidth - (borderStroke*2)
        availableHeight = itemContent.itemheight - (borderStroke*2) - 18   
        widthHeight = availableWidth * 250 / 165
        heightWidth = availableHeight * 165 / 250
    
        if widthHeight <= availableHeight
            width = availableWidth
            height = widthHeight
        else
            height = availableHeight
            width = heightWidth
        end if
    
        left = itemContent.itemwidth/2 - width/2
        top = itemContent.itemheight/2 - height/2
        rectLeft = left - borderStroke
        rectWidth = width + (borderStroke*2)
        rectHeight = height + (borderStroke*2)
        rectTop = top - borderStroke
        textTop = height + borderStroke
    end if
    
    m.rectangle = createObject("roSGNode", "Rectangle")
    m.rectangle.width = rectWidth
    m.rectangle.height = rectHeight
    m.rectangle.translation = [rectLeft, rectTop]
    m.rectangle.opacity = 0
    m.top.appendChild(m.rectangle)
   
    poster = createObject("roSGNode", "Poster")
    m.poster = poster
    poster.width = width
    poster.translation = [left, top]
    poster.height = height
    poster.loadDisplayMode = "scaleToFit"
    poster.uri = itemcontent.HDPosterUrl
    if itemcontent.seasonWatched
        poster.opacity = 0.5
    end if
    m.top.appendChild(poster)
    
    itemContent.observeField("seasonWatched","updateWatched")
   
    itemlabel = createObject("roSGNode", "Label")
    itemlabel.font = m.font18 
    itemlabel.translation = [ left, textTop ]
    itemlabel.horizAlign = "center"
    itemlabel.width = itemContent.itemwidth
    itemlabel.height = 18
    itemLabel.text = itemcontent.title
    
    m.top.appendChild(itemLabel)
    
end sub

sub updateWatched()
    print "SeasonRowListComponent:updateWatched()"
    if m.top.itemContent.seasonWatched
        m.poster.opacity = 0.5
    else
        m.poster.opacity = 1
    end if
end sub

sub showfocus()
    'scale = 1 + (m.top.focusPercent * 0.08)
    'm.itemposter.scale = [scale, scale]
    if m.top.focusPercent > 0.5
        m.rectangle.opacity = 1
    else
        m.rectangle.opacity = 0
    end if
end sub

sub showrowfocus()
    'm.itemlabel.opacity = m.top.rowFocusPercent
end sub