sub init()
    print "MenuScene: Init"
    print m.global.accessToken

    m.readContentTask = createObject("roSGNode", "ContentReader")
    m.readContentTask.observeField("content", "setcategories")
        
    m.readContentTask.baseUrl = "https://api.service-kp.com/v1/types"
    m.readContentTask.parameters = ["access_token", m.global.accessToken]
    m.readContentTask.control = "RUN"
end sub

sub setcategories()
    content = createObject("roSGNode", "ContentNode")
    
    itemcontent = content.createChild("ContentNode")
    itemcontent.setField("id", "bookmarks")
    itemcontent.setField("title", recode("Закладки"))
    
    itemId = 0
    for each item in m.readContentTask.content.items
        itemcontent = content.createChild("ContentNode")
        itemcontent.setField("id", itemId.ToStr())
        itemcontent.setField("kinoPubId", item.id)
        itemcontent.setField("title", recode(item.title))
        itemId = itemId+1
    end for
   
    m.categoriespanel = m.top.panelSet.createChild("CategoriesListPanel")
    m.categoryinfopanel = m.top.panelSet.createChild("EmptyPanel")
    m.categoryinfopanel.observeField("focusedChild", "categorySelected")
    m.categoriespanel.list.content = content
    m.categoriespanel.list.observeField("itemFocused", "showCategoryInfo")
    m.categoriespanel.setFocus(true)
    
end sub

sub showCategoryInfo()
    print "Category focused"
    
    categorycontent = m.categoriespanel.list.content.getChild(m.categoriespanel.list.itemFocused)
    print categoryContent
    
    m.id = categoryContent.id
    
    if m.id = "bookmarks"
        m.childPanel = createObject("roSGNode", "CategoriesListPanel")
        
    else
        m.childPanel = createObject("roSGNode", "PosterGridPanel")
        m.childPanel.overhangtext = recode(categorycontent.title)
    end if 
end sub

sub categorySelected()
    print "Category selected" 
    if not m.top.panelSet.isGoingBack
        m.top.panelSet.appendChild(m.childPanel)
   
        if m.id <> "bookmarks"
            content = m.categoriespanel.list.content.getChild(m.categoriespanel.list.itemFocused)
            kinoPubId = content.kinoPubId
            m.childPanel.grid.observeField("itemSelected", "runSelectedVideo")
            m.childPanel.gridContentUriParameters = ["access_token", m.global.accessToken, "type", kinoPubId]
            m.childPanel.gridContentBaseUri = "https://api.service-kp.com/v1/items"
            m.childPanel.grid.setFocus(true)
        else
            m.readBookmarksTask = createObject("roSGNode", "ContentReader")
            m.readBookmarksTask.observeField("content", "getBookmarks")
                
            m.readBookmarksTask.baseUrl = "https://api.service-kp.com/v1/bookmarks"
            m.readBookmarksTask.parameters = ["access_token", m.global.accessToken]
            m.readBookmarksTask.control = "RUN"
            m.bookmarkInfoPanel = m.top.panelSet.createChild("EmptyPanel")
            m.bookmarkInfoPanel.observeField("focusedChild", "bookmarkSelected")
            m.childPanel.list.observeField("itemFocused", "showBookmarkInfo")
            m.childPanel.setFocus(true)
            m.bookmarkListPanel = m.childPanel
        end if

    else
        m.categoriespanel.setFocus(true)
    end if
end sub

sub runSelectedVideo()
    print "RunSelectedVideo"
    if m.id = "bookmarks"
        selectedItem = m.bookmarkPanel.grid.content.getChild(m.bookmarkPanel.grid.itemSelected)
    else
        selectedItem = m.childPanel.grid.content.getChild(m.childPanel.grid.itemSelected)
    end if
    m.videoDescriptionPanel = m.top.panelSet.createChild("VideoDescriptionPanel")
    m.videoDescriptionPanel.itemUriParameters = ["access_token", m.global.accessToken]
    m.videoDescriptionPanel.observeField("videoUri", "playVideo")
    
    print selectedItem
    print type(selectedItem.kinoPubId)
    
    itemUrl = "https://api.service-kp.com/v1/items/" + selectedItem.kinoPubId
    m.videoDescriptionPanel.itemUri = itemUrl
end sub

sub playVideo()
    print "Play video"
    m.top.overhang.visible = false
    m.top.panelset.visible = false
    m.video = createObject("roSGNode", "VideoNode")
    m.video.videoUri = m.videoDescriptionPanel.videoUri
    m.video.videoFormat = m.videoDescriptionPanel.videoFormat
    m.top.appendChild(m.video)
    m.video.setFocus(true)
end sub

sub getBookmarks()
    print "GetBookmarks"
    
    content = createObject("roSGNode", "ContentNode")
    
    itemId = 0
    for each item in m.readBookmarksTask.content.items
        itemcontent = content.createChild("ContentNode")
        itemcontent.setField("id", itemId.ToStr())
        itemcontent.addFields({kinoPubId: item.id.ToStr()})
        itemcontent.setField("title", recode(item.title))
        itemId = itemId+1
    end for
    
    m.childPanel.list.content = content
    'm.childPanel.list.observeField(fieldName,functionName)
end sub

sub bookmarkSelected()
    print "Bookmark selected"
    if not m.top.panelSet.isGoingBack
        m.top.panelSet.appendChild(m.bookmarkPanel)
        content = m.childPanel.list.content.getChild(m.categoriespanel.list.itemFocused)
        print content
        kinoPubId = content.kinoPubId
        m.bookmarkPanel.grid.observeField("itemSelected", "runSelectedVideo")
        m.bookmarkPanel.gridContentUriParameters = ["access_token", m.global.accessToken]
        m.bookmarkPanel.gridContentBaseUri = "https://api.service-kp.com/v1/bookmarks/" + kinoPubId.ToStr()
        m.bookmarkPanel.grid.setFocus(true)
    else
        m.bookmarkListPanel.setFocus(true)
    end if
end sub

sub showBookmarkInfo()
    print "Bookmark focused"
    m.bookmarkPanel = createObject("roSGNode", "PosterGridPanel")
end sub

sub recode(str as string) as string
    input = createObject("roByteArray")
    input.FromAsciiString(str)
    for i=0 to input.Count()-1 step 1
        firstByte = input[i]
        if firstByte > 240
            i=i+3
        else if firstByte > 224
            i=i+2
        else if firstByte > 192
            code = ((firstByte and &H1F)<<6) + (input[i+1] and &H3F)
            newCode = -1
            if code > 1039 and code < 1104
                newCode = (code-1040)+192
            else if code = 1031
                newCode = 134
            else if code = 1030
                newCode = 132
            else if code = 1038
                newCode = 128
            else if code = 1025
                newCode = 130
            else if code = 1110
                newCode = 133
            else if code = 1111
                newCode = 135
            else if code = 1105
                newCode = 131
            else if code = 1118
                newCode = 129
            end if
            
            if(newCode <> -1) 
                input[i] = &HC0+ ((newCode >> 6) and &H1F)
                input[i+1] = &H80 + (newCode and &H3F)
            end if
            i=i+1
        end if
    end for
    
    return input.ToAsciiString()
end sub