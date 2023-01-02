local types, BaseType, FailedTransform
do
  local _obj_0 = require("tableshape")
  types, BaseType, FailedTransform = _obj_0.types, _obj_0.BaseType, _obj_0.FailedTransform
end
local instance_of
instance_of = require("tableshape.moonscript").instance_of
local yield_error
yield_error = require("lapis.application").yield_error
local indent
indent = function(str)
  local rows
  do
    local _accum_0 = { }
    local _len_0 = 1
    for s in str:gmatch("[^\n]+") do
      _accum_0[_len_0] = s
      _len_0 = _len_0 + 1
    end
    rows = _accum_0
  end
  return table.concat((function()
    local _accum_0 = { }
    local _len_0 = 1
    for idx, r in ipairs(rows) do
      _accum_0[_len_0] = idx > 1 and "  " .. tostring(r) or r
      _len_0 = _len_0 + 1
    end
    return _accum_0
  end)(), "\n")
end
local AssertErrorType
do
  local _class_0
  local _parent_0 = types.assert
  local _base_0 = {
    assert = function(first, msg, ...)
      if not (first) then
        if type(msg) == "table" then
          coroutine.yield("error", msg)
        else
          yield_error(msg or "unknown error")
        end
        assert(first, msg, ...)
      end
      return first, msg, ...
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, ...)
      return _class_0.__parent.__init(self, ...)
    end,
    __base = _base_0,
    __name = "AssertErrorType",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  AssertErrorType = _class_0
end
local ValidateParamsType
do
  local _class_0
  local test_input_type, is_base_type, validate_type, param_validator_spec
  local _parent_0 = BaseType
  local _base_0 = {
    assert_errors = function(self)
      return AssertErrorType(self)
    end,
    _transform = function(self, value, state)
      local pass, err = test_input_type(value)
      if not (pass) then
        return FailedTransform, {
          err
        }
      end
      local out = { }
      local errors, state
      local _list_0 = self.params_spec
      for _index_0 = 1, #_list_0 do
        local validation = _list_0[_index_0]
        local result, state_or_err = validation.type:_transform(value[validation.field], state)
        if result == FailedTransform then
          if not (errors) then
            errors = { }
          end
          if validation.error then
            table.insert(errors, validation.error)
          else
            local error_prefix = tostring(validation.label or validation.field) .. ": "
            if type(state_or_err) == "table" then
              for _index_1 = 1, #state_or_err do
                local e = state_or_err[_index_1]
                table.insert(errors, error_prefix .. e)
              end
            else
              table.insert(errors, error_prefix .. state_or_err)
            end
          end
        else
          state = state_or_err
          out[validation.as or validation.field] = result
        end
      end
      if errors then
        return FailedTransform, errors
      end
      return out, state
    end,
    _describe = function(self)
      local rows
      do
        local _accum_0 = { }
        local _len_0 = 1
        local _list_0 = self.params_spec
        for _index_0 = 1, #_list_0 do
          local thing = _list_0[_index_0]
          _accum_0[_len_0] = tostring(thing.field) .. ": " .. tostring(indent(tostring(thing.type)))
          _len_0 = _len_0 + 1
        end
        rows = _accum_0
      end
      if #rows == 1 then
        return "params type {" .. tostring(rows[1]) .. "}"
      else
        return "params type {\n  " .. tostring(table.concat(rows, "\n  ")) .. "\n}"
      end
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, params_spec)
      do
        local _accum_0 = { }
        local _len_0 = 1
        for idx, validator in pairs(params_spec) do
          local t, err = param_validator_spec(validator)
          if not (t) then
            error(tostring(err) .. " (index: " .. tostring(idx) .. ")")
          end
          local _value_0 = t
          _accum_0[_len_0] = _value_0
          _len_0 = _len_0 + 1
        end
        self.params_spec = _accum_0
      end
    end,
    __base = _base_0,
    __name = "ValidateParamsType",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  local self = _class_0
  test_input_type = types.annotate(types.table, {
    format_error = function(self, val, err)
      return "params: " .. tostring(err)
    end
  })
  is_base_type = instance_of(BaseType)
  validate_type = types.one_of({
    is_base_type
  })
  param_validator_spec = types.annotate(types.shape({
    types.string:tag("field"),
    validate_type:describe("tableshape type"):tag("type"),
    error = types["nil"] + types.string:tag("error"),
    label = types["nil"] + types.string:tag("label"),
    as = types["nil"] + types.string:tag("as")
  }), {
    format_error = function(self, val, err)
      return "validate_params: Invalid validation specification object: " .. tostring(err)
    end
  })
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  ValidateParamsType = _class_0
end
local printable_character, trim
do
  local _obj_0 = require("lapis.util.utf8")
  printable_character, trim = _obj_0.printable_character, _obj_0.trim
end
local valid_text = (types.string * types.custom((function()
  local _base_0 = (printable_character ^ 0 * -1)
  local _fn_0 = _base_0.match
  return function(...)
    return _fn_0(_base_0, ...)
  end
end)())):describe("valid text")
local trimmed_text = valid_text / (function()
  local _base_0 = trim
  local _fn_0 = _base_0.match
  return function(...)
    return _fn_0(_base_0, ...)
  end
end)() * types.custom(function(v)
  return v ~= "", "expected text"
end):describe("text")
local limited_text
limited_text = function(max_len, min_len)
  if min_len == nil then
    min_len = 1
  end
  local out = trimmed_text * types.string:length(min_len, max_len)
  return out:describe("text between " .. tostring(min_len) .. " and " .. tostring(max_len) .. " characters")
end
return {
  validate_params = ValidateParamsType,
  assert_error = AssertErrorType,
  valid_text = valid_text,
  trimmed_text = trimmed_text
}
