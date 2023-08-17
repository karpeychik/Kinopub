sub init()
    m.top.panelSize = "full"
    m.top.isFullScreen = true
    m.top.leftPosition = 130
    m.top.focusable = true
    m.top.hasNextPanel = false
    m.top.isVideo = false

    m.top.updateFocus = false

    m.top.observeField("start", "start")
    m.top.observeField("updateFocus", "updateFocus")

    'HACKHACK: These are expected thumbnail dimensions. How can we make sure that this is always the case?
    thumbWidth = 480
    thumbHeight = 270

    m.panelWidth = 1280 - m.top.leftPosition

    m.posterWidth = 200
    m.posterHeight = m.posterWidth*thumbHeight/thumbWidth

    m.separ = 0

    m.numColumns = Fix(m.panelWidth / (m.posterWidth + m.separ))
end sub

sub start()
    m.rowList = createObject("roSGNode", "RowList")
    rowList = m.rowList
    rowList.itemComponentName = "EpisodeRowListComponent"
    rowList.numRows = 5
    rowList.rowItemSize = [ [m.posterWidth, m.posterHeight] ]
    rowList.rowItemSpacing = [[ m.separ, m.separ ]]
    rowList.showRowLabel = [ true ]
    rowList.itemSize = [ m.panelWidth, m.posterHeight ]
    rowList.showRowLabel = false
    rowList.drawFocusFeedback = false
    rowList.vertFocusAnimationStyle = "floatingFocus"
    rowList.rowFocusAnimationStyle = "floatingFocus"
    rowList.observeField("rowItemSelected", "rowItemSelected")

    content = createObject("roSGNode", "ContentNode")
    columnCount = 0
    row = createObject("roSGNode", "ContentNode")
    for i = 0 to m.top.seasonNode.getChildCount() - 1
        item = m.top.seasonNode.getChild(i)
        if columnCount = m.numColumns
            columnCount = 0
            content.appendChild(row)
            row = createObject("roSGNode", "ContentNode")
        end if

        title = createObject("roString")

        if item.doesExist("number")
            if item.number < 9
                title.AppendString("0", 1)
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

    rowList.content = content

    m.top.appendChild(rowList)

    rowList.setFocus(true)

end sub

sub updateFocus()
    if m.top.updateFocus
        if m.playlist <> invalid
            for i = 0 to m.playlist.getChildCount() - 1 step 1
                episodeIndex = m.playListFirstIndex + i
                rowIndex = episodeIndex \ m.numColumns
                columnIndex = episodeIndex MOD m.numColumns
                row = m.rowList.content.getChild(rowIndex)
                item = row.getChild(columnIndex)
                item.episodeWatched = m.playlist.getChild(i).watched
                m.top.seasonNode.getChild(episodeIndex).watched = m.playlist.getChild(i).watched
            end for
        end if

        m.rowList.setFocus(true)
    end if
end sub

sub rowItemSelected()
    episodeIndex = m.rowList.rowItemSelected[0] * m.numColumns + m.rowList.rowItemSelected[1]
    episode = m.top.seasonNode.getChild(episodeIndex)

    nPanel = createObject("roSGNode", "EpisodeVideoDescriptionPanel")
    nPanel.itemUriParameters = ["access_token", m.global.accessToken]
    nPanel.serial  = m.top.serial
    nPanel.season  = m.top.seasonNode
    nPanel.episode = episode
    m.top.nPanel = nPanel
end sub

function recode(str as String)
    return m.global.utilities.callFunc("Encode", {str: str})
end function
