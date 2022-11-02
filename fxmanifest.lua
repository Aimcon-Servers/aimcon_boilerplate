fx_version 'adamant'

game 'gta5'

version '1.1'

server_scripts {
	"@mysql-async/lib/MySQL.lua",
	'config_sv.lua',
	'server/main.lua'
}

client_scripts {
	'config_cl.lua',
	'client/functions.lua',
	'client/main.lua'
}
