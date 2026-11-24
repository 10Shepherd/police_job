return {
    -- ACE groups that count as police
    policeGroups = {
        "group.leo",
        "group.leoc",
        "group.leohc",
        "group.management",
    },

    -- command to toggle duty from anywhere
    dutyCommand = "policeduty",

    -- ACE groups allowed to use /jail and /unjail
    jailCommandGroups = { "group.admin" },
    unjailCommandGroups = { "group.admin" },

    clearGSR = 20, -- time in minutes
    clearGSRinWater = 2, -- minutes

    minImpoundPrice = 100,
    maxImpoundPrice = 500,
    defaultImpoundPrice = 200, -- this should be within the max and min above.

    -- seconds between ACE group re-checks
    permissionRefreshInterval = 30
}
