###
@miujing
created 2014.1.11
main express routes configuration
###
express = require 'express'
assert = require 'assert'
_ = require 'underscore'

log = require '../logger/logger'
common = require '../common/common'
dao = require '../dao/dao'
util = require '../util/util'

router = express.Router()


#GET home page
router.get '/', (req, res)->
    context =
        appName: '订单信息系统'
    res.render 'pages/index', {context: context}

# angularjs demo page
router.get '/angularjs', (req, res)->
    res.render 'pages/angularjs_demo'

MSG_BAD_GATEWAY = 'bad_gateway'

router.get '/menus', (req, res)->
    dao.listMenus(null, (err, docs)->
        res.send(500, MSG_BAD_GATEWAY) if err
        res.json(docs)
    )

###
荤素配点餐
    data = [
        ['bid', 'NzU0MTk=']
        ['food_id[]', '197877']
        ['food_id[]', '214412']
        ['zhushi', '194830']
        ['quantity', '1']
    ]
    
    data = 
        bid
        foodIds
        zhushi
###
router.post '/order/combo', (req, res)->
    data = req.body.data

    assert.ok(data.bid)
    assert.ok(data.foodIds.length isnt 0)
    assert.ok(data.zhushi)

    postDataArr = [
        ['bid', data.bid]
        ['zhushi', data.zhushi]
        ['quantity', '1']
    ]

    _.each data.foodIds, (foodId)->
        postDataArr.push(['food_id[]', foodId])
        postDataArr.push(["dandian[#{foodId}]", '1'])

    # do post data here
    placeComboOrder postDataArr, (err, httpResponse, body)->
        res.send 500, MSG_BAD_GATEWAY if err
        orderResult = JSON.parse(body)
        if orderResult.status is 1 then res.json({success: true}) else res.json({success: false, msg: orderResult.info})


###
    data
        fid:MTYwMTE3
        bid:NjA3MTM=
        quantity:1
###
router.post '/order/single', (req, res)->
    data = req.body.data
    assert.ok(data.fid and data.bid)

    postDataArr = [
        ['fid', data.fid]
        ['bid', data.bid]
        ['quantity', 1]
    ]

    placeSingleOrder postDataArr, (err, httpResponse, body)->
        res.send 500, MSG_BAD_GATEWAY if err
        orderResult = JSON.parse(body)
        if orderResult.status is 1 then res.json({success: true}) else res.json({success: false})


placeComboOrder = (dataArr, callback)->
    url = 'http://fuhua.xiaozufan.com/Index/orderadd'
    util.request.postJSONRaw(url, dataArr, callback)

placeSingleOrder = (dataArr, callback)->
    url = 'http://fuhua.xiaozufan.com/Index/orderadd_dan'
    util.request.postJSONRaw url, dataArr, callback


#----------- ends: MENU ENTRY ROUTES


module.exports = router

console.log('** module ./routes/routes loaded **')