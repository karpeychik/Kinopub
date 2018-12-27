sub init()
    print "Initializing poster"
    m.top.panelSize = "full"
    m.top.isFullScreen = true
    m.top.leftPosition = 130
    m.top.focusable = true
    m.top.hasNextPanel = false
    m.top.createNextPanelOnItemFocus = false
    m.top.grid = m.top.findNode("posterGrid")
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
    print "showPosterGrid"
    
    content = createObject("roSGNode", "ContentNode")
    for each item in m.readPosterGridTask.content.items
        itemcontent = createObject("roSGNode", "ContentNode")
        itemcontent.setField("shortdescriptionline1", recode(item.title))
        itemcontent.setField("hdgridposterurl", item.posters.small)
        itemcontent.setField("id", item.id)
        itemcontent.addFields({kinoPubId: item.id.ToStr()})
        content.appendChild(itemContent)
    end for
    
    m.top.grid.visible = true
    m.top.grid.content = content
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