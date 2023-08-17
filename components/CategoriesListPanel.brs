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

sub addCategory(content as object, id as string, kinoPubId as string, title as string)
    itemContent = content.createChild("ContentNode")
    itemContent.setField("id", id)
    itemContent.addFields({ kinoPubId: kinoPubId})
    itemContent.setField("title", recode(title))
end sub

sub setCategories()
    items = m.readContentTask.content.items

    ' If there is only one item in the category, open it right away
    if items.Count() = 1
        item = items[0]
        m.preparedPanel = createObject("roSGNode", "PosterGridPanel")
        m.preparedPanel.previousPanel = m.top.previousPanel
        m.currentCategory = item.id.ToStr()
        openSubMenu()
        return
    end if

    content = createObject("roSGNode", "ContentNode")
    if m.top.pType <> "bookmarks"
        addCategory(content, "bookmarks", "bookmarks", "Закладки")
    end if
    itemId = 0
    for each item in items
        addCategory(content, itemId.ToStr(), item.id.ToStr(), item.title)
        itemId = itemId + 1
    end for

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
            openSubMenu()
        else
            m.emptyPanel.setFocus(false)
            m.top.list.setFocus(true)
        end if
    end if
end sub

sub openSubMenu()
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
end sub
