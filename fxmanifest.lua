fx_version 'cerulean'
game 'rdr3'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

description 'QB-Prompts'
version '1.0.0'

client_script 'client/cl_*.lua'
server_script 'server/sv_*.lua'

ui_page 'html/index.html'

dependencies {
    'qb-core'
}
