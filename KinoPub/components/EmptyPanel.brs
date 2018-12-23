sub init()
      m.top.panelSize = "medium"
      m.top.focusable = true
      m.top.hasNextPanel = true

      m.infolabel = m.top.findNode("infoLabel")
    end sub

    sub showdescription()
      m.infolabel.text = m.top.description
    end sub