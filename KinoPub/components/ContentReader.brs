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
    
  'content = createObject("roSGNode", "ContentNode")

  'contentxml = createObject("roXMLElement")

  ' uncomment/conditionalize for development package XML transfers (pkg:/server/foo.xml)
  ' xmlstring = ReadAsciiFile(m.top.contenturi)
  ' contentxml.parse(xmlstring)

  ' uncomment/conditionalize for published channel Internet XML transfers (http://serverdomain/foo.xml)
#if development
    print "ContentReader: DevMode: getContent: " + url
    urlContent = ReadAsciiFile("pkg:/devcontent/types.json")
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