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
    -- add-on pistols
    [`WEAPON_GLOCK17`] = 'ammo-9',
    [`WEAPON_GLOCK19`] = 'ammo-9',
    [`WEAPON_M9A3`] = 'ammo-9',
    [`WEAPON_MP`] = 'ammo-9',
    [`WEAPON_P226R`] = 'ammo-9',
    [`WEAPON_SAFETYPISTOL`] = 'ammo-9', -- SIG P320
    [`WEAPON_P320C`] = 'ammo-9',
    [`WEAPON_P99`] = 'ammo-9',
    [`WEAPON_FN509`] = 'ammo-9',
    [`WEAPON_MODEL659`] = 'ammo-9',
    [`WEAPON_TX22`] = 'ammo-22', -- Taurus TX22 is genuinely .22 LR

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
    -- add-on rifles
    [`WEAPON_PM4`] = 'ammo-rifle',
    [`WEAPON_R9`] = 'ammo-rifle',
    [`WEAPON_AR15RIS2`] = 'ammo-rifle',
    [`WEAPON_AR15RIS3`] = 'ammo-rifle',
    [`WEAPON_M27`] = 'ammo-rifle',
    [`WEAPON_M16A1`] = 'ammo-rifle',
    [`WEAPON_M4`] = 'ammo-rifle',
    [`WEAPON_M4A1`] = 'ammo-rifle',
    [`WEAPON_HK416B`] = 'ammo-rifle',
    [`WEAPON_SCARH`] = 'ammo-rifle',

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
    -- add-on shotguns
    [`WEAPON_590`] = 'ammo-shotgun',
    [`WEAPON_BEANBAG`] = 'ammo-shotgun',
    [`WEAPON_BENELLI`] = 'ammo-shotgun',
    [`WEAPON_SUPERNOVA`] = 'ammo-shotgun',

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
    [`WEAPON_TACTICALSNIPER`] = 'ammo-sniper',
    [`WEAPON_TACTICALSNIPER_FDE`] = 'ammo-sniper',
    [`WEAPON_TACTICALSNIPER_TANODIZED`] = 'ammo-sniper',
}
