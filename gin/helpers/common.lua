-- dep
local lfs = require 'lfs'
local prettyprint = require 'pl.pretty'

-- perf
local iopen = io.open
local ipairs = ipairs
local pairs = pairs
local pcall = pcall
local require = require
local sfind = string.find
local sgsub = string.gsub
local smatch = string.match
local ssub = string.sub
local tinsert = table.insert
local type = type


local CommonHelpers = {}

-- try to require
function CommonHelpers.try_require(module_name, default)
    local ok, module_or_err = pcall(function() return require(module_name) end)

    if ok == true then return module_or_err end

    if ok == false and smatch(module_or_err, "'" .. module_name .. "' not found") then
        return default
    else
        error(module_or_err)
    end
end

-- read file
function CommonHelpers.read_file(file_path)
    local f = iopen(file_path, "rb")
    local content = f:read("*all")
    f:close()
    return content
end

-- check if folder exists
function CommonHelpers.folder_exists(folder_path)
    return lfs.attributes(sgsub(folder_path, "\\$",""), "mode") == "directory"
end

-- split function
function CommonHelpers.split(str, pat)
    local t = {}
    local fpat = "(.-)" .. pat
    local last_end = 1
    local s, e, cap = sfind(str, fpat, 1)

    while s do
        if s ~= 1 or cap ~= "" then
            tinsert(t,cap)
        end
        last_end = e+1
        s, e, cap = sfind(str, fpat, last_end)
    end

    if last_end <= #str then
        cap = ssub(str, last_end)
        tinsert(t, cap)
    end

    return t
end

-- split a path in individual parts
function CommonHelpers.split_path(str)
   return CommonHelpers.split(str, '[\\/]+')
end

-- recursively make directories
function CommonHelpers.mkdirs(file_path)
    -- get dir path and parts
    dir_path = smatch(file_path, "(.*)/.*")
    parts = CommonHelpers.split_path(dir_path)
    -- loop
    local current_dir = nil
    for _, part in ipairs(parts) do
        if current_dir == nil then
            current_dir = part
        else
            current_dir = current_dir .. '/' .. part
        end
        lfs.mkdir(current_dir)
    end
end

-- value in table?
function CommonHelpers.included_in_table(t, value)
    for _, v in ipairs(t) do
        if v == value then return true end
    end
    return false
end

-- reverse table
function CommonHelpers.reverse_table(t)
    local size = #t + 1
    local reversed = {}
    for i, v in ipairs(t) do
        reversed[size - i] = v
    end
    return reversed
end

-- pretty print to file
function CommonHelpers.pp_to_file(o, file_path)
    prettyprint.dump(o, file_path)
end

-- pretty print
function CommonHelpers.pp(o)
    prettyprint.dump(o)
end

-- check if folder exists
function folder_exists(folder_path)
    return lfs.attributes(sgsub(folder_path, "\\$",""), "mode") == "directory"
end

-- get the lua module name
function CommonHelpers.get_lua_module_name(file_path)
    return smatch(file_path, "(.*)%.lua")
end

-- shallow copy of a table
function CommonHelpers.shallowcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

return CommonHelpers
