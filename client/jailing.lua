local data_jail = lib.load("data.jail")

local function teleport(ped, coords)
    DoScreenFadeOut(500)
    Wait(500)
    FreezeEntityPosition(ped, true)

    StartPlayerTeleport(cache.playerId, coords.x, coords.y, coords.z, coords.w, false, true, true)
    while IsPlayerTeleportActive() or not HasCollisionLoadedAroundEntity(cache.ped) do Wait(10) end

    SetGameplayCamRelativeHeading(0)
    FreezeEntityPosition(ped, false)

    Wait(100)
    DoScreenFadeIn(500)
end

-- send jailed players back if they leave the prison
lib.zones.poly({
    name = "police_job:prison",
    points = data_jail.zone.points,
    thickness = data_jail.zone.thickness,
    onExit = function(self)
        local sentence = LocalPlayer.state.jailed
        if not sentence or sentence < 1 then return end
        teleport(cache.ped, data_jail.prisonCoords)
    end
})

RegisterNetEvent("police_job:sentencePlayer", function(setJailed)
    if source == "" then return end
    teleport(cache.ped, setJailed and data_jail.prisonCoords or data_jail.releaseCoords)
end)

-- uses the isCuffed state bag, IsPedCuffed here would be the GTA native
exports.ox_target:addGlobalPlayer({
    {
        name = "police_job:jailPlayer",
        icon = "fa-solid fa-building-shield",
        label = locale("jail_player"),
        distance = 1.5,
        canInteract = function(entity)
            if not Bridge.isOnDuty() then return false end

            local targetSrc = GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))
            local targetState = Player(targetSrc).state
            return targetState.isCuffed and not targetState.jailed
        end,
        onSelect = function(data)
            local targetSrc = GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity))

            local input = lib.inputDialog(locale("jail_player"), {
                {
                    type = "number",
                    label = locale("jail_sentence_label"),
                    description = locale("jail_sentence_description"),
                    required = true,
                    max = data_jail.maxSentence,
                    min = 1,
                    step = 1
                }
            })

            if not input or not input[1] then return end

            -- stop escorting first
            if LocalPlayer.state.blockHandsUp then
                StopEscortPlayer(targetSrc)
            end

            TriggerServerEvent("police_job:jailPlayer", targetSrc, input[1])
        end
    }
})
