local data = lib.load("data.officerBlips")

local function getVehicleCategory(ped)
    local veh = GetVehiclePedIsIn(ped, false)
    if veh == 0 then return "foot" end

    local class = GetVehicleClass(veh)
    if class == 8 then return "bike" end   -- motorcycles
    if class == 15 then return "heli" end  -- helicopters
    return "car"                           -- catch-all for every other vehicle class
end

-- on-duty officers and anyone with a shareWithStates key
local function canReceive(state)
    if state.onDuty then return true end

    local shared = data.shareWithStates
    if shared then
        for i = 1, #shared do
            if state[shared[i]] then return true end
        end
    end

    return false
end

CreateThread(function()
    while true do
        Wait(data.interval * 1000)

        local snapshot = {}
        local recipients = {}

        for _, playerId in ipairs(GetPlayers()) do
            local src = tonumber(playerId)
            local state = Player(src).state
            local ped = state.onDuty and GetPlayerPed(src)

            if canReceive(state) then
                recipients[#recipients + 1] = src
            end

            -- ped is 0 while loading in, skip
            if ped and ped ~= 0 then
                snapshot[#snapshot + 1] = {
                    id = src,
                    coords = GetEntityCoords(ped),
                    category = getVehicleCategory(ped),
                    label = Callsigns.get(src)
                }
            end
        end

        -- only send to players allowed to see blips
        for i = 1, #recipients do
            TriggerClientEvent("police_job:officerBlips", recipients[i], snapshot)
        end
    end
end)
