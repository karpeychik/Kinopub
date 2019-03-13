'TODO: add rating to the 2nd caption line
sub init()
    print "Initializing poster"
    m.top.panelSize = "full"
    m.top.isFullScreen = true
    m.top.leftPosition = 130
    m.top.focusable = true
    m.top.hasNextPanel = false
    m.top.createNextPanelOnItemFocus = false
    m.posterWidth = 250.0
    m.top.grid = m.top.findNode("posterGrid")

	m.top.grid.vertFocusAnimationStyle = "floatingFocus"
    
    deviceInfo = CreateObject("roDeviceInfo")
    resolution = deviceInfo.GetUIResolution()
    physicalWidth = deviceInfo.GetDisplayProperties().Width * 10.0
    mmPixelCoef = physicalWidth / resolution.width
    
    gridRect = m.top.boundingRect()
    posterWidth = m.posterWidth * mmPixelCoef
    
    numColumns = Fix(gridRect.width / posterWidth)
    m.top.grid.numColumns = numColumns
    
    m.top.grid.numRows = 100
    posterWidth = gridRect.width / numColumns
    m.top.grid.basePosterSize = [ posterWidth, (250 * posterWidth) / 165]
    
    m.top.observeField("start","loadCategoryPosters")
    m.top.grid.observeField("itemSelected","itemSelected")
    m.top.isVideo = false
end sub

sub loadCategoryPosters()
    print "loadCategoryPosters"
    m.top.overhangTitle = "Kino.pub"
    m.readPosterGridTask = createObject("roSGNode", "ContentReader")
    m.readPosterGridTask.baseUrl = m.top.gridContentBaseUri
    m.readPosterGridTask.parameters = m.top.gridContentUriParameters
    m.readPosterGridTask.observeField("content", "showPosterGrid")
    m.readPosterGridTask.control = "RUN"
end sub

sub showPosterGrid()    
    print "PosterGrid:showPosterGrid"
    content = createObject("roSGNode", "ContentNode")
    for each item in m.readPosterGridTask.content.items
        itemcontent = createObject("roSGNode", "ContentNode")
        itemcontent.setField("shortdescriptionline1", m.global.utilities.callFunc("Encode", {str: item.title}))
        itemcontent.setField("hdgridposterurl", item.posters.small)
        itemcontent.addFields({kinoPubId: item.id.ToStr(), kinoPubType: item.type})
        content.appendChild(itemContent)
    end for

	totalPages = m.readPosterGridTask.content.pagination.total
	currentPage = m.readPosterGridTask.content.pagination.current
	nextPage = currentPage + 1

	m.top.hasNextPanel = true
	if nextPage > totalPages
		nextPage = totalPages
		m.top.hasNextPanel = false		
	end if
	m.top.nextPage = nextPage

    m.top.grid.setFocus(true)
    m.top.grid.visible = true
    m.top.grid.content = content

    m.top.grid.observeField("focusedChild","nextPageSlide")
end sub

sub nextPageSlide(evt)
print "PosterGrid:nextPageSlide"
data = evt.getData()
print m.top.nextPage
if not m.top.panelSet.isGoingBack and type(data) <> "roInvalid"	 and m.top.hasNextPanel = true	
	if data.horizFocusDirection = "none" and data.vertFocusDirection = "none"
		nPanel = createObject("roSGNode", "PosterGridPanel")
		nPanel.gridContentBaseUri = m.top.gridContentBaseUri
		nPanel.category = m.top.category
		
		if m.top.category = ""
			nPanel.gridContentUriParameters = ["page", m.top.nextPage, "perpage", 14]
		else
			nPanel.gridContentUriParameters = ["type", m.top.category, "page", m.top.nextPage, "perpage", 14]
		endif
		m.top.nPanel = nPanel
	end if
end if 
end sub

sub itemSelected()
    print "PosterGrid:itemSelected"
    selectedItem = m.top.grid.content.getChild(m.top.grid.itemSelected)
    print selectedItem
    if selectedItem.kinoPubType = "movie" or selectedItem.kinoPubType = "documovie" or selectedItem.kinoPubType = "concert" or selectedItem.kinoPubType = "3d" or selectedItem.kinoPubType = "4k"
        nPanel = createObject("roSGNode", "VideoDescriptionPanel")
        nPanel.itemUriParameters = ["access_token", m.global.accessToken]
        itemUrl = "https://api.service-kp.com/v1/items/" + selectedItem.kinoPubId
        nPanel.itemUri = itemUrl
        m.top.nPanel = nPanel
    else if selectedItem.kinoPubType = "serial" or selectedItem.kinoPubType = "docuserial" or selectedItem.kinoPubType = "tvshow"
        nPanel = createObject("roSGNode", "SerialGridPanel")
        nPanel.serialUriParameters = ["access_token", m.global.accessToken]
        itemUrl = "https://api.service-kp.com/v1/items/" + selectedItem.kinoPubId
        nPanel.serialBaseUri = itemUrl
        m.top.nPanel = nPanel
    end if
end sub
