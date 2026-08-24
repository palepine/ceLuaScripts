--[[
The function invokes a class method via its class name and method name.
  If the method is static, passing ptrSymbolName isn't required.
  Otherwise it has to be a registered symbol string associated with a pointer storing the object address.

Created by palepine.
]]

--- func desc
---@param className string @ 'SomeClass'
---@param methodName string @ 'SomeMethod'
---@param ptrSymbolName string @ 'PointerSymbol'
---@param args table @ { 1, 999 } -- true, 999
---@param domainName string @ 'Some.Namespace'
---@return any @ whatever the method returns
function mono_invokeMethodFromClass( className, methodName, ptrSymbolName, args, domainName )
  if className == nil or className == '' then error('class name invalid') end
  if methodName == nil or methodName == '' then error('method name invalid') end

  args = args or {}
  local domainName = domainName or ''

  local classID = mono_findClass( domainName, className )
  if classID == 0 or classID == nil then error('class not found') end

  local methodID = mono_class_findMethod( classID, methodName )
  if methodID == 0 or methodID == nil then error('method not found') return end

  local flags = mono_method_getFlags(methodID) or 0
  -- defined by CE
  local isStatic = ( flags & METHOD_ATTRIBUTE_STATIC ) == METHOD_ATTRIBUTE_STATIC

  local addr = 0
  if not isStatic then
    if ptrSymbolName == nil or ptrSymbolName == '' then
      error('instance address required for non-static method')
    end
    addr = readPointer(ptrSymbolName)
    if addr == 0 or addr == nil then showMessage('Address not found/resolved!') error('address not found') end
  end

  local params = mono_method_get_parameters(methodID)
  if #args ~= #params.parameters then
    error(
      ( 'expected number of args: %d, got: %d' ):format( (#args or 0) , (#params.parameters or 0) )
    )
  end

  local args_t = {}
  for i=1, #params.parameters do
    args_t[i] = {}
    args_t[i].type = monoTypeToVartypeLookup[ params.parameters[i].type ]
    args_t[i].value = args[i]
  end

  return mono_invoke_method(domainName, methodID, addr, args_t)
end