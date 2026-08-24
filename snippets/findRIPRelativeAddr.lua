--[[
A simple script to resolve the absolute address of an ASM instruction

created by palepine
]]

--- x64 RIP relative address resolution
---@param aobSignature string
---@param offsetToValue number
---@param offsetToNextInstr number
---@return number @ resolved address
function findRIPRelativeAddress( aobSignature, offsetToValue, offsetToNextInstr )
  assert( type(aobSignature) == 'string', 'signature must be a string')
  local function resolveAddress(instrAddr, offsetToValue, offsetToNextInstr)
    local relAddr = readInteger( instrAddr + offsetToValue )
    local nextAddr = getAddress( instrAddr + offsetToNextInstr )
    return nextAddr + relAddr
  end
  
  local addr = AOBScanModuleUnique( process, aobSignature, '+X-W-C' )
  if addr == 0 or addr == nil then
    error('AOB signature - 0 hits')
  end
  
  offsetToNextInstr = offsetToNextInstr or getInstructionSize(addr)
  offsetToValue = offsetToValue or ( getInstructionSize( addr ) - 4 ) -- TODO: count to wildcards?
  
  return resolveAddress( addr, offsetToValue, offsetToNextInstr )
end