local UE = {}
UE.VERSION = "1.0.0"
UE.BUILD = "phase-6"
UE.FORMAT = "1.0"

getgenv().UniversalExplorer = UE

UE.config = {
    ui_autoload = true,
    debug = false,
    silent = false,
    workspace_root = "UniversalExplorer",
    autosave = false,
    autosave_interval_sec = 300,
    backup_rotation = true,
    compress = true,
    size_warn_mb = 25,
    size_refuse_mb = 200,
    tree_lazy = true,
    tree_track_props = true,
    tree_watch_tags = true,
    discover_remotes = true,
    discover_scripts = true,
    discover_signals = true,
    hook_budget = 64,
    hook_autoscale = true,
    hook_max_retries = 3,
    net_full_values = true,
    net_deep_copy = true,
    net_rate_window = 5,
    deob_auto = true,
    deob_full_reconstruct = true,
    deob_confidence_floor = 0.0,
    timeline_capacity = 10000,
    timeline_snapshot_hz = 4,
    anomaly_baseline_sec = 30,
    anomaly_sensitivity = 3.0,
    repl_history_max = 500,
    repl_persist_history = true,
    _user_overrides = {},
}

do
    local ext = rawget(_G, "UE_CONFIG")
    if type(ext) == "table" then
        for k, v in pairs(ext) do
            UE.config[k] = v
            UE.config._user_overrides[k] = true
        end
    end
end

function UE.config.set(key, value)
    UE.config[key] = value
    UE.config._user_overrides[key] = true
end

function UE.config.get(key)
    return UE.config[key]
end

UE.util = {}

function UE.util.deep_copy(value, seen)
    seen = seen or {}
    local t = type(value)
    if t ~= "table" then return value end
    if seen[value] then return seen[value] end
    local copy = {}
    seen[value] = copy
    for k, v in next, value do
        copy[UE.util.deep_copy(k, seen)] = UE.util.deep_copy(v, seen)
    end
    return setmetatable(copy, getmetatable(value))
end

function UE.util.deep_equal(a, b, seen)
    if a == b then return true end
    local ta, tb = type(a), type(b)
    if ta ~= tb then return false end
    if ta ~= "table" then return false end
    seen = seen or {}
    local key = tostring(a) .. "|" .. tostring(b)
    if seen[key] then return true end
    seen[key] = true
    for k, v in next, a do
        if not UE.util.deep_equal(v, b[k], seen) then return false end
    end
    for k in next, b do
        if a[k] == nil then return false end
    end
    return true
end

function UE.util.timestamp()
    return os.time()
end

function UE.util.timestamp_ms()
    if tick then return tick() end
    return os.clock()
end

function UE.util.uid()
    return string.format("%x%x", os.time(), math.random(1, 0xFFFFFF))
end

function UE.util.hash(str)
    str = tostring(str)
    local h = 5381
    for i = 1, #str do
        h = ((h * 33) + string.byte(str, i)) % 4294967296
    end
    return h
end

function UE.util.path_sanitize(name)
    name = tostring(name or "")
    name = name:gsub("%.%.", "")
    name = name:gsub("[\\/]+", "_")
    name = name:gsub("[%z\1-\31]", "")
    name = name:gsub("^%s+", ""):gsub("%s+$", "")
    if #name == 0 then name = "unnamed" end
    if #name > 128 then name = name:sub(1, 128) end
    return name
end

function UE.util.size_human(bytes)
    bytes = tonumber(bytes) or 0
    local units = { "B", "KB", "MB", "GB" }
    local i = 1
    while bytes >= 1024 and i < #units do
        bytes = bytes / 1024
        i = i + 1
    end
    return string.format("%.2f%s", bytes, units[i])
end

function UE.util.clamp(v, lo, hi)
    if v < lo then return lo end
    if v > hi then return hi end
    return v
end

function UE.util.round(v, decimals)
    decimals = decimals or 0
    local mult = 10 ^ decimals
    return math.floor(v * mult + 0.5) / mult
end

function UE.util.table_keys(t)
    local keys = {}
    for k in next, t do
        table.insert(keys, k)
    end
    return keys
end

function UE.util.table_len(t)
    local n = 0
    for _ in next, t do n = n + 1 end
    return n
end

function UE.util.merge(dst, src)
    for k, v in next, src do
        if dst[k] == nil then dst[k] = v end
    end
    return dst
end

function UE.util.merge_deep(dst, src)
    for k, v in next, src do
        if type(v) == "table" and type(dst[k]) == "table" then
            UE.util.merge_deep(dst[k], v)
        elseif dst[k] == nil then
            dst[k] = v
        end
    end
    return dst
end

function UE.util.is_instance(v)
    return typeof(v) == "Instance"
end

function UE.util.safe_serialize(value, seen, depth)
    seen = seen or {}
    depth = depth or 0
    if depth > 32 then return "<depth-limit>" end
    local t = type(value)
    if t == "nil" or t == "boolean" or t == "number" or t == "string" then
        return value
    end
    if t == "Instance" then
        return { __type = "Instance", path = value:GetFullName() }
    end
    if t == "Vector3" then
        return { __type = "Vector3", x = value.X, y = value.Y, z = value.Z }
    end
    if t == "Vector2" then
        return { __type = "Vector2", x = value.X, y = value.Y }
    end
    if t == "CFrame" then
        return { __type = "CFrame", components = { value:GetComponents() } }
    end
    if t == "Color3" then
        return { __type = "Color3", r = value.R, g = value.G, b = value.B }
    end
    if t == "UDim2" then
        return { __type = "UDim2", xs = value.X.Scale, xo = value.X.Offset, ys = value.Y.Scale, yo = value.Y.Offset }
    end
    if t == "BrickColor" then
        return { __type = "BrickColor", name = value.Name, number = value.Number }
    end
    if t == "EnumItem" then
        return { __type = "EnumItem", enum = tostring(value.EnumType), name = value.Name, value = value.Value }
    end
    if t == "function" then
        return { __type = "function", tostring = tostring(value) }
    end
    if t == "thread" then
        return { __type = "thread", tostring = tostring(value) }
    end
    if t == "userdata" then
        return { __type = "userdata", tostring = tostring(value) }
    end
    if t == "table" then
        if seen[value] then return { __type = "ref", id = seen[value] } end
        local id = UE.util.uid()
        seen[value] = id
        local out = { __type = "table", __id = id, data = {} }
        for k, v in next, value do
            local ks = UE.util.safe_serialize(k, seen, depth + 1)
            local vs = UE.util.safe_serialize(v, seen, depth + 1)
            table.insert(out.data, { k = ks, v = vs })
        end
        return out
    end
    return { __type = "unknown", raw = tostring(value) }
end

function UE.util.safe_deserialize(value)
    if type(value) ~= "table" then return value end
    local t = value.__type
    if t == nil then
        local out = {}
        for k, v in next, value do
            out[k] = UE.util.safe_deserialize(v)
        end
        return out
    end
    if t == "Instance" then return value.path end
    if t == "Vector3" then return Vector3.new(value.x or 0, value.y or 0, value.z or 0) end
    if t == "Vector2" then return Vector2.new(value.x or 0, value.y or 0) end
    if t == "CFrame" then
        if value.components and #value.components == 12 then
              local unpack_fn = table.unpack or unpack
return CFrame.new(unpack_fn(value.components))
        end
        return CFrame.new()
    end
    if t == "Color3" then return Color3.new(value.r or 0, value.g or 0, value.b or 0) end
    if t == "UDim2" then return UDim2.new(value.xs or 0, value.xo or 0, value.ys or 0, value.yo or 0) end
    if t == "table" then
        local out = {}
        for _, pair in next, value.data do
            out[UE.util.safe_deserialize(pair.k)] = UE.util.safe_deserialize(pair.v)
        end
        return out
    end
    return value
end

function UE.util.wrap(fn)
    return function(...)
        local ok, res = pcall(fn, ...)
        if not ok then
            if UE.config.debug then warn("[UE] " .. tostring(res)) end
            return nil, res
        end
        return res
    end
end

function UE.util.safe_call(fn, ...)
    if type(fn) ~= "function" then return nil end
    local ok, res = pcall(fn, ...)
    if not ok then return nil end
    return res
end

function UE.util.json_encode(value)
    local HttpService = game:GetService("HttpService")
    local ok, res = pcall(function()
        return HttpService:JSONEncode(UE.util.safe_serialize(value))
    end)
    if ok then return res end
    return nil
end

function UE.util.json_decode(str)
    if type(str) ~= "string" then return nil end
    local HttpService = game:GetService("HttpService")
    local ok, res = pcall(function()
        return HttpService:JSONDecode(str)
    end)
    if ok then return UE.util.safe_deserialize(res) end
    return nil
end

UE.exec = {}
UE.exec.caps = {}

local function has_fn(name)
    local env = (getfenv and getfenv()) or _G
    local f = rawget(env, name) or rawget(_G, name)
    return type(f) == "function", f
end

function UE.exec.detect()
    local caps = {}
    local function check(key, ...)
        local names = { ... }
        local all_exist = true
        local funcs = {}
        for _, n in ipairs(names) do
            local exists, f = has_fn(n)
            if exists then
                funcs[n] = f
            else
                all_exist = false
            end
        end
        if all_exist then
            caps[key] = true
            for n, f in pairs(funcs) do caps[n] = f end
        else
            caps[key] = false
        end
    end
    check("file_read", "readfile")
    check("file_write", "writefile")
    check("file_append", "appendfile")
    check("file_exists", "isfile")
    check("file_delete", "delfile")
    check("file_list", "listfiles")
    check("folder_make", "makefolder")
    check("folder_delete", "delfolder")
    check("hook", "hookfunction", "hookfunc")
    check("newcclosure", "newcclosure")
    check("getrawmeta", "getrawmetatable")
    check("setreadonly", "setreadonly")
    check("getfenv", "getfenv")
    check("getsenv", "getsenv")
    check("getrenv", "getrenv")
    check("setfenv", "setfenv")
    check("getgc", "getgc")
    check("getreg", "getreg")
    check("getupvalues", "getupvalues", "getupvalue")
    check("getconstants", "getconstants", "getconstant")
    check("getprotos", "getprotos", "getproto")
    check("getscriptbytecode", "getscriptbytecode", "getbytecode")
    check("decompile", "decompile")
    check("disassemble", "disassemble")
    check("getloadedmodules", "getloadedmodules")
    check("getconnections", "getconnections")
    check("firesignal", "firesignal")
    check("getnilinstances", "getnilinstances")
    check("gethui", "gethui")
    check("getcustomasset", "getcustomasset")
    check("identifyexecutor", "identifyexecutor")
    check("getscript", "getscript")
    local ok_ident, ident = pcall(function()
        if type(caps.identifyexecutor) == "function" then
            return caps.identifyexecutor()
        end
        return "unknown"
    end)
    caps.executor_name = ok_ident and ident or "unknown"
    UE.exec.caps = caps
    return caps
end

function UE.exec.has(name) return UE.exec.caps[name] == true end
function UE.exec.get(name) return UE.exec.caps[name] end

function UE.exec.write_file(path, data)
    if not UE.exec.has("file_write") then return false, "no writefile" end
    local fn = UE.exec.get("writefile")
    local ok, err = pcall(fn, path, data)
    if not ok then return false, err end
    return true
end

function UE.exec.read_file(path)
    if not UE.exec.has("file_read") then return nil, "no readfile" end
    local fn = UE.exec.get("file_read")
    local f = UE.exec.get("readfile")
    local ok, data = pcall(f, path)
    if not ok then return nil, data end
    return data
end

function UE.exec.append_file(path, data)
    if not UE.exec.has("file_append") then return false, "no appendfile" end
    local f = UE.exec.get("appendfile")
    local ok, err = pcall(f, path, data)
    if not ok then return false, err end
    return true
end

function UE.exec.file_exists(path)
    if not UE.exec.has("file_exists") then return false end
    local f = UE.exec.get("isfile")
    local ok, res = pcall(f, path)
    return ok and res or false
end

function UE.exec.delete_file(path)
    if not UE.exec.has("file_delete") then return false end
    local f = UE.exec.get("delfile")
    local ok = pcall(f, path)
    return ok
end

function UE.exec.list_files(path)
    if not UE.exec.has("file_list") then return {} end
    local f = UE.exec.get("listfiles")
    local ok, res = pcall(f, path)
    if ok and type(res) == "table" then return res end
    return {}
end

function UE.exec.make_folder(path)
    if not UE.exec.has("folder_make") then return false end
    local f = UE.exec.get("makefolder")
    local ok = pcall(f, path)
    return ok
end

function UE.exec.delete_folder(path)
    if not UE.exec.has("folder_delete") then return false end
    local f = UE.exec.get("delfolder")
    local ok = pcall(f, path)
    return ok
end

function UE.exec.hook(target, replacement)
    if not UE.exec.has("hook") then return nil end
    local fn = UE.exec.get("hookfunction") or UE.exec.get("hookfunc")
    local ok, res = pcall(fn, target, replacement)
    if ok then return res end
    return nil
end

function UE.exec.newcclosure(fn)
    if not UE.exec.has("newcclosure") then return fn end
    local fnc = UE.exec.get("newcclosure")
    local ok, res = pcall(fnc, fn)
    if ok then return res end
    return fn
end

function UE.exec.getrawmetatable(obj)
    if not UE.exec.has("getrawmeta") then return nil end
    local fn = UE.exec.get("getrawmetatable")
    local ok, res = pcall(fn, obj)
    if ok then return res end
    return nil
end

function UE.exec.set_readonly(tbl, state)
    if not UE.exec.has("setreadonly") then return false end
    local fn = UE.exec.get("setreadonly")
    local ok = pcall(fn, tbl, state)
    return ok
end

function UE.exec.getfenv(target)
    if not UE.exec.has("getfenv") then return nil end
    local fn = UE.exec.get("getfenv")
    local ok, res = pcall(fn, target)
    if ok then return res end
    return nil
end

function UE.exec.getsenv(script)
    if not UE.exec.has("getsenv") then return nil end
    local fn = UE.exec.get("getsenv")
    local ok, res = pcall(fn, script)
    if ok then return res end
    return nil
end

function UE.exec.getrenv()
    if not UE.exec.has("getrenv") then return nil end
    local fn = UE.exec.get("getrenv")
    local ok, res = pcall(fn)
    if ok then return res end
    return nil
end

function UE.exec.getgc()
    if not UE.exec.has("getgc") then return {} end
    local fn = UE.exec.get("getgc")
    local ok, res = pcall(fn, true)
    if ok then return res end
    return {}
end

function UE.exec.getreg()
    if not UE.exec.has("getreg") then return {} end
    local fn = UE.exec.get("getreg")
    local ok, res = pcall(fn)
    if ok then return res end
    return {}
end

function UE.exec.getupvalues(fn)
    if not UE.exec.has("getupvalues") then return {} end
    local f = UE.exec.get("getupvalues") or UE.exec.get("getupvalue")
    local ok, res = pcall(f, fn)
    if ok then return res end
    return {}
end

function UE.exec.getconstants(fn)
    if not UE.exec.has("getconstants") then return {} end
    local f = UE.exec.get("getconstants") or UE.exec.get("getconstant")
    local ok, res = pcall(f, fn)
    if ok then return res end
    return {}
end

function UE.exec.getscriptbytecode(script)
    if not UE.exec.has("getscriptbytecode") then return nil end
    local fn = UE.exec.get("getscriptbytecode") or UE.exec.get("getbytecode")
    local ok, res = pcall(fn, script)
    if ok then return res end
    return nil
end

function UE.exec.decompile(script)
    if not UE.exec.has("decompile") then return nil end
    local fn = UE.exec.get("decompile")
    local ok, res = pcall(fn, script)
    if ok then return res end
    return nil
end

function UE.exec.disassemble(script)
    if not UE.exec.has("disassemble") then return nil end
    local fn = UE.exec.get("disassemble")
    local ok, res = pcall(fn, script)
    if ok then return res end
    return nil
end

function UE.exec.getconnections(signal)
    if not UE.exec.has("getconnections") then return {} end
    local fn = UE.exec.get("getconnections")
    local ok, res = pcall(fn, signal)
    if ok then return res end
    return {}
end

function UE.exec.getscript(instance)
    if type(instance) ~= "userdata" and type(instance) ~= "table" then return nil end
    local fn = rawget(_G, "getscript")
    if type(fn) == "function" then
        local ok, res = pcall(fn, instance)
        if ok then return res end
    end
    local cap = UE.exec.get("getscript")
    if type(cap) == "function" then
        local ok, res = pcall(cap, instance)
        if ok then return res end
    end
    return nil
end

function UE.exec.identify()
    return UE.exec.caps.executor_name or "unknown"
end

function UE.exec.summary()
    local available = {}
    local missing = {}
    for k, v in pairs(UE.exec.caps) do
        if type(v) == "boolean" then
            if v then table.insert(available, k) else table.insert(missing, k) end
        end
    end
    return { executor = UE.exec.identify(), available = available, missing = missing }
end

UE.file = {}
UE.file._root = nil
UE.file._events = {}
UE.file._migrations = {}

function UE.file._emit(name, ...)
    local subs = UE.file._events[name]
    if not subs then return end
    for _, cb in next, subs do
        local ok, err = pcall(cb, ...)
        if not ok and UE.config.debug then warn("[UE.file] listener error: " .. tostring(err)) end
    end
end

function UE.file.on(name, cb)
    if type(cb) ~= "function" then return end
    UE.file._events[name] = UE.file._events[name] or {}
    table.insert(UE.file._events[name], cb)
end

function UE.file.off(name, cb)
    local subs = UE.file._events[name]
    if not subs then return end
    for i = #subs, 1, -1 do
        if subs[i] == cb then table.remove(subs, i) end
    end
end

function UE.file.get_root() return UE.file._root end

function UE.file.path(...)
    local parts = { UE.file._root or UE.config.workspace_root }
    for _, p in ipairs({ ... }) do
        if p ~= nil and p ~= "" then
            table.insert(parts, UE.util.path_sanitize(p))
        end
    end
    return table.concat(parts, "/")
end

function UE.file._ensure_folder(path)
    if not UE.exec.has("folder_make") then return false end
    if UE.exec.has("file_exists") then
        if UE.exec.file_exists(path) then return true end
    end
    UE.exec.make_folder(path)
    return true
end

function UE.file._ensure_subfolders()
    local subs = { "sessions", "patterns", "snapshots", "dumps", "logs", "config" }
    for _, s in ipairs(subs) do
        UE.file._ensure_folder(UE.file.path(s))
    end
end

function UE.file.init()
    UE.file._root = UE.config.workspace_root
    if not UE.exec.has("folder_make") then
        UE.file._root = nil
        return false, "no makefolder capability"
    end
    UE.file._ensure_folder(UE.file._root)
    UE.file._ensure_subfolders()
    return true
end

function UE.file._atomic_write(path, data)
    local tmp = path .. ".tmp"
    local ok, err = UE.exec.write_file(tmp, data)
    if not ok then return false, err end
    if UE.exec.has("file_delete") and UE.exec.file_exists(path) then
        UE.exec.delete_file(path)
    end
    local ok2, err2 = UE.exec.write_file(path, data)
    if not ok2 then return false, err2 end
    if UE.exec.file_exists(tmp) then
        UE.exec.delete_file(tmp)
    end
    return true
end

function UE.file._backup(path)
    if not UE.config.backup_rotation then return end
    if not UE.exec.file_exists(path) then return end
    local bak = path .. ".bak"
    local existing = UE.exec.read_file(path)
    if existing then
        UE.exec.write_file(bak, existing)
    end
end

function UE.file._size_guard(data)
    local size = #tostring(data or "")
    local mb = size / (1024 * 1024)
    if mb >= UE.config.size_refuse_mb then
        return false, "size exceeds refuse limit (" .. UE.util.size_human(size) .. ")"
    end
    if mb >= UE.config.size_warn_mb then
        if not UE.config.silent then
            warn("[UE.file] large write: " .. UE.util.size_human(size))
        end
    end
    return true
end

function UE.file._header(kind)
    return {
        _ue = UE.FORMAT,
        type = kind,
        version = UE.VERSION,
        build = UE.BUILD,
        created = UE.util.timestamp(),
        executor = UE.exec.identify(),
    }
end

function UE.file._wrap(kind, payload)
    local out = UE.file._header(kind)
    out.payload = payload
    return out
end

function UE.file._parse_version(v)
    if type(v) ~= "string" then return nil end
    local parts = {}
    for p in v:gmatch("%d+") do table.insert(parts, tonumber(p)) end
    return parts
end

