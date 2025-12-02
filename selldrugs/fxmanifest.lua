fx_version 'bodacious'
game 'gta5'

author 'Jeremy'
description 'Woepwoep'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config/config.lua'
}

client_scripts {
    'client/client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/server.lua'
}

dependencies {
    'es_extended',
    'ox_target',
    'ox_lib',
    'oxmysql'
}
