--[[
  created by ??
  modified by palepine for Cheat Engine
]]

local function toggleFullView(sender, force)

  local state = not( sender.Caption == 'Compact View' )

  if force ~= nil then
    state = not force
  end

  sender.Caption = state and 'Compact View' or 'Full View'

  -- addrlist and scan splitter
  getMainForm().Splitter1.Visible = state;
  -- advanced options/comments
  getMainForm().Panel4.Visible = state
  -- full scan view
  getMainForm().Panel5.Visible = state
end

local function addCompactMenu()
  if compactMenuItemCreated then return end

  local parent = getMainForm().Menu.Items
  
  local compactMenuItem = createMenuItem(parent)
  parent.add(compactMenuItem)
  
  compactMenuItem.Caption = 'Full View'
  compactMenuItem.OnClick = toggleFullView
  compactMenuItemCreated = true

  toggleFullView( compactMenuItem, true ) -- activate by def
end

addCompactMenu()