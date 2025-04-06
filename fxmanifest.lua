fx_version 'adamant'

game 'gta5'

author 'Aimcon'

version '1.0'

lua54 'yes'

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'config_sv.lua',
	'server/*.lua',
}

client_scripts {
	'config_cl.lua',
	'client/*.lua',
}

shared_script {
	'@es_extended/imports.lua',
	'@ox_lib/init.lua'
}
