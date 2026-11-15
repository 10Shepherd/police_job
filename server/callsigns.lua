local config = lib.load("data.config")

-- identifier -> callsign, cached so the blip loop doesn't hit the database
local callsigns = {}

MySQL.ready(function()
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS police_callsigns (
            identifier VARCHAR(64) NOT NULL PRIMARY KEY,
            callsign VARCHAR(24) NOT NULL,
            updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
        )
    ]])

    local rows = MySQL.query.await('SELECT identifier, callsign FROM police_callsigns')
    for i = 1, #rows do
        callsigns[rows[i].identifier] = rows[i].callsign
    end
end)

local function getKey(src)
    local discord = GetPlayerIdentifierByType(src, "discord")
    return discord and ("discord:" .. discord) or ("license:" .. (GetPlayerIdentifierByType(src, "license") or ""))
end

Callsigns = {}

-- player name if no callsign is set
function Callsigns.get(src)
    return callsigns[getKey(src)] or GetPlayerName(src)
end

-- exports.police_job:getCallsign(src)
exports('getCallsign', Callsigns.get)

RegisterNetEvent("police_job:setCallsign", function(rawText)
    local src = source

    if not Bridge.hasJobs(src, config.policeGroups) then
        return Bridge.notify(src, { type = "error", description = locale("no_perms_duty") })
    end

    local key = getKey(src)
    local text = type(rawText) == "string" and rawText:gsub("^%s+", ""):gsub("%s+$", "") or ""

    if text == "" then
        callsigns[key] = nil
        MySQL.query('DELETE FROM police_callsigns WHERE identifier = ?', { key })
        return Bridge.notify(src, { type = "success", description = locale("callsign_cleared") })
    end

    if #text > 24 then
        return Bridge.notify(src, { type = "error", description = locale("callsign_too_long") })
    end

    callsigns[key] = text
    MySQL.insert('INSERT INTO police_callsigns (identifier, callsign) VALUES (?, ?) ON DUPLICATE KEY UPDATE callsign = ?', { key, text, text })
    Bridge.notify(src, { type = "success", description = locale("callsign_set", text) })
end)
