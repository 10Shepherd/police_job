local config = lib.load("data.config")
local data_jail = lib.load("data.jail")

-- src -> minutes left, also saved to the database
local sentences = {}

local function getKey(src)
    local discord = GetPlayerIdentifierByType(src, "discord")
    return discord and ("discord:" .. discord) or ("license:" .. (GetPlayerIdentifierByType(src, "license") or ""))
end

local function hexToDiscordColor(hex)
    hex = hex:gsub("#", "")
    local r = tonumber(hex:sub(1, 2), 16)
    local g = tonumber(hex:sub(3, 4), 16)
    local b = tonumber(hex:sub(5, 6), 16)
    return r * 65536 + g * 256 + b
end

local function sendToDiscord(title, description, fields)
    if not data_jail.discord.enabled then return end

    PerformHttpRequest(data_jail.discord.webhook, function() end, 'POST', json.encode({
        username = "Jail logs",
        embeds = {{
            title = title,
            description = description,
            fields = fields,
            color = hexToDiscordColor(data_jail.discord.color)
        }}
    }), { ["Content-Type"] = "application/json" })
end

local function sentenceNotify(src, minutes)
    if not minutes or minutes <= 0 then return end

    Bridge.notify(src, {
        title = locale("jail"),
        description = locale("jail_time_left", minutes, minutes == 1 and "" or "s"),
        duration = 5000,
        type = "inform"
    })
end

local function persistSentence(src, minutes)
    MySQL.query('INSERT INTO police_jail (identifier, minutes_remaining) VALUES (?, ?) ON DUPLICATE KEY UPDATE minutes_remaining = ?', { getKey(src), minutes, minutes })
end

local function clearPersistedSentence(src)
    MySQL.query('DELETE FROM police_jail WHERE identifier = ?', { getKey(src) })
end

local function releasePlayer(src)
    sentences[src] = nil
    Player(src).state:set("jailed", false, true)
    clearPersistedSentence(src)
    TriggerClientEvent("police_job:sentencePlayer", src, false)
end

local function jailPlayer(src, targetSrc, minutes, adminBypass)
    if not adminBypass and not Bridge.isOnDuty(src) then return end

    targetSrc = tonumber(targetSrc)
    minutes = tonumber(minutes)
    if not targetSrc or not DoesPlayerExist(targetSrc) or not minutes or minutes < 1 or minutes > data_jail.maxSentence then return end

    minutes = math.floor(minutes)

    if not adminBypass then
        -- target must be cuffed, not jailed and close
        local targetState = Player(targetSrc).state
        if not targetState.isCuffed or targetState.jailed then return end

        local ped = GetPlayerPed(src)
        local targetPed = GetPlayerPed(targetSrc)
        if #(GetEntityCoords(ped) - GetEntityCoords(targetPed)) > 3.0 then return end
    end

    sendToDiscord("Jail logs", ("**Jail time:** %s minute(s)"):format(minutes), {
        {
            name = adminBypass and "**Admin (used /jail command):**" or "**Officer:**",
            -- src 0 = console
            value = ("**Server ID:** %s\n**Username:** %s"):format(src, src == 0 and "Console" or GetPlayerName(src))
        },
        {
            name = "**Prisoner:**",
            value = ("**Server ID:** %s\n**Username:** %s"):format(targetSrc, GetPlayerName(targetSrc))
        }
    })

    sentences[targetSrc] = minutes
    Player(targetSrc).state:set("jailed", minutes, true)
    persistSentence(targetSrc, minutes)

    -- uncuff and stop escort before teleporting
    Player(targetSrc).state:set("isEscorted", false, true)
    TriggerClientEvent("police_job:uncuffPed", targetSrc)
    TriggerClientEvent("police_job:sentencePlayer", targetSrc, true)
    sentenceNotify(targetSrc, minutes)
end

RegisterNetEvent("police_job:jailPlayer", function(targetSrc, minutes)
    jailPlayer(source, targetSrc, minutes)
end)

-- load a saved sentence, teleport is false after a resource restart
local function restoreSentence(src, teleport)
    if not DoesPlayerExist(src) then return end

    local row = MySQL.single.await('SELECT minutes_remaining FROM police_jail WHERE identifier = ?', { getKey(src) })
    local minutes = row and row.minutes_remaining
    local state = Player(src).state

    if not minutes or minutes < 1 then
        -- no saved sentence, clear leftover state
        if state.jailed then state:set("jailed", false, true) end
        return
    end

    sentences[src] = minutes
    state:set("jailed", minutes, true)

    if teleport then
        TriggerClientEvent("police_job:sentencePlayer", src, true)
    end

    sentenceNotify(src, minutes)
end

MySQL.ready(function()
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS police_jail (
            identifier VARCHAR(64) NOT NULL PRIMARY KEY,
            minutes_remaining INT NOT NULL,
            updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
        )
    ]])

    -- players already online after a restart
    for _, playerId in ipairs(GetPlayers()) do
        restoreSentence(tonumber(playerId), false)
    end
end)

-- re-apply the sentence on reconnect
AddEventHandler("playerJoining", function()
    local src = source
    SetTimeout(5000, function()
        restoreSentence(src, true)
    end)
end)

AddEventHandler("playerDropped", function()
    sentences[source] = nil
end)

lib.cron.new("* * * * *", function()
    for src, minutes in pairs(sentences) do
        if not DoesPlayerExist(src) then
            sentences[src] = nil
        elseif minutes <= 1 then
            releasePlayer(src)
        else
            sentences[src] = minutes - 1
            Player(src).state:set("jailed", sentences[src], true)
            persistSentence(src, sentences[src])
            sentenceNotify(src, sentences[src])
        end
    end
end)

lib.addCommand("unjail", {
    help = "Admin command, release a jailed player.",
    restricted = config.unjailCommandGroups,
    params = {
        {
            name = "target",
            type = "playerId",
            help = "Target player's server id"
        }
    }
}, function(source, args, raw)
    local target = args.target

    if not sentences[target] and not Player(target).state.jailed then
        if source ~= 0 then
            Bridge.notify(source, { type = "error", description = locale("player_not_jailed") })
        end
        return
    end

    releasePlayer(target)
end)

lib.addCommand("jail", {
    help = "Admin command, jail a player.",
    restricted = config.jailCommandGroups,
    params = {
        {
            name = "target",
            type = "playerId",
            help = "Target player's server id"
        },
        {
            name = "time",
            type = "number",
            help = "Amount of time in (minutes) to jail for"
        }
    }
}, function(source, args, raw)
    jailPlayer(source, args.target, args.time, true)
end)
