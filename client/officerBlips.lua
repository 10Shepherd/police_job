local data = lib.load("data.officerBlips")
local activeBlips = {}

-- blips for on-duty EMS, only used if an ambulance resource sends them
local emsData = {
    sprites = { foot = 1, car = 56, bike = 225, heli = 64 },
    color = 8, -- pink
    shortRange = true
}
local activeEmsBlips = {}

local function removeBlip(blips, id)
    if blips[id] then
        RemoveBlip(blips[id])
        blips[id] = nil
    end
end

local function removeAllBlips(blips)
    for id in pairs(blips) do
        removeBlip(blips, id)
    end
end

local function updateBlips(blips, info, blipData)
    local blip = blips[info.id]
    -- recreate the blip if the handle is gone
    if not blip or not DoesBlipExist(blip) then
        blip = AddBlipForCoord(info.coords.x, info.coords.y, info.coords.z)
        SetBlipAsShortRange(blip, blipData.shortRange)
        SetBlipColour(blip, blipData.color)
        SetBlipScale(blip, blipData.scale or 0.8)
        blips[info.id] = blip
    end

    SetBlipCoords(blip, info.coords.x, info.coords.y, info.coords.z)
    SetBlipSprite(blip, blipData.sprites[info.category] or blipData.sprites.foot)

    -- set the name every time in case the callsign changed
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(info.label)
    EndTextCommandSetBlipName(blip)
end

RegisterNetEvent("police_job:officerBlips", function(snapshot)
    if not Bridge.isOnDuty() then
        removeAllBlips(activeBlips)
        return
    end

    local seen = {}

    for i = 1, #snapshot do
        local officer = snapshot[i]
        if officer.id ~= cache.serverId then
            seen[officer.id] = true
            updateBlips(activeBlips, officer, data)
        end
    end

    for id in pairs(activeBlips) do
        if not seen[id] then
            removeBlip(activeBlips, id)
        end
    end
end)

-- EMS blips
RegisterNetEvent("ND_Ambulance:emsBlips", function(snapshot)
    if not Bridge.isOnDuty() then
        removeAllBlips(activeEmsBlips)
        return
    end

    local seen = {}

    for i = 1, #snapshot do
        local medic = snapshot[i]
        if medic.id ~= cache.serverId then
            seen[medic.id] = true
            updateBlips(activeEmsBlips, medic, emsData)
        end
    end

    for id in pairs(activeEmsBlips) do
        if not seen[id] then
            removeBlip(activeEmsBlips, id)
        end
    end
end)

RegisterNetEvent("police_job:officerBlipRemove", function(id)
    removeBlip(activeBlips, id)
end)

-- clear blips when going off duty
AddStateBagChangeHandler('onDuty', ('player:%s'):format(cache.serverId), function(_, _, value)
    if not value then
        removeAllBlips(activeBlips)
        removeAllBlips(activeEmsBlips)
    end
end)

AddEventHandler("onResourceStop", function(resource)
    if resource ~= cache.resource then return end
    removeAllBlips(activeBlips)
    removeAllBlips(activeEmsBlips)
end)
