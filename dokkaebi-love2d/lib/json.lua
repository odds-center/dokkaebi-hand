--- 최소 JSON 인코더/디코더 (세이브 시스템용)
local json = {}

-- encode
local encode_value

local function encode_string(s)
    s = s:gsub('\\', '\\\\'):gsub('"', '\\"'):gsub('\n', '\\n'):gsub('\r', '\\r'):gsub('\t', '\\t')
    return '"' .. s .. '"'
end

local function encode_table(t, indent, level)
    level = level or 0
    local is_array = #t > 0
    local items = {}
    local nl = indent and "\n" or ""
    local sp = indent and string.rep("  ", level + 1) or ""
    local sp_end = indent and string.rep("  ", level) or ""

    if is_array then
        for _, v in ipairs(t) do
            table.insert(items, sp .. encode_value(v, indent, level + 1))
        end
        return "[" .. nl .. table.concat(items, "," .. nl) .. nl .. sp_end .. "]"
    else
        for k, v in pairs(t) do
            if type(k) == "string" then
                table.insert(items, sp .. encode_string(k) .. ": " .. encode_value(v, indent, level + 1))
            end
        end
        table.sort(items)
        return "{" .. nl .. table.concat(items, "," .. nl) .. nl .. sp_end .. "}"
    end
end

encode_value = function(v, indent, level)
    local vtype = type(v)
    if vtype == "string" then return encode_string(v)
    elseif vtype == "number" then
        if v ~= v then return "null" end -- NaN
        if v == math.huge or v == -math.huge then return "null" end
        if v == math.floor(v) and math.abs(v) < 1e15 then return string.format("%d", v) end
        return string.format("%.6g", v)
    elseif vtype == "boolean" then return v and "true" or "false"
    elseif vtype == "table" then return encode_table(v, indent, level)
    elseif vtype == "nil" then return "null"
    else return '"' .. tostring(v) .. '"'
    end
end

function json.encode(value, pretty)
    return encode_value(value, pretty, 0)
end

-- decode (간단한 재귀 파서)
local decode_value

local function skip_ws(s, i)
    return s:match("^%s*()", i)
end

local function decode_string(s, i)
    i = i + 1 -- skip opening "
    local parts = {}
    while i <= #s do
        local c = s:sub(i, i)
        if c == '"' then return table.concat(parts), i + 1 end
        if c == '\\' then
            i = i + 1
            c = s:sub(i, i)
            if c == 'n' then c = '\n'
            elseif c == 't' then c = '\t'
            elseif c == 'r' then c = '\r'
            elseif c == '"' then c = '"'
            elseif c == '\\' then c = '\\'
            elseif c == '/' then c = '/'
            end
        end
        table.insert(parts, c)
        i = i + 1
    end
    error("JSON: unterminated string")
end

local function decode_number(s, i)
    local j = s:match("^%-?%d+%.?%d*[eE]?[%+%-]?%d*()", i)
    return tonumber(s:sub(i, j - 1)), j
end

local function decode_array(s, i)
    i = i + 1 -- skip [
    local arr = {}
    i = skip_ws(s, i)
    if s:sub(i, i) == ']' then return arr, i + 1 end
    while true do
        local val
        val, i = decode_value(s, i)
        table.insert(arr, val)
        i = skip_ws(s, i)
        local c = s:sub(i, i)
        if c == ']' then return arr, i + 1 end
        if c == ',' then i = skip_ws(s, i + 1) end
    end
end

local function decode_object(s, i)
    i = i + 1 -- skip {
    local obj = {}
    i = skip_ws(s, i)
    if s:sub(i, i) == '}' then return obj, i + 1 end
    while true do
        local key, val
        key, i = decode_string(s, i)
        i = skip_ws(s, i)
        i = i + 1 -- skip :
        i = skip_ws(s, i)
        val, i = decode_value(s, i)
        obj[key] = val
        i = skip_ws(s, i)
        local c = s:sub(i, i)
        if c == '}' then return obj, i + 1 end
        if c == ',' then i = skip_ws(s, i + 1) end
    end
end

decode_value = function(s, i)
    i = skip_ws(s, i)
    local c = s:sub(i, i)
    if c == '"' then return decode_string(s, i)
    elseif c == '{' then return decode_object(s, i)
    elseif c == '[' then return decode_array(s, i)
    elseif c == 't' then return true, i + 4
    elseif c == 'f' then return false, i + 5
    elseif c == 'n' then return nil, i + 4
    elseif c == '-' or (c >= '0' and c <= '9') then return decode_number(s, i)
    else error("JSON: unexpected char '" .. c .. "' at " .. i)
    end
end

function json.decode(s)
    if not s or s == "" then return nil end
    local val, _ = decode_value(s, 1)
    return val
end

return json
