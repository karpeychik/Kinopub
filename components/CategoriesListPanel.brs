sub init()
    m.top.panelSize = "medium"
    m.top.focusable = true
    m.top.hasNextPanel = true
    m.top.leftOnly = true
    m.top.createNextPanelOnItemFocus = false
    m.top.selectButtonMovesPanelForward = true

    m.top.optionsAvailable = false
    m.top.overhangTitle = "Kino.Pub"
    m.top.list = m.top.findNode("categoriesLabelList")

    m.top.dialog = invalid

    m.currentCategory = ""
    m.top.observeField("start", "start")
end sub

sub start()
    m.readContentTask = createObject("roSGNode", "ContentReader")
    m.readContentTask.observeField("content", "setcategories")
    m.readContentTask.observeField("error", "error")

    if m.top.pType <> "bookmarks"
        m.readContentTask.baseUrl = "https://api.service-kp.com/v1/types"
    else
        m.readContentTask.baseUrl = "https://api.service-kp.com/v1/bookmarks"
    end if

    m.readContentTask.parameters = []
    m.readContentTask.control = "RUN"

end sub

sub error()
    print "CategoriesListPanel:error()"
    source = "CategoriesListPanel:"+m.top.pType
    errorMessage = m.global.utilities.callFunc("GetErrorMessage", {errorCode: m.readContentTask.error, source: source})
    print errorMessage
    font  = CreateObject("roSGNode", "Font")
    font.uri = "pkg:/fonts/NotoSans-Regular-w1251-rename.ttf"
    font.size = 24

    m.dialog = createObject("roSGNode", "Dialog")
    m.dialog.title = recode("Ошибка")
    m.dialog.titleFont = font
    m.dialog.message = recode(errorMessage)
    m.dialog.messageFont = font
    m.top.dialog = m.dialog
end sub

sub setCategories()
    content = createObject("roSGNode", "ContentNode")
    if m.top.pType <> "bookmarks"
        itemContent = content.createChild("ContentNode")
        itemContent.setField("id", "bookmarks")
        itemContent.addFields({ kinoPubId: "bookmarks"})
        itemContent.setField("title", recode("Закладки"))

        itemId = 0
        for each item in m.readContentTask.content.items
            itemContent = content.createChild("ContentNode")
            itemContent.setField("id", itemId.ToStr())
            itemContent.addFields({ kinoPubId: item.id})
            itemContent.setField("title", recode(item.title))
            itemId = itemId+1
        end for

    else
        itemId = 0
        for each item in m.readContentTask.content.items
            itemContent = content.createChild("ContentNode")
            itemContent.setField("id", itemId.ToStr())
            itemContent.addFields({kinoPubId: item.id.ToStr()})
            itemContent.setField("title", recode(item.title))
            itemId = itemId+1
        end for
    end if

    m.top.list.content = content
    m.top.list.observeField("itemFocused", "itemFocused")

    m.emptyPanel = createObject("roSGNode", "EmptyPanel")
    m.emptyPanel.panelSet = m.top.panelSet
    m.emptyPanel.pType = m.top.pType
    m.emptyPanel.observeField("focusedChild", "categorySelected")

    m.top.panelSet.appendChild(m.emptyPanel)

    m.top.setFocus(true)
end sub

sub itemFocused()
    categorycontent = m.top.list.content.getChild(m.top.list.itemFocused)
    selectedCategory = categorycontent.kinoPubId.ToStr()
    if selectedCategory = "bookmarks"
        m.preparedPanel = createObject("roSGNode", "CategoriesListPanel")
        m.preparedPanel.previousPanel = m.top
        m.preparedPanel.panelSet = m.top.panelSet
        m.preparedPanel.pType = "bookmarks"
        m.currentCategory = "bookmarks"
    else
        m.preparedPanel = createObject("roSGNode", "PosterGridPanel")
        m.preparedPanel.previousPanel = m.top
        m.currentCategory = selectedCategory
    end if
end sub

sub categorySelected()
    ' print m.emptyPanel.isInFocusChain()
    ' print m.emptyPanel.hasFocus()
    ' print m.top.panelSet.isGoingBack
    if m.emptyPanel.isInFocusChain()
        if not m.top.panelSet.isGoingBack
            if m.currentCategory <> "bookmarks"
                if m.top.pType <> "bookmarks"
                    m.preparedPanel.gridContentBaseUri = "https://api.service-kp.com/v1/items"
                    m.preparedPanel.gridContentUriParameters = ["type", m.currentCategory]
                    m.preparedPanel.category = m.currentCategory
                else
                    m.preparedPanel.gridContentBaseUri = "https://api.service-kp.com/v1/bookmarks/" + m.currentCategory
                    m.preparedPanel.gridContentUriParameters = []
                    m.preparedPanel.category = ""
                end if
            end if

            m.top.nPanel = m.preparedPanel
        else
            m.emptyPanel.setFocus(false)
            m.top.list.setFocus(true)
        end if
    end if
end sub

function recode(str as string) as string
    return m.global.utilities.callFunc("Encode", {str: str})
end function
