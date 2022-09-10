fx_version 'cerulean'
game 'gta5'

author 'KKasutaja'
github 'https://github.com/KKasutaja'

ui_page 'ui/index.html'

shared_scripts {
    '@ox_lib/init.lua',
    '@es_extended/imports.lua'
}

client_script 'client.lua'
server_script 'server.lua'

files {
    'ui/index.html',
    'ui/script.js'
}

lua54 'yes'