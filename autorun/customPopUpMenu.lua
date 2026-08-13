--[[
  created by palepine
  credit to YoucefHam for the original idea and scripts I optimized and enhanced

]]

--[[ To add a new command entry to the popup menu, use 

  addCommand
  {
    caption = "", -- caption of the item
    onClick = function() end, -- on click callback
    imageIndex = 1, -- red arrow -- index of an icon if you want to set any
    placeAfter = MainForm.Cut1.MenuIndex, -- where to place (insert) in the menu

    visible = function(context) -- callback returning a bool to define if the item would be displayed or not, takes a context table with characteristics
      return context.hasSelection and context.anyRecordHasOffsets
    end
  }

  -- Context is built in the POPUP OVERRIDE, feel free to add more context, e.g. this extends the context with a getCaption callback to edit the menuItem caption when activating
  if isVisible and command.getCaption then
    command.popupMenuItem.Caption = command.getCaption(context)
  end
]]

-- -- -- HELPERS -- -- -- 
  local commands = {}

  local popupMenu = AddressList.PopupMenu

  local function addPopUpMenuItem(caption, onClick, placeAfterItem)
    local newMenuItem = createMenuItem(popupMenu)
    newMenuItem.Caption = caption
    newMenuItem.OnClick = onClick

    if placeAfterItem == nil then
      popupMenu.Items.Add(newMenuItem)
    else
      popupMenu.Items.insert(placeAfterItem , newMenuItem)
    end

    return newMenuItem
  end

  local function createPopupCommand(commandContext)
    local popupMenuItem = addPopUpMenuItem(commandContext.caption, commandContext.onClick, commandContext.placeAfter)

    if commandContext.imageIndex then
      popupMenuItem.ImageIndex = commandContext.imageIndex
    end

    commandContext.popupMenuItem = popupMenuItem
    return commandContext
  end

  local function addCommand(commandContext)
    commands[#commands + 1] = createPopupCommand(commandContext)
  end

  local function getSelectedRecord()
    if (AddressList.SelCount or 0) ~= 1 then return nil end

    return AddressList.getSelectedRecord()
  end

  local function getSelectedRecords()
    if (AddressList.SelCount or 0) == 0 then return nil end

    return AddressList.getSelectedRecords()
  end

  local function flattenMemrec(memrec)
    local offsetCount = memrec.getOffsetCount()

    if offsetCount == 0 then
      return memrec.getAddress()
    end

    local address = memrec.getAddress()

    for i = offsetCount - 1, 0, -1 do
      address = "[" .. address .. "]+" .. memrec.OffsetText[i]
    end

    memrec.setOffsetCount(0)
    -- we will use this addres string as a base to be wrapped with []
    memrec.setAddress(address)

    return address
  end

-- -- -- CALLBACKS -- -- -- 

  local function convertMemRecToCollapsableHeader()
    local selectedRecords = getSelectedRecords()
    if selectedRecords == nil then return end;

    for i, memrec in pairs(selectedRecords) do
    -- don't ruin scripts
      if memrec.VarType ~= vtAutoAssembler then
        memrec.IsGroupHeader = true
      end

      if memrec.Count > 0 then
        memrec.Options = '[moHideChildren,moManualExpandCollapse,moAllowManualCollapseAndExpand]'
      else
        memrec.Options = '[moHideChildren,moAllowManualCollapseAndExpand]'
      end
    end

  end

  local function flattenPointer()

    local selectedRecords = getSelectedRecords()
    if selectedRecords == nil then return end

    for _, rec in pairs(selectedRecords) do
      flattenMemrec(rec)
    end
  end

  local function replaceLastOffsetAsSymbol()
    local selectedRecords = getSelectedRecords();
    if selectedRecords == nil then return end;

    local baseSymbol = inputQuery("Struct Symbol", "Symbol", "")
    if baseSymbol == nil or baseSymbol == '' then return end

    for i, memrec in pairs(selectedRecords) do
      if memrec.getOffsetCount() ~= 0 then
        local memrecName = memrec.getDescription() or ''
        local symbolName = memrecName:match("[%w_]+$") or ''

        memrec.OffsetText[0] = ( baseSymbol .. '.' .. symbolName )
      end
    end

  end

  -- create Structure Data
  local function createStructureData()

    local selectedRecords = getSelectedRecords()
    if selectedRecords == nil then return end

    local structure
    local recCount = 0
    for i, memrec in pairs(selectedRecords) do

      if  memrec.CurrentAddress=='' or
          memrec.CurrentAddress==nil or
          memrec.CurrentAddress=='0' or
          memrec.Type == vtAutoAssembler then
            goto continue
      end

      recCount = recCount + 1
      if recCount == 1 then
        structure = createStructureForm( string.format('%X', memrec.CurrentAddress) )
      elseif recCount > 1 then
        structure.addGroup().addColumn().AddressText = string.format('%X', memrec.CurrentAddress)
      end

      ::continue::
    end

    -- structure.Menu.Items[2][0].doClick()
    structure.Definenewstructure1.doClick()

  end

  --Copy Current Address
  local function getMemrecCurrentAddress()
    local memrec = getSelectedRecord()
    if memrec==nil then return end;
    writeToClipboard( string.format('%X',memrec.CurrentAddress) )
  end

  --Create Header Spacer
  local function addHeaderSpacer()
    local header = AddressList.createMemoryRecord()
    header.IsGroupHeader = true
    header.IsAddressGroupHeader = false
    header.noCheckBox = true
    header.Description=''
    -- add the spacer to the selected record
    if AddressList.SelCount > 0 then
      header.appendToEntry(getSelectedRecord())
    end
  end

  local function OpenAddManualAddress()
    getMainForm().btnAddAddressManually.doClick()
  end

-- -- -- POPUP ITEMS -- -- -- 

  addCommand
  {
    caption = "Flatten Pointer",
    onClick = flattenPointer,
    imageIndex = 1, -- red arrow
    placeAfter = MainForm.Cut1.MenuIndex,

    visible = function(context)
      return context.hasSelection and context.anyRecordHasOffsets
    end
  }

  addCommand
  {
    caption = "Create Header From",
    onClick = convertMemRecToCollapsableHeader,
    imageIndex = 11, -- info sign
    placeAfter = MainForm.Cut1.MenuIndex,

    visible = function(context)
      return context.hasSelection
    end
  }

  addCommand
  {
    caption = "Copy Current Address:",
    onClick = getMemrecCurrentAddress,
    imageIndex = MainForm.ComponentByName["Copy1"].ImageIndex,
    placeAfter = MainForm.Cut1.MenuIndex,

    visible = function(context)
      return context.isSignleRecordSelected
    end,

    getCaption = function(context)
      local selectedMemrec = getSelectedRecord()
      return ("Copy Current Address: %X"):format( selectedMemrec.CurrentAddress or 0)
    end
  }

  addCommand
  {
    caption = "New Address",
    onClick = OpenAddManualAddress,
    imageIndex = 8, -- magnifier with a plus
    placeAfter = MainForm.Cut1.MenuIndex,

    visible = function(context) return true end,
  }

  addCommand
  {
    caption = "Create Structure Data",
    onClick = createStructureData,
    imageIndex = MainForm.ComponentByName['miCreateLuaForm'].ImageIndex,
    placeAfter = MainForm.Cut1.MenuIndex,

    visible = function(context) return context.hasSelection end,
  }

  addCommand
  {
    caption = "Add Empty Spacer",
    onClick = addHeaderSpacer,
    imageIndex = MainForm.CreateGroup.ImageIndex,
    placeAfter = MainForm.Cut1.MenuIndex,

    visible = function(context) return true end,
  }

  addCommand
  {
    caption = "Set last offset to sym",
    onClick = replaceLastOffsetAsSymbol,
    imageIndex = 18, -- interrog sign
    placeAfter = MainForm.Cut1.MenuIndex,

    visible = function(context)
      return context.hasSelection and context.anyRecordHasOffsets
    end,
  }

  addCommand
  {
    caption = "-",
    onClick = nil,
    -- imageIndex = 1,
    placeAfter = MainForm.Cut1.MenuIndex,

    visible = function(context) return true end,
  }


-- -- -- POPUP OVERRIDE -- -- -- 

  local oldOnPopup = AddressList.PopupMenu.OnPopup

  AddressList.PopupMenu.OnPopup=function(...)
    if oldOnPopup then
      oldOnPopup(...)
    end

    local selectCount = AddressList.SelCount or 0
    local mainSelectedRec = selectCount > 0 and getSelectedRecord() or nil
    local selectedRecords = selectCount > 0 and getSelectedRecords() or {}

    local anyRecordHasOffsets = false

    for _, rec in pairs(selectedRecords) do
      if rec.getOffsetCount() > 0 then
        anyRecordHasOffsets = true
        break
      end
    end

    local context =
    {
      selectCount = selectCount,
      mainSelectedRec = mainSelectedRec,
      records = selectedRecords,
      hasSelection = selectCount > 0,
      isSignleRecordSelected = selectCount == 1,
      isMultipleRecordSelected = selectCount > 1,
      anyRecordHasOffsets = anyRecordHasOffsets,
    }

    for _, command in ipairs(commands) do
      local isVisible = command.visible == nil or command.visible(context)

      command.popupMenuItem.Visible = isVisible

      if isVisible and command.getCaption then
        command.popupMenuItem.Caption = command.getCaption(context)
      end

    end
  end