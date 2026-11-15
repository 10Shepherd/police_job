-- /callsign [text], no text clears it
RegisterCommand("callsign", function(source, args)
    TriggerServerEvent("police_job:setCallsign", table.concat(args, " "))
end, false)

TriggerEvent('chat:addSuggestion', '/callsign', 'Set your callsign shown on the on-duty officer blip', {
    { name="text", help="e.g. 1-Adam-12 (leave blank to clear)" }
})
