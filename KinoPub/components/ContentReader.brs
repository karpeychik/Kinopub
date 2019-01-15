sub init()
    m.top.functionName = "getcontent"
    m.top.appended = false
    m.top.requestType = "GET"
    m.top.refreshAuth = true
end sub

sub getcontent()
    currentTime = createObject("roDateTime")
    currentSeconds = currentTime.AsSeconds()
    if m.top.refreshAuth and m.global.doesExist("tokenExpiration") and currentSeconds + 3600 > m.global.tokenExpiration
        print "Token is about to expire, need to refresh"
        renewToken()
    end if
    
    fetchUrl()
end sub

sub fetchUrl()
print "in ContentReader getContent"
    print "m.top.baseUrl is " m.top.baseUrl
    url = buildUrl(m.top.baseUrl, m.top.parameters)
    
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
     else if url.Instr("https://api.service-kp.com/v1/items/8739") >= 0
        urlContent = ReadAsciiFile("pkg:/devcontent/serial.txt")
    else if url.Instr("https://api.service-kp.com/v1/device/notify") >= 0
        urlContent = ReadAsciiFile("pkg:/devcontent/success.txt")
    else if url.Instr("https://api.service-kp.com/v1/items") >= 0
        urlContent = ReadAsciiFile("pkg:/devcontent/Items.txt")
    end if
#else
    print "ContentReader: RealMode: getContent: " + m.top.requestType+": " + url
    readInternet = createObject("roUrlTransfer")
    readInternet.setUrl(url)
    readInternet.SetCertificatesFile("common:/certs/ca-bundle.crt")
    readInternet.setRequest(m.top.requestType)
    urlContent = readInternet.GetToString()
#end if
  
  json = parseJSON(urlContent)
  
  m.top.content = json
end sub

function buildUrl(baseUrl as String, parameters as Object) as String
    url = createObject("roString")
    url.AppendString(baseUrl, baseUrl.len())
    foundAuth = false
    if parameters.Count() > 0
        url.AppendString("?", 1)
        tempStr = createObject("roString")
        foundAuth = false
        for i=0 to parameters.Count()-1 step 2
            if i>0
                url.AppendString("&", 1)
            end if
            
            key = parameters[i]
            value = parameters[i+1]
            
            if key = "access_token"
                value = m.global.accessToken
                foundAuth = true
            end if
           
            url.AppendString(key, key.Len())
            url.AppendString("=", 1)
            url.AppendString(value, value.Len())
        end for
    end if
    
    if false = foundAuth and m.top.refreshAuth
        if parameters.Count() > 0
            url.AppendString("&", 1)
        else
            url.AppendString("?", 1)
        end if
        
        appendString = "access_token"
        url.AppendString(appendString, appendString.Len())
        url.AppendString("=", 1)
        url.AppendString(m.global.accessToken, m.global.accessToken.Len())    
    end if
    
    return url
end function

sub renewToken()
    print "ContentReader:renewToken()"
    print "Old auth:"
    print "AuthToken: " + m.global.accessToken
    print "RefreshToken: " + m.global.refreshToken
    print "Expiration:" + m.global.tokenExpiration.ToStr()
    url = buildUrl("https://api.service-kp.com/oauth2/token", ["grant_type", "refresh_token", "refresh_token", m.global.refreshToken, "client_id", m.global.clientId, "client_secret", m.global.clientSecret])
    print "Refresh url: " + url
    readInternet = createObject("roUrlTransfer")
    readInternet.setUrl(url)
    readInternet.SetCertificatesFile("common:/certs/ca-bundle.crt")
    readInternet.setRequest("POST")
    urlContent = readInternet.GetToString()
    json = parseJSON(urlContent)
    
    if json <> invalid    
        m.global.accessToken = json.access_token
        m.global.refreshToken = json.refresh_token
        date = CreateObject("roDateTime")
        m.global.tokenExpiration = date.AsSeconds() + json.expires_in
        sec = createObject("roRegistrySection", "Authentication")
        sec.Write("AuthenticationToken", json.access_token)
        sec.Write("RefreshToken", json.refresh_token)
        sec.Write("TokenExpiration", m.global.tokenExpiration.ToStr())
        sec.Flush()
        
        print "Current auth:"
        print "AuthToken: " + m.global.accessToken
        print "RefreshToken: " + m.global.refreshToken
        print "Expiration:" + m.global.tokenExpiration.ToStr()
    else
        print "Couldn't refresh access token."
        m.top.error = "Couldn't refresh access token."
    end if
end sub