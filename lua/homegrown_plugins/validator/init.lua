--- @generic T
--- @param val T | nil
--- @param default_val T
--- @return T
local function default(val, default_val)
  if val == nil then
    return default_val
  end
  return val
end

--- @alias CustomValidator function
--- @alias Type "nil" | "number" | "string" | "boolean" | "function" | "table" | CustomValidator

--- @class BaseSchema
--- @field type Type
--- @field optional? boolean

--- @alias PrimitiveSchema BaseSchema

--- @class TableSchema : BaseSchema
--- @field entries? Type | Schema[]

--- @alias Schema PrimitiveSchema | TableSchema

local type_validator = function(val)
  return vim.tbl_contains({ "nil", "number", "string", "boolean", "function", "table", }, val) or type(val) == "function"
end

--- @param schema Schema
local function validate(schema, val)
  -- --- @type Schema
  -- local schema_schema = {
  --   type = "table",
  --   entries = {
  --     type = { type = type_validator, },
  --     optional = { type = "boolean", optional = true, },
  --     entries = {
  --       type = function(val)
  --         --- @type Schema
  --         local str_entries_schema = { type = type_validator, }
  --
  --         --- @type Schema
  --         local table_entries_schema = { type = "table", entries = {}, }
  --
  --         return validate(str_entries_schema, val) or validate(table_entries_schema, val)
  --       end,
  --     },
  --   },
  -- }
  --
  -- if not validate(schema_schema, schema) then return false end

  local optional = default(schema.optional, false)
  if val == nil and optional then return true end

  if type(schema.type) == "string" then
    if schema.type == "table" then
      if type(val) ~= "table" then return false end

      if type(schema.entries) == "string" then
        for _, curr_val in pairs(val) do
          if not validate({ type = schema.entries, }, curr_val) then
            return false
          end
        end
        return true
      else
        -- TODO: can I skip a loop?
        for key, entry in pairs(schema.entries) do
          if val[key] == nil then return false end

          if not validate(entry, val[key]) then
            return false
          end
        end

        for key, curr_val in pairs(val) do
          if schema.entries[key] == nil then return false end

          if not validate(schema.entries[key], curr_val) then
            return false
          end
        end

        return true
      end
    end

    if type(val) == schema.type then return true end

    return false
  elseif type(schema.type) == "function" then
    return schema.type(val)
  end
end

print(
  validate(
    {
      type = "table",
      entries = {
        {
          type = "table",
          entries = "number",
        },
        {
          type = function(val)
            return validate({ type = "boolean", }, val) or validate({ type = "number", }, val)
          end,
        },
        {
          type = "boolean",
          optional = true,
        },
        {
          type = "string",
        },
      },
    },
    {
      { 1, 2, 3, },
      1,
      true,
      "hello",
    }
  )
)
