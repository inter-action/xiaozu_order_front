'user strict'

assert = require 'assert'
mongoose = require 'mongoose'

log = require '../logger/logger'

DB_NAME = 'xiaozu_crawler'

#mongoose.connect('mongodb://username:password@host:port/database?options...');
mongoose.connect("mongodb://localhost:27017/#{DB_NAME}")

#listen mongodb connection event
mongoose.connection.on 'errror', console.error.bind(console, 'connection error')
mongoose.connection.once 'open', ->
    console.log 'mongodb successfully connected'


exports = module.exports = {}

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

console.log('** DAO MODULE LOADED **')