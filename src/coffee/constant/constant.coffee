getUserHomeDirectory = ()->
    process.env[if process.platform is 'win32' then 'USERPROFILE' else 'HOME']

CONSTANTS =
    # image folder path, with a default value of course
    LOG_PATH: process.env.LOG_PATH || getUserHomeDirectory() + '/temp/log'

CODES =
	SUCCESS: 0x00
	FAILURE: 0x01
	NOT_LOGIN: 0x10

module.exports = 
	CONSTANTS: CONSTANTS
	CODES: CODES

console.log('** CONSTANT MODULE LOADED **')