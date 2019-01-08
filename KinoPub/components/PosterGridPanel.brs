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
    
    m.top.grid.setFocus(true)
    m.top.grid.visible = true
    m.top.grid.content = content
end sub

sub itemSelected()
    print "PosterGrid:itemSelected"
    selectedItem = m.top.grid.content.getChild(m.top.grid.itemSelected)
    nextPanel = createObject("roSGNode", "VideoDescriptionPanel")
    nextPanel.itemUriParameters = ["access_token", m.global.accessToken]
    itemUrl = "https://api.service-kp.com/v1/items/" + selectedItem.kinoPubId
    nextPanel.itemUri = itemUrl
    m.top.nextPanel = nextPanel
end sub