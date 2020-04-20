sub init()
    m.top.functionName = "getcontent"
    m.top.requestType = "GET"
    m.top.refreshAuth = true
    m.top.timeout = 30000
    m.top.authFailure = false
end sub

sub getcontent()
    currentTime = createObject("roDateTime")
    currentSeconds = currentTime.AsSeconds()
    print "Auth mode:" m.top.refreshAuth
    if m.top.refreshAuth and m.global.doesExist("tokenExpiration") and currentSeconds + 3600 > m.global.tokenExpiration
        print "Token is about to expire, need to refresh"
        renewToken()
    end if
    
    if false = m.top.authFailure
        fetchUrl()
    else
        print "Skip fetch because of auth failure"
    end if
end sub

sub fetchUrl()
    print "ContentReader:getContent"
    print "m.top.baseUrl is " m.top.baseUrl
    url = buildUrl(m.top.baseUrl, m.top.parameters)
    
#if development
    print "ContentReader: DevMode: getContent: " + url
    if url.Instr("https://api.service-kp.com/v1/types?") >= 0
        data = ReadAsciiFile("pkg:/devcontent/types.json")
        errorCode = 200
    else if url.Instr("https://api.service-kp.com/v1/bookmarks/174340?") >= 0
        data = ReadAsciiFile("pkg:/devcontent/Bookmark.txt")
        errorCode = 200
    else if url.Instr("https://api.service-kp.com/v1/bookmarks?") >= 0
        data = ReadAsciiFile("pkg:/devcontent/Bookmarks.txt")
        errorCode = 200
    else if url.Instr("https://api.service-kp.com/v1/items/42916") >= 0
        data = ReadAsciiFile("pkg:/devcontent/Item.txt")
        errorCode = 200
     else if url.Instr("https://api.service-kp.com/v1/items/8739") >= 0
        data = ReadAsciiFile("pkg:/devcontent/serial.txt")
        errorCode = 200
    else if url.Instr("https://api.service-kp.com/v1/device/notify") >= 0
        data = ReadAsciiFile("pkg:/devcontent/success.txt")
        errorCode = 200
    else if url.Instr("https://api.service-kp.com/v1/items") >= 0
        data = ReadAsciiFile("pkg:/devcontent/Items.txt")
        errorCode = 200
    end if
#else
    print "ContentReader: RealMode: getContent: " + m.top.requestType+": " + url
    
    port=createobject("roMessagePort")
    
    readInternet = createObject("roUrlTransfer")
    readInternet.setUrl(url)
    readInternet.setPort(port)
    readInternet.SetCertificatesFile("common:/certs/ca-bundle.crt")
    'readInternet.setRequest(m.top.requestType)
    
    if m.top.requestType = "GET"
        createRequest = readInternet.AsyncGetToString()
    else if m.top.requestType = "POST"
        createRequest = readInternet.AsyncPostFromString("")
    end if
    
    if createRequest
        timer=createobject("roTimeSpan")
        timer.mark()
        
        while true
            msg=wait(100,port) '100 millisecond pause
            if type(msg)="roUrlEvent"
                errorCode = msg.getresponsecode() 
                if errorCode = 200
                    data=msg.getstring()
                end if
                
                exit while
            end if
            
            'Check if we have hit the timeout
            if timer.totalmilliseconds() > m.top.timeout then
                print "ContentReader:timeout exceeded"
                readInternet.AsyncCancel()
                errorCode = -2
                exit while
            end if
        end while
    else
        errorCode = -1
    end if
    
    'urlContent = readInternet.GetToString()
#end if
    
    print "ContentReader:errorCode:" + errorCode.ToStr()
    if errorCode = 401
        print "Got 401 back - auth"
        m.top.authFailure = true
    else if errorCode <> 200
        m.top.error = errorCode.ToStr()
    else
        json = parseJSON(data)
        m.top.content = json
    end if
    
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
    
    if urlContent = ""
        print "Renew response is empty"
        m.top.authFailure = true
    else
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
            m.top.authFailure = true
        end if
    end if
end sub