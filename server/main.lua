local config = lib.load("data.config")

RegisterServerEvent('police_job:setPlayerEscort', function(target, state, setIntoVeh, setIntoSeat, exitVeh)
    local src = source
    if not Bridge.isOnDuty(src) then return end

    target = tonumber(target)
    if not target or target == 0 or not DoesPlayerExist(target) then return end

    if not Player(target).state.isCuffed then return end

    local playerCoords = GetEntityCoords(GetPlayerPed(src))
    local targetPed = GetPlayerPed(target)
    local targetCoords = GetEntityCoords(targetPed)
    if not playerCoords or not targetCoords or #(playerCoords-targetCoords) > 10 then return end

    if exitVeh then
        SetEntityCoords(targetPed, playerCoords.x, playerCoords.y, playerCoords.z)
    end

    target = Player(target)?.state

    if not target then return end
    target:set('isEscorted', state and src, true)

    if not setIntoVeh or not setIntoSeat then return end
    Wait(500)

    local veh = NetworkGetEntityFromNetworkId(setIntoVeh)
    if not DoesEntityExist(veh) then return end

    SetPedIntoVehicle(targetPed, veh, setIntoSeat)
end)

RegisterNetEvent('police_job:gsrTest', function(target)
    local src = source

    if not Bridge.isOnDuty(src) then return end

    target = tonumber(target)
    if not target or not DoesPlayerExist(target) then return end

    local distance = #(GetEntityCoords(GetPlayerPed(src)) - GetEntityCoords(GetPlayerPed(target)))
    if distance > 5.0 then return end

    local state = Player(target).state

    if state.shot then
        return Bridge.notify(src, {
            type = 'success',
            description = locale("gsr_positive")
        })
    end

    Bridge.notify(src, {
        type = 'error',
        description = locale("gsr_negative")
    })
end)

RegisterNetEvent("police_job:impoundVehicle", function(netId, impoundReclaimPrice)
    local src = source

    impoundReclaimPrice = tonumber(impoundReclaimPrice)

    if not impoundReclaimPrice or impoundReclaimPrice > config.maxImpoundPrice or impoundReclaimPrice < config.minImpoundPrice then
        return Bridge.notify(src, {
            type = "error",
            description = locale("invalid_impound_price")
        })
    end

    if not Bridge.isOnDuty(src) then
        return Bridge.notify(src, {
            type = "error",
            description = locale("no_perms_impound")
        })
    end

    local vehicle = type(netId) == "number" and NetworkGetEntityFromNetworkId(netId) or 0

    -- 2 = vehicle
    if vehicle == 0 or not DoesEntityExist(vehicle) or GetEntityType(vehicle) ~= 2 then
        return Bridge.notify(src, {
            type = "error",
            description = locale("veh_not_found_try_again")
        })
    end

    local vehCoords = GetEntityCoords(vehicle)
    local pedCoords = GetEntityCoords(GetPlayerPed(src))

    if #(vehCoords-pedCoords) > 5 then
        return Bridge.notify(src, {
            type = "error",
            description = locale("too_far_from_veh")
        })
    end

    -- vehicle is just deleted, use police_job:vehicleImpounded to store it somewhere
    local plate = GetVehicleNumberPlateText(vehicle)
    TriggerEvent("police_job:vehicleImpounded", src, plate, impoundReclaimPrice, GetEntityModel(vehicle))

    DeleteEntity(vehicle)
end)

-- server event for other resources
RegisterNetEvent("police_job:playerSearched", function(target)
    local src = source
    if not Bridge.isOnDuty(src) then return end

    target = tonumber(target)
    if not target or not DoesPlayerExist(target) then return end

    TriggerEvent("police_job:searchedPlayer", src, target)
end)