function UE.file._compare_version(a, b)
    local pa = UE.file._parse_version(a) or {}
    local pb = UE.file._parse_version(b) or {}
    for i = 1, math.max(#pa, #pb) do
        local x = pa[i] or 0
        local y = pb[i] or 0
        if x < y then return -1 end
        if x > y then return 1 end
    end
    return 0
end

function UE.file.register_migration(from_ver, to_ver, fn)
    if type(fn) ~= "function" then return false end
    UE.file._migrations[from_ver] = UE.file._migrations[from_ver] or {}
    UE.file._migrations[from_ver][to_ver] = fn
    return true
end

function UE.file._migrate(data, target_version)
    if type(data) ~= "table" then return data end
    local ver = data._ue or data.version or "0.0"
    target_version = target_version or UE.FORMAT
    local cmp = UE.file._compare_version(ver, target_version)
    if cmp == 0 then return data end
    if cmp > 0 then
        if not UE.config.silent then
            warn("[UE.file] data version " .. tostring(ver) .. " newer than " .. target_version)
        end
        return data
    end
    local chain = {}
    local current = ver
    for _ = 1, 16 do
        local bucket = UE.file._migrations[current]
        if not bucket then break end
        local next_ver = nil
        for v, _ in pairs(bucket) do
            if UE.file._compare_version(v, current) > 0 then
                if not next_ver or UE.file._compare_version(v, next_ver) < 0 then
                    next_ver = v
                end
            end
        end
        if not next_ver then break end
        table.insert(chain, { from = current, to = next_ver })
        current = next_ver
        if UE.file._compare_version(current, target_version) >= 0 then break end
    end
    local migrated = data
    for _, step in ipairs(chain) do
        local fn = UE.file._migrations[step.from] and UE.file._migrations[step.from][step.to]
        if fn then
            local ok, res = pcall(fn, migrated)
            if ok and type(res) == "table" then migrated = res end
        end
    end
    migrated._ue = target_version
    migrated._migrated_from = ver
    return migrated
end

function UE.file._unwrap(data)
    if type(data) ~= "table" then return nil, "not a table" end
    if data._ue == nil and data.version == nil then return nil, "missing header" end
    if data.type == nil and data.payload == nil then return nil, "missing type" end
    return UE.file._migrate(data, UE.FORMAT)
end

UE.file.register_migration("0.9", "1.0", function(data)
    if type(data) ~= "table" then return data end
    local out = UE.util.deep_copy(data)
    if out.payload == nil and out.data ~= nil then
        out.payload = out.data
        out.data = nil
    end
    if out.type == nil then out.type = "generic" end
    return out
end)

function UE.file.write(name, data, kind)
    if not UE.file._root then return false, "workspace not initialized" end
    kind = kind or "generic"
    local path = UE.file.path(name)
    local wrapped = UE.file._wrap(kind, data)
    local json = UE.util.json_encode(wrapped)
    if not json then return false, "json encode failed" end
    local ok, err = UE.file._size_guard(json)
    if not ok then return false, err end
    UE.file._backup(path)
    local ok2, err2 = UE.file._atomic_write(path, json)
    if not ok2 then
        UE.file._emit("onFileError", name, err2)
        return false, err2
    end
    UE.file._emit("onFileSaved", name, path, #json)
    return true, path
end

function UE.file.write_raw(name, data)
    if not UE.file._root then return false, "workspace not initialized" end
    local path = UE.file.path(name)
    local ok, err = UE.file._size_guard(data)
    if not ok then return false, err end
    UE.file._backup(path)
    local ok2, err2 = UE.file._atomic_write(path, data)
    if not ok2 then
        UE.file._emit("onFileError", name, err2)
        return false, err2
    end
    UE.file._emit("onFileSaved", name, path, #data)
    return true, path
end

function UE.file.read(name)
    if not UE.file._root then return nil, "workspace not initialized" end
    local path = UE.file.path(name)
    local data, err = UE.exec.read_file(path)
    if not data then
        UE.file._emit("onFileError", name, err)
        return nil, err
    end
    local parsed = UE.util.json_decode(data)
    if not parsed then
        UE.file._emit("onFileLoaded", name, path, #data)
        return data
    end
    local unwrapped = UE.file._unwrap(parsed)
    if not unwrapped then return parsed end
    UE.file._emit("onFileLoaded", name, path, #data)
    return unwrapped.payload
end

function UE.file.read_raw(name)
    if not UE.file._root then return nil, "workspace not initialized" end
    local path = UE.file.path(name)
    local data, err = UE.exec.read_file(path)
    if not data then
        UE.file._emit("onFileError", name, err)
        return nil, err
    end
    UE.file._emit("onFileLoaded", name, path, #data)
    return data
end

function UE.file.exists(name)
    if not UE.file._root then return false end
    return UE.exec.file_exists(UE.file.path(name))
end

function UE.file.delete(name)
    if not UE.file._root then return false end
    return UE.exec.delete_file(UE.file.path(name))
end

function UE.file.list(sub)
    if not UE.file._root then return {} end
    local path = sub and UE.file.path(sub) or UE.file._root
    return UE.exec.list_files(path)
end

function UE.file.folder(name)
    if not UE.file._root then return false end
    return UE.file._ensure_folder(UE.file.path(name))
end

function UE.file.usage()
    if not UE.file._root then return { total = 0, files = 0, folders = {} } end
    local result = { total = 0, files = 0, folders = {} }
    local visited = {}
    local function walk(path, label)
        if visited[path] then return end
        visited[path] = true
        local entries = UE.exec.list_files(path)
        if type(entries) ~= "table" then return end
        for _, entry in ipairs(entries) do
            local full = entry
            if not full:find("/") and not full:find("\\") then
                full = path .. "/" .. entry
            end
            local data = UE.exec.read_file(full)
            if type(data) == "string" then
                result.total = result.total + #data
                result.files = result.files + 1
            else
                result.folders[full] = true
                walk(full, entry)
            end
        end
    end
    walk(UE.file._root, "root")
    return result
end

function UE.file.export_session(name, payload)
    if not UE.file._root then return false, "no workspace" end
    local fname = "sessions/" .. UE.util.path_sanitize(name) .. ".uex"
    return UE.file.write(fname, payload, "session")
end

function UE.file.import_session(name)
    local fname = "sessions/" .. UE.util.path_sanitize(name) .. ".uex"
    return UE.file.read(fname)
end

function UE.file.export_pattern(name, payload)
    local fname = "patterns/" .. UE.util.path_sanitize(name) .. ".uep"
    return UE.file.write(fname, payload, "pattern")
end

function UE.file.import_pattern(name)
    local fname = "patterns/" .. UE.util.path_sanitize(name) .. ".uep"
    return UE.file.read(fname)
end

function UE.file.dump(name, content, kind)
    kind = kind or "dump"
    local ext = kind == "bytecode" and ".ueb" or ".ued"
    local fname = "dumps/" .. UE.util.path_sanitize(name) .. ext
    return UE.file.write_raw(fname, content)
end

function UE.file.log(name, content)
    local fname = "logs/" .. UE.util.path_sanitize(name) .. ".uel"
    return UE.file.write_raw(fname, content)
end

function UE.file.save_snapshot(name, payload)
    local fname = "snapshots/" .. UE.util.path_sanitize(name) .. ".ues"
    return UE.file.write(fname, payload, "snapshot")
end

function UE.file.load_snapshot(name)
    local fname = "snapshots/" .. UE.util.path_sanitize(name) .. ".ues"
    return UE.file.read(fname)
end

function UE.file.save_config(cfg)
    local fname = "config/settings.cfg"
    return UE.file.write(fname, cfg or UE.config, "config")
end

function UE.file.load_config()
    local fname = "config/settings.cfg"
    return UE.file.read(fname)
end

UE.model = {}
UE.model._events = {}
UE.model._nodes = {}
UE.model._props = {}
UE.model._tags = {}
UE.model._classes = {}
UE.model._watchers = {}
UE.model._dirty = {}
UE.model._root = nil

function UE.model._emit(name, ...)
    local subs = UE.model._events[name]
    if not subs then return end
    for _, cb in next, subs do
        local ok, err = pcall(cb, ...)
        if not ok and UE.config.debug then warn("[UE.model] listener error: " .. tostring(err)) end
    end
end

function UE.model.on(name, cb)
    if type(cb) ~= "function" then return end
    UE.model._events[name] = UE.model._events[name] or {}
    table.insert(UE.model._events[name], cb)
end

function UE.model.off(name, cb)
    local subs = UE.model._events[name]
    if not subs then return end
    for i = #subs, 1, -1 do
        if subs[i] == cb then table.remove(subs, i) end
    end
end

function UE.model._class_ancestry(instance)
    local chain = {}
    if not UE.util.is_instance(instance) then return chain end
    local ok, class = pcall(function() return instance.ClassName end)
    if not ok or not class then return chain end
    table.insert(chain, class)
    local current = class
    for _ = 1, 16 do
        local api_ok, info = pcall(function()
            return game:GetService("ReflectionService"):GetClass(current)
        end)
        if not api_ok or not info then break end
        local super_ok, super = pcall(function() return info.Superclass end)
        if not super_ok or not super or super == "<<<ROOT>>>" or super == "" then break end
        table.insert(chain, super)
        current = super
    end
    return chain
end

function UE.model._register_node(instance, parent_path)
    if not UE.util.is_instance(instance) then return nil end
    local ok, path = pcall(function() return instance:GetFullName() end)
    if not ok then return nil end
    local node = UE.model._nodes[path]
    if not node then
        node = {
            instance = instance,
            path = path,
            name = instance.Name,
            class = instance.ClassName,
            children = {},
            parent = parent_path,
            created = UE.util.timestamp_ms(),
        }
        UE.model._nodes[path] = node
    end
    return node
end

function UE.model._register_props(instance, path)
    if not UE.config.tree_track_props then return end
    if UE.model._props[path] then return end
    local props = {}
    props.registered_at = UE.util.timestamp_ms()
    props.class = instance.ClassName
    UE.model._props[path] = props
end

function UE.model._walk(instance, parent_path, depth)
    depth = depth or 0
    if depth > 128 then return end
    if not UE.util.is_instance(instance) then return end
    local node = UE.model._register_node(instance, parent_path)
    if not node then return end
    if parent_path then
        local parent_node = UE.model._nodes[parent_path]
        if parent_node then
            local exists = false
            for _, cp in ipairs(parent_node.children) do
                if cp == node.path then exists = true break end
            end
            if not exists then
                table.insert(parent_node.children, node.path)
            end
        end
    end
    UE.model._register_props(instance, node.path)
    UE.model._hook_node(node)
    local ok, children = pcall(function() return instance:GetChildren() end)
    if not ok or type(children) ~= "table" then return end
    for _, child in ipairs(children) do
        UE.model._walk(child, node.path, depth + 1)
    end
end

function UE.model._hook_node(node)
    if not node or not node.instance then return end
    if node._hooked then return end
    node._hooked = true
    local inst = node.instance
    local ok, conn = pcall(function()
        return inst.ChildAdded:Connect(function(child)
            if not UE.util.is_instance(child) then return end
            UE.model._walk(child, node.path, 0)
            UE.model._emit("onTreeChanged", node.path, "child_added", child)
        end)
    end)
    if ok then node._child_added_conn = conn end
    local ok2, conn2 = pcall(function()
        return inst.ChildRemoved:Connect(function(child)
            if not UE.util.is_instance(child) then return end
            local cpath = node.path .. "." .. child.Name
            local old = UE.model._nodes[cpath]
            if old then
                if old._child_added_conn then old._child_added_conn:Disconnect() end
                if old._child_removed_conn then old._child_removed_conn:Disconnect() end
                if old._changed_conn then old._changed_conn:Disconnect() end
                UE.model._nodes[cpath] = nil
            end
            local pnode = UE.model._nodes[node.path]
            if pnode then
                for i = #pnode.children, 1, -1 do
                    if pnode.children[i] == cpath then
                        table.remove(pnode.children, i)
                    end
                end
            end
            UE.model._emit("onTreeChanged", node.path, "child_removed", child)
        end)
    end)
    if ok2 then node._child_removed_conn = conn2 end
    local ok3, conn3 = pcall(function()
        return inst.Changed:Connect(function(prop)
            UE.model._emit("onPropertyChanged", node.path, prop, inst[prop])
        end)
    end)
    if ok3 then node._changed_conn = conn3 end
end

function UE.model.get(path) return UE.model._nodes[path] end

function UE.model.by_instance(instance)
    if not UE.util.is_instance(instance) then return nil end
    local ok, path = pcall(function() return instance:GetFullName() end)
    if not ok then return nil end
    return UE.model._nodes[path]
end

function UE.model.all() return UE.model._nodes end

function UE.model.children(path)
    local node = UE.model._nodes[path]
    if not node then return {} end
    local out = {}
    for _, child_path in ipairs(node.children) do
        local child = UE.model._nodes[child_path]
        if child then table.insert(out, child) end
    end
    return out
end

function UE.model.tags(path) return UE.model._tags[path] or {} end

function UE.model.find_class(class)
    local out = {}
    for _, node in pairs(UE.model._nodes) do
        if node.class == class then table.insert(out, node) end
    end
    return out
end

function UE.model.find_name(name)
    local out = {}
    for _, node in pairs(UE.model._nodes) do
        if node.name == name then table.insert(out, node) end
    end
    return out
end

function UE.model.watch(path, callback)
    if type(callback) ~= "function" then return end
    UE.model._watchers[path] = UE.model._watchers[path] or {}
    table.insert(UE.model._watchers[path], callback)
    local node = UE.model._nodes[path]
    if node and node.instance then UE.model._hook_node(node) end
end

function UE.model.init()
    UE.model._root = game
    UE.model._nodes = {}
    UE.model._props = {}
    UE.model._tags = {}
    UE.model._walk(game, nil, 0)
    if UE.disc and UE.disc._build_tag_index then
        UE.disc._build_tag_index()
    end
    return true
end

function UE.model.stop()
    for _, node in pairs(UE.model._nodes) do
        if node._child_added_conn then node._child_added_conn:Disconnect() end
        if node._child_removed_conn then node._child_removed_conn:Disconnect() end
        if node._changed_conn then node._changed_conn:Disconnect() end
    end
end

UE.disc = {}
UE.disc._events = {}
UE.disc._remotes = {}
UE.disc._scripts = {}
UE.disc._signals = {}
UE.disc._modules = {}
UE.disc._require_hooked = false
UE.disc._module_cache = {}
UE.disc._loaded_modules_scanned = false

function UE.disc._emit(name, ...)
    local subs = UE.disc._events[name]
    if not subs then return end
    for _, cb in next, subs do
        local ok, err = pcall(cb, ...)
        if not ok and UE.config.debug then warn("[UE.disc] listener error: " .. tostring(err)) end
    end
end

function UE.disc.on(name, cb)
    if type(cb) ~= "function" then return end
    UE.disc._events[name] = UE.disc._events[name] or {}
    table.insert(UE.disc._events[name], cb)
end

function UE.disc.off(name, cb)
    local subs = UE.disc._events[name]
    if not subs then return end
    for i = #subs, 1, -1 do
        if subs[i] == cb then table.remove(subs, i) end
    end
end

function UE.disc._is_remote(inst)
    if not UE.util.is_instance(inst) then return false end
    local ok, class = pcall(function() return inst.ClassName end)
    if not ok then return false end
    return class == "RemoteEvent"
        or class == "RemoteFunction"
        or class == "UnreliableRemoteEvent"
        or class == "BindableEvent"
        or class == "BindableFunction"
end

function UE.disc._register_remote(inst)
    if not UE.util.is_instance(inst) then return end
    local ok, path = pcall(function() return inst:GetFullName() end)
    if not ok then return end
    if UE.disc._remotes[path] then return end
    local class_ok, class = pcall(function() return inst.ClassName end)
    if not class_ok then return end
    local entry = {
        instance = inst,
        path = path,
        class = class,
        name = inst.Name,
        first_seen = UE.util.timestamp_ms(),
        fires = 0,
        invokes = 0,
        last_fire = nil,
        last_args = nil,
        callers = {},
    }
    UE.disc._remotes[path] = entry
    UE.disc._emit("onRemoteDiscovered", entry)
end

function UE.disc._register_script(inst)
    if not UE.util.is_instance(inst) then return end
    local ok, class = pcall(function() return inst.ClassName end)
    if not ok then return end
    if class ~= "Script" and class ~= "LocalScript" and class ~= "ModuleScript" then return end
    local pok, path = pcall(function() return inst:GetFullName() end)
    if not pok then return end
    if UE.disc._scripts[path] then return end
    local entry = {
        instance = inst,
        path = path,
        class = class,
        name = inst.Name,
        first_seen = UE.util.timestamp_ms(),
        requires = {},
        required_by = {},
        obfuscation_suspect = false,
        entropy_score = 0,
    }
    UE.disc._scripts[path] = entry
    UE.disc._emit("onScriptDiscovered", entry)
end

function UE.disc._scan_remotes(root)
    if not UE.config.discover_remotes then return end
    local ok, descendants = pcall(function() return root:GetDescendants() end)
    if not ok then return end
    for _, inst in ipairs(descendants) do
        if UE.disc._is_remote(inst) then UE.disc._register_remote(inst) end
    end
end

function UE.disc._scan_scripts(root)
    if not UE.config.discover_scripts then return end
    local ok, descendants = pcall(function() return root:GetDescendants() end)
    if not ok then return end
    for _, inst in ipairs(descendants) do
        UE.disc._register_script(inst)
    end
end

function UE.disc._track_child_added(inst)
    if not UE.util.is_instance(inst) then return end
    if UE.disc._is_remote(inst) then UE.disc._register_remote(inst) end
    UE.disc._register_script(inst)
    local ok, descendants = pcall(function() return inst:GetDescendants() end)
    if not ok or type(descendants) ~= "table" then return end
    for _, d in ipairs(descendants) do
        if UE.util.is_instance(d) then
            if UE.disc._is_remote(d) then UE.disc._register_remote(d) end
            UE.disc._register_script(d)
        end
    end
end

function UE.disc._start_tree_listener()
    local ok, conn = pcall(function()
        return game.DescendantAdded:Connect(function(inst)
            UE.disc._track_child_added(inst)
        end)
    end)
    if ok then UE.disc._desc_conn = conn end
    local ok2, conn2 = pcall(function()
        return game.DescendantRemoving:Connect(function(inst)
            if not UE.util.is_instance(inst) then return end
            local pok, path = pcall(function() return inst:GetFullName() end)
            if not pok then return end
            UE.disc._remotes[path] = nil
            UE.disc._scripts[path] = nil
        end)
    end)
    if ok2 then UE.disc._desc_remove_conn = conn2 end
end

function UE.disc._hook_require()
    if UE.disc._require_hooked then return true end
    if not UE.exec.has("hook") or not UE.exec.has("newcclosure") then
        return false, "no hook capability"
    end
    local req = rawget(_G, "require")
    if type(req) ~= "function" then return false, "require not found" end
    local wrapper = UE.exec.newcclosure(function(target, ...)
        local result = req(target, ...)
        if UE.util.is_instance(target) then
            local pok, path = pcall(function() return target:GetFullName() end)
            if pok then
                local entry = UE.disc._modules[path]
                if not entry then
                    entry = {
                        instance = target,
                        path = path,
                        first_required = UE.util.timestamp_ms(),
                        require_count = 0,
                        result_type = type(result),
                    }
                    UE.disc._modules[path] = entry
                end
                entry.require_count = entry.require_count + 1
                UE.disc._emit("onModuleRequired", path, result)
            end
        end
        return result
    end)
    local hooked = UE.exec.hook(req, wrapper)
    if hooked then
        UE.disc._require_hooked = true
        return true
    end
    return false, "hook call failed"
end

function UE.disc._build_tag_index()
    if not UE.config.tree_watch_tags then return end
    local CollectionService = game:GetService("CollectionService")
    UE.model._tags = {}
    local known_tags = {}
    pcall(function()
        for _, inst in ipairs(game:GetDescendants()) do
            local tags_ok, tags = pcall(function()
                return CollectionService:GetTags(inst)
            end)
            if tags_ok and type(tags) == "table" then
                local pok, p = pcall(function() return inst:GetFullName() end)
                if pok then
                    UE.model._tags[p] = tags
                    for _, t in ipairs(tags) do known_tags[t] = true end
                end
            end
        end
    end)
    return known_tags
end

function UE.disc._scan_loaded_modules()
    if UE.disc._loaded_modules_scanned then return 0 end
    if not UE.exec.has("getloadedmodules") then return 0 end
    local fn = UE.exec.get("getloadedmodules")
    if type(fn) ~= "function" then return 0 end
    local ok, modules = pcall(fn)
    if not ok or type(modules) ~= "table" then return 0 end
    local count = 0
    for _, mod in ipairs(modules) do
        if UE.util.is_instance(mod) then
            local pok, path = pcall(function() return mod:GetFullName() end)
            if pok then
                if not UE.disc._modules[path] then
                    UE.disc._modules[path] = {
                        instance = mod,
                        path = path,
                        first_required = nil,
                        require_count = 0,
                        result_type = "unknown",
                        source = "getloadedmodules",
                    }
                    UE.disc._emit("onModuleDiscovered", UE.disc._modules[path])
                end
                count = count + 1
            end
        end
    end
    UE.disc._loaded_modules_scanned = true
    return count
end

function UE.disc.rescan_loaded_modules()
    UE.disc._loaded_modules_scanned = false
    return UE.disc._scan_loaded_modules()
end

function UE.disc.get_remote(path) return UE.disc._remotes[path] end
function UE.disc.all_remotes() return UE.disc._remotes end
function UE.disc.all_scripts() return UE.disc._scripts end
function UE.disc.all_modules() return UE.disc._modules end

function UE.disc.record_fire(path, args, caller)
    local entry = UE.disc._remotes[path]
    if not entry then return end
    entry.fires = entry.fires + 1
    entry.last_fire = UE.util.timestamp_ms()
    entry.last_args = UE.config.net_full_values and UE.util.deep_copy(args) or nil
    if caller then entry.callers[caller] = (entry.callers[caller] or 0) + 1 end
end

function UE.disc.record_invoke(path, args, caller)
    local entry = UE.disc._remotes[path]
    if not entry then return end
    entry.invokes = entry.invokes + 1
    entry.last_fire = UE.util.timestamp_ms()
    entry.last_args = UE.config.net_full_values and UE.util.deep_copy(args) or nil
    if caller then entry.callers[caller] = (entry.callers[caller] or 0) + 1 end
end

function UE.disc.flag_obfuscated(path, score)
    local entry = UE.disc._scripts[path]
    if not entry then return end
    entry.obfuscation_suspect = true
    entry.entropy_score = score or entry.entropy_score
    UE.disc._emit("onObfuscationFlagged", entry)
end

function UE.disc.start()
    UE.disc._scan_remotes(game)
    UE.disc._scan_scripts(game)
    UE.disc._scan_loaded_modules()
    UE.disc._start_tree_listener()
    UE.disc._hook_require()
    return true
end

function UE.disc.stop()
    if UE.disc._desc_conn then UE.disc._desc_conn:Disconnect() end
    if UE.disc._desc_remove_conn then UE.disc._desc_remove_conn:Disconnect() end
    UE.disc._require_hooked = false
end

UE.signal = {}
UE.signal._events = {}
UE.signal._graph = {}
UE.signal._connections = {}
UE.signal._signal_meta = {}
UE.signal._hooked = false

function UE.signal._emit(name, ...)
    local subs = UE.signal._events[name]
    if not subs then return end
    for _, cb in next, subs do
        local ok, err = pcall(cb, ...)
        if not ok and UE.config.debug then warn("[UE.signal] listener error: " .. tostring(err)) end
    end
end

function UE.signal.on(name, cb)
    if type(cb) ~= "function" then return end
    UE.signal._events[name] = UE.signal._events[name] or {}
    table.insert(UE.signal._events[name], cb)
end

function UE.signal.off(name, cb)
    local subs = UE.signal._events[name]
    if not subs then return end
    for i = #subs, 1, -1 do
        if subs[i] == cb then table.remove(subs, i) end
    end
end

function UE.signal._signal_id(signal)
    if not signal then return nil end
    local ok, id = pcall(function()
        return tostring(signal):match("0x(%x+)")
    end)
    if ok and id then return id end
    return tostring(signal)
end

function UE.signal._instance_path(inst)
    if not UE.util.is_instance(inst) then return nil end
    local ok, path = pcall(function() return inst:GetFullName() end)
    return ok and path or nil
end

function UE.signal._classify_source(fn)
    if type(fn) ~= "function" then return "unknown" end
    local ok, info = pcall(function()
        return debug and debug.info and debug.info(fn, "sl")
    end)
    if ok and info then
        if type(info) == "string" then return info end
        if type(info) == "table" and info[1] then return info[1] end
    end
    return "unknown"
end

function UE.signal._record_connection(signal, fn, inst, method)
    local sig_id = UE.signal._signal_id(signal)
    if not sig_id then return end
    local path = UE.signal._instance_path(inst) or "?"
    local source = UE.signal._classify_source(fn)
    local entry = {
        signal_id = sig_id,
        path = path,
        method = method,
        source = source,
        fn = fn,
        connected_at = UE.util.timestamp_ms(),
    }
    UE.signal._connections[sig_id] = UE.signal._connections[sig_id] or {}
    table.insert(UE.signal._connections[sig_id], entry)
    UE.signal._graph[path] = UE.signal._graph[path] or {}
    table.insert(UE.signal._graph[path], {
        signal_id = sig_id,
        method = method,
        source = source,
        t = entry.connected_at,
    })
    UE.signal._emit("onConnected", entry)
end

function UE.signal._record_disconnect(signal, fn)
    local sig_id = UE.signal._signal_id(signal)
    if not sig_id then return end
    local list = UE.signal._connections[sig_id]
    if not list then return end
    for i = #list, 1, -1 do
        if list[i].fn == fn then
            local removed = table.remove(list, i)
            UE.signal._emit("onDisconnected", removed)
        end
    end
end

function UE.signal.scan()
    if not UE.exec.has("getconnections") then
        return { scanned = false, reason = "no getconnections capability" }
    end
    local scanned = 0
    for path, remote in pairs(UE.disc._remotes) do
        local inst = remote.instance
        if UE.util.is_instance(inst) then
            local signal_names = {}
            local class_ok, class = pcall(function() return inst.ClassName end)
            if class_ok then
                if class == "RemoteEvent" or class == "UnreliableRemoteEvent" then
                    table.insert(signal_names, "OnClientEvent")
                elseif class == "RemoteFunction" then
                    table.insert(signal_names, "OnClientInvoke")
                elseif class == "BindableEvent" then
                    table.insert(signal_names, "Event")
                end
            end
            for _, sname in ipairs(signal_names) do
                local ok, sig = pcall(function() return inst[sname] end)
                if ok and sig then
                    local conns = UE.exec.getconnections(sig)
                    for _, c in ipairs(conns) do
                        UE.signal._record_connection(sig, c.Function or c["function"] or c, inst, sname)
                    end
                end
            end
            scanned = scanned + 1
        end
    end
    return { scanned = true, count = scanned }
end

function UE.signal.graph() return UE.signal._graph end

function UE.signal.connections(signal)
    local id = UE.signal._signal_id(signal)
    if not id then return {} end
    return UE.signal._connections[id] or {}
end

function UE.signal.by_path(path) return UE.signal._graph[path] or {} end

function UE.signal.summary()
    local total = 0
    local signals = 0
    for _, list in pairs(UE.signal._connections) do
        total = total + #list
        signals = signals + 1
    end
    return {
        total_connections = total,
        unique_signals = signals,
        tracked_instances = UE.util.table_len(UE.signal._signal_meta),
    }
end

function UE.signal.wrap_connect(inst)
    if not UE.exec.has("getrawmeta") then return false, "no metatable" end
    if not UE.util.is_instance(inst) then return false, "not an instance" end
    local mt = UE.exec.getrawmetatable(inst)
    if not mt then return false, "no mt" end
    if UE.signal._signal_meta[inst] then return true end
    if UE.exec.has("setreadonly") then UE.exec.set_readonly(mt, false) end
    local original = mt.__index
    if type(original) ~= "function" then
        if UE.exec.has("setreadonly") then UE.exec.set_readonly(mt, true) end
        return false, "no __index"
    end
    mt.__index = UE.exec.newcclosure(function(self, key, ...)
        local value = original(self, key, ...)
        if type(key) == "string" and (key == "Connect" or key == "Once" or key == "Wait") then
            return UE.exec.newcclosure(function(fn, ...)
                UE.signal._record_connection(value, fn, self, key)
                return value(fn, ...)
            end)
        end
        return value
    end)
    if UE.exec.has("setreadonly") then UE.exec.set_readonly(mt, true) end
    UE.signal._signal_meta[inst] = true
    return true
end

function UE.signal.start()
    UE.signal._graph = {}
    UE.signal._connections = {}
    UE.signal._signal_meta = {}
    UE.signal.scan()
    if UE.exec.has("getrawmeta") and UE.exec.has("newcclosure") then
        pcall(function() UE.signal.wrap_connect(game) end)
    end
    UE.disc.on("onRemoteDiscovered", function(entry)
        if UE.util.is_instance(entry.instance) then
            UE.signal._record_connection(entry.instance.OnClientEvent, function() end, entry.instance, "OnClientEvent")
        end
    end)
    return true
end

function UE.signal.stop()
    UE.signal._graph = {}
    UE.signal._connections = {}
    UE.signal._signal_meta = {}
end

UE.introspect = {}
UE.introspect._events = {}
UE.introspect._hooks = {}
UE.introspect._budget = 0
UE.introspect._budget_max = 64
UE.introspect._frame_time_avg = 0
UE.introspect._last_frame = 0
UE.introspect._hooked_fns = {}

function UE.introspect._emit(name, ...)
    local subs = UE.introspect._events[name]
    if not subs then return end
    for _, cb in next, subs do
        local ok, err = pcall(cb, ...)
        if not ok and UE.config.debug then warn("[UE.introspect] listener error: " .. tostring(err)) end
    end
end

function UE.introspect.on(name, cb)
    if type(cb) ~= "function" then return end
    UE.introspect._events[name] = UE.introspect._events[name] or {}
    table.insert(UE.introspect._events[name], cb)
end

function UE.introspect.off(name, cb)
    local subs = UE.introspect._events[name]
    if not subs then return end
    for i = #subs, 1, -1 do
        if subs[i] == cb then table.remove(subs, i) end
    end
end

function UE.introspect._budget_available()
    return UE.introspect._budget < UE.introspect._budget_max
end

function UE.introspect._consume_budget()
    UE.introspect._budget = UE.introspect._budget + 1
    return UE.introspect._budget
end

function UE.introspect._release_budget()
    UE.introspect._budget = math.max(0, UE.introspect._budget - 1)
end

function UE.introspect._autoscale()
    if not UE.config.hook_autoscale then return end
    local now = UE.util.timestamp_ms()
    if UE.introspect._last_frame > 0 then
        local dt = now - UE.introspect._last_frame
        UE.introspect._frame_time_avg = (UE.introspect._frame_time_avg * 0.9) + (dt * 0.1)
    end
    UE.introspect._last_frame = now
    if UE.introspect._frame_time_avg > 32 then
        UE.introspect._budget_max = UE.util.clamp(UE.introspect._budget_max - 4, 8, UE.config.hook_budget)
    elseif UE.introspect._frame_time_avg < 18 then
        UE.introspect._budget_max = UE.util.clamp(UE.introspect._budget_max + 2, 8, UE.config.hook_budget)
    end
end

function UE.introspect.hook_metatable(obj, hooks)
    if not UE.exec.has("getrawmeta") then return false, "no getrawmetatable" end
    if not UE.introspect._budget_available() then return false, "budget full" end
    local mt = UE.exec.getrawmetatable(obj)
    if not mt then return false, "no metatable" end
    if UE.exec.has("setreadonly") then UE.exec.set_readonly(mt, false) end
    for key, fn in pairs(hooks) do
        local original = mt[key]
        if type(original) == "function" then
            mt[key] = UE.exec.newcclosure(function(...)
                UE.introspect._emit("onMetaCall", key, obj, ...)
                return fn(original, ...)
            end)
        end
    end
    if UE.exec.has("setreadonly") then UE.exec.set_readonly(mt, true) end
    local id = UE.util.uid()
    UE.introspect._hooked_fns[id] = mt
    UE.introspect._consume_budget()
    return true, id
end

function UE.introspect.hook_function(target, hook_fn)
    if type(target) ~= "function" then return false, "not a function" end
    if not UE.introspect._budget_available() then return false, "budget full" end
    local wrapper = UE.exec.newcclosure(function(...)
        UE.introspect._emit("onFunctionCall", target, ...)
        return hook_fn(target, ...)
    end)
    local hooked = UE.exec.hook(target, wrapper)
    if not hooked then return false, "hook failed" end
    local id = UE.util.uid()
    UE.introspect._hooked_fns[id] = { original = target, wrapper = wrapper }
    UE.introspect._consume_budget()
    return true, id
end

function UE.introspect.unhook(id)
    local entry = UE.introspect._hooked_fns[id]
    if not entry then return false end
    UE.introspect._hooked_fns[id] = nil
    UE.introspect._release_budget()
    return true
end

function UE.introspect.hook_namecall(obj)
    if not UE.exec.has("getrawmeta") then return false, "no getrawmetatable" end
    local mt = UE.exec.getrawmetatable(obj)
    if not mt then return false, "no metatable" end
    if UE.exec.has("setreadonly") then UE.exec.set_readonly(mt, false) end
    local original = mt.__namecall
    if type(original) ~= "function" then
        if UE.exec.has("setreadonly") then UE.exec.set_readonly(mt, true) end
        return false, "no __namecall"
    end
    mt.__namecall = UE.exec.newcclosure(function(...)
        local method = getnamecallmethod and getnamecallmethod() or "unknown"
        UE.introspect._emit("onNamecall", obj, method, ...)
        return original(...)
    end)
    if UE.exec.has("setreadonly") then UE.exec.set_readonly(mt, true) end
    return true
end

function UE.introspect.scan_closures(filter)
    if not UE.exec.has("getgc") then return {} end
    local gc = UE.exec.getgc()
    local out = {}
    filter = filter or function() return true end
    for _, item in ipairs(gc) do
        if type(item) == "function" then
            pcall(function()
                if filter(item) then table.insert(out, item) end
            end)
        end
    end
    return out
end

function UE.introspect.find_closures_matching(pattern)
    return UE.introspect.scan_closures(function(fn)
        local info = debug and debug.info and debug.info(fn, "s")
        if info and info:find(pattern) then return true end
        return false
    end)
end

function UE.introspect.get_upvalues(fn) return UE.exec.getupvalues(fn) or {} end
function UE.introspect.get_constants(fn) return UE.exec.getconstants(fn) or {} end

function UE.introspect.read_env(script)
    if UE.exec.has("getsenv") then return UE.exec.getsenv(script) end
    if UE.exec.has("getfenv") then return UE.exec.getfenv(script) end
    return nil
end

function UE.introspect.read_renv() return UE.exec.getrenv() end

function UE.introspect.trace_coroutines()
    if not UE.exec.has("getgc") then return {} end
    local gc = UE.exec.getgc()
    local threads = {}
    for _, item in ipairs(gc) do
        if type(item) == "thread" then table.insert(threads, item) end
    end
    return threads
end

function UE.introspect.summary()
    return {
        budget = UE.introspect._budget,
        budget_max = UE.introspect._budget_max,
        frame_time_avg = UE.util.round(UE.introspect._frame_time_avg, 2),
        hooks_active = UE.util.table_len(UE.introspect._hooked_fns),
    }
end

function UE.introspect.start()
    UE.introspect._budget = 0
    UE.introspect._budget_max = UE.config.hook_budget
    UE.introspect._last_frame = UE.util.timestamp_ms()
    if UE.exec.has("getrawmeta") and UE.exec.has("newcclosure") then
        pcall(function() UE.introspect.hook_namecall(game) end)
    end
    return true
end

function UE.introspect.stop()
    local ids = {}
    for id, _ in pairs(UE.introspect._hooked_fns) do
        table.insert(ids, id)
    end
    for _, id in ipairs(ids) do
        UE.introspect.unhook(id)
    end
    UE.introspect._hooked_fns = {}
    UE.introspect._budget = 0
end

UE.net = {}
UE.net._events = {}
UE.net._log = {}
UE.net._capacity = 10000
UE.net._namecall_hooked = false
UE.net._response_hooked = {}
UE.net._rate_window = {}
UE.net._rate_start = 0
UE.net._call_counts = {}
UE.net.fire_history = {}

function UE.net._emit(name, ...)
    local subs = UE.net._events[name]
    if not subs then return end
    for _, cb in next, subs do
        local ok, err = pcall(cb, ...)
        if not ok and UE.config.debug then warn("[UE.net] listener error: " .. tostring(err)) end
    end
end

function UE.net.on(name, cb)
    if type(cb) ~= "function" then return end
    UE.net._events[name] = UE.net._events[name] or {}
    table.insert(UE.net._events[name], cb)
end

function UE.net.off(name, cb)
    local subs = UE.net._events[name]
    if not subs then return end
    for i = #subs, 1, -1 do
        if subs[i] == cb then table.remove(subs, i) end
    end
end

function UE.net._record(entry)
    table.insert(UE.net._log, entry)
    if #UE.net._log > UE.net._capacity then table.remove(UE.net._log, 1) end
end

function UE.net._rate_tick(kind)
    local now = UE.util.timestamp_ms()
    if UE.net._rate_start == 0 then UE.net._rate_start = now end
    local window_ms = UE.config.net_rate_window * 1000
    if now - UE.net._rate_start > window_ms then
        UE.net._rate_start = now
        UE.net._rate_window = {}
    end
    UE.net._rate_window[kind] = (UE.net._rate_window[kind] or 0) + 1
    UE.net._call_counts[kind] = (UE.net._call_counts[kind] or 0) + 1
end

function UE.net._capture_args(...)
    local n = select("#", ...)
    local args = { n = n }
    for i = 1, n do
        local v = select(i, ...)
        if UE.config.net_full_values and UE.config.net_deep_copy then
            args[i] = UE.util.deep_copy(v)
        else
            args[i] = v
        end
    end
    return args
end

function UE.net._resolve_path(obj)
    if not UE.util.is_instance(obj) then return nil end
    local ok, path = pcall(function() return obj:GetFullName() end)
    return ok and path or nil
end

function UE.net._identify_caller()
    local info = nil
    if debug and debug.info then
        local ok, a, b = pcall(function() return debug.info(3, "sl") end)
        if ok then info = { source = a, line = b } end
    end
    return info
end

function UE.net._hook_namecall()
    if UE.net._namecall_hooked then return true end
    if not UE.exec.has("getrawmeta") then return false, "no metatable access" end
    local mt = UE.exec.getrawmetatable(game)
    if not mt then return false, "no metatable" end
    if UE.exec.has("setreadonly") then UE.exec.set_readonly(mt, false) end
    local original = mt.__namecall
    if type(original) ~= "function" then
        if UE.exec.has("setreadonly") then UE.exec.set_readonly(mt, true) end
        return false, "no __namecall"
    end
    mt.__namecall = UE.exec.newcclosure(function(...)
        local self = ...
        local method = getnamecallmethod and getnamecallmethod() or nil
        if method == "FireServer" or method == "InvokeServer" then
            local path = UE.net._resolve_path(self)
            if path then
                local args = UE.net._capture_args(select(2, ...))
                local caller = UE.net._identify_caller()
                local entry = {
                    path = path,
                    method = method,
                    args = args,
                    caller = caller,
                    time = UE.util.timestamp_ms(),
                }
                UE.net._record(entry)
                UE.net._rate_tick(method)
                if method == "FireServer" then
                    UE.disc.record_fire(path, args, caller and caller.source or nil)
                else
                    UE.disc.record_invoke(path, args, caller and caller.source or nil)
                end
                UE.net._emit("onRemoteFired", entry)
            end
        end
        return original(...)
    end)
    if UE.exec.has("setreadonly") then UE.exec.set_readonly(mt, true) end
    UE.net._namecall_hooked = true
    return true
end

function UE.net._hook_response(remote_instance)
    if not UE.util.is_instance(remote_instance) then return end
    local path = UE.net._resolve_path(remote_instance)
    if not path or UE.net._response_hooked[path] then return end
    if not UE.exec.has("getconnections") then return end
    local ok, signal = pcall(function()
        if remote_instance.ClassName == "RemoteEvent" then
            return remote_instance.OnClientEvent
        elseif remote_instance.ClassName == "UnreliableRemoteEvent" then
            return remote_instance.OnClientEvent
        elseif remote_instance.ClassName == "RemoteFunction" then
            return remote_instance.OnClientInvoke
        end
    end)
    if not ok or not signal then return end
    local conns = UE.exec.getconnections(signal)
    for _, conn in ipairs(conns) do
        if type(conn.Function) == "function" then
            local original = conn.Function
            local wrapper = UE.exec.newcclosure(function(...)
                local args = UE.net._capture_args(...)
                local entry = {
                    path = path,
                    method = "OnClientEvent",
                    args = args,
                    caller = nil,
                    time = UE.util.timestamp_ms(),
                }
                UE.net._record(entry)
                UE.net._rate_tick("OnClientEvent")
                UE.net._emit("onRemoteResponse", entry)
                return original(...)
            end)
            pcall(function() conn.Function = wrapper end)
        end
    end
    UE.net._response_hooked[path] = true
end

function UE.net.attach_to_all()
    for path, entry in pairs(UE.disc._remotes) do
        UE.net._hook_response(entry.instance)
    end
end

function UE.net.log(limit)
    limit = limit or #UE.net._log
    local out = {}
    local start = math.max(1, #UE.net._log - limit + 1)
    for i = start, #UE.net._log do
        table.insert(out, UE.net._log[i])
    end
    return out
end

function UE.net.find_by_path(path)
    local out = {}
    for _, entry in ipairs(UE.net._log) do
        if entry.path == path then table.insert(out, entry) end
    end
    return out
end

function UE.net.stats()
    return {
        total_logged = #UE.net._log,
        window_counts = UE.util.deep_copy(UE.net._rate_window),
        lifetime_counts = UE.util.deep_copy(UE.net._call_counts),
    }
end

function UE.net.clear()
    UE.net._log = {}
    UE.net._rate_window = {}
end

function UE.net.fire(target, method, ...)
    if not UE.exec.has("firesignal") then return false, "no firesignal capability" end
    local signal = nil
    if type(target) == "userdata" or type(target) == "table" then
        local ok, sig = pcall(function() return target[method] end)
        if ok then signal = sig end
    else
        signal = target
    end
    if not signal then return false, "invalid signal target" end
    local fn = UE.exec.get("firesignal")
    local ok, err = pcall(fn, signal, ...)
    if not ok then return false, err end
    UE.net._emit("onSignalFired", {
        signal = signal,
        method = method,
        args = { ... },
        t = UE.util.timestamp_ms(),
    })
    return true
end

function UE.net.fire_remote(remote, method, ...)
    if not UE.util.is_instance(remote) then return false, "not an instance" end
    local valid_methods = {
        RemoteEvent = { "OnClientEvent", "OnServerEvent" },
        UnreliableRemoteEvent = { "OnClientEvent", "OnServerEvent" },
        RemoteFunction = { "OnClientInvoke", "OnServerInvoke" },
        BindableEvent = { "Event" },
        BindableFunction = { "OnInvoke" },
    }
    local class_ok, class = pcall(function() return remote.ClassName end)
    if not class_ok or not valid_methods[class] then return false, "unsupported class" end
    local allowed = false
    for _, m in ipairs(valid_methods[class]) do
        if m == method then allowed = true break end
    end
    if not allowed then return false, "invalid method for class" end
    return UE.net.fire(remote, method, ...)
end

function UE.net.simulate(remote, ...)
    if not UE.util.is_instance(remote) then return false, "not an instance" end
    local class_ok, class = pcall(function() return remote.ClassName end)
    if not class_ok then return false end
    if class == "RemoteEvent" or class == "UnreliableRemoteEvent" then
        return UE.net.fire(remote, "OnClientEvent", ...)
    end
    if class == "RemoteFunction" then
        return UE.net.fire(remote, "OnClientInvoke", ...)
    end
    if class == "BindableEvent" then
        return UE.net.fire(remote, "Event", ...)
    end
    return false, "unsupported class"
end

UE.net.on("onSignalFired", function(entry)
    table.insert(UE.net.fire_history, entry)
    while #UE.net.fire_history > 200 do
        table.remove(UE.net.fire_history, 1)
    end
end)

function UE.net.start()
    UE.net._hook_namecall()
    UE.net.attach_to_all()
    return true
end

function UE.net.stop()
    UE.net._namecall_hooked = false
    UE.net._response_hooked = {}
end

UE.deob = {}
UE.deob._events = {}
UE.deob._signatures = {
    { name = "Luraph", markers = { "LPH_", "LPH!", "lph_" } },
    { name = "Moonsec", markers = { "moonsec", "MoonSec", "MOONSEC" } },
    { name = "IronBrew", markers = { "ironbrew", "IronBrew", "IB2" } },
    { name = "PSU", markers = { "PSU", "psu_", "PSU_" } },
    { name = "AztupBrew", markers = { "aztup", "Aztup" } },
    { name = "Luarmor", markers = { "Luarmor", "luarmor" } },
    { name = "Prometheus", markers = { "prometheus", "Prometheus" } },
    { name = "Hercules", markers = { "Hercules", "hercules" } },
}

function UE.deob._emit(name, ...)
    local subs = UE.deob._events[name]
    if not subs then return end
    for _, cb in next, subs do
        local ok, err = pcall(cb, ...)
        if not ok and UE.config.debug then warn("[UE.deob] listener error: " .. tostring(err)) end
    end
end

function UE.deob.on(name, cb)
    if type(cb) ~= "function" then return end
    UE.deob._events[name] = UE.deob._events[name] or {}
    table.insert(UE.deob._events[name], cb)
end

function UE.deob.off(name, cb)
    local subs = UE.deob._events[name]
    if not subs then return end
    for i = #subs, 1, -1 do
        if subs[i] == cb then table.remove(subs, i) end
    end
end

function UE.deob.entropy(str)
    if type(str) ~= "string" or #str == 0 then return 0 end
    local counts = {}
    local total = #str
    for i = 1, total do
        local b = string.byte(str, i)
        counts[b] = (counts[b] or 0) + 1
    end
    local h = 0
    for _, c in pairs(counts) do
        local p = c / total
        h = h - (p * math.log(p) / math.log(2))
    end
    return h
end

function UE.deob.byte_entropy(str)
    if type(str) ~= "string" or #str == 0 then return 0 end
    local printable = 0
    for i = 1, #str do
        local b = string.byte(str, i)
        if b >= 32 and b <= 126 then printable = printable + 1 end
    end
    return 1 - (printable / #str)
end

function UE.deob.detect_signature(source)
    if type(source) ~= "string" then return nil end
    for _, sig in ipairs(UE.deob._signatures) do
        for _, marker in ipairs(sig.markers) do
            if source:find(marker, 1, true) then return sig.name, marker end
        end
    end
    return nil
end

function UE.deob.detect_anti_tamper(source)
    if type(source) ~= "string" then return {} end
    local flags = {}
    local patterns = {
        { name = "getfenv_probe", pattern = "getfenv" },
        { name = "debug_info", pattern = "debug%.info" },
        { name = "string_char_chain", pattern = "string%.char" },
        { name = "loadstring_wrap", pattern = "loadstring" },
        { name = "env_compare", pattern = "getfenv%(0%)" },
        { name = "bytecode_load", pattern = "load%(string" },
        { name = "os_clock_check", pattern = "os%.clock" },
        { name = "tick_check", pattern = "tick%(" },
    }
    for _, p in ipairs(patterns) do
        if source:find(p.pattern) then table.insert(flags, p.name) end
    end
    return flags
end

function UE.deob.detect(instance)
    if not UE.util.is_instance(instance) then
        return { is_obfuscated = false, reason = "not an instance" }
    end
    local source = UE.exec.decompile(instance)
    local bytecode = UE.exec.getscriptbytecode(instance)
    local pok, path = pcall(function() return instance:GetFullName() end)
    path = pok and path or "?"
    local result = {
        path = path,
        has_source = source ~= nil,
        has_bytecode = bytecode ~= nil,
        entropy_source = 0,
        entropy_bytecode = 0,
        byte_entropy_source = 0,
        signature = nil,
        signature_marker = nil,
        anti_tamper = {},
        is_obfuscated = false,
    }
    if source then
        result.entropy_source = UE.util.round(UE.deob.entropy(source), 3)
        result.byte_entropy_source = UE.util.round(UE.deob.byte_entropy(source), 3)
        result.signature, result.signature_marker = UE.deob.detect_signature(source)
        result.anti_tamper = UE.deob.detect_anti_tamper(source)
    end
    if bytecode then
        result.entropy_bytecode = UE.util.round(UE.deob.entropy(bytecode), 3)
    end
    if result.signature then
        result.is_obfuscated = true
        result.reason = "signature:" .. result.signature
    elseif result.entropy_source > 5.8 and result.byte_entropy_source > 0.35 then
        result.is_obfuscated = true
        result.reason = "entropy"
    elseif #result.anti_tamper >= 4 then
        result.is_obfuscated = true
        result.reason = "anti_tamper"
    end
    UE.deob._emit("onDetection", result)
    return result
end

function UE.deob._strip_whitespace_artifacts(src)
    src = src:gsub("[\t ]+", " ")
    src = src:gsub("\r\n", "\n")
    src = src:gsub("\n\n+", "\n")
    return src
end

function UE.deob._strip_comments(src)
    src = src:gsub("%-%-%[%[.-%]%]", "")
    src = src:gsub("%-%-[^\n]*", "")
    return src
end

function UE.deob._rename_symbols(src)
    local map = {}
    local counter = 0
    src = src:gsub("_(0x%x+)", function(m)
        if not map[m] then
            counter = counter + 1
            map[m] = "v" .. counter
        end
        return map[m]
    end)
    src = src:gsub("l_%d+", function(m)
        if not map[m] then
            counter = counter + 1
            map[m] = "local" .. counter
        end
        return map[m]
    end)
    return src, map
end

function UE.deob._collapse_cff(src)
    local hits = 0
    src = src:gsub("while%s+true%s+do%s+if%s+(.-)%s+then%s+break%s+end%s+end", function(cond)
        hits = hits + 1
        return "--[[ cff-removed: " .. cond .. " ]]"
    end)
    return src, hits
end

function UE.deob._fold_constants(src)
    if type(src) ~= "string" then return src, 0 end
    local iterations = 0
    local prev
    local safe_env = {
        math = math,
        string = string,
        table = table,
        tostring = tostring,
        tonumber = tonumber,
        select = select,
        type = type,
        pairs = pairs,
        ipairs = ipairs,
    }
    repeat
        prev = src
        src = src:gsub("(%b())", function(inner)
            local expr = inner:sub(2, -2)
            if not expr:find("[%w_]") then return inner end
            if expr:find("[=;{}]") then return inner end
            if expr:find("function") then return inner end
            if expr:find("return") then return inner end
            local fn = loadstring("return " .. expr)
            if not fn then return inner end
            if setfenv then setfenv(fn, safe_env) end
            local ok, val = pcall(fn)
            if not ok then return inner end
            local t = type(val)
            if t == "number" or t == "boolean" then return tostring(val) end
            if t == "string" and #val < 4096 then return string.format("%q", val) end
            return inner
        end)
        iterations = iterations + 1
    until src == prev or iterations > 8
    return src, iterations
end

function UE.deob._extract_string_decryptor(src)
    local candidates = {}
    local pattern = "function%s+([%w_]+)%s*%(%s*[%w_]*%s*%)%s*(.-)end"
    for name, body in src:gmatch(pattern) do
        if #body < 500 then
            if body:find("string%.char") or body:find("string%.byte")
                or body:find("bit32%.") or body:find("bxor") or body:find("band") then
                table.insert(candidates, { name = name, body = body })
            end
        end
    end
    return candidates
end

function UE.deob._try_decrypt(candidate, encoded)
    if type(candidate) ~= "table" or type(encoded) ~= "string" then return nil end
    local source = "local function " .. candidate.name .. "(s) " .. candidate.body .. " end return " .. candidate.name
    local fn = loadstring(source)
    if not fn then return nil end
    local sandbox = {
        string = string, table = table, math = math,
        bit32 = bit32, bit = bit,
        tostring = tostring, tonumber = tonumber, type = type,
        select = select, pairs = pairs, ipairs = ipairs, next = next,
        rawget = rawget, rawset = rawset,
        setmetatable = setmetatable, getmetatable = getmetatable,
        unpack = unpack or table.unpack,
    }
    pcall(function() if setfenv then setfenv(fn, sandbox) end end)
    local ok_load, decryptor = pcall(fn)
    if not ok_load or type(decryptor) ~= "function" then
        fn = loadstring(source)
        if not fn then return nil end
        local ok2, decryptor2 = pcall(fn)
        if not ok2 or type(decryptor2) ~= "function" then return nil end
        decryptor = decryptor2
    end
    local ok_run, result = pcall(decryptor, encoded)
    if ok_run then return result end
    fn = loadstring(source)
    if not fn then return nil end
    local ok_full, decryptor_full = pcall(fn)
    if not ok_full or type(decryptor_full) ~= "function" then return nil end
    local ok_final, result_final = pcall(decryptor_full, encoded)
    if ok_final then return result_final end
    return nil
end

function UE.deob._confidence_map(original, reconstructed)
    local new_lines = {}
    for line in reconstructed:gmatch("[^\n]+") do table.insert(new_lines, line) end
    local map = {}
    for i, line in ipairs(new_lines) do
        local conf = 0.5
        if line:find("^%s*%-%-%[%[") then conf = 0.9
        elseif line:find("^%s*$") then conf = 1.0
        elseif line:find("local") and #line < 120 then conf = 0.75 end
        map[i] = conf
    end
    return map
end

function UE.deob.scan_all()
    local results = {}
    for path, entry in pairs(UE.disc._scripts) do
        local det = UE.deob.detect(entry.instance)
        if det.is_obfuscated then
            table.insert(results, det)
            UE.disc.flag_obfuscated(path, det.entropy_source)
        end
    end
    return results
end

function UE.deob.auto_watch()
    if not UE.config.deob_auto then return end
    UE.disc.on("onScriptDiscovered", function(entry)
        local det = UE.deob.detect(entry.instance)
        if det.is_obfuscated then
            UE.disc.flag_obfuscated(entry.path, det.entropy_source)
            UE.deob._emit("onAutoTrigger", entry.path, det)
        end
    end)
end

function UE.deob.dump(name, instance)
    local rec = UE.deob.reconstruct(instance)
    if not rec.success then return false, rec.reason end
    local payload = {
        path = rec.path,
        stages = rec.stages,
        confidence = rec.confidence,
        source = rec.source,
        rename_map = rec.rename_map,
    }
    return UE.file.dump(name, UE.util.json_encode(payload), "dump")
end

function UE.deob.start()
    UE.deob.auto_watch()
    return true
end

function UE.deob.stop()
    UE.deob._events = {}
end

UE.deob.dynamic = {}
UE.deob.dynamic._events = {}
UE.deob.dynamic._captured = {}
UE.deob.dynamic._active = false
UE.deob.dynamic._originals = {}

function UE.deob.dynamic._emit(name, ...)
    local subs = UE.deob.dynamic._events[name]
    if not subs then return end
    for _, cb in next, subs do
        local ok, err = pcall(cb, ...)
        if not ok and UE.config.debug then warn("[UE.deob.dynamic] listener error: " .. tostring(err)) end
    end
end

function UE.deob.dynamic.on(name, cb)
    if type(cb) ~= "function" then return end
    UE.deob.dynamic._events[name] = UE.deob.dynamic._events[name] or {}
    table.insert(UE.deob.dynamic._events[name], cb)
end

function UE.deob.dynamic._capture_chunk(source, tag, extra)
    if type(source) ~= "string" then return end
    local entry = {
        t = UE.util.timestamp_ms(),
        tag = tag or "loadstring",
        size = #source,
        source = source,
        extra = extra,
    }
    table.insert(UE.deob.dynamic._captured, entry)
    while #UE.deob.dynamic._captured > 500 do
        table.remove(UE.deob.dynamic._captured, 1)
    end
    UE.deob.dynamic._emit("onChunkCaptured", entry)
end

function UE.deob.dynamic.hook_loadstring()
    if not UE.exec.has("hook") or not UE.exec.has("newcclosure") then
        return false, "no hook capability"
    end
    if UE.deob.dynamic._originals.loadstring then return true end
    local original = rawget(_G, "loadstring")
    if type(original) ~= "function" then return false, "loadstring missing" end
    UE.deob.dynamic._originals.loadstring = original
    local wrapper = UE.exec.newcclosure(function(source, chunkname, ...)
        if type(source) == "string" then
            UE.deob.dynamic._capture_chunk(source, "loadstring", chunkname)
        end
        return original(source, chunkname, ...)
    end)
    return UE.exec.hook(original, wrapper) ~= nil
end

function UE.deob.dynamic.hook_load()
    if not UE.exec.has("hook") or not UE.exec.has("newcclosure") then return false end
    if UE.deob.dynamic._originals.load then return true end
    local original = rawget(_G, "load")
    if type(original) ~= "function" then return false end
    UE.deob.dynamic._originals.load = original
    local wrapper = UE.exec.newcclosure(function(chunk, chunkname, ...)
        if type(chunk) == "string" then
            UE.deob.dynamic._capture_chunk(chunk, "load", chunkname)
        end
        return original(chunk, chunkname, ...)
    end)
    return UE.exec.hook(original, wrapper) ~= nil
end

function UE.deob.dynamic.hook_string_char()
    if not UE.exec.has("getrawmeta") then return false end
    local mt = UE.exec.getrawmetatable(string)
    if not mt then return false end
    if UE.deob.dynamic._originals.string_char then return true end
    if UE.exec.has("setreadonly") then UE.exec.set_readonly(mt, false) end
    local original = mt.__index
    if type(original) ~= "function" then
        if UE.exec.has("setreadonly") then UE.exec.set_readonly(mt, true) end
        return false
    end
    UE.deob.dynamic._originals.string_char = original
    mt.__index = UE.exec.newcclosure(function(self, key, ...)
        local val = original(self, key, ...)
        if key == "char" then UE.deob.dynamic._emit("onStringChar", { ... }) end
        return val
    end)
    if UE.exec.has("setreadonly") then UE.exec.set_readonly(mt, true) end
    return true
end

function UE.deob.dynamic.hook_env()
    if not UE.exec.has("hook") or not UE.exec.has("newcclosure") then return false end
    if UE.deob.dynamic._originals.getfenv then return true end
    local original = rawget(_G, "getfenv")
    if type(original) ~= "function" then return false end
    UE.deob.dynamic._originals.getfenv = original
    local wrapper = UE.exec.newcclosure(function(target, ...)
        UE.deob.dynamic._emit("onEnvAccess", target)
        return original(target, ...)
    end)
    return UE.exec.hook(original, wrapper) ~= nil
end

function UE.deob.dynamic.captured() return UE.deob.dynamic._captured end

function UE.deob.dynamic.find_pattern(pattern)
    local out = {}
    for _, entry in ipairs(UE.deob.dynamic._captured) do
        if entry.source:find(pattern) then table.insert(out, entry) end
    end
    return out
end

function UE.deob.dynamic.reconstruct_from_capture()
    local results = {}
    for _, entry in ipairs(UE.deob.dynamic._captured) do
        local ok, det = pcall(function() return UE.deob.detect_signature(entry.source) end)
        if ok and det then
            table.insert(results, {
                source = entry.source,
                signature = det,
                t = entry.t,
                size = entry.size,
            })
        end
    end
    return results
end

function UE.deob.dynamic.start()
    if UE.deob.dynamic._active then return true end
    UE.deob.dynamic.hook_loadstring()
    UE.deob.dynamic.hook_load()
    UE.deob.dynamic.hook_env()
    UE.deob.dynamic.hook_string_char()
    UE.deob.dynamic._active = true
    return true
end

function UE.deob.dynamic.stop()
    UE.deob.dynamic._active = false
end

UE.deob.cfg = {}
UE.deob.cfg._jumps = {
    JMP = true, FORNPREP = true, FORNLOOP = true,
    FORGPREP = true, FORGLOOP = true, FORGPREP_NEXT = true,
    FORGPREP_INEXT = true, FORGLOOP_NEXT = true,
}
UE.deob.cfg._conditional_jumps = {
    TEST = true, TESTSET = true, EQ = true, LT = true, LE = true,
    EQK = true, EQI = true, LTK = true, LEK = true, LTI = true, LEI = true,
    JUMPIF = true, JUMPIFNOT = true,
    JUMPIFEQ = true, JUMPIFNOTEQ = true, JUMPIFLT = true, JUMPIFNOTLT = true,
    JUMPIFLE = true, JUMPIFNOTLE = true,
    JUMPIFEQK = true, JUMPIFNOTEQK = true,
    JUMPXEQKNIL = true, JUMPXEQKB = true, JUMPXEQKN = true, JUMPXEQKS = true,
}
UE.deob.cfg._returns = { RETURN = true, TAILCALL = true }

function UE.deob.cfg.parse_disassembly(text)
    if type(text) ~= "string" then return {} end
    local instructions = {}
    local index = 0
    for line in text:gmatch("[^\n]+") do
        local addr, op, operand = line:match("^%s*(%d+)%s+([%u_]+)%s*(.*)$")
        if not op then
            op, operand = line:match("^%s*([%u_]+)%s*(.*)$")
        end
        if op then
            index = index + 1
            table.insert(instructions, {
                idx = index,
                addr = tonumber(addr) or index,
                op = op,
                operand = operand or "",
            })
        end
    end
    return instructions
end

function UE.deob.cfg.target_addr(operand)
    if type(operand) ~= "string" then return nil end
    return tonumber(operand:match("^(%-?%d+)"))
end

function UE.deob.cfg.build(instructions)
    if type(instructions) ~= "table" or #instructions == 0 then
        return { nodes = {}, edges = {}, entry = nil }
    end
    local addr_to_idx = {}
    for i, ins in ipairs(instructions) do addr_to_idx[ins.addr] = i end
    local nodes = {}
    local edges = {}
    for i, ins in ipairs(instructions) do
        nodes[i] = {
            idx = i, addr = ins.addr, op = ins.op, operand = ins.operand,
            successors = {}, predecessors = {},
        }
    end
    for i, ins in ipairs(instructions) do
        local next_i = i + 1
        local succ = {}
        if UE.deob.cfg._returns[ins.op] then
            succ = {}
        elseif UE.deob.cfg._jumps[ins.op] then
            local target = UE.deob.cfg.target_addr(ins.operand)
            if target and addr_to_idx[target] then table.insert(succ, addr_to_idx[target]) end
            if ins.op ~= "JMP" and next_i <= #instructions then table.insert(succ, next_i) end
        elseif UE.deob.cfg._conditional_jumps[ins.op] then
            if next_i <= #instructions then table.insert(succ, next_i) end
            local target = UE.deob.cfg.target_addr(ins.operand)
            if target and addr_to_idx[target] then table.insert(succ, addr_to_idx[target]) end
        else
            if next_i <= #instructions then table.insert(succ, next_i) end
        end
        nodes[i].successors = succ
        for _, s in ipairs(succ) do
            table.insert(edges, { from = i, to = s })
            table.insert(nodes[s].predecessors, i)
        end
    end
    return { nodes = nodes, edges = edges, entry = 1, count = #instructions }
end

function UE.deob.cfg.find_loops(cfg)
    if not cfg or not cfg.nodes then return {} end
    local loops = {}
    local visited = {}
    local stack = {}
    local on_stack = {}
    local function dfs(node)
        visited[node] = true
        on_stack[node] = true
        table.insert(stack, node)
        local n = cfg.nodes[node]
        if not n then return end
        for _, s in ipairs(n.successors or {}) do
            if on_stack[s] then
                local loop_body = {}
                local found = false
                for _, st in ipairs(stack) do
                    if st == s then found = true end
                    if found then table.insert(loop_body, st) end
                end
                table.insert(loops, { head = s, body = loop_body })
            elseif not visited[s] then
                dfs(s)
            end
        end
        table.remove(stack)
        on_stack[node] = false
    end
    for i = 1, (cfg.count or 0) do
        if not visited[i] then dfs(i) end
    end
    return loops
end

function UE.deob.cfg.annotate(cfg)
    if not cfg or not cfg.nodes then return cfg end
    for _, node in pairs(cfg.nodes) do
        local op = node.op
        if op == "RETURN" or op == "TAILCALL" then node.meaning = "exit"
        elseif UE.deob.cfg._conditional_jumps[op] then node.meaning = "branch"
        elseif op == "JMP" then node.meaning = "jump"
        elseif op:find("CALL") then node.meaning = "call"
        elseif op:find("GET") or op:find("SET") then node.meaning = "access"
        elseif op:find("LOAD") or op:find("MOVE") then node.meaning = "assign"
        elseif op:find("FOR") then node.meaning = "loop"
        else node.meaning = "other" end
    end
    return cfg
end

function UE.deob.cfg.build_from_instance(instance)
    local dis = UE.exec.disassemble(instance)
    if not dis then return { success = false, reason = "no disassemble capability" } end
    local instructions = UE.deob.cfg.parse_disassembly(dis)
    local cfg = UE.deob.cfg.build(instructions)
    cfg = UE.deob.cfg.annotate(cfg)
    cfg.loops = UE.deob.cfg.find_loops(cfg)
    local pok, path = pcall(function() return instance:GetFullName() end)
    cfg.path = pok and path or "?"
    cfg.success = true
    return cfg
end

function UE.deob.cfg.export(cfg)
    if not cfg or not cfg.nodes then return nil end
    local out = { path = cfg.path, count = cfg.count, nodes = {}, edges = cfg.edges or {} }
    for i, node in pairs(cfg.nodes) do
        table.insert(out.nodes, {
            idx = i, op = node.op, operand = node.operand,
            successors = node.successors, predecessors = node.predecessors,
            meaning = node.meaning,
        })
    end
    return out
end

UE.deob.bytecode = {}
UE.deob.bytecode._reader = {}

function UE.deob.bytecode._new_reader(data)
    return { data = data, pos = 1, len = #data }
end

function UE.deob.bytecode._read_byte(r)
    if r.pos > r.len then return nil end
    local b = string.byte(r.data, r.pos)
    r.pos = r.pos + 1
    return b
end

function UE.deob.bytecode._read_bytes(r, n)
    if r.pos + n - 1 > r.len then return nil end
    local s = r.data:sub(r.pos, r.pos + n - 1)
    r.pos = r.pos + n
    return s
end

function UE.deob.bytecode._read_varint(r)
    local result = 0
    local shift = 0
    for _ = 1, 5 do
        local b = UE.deob.bytecode._read_byte(r)
        if not b then return nil end
        result = result + ((b % 128) * (2 ^ shift))
        if b < 128 then return result end
        shift = shift + 7
    end
    return result
end

function UE.deob.bytecode._read_string(r)
    local n = UE.deob.bytecode._read_varint(r)
    if not n then return nil end
    if n == 0 then return "" end
    return UE.deob.bytecode._read_bytes(r, n)
end

UE.deob.bytecode.OPCODES = {
    [0] = { name = "NOP", format = "ABC" },
    [1] = { name = "BREAK", format = "ABC" },
    [2] = { name = "LOADNIL", format = "A" },
    [3] = { name = "LOADB", format = "AB" },
    [4] = { name = "LOADN", format = "AB" },
    [5] = { name = "LOADK", format = "AD" },
    [6] = { name = "MOVE", format = "AB" },
    [7] = { name = "GETGLOBAL", format = "AC" },
    [8] = { name = "SETGLOBAL", format = "AC" },
    [9] = { name = "GETUPVAL", format = "AB" },
    [10] = { name = "SETUPVAL", format = "AB" },
    [11] = { name = "CLOSEUPVALS", format = "A" },
    [12] = { name = "GETIMPORT", format = "AD" },
    [13] = { name = "GETTABLE", format = "ABC" },
    [14] = { name = "SETTABLE", format = "ABC" },
    [15] = { name = "GETTABLEKS", format = "ABC" },
    [16] = { name = "SETTABLEKS", format = "ABC" },
    [17] = { name = "GETTABLEN", format = "ABC" },
    [18] = { name = "SETTABLEN", format = "ABC" },
    [19] = { name = "NEWCLOSURE", format = "AD" },
    [20] = { name = "NAMECALL", format = "ABC" },
    [21] = { name = "CALL", format = "ABC" },
    [22] = { name = "RETURN", format = "AB" },
    [23] = { name = "JUMP", format = "D" },
    [24] = { name = "JUMPBACK", format = "D" },
    [25] = { name = "JUMPIF", format = "AD" },
    [26] = { name = "JUMPIFNOT", format = "AD" },
    [27] = { name = "JUMPIFEQ", format = "AD" },
    [28] = { name = "JUMPIFNOTEQ", format = "AD" },
    [29] = { name = "JUMPIFLT", format = "AD" },
    [30] = { name = "JUMPIFNOTLT", format = "AD" },
    [31] = { name = "JUMPIFLE", format = "AD" },
    [32] = { name = "JUMPIFNOTLE", format = "AD" },
    [33] = { name = "JUMPIFEQK", format = "AD" },
    [34] = { name = "JUMPIFNOTEQK", format = "AD" },
    [35] = { name = "ADD", format = "ABC" },
    [36] = { name = "SUB", format = "ABC" },
    [37] = { name = "MUL", format = "ABC" },
    [38] = { name = "DIV", format = "ABC" },
    [39] = { name = "MOD", format = "ABC" },
    [40] = { name = "POW", format = "ABC" },
    [41] = { name = "ADDK", format = "ABC" },
    [42] = { name = "SUBK", format = "ABC" },
    [43] = { name = "MULK", format = "ABC" },
    [44] = { name = "DIVK", format = "ABC" },
    [45] = { name = "MODK", format = "ABC" },
    [46] = { name = "POWK", format = "ABC" },
    [47] = { name = "AND", format = "ABC" },
    [48] = { name = "OR", format = "ABC" },
    [49] = { name = "ANDK", format = "ABC" },
    [50] = { name = "ORK", format = "ABC" },
    [51] = { name = "CONCAT", format = "ABC" },
    [52] = { name = "NOT", format = "AB" },
    [53] = { name = "MINUS", format = "AB" },
    [54] = { name = "LENGTH", format = "AB" },
    [55] = { name = "NEWTABLE", format = "AB" },
    [56] = { name = "DUPTABLE", format = "AD" },
    [57] = { name = "SETLIST", format = "ABC" },
    [58] = { name = "FORNPREP", format = "AD" },
    [59] = { name = "FORNLOOP", format = "AD" },
    [60] = { name = "FORGLOOP", format = "AD" },
    [61] = { name = "FORGPREP_INEXT", format = "AD" },
    [62] = { name = "FORGPREP_NEXT", format = "AD" },
    [63] = { name = "FASTCALL2K", format = "ABC" },
    [64] = { name = "FASTCALL2", format = "ABC" },
    [65] = { name = "COVERAGE", format = "A" },
    [66] = { name = "CAPTURE", format = "AB" },
    [67] = { name = "SUBK", format = "ABC" },
    [68] = { name = "DIVK", format = "ABC" },
    [69] = { name = "IDIV", format = "ABC" },
    [70] = { name = "IDIVK", format = "ABC" },
    [71] = { name = "MODK", format = "ABC" },
    [72] = { name = "POWK", format = "ABC" },
    [73] = { name = "GETVARARGS", format = "AB" },
    [74] = { name = "SETLIST", format = "ABC" },
    [75] = { name = "FORGLOOP", format = "AD" },
    [76] = { name = "JUMPX", format = "E" },
    [77] = { name = "FASTCALL", format = "ABC" },
    [88] = { name = "JUMPXEQKNIL", format = "AD" },
    [89] = { name = "JUMPXEQKB", format = "AD" },
    [90] = { name = "JUMPXEQKN", format = "AD" },
    [91] = { name = "JUMPXEQKS", format = "AD" },
}

function UE.deob.bytecode._read_instruction(r, offset_accum)
    local opcode = UE.deob.bytecode._read_byte(r)
    if not opcode then return nil end
    local meta = UE.deob.bytecode.OPCODES[opcode]
    if not meta then
        return { offset = offset_accum, opcode = opcode, op = "UNKNOWN_" .. tostring(opcode), A = 0, B = 0, C = 0, D = 0, format = "?" }
    end
    local fmt = meta.format
    local ins = { offset = offset_accum, opcode = opcode, op = meta.name, format = fmt }
    if fmt == "ABC" then
        ins.A = UE.deob.bytecode._read_byte(r)
        ins.B = UE.deob.bytecode._read_byte(r)
        ins.C = UE.deob.bytecode._read_byte(r)
    elseif fmt == "AB" then
        ins.A = UE.deob.bytecode._read_byte(r)
        ins.B = UE.deob.bytecode._read_byte(r)
        ins.C = 0
    elseif fmt == "AC" then
        ins.A = UE.deob.bytecode._read_byte(r)
        ins.B = 0
        ins.C = UE.deob.bytecode._read_byte(r)
    elseif fmt == "A" then
        ins.A = UE.deob.bytecode._read_byte(r)
        ins.B = 0
        ins.C = 0
    elseif fmt == "AD" then
        ins.A = UE.deob.bytecode._read_byte(r)
        ins.B = 0
        ins.C = 0
        local d1 = UE.deob.bytecode._read_byte(r)
        local d2 = UE.deob.bytecode._read_byte(r)
        ins.D = (d1 and d2) and (d1 + d2 * 256) or 0
    elseif fmt == "D" then
        ins.A = 0
        ins.B = 0
        ins.C = 0
        local d1 = UE.deob.bytecode._read_byte(r)
        local d2 = UE.deob.bytecode._read_byte(r)
        ins.D = (d1 and d2) and (d1 + d2 * 256) or 0
    elseif fmt == "E" then
        ins.A = 0
        ins.B = 0
        ins.C = 0
        local d1 = UE.deob.bytecode._read_byte(r)
        local d2 = UE.deob.bytecode._read_byte(r)
        local d3 = UE.deob.bytecode._read_byte(r)
        local d4 = UE.deob.bytecode._read_byte(r)
        ins.D = (d1 and d2 and d3 and d4) and (d1 + d2 * 256 + d3 * 65536 + d4 * 16777216) or 0
    end
    if ins.A == nil then ins.A = 0 end
    if ins.B == nil then ins.B = 0 end
    if ins.C == nil then ins.C = 0 end
    if ins.D == nil then ins.D = 0 end
    return ins
end

function UE.deob.bytecode._parse_proto(r, strings, version)
    local proto = {}
    proto.maxstacksize = UE.deob.bytecode._read_byte(r)
    proto.numparams = UE.deob.bytecode._read_byte(r)
    proto.nups = UE.deob.bytecode._read_byte(r)
    proto.is_vararg = UE.deob.bytecode._read_byte(r)
    proto.flags = (version >= 4) and UE.deob.bytecode._read_byte(r) or 0
    proto.sizecode = UE.deob.bytecode._read_varint(r)
    proto.code = {}
    for i = 1, proto.sizecode do
        local ins = UE.deob.bytecode._read_instruction(r, i)
        if not ins then break end
        table.insert(proto.code, ins)
    end
    proto.sizek = UE.deob.bytecode._read_varint(r)
    proto.constants = {}
    for i = 1, proto.sizek do
        local ktype = UE.deob.bytecode._read_byte(r)
        if ktype == 0 then
            table.insert(proto.constants, nil)
        elseif ktype == 1 then
            local b = UE.deob.bytecode._read_byte(r)
            table.insert(proto.constants, b ~= 0)
        elseif ktype == 2 then
            local raw = UE.deob.bytecode._read_bytes(r, 8)
            if not raw then break end
            local val = UE.util.safe_call(function()
                return string.unpack and string.unpack("<d", raw) or 0
            end)
            if not val or type(val) ~= "number" then val = 0 end
            table.insert(proto.constants, val)
        elseif ktype == 3 then
            local len = UE.deob.bytecode._read_varint(r)
            if not len then break end
            local s = UE.deob.bytecode._read_bytes(r, len)
            table.insert(proto.constants, s)
        elseif ktype == 4 then
            local idx = UE.deob.bytecode._read_varint(r)
            table.insert(proto.constants, strings[idx + 1] or "")
        elseif ktype == 5 then
            table.insert(proto.constants, { __type = "import" })
        elseif ktype == 6 then
            local kidx = UE.deob.bytecode._read_varint(r)
            table.insert(proto.constants, { __type = "table", size = kidx })
        elseif ktype == 7 then
            local b = UE.deob.bytecode._read_byte(r)
            table.insert(proto.constants, { __type = "closure", idx = b })
        elseif ktype == 8 then
            local raw = UE.deob.bytecode._read_bytes(r, 8)
            table.insert(proto.constants, { __type = "vector", raw = raw })
        else
            break
        end
    end
    proto.sizep = UE.deob.bytecode._read_varint(r)
    proto.protos = {}
    for i = 1, proto.sizep do
        local nested = UE.deob.bytecode._parse_proto(r, strings, version)
        table.insert(proto.protos, nested)
    end
    proto.linegaplog2 = UE.deob.bytecode._read_byte(r)
    local lineinfo_size = math.max(0, proto.sizecode - 1)
    if lineinfo_size > 0 then
        proto.raw_lineinfo = UE.deob.bytecode._read_bytes(r, lineinfo_size)
    end
    if version >= 4 then
        proto.debugname = UE.deob.bytecode._read_string(r)
    end
    proto.sizelocvars = UE.deob.bytecode._read_varint(r)
    proto.locvars = {}
    for i = 1, proto.sizelocvars do
        local var_name = UE.deob.bytecode._read_string(r)
        local start_pc = UE.deob.bytecode._read_varint(r)
        local end_pc = UE.deob.bytecode._read_varint(r)
        local reg = UE.deob.bytecode._read_byte(r)
        table.insert(proto.locvars, { name = var_name, start_pc = start_pc, end_pc = end_pc, reg = reg })
    end
    proto.sizeupvalues = UE.deob.bytecode._read_varint(r)
    proto.upvalues = {}
    for i = 1, proto.sizeupvalues do
        local uv_name = UE.deob.bytecode._read_string(r)
        table.insert(proto.upvalues, { name = uv_name })
    end
    return proto
end

function UE.deob.bytecode.parse(data)
    if type(data) ~= "string" then
        return { success = false, reason = "not a string" }
    end
    local r = UE.deob.bytecode._new_reader(data)
    local ver = UE.deob.bytecode._read_byte(r)
    if not ver then return { success = false, reason = "empty bytecode" } end
    local types_version = UE.deob.bytecode._read_byte(r)
    local strings_count = UE.deob.bytecode._read_varint(r)
    if not strings_count then return { success = false, reason = "no string table" } end
    local strings = {}
    for i = 1, strings_count do
        local s = UE.deob.bytecode._read_string(r)
        if not s then break end
        table.insert(strings, s)
    end
    if ver >= 4 then
        local userdata_count = UE.deob.bytecode._read_varint(r) or 0
        for _ = 1, userdata_count do
            UE.deob.bytecode._read_string(r)
        end
    end
    local main_proto = UE.deob.bytecode._parse_proto(r, strings, ver)
    return {
        success = true,
        version = ver,
        types_version = types_version,
        string_count = #strings,
        strings = strings,
        main = main_proto,
        bytes_consumed = r.pos - 1,
        bytes_total = r.len,
    }
end

function UE.deob.bytecode.flatten_protos(proto, out, path)
    out = out or {}
    path = path or "main"
    table.insert(out, { path = path, proto = proto })
    for i, nested in ipairs(proto.protos or {}) do
        UE.deob.bytecode.flatten_protos(nested, out, path .. "/proto" .. i)
    end
    return out
end

function UE.deob.bytecode.to_disassembly(proto, strings)
    if type(proto) ~= "table" or not proto.code then return "" end
    local lines = {}
    strings = strings or {}
    for i, ins in ipairs(proto.code) do
        local operand = ""
        local fmt = ins.format or "?"
        if fmt == "ABC" then operand = string.format("%d %d %d", ins.A or 0, ins.B or 0, ins.C or 0)
        elseif fmt == "AB" then operand = string.format("%d %d", ins.A or 0, ins.B or 0)
        elseif fmt == "AC" then operand = string.format("%d %d", ins.A or 0, ins.C or 0)
        elseif fmt == "A" then operand = string.format("%d", ins.A or 0)
        elseif fmt == "AD" then operand = string.format("%d %d", ins.A or 0, ins.D or 0)
        elseif fmt == "D" or fmt == "E" then operand = string.format("%d", ins.D or 0)
        end
        table.insert(lines, string.format("%05d %s %s", i, ins.op, operand))
    end
    return table.concat(lines, "\n")
end

function UE.deob.bytecode.decompile(instance)
    local raw = UE.exec.getscriptbytecode(instance)
    if not raw then return { success = false, reason = "no bytecode access" } end
    local parsed = UE.deob.bytecode.parse(raw)
    if not parsed.success then return parsed end
    local pok, path = pcall(function() return instance:GetFullName() end)
    parsed.path = pok and path or "?"
    local disassembly_lines = {}
    local flat = UE.deob.bytecode.flatten_protos(parsed.main)
    for _, entry in ipairs(flat) do
        table.insert(disassembly_lines, "-- proto: " .. entry.path)
        table.insert(disassembly_lines, UE.deob.bytecode.to_disassembly(entry.proto, parsed.strings))
    end
    parsed.disassembly = table.concat(disassembly_lines, "\n")
    parsed.proto_count = #flat
    return parsed
end

function UE.deob.bytecode.to_lua(parsed)
    if not parsed or not parsed.success then return { success = false, reason = "invalid parse" } end
    local main_dis = UE.deob.bytecode.to_disassembly(parsed.main, parsed.strings)
    local instructions = UE.deob.cfg.parse_disassembly(main_dis)
    local constants = parsed.main.constants or {}
    local dec = UE.deob.decompiler.decompile(instructions, constants)
    dec.method = "bytecode_parser"
    dec.path = parsed.path
    dec.parsed = parsed
    return dec
end

UE.deob.decompiler = {}
UE.deob.decompiler._constants_pool = {}

function UE.deob.decompiler.reg(n) return "R" .. tostring(n) end

function UE.deob.decompiler.escape_string(s)
    if type(s) ~= "string" then return nil end
    local escaped = s:gsub("\\", "\\\\"):gsub("\n", "\\n"):gsub("\r", "\\r"):gsub("\t", "\\t"):gsub("\"", "\\\"")
    return "\"" .. escaped .. "\""
end

function UE.deob.decompiler.format_value(v)
    if v == nil then return "nil" end
    local t = type(v)
    if t == "string" then return UE.deob.decompiler.escape_string(v) end
    if t == "number" then
        if v == math.floor(v) then return tostring(math.floor(v)) end
        return tostring(v)
    end
    if t == "boolean" then return v and "true" or "false" end
    if t == "table" then
        if v.__type == "closure" then return "function(...) end" end
        return "{...}"
    end
    return tostring(v)
end

UE.deob.decompiler._ops = {
    ADD = "+", SUB = "-", MUL = "*", DIV = "/", MOD = "%", POW = "^",
    IDIV = "//", BAND = "&", BOR = "|", BXOR = "~", SHL = "<<", SHR = ">>",
    ADDK = "+", SUBK = "-", MULK = "*", DIVK = "/", MODK = "%", POWK = "^",
}
UE.deob.decompiler._unary = { NOT = "not ", MINUS = "-", LENGTH = "#" }
UE.deob.decompiler._compare = { EQ = "==", NE = "~=", LT = "<", LE = "<=", GT = ">", GE = ">=" }

function UE.deob.decompiler.decompile(instructions, constants)
    if type(instructions) ~= "table" then
        return { success = false, reason = "no instructions" }
    end
    constants = constants or {}
    local reg_expr = {}
    local pending_closure = {}
    local indent = 0
    local lines = {}
    local function emit(line)
        table.insert(lines, string.rep("  ", indent) .. line)
    end
    local function get_reg(n)
        if reg_expr[n] then return reg_expr[n] end
        return UE.deob.decompiler.reg(n)
    end
    local function set_reg(n, expr) reg_expr[n] = expr end

    for i, ins in ipairs(instructions) do
        local op = ins.op
        local a = tonumber(ins.operand:match("^(%d+)")) or 0
        local b = tonumber(ins.operand:match("^%d+%s+(%d+)")) or 0
        local c = tonumber(ins.operand:match("^%d+%s+%d+%s+(%d+)")) or 0
        if op == "LOADK" then
            local k = constants[b] or ("K" .. tostring(b))
            set_reg(a, UE.deob.decompiler.format_value(k))
            emit("local " .. UE.deob.decompiler.reg(a) .. " = " .. UE.deob.decompiler.format_value(k))
        elseif op == "LOADN" then
            set_reg(a, tostring(b))
            emit("local " .. UE.deob.decompiler.reg(a) .. " = " .. tostring(b))
        elseif op == "LOADNIL" then
            set_reg(a, "nil")
            emit("local " .. UE.deob.decompiler.reg(a) .. " = nil")
        elseif op == "LOADB" then
            local v = (b ~= 0) and "true" or "false"
            set_reg(a, v)
            emit("local " .. UE.deob.decompiler.reg(a) .. " = " .. v)
        elseif op == "MOVE" then
            set_reg(a, get_reg(b))
            emit("local " .. UE.deob.decompiler.reg(a) .. " = " .. get_reg(b))
        elseif op == "GETGLOBAL" then
            local k = constants[b] or ("K" .. tostring(b))
            set_reg(a, tostring(k))
            emit("local " .. UE.deob.decompiler.reg(a) .. " = " .. tostring(k))
        elseif op == "SETGLOBAL" then
            local k = constants[b] or ("K" .. tostring(b))
            emit(tostring(k) .. " = " .. get_reg(a))
        elseif op == "GETUPVAL" then
            set_reg(a, "upval[" .. tostring(b) .. "]")
        elseif op == "SETUPVAL" then
            emit("upval[" .. tostring(b) .. "] = " .. get_reg(a))
        elseif op == "GETTABLEKS" then
            local k = constants[c] or ("K" .. tostring(c))
            local expr = get_reg(b) .. "." .. tostring(k)
            set_reg(a, expr)
        elseif op == "SETTABLEKS" then
            local k = constants[c] or ("K" .. tostring(c))
            emit(get_reg(b) .. "." .. tostring(k) .. " = " .. get_reg(a))
        elseif op == "GETTABLEN" then
            set_reg(a, get_reg(b) .. "[" .. tostring(c) .. "]")
        elseif op == "SETTABLEN" then
            emit(get_reg(b) .. "[" .. tostring(c) .. "] = " .. get_reg(a))
        elseif op == "GETTABLE" then
            set_reg(a, get_reg(b) .. "[" .. get_reg(c) .. "]")
        elseif op == "SETTABLE" then
            emit(get_reg(b) .. "[" .. get_reg(c) .. "] = " .. get_reg(a))
        elseif op == "NEWTABLE" then
            set_reg(a, "{}")
            emit("local " .. UE.deob.decompiler.reg(a) .. " = {}")
        elseif op == "DUPTABLE" then
            set_reg(a, "{...}")
            emit("local " .. UE.deob.decompiler.reg(a) .. " = {...}")
        elseif op == "NAMECALL" or op == "SELF" then
            local k = constants[c] or ("K" .. tostring(c))
            set_reg(a, get_reg(b))
            set_reg(a + 1, get_reg(b) .. ":" .. tostring(k))
        elseif UE.deob.decompiler._ops[op] then
            local sym = UE.deob.decompiler._ops[op]
            local rhs = nil
            if op:sub(-1) == "K" then
                local k = constants[c] or ("K" .. tostring(c))
                rhs = UE.deob.decompiler.format_value(k)
            else
                rhs = get_reg(c)
            end
            local expr = "(" .. get_reg(b) .. " " .. sym .. " " .. rhs .. ")"
            set_reg(a, expr)
            emit("local " .. UE.deob.decompiler.reg(a) .. " = " .. get_reg(b) .. " " .. sym .. " " .. rhs)
        elseif op == "CONCAT" then
            local parts = {}
            for r = b, c do table.insert(parts, get_reg(r)) end
            local expr = table.concat(parts, " .. ")
            set_reg(a, expr)
            emit("local " .. UE.deob.decompiler.reg(a) .. " = " .. expr)
        elseif UE.deob.decompiler._unary[op] then
            local sym = UE.deob.decompiler._unary[op]
            set_reg(a, sym .. get_reg(b))
            emit("local " .. UE.deob.decompiler.reg(a) .. " = " .. sym .. get_reg(b))
        elseif op == "NEWCLOSURE" or op == "CLOSURE" then
            pending_closure[a] = b
            set_reg(a, "function(...) end")
            emit("local " .. UE.deob.decompiler.reg(a) .. " = function(...) --[[closure " .. tostring(b) .. "]] end")
        elseif op == "GETVARARGS" then
            set_reg(a, "...")
            emit("local " .. UE.deob.decompiler.reg(a) .. " = ...")
        elseif op == "CALL" then
            local arg_start = a + 1
            local arg_count = b - 1
            local ret_count = c - 1
            local args = {}
            for k = 0, arg_count - 1 do table.insert(args, get_reg(arg_start + k)) end
            local call_expr = get_reg(a) .. "(" .. table.concat(args, ", ") .. ")"
            if ret_count > 0 then
                set_reg(a, call_expr)
                emit("local " .. UE.deob.decompiler.reg(a) .. " = " .. call_expr)
            else
                emit(call_expr)
            end
        elseif op == "TAILCALL" then
            local arg_start = a + 1
            local arg_count = b - 1
            local args = {}
            for k = 0, arg_count - 1 do table.insert(args, get_reg(arg_start + k)) end
            emit("return " .. get_reg(a) .. "(" .. table.concat(args, ", ") .. ")")
        elseif op == "RETURN" then
            local ret_count = b - 1
            if ret_count == 0 then
                emit("return")
            elseif ret_count == -1 or ret_count > 100 then
                emit("return " .. get_reg(a) .. ", ...")
            else
                local rets = {}
                for k = 0, ret_count - 1 do table.insert(rets, get_reg(a + k)) end
                emit("return " .. table.concat(rets, ", "))
            end
        elseif op == "JUMP" or op == "JUMPBACK" or op == "JUMPX" then
            local target = UE.deob.cfg.target_addr(ins.operand)
            emit("-- jump to " .. tostring(target))
        elseif op == "JUMPIF" then
            local target = UE.deob.cfg.target_addr(ins.operand)
            emit("if " .. get_reg(a) .. " then -- goto " .. tostring(target))
        elseif op == "JUMPIFNOT" then
            local target = UE.deob.cfg.target_addr(ins.operand)
            emit("if not " .. get_reg(a) .. " then -- goto " .. tostring(target))
        elseif op == "JUMPIFEQ" or op == "JUMPIFNOTEQ" or op == "JUMPIFLE" or op == "JUMPIFLT" or op == "JUMPIFNOTLE" or op == "JUMPIFNOTLT" then
            local target = UE.deob.cfg.target_addr(ins.operand)
            local cmp_map = {
                JUMPIFEQ = "==", JUMPIFNOTEQ = "~=",
                JUMPIFLE = "<=", JUMPIFLT = "<",
                JUMPIFNOTLE = ">", JUMPIFNOTLT = ">=",
            }
            local sym = cmp_map[op] or "?"
            emit("if " .. get_reg(a) .. " " .. sym .. " " .. get_reg(b) .. " then -- goto " .. tostring(target))
        elseif op == "FORNPREP" then
            emit("for " .. get_reg(a) .. " = " .. get_reg(a) .. ", " .. get_reg(a + 1) .. ", " .. get_reg(a + 2) .. " do")
            indent = indent + 1
        elseif op == "FORNLOOP" then
            indent = math.max(0, indent - 1)
            emit("end")
        elseif op == "FORGPREP" then
            emit("for " .. get_reg(a + 3) .. " in " .. get_reg(a) .. " do")
            indent = indent + 1
        elseif op == "FORGLOOP" then
            indent = math.max(0, indent - 1)
            emit("end")
        else
            emit("-- " .. tostring(op) .. " " .. tostring(ins.operand))
        end
    end
    while indent > 0 do
        indent = indent - 1
        table.insert(lines, string.rep("  ", indent) .. "end")
    end
    return {
        success = true,
        lines = lines,
        source = table.concat(lines, "\n"),
        count = #lines,
    }
end

function UE.deob.decompiler.from_instance(instance)
    local dis = UE.exec.disassemble(instance)
    if not dis then
        local bcs = UE.exec.getscriptbytecode(instance)
        if bcs then return UE.deob.bytecode.decompile(instance) end
        return { success = false, reason = "no disassembly or bytecode available" }
    end
    local instructions = UE.deob.cfg.parse_disassembly(dis)
    local constants = {}
    if UE.exec.has("getconstants") then
        local ok, k = pcall(function() return UE.exec.getconstants(instance) end)
        if ok and type(k) == "table" then constants = k end
    end
    local result = UE.deob.decompiler.decompile(instructions, constants)
    local pok, path = pcall(function() return instance:GetFullName() end)
    result.path = pok and path or "?"
    return result
end

function UE.deob.reconstruct(instance)
    if UE.exec.has("decompile") then
        local source = UE.exec.decompile(instance)
        if source then
            local current = source
            local stages = { { name = "source", size = #current } }
            current = UE.deob._strip_comments(current)
            current = UE.deob._strip_whitespace_artifacts(current)
            local folded, fold_iters = UE.deob._fold_constants(current)
            current = folded
            table.insert(stages, { name = "constants_folded", iterations = fold_iters })
            local cff_src, cff_hits = UE.deob._collapse_cff(current)
            current = cff_src
            table.insert(stages, { name = "cff_collapsed", hits = cff_hits })
            local renamed, rename_map = UE.deob._rename_symbols(current)
            current = renamed
            local candidates = UE.deob._extract_string_decryptor(current)
            local confidence = UE.deob._confidence_map(source, current)
            local pok, path = pcall(function() return instance:GetFullName() end)
            return {
                success = true,
                method = "decompile",
                path = pok and path or "?",
                original_size = #source,
                reconstructed_size = #current,
                stages = stages,
                rename_map = rename_map,
                decryptor_candidates = candidates,
                confidence = confidence,
                source = current,
            }
        end
    end
    if UE.exec.has("getscriptbytecode") then
        local bc = UE.deob.bytecode.decompile(instance)
        if bc.success then
            local lua = UE.deob.bytecode.to_lua(bc)
            local pok, path = pcall(function() return instance:GetFullName() end)
            if lua.success then
                return {
                    success = true,
                    method = "bytecode_parser",
                    path = pok and path or "?",
                    reconstructed_size = #lua.source,
                    stages = {
                        { name = "bytecode_parsed", protos = bc.proto_count, strings = bc.string_count },
                        { name = "decompiled", lines = lua.count },
                    },
                    confidence = {},
                    source = lua.source,
                    disassembly = bc.disassembly,
                    parsed = bc,
                }
            end
            return {
                success = true,
                method = "disassembly_only",
                path = pok and path or "?",
                source = "-- decompilation unavailable, disassembly below\n" .. bc.disassembly,
                disassembly = bc.disassembly,
                parsed = bc,
                reconstructed_size = #bc.disassembly,
                stages = { { name = "bytecode_parsed", protos = bc.proto_count, strings = bc.string_count } },
                confidence = {},
            }
        end
    end
    if UE.exec.has("disassemble") then
        local dis = UE.exec.disassemble(instance)
        if dis then
            local instructions = UE.deob.cfg.parse_disassembly(dis)
            local constants = {}
            if UE.exec.has("getconstants") then
                local ok, k = pcall(function() return UE.exec.getconstants(instance) end)
                if ok and type(k) == "table" then constants = k end
            end
            local dec = UE.deob.decompiler.decompile(instructions, constants)
            local pok, path = pcall(function() return instance:GetFullName() end)
            if dec.success then
                return {
                    success = true,
                    method = "disassembler",
                    path = pok and path or "?",
                    reconstructed_size = #dec.source,
                    stages = { { name = "decompiled", lines = dec.count } },
                    confidence = {},
                    source = dec.source,
                }
            end
        end
    end
    return { success = false, reason = "no decompile, disassemble, or bytecode capability" }
end

UE.analyze = {}
UE.analyze._events = {}
UE.analyze._timeline = {}
UE.analyze._snapshots = {}
UE.analyze._snapshot_hz = 4
UE.analyze._last_snapshot = 0
UE.analyze._baseline = {}
UE.analyze._baseline_samples = {}
UE.analyze._baseline_until = 0
UE.analyze._anomalies = {}
UE.analyze._patterns = {}
UE.analyze._provenance = {}
UE.analyze._causal = {}
UE.analyze._hook_stats = {}
UE.analyze._predictive = {}
UE.analyze._prediction_history = {}
UE.analyze._source_detectors = {}
UE.analyze._dsl_cache = {}

function UE.analyze._emit(name, ...)
    local subs = UE.analyze._events[name]
    if not subs then return end
    for _, cb in next, subs do
        local ok, err = pcall(cb, ...)
        if not ok and UE.config.debug then warn("[UE.analyze] listener error: " .. tostring(err)) end
    end
end

function UE.analyze.on(name, cb)
    if type(cb) ~= "function" then return end
    UE.analyze._events[name] = UE.analyze._events[name] or {}
    table.insert(UE.analyze._events[name], cb)
end

function UE.analyze.off(name, cb)
    local subs = UE.analyze._events[name]
    if not subs then return end
    for i = #subs, 1, -1 do
        if subs[i] == cb then table.remove(subs, i) end
    end
end

function UE.analyze._push_timeline(entry)
    entry.t = UE.util.timestamp_ms()
    table.insert(UE.analyze._timeline, entry)
    while #UE.analyze._timeline > UE.config.timeline_capacity do
        table.remove(UE.analyze._timeline, 1)
    end
end

function UE.analyze.timeline() return UE.analyze._timeline end

function UE.analyze.timeline_slice(t_start, t_end)
    local out = {}
    for _, e in ipairs(UE.analyze._timeline) do
        if e.t >= t_start and e.t <= t_end then table.insert(out, e) end
    end
    return out
end

function UE.analyze.snapshot()
    local snap = { t = UE.util.timestamp_ms(), remotes = {}, script_count = 0, node_count = 0 }
    for path, entry in pairs(UE.disc._remotes) do
        snap.remotes[path] = { fires = entry.fires, invokes = entry.invokes, last_fire = entry.last_fire }
    end
    snap.script_count = UE.util.table_len(UE.disc._scripts)
    snap.node_count = UE.util.table_len(UE.model._nodes)
    table.insert(UE.analyze._snapshots, snap)
    while #UE.analyze._snapshots > 512 do table.remove(UE.analyze._snapshots, 1) end
    return snap
end

function UE.analyze.snapshots() return UE.analyze._snapshots end

function UE.analyze.diff_snapshots(a, b)
    if not a or not b then return nil end
    local diff = { remotes = {}, meta = {} }
    for path, rem_a in pairs(a.remotes or {}) do
        local rem_b = (b.remotes or {})[path]
        if rem_b then
            local d_fires = (rem_b.fires or 0) - (rem_a.fires or 0)
            local d_invokes = (rem_b.invokes or 0) - (rem_a.invokes or 0)
            if d_fires ~= 0 or d_invokes ~= 0 then
                diff.remotes[path] = { fires = d_fires, invokes = d_invokes }
            end
        end
    end
    diff.meta.script_delta = (b.script_count or 0) - (a.script_count or 0)
    diff.meta.node_delta = (b.node_count or 0) - (a.node_count or 0)
    return diff
end

function UE.analyze._tick_snapshot()
    local now = UE.util.timestamp_ms()
    local interval = 1000 / UE.analyze._snapshot_hz
    if now - UE.analyze._last_snapshot >= interval then
        UE.analyze.snapshot()
        UE.analyze._last_snapshot = now
    end
end

function UE.analyze.link_causal(remote_entry)
    if type(remote_entry) ~= "table" then return {} end
    local t0 = remote_entry.time or UE.util.timestamp_ms()
    local window = 100
    local linked = {}
    for _, snap in ipairs(UE.analyze._snapshots) do
        if snap.t >= t0 and snap.t <= t0 + window then table.insert(linked, snap) end
    end
    if not UE.analyze._causal[t0] then UE.analyze._causal[t0] = {} end
    for _, s in ipairs(linked) do table.insert(UE.analyze._causal[t0], s) end
    return linked
end

function UE.analyze.causal_graph() return UE.analyze._causal end

function UE.analyze._detect_source(path, prop, value, context)
    for name, detector in pairs(UE.analyze._source_detectors) do
        local ok, result = pcall(detector, path, prop, value, context)
        if ok and result then return result end
    end
    return nil
end

function UE.analyze.record_provenance(path, prop, value, source)
    UE.analyze._provenance[path] = UE.analyze._provenance[path] or {}
    table.insert(UE.analyze._provenance[path], {
        prop = prop, value = value, source = source or "unknown", t = UE.util.timestamp_ms(),
    })
    while #UE.analyze._provenance[path] > 200 do table.remove(UE.analyze._provenance[path], 1) end
end

function UE.analyze.record_provenance_advanced(path, prop, value, context)
    local source = UE.analyze._detect_source(path, prop, value, context)
    UE.analyze.record_provenance(path, prop, value, source)
    return source
end

function UE.analyze.provenance(path) return UE.analyze._provenance[path] or {} end

function UE.analyze.provenance_sources(path)
    local out = {}
    for _, entry in ipairs(UE.analyze._provenance[path] or {}) do
        out[entry.source] = (out[entry.source] or 0) + 1
    end
    return out
end

function UE.analyze._baseline_sample(kind, value)
    UE.analyze._baseline_samples[kind] = UE.analyze._baseline_samples[kind] or {}
    table.insert(UE.analyze._baseline_samples[kind], value)
    while #UE.analyze._baseline_samples[kind] > 256 do
        table.remove(UE.analyze._baseline_samples[kind], 1)
    end
end

function UE.analyze._baseline_compute()
    for kind, samples in pairs(UE.analyze._baseline_samples) do
        if #samples >= 8 then
            local sum = 0
            for _, v in ipairs(samples) do sum = sum + v end
            local mean = sum / #samples
            local sq = 0
            for _, v in ipairs(samples) do sq = sq + (v - mean) ^ 2 end
            local stddev = math.sqrt(sq / #samples)
            UE.analyze._baseline[kind] = { mean = mean, stddev = stddev }
        end
    end
end

function UE.analyze._baseline_check(kind, value)
    local b = UE.analyze._baseline[kind]
    if not b then return false end
    local threshold = b.stddev * UE.config.anomaly_sensitivity
    if threshold <= 0 then return false end
    return math.abs(value - b.mean) > threshold
end

function UE.analyze.flag_anomaly(kind, value, context)
    local anomaly = {
        kind = kind, value = value, baseline = UE.analyze._baseline[kind],
        context = context, t = UE.util.timestamp_ms(),
    }
    table.insert(UE.analyze._anomalies, anomaly)
    while #UE.analyze._anomalies > 500 do table.remove(UE.analyze._anomalies, 1) end
    UE.analyze._emit("onAnomaly", anomaly)
    return anomaly
end

function UE.analyze.anomalies() return UE.analyze._anomalies end

function UE.analyze.predict_replication_live(path)
    local entry = UE.disc._remotes[path]
    if not entry then return nil end
    local fires = UE.net.find_by_path(path)
    if #fires < 6 then
        return { path = path, confidence = 0, reason = "insufficient_samples", samples = #fires }
    end
    local recent = {}
    local start = math.max(1, #fires - 32)
    for i = start, #fires do table.insert(recent, fires[i]) end
    local intervals = {}
    for i = 2, #recent do table.insert(intervals, recent[i].time - recent[i - 1].time) end
    local sum = 0
    for _, v in ipairs(intervals) do sum = sum + v end
    local mean = sum / #intervals
    if mean <= 0 then return { path = path, confidence = 0, reason = "zero_interval" } end
    local sq = 0
    for _, v in ipairs(intervals) do sq = sq + (v - mean) ^ 2 end
    local stddev = math.sqrt(sq / #intervals)
    local confidence = UE.util.clamp(1 - (stddev / mean), 0, 1)
    local last = recent[#recent].time
    local predicted_next = last + mean
    local result = {
        path = path, samples = #intervals,
        mean_interval = UE.util.round(mean, 2),
        stddev = UE.util.round(stddev, 2),
        confidence = UE.util.round(confidence, 3),
        last_seen = last,
        predicted_next = predicted_next,
        overdue = UE.util.timestamp_ms() > predicted_next + (stddev * 2),
    }
    UE.analyze._predictive[path] = result
    return result
end

function UE.analyze.predict_replication(path)
    return UE.analyze.predict_replication_live(path)
end

function UE.analyze.predict_all()
    local out = {}
    for path, _ in pairs(UE.disc._remotes) do
        local p = UE.analyze.predict_replication_live(path)
        if p and p.confidence and p.confidence > 0.4 then table.insert(out, p) end
    end
    return out
end

function UE.analyze._predictive_tick()
    local now = UE.util.timestamp_ms()
    local last = UE.analyze._last_predict_tick or 0
    if now - last < 2000 then return end
    UE.analyze._last_predict_tick = now
    local predictions = UE.analyze.predict_all()
    for _, p in ipairs(predictions) do
        local hist = UE.analyze._prediction_history[p.path]
        if not hist then
            hist = { misses = 0, hits = 0 }
            UE.analyze._prediction_history[p.path] = hist
        end
        if p.overdue then
            hist.misses = hist.misses + 1
            if hist.misses >= 3 then
                UE.analyze._emit("onPredictionOverdue", p)
                hist.misses = 0
            end
        else
            hist.hits = hist.hits + 1
        end
    end
end

function UE.analyze.predictive_state() return UE.util.deep_copy(UE.analyze._predictive) end

function UE.analyze.hook_stats() return UE.introspect.summary() end

function UE.analyze._dsl_parse(spec)
    if type(spec) == "string" then return { kind = "regex", pattern = spec } end
    if type(spec) ~= "table" then return nil end
    return spec
end

function UE.analyze._dsl_match(spec, event)
    local s = UE.analyze._dsl_parse(spec)
    if not s then return false end
    if s.kind == "event" and s.event then
        if event.kind ~= s.event then return false end
    end
    if s.event and event.kind ~= s.event then return false end
    if s.path and event.path and not tostring(event.path):find(s.path, 1, true) then return false end
    if s.prop and event.prop and event.prop ~= s.prop then return false end
    if s.class and event.entry and event.entry.class ~= s.class then return false end
    if s.name and event.entry and event.entry.name and not event.entry.name:find(s.name, 1, true) then return false end
    if s.min_fires and event.entry then
        if (event.entry.fires or 0) < s.min_fires then return false end
    end
    if s.min_invokes and event.entry then
        if (event.entry.invokes or 0) < s.min_invokes then return false end
    end
    if s.has_args and event.entry and event.entry.args then
        if #event.entry.args < s.has_args then return false end
    end
    if s.class_in and event.entry then
        local found = false
        for _, c in ipairs(s.class_in) do
            if event.entry.class == c then found = true break end
        end
        if not found then return false end
    end
    return true
end

function UE.analyze._compile_pattern(spec)
    local key = type(spec) == "string" and ("str:" .. spec) or ("tbl:" .. tostring(spec))
    if UE.analyze._dsl_cache[key] then return UE.analyze._dsl_cache[key] end
    local compiled = function(event) return UE.analyze._dsl_match(spec, event) end
    UE.analyze._dsl_cache[key] = compiled
    return compiled
end

function UE.analyze.register_pattern(name, spec)
    if type(spec) ~= "table" then return false end
    local matcher_spec = spec.match or spec.when or spec
    local compiled = UE.analyze._compile_pattern(matcher_spec)
    if not compiled then return false end
    UE.analyze._patterns[name] = {
        name = name, spec = matcher_spec, match = compiled,
        on_match = spec.on_match, enabled = spec.enabled ~= false, hits = 0,
    }
    return true
end

function UE.analyze.unregister_pattern(name) UE.analyze._patterns[name] = nil end
function UE.analyze.patterns() return UE.analyze._patterns end

function UE.analyze._run_patterns(event)
    for _, pattern in pairs(UE.analyze._patterns) do
        if pattern.enabled and type(pattern.match) == "function" then
            local ok, matched = pcall(pattern.match, event)
            if ok and matched then
                pattern.hits = pattern.hits + 1
                if type(pattern.on_match) == "function" then
                    pcall(pattern.on_match, event, pattern)
                end
            end
        end
    end
end

function UE.analyze.export_pattern(name)
    local p = UE.analyze._patterns[name]
    if not p then return nil end
    return { name = p.name, when = p.spec, enabled = p.enabled, hits = p.hits }
end

function UE.analyze.import_pattern(spec)
    if type(spec) ~= "table" or not spec.name then return false end
    return UE.analyze.register_pattern(spec.name, spec)
end

function UE.analyze.register_source_detector(name, detector)
    if type(detector) ~= "function" then return false end
    UE.analyze._source_detectors[name] = detector
    return true
end

UE.analyze.register_source_detector("tween_service", function(path, prop, value, context)
    if not context or not context.t then return nil end
    if prop == "Position" or prop == "CFrame" or prop == "Size" or prop == "Transparency" or prop == "Rotation" then
        local now = UE.util.timestamp_ms()
        if now - context.t < 16 then
            for _, prev in ipairs(UE.analyze._provenance[path] or {}) do
                if prev.prop == prop and now - prev.t < 16 then return "tween_service" end
            end
        end
    end
    return nil
end)

UE.analyze.register_source_detector("local_script", function(path, prop, value, context)
    if debug and debug.info then
        local ok, source = pcall(function() return debug.info(4, "s") end)
        if ok and source then return "local_script:" .. source end
    end
    return nil
end)

UE.analyze.register_source_detector("server_replication", function(path, prop, value, context)
    local node = UE.model.get(path)
    if not node or not node.instance then return nil end
    local pok, ancestor_ok = pcall(function() return node.instance:IsDescendantOf(game) end)
    if not pok or not ancestor_ok then return "server_replication" end
    return nil
end)

function UE.analyze.start()
    UE.analyze._baseline_until = UE.util.timestamp_ms() + (UE.config.anomaly_baseline_sec * 1000)
    UE.net.on("onRemoteFired", function(entry)
        UE.analyze._push_timeline({ kind = "remote", entry = entry })
        UE.analyze.link_causal(entry)
        UE.analyze._run_patterns({ kind = "remote", entry = entry })
        if UE.util.timestamp_ms() > UE.analyze._baseline_until then
            local rate = UE.net._call_counts.FireServer or 0
            if UE.analyze._baseline_check("fires", rate) then
                UE.analyze.flag_anomaly("fires", rate, { path = entry.path })
            end
        else
            UE.analyze._baseline_sample("fires", UE.net._call_counts.FireServer or 0)
        end
    end)
    UE.net.on("onRemoteResponse", function(entry)
        UE.analyze._push_timeline({ kind = "response", entry = entry })
        UE.analyze._run_patterns({ kind = "response", entry = entry })
    end)
    UE.model.on("onPropertyChanged", function(path, prop, value)
        UE.analyze._push_timeline({ kind = "prop", path = path, prop = prop, value = value })
        UE.analyze.record_provenance_advanced(path, prop, value, { t = UE.util.timestamp_ms() })
        UE.analyze._run_patterns({ kind = "prop", path = path, prop = prop, value = value })
    end)
    UE.disc.on("onRemoteDiscovered", function(entry)
        UE.analyze._push_timeline({ kind = "discover_remote", entry = entry })
        UE.analyze._run_patterns({ kind = "discover_remote", entry = entry })
    end)
    UE.disc.on("onScriptDiscovered", function(entry)
        UE.analyze._push_timeline({ kind = "discover_script", entry = entry })
        UE.analyze._run_patterns({ kind = "discover_script", entry = entry })
    end)
    UE.deob.on("onDetection", function(result)
        UE.analyze._run_patterns({ kind = "deob_detect", result = result })
    end)
    return true
end

function UE.analyze.stop()
    UE.analyze._timeline = {}
    UE.analyze._snapshots = {}
end

UE.session = {}
UE.session._events = {}
UE.session._recording = false
UE.session._record = {}
UE.session._id = nil

function UE.session._emit(name, ...)
    local subs = UE.session._events[name]
    if not subs then return end
    for _, cb in next, subs do
        local ok, err = pcall(cb, ...)
        if not ok and UE.config.debug then warn("[UE.session] listener error: " .. tostring(err)) end
    end
end

function UE.session.on(name, cb)
    if type(cb) ~= "function" then return end
    UE.session._events[name] = UE.session._events[name] or {}
    table.insert(UE.session._events[name], cb)
end

function UE.session.off(name, cb)
    local subs = UE.session._events[name]
    if not subs then return end
    for i = #subs, 1, -1 do
        if subs[i] == cb then table.remove(subs, i) end
    end
end

function UE.session._capture(event)
    if not UE.session._recording then return end
    table.insert(UE.session._record, { t = UE.util.timestamp_ms(), event = event })
end

function UE.session.start()
    UE.session._id = UE.util.uid()
    UE.session._record = {}
    UE.session._recording = true
    UE.net.on("onRemoteFired", function(e) UE.session._capture({ kind = "remote", entry = e }) end)
    UE.net.on("onRemoteResponse", function(e) UE.session._capture({ kind = "response", entry = e }) end)
    UE.model.on("onPropertyChanged", function(p, pr, v) UE.session._capture({ kind = "prop", path = p, prop = pr, value = v }) end)
    UE.disc.on("onRemoteDiscovered", function(e) UE.session._capture({ kind = "discover_remote", entry = e }) end)
    UE.disc.on("onScriptDiscovered", function(e) UE.session._capture({ kind = "discover_script", entry = e }) end)
    UE.deob.on("onDetection", function(r) UE.session._capture({ kind = "deob_detect", result = r }) end)
    return UE.session._id
end

function UE.session.stop() UE.session._recording = false end
function UE.session.record() return UE.session._record end

function UE.session.serialize()
    local meta = {
        id = UE.session._id,
        started = UE.session._record[1] and UE.session._record[1].t or nil,
        ended = UE.session._record[#UE.session._record] and UE.session._record[#UE.session._record].t or nil,
        events = #UE.session._record,
        executor = UE.exec.identify(),
    }
    return {
        meta = meta,
        events = UE.session._record,
        remote_snapshot = UE.util.deep_copy(UE.disc._remotes),
        script_snapshot = UE.util.deep_copy(UE.disc._scripts),
        anomalies = UE.util.deep_copy(UE.analyze._anomalies),
    }
end

function UE.session.export(name)
    local payload = UE.session.serialize()
    local ok, path = UE.file.export_session(name or UE.session._id or "session", payload)
    if ok then UE.session._emit("onExport", name, path) end
    return ok, path
end

function UE.session.import(name)
    local payload = UE.file.import_session(name)
    if not payload then return nil end
    UE.session._emit("onImport", name, payload)
    return payload
end

function UE.session.replay(payload)
    if type(payload) ~= "table" or not payload.events then return false end
    UE.session._emit("onReplayStart", payload.meta)
    for _, ev in ipairs(payload.events) do
        UE.session._emit("onReplayEvent", ev)
    end
    UE.session._emit("onReplayEnd", payload.meta)
    return true
end

function UE.session.diff(a, b)
    if type(a) ~= "table" or type(b) ~= "table" then return nil end
    local result = { added_remotes = {}, removed_remotes = {}, event_delta = 0 }
    local a_remotes = a.remote_snapshot or {}
    local b_remotes = b.remote_snapshot or {}
    for path in pairs(b_remotes) do
        if not a_remotes[path] then table.insert(result.added_remotes, path) end
    end
    for path in pairs(a_remotes) do
        if not b_remotes[path] then table.insert(result.removed_remotes, path) end
    end
    result.event_delta = (b.meta and b.meta.events or 0) - (a.meta and a.meta.events or 0)
    return result
end

function UE.session.save_snapshot(name)
    local snap = {
        t = UE.util.timestamp_ms(),
        remotes = UE.disc._remotes,
        scripts = UE.disc._scripts,
        modules = UE.disc._modules,
        nodes_count = UE.util.table_len(UE.model._nodes),
    }
    return UE.file.save_snapshot(name, snap)
end

function UE.session.load_snapshot(name)
    return UE.file.load_snapshot(name)
end

UE.repl = {}
UE.repl._history = {}
UE.repl._vars = {}
UE.repl._max_history = 500
UE.repl._out = {}

function UE.repl.eval(source)
    if type(source) ~= "string" then return nil, "not a string" end
    local env = setmetatable({}, {
        __index = function(_, k)
            if UE.repl._vars[k] ~= nil then return UE.repl._vars[k] end
            return _G[k]
        end,
        __newindex = function(_, k, v) UE.repl._vars[k] = v end,
    })
    local fn = loadstring(source, "=UE.repl")
    if not fn then return nil, "load failed" end
    if setfenv then setfenv(fn, env) end
    local ok, result = pcall(fn)
    if not ok then
        UE.repl._out[#UE.repl._out + 1] = { error = tostring(result), source = source }
        return nil, result
    end
    UE.repl._out[#UE.repl._out + 1] = { result = result, source = source }
    table.insert(UE.repl._history, source)
    while #UE.repl._history > UE.repl._max_history do
        table.remove(UE.repl._history, 1)
    end
    return result
end

function UE.repl.inspect(obj)
    if UE.util.is_instance(obj) then
        local ok, path = pcall(function() return obj:GetFullName() end)
        return { type = "Instance", class = obj.ClassName, path = ok and path or "?" }
    end
    if type(obj) == "table" then
        local out = { type = "table", keys = {} }
        for k, v in pairs(obj) do
            table.insert(out.keys, { k = tostring(k), v = tostring(v):sub(1, 128) })
        end
        return out
    end
    return { type = type(obj), value = tostring(obj) }
end

function UE.repl.trace(obj, duration)
    duration = duration or 5000
    if not UE.util.is_instance(obj) then return false, "not an instance" end
    local path_ok, path = pcall(function() return obj:GetFullName() end)
    if not path_ok then return false, "no path" end
    local start = UE.util.timestamp_ms()
    UE.model.watch(path, function(prop, value)
        if UE.util.timestamp_ms() - start > duration then return end
        UE.repl._out[#UE.repl._out + 1] = { trace = path, prop = prop, value = value }
    end)
    return true
end

function UE.repl.history() return UE.repl._history end
function UE.repl.output() return UE.repl._out end
function UE.repl.clear() UE.repl._out = {} end
function UE.repl.set(name, value) UE.repl._vars[name] = value end
function UE.repl.get(name) return UE.repl._vars[name] end

function UE.repl.start()
    if UE.config.repl_persist_history then
        local hist = UE.file.read("config/repl_history.cfg")
        if type(hist) == "table" and hist.history then
            UE.repl._history = hist.history
        end
    end
    return true
end

function UE.repl.persist()
    if not UE.config.repl_persist_history then return end
    UE.file.write("config/repl_history.cfg", { history = UE.repl._history }, "config")
end

UE.boot = UE.boot or {}
UE.boot._stage = "phase-6-loaded"
UE.boot._ready = false
UE.boot._events = {}
UE.boot._last_autosave = 0

function UE.boot._emit(name, ...)
    local subs = UE.boot._events[name]
    if not subs then return end
    for _, cb in next, subs do
        local ok, err = pcall(cb, ...)
        if not ok and UE.config.debug then warn("[UE.boot] listener error: " .. tostring(err)) end
    end
end

function UE.boot.on(name, cb)
    if type(cb) ~= "function" then return end
    UE.boot._events[name] = UE.boot._events[name] or {}
    table.insert(UE.boot._events[name], cb)
end

function UE.boot.off(name, cb)
    local subs = UE.boot._events[name]
    if not subs then return end
    for i = #subs, 1, -1 do
        if subs[i] == cb then table.remove(subs, i) end
    end
end

function UE.boot.ready() return UE.boot._ready end

function UE.boot._register_default_patterns()
    UE.analyze.register_pattern("high_entropy_script", {
        when = { event = "deob_detect" },
        on_match = function(event)
            if event.result and event.result.entropy_source and event.result.entropy_source > 6.0 then
                UE.analyze._emit("onAnomaly", {
                    kind = "high_entropy",
                    path = event.result.path,
                    t = UE.util.timestamp_ms(),
                })
            end
        end,
    })
    UE.analyze.register_pattern("new_remote_discovered", {
        when = { event = "discover_remote" },
        on_match = function(event)
            UE.analyze._emit("onAnomaly", {
                kind = "new_remote",
                path = event.entry and event.entry.path,
                t = UE.util.timestamp_ms(),
            })
        end,
    })
    UE.analyze.register_pattern("new_script_discovered", {
        when = { event = "discover_script" },
        on_match = function(event)
            UE.analyze._emit("onAnomaly", {
                kind = "new_script",
                path = event.entry and event.entry.path,
                t = UE.util.timestamp_ms(),
            })
        end,
    })
    UE.analyze.register_pattern("rapid_remote_fire", {
        when = { event = "remote", min_fires = 20 },
        on_match = function(event)
            UE.analyze._emit("onAnomaly", {
                kind = "rapid_fire",
                path = event.entry and event.entry.path,
                fires = event.entry and event.entry.fires,
                t = UE.util.timestamp_ms(),
            })
        end,
    })
end

function UE.boot.init()
    UE.boot._emit("stage", "executor_detect")
    UE.exec.detect()
    UE.boot._emit("stage", "config_apply")
    if type(UE.config._user_overrides) ~= "table" then UE.config._user_overrides = {} end
    UE.boot._emit("stage", "persistence_init")
    local pok, perr = UE.file.init()
    if not pok and UE.config.debug then
        warn("[UE.boot] persistence unavailable: " .. tostring(perr))
    end
    UE.boot._emit("stage", "model_init")
    UE.model.init()
    UE.boot._emit("stage", "discovery_start")
    UE.disc.start()
    UE.boot._emit("stage", "loaded_modules_scan")
    UE.disc._scan_loaded_modules()
    UE.boot._emit("stage", "signal_start")
    UE.signal.start()
    UE.boot._emit("stage", "introspect_start")
    UE.introspect.start()
    UE.boot._emit("stage", "net_start")
    UE.net.start()
    UE.boot._emit("stage", "deob_start")
    UE.deob.start()
    UE.boot._emit("stage", "deob_dynamic_start")
    UE.deob.dynamic.start()
    UE.boot._emit("stage", "analyze_start")
    UE.analyze.start()
    UE.boot._emit("stage", "session_start")
    UE.session.start()
    UE.boot._emit("stage", "repl_start")
    UE.repl.start()
    UE.boot._register_default_patterns()
    UE.boot._ready = true
    UE.boot._emit("ready", UE)
    UE.boot._emit("stage", "ready")
    return UE
end

function UE.boot.shutdown()
    UE.session.stop()
    UE.repl.persist()
    UE.analyze.stop()
    UE.deob.dynamic.stop()
    UE.deob.stop()
    UE.net.stop()
    UE.introspect.stop()
    UE.signal.stop()
    UE.disc.stop()
    UE.model.stop()
    if UE.config.autosave then
        UE.session.export("autosave_" .. UE.util.uid())
    end
    UE.boot._ready = false
    UE.boot._emit("shutdown")
end

function UE.boot.tick()
    UE.analyze._tick_snapshot()
    UE.analyze._predictive_tick()
    UE.introspect._autoscale()
    if UE.config.autosave and UE.session._recording then
        local now = UE.util.timestamp_ms()
        local interval_ms = UE.config.autosave_interval_sec * 1000
        if now - (UE.boot._last_autosave or 0) >= interval_ms then
            UE.boot._last_autosave = now
            pcall(function() UE.session.export("autosave_" .. UE.util.uid()) end)
        end
    end
end

function UE.boot.summary()
    return {
        ready = UE.boot._ready,
        stage = UE.boot._stage,
        executor = UE.exec.identify(),
        remotes = UE.util.table_len(UE.disc._remotes),
        scripts = UE.util.table_len(UE.disc._scripts),
        modules = UE.util.table_len(UE.disc._modules),
        nodes = UE.util.table_len(UE.model._nodes),
        hooks = UE.introspect.summary(),
        net = UE.net.stats(),
        signals = UE.signal.summary(),
        anomalies = #UE.analyze._anomalies,
        patterns = UE.util.table_len(UE.analyze._patterns),
        timeline = #UE.analyze._timeline,
        workspace = UE.file.get_root(),
    }
end

UE.query = function(dsl)
    if type(dsl) ~= "string" or #dsl == 0 then return {} end
    local filters = {}
    for token in dsl:gmatch("%S+") do
        local k, v = token:match("^(%w+):(.+)$")
        if k then filters[k] = v end
    end
    local results = {}
    for _, node in pairs(UE.model._nodes) do
        local match = true
        if filters.class and node.class ~= filters.class then match = false end
        if filters.name and not node.name:find(filters.name, 1, true) then match = false end
        if filters.path and not node.path:find(filters.path, 1, true) then match = false end
        if match then table.insert(results, node) end
    end
    if filters.tag then
        local tag_filtered = {}
        for _, node in ipairs(results) do
            local tags = UE.model.tags(node.path)
            for _, tag in ipairs(tags) do
                if tag == filters.tag then
                    table.insert(tag_filtered, node)
                    break
                end
            end
        end
        return tag_filtered
    end
    return results
end

UE.watch = function(id, expr)
    if type(id) ~= "string" or type(expr) ~= "string" then return false end
    if not UE._watches then UE._watches = {} end
    UE._watches[id] = { expr = expr, results = {}, last = nil }
    return true
end

UE.watch_evaluate = function()
    if not UE._watches then return end
    for id, w in pairs(UE._watches) do
        local fn = loadstring("return " .. w.expr)
        if fn then
            if setfenv then setfenv(fn, getfenv()) end
            local ok, res = pcall(fn)
            if ok and res ~= w.last then
                w.last = res
                table.insert(w.results, { t = UE.util.timestamp_ms(), value = res })
            end
        end
    end
end

UE.export = function(format)
    format = format or "session"
    if format == "session" then
        return UE.session.export("export_" .. UE.util.uid())
    elseif format == "snapshot" then
        return UE.session.save_snapshot("snap_" .. UE.util.uid())
    end
    return false, "unknown format"
end

UE.import = function(format, name)
    format = format or "session"
    if format == "session" then
        return UE.session.import(name)
    elseif format == "snapshot" then
        return UE.session.load_snapshot(name)
    end
    return nil
end

UE.on = function(name, cb)
    local modules = { "model", "net", "disc", "signal", "introspect", "analyze", "session", "deob", "file", "boot" }
    for _, mod in ipairs(modules) do
        local m = UE[mod]
        if m and type(m.on) == "function" then m.on(name, cb) end
    end
end

UE.off = function(name, cb)
    local modules = { "model", "net", "disc", "signal", "introspect", "analyze", "session", "deob", "file", "boot" }
    for _, mod in ipairs(modules) do
        local m = UE[mod]
        if m and type(m.off) == "function" then m.off(name, cb) end
    end
end

UE.file.on("onFileSaved", function(name, path, size)
    UE.boot._emit("file", "saved", name, path, size)
end)

UE.file.on("onFileError", function(name, err)
    UE.boot._emit("file", "error", name, err)
end)

UE.ui = {}
UE.ui._root = nil
UE.ui._main = nil
UE.ui._events = {}

UE.ui.theme = {
    bg_primary = Color3.fromRGB(255, 255, 255),
    bg_secondary = Color3.fromRGB(245, 245, 245),
    bg_tertiary = Color3.fromRGB(235, 235, 235),
    border = Color3.fromRGB(208, 208, 208),
    border_strong = Color3.fromRGB(180, 180, 180),
    text_primary = Color3.fromRGB(30, 30, 30),
    text_secondary = Color3.fromRGB(120, 120, 120),
    text_muted = Color3.fromRGB(160, 160, 160),
    accent = Color3.fromRGB(0, 122, 204),
    accent_light = Color3.fromRGB(230, 242, 252),
    selection = Color3.fromRGB(204, 232, 255),
    warning = Color3.fromRGB(206, 145, 120),
    error = Color3.fromRGB(244, 135, 113),
    success = Color3.fromRGB(106, 153, 85),
    titlebar = Color3.fromRGB(240, 240, 240),
    tab_active = Color3.fromRGB(255, 255, 255),
    tab_inactive = Color3.fromRGB(230, 230, 230),
}

UE.ui.font = Enum.Font.Gotham
UE.ui.font_bold = Enum.Font.GothamBold
UE.ui.font_mono = Enum.Font.Code

UE.ui._event = function(name, ...)
    local subs = UE.ui._events[name]
    if not subs then return end
    for _, cb in next, subs do
        local ok, err = pcall(cb, ...)
        if not ok and UE.config.debug then
            warn("[UE.ui] event error: " .. tostring(err))
        end
    end
end

UE.ui.on = function(name, cb)
    if type(cb) ~= "function" then return end
    UE.ui._events[name] = UE.ui._events[name] or {}
    table.insert(UE.ui._events[name], cb)
end

UE.ui._make = function(class, props, children)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then
            inst[k] = v
        end
    end
    for _, child in ipairs(children or {}) do
        child.Parent = inst
    end
    if props and props.Parent then
        inst.Parent = props.Parent
    end
    return inst
end

UE.ui._corner = function(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 4)
    c.Parent = parent
    return c
end

UE.ui._stroke = function(parent, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or UE.ui.theme.border
    s.Thickness = thickness or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end

UE.ui._pad = function(parent, top, right, bottom, left)
    local p = Instance.new("UIPadding")
    p.PaddingTop = UDim.new(0, top or 0)
    p.PaddingRight = UDim.new(0, right or top or 0)
    p.PaddingBottom = UDim.new(0, bottom or top or 0)
    p.PaddingLeft = UDim.new(0, left or right or top or 0)
    p.Parent = parent
    return p
end

UE.ui._button = function(props)
    local btn = Instance.new("TextButton")
    btn.BackgroundColor3 = props.bg or UE.ui.theme.bg_secondary
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Text = props.text or ""
    btn.TextColor3 = props.fg or UE.ui.theme.text_primary
    btn.TextSize = props.size or 13
    btn.Font = props.font or UE.ui.font
    btn.TextXAlignment = props.x_align or Enum.TextXAlignment.Center
    btn.TextYAlignment = Enum.TextYAlignment.Center
    btn.Size = props.size_udim or UDim2.fromOffset(28, 28)
    btn.Position = props.pos or UDim2.fromOffset(0, 0)
    btn.ZIndex = props.z or 2
    if props.parent then btn.Parent = props.parent end
    UE.ui._corner(btn, props.radius or 3)
    btn.MouseEnter:Connect(function()
        if not btn:GetAttribute("active") then
            btn.BackgroundColor3 = props.bg_hover or UE.ui.theme.bg_tertiary
        end
    end)
    btn.MouseLeave:Connect(function()
        if not btn:GetAttribute("active") then
            btn.BackgroundColor3 = props.bg or UE.ui.theme.bg_secondary
        end
    end)
    if props.on_click then
        btn.MouseButton1Click:Connect(props.on_click)
    end
    return btn
end

UE.ui._label = function(props)
    local lbl = Instance.new("TextLabel")
    lbl.BackgroundTransparency = 1
    lbl.BorderSizePixel = 0
    lbl.Text = props.text or ""
    lbl.TextColor3 = props.fg or UE.ui.theme.text_primary
    lbl.TextSize = props.size or 13
    lbl.Font = props.font or UE.ui.font
    lbl.TextXAlignment = props.x_align or Enum.TextXAlignment.Left
    lbl.TextYAlignment = props.y_align or Enum.TextYAlignment.Center
    lbl.TextTruncate = props.truncate or Enum.TextTruncate.AtEnd
    lbl.Size = props.size_udim or UDim2.new(1, 0, 1, 0)
    lbl.Position = props.pos or UDim2.fromOffset(0, 0)
    lbl.ZIndex = props.z or 2
    if props.parent then lbl.Parent = props.parent end
    return lbl
end

UE.ui._frame = function(props)
    local f = Instance.new("Frame")
    f.BackgroundColor3 = props.bg or UE.ui.theme.bg_primary
    f.BorderSizePixel = 0
    f.Size = props.size_udim or UDim2.fromOffset(100, 100)
    f.Position = props.pos or UDim2.fromOffset(0, 0)
    f.ZIndex = props.z or 1
    f.ClipsDescendants = props.clip or false
    if props.anchor then f.AnchorPoint = props.anchor end
    if props.parent then f.Parent = props.parent end
    if props.radius then UE.ui._corner(f, props.radius) end
    if props.stroke then UE.ui._stroke(f, props.stroke_color, props.stroke_thickness) end
    return f
end

UE.ui._build_topbar = function(parent)
    local theme = UE.ui.theme
    local bar = UE.ui._frame({
        bg = theme.titlebar,
        size_udim = UDim2.new(1, 0, 0, 32),
        pos = UDim2.fromOffset(0, 0),
        z = 5,
        parent = parent,
    })
    bar.Name = "TopBar"

    local bottom_border = Instance.new("Frame")
    bottom_border.BackgroundColor3 = theme.border
    bottom_border.BorderSizePixel = 0
    bottom_border.Size = UDim2.new(1, 0, 0, 1)
    bottom_border.Position = UDim2.new(0, 0, 1, -1)
    bottom_border.ZIndex = 6
    bottom_border.Parent = bar

    local logo = UE.ui._label({
        text = "Universal Explorer",
        size = 13,
        font = UE.ui.font_bold,
        fg = theme.text_primary,
        size_udim = UDim2.fromOffset(160, 32),
        pos = UDim2.fromOffset(10, 0),
        parent = bar,
        z = 6,
    })
    logo.Name = "Logo"

    local ver = UE.ui._label({
        text = "v" .. UE.VERSION,
        size = 11,
        fg = theme.text_muted,
        size_udim = UDim2.fromOffset(60, 32),
        pos = UDim2.fromOffset(150, 0),
        parent = bar,
        z = 6,
    })

    local executor_lbl = UE.ui._label({
        text = "executor: " .. UE.exec.identify(),
        size = 11,
        fg = theme.text_muted,
        x_align = Enum.TextXAlignment.Right,
        size_udim = UDim2.new(0, 220, 1, 0),
        pos = UDim2.new(1, -280, 0, 0),
        parent = bar,
        z = 6,
    })
    executor_lbl.Name = "ExecutorLabel"

    local btn_size = UDim2.fromOffset(28, 28)
    local controls = UE.ui._frame({
        bg = theme.titlebar,
        size_udim = UDim2.fromOffset(90, 32),
        pos = UDim2.new(1, -92, 0, 0),
        z = 6,
        parent = bar,
    })
    controls.Name = "WindowControls"
    controls.BackgroundTransparency = 1

    local min_btn = UE.ui._button({
        text = "—",
        size = 14,
        font = UE.ui.font_bold,
        bg = theme.titlebar,
        bg_hover = theme.bg_tertiary,
        size_udim = btn_size,
        pos = UDim2.fromOffset(0, 2),
        parent = controls,
        z = 7,
        on_click = function()
            UE.ui._event("window_minimize")
        end,
    })
    min_btn.Name = "MinimizeButton"

    local max_btn = UE.ui._button({
        text = "□",
        size = 14,
        font = UE.ui.font_bold,
        bg = theme.titlebar,
        bg_hover = theme.bg_tertiary,
        size_udim = btn_size,
        pos = UDim2.fromOffset(30, 2),
        parent = controls,
        z = 7,
        on_click = function()
            UE.ui._event("window_maximize")
        end,
    })
    max_btn.Name = "MaximizeButton"

    local close_btn = UE.ui._button({
        text = "✕",
        size = 14,
        font = UE.ui.font_bold,
        bg = theme.titlebar,
        bg_hover = theme.error,
        fg = theme.text_primary,
        size_udim = btn_size,
        pos = UDim2.fromOffset(60, 2),
        parent = controls,
        z = 7,
        on_click = function()
            UE.ui._event("window_close")
        end,
    })
    close_btn.Name = "CloseButton"

    return bar
end

UE.ui._build_statusbar = function(parent)
    local theme = UE.ui.theme
    local bar = UE.ui._frame({
        bg = theme.bg_secondary,
        size_udim = UDim2.new(1, 0, 0, 22),
        pos = UDim2.new(0, 0, 1, -22),
        z = 4,
        parent = parent,
    })
    bar.Name = "StatusBar"

    local top_border = Instance.new("Frame")
    top_border.BackgroundColor3 = theme.border
    top_border.BorderSizePixel = 0
    top_border.Size = UDim2.new(1, 0, 0, 1)
    top_border.Position = UDim2.new(0, 0, 0, 0)
    top_border.ZIndex = 5
    top_border.Parent = bar

    local status = UE.ui._label({
        text = "ready",
        size = 11,
        fg = theme.text_secondary,
        size_udim = UDim2.new(0, 300, 1, 0),
        pos = UDim2.fromOffset(10, 0),
        parent = bar,
        z = 5,
    })
    status.Name = "StatusText"

    local stats = UE.ui._label({
        text = "",
        size = 11,
        fg = theme.text_muted,
        x_align = Enum.TextXAlignment.Right,
        size_udim = UDim2.new(0, 400, 1, 0),
        pos = UDim2.new(1, -410, 0, 0),
        parent = bar,
        z = 5,
    })
    stats.Name = "StatsText"

    UE.ui._statusbar = { status = status, stats = stats }
    return bar
end

UE.ui._build_pane = function(props)
    local theme = UE.ui.theme
    local pane = UE.ui._frame({
        bg = props.bg or theme.bg_primary,
        size_udim = props.size_udim,
        pos = props.pos,
        z = 2,
        parent = props.parent,
        clip = true,
    })
    pane.Name = props.name or "Pane"

    if props.header then
        local header = UE.ui._frame({
            bg = theme.bg_secondary,
            size_udim = UDim2.new(1, 0, 0, 24),
            z = 3,
            parent = pane,
        })
        header.Name = "Header"

        local header_border = Instance.new("Frame")
        header_border.BackgroundColor3 = theme.border
        header_border.BorderSizePixel = 0
        header_border.Size = UDim2.new(1, 0, 0, 1)
        header_border.Position = UDim2.new(0, 0, 1, -1)
        header_border.ZIndex = 4
        header_border.Parent = header

        local title = UE.ui._label({
            text = props.header,
            size = 11,
            font = UE.ui.font_bold,
            fg = theme.text_secondary,
            size_udim = UDim2.new(1, -20, 1, 0),
            pos = UDim2.fromOffset(10, 0),
            parent = header,
            z = 4,
        })
        title.Name = "Title"

        pane:SetAttribute("header_height", 24)
    else
        pane:SetAttribute("header_height", 0)
    end

    return pane
end

UE.ui._build_bottom_pane = function(parent)
    local theme = UE.ui.theme
    local pane = UE.ui._frame({
        bg = theme.bg_primary,
        size_udim = UDim2.new(1, 0, 0, 200),
        pos = UDim2.new(0, 0, 1, -222),
        z = 3,
        parent = parent,
        clip = true,
    })
    pane.Name = "BottomPane"

    local top_border = Instance.new("Frame")
    top_border.BackgroundColor3 = theme.border
    top_border.BorderSizePixel = 0
    top_border.Size = UDim2.new(1, 0, 0, 1)
    top_border.Position = UDim2.new(0, 0, 0, 0)
    top_border.ZIndex = 4
    top_border.Parent = pane

    local tabs_bar = UE.ui._frame({
        bg = theme.bg_secondary,
        size_udim = UDim2.new(1, 0, 0, 24),
        pos = UDim2.fromOffset(0, 0),
        z = 4,
        parent = pane,
    })
    tabs_bar.Name = "TabsBar"

    local tabs_border = Instance.new("Frame")
    tabs_border.BackgroundColor3 = theme.border
    tabs_border.BorderSizePixel = 0
    tabs_border.Size = UDim2.new(1, 0, 0, 1)
    tabs_border.Position = UDim2.new(0, 0, 1, -1)
    tabs_border.ZIndex = 5
    tabs_border.Parent = tabs_bar

    local tab_names = { "Console", "Timeline", "Network", "Signals", "Deob", "Session", "Anomalies" }
    local tab_buttons = {}

    local function select_tab(name)
        for tn, btn in pairs(tab_buttons) do
            if tn == name then
                btn.BackgroundColor3 = theme.bg_primary
                btn.TextColor3 = theme.text_primary
                btn:SetAttribute("active", true)
            else
                btn.BackgroundColor3 = theme.tab_inactive
                btn.TextColor3 = theme.text_secondary
                btn:SetAttribute("active", false)
            end
        end
        UE.ui._event("bottom_tab_change", name)
    end

    local x_pos = 4
    for _, name in ipairs(tab_names) do
        local btn = UE.ui._button({
            text = name,
            size = 11,
            font = UE.ui.font,
            bg = theme.tab_inactive,
            bg_hover = theme.bg_tertiary,
            fg = theme.text_secondary,
            size_udim = UDim2.fromOffset(80, 20),
            pos = UDim2.fromOffset(x_pos, 2),
            parent = tabs_bar,
            z = 5,
            on_click = function()
                select_tab(name)
            end,
        })
        btn.Name = name .. "Tab"
        tab_buttons[name] = btn
        x_pos = x_pos + 82
    end

    local content = UE.ui._frame({
        bg = theme.bg_primary,
        size_udim = UDim2.new(1, 0, 1, -24),
        pos = UDim2.fromOffset(0, 24),
        z = 3,
        parent = pane,
    })
    content.Name = "Content"

    UE.ui._bottom = {
        pane = pane,
        tabs = tab_buttons,
        content = content,
        select_tab = select_tab,
    }

    select_tab("Console")
    return pane
end

UE.ui._make_draggable = function(handle, target)
    local dragging = false
    local drag_start = nil
    local start_pos = nil
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            drag_start = input.Position
            start_pos = target.Position
        end
    end)
    handle.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - drag_start
            target.Position = UDim2.new(
                start_pos.X.Scale, start_pos.X.Offset + delta.X,
                start_pos.Y.Scale, start_pos.Y.Offset + delta.Y
            )
        end
    end)
    handle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

UE.ui._make_resizable = function(frame)
    local MIN_W = 600
    local MIN_H = 400
    local HANDLE_SIZE = 6

    local handles = {}
    local sides = { "r", "b", "br" }

    for _, side in ipairs(sides) do
        local handle = Instance.new("TextButton")
        handle.Text = ""
        handle.BackgroundTransparency = 1
        handle.BorderSizePixel = 0
        handle.ZIndex = 10
        handle.AutoButtonColor = false
        handle.Parent = frame

        if side == "r" then
            handle.Size = UDim2.new(0, HANDLE_SIZE, 1, -HANDLE_SIZE)
            handle.Position = UDim2.new(1, -HANDLE_SIZE, 0, 0)
        elseif side == "b" then
            handle.Size = UDim2.new(1, -HANDLE_SIZE, 0, HANDLE_SIZE)
            handle.Position = UDim2.new(0, 0, 1, -HANDLE_SIZE)
        elseif side == "br" then
            handle.Size = UDim2.new(0, HANDLE_SIZE * 2, 0, HANDLE_SIZE * 2)
            handle.Position = UDim2.new(1, -HANDLE_SIZE * 2, 1, -HANDLE_SIZE * 2)
        end

        local dragging = false
        local drag_start = nil
        local start_size = nil
        local start_pos = nil

        handle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                drag_start = input.Position
                start_size = frame.Size
                start_pos = frame.Position
            end
        end)
        handle.InputChanged:Connect(function(input)
            if not dragging then return end
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = input.Position - drag_start
                if side == "r" or side == "br" then
                    local new_w = math.max(MIN_W, start_size.X.Offset + delta.X)
                    frame.Size = UDim2.new(start_size.X.Scale, new_w, frame.Size.Y.Scale, frame.Size.Y.Offset)
                end
                if side == "b" or side == "br" then
                    local new_h = math.max(MIN_H, start_size.Y.Offset + delta.Y)
                    frame.Size = UDim2.new(frame.Size.X.Scale, frame.Size.X.Offset, start_size.Y.Scale, new_h)
                end
            end
        end)
        handle.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)

        table.insert(handles, handle)
    end

    return handles
end

UE.ui.build = function()
    if UE.ui._root and UE.ui._root.Parent then
        UE.ui._root:Destroy()
    end

    local theme = UE.ui.theme
    local player = game:GetService("Players").LocalPlayer
    local gui_parent = player:WaitForChild("PlayerGui")

    local root = Instance.new("ScreenGui")
    root.Name = "UniversalExplorer"
    root.ResetOnSpawn = false
    root.IgnoreGuiInset = true
    root.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    root.Parent = gui_parent
    UE.ui._root = root

    local viewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
    local w = math.min(1100, viewport.X - 80)
    local h = math.min(700, viewport.Y - 80)

    local main = UE.ui._frame({
        bg = theme.bg_primary,
        size_udim = UDim2.fromOffset(w, h),
        pos = UDim2.fromOffset(math.floor((viewport.X - w) / 2), math.floor((viewport.Y - h) / 2)),
        z = 1,
        parent = root,
        radius = 6,
        stroke = true,
        stroke_color = theme.border_strong,
        clip = true,
    })
    main.Name = "MainFrame"
    UE.ui._main = main

    local topbar = UE.ui._build_topbar(main)
    UE.ui._topbar = topbar

    local statusbar = UE.ui._build_statusbar(main)
    UE.ui._statusbar_bar = statusbar

    local workspace_frame = UE.ui._frame({
        bg = theme.bg_primary,
        size_udim = UDim2.new(1, 0, 1, -(32 + 22 + 200)),
        pos = UDim2.fromOffset(0, 32),
        z = 2,
        parent = main,
        clip = true,
    })
    workspace_frame.Name = "Workspace"

    local tree_pane = UE.ui._build_pane({
        name = "TreePane",
        header = "EXPLORER",
        bg = theme.bg_primary,
        size_udim = UDim2.new(0, 260, 1, 0),
        pos = UDim2.fromOffset(0, 0),
        parent = workspace_frame,
    })

    local splitter_left = UE.ui._frame({
        bg = theme.border,
        size_udim = UDim2.new(0, 1, 1, 0),
        pos = UDim2.new(0, 260, 0, 0),
        z = 3,
        parent = workspace_frame,
    })
    splitter_left.Name = "SplitterLeft"

    local inspector_pane = UE.ui._build_pane({
        name = "InspectorPane",
        header = "INSPECTOR",
        bg = theme.bg_primary,
        size_udim = UDim2.new(1, -(260 + 280 + 2), 1, 0),
        pos = UDim2.fromOffset(261, 0),
        parent = workspace_frame,
    })

    local splitter_right = UE.ui._frame({
        bg = theme.border,
        size_udim = UDim2.new(0, 1, 1, 0),
        pos = UDim2.new(1, -(280 + 1), 0, 0),
        z = 3,
        parent = workspace_frame,
    })
    splitter_right.Name = "SplitterRight"

    local side_pane = UE.ui._build_pane({
        name = "SidePane",
        header = "PROPERTIES",
        bg = theme.bg_primary,
        size_udim = UDim2.new(0, 280, 1, 0),
        pos = UDim2.new(1, -280, 0, 0),
        parent = workspace_frame,
    })

    local bottom_pane = UE.ui._build_bottom_pane(main)

    UE.ui._panes = {
        workspace = workspace_frame,
        tree = tree_pane,
        inspector = inspector_pane,
        side = side_pane,
        bottom = bottom_pane,
        splitters = { left = splitter_left, right = splitter_right },
    }

    UE.ui._make_draggable(topbar, main)
    UE.ui._make_resizable(main)

    local close_btn = topbar:FindFirstChild("WindowControls")
    if close_btn then
        local cb = close_btn:FindFirstChild("CloseButton")
        if cb then
            cb.MouseButton1Click:Connect(function()
                UE.ui.destroy()
            end)
        end
        local maxb = close_btn:FindFirstChild("MaximizeButton")
        if maxb then
            local maximized = false
            local saved_size = nil
            local saved_pos = nil
            maxb.MouseButton1Click:Connect(function()
                if not maximized then
                    saved_size = main.Size
                    saved_pos = main.Position
                    main.Size = UDim2.new(1, -20, 1, -20)
                    main.Position = UDim2.fromOffset(10, 10)
                    maximized = true
                else
                    if saved_size then main.Size = saved_size end
                    if saved_pos then main.Position = saved_pos end
                    maximized = false
                end
            end)
        end
        local minb = close_btn:FindFirstChild("MinimizeButton")
        if minb then
            local minimized = false
            local saved_size = nil
            local saved_pos = nil
            minb.MouseButton1Click:Connect(function()
                if not minimized then
                    saved_size = main.Size
                    saved_pos = main.Position
                    main.Size = UDim2.fromOffset(280, 32)
                    main.Position = UDim2.fromOffset(saved_pos.X.Offset, saved_pos.Y.Offset + saved_size.Y.Offset - 32)
                    minimized = true
                else
                    main.Size = saved_size
                    main.Position = saved_pos
                    minimized = false
                end
            end)
        end
    end

    UE.ui._event("ready", main)
    return main
end

UE.ui.destroy = function()
    if UE.ui._root then
        UE.ui._event("destroy")
        UE.ui._root:Destroy()
        UE.ui._root = nil
        UE.ui._main = nil
    end
end

UE.ui.toggle = function()
    if UE.ui._root and UE.ui._root.Parent then
        UE.ui.destroy()
    else
        UE.ui.build()
    end
end

UE.ui.update_status = function(text)
    if UE.ui._statusbar and UE.ui._statusbar.status then
        UE.ui._statusbar.status.Text = tostring(text)
    end
end

UE.ui.update_stats = function(text)
    if UE.ui._statusbar and UE.ui._statusbar.stats then
        UE.ui._statusbar.stats.Text = tostring(text)
    end
end

task.spawn(function()
    UE.boot.init()
    if UE.config.ui_autoload ~= false then
        task.wait(0.5)
        pcall(function() UE.ui.build() end)
    end
    while UE.boot._ready do
        pcall(UE.boot.tick)
        if UE.ui._root and UE.ui._statusbar then
            pcall(function()
                local s = UE.boot.summary()
                UE.ui.update_stats(string.format(
                    "remotes: %d   scripts: %d   nodes: %d   hooks: %d/%d   anomalies: %d",
                    s.remotes or 0, s.scripts or 0, s.nodes or 0,
                    (s.hooks and s.hooks.budget or 0), (s.hooks and s.hooks.budget_max or 0),
                    s.anomalies or 0
                ))
            end)
        end
        task.wait(0.5)
    end
end)

return UE
