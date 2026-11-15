Config = lib.load("data.config")
local weaponAmmoMap = lib.load("data.weaponAmmo")

-- shot detection for evidence and GSR
CreateThread(function()
    while true do
        Wait(0)
        local weapon = cache.weapon
        local ammoType = weapon and weaponAmmoMap[weapon]

        if ammoType and IsPedShooting(cache.ped) then
            TriggerEvent("police_job:playerJustShot", { weapon = weapon, ammo = ammoType })
        end
    end
end)

-- clear old state on start
AddEventHandler("onClientResourceStart", function(resource)
    if resource ~= cache.resource then return end
    LocalPlayer.state:set('isCuffed', false, true)
    LocalPlayer.state:set('isEscorted', false, true)
end)

exports.ox_target:addGlobalVehicle({
    {
        icon = "fa-solid fa-car-side",
        label = locale("impound_vehicle"),
        distance = 1.5,
        canInteract = function()
            return Bridge.isOnDuty()
        end,
        onSelect = function(data)
            local input = lib.inputDialog(locale("impound_vehicle"), {
                {
                    type = "number",
                    label = locale("impound_reclaim_price"),
                    description = locale("impound_reclaim_price_description"),
                    icon = "money-check",
                    min = Config.minImpoundPrice,
                    max = Config.maxImpoundPrice,
                    default = Config.defaultImpoundPrice
                }
            })

            local impoundReclaimPrice = input and input[1]
            if not impoundReclaimPrice then return end

            local alert = lib.alertDialog({
                header = locale("impound_vehicle"),
                content = locale("impound_vehicle_alert", impoundReclaimPrice),
                centered = true,
                cancel = true
            })

            if alert ~= "confirm" then return end
            TriggerServerEvent("police_job:impoundVehicle", VehToNet(data.entity), impoundReclaimPrice)
        end
    }
})
