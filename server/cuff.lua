local cuffItems = {"cuffs", "zipties"}

local function cuffCheck(src, target, cuffType)
    target = tonumber(target)
    if not target or target == src or not DoesPlayerExist(target) then return end

    local ped = GetPlayerPed(src)
    local targetPed = GetPlayerPed(target)
    if GetVehiclePedIsIn(ped) ~= 0 or
        GetVehiclePedIsIn(targetPed) ~= 0 or
        #(GetEntityCoords(ped)-GetEntityCoords(targetPed)) > 5.0 or
        not lib.table.contains(cuffItems, cuffType) or
        not Bridge.isOnDuty(src)
        then return
    end

    local playerState = Player(src).state
    local targetState = Player(target).state
    return (not playerState.handsUp and
        not playerState.gettingCuffed and
        not playerState.isCuffed and
        not playerState.isCuffing) and

        -- zipties need hands up, cuffs don't
        (targetState.handsUp or cuffType == "cuffs") and
        not targetState.gettingCuffed and
        not targetState.isCuffing and
        not targetState.isCuffed
end

local function uncuffCheck(src, target, cuffType)
    target = tonumber(target)
    if not target or target == src or not DoesPlayerExist(target) then return end

    local ped = GetPlayerPed(src)
    local targetPed = GetPlayerPed(target)

    if GetVehiclePedIsIn(ped) ~= 0 or
        GetVehiclePedIsIn(targetPed) ~= 0 or
        #(GetEntityCoords(ped)-GetEntityCoords(targetPed)) > 5.0 or
        not lib.table.contains(cuffItems, cuffType) or
        not Bridge.isOnDuty(src)
        then return
    end

    local playerState = Player(src).state
    local targetState = Player(target).state
    return not playerState.handsUp and
        not playerState.gettingCuffed and
        not playerState.isCuffed and
        not playerState.isCuffing and
        targetState.isCuffed
end

RegisterNetEvent("police_job:syncAgressiveCuff", function(target, angle, cuffType, slot, heading)
    local src = source
    if not cuffCheck(src, target, cuffType) then return end

    local escaped = lib.callback.await("police_job:syncAgressiveCuff", target, angle, cuffType, heading)
    if escaped then return end

    Player(target).state.handsUp = false
end)

RegisterNetEvent("police_job:syncNormalCuff", function(target, angle, cuffType, slot)
    local src = source
    if not cuffCheck(src, target, cuffType) then return end
    TriggerClientEvent("police_job:syncNormalCuff", target, angle, cuffType)
end)

RegisterNetEvent("police_job:uncuffPed", function(target, cuffType)
    local src = source
    if not uncuffCheck(src, target, cuffType) then return end

    local playerCuffType = Player(target).state.cuffType or "cuffs"
    if playerCuffType ~= cuffType then return end

    TriggerClientEvent("police_job:uncuffPed", target)
end)
