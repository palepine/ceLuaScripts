--[[
The script attaches to the given process name continuously.
]]
if syntaxcheck then return end

local ceVer = 7.7
local processName = 'procName' -- eg Firefox.exe/Firefox/Fire
local author = "vesperpallens"
local notAttached = "Process not attached. Table by " .. author
local attached = "Table loaded. By" .. author .. " | " .. (process or "")

if getCEVersion() < ceVer then ShowMessage('Update CE to ' .. ceVer) end


TIMOpenProc = createTimer()
TIMOpenProc.setInterval(2000)
TIMOpenProc.OnTimer = function()
  if not getProcessIDFromProcessName( processName ) then
    getMainForm().caption = notAttached
    return
  end

  if openProcess( processName ) then
    TIMOpenProc.setEnabled(false)
    if TIMAttachWatchdog then
      TIMAttachWatchdog.setEnabled(true)
    end
    getMainForm().caption = attached
  else
    getMainForm().caption = notAttached
  end
end

TIMAttachWatchdog = createTimer( nil, false ) -- create disabled
TIMAttachWatchdog.setInterval(2000)
TIMAttachWatchdog.OnTimer = function()
  if not readInteger( process ) then
    TIMOpenProc.setEnabled(true)
    TIMAttachWatchdog.setEnabled(false)
    getMainForm().caption = notAttached
  end
end