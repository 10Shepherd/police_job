local bridge = {}

function bridge.notify(info)
    lib.notify(info)
end

-- groups: array of ACE group strings, checked against the synced policeGroups state bag
function bridge.hasGroup(groups)
    if not groups then return false end
    local groupState = LocalPlayer.state.policeGroups
    if not groupState then return false end
    for i = 1, #groups do
        if groupState[groups[i]] then
            return true
        end
    end
    return false
end

function bridge.getPlayer()
    return LocalPlayer.state.policeGroups or {}
end

-- true only when clocked on, holding the ACE group alone isn't enough
function bridge.isOnDuty()
    return LocalPlayer.state.onDuty == true
end

function bridge.doesPlayerHaveJob(player, job)
    return player and player[job] == true
end

-- exports.police_job:isOnDuty()
exports('isOnDuty', function()
    return bridge.isOnDuty()
end)

return bridge
