--[[
  created by palepine
]]


--- x64 RIP relative address resolution
---@param aobSignature string
---@param offsetToValue number
---@param offsetToNextInstr number
function findRIPRelativeAddress( aobSignature, offsetToValue, offsetToNextInstr )
  assert( type(aobSignature) == 'string', 'signature must be a string')
  local function resolveAddress(instrAddr, offsetToValue, offsetToNextInstr)
    local relAddr = readInteger( instrAddr + offsetToValue )
    local nextAddr = getAddress( instrAddr + offsetToNextInstr )
    registerSymbol('ptrUW', (nextAddr+relAddr) ,false)
  end
  
  local addr = AOBScanModuleUnique( process, aobSignature, '+X-W-C' )
  if addr == 0 or addr == nil then
    error('AOB signature - 0 hits')
  end
  
  offsetToNextInstr = offsetToNextInstr or getInstructionSize(addr)
  offsetToValue = offsetToValue or ( getInstructionSize( addr ) - 4 )
  
  resolveAddress( addr, offsetToValue, offsetToNextInstr )
end

--- register mono class fields as symbols to be accessible elsewhere (e.g. AddressList offsets for persistent tables)
---@param className string @mono class name
---@param namespace string @optional
function registerMonoClassSymbols( className, namespace )
  className = string.gsub(className, '[%+%-]', '')
  namespace = (namespace and namespace ~= '' and namespace .. '.') or ''
  
  local classFields = mono_class_enumFields( mono_findClass( namespace, className ) )
  
  if not classFields then return end

  namespace = string.gsub( namespace, '[%+%-]', '' )
  
  for _ , field in ipairs( classFields ) do
    -- SomeNamespace.ClassName.field
    registerSymbol( namespace..className..'.'..field.name , field.offset , true )
  end
end


--- returns AutoAssembler struct for the passed class names
function getMonoStructsFor( ... )
  local tableOfNames = table.pack(...)
  assert( type(tableOfNames) == "table", "Pass a valid table of class names." )
  local outStructs = ""

  for i = 1, tableOfNames.n do
 
    local ok, result, err = pcall( monoAA_GETMONOSTRUCT, tableOfNames[i] , false )

    if ok and result then
      outStructs = outStructs .. result .. "\n\n"
    else
      print( err or "" )
    end

  end

  return outStructs

end