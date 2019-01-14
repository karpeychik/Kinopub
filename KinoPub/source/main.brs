' ********** Copyright 2016 Roku Corp.  All Rights Reserved. ********** 

sub Main()
    showChannelSGScreen()
end sub

sub showChannelSGScreen()
    screen = CreateObject("roSGScreen")
    m.port = CreateObject("roMessagePort")
    
    m.global = screen.getGlobalNode()  
    m.global.id = "GlobalNode"
    
    m.global.addFields({clientId: "xbmc", clientSecret: "cgg3gtifu46urtfp2zp1nqtba0k2ezxh"})
    
    screen.setMessagePort(m.port)
    scene = screen.CreateScene("MenuScene")
    screen.show()

    while(true)
        msg = wait(0, m.port)
        msgType = type(msg)
        if msgType = "roSGScreenEvent"
            if msg.isScreenClosed() then return
        end if
    end while
end sub
