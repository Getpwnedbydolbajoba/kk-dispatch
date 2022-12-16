fx_version 'cerulean'
game 'gta5'

author 'KKasutaja, Lil Dolbajoba'
github 'https://github.com/KKasutaja'
version '1.0.1'

ui_page 'ui/index.html'

shared_scripts {
    '@ox_lib/init.lua',
    '@es_extended/imports.lua',
    'config.lua'
}

client_script 'client/client.lua'
server_script 'server/server.lua'

files {
    'ui/index.html',
    'ui/script.js'
}

lua54 'yes'