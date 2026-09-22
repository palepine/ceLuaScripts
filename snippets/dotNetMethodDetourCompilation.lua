// AutoAssemble script for detouring Unity methods
// credit to DarkByte, just made it easier to follow
// todo: clean duplicate assmeblies

{$lua}
if syntaxcheck then return end
local className = 'ChangeToClass'
local methodDetour = 'changeToMethodToDetour'
local detourName = className .. '.' .. methodDetour
local csharpscript = [[

]]

local function tryDisassembleDetour(detourName)
  local detourInfo = dotnetdetours[detourName]
  if detourInfo and detourInfo.processid == getOpenedProcessID() then
    local result, err = autoAssemble( detourInfo.disablescript, detourInfo.disableinfo )
    if not result then error(err) end
    dotnetdetours[detourName] = nil
  end
end

local function tryCompileDetour(csharpScript)
  local detourinfo = {}
  local assemblyRefs, sysfile = dotnetpatch_getAllReferences() -- get assembly paths

  local csfile, err = compileCS( csharpScript, assemblyRefs, sysfile )
  if not csfile then
    -- sometimes having sysfile fails, try without
    csfile, err = compileCS( csharpScript, assemblyRefs )
    if not csfile then
      if not err then err = ' (?Unknown error?)' end
      messageDialog( 'Compilation error:' .. err, mtError, mbOK )
      error(err)
    end
  end
  -- new assembly created, now inject and hook
  local oldMethodName = className..'::'..methodDetour -- Class::Method
  local newMethodName = 'patched'..className..'::'..'new'..methodDetour -- patchedClass::newMethod
  local oldMethodCaller = 'patched'..className..'::'..'old'..methodDetour -- "patchedClass::oldMethod"
  
  local result, disableinfo, disablescript = InjectDotNetDetour( csfile, oldMethodName, newMethodName, oldMethodCaller )
  if result then
    detourinfo.disableinfo = disableinfo
    detourinfo.disablescript = disablescript
    detourinfo.processid = getOpenedProcessID()
    dotnetdetours[detourName] = detourinfo
  else   
    if disableinfo == nil then disableinfo = 'no reason' end  
    error( 'InjectDotNetDetour failed: '..disableinfo)  
  end

end
if dotnetdetours == nil then dotnetdetours = {} end
[ENABLE]

-- first disasm the detour if we know one
tryDisassembleDetour( detourName )
tryCompileDetour( csharpscript )

[DISABLE]
tryDisassembleDetour( detourName )
