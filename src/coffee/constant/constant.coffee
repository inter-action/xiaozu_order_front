path = require 'path'
fs = require 'fs'

getUserHomeDirectory = ()->
    process.env[if process.platform is 'win32' then 'USERPROFILE' else 'HOME']

CONSTANTS =
    # image folder path, with a default value of course
    LOG_PATH: process.env.LOG_PATH || getUserHomeDirectory() + '/temp/log'
    CRAWLER_JAR_NAME: 'XIAOZU_CRAWLER-assembly-0.1-SNAPSHOT.jar'

CONSTANTS.CRAWLER_JAR_PATH = ( ->
    rootpath = path.normalize(__dirname + '/../../../')
    jar_path = 'assets/' + CONSTANTS.CRAWLER_JAR_NAME
    path.join(rootpath, jar_path)
)()



CODES =
    SUCCESS: 0x00
    FAILURE: 0x01
    NOT_LOGIN: 0x10

_validate_jar_exitence = ->
    console.log("crawler jar path is: #{CONSTANTS.CRAWLER_JAR_PATH}")
    if not fs.existsSync(CONSTANTS.CRAWLER_JAR_PATH)
        throw new Error("cant not find crawler jar file in : #{CONSTANTS.CRAWLER_JAR_PATH}")


module.exports = 
    CONSTANTS: CONSTANTS
    CODES: CODES

# start initialization

_validate_jar_exitence()
console.log('** CONSTANT MODULE LOADED **')