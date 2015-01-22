'user strict'


mongoose = require 'mongoose'
assert = require 'assert'

log = require '../logger/logger'

DB_NAME = 'xiaozu_crawler'

#mongoose.connect('mongodb://username:password@host:port/database?options...');
mongoose.connect("mongodb://localhost:27017/#{DB_NAME}")

#listen mongodb connection event
mongoose.connection.on 'errror', console.error.bind(console, 'connection error')
mongoose.connection.once 'open', ->
    console.log 'mongodb successfully connected'


exports = module.exports = {}

#exports moongoose
exports.mongoose = mongoose



# ----------- start: user definition
UserSchemaOption =
    username: 
        type: String
        required: true
    ip:
        type: String
        default: 0
    isLogin:
        type: Number
        default: 0
    privilige:
        type: Number
        default: 0
    createdTime:
        type: Date
        default: Date.now


exports.UserModel = mongoose.model('User', userSchema = mongoose.Schema(UserSchemaOption))
# ----------- end: user definition

# ----------- start: AuditLog definition
AuditLogSchemaOption
    body:
        type: String
        required: true
    type:
        type: Number
        required: true
    createdTime:
        type: Date
        default: Date.now

exports.AuditLogModel = mongoose.model('AuditLog', auditLogSchemaInstance = mongoose.Schema(AuditLogSchemaOption))
exports.AuditLogModel.typies =
    PLACE_ORDER: 0x00 # 下订单

# ----------- end: AuditLog definition


MENU_COLLECTION = 'menu'
exports.listMenus = (query = {}, callback)->
    mongoose.connection.db.collection MENU_COLLECTION, (err, collection)->
        console.log(err) if err
        collection.find(query).toArray callback


exports.script =
    listMenus: ->
        callback = (err, docs) ->
            throw err if err
            console.log(JSON.stringify(docs))

        mongoose.connection.db.collection MENU_COLLECTION, (err, collection)->
            console.log(err) if err

            collection.find({}).toArray callback

    # mongoose batch insertion
    # see http://stackoverflow.com/questions/16726330/mongoose-mongodb-batch-insert
    batchInsertUser: ->
        exports.UserModel.remove {}, (err)->
            if err
                console.log err
            else
                usernames = ['张硕', '袁海杰', '王鹤林', '朱海波', '赵鹏', '朱文豪']
                users = []

                for username in usernames
                    users.push({username: username})

                exports.UserModel.collection.insert users, null, (err, docs)->
                    console.log err if err
                    assert.ok(docs.length == users.length)
                    console.log "successfully isnerted #{docs.length} records"

    # 重置用户登录状态
    resetUserLoginState: ->
        exports.UserModel.update {}, {isLogin: 0}, (err, numAffected)->
            if err then console.log err else console.log "#{numAffected} records updated"

# ----- start: module init
exports.script.resetUserLoginState()

console.log('** DAO MODULE LOADED **')