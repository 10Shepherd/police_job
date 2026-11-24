fx_version 'cerulean'
game 'gta5'
use_experimental_fxv2_oal 'yes'
lua54 'yes'

name 'police_job'
author '10shepherd'
description 'Standalone police job'
version '1.0.0'

files {
    "audiodata/nd_police.dat54.rel",
    "audiodirectory/nd_police.awc",
    "data/**",
    "bridge/**/client.lua",
    "locales/*.json"
}

data_file "DLC_ITYP_REQUEST" "stream/cuffs_main.ytyp"
data_file "AUDIO_WAVEPACK" "audiodirectory"
data_file "AUDIO_SOUNDDATA" "audiodata/nd_police.dat"

dependencies {
    "ox_target",
    "ox_lib",
    "oxmysql"
}

shared_scripts {
    "@ox_lib/init.lua",
    "shared/bridge.lua"
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
    'server/evidence.lua',
    'server/cuff.lua',
    'server/duty.lua',
    'server/callsigns.lua',
    'server/officerBlips.lua',
    'server/jailing.lua'
}

client_scripts {
    'client/main.lua',
    'client/cuff.lua',
    'client/escort.lua',
    'client/evidence.lua',
    'client/gsr.lua',
    'client/duty.lua',
    'client/callsigns.lua',
    'client/officerBlips.lua',
    'client/jailing.lua'
}
