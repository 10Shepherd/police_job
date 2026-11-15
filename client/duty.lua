local config = lib.load("data.config")
local data_dutyPeds = lib.load("data.dutyPeds")
local spawnedPeds = {}

-- works from anywhere, the server does the permission check
RegisterCommand(config.dutyCommand, function()
    TriggerServerEvent("police_job:toggleDuty")
end, false)
TriggerEvent("chat:addSuggestion", "/" .. config.dutyCommand, "Toggle police duty from anywhere.")

local function createDutyPed(info)
    lib.requestModel(info.model)
    local ped = CreatePed(4, info.model, info.coords.x, info.coords.y, info.coords.z, info.coords.w, false, true)

    SetEntityAsMissionEntity(ped, true, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedDiesWhenInjured(ped, false)
    SetPedCanPlayAmbientAnims(ped, true)
    SetPedCanRagdollFromPlayerImpact(ped, false)
    SetEntityInvincible(ped, true)
    FreezeEntityPosition(ped, true)
    SetModelAsNoLongerNeeded(info.model)

    spawnedPeds[#spawnedPeds + 1] = ped
    return ped
end

CreateThread(function()
    for i = 1, #data_dutyPeds do
        local ped = createDutyPed(data_dutyPeds[i])

        exports.ox_target:addLocalEntity(ped, {
            {
                name = "police_job:toggleDuty",
                icon = "fa-solid fa-right-left",
                label = locale("toggle_duty"),
                distance = 2.0,
                -- only shown to players with a police group
                canInteract = function()
                    return Bridge.hasGroup(Config.policeGroups)
                end,
                onSelect = function()
                    TriggerServerEvent("police_job:toggleDuty")
                end
            }
        })
    end
end)

AddEventHandler("onResourceStop", function(resource)
    if resource ~= cache.resource then return end
    for i = 1, #spawnedPeds do
        if DoesEntityExist(spawnedPeds[i]) then
            DeleteEntity(spawnedPeds[i])
        end
    end
end)
