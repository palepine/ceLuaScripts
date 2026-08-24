--[[
The script attaches to the given process names upon activation
]]

if syntaxcheck then return end

local procNameArr =
{
'Firefox.exe',
'Firefox',
}

local function iterateToOpenProc()
  for _, name in ipairs(procNameArr) do
    if openProcess( name ) then
      return true
    end
  end
  return false
end

if not iterateToOpenProc() then
  ShowMessage( 'Failed to attach. App isnt run? Process names tried: ' .. (table.concat( procNameArr , ', ' ) or "") )
  error( 'Cant attach. App isnt run or name mismatch.' )
end


