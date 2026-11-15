RegisterNetEvent("police_job:toggleDuty", function()
    local src = source
    local state = Player(src).state

    -- not while cuffed, cuffing, escorted or hands up
    if state.isCuffed or state.isCuffing or state.gettingCuffed or state.isEscorted or state.handsUp then
        return Bridge.notify(src, {
            type = "error",
            description = locale("cant_do_this")
        })
    end

    local wasOnDuty = Bridge.isOnDuty(src)

    -- setDuty checks the ACE group
    if not Bridge.setDuty(src, not wasOnDuty) then
        return Bridge.notify(src, {
            type = "error",
            description = locale("no_perms_duty")
        })
    end

    Bridge.notify(src, {
        type = "success",
        description = (not wasOnDuty) and locale("now_on_duty") or locale("now_off_duty")
    })
end)
