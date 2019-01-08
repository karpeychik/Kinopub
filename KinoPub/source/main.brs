' ********** Copyright 2016 Roku Corp.  All Rights Reserved. ********** 

sub Main()
    showChannelSGScreen()
end sub

sub showChannelSGScreen()
    screen = CreateObject("roSGScreen")
    m.port = CreateObject("roMessagePort")
    m.global = screen.getGlobalNode()  
    m.global.id = "GlobalNode"
    m.global.addFields({accessToken: "5hbe46uyfpgfu5g3mim397ghr2q3yyjp" })
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
