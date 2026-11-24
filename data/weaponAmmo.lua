-- weapon hash -> ammo type (see data/evidence.lua)
-- melee, throwables, launchers and energy weapons are left out
-- calibers are approximate, change them if you want

return {
    -- ===== Handguns =====
    [`WEAPON_PISTOL`] = 'ammo-9',
    [`WEAPON_PISTOL_MK2`] = 'ammo-9',
    [`WEAPON_COMBATPISTOL`] = 'ammo-9',
    [`WEAPON_SNSPISTOL`] = 'ammo-380',
    [`WEAPON_SNSPISTOL_MK2`] = 'ammo-380',
    [`WEAPON_HEAVYPISTOL`] = 'ammo-50',
    [`WEAPON_VINTAGEPISTOL`] = 'ammo-44',
    [`WEAPON_MARKSMANPISTOL`] = 'ammo-44',
    [`WEAPON_REVOLVER`] = 'ammo-41',
    [`WEAPON_REVOLVER_MK2`] = 'ammo-41',
    [`WEAPON_DOUBLEACTION`] = 'ammo-41',
    [`WEAPON_NAVYREVOLVER`] = 'ammo-44',
    [`WEAPON_CERAMICPISTOL`] = 'ammo-50',
    [`WEAPON_APPISTOL`] = 'ammo-45',
    [`WEAPON_PISTOL50`] = 'ammo-50',

    -- ===== Assault Rifles =====
    [`WEAPON_ASSAULTRIFLE`] = 'ammo-rifle',
    [`WEAPON_ASSAULTRIFLE_MK2`] = 'ammo-rifle',
    [`WEAPON_CARBINERIFLE`] = 'ammo-rifle',
    [`WEAPON_CARBINERIFLE_MK2`] = 'ammo-rifle',
    [`WEAPON_ADVANCEDRIFLE`] = 'ammo-rifle',
    [`WEAPON_SPECIALCARBINE`] = 'ammo-rifle',
    [`WEAPON_SPECIALCARBINE_MK2`] = 'ammo-rifle',
    [`WEAPON_BULLPUPRIFLE`] = 'ammo-rifle',
    [`WEAPON_BULLPUPRIFLE_MK2`] = 'ammo-rifle',
    [`WEAPON_COMPACTRIFLE`] = 'ammo-rifle',
    [`WEAPON_MILITARYRIFLE`] = 'ammo-rifle',
    [`WEAPON_TACTICALRIFLE`] = 'ammo-rifle',
    [`WEAPON_HEAVYRIFLE`] = 'ammo-rifle',
    [`WEAPON_BATTLERIFLE`] = 'ammo-rifle',

    -- ===== Shotguns =====
    [`WEAPON_PUMPSHOTGUN`] = 'ammo-shotgun',
    [`WEAPON_PUMPSHOTGUN_MK2`] = 'ammo-shotgun',
    [`WEAPON_SAWNOFFSHOTGUN`] = 'ammo-shotgun',
    [`WEAPON_ASSAULTSHOTGUN`] = 'ammo-shotgun',
    [`WEAPON_BULLPUPSHOTGUN`] = 'ammo-shotgun',
    [`WEAPON_HEAVYSHOTGUN`] = 'ammo-shotgun',
    [`WEAPON_DBSHOTGUN`] = 'ammo-shotgun',
    [`WEAPON_AUTOSHOTGUN`] = 'ammo-shotgun',
    [`WEAPON_COMBATSHOTGUN`] = 'ammo-shotgun',
    [`WEAPON_MUSKET`] = 'ammo-musket',
    -- add-on shotgun: Shrewsbury Riot Shotgun (less-lethal, same 12-gauge shells)
    [`WEAPON_RIOTSHOTGUN`] = 'ammo-shotgun',

    -- ===== Sub-/Light Machine Guns =====
    [`WEAPON_MICROSMG`] = 'ammo-9',
    [`WEAPON_SMG`] = 'ammo-9',
    [`WEAPON_SMG_MK2`] = 'ammo-9',
    [`WEAPON_ASSAULTSMG`] = 'ammo-9',
    [`WEAPON_COMBATPDW`] = 'ammo-9',
    [`WEAPON_MACHINEPISTOL`] = 'ammo-9',
    [`WEAPON_MINISMG`] = 'ammo-9',
    [`WEAPON_GUSENBERG`] = 'ammo-45',
    [`WEAPON_MG`] = 'ammo-rifle2',
    [`WEAPON_COMBATMG`] = 'ammo-rifle2',
    [`WEAPON_COMBATMG_MK2`] = 'ammo-rifle2',

    -- ===== Sniper Rifles =====
    [`WEAPON_SNIPERRIFLE`] = 'ammo-sniper',
    [`WEAPON_HEAVYSNIPER`] = 'ammo-heavysniper',
    [`WEAPON_HEAVYSNIPER_MK2`] = 'ammo-heavysniper',
    [`WEAPON_MARKSMANRIFLE`] = 'ammo-sniper',
    [`WEAPON_MARKSMANRIFLE_MK2`] = 'ammo-sniper',
    [`WEAPON_PRECISIONRIFLE`] = 'ammo-sniper',
}
