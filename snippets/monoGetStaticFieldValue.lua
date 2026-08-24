--[[
The function returns the value of a static field via its class name and field name.

Created by palepine.
]]

--- func desc
---@param className string
---@param fieldName string
---@param namespace string
function mono_getStaticField(className, fieldName, namespace)
  if className == nil or className == '' then error('class name invalid') end

  if fieldName == nil or fieldName == '' then error('field name invalid') end

  namespace = namespace or ''

  local classID = mono_findClass(namespace, className)
  if classID == nil or classID == 0 then error('class not found') end

  -- true = include parent fields
  local fields = mono_class_enumFields(classID, true)
  if fields == nil then error('could not enumerate class fields') end

  local field = nil

  for i = 1, #fields do
    local f = fields[i]

    if f.name == fieldName or f.altname == fieldName then
      field = f
      break
    end
  end

  if field == nil then error('field not found') end

  if not field.isStatic then error('field is not static') end

  return mono_class_getStaticFieldValue(classID, field.field)
end
