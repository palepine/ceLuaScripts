--[[
Builds Auto Assemble structures for the passed class names.
  Usage: pass "someClassOne", "someClassTwo" ...
  You may use namespaces too.

created by palepine
]]

--- returns AutoAssemble struct for the passed class names
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