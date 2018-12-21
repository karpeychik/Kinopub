sub init()
    m.readContentTask = createObject("roSGNode", "ContentReader")
    m.readContentTask.observeField("content", "setcategories")
        
    parameters = createObject("roArray", 2, false)
    m.readContentTask.baseUrl = "https://api.service-kp.com/v1/types"
    m.readContentTask.parameters = ["access_token", "p3mgxrvtblllxkuzfnw2eg5gknf047uj"]
    m.readContentTask.control = "RUN"
end sub

sub setcategories()
    content = createObject("roSGNode", "ContentNode")
    for each item in m.readContentTask.content.items
        itemcontent = content.createChild("ContentNode")
        itemcontent.setField("id", item.id)
        title = recode(item.title)
        itemcontent.setField("title", title)
    end for
   
    m.categoriespanel = m.top.panelSet.createChild("CategoriesListPanel")
    m.categoriespanel.list.content = content
    
    #if false
    print m.readContentTask.content.items[1].title
    byteArray = createObject("roByteArray")
    byteArray.FromAsciiString(m.readContentTask.content.items[1].title)
    print byteArray.Count()
    for i=0 to byteArray.Count()-1 step 1
        print byteArray[i]
    end for
    print ""
    for i=0 to byteArray.Count()-1 step 2
        print i
        print byteArray[i]
        print byteArray[i+1]
        firstByte=byteArray[i]
        code = ((firstByte and &H1F)<<6) + (byteArray[i+1] and &H3F)
        newCode = (code-1040)+192
        print code
        print newCode
        secondByte = &H80 + (newCode and &H3F)  
        firstByte = &HC0+ ((newCode >> 6) and &H1F) 
        byteArray[i] = firstByte
        byteArray[i+1]=secondByte
        print firstByte
        print secondByte
        print i
        print ""
    end for
    
    str = byteArray.ToAsciiString()
    print str
    print str.len()
    
    
    itemcontent = content.createChild("ContentNode")
    itemcontent.setField("id", "1")
    itemcontent.setField("title", str)
    m.categoriespanel = m.top.panelSet.createChild("CategoriesListPanel")
    m.categoriespanel.list.content = content
    #end if
    
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
                print "Replacing " + code.ToStr() + " into " + newCode.ToStr() 
                input[i] = &HC0+ ((newCode >> 6) and &H1F)
                input[i+1] = &H80 + (newCode and &H3F)
                
                print "First " + input[i].ToStr() + " second " + input[i+1].ToStr()
            end if
            i=i+1
        end if
    end for
    
    return input.ToAsciiString()
end sub