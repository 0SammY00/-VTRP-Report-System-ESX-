fx_version 'cerulean'
game 'gta5'

description 'Moderný ESX Report System'
version '1.0.0'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}

client_script 'client.lua'
server_script 'server.lua'

shared_script '@es_extended/imports.lua' -- Načítanie ESX