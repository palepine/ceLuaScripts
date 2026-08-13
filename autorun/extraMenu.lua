

-- -- -- GLOBALS -- -- -- 
  local mainMenu = getMainForm().Menu
  local extraMenuItem = nil
  local addressList = getAddressList()

-- -- -- CALLBACK HELPERS -- -- -- 

  local function OpenMemViewer()
    getMainForm().btnMemoryView.doClick()
  end

  local function OpenAAssembler()
    getMemoryViewForm().ComponentByName["AutoInject1"].doClick()
  end

  local function OpenAddManualAddress()
    getMainForm().btnAddAddressManually.doClick()
  end

  local function OpenLuaEngine()
    getMemoryViewForm().miLuaEngine.doClick()
  end

  local function getProcName()
    writeToClipboard(process)
  end

  local function openASMScan(sender)
    getMemoryViewForm().ComponentByName["Assemblycode1"].doClick()
  end

-- -- -- EXTRA MENU HELPERS -- -- -- 
  --- creates and adds button to parent with callback on click
  ---@param ownerParent userdata
  ---@param captionName string
  ---@param customCallback function
  local function addCustomMenuItemTo(ownerParent, captionName, customCallback)
    local newMenuItem = createMenuItem(ownerParent)
    newMenuItem.Caption = captionName
    ownerParent.add(newMenuItem)
    newMenuItem.OnClick = customCallback
    return newMenuItem
  end

  --- adds a (collapsed) menu item to the parent
  ---@param ownerParent userdata
  ---@param captionName string
  ---@param menuItemName string
  local function addCollapsedMenuItemTo(ownerParent, captionName, menuItemName)
    local newMenuItem = createMenuItem(ownerParent)
    newMenuItem.Caption = captionName
    newMenuItem.setName(menuItemName)
    ownerParent.add(newMenuItem)
    return newMenuItem
  end

  --- adds a separator line item to the parent
  ---@param ownerParent userdata
  local function addSeparatorItemTo(ownerParent)
    local newMenuItem = createMenuItem(ownerParent)
    newMenuItem.Caption = "-"
    ownerParent.add(newMenuItem)
    return newMenuItem
  end

-- -- -- EXTRA MENU INIT -- -- -- 
  local extraMenuItemCaption = 'Extra'
  local extraMenuItemName = 'miExtras' -- for recovery
  
  local templateCollapsedCaption = "Templates"
  local templateCollapsedName = "miMenuTemplates"


  local function getExtraMenuItem()
    if mainMenu then
      return mainMenu.ComponentByName[extraMenuItemName] or nil
    end
  end
  
  local function createExtraMenuItem()
    local existing = getExtraMenuItem()

    if existing then
      extraMenuItem = existing
      return existing
    end

    extraMenuItem = createMenuItem(mainMenu)
    extraMenuItem.Caption = extraMenuItemCaption
    extraMenuItem.setName(extraMenuItemName)
    mainMenu.getItems().add(extraMenuItem)
  end

  createExtraMenuItem()

-- -- -- EXTRA MENU ITEMS -- -- -- 
  addCustomMenuItemTo(extraMenuItem, 'MemView', OpenMemViewer)
  addCustomMenuItemTo(extraMenuItem, 'Auto Assembler', OpenAAssembler)
  addCustomMenuItemTo(extraMenuItem, 'Add Address', OpenAddManualAddress)
  addCustomMenuItemTo(extraMenuItem, 'Dissect', createStructureForm)
  addCustomMenuItemTo(extraMenuItem, 'Lua Engine', OpenLuaEngine)
  addCustomMenuItemTo(extraMenuItem, 'Get Proc Name', getProcName)
  addCustomMenuItemTo(extraMenuItem, 'ASM Scan', openASMScan)

-- Just add the collapsed items under created items
--  addSeparatorItemTo(extraMenuItem)
--  -- Template Menu
--  local templateMenuItem = addCollapsedMenuItemTo(extraMenuItem, templateCollapsedCaption, templateCollapsedName)
--    addCustomMenuItemTo(templateMenuItem, 'Some Menu Item', function() print('big news') end )
