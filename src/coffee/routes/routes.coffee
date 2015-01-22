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
CODES = require('../constant/constant').CODES 


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
        audit: JSON str
            {foods: , username}
###
router.post '/order/combo', (req, res)->
    data = req.body.data

    assert.ok(data.bid)
    assert.ok(data.foodIds.length isnt 0)
    assert.ok(data.zhushi)
    assert.ok(data.audit) # this seems a security issue, it's not big deal since this app will run in a trusted env

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
        if err
            res.send 500, MSG_BAD_GATEWAY 
        else
            auditInstance = new dao.AuditLogModel {body: JSON.stringify(data.audit), type: dao.AuditLogModel.types.PLACE_ORDER}
            auditInstance.save() # we dont care if success or not

            orderResult = JSON.parse(body)
            if orderResult.status is 1 then res.json({code: CODES.SUCCESS}) else res.json({code: CODES.FAILURE, msg: orderResult.info})


###
    data
        fid:MTYwMTE3
        bid:NjA3MTM=
        quantity:1
        audit: JSON str
            {foods: , username}

###
router.post '/order/single', (req, res)->
    data = req.body.data
    assert.ok(data.fid and data.bid)
    assert.ok(data.audit)

    postDataArr = [
        ['fid', data.fid]
        ['bid', data.bid]
        ['quantity', 1]
    ]

    placeSingleOrder postDataArr, (err, httpResponse, body)->
        if err
            res.send 500, MSG_BAD_GATEWAY
        else
            auditInstance = new dao.AuditLogModel {body: JSON.stringify(data.audit), type: dao.AuditLogModel.types.PLACE_ORDER}
            auditInstance.save() # we dont care if success or not

            orderResult = JSON.parse(body)
            if orderResult.status is 1 then res.json({code: CODES.SUCCESS}) else res.json({code: CODES.FAILURE})

# 抢占式登陆, 一个用户名如果被登陆, 除非这个用户退出, 否则不能登陆
router.post '/login', (req, res)->
    username = req.body.username
    assert.ok(username)

    if req.session.user
        if username == req.session.username
            res.json({code: CODES.SUCCESS, data: req.session.user})
        else
            res.json({code: CODES.FAILURE, msg: "you already logined with user: #{req.session.username}"})
    else
        dao.UserModel.findOne {username: username}, (err, user)->
            res.send(500, MSG_BAD_GATEWAY) if err
            res.send(404, 'not found') if not user

            if user.isLogin is 1 and uesr.ip != req.ip
                res.json({code: CODES.FAILURE, msg: "#{username} is logined by this ip:#{user.ip}"})
            else # user is not login or user is login and his/her ip is same with the record in database
                user.isLogin = 1
                user.ip = req.ip
                user.save (err, instance)->
                    if err
                        res.send(500, MSG_BAD_GATEWAY) 
                    else
                        req.session.user = instance 
                        res.json({code: CODES.SUCCESS, data: instance})

# 退出
router.post '/logout', (req, res)->
    if req.session.user
        dao.UserModel.findOne {username: req.session.user.username}, (err, user)->
            res.send(500, MSG_BAD_GATEWAY) if err
            res.send(404, 'not found') if not user

            user.isLogin = 0
            user.ip = req.ip
            user.save (err, userInstance)->
                if err
                    res.send(500, MSG_BAD_GATEWAY)
                else
                    req.session.destroy (err)->#we dont care if success or not in here
                    res.json({code: CODES.SUCCESS})
    else
        res.json({code: CODES.FAILURE, msg: 'you are not logged-in'})


#------------ start: users routes
# user lists
router.get '/users', (req, res)->
    dao.UserModel.find {}, (err, users)->
        if err
            res.send 500, MSG_BAD_GATEWAY
        else
            res.json(users)

#------------ ends: users routes

# ---- 审计数据
router.get '/auditlogs', (req, res)->
    now = new Date()
    today = new Date(now.getFullYear(), now.getMonth(), now.getDate())
    dao.AuditLogModel.find {createdTime: { $gte: today}}, (err, audits)->
        if err then res.send(500, MSG_BAD_GATEWAY) else res.json({code: CODES.SUCCESS, data: audits})

placeComboOrder = (dataArr, callback)->
    url = 'http://fuhua.xiaozufan.com/Index/orderadd'
    util.request.postJSONRaw(url, dataArr, callback)

placeSingleOrder = (dataArr, callback)->
    url = 'http://fuhua.xiaozufan.com/Index/orderadd_dan'
    util.request.postJSONRaw url, dataArr, callback




module.exports = router

console.log('** module ./routes/routes loaded **')