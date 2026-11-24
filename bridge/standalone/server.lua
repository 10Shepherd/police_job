local config = lib.load("data.config")

local bridge = {}

function bridge.notify(src, info)
    TriggerClientEvent("ox_lib:notify", src, info)
end

function bridge.hasJobs(src, groups)
    if not groups then return false end
    for i = 1, #groups do
        if IsPlayerAceAllowed(src, groups[i]) then
            return true
        end
    end
    return false
end

-- ACE groups that get synced to clients
local trackedGroups = {}
local function track(list)
    if not list then return end
    for i = 1, #list do
        trackedGroups[list[i]] = true
    end
end

track(config.policeGroups)

local trackedGroupList = {}
for group in pairs(trackedGroups) do
    trackedGroupList[#trackedGroupList + 1] = group
end

-- being in a group doesn't make IsPlayerAceAllowed(src, group) true, the group needs an
-- allow rule on its own name. if this fails add to server.cfg:
-- add_ace resource.police_job command.add_ace allow
for i = 1, #trackedGroupList do
    local group = trackedGroupList[i]
    ExecuteCommand(('add_ace %s %s allow'):format(group, group))
end

function bridge.isOnDuty(src)
    return Player(src).state.onDuty == true
end

-- clocking on is refused if the ACE check fails
function bridge.setDuty(src, status)
    if status and not bridge.hasJobs(src, config.policeGroups) then
        return false
    end

    local state = Player(src).state
    state:set("onDuty", status, true)

    -- optional hud resource support
    if GetResourceState("hud") == "started" then
        pcall(function()
            if status then
                exports.hud:setLeoDuty(src)
            else
                exports.hud:clearDuty(src)
            end
        end)
    end

    if not status then
        -- remove their blip for everyone right away
        TriggerClientEvent("police_job:officerBlipRemove", -1, src)
    end

    -- for other resources (logs, MDT)
    TriggerEvent("police_job:dutyChanged", src, status == true)

    return true
end

local function refreshPlayer(src)
    if not GetPlayerName(src) then return end

    local groupState = {}
    for i = 1, #trackedGroupList do
        local group = trackedGroupList[i]
        groupState[group] = IsPlayerAceAllowed(src, group) or nil
    end

    local state = Player(src).state
    state:set("policeGroups", groupState, true)

    -- lost the group while on duty
    if bridge.isOnDuty(src) and not bridge.hasJobs(src, config.policeGroups) then
        bridge.setDuty(src, false)
    end
end

AddEventHandler("playerJoining", function()
    local src = source
    SetTimeout(3000, function()
        refreshPlayer(src)
    end)
end)

-- refresh players already online when the resource starts
CreateThread(function()
    for _, playerId in ipairs(GetPlayers()) do
        refreshPlayer(tonumber(playerId))
    end
end)

-- ACE grants can change without a reconnect
CreateThread(function()
    while true do
        Wait(config.permissionRefreshInterval * 1000)
        for _, playerId in ipairs(GetPlayers()) do
            refreshPlayer(tonumber(playerId))
        end
    end
end)

-- force a refresh for one player
exports("refreshPolicePermissions", refreshPlayer)

-- exports.police_job:isOnDuty(src)
exports('isOnDuty', function(src)
    return bridge.isOnDuty(src)
end)

return bridge
