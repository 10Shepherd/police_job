return {
    -- seconds between blip updates
    interval = 3,

    -- other player state bag keys that can also see officer blips, e.g. on-duty EMS
    shareWithStates = { "ambulanceOnDuty" },

    -- blip sprite ids
    sprites = {
        foot = 1,   -- plain circle
        car  = 56,  -- "Cop Car"
        bike = 225, -- "Personal Vehicle Bike"
        heli = 64   -- Helicopter (animated rotor)
    },

    color = 3,  -- blue
    scale = 0.8,
    shortRange = true
}
