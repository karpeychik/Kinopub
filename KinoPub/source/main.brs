sub Main()
    showChannelSGScreen()
end sub

sub showChannelSGScreen()
    screen = CreateObject("roSGScreen")
    port = CreateObject("roMessagePort")
    
    m.global = screen.getGlobalNode()  
    m.global.id = "GlobalNode"
    
    m.global.addFields({clientId: "xbmc", clientSecret: "cgg3gtifu46urtfp2zp1nqtba0k2ezxh"})
    
    screen.setMessagePort(m.port)
    scene = screen.CreateScene("MenuScene")
    screen.show()
    scene.setFocus(true)

    while true
        msg = wait(0, port)
        msgType = type(msg)
        if msgType = "roSGScreenEvent"
            if msg.isScreenClosed() return
        end if
    end while
end sub
