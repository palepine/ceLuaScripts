--[[
Registers a mono class' fields as symbols to the CE symbol list.
  Then you may create more consistent tables with SomeClass.someField instead of absolute offsets

created by palepine
]]

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