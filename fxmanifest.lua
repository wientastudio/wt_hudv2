fx_version 'cerulean'
game 'gta5'

author 'Wienta Studio'
description 'Wienta HUD'
version '1.0.0'

lua54 'yes'

ui_page 'html/index.html'

shared_scripts {
    'config.lua',
    'shared/utils.lua'
}

client_scripts {
    'client/main.lua',
    'client/player.lua',
    'client/status.lua',
    'client/vehicle.lua',
    'client/minimap.lua',
    'client/location.lua',
    'client/voice.lua',
    'client/weapon.lua',
    'client/cinematic.lua',
    'client/settings.lua'
}

server_scripts {
    'server/main.lua'
}

files {
    'html/index.html',

    'html/css/*.css',
    'html/js/*.js',

    'data/postals.json'
}

dependencies {
    'qb-core',
    'ox_inventory',
    'pma-voice'
}