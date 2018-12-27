sub init()
    m.top.functionName = "getcontent"
    m.top.appended = false
end sub

sub getcontent()
    print "in ContentReader getContent"
    print "m.top.baseUrl is " m.top.baseUrl
  
    url = createObject("roString")
    url.AppendString(m.top.baseUrl, m.top.baseUrl.len())
    if m.top.parameters.Count() > 0
        url.AppendString("?", 1)
        tempStr = createObject("roString")
        for i=0 to m.top.parameters.Count()-1 step 2
            if i>0
                url.AppendString("&", 1)
            end if
            
            key = m.top.parameters[i]
            value = m.top.parameters[i+1]
           
            url.AppendString(key, key.Len())
            url.AppendString("=", 1)
            url.AppendString(value, value.Len())
        end for
    end if
    
#if development
    print "ContentReader: DevMode: getContent: " + url
    if url.Instr("https://api.service-kp.com/v1/types?") >= 0
        urlContent = ReadAsciiFile("pkg:/devcontent/types.json")
    else if url.Instr("https://api.service-kp.com/v1/bookmarks/174340?") >= 0
        urlContent = ReadAsciiFile("pkg:/devcontent/Bookmark.txt")
    else if url.Instr("https://api.service-kp.com/v1/bookmarks?") >= 0
        urlContent = ReadAsciiFile("pkg:/devcontent/Bookmarks.txt")
    else if url.Instr("https://api.service-kp.com/v1/items/42916") >= 0
        urlContent = ReadAsciiFile("pkg:/devcontent/Item.txt")
    else if url.Instr("https://api.service-kp.com/v1/items") >= 0
        urlContent = ReadAsciiFile("pkg:/devcontent/Items.txt")
    end if
    print urlContent
#else
    print "ContentReader: RealMode: getContent: " + url
    readInternet = createObject("roUrlTransfer")
    readInternet.setUrl(url)
    readInternet.SetCertificatesFile("common:/certs/ca-bundle.crt")
    readInternet.setRequest("GET")
    urlContent = readInternet.GetToString()
    print urlContent
#end if
  
  json = parseJSON(urlContent)
  
  m.top.content = json
end sub