request = require 'request'
_ = require 'underscore'

class Pagination
    constructor: (@pageno, @max) ->
        @skip = (pageno - 1) * max
        @total = 0

    query: (query, success_callback, failure_callback)->
        promise = query.skip(@skip).limit(@max).exec()
        promise.then( (results)=>
            @results = results

            delete query.options.sort#fix: Error: sort cannot be used with count
            #remove pagination so we can find the count we wanted
            delete query.options.skip
            delete query.options.limit

            query.count().exec()
        ).then( (total)=>
            @total = total

            success_callback(this)
        ).then(null, (error)->
            failure_callback(error)
        )


# configure request accept cookie
request.defaults({jar: true})
jar = request.jar()
request = request.defaults({jar: jar})


# https://github.com/request/request#forms
_request =
    # send a http post
    # @params
    #   callback: (error, response, body)
    # @example
    #   (error, response, body)->
    #       if response.statusCode == 200
    #           console.log(body)
    post: (url, data, callback)->
        request.post({url:url, formData: data}, callback)

    #
    get: (url, callback)->
        #@params {http.IncomingMessage} resp , http://nodejs.org/api/http.html#http_http_incomingmessage
        #
        request.get(url).on 'response', (resp)->
            # console.log(resp.statusCode)
            # console.log(resp.headers['content-type'])
            resp.on 'data', (buffer)->
                callback(buffer.toString('utf-8'))

    # send a http post with json result
    # @params
    #   callback: (error, response, jsonResult)
    postJSON:(url, data, callback)->
        options =
            url: url
            form: data
            json: true
            method: 'POST'

        request(options, callback)

    ###
    用于发送Http请求, 这个方法存在的意义就是为了能够提交下面这样的数据
        bid:NzU0MTk=
        food_id[]:197877
        food_id[]:214412
        zhushi:194830
        quantity:1
    @params
        url: String -
        dataArr: Array[Array] - 提交表单的二维数组
            eg.
            data = [
                ['bid', 'NzU0MTk=']
                ['food_id[]', '197877']
                ['food_id[]', '214412']
                ['zhushi', '194830']
                ['quantity', '1']
            ]
        callback: Function(err, resp, body) - 回调
            eg.
            console.log(resp.statusCode)
            console.log(body)

    ###
    postJSONRaw: (url, dataArr, callback)->
        options =
            url: url
            form: encodeFormDataStr(dataArr)
            headers:
                'X-Requested-With': 'XMLHttpRequest'
        request.post options, callback

    ###
    设置cookie
    var j = request.jar();
    var cookie = request.cookie('key1=value1');
    var url = 'http://www.google.com';
    j.setCookie(cookie, url);
    ###
    setCookie: (url, cookieStr)->
        cookie = request.cookie(cookieStr)
        jar.setCookie(cookie, url)
        #

_request.setCookie('http://fuhua.xiaozufan.com/', 'PHPSESSID=oc009ls05egr8uh06nhsgfnuv5')

# 编码表单数据  application/x-www-form-urlencoded;
encodeFormDataStr = (arr)->
    result = _.map arr, (subarr)->
        encoded = _.map subarr, (nameOrValue)->
            encodeURIComponent(nameOrValue)
        encoded.join('=')

    result.join('&')

scripts =
    testXiaozu: ->
        _request.get('http://fuhua.xiaozufan.com/Index/orderToday')
    testPlaceOrder: ->
        ###
        bid:NzU0MTk=
        food_id[]:197877
        food_id[]:214412
        zhushi:194830
        quantity:1
        ###

        # 莲藕炒肉 + 老厨白菜 (配米饭) ：易众园
        # data =
        #     'bid': 'NzU0MTk='
        #     'food_id': ['197877', '214412']
        #     'zhushi': '194830'
        #     'quantity':1

        # _request.postJSON 'http://fuhua.xiaozufan.com/Index/orderadd', data, (err, resp, jsonResult)->
        #     console.log(jsonResult)

        data = [
            ['bid', 'NzU0MTk=']
            ['food_id[]', '197877']
            ['food_id[]', '214412']
            ['zhushi', '194830']
            ['quantity', '1']
        ]
        options =
            url: 'http://fuhua.xiaozufan.com/Index/orderadd'
            form: encodeFormDataStr(data)
            headers:
                'X-Requested-With': 'XMLHttpRequest'

        request.post options, (err, resp, body)->
            console.log(err) if err
            console.log(resp.statusCode)
            console.log(body)

module.exports =
    Pagination: Pagination
    request: _request
    scripts: scripts
