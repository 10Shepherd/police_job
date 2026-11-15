local evidence = {}
local addEvidence = {}
local clearEvidence = {}
local evidenceMetadata = lib.load("data.evidence")

local bulletText = {
    projectile = locale("projectile_from"),
    casing = locale("casing_from"),
}

CreateThread(function()
    while true do
        Wait(1000)

        if next(addEvidence) or next(clearEvidence) then
            TriggerClientEvent('police_job:updateEvidence', -1, addEvidence, clearEvidence)

            table.wipe(addEvidence)
            table.wipe(clearEvidence)
        end
    end
end)

-- send existing evidence to a client that just loaded
RegisterNetEvent('police_job:requestEvidenceSync', function()
    if next(evidence) then
        TriggerClientEvent('police_job:updateEvidence', source, evidence, {})
    end
end)

local maxNodesPerUpdate = 40
local maxNodeDistance = 100.0 -- casings land within 5m, projectiles within the 50m raycast

-- coords: vector3 world position, or vector4 offset from an entity (w = net id)
local function isValidNode(coords, items, pedCoords)
    local coordsType = type(coords)
    if coordsType ~= "vector3" and coordsType ~= "vector4" then return false end
    if type(items) ~= "table" then return false end

    for item, ammo in pairs(items) do
        if not bulletText[item] or type(ammo) ~= "table" then return false end

        for ammoType, count in pairs(ammo) do
            if not evidenceMetadata[ammoType] or type(count) ~= "number" then return false end
        end
    end

    if coordsType == "vector3" and #(pedCoords - coords) > maxNodeDistance then return false end

    return true
end

RegisterServerEvent('police_job:distributeEvidence', function(nodes)
    local src = source
    if type(nodes) ~= "table" then return end

    local state = Player(src).state
    state.lastShot = os.time()

    if not state.shot then
        state.shot = true
    end

    -- limit and validate what a client can add
    local pedCoords = GetEntityCoords(GetPlayerPed(src))
    local accepted = 0

    for coords, items in pairs(nodes) do
        if accepted >= maxNodesPerUpdate then break end
        if not isValidNode(coords, items, pedCoords) then goto continue end
        accepted = accepted + 1

        if evidence[coords] then
            lib.table.merge(evidence[coords], items)
        else
            evidence[coords] = items
            addEvidence[coords] = true
        end

        ::continue::
    end
end)

-- world position of a node
local function resolveNodeCoords(node)
    if node.w then
        local entity = NetworkGetEntityFromNetworkId(node.w)
        if entity == 0 or not DoesEntityExist(entity) then return nil end
        return GetOffsetFromEntityInWorldCoords(entity, node.x, node.y, node.z)
    end
    return node
end

-- no inventory, so notify and trigger police_job:evidenceCollected
RegisterServerEvent('police_job:collectEvidence', function(nodes)
    local src = source
    if type(nodes) ~= "table" or not Bridge.isOnDuty(src) then return end

    local pedCoords = GetEntityCoords(GetPlayerPed(src))
    local items = {}

    for i = 1, #nodes do
        local coords = nodes[i]
        local coordsType = type(coords)
        if coordsType ~= "vector3" and coordsType ~= "vector4" then goto continue end
        if not evidence[coords] then goto continue end

        local worldCoords = resolveNodeCoords(coords)
        if not worldCoords or #(pedCoords - worldCoords) > 3.0 then goto continue end

        lib.table.merge(items, evidence[coords])

        clearEvidence[coords] = true
        evidence[coords] = nil

        ::continue::
    end

    local found = {}
    local foundAny = false

    for item, data in pairs(items) do
        for ammoType, count in pairs(data) do
            foundAny = true
            local info = evidenceMetadata[ammoType]
            local label = info and bulletText[item]:format(info.label) or item
            found[#found + 1] = ("%s x%d"):format(label, count)
            TriggerEvent('police_job:evidenceCollected', src, item, ammoType, count)
        end
    end

    if not foundAny then return end
    Bridge.notify(src, {
        type = 'success',
        title = locale("evidence_collected"),
        description = table.concat(found, ", ")
    })
end)
