#node modules
child_process = require 'child_process'

# 3rd party
request = require 'request'
_ = require 'underscore'

#
CONSTANT = require('../constant/constant').CONSTANTS
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
# 用于发送 Http 请求
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

# Shell 交互
_Shell = 
    # child_process.exec has limitation of 512 memory usage
    # @see http://stackoverflow.com/questions/5775088/is-it-possible-to-execute-an-external-program-from-within-node-js
    # callback: (error, stdout, stderr)=>None
    crawl_data: (callback)->
        cmd = "java -jar #{CONSTANT.CRAWLER_JAR_PATH}"
        child_process.exec(cmd, callback)

    # update data with spawn child process
    #@params ondata_cb {Function} (str)->
    #@params onclose_cb {Function} (exit_code)->
    spawn_crawl_data: (ondata_cb, onclose_cb)->
        spawn = require('child_process').spawn
        prc = spawn('java',  ['-jar', '-Xmx512M', '-Dfile.encoding=utf8', CONSTANT.CRAWLER_JAR_PATH]);

        prc.stdout.setEncoding('utf8')
        prc.stdout.on 'data', ondata_cb

        prc.on 'close', onclose_cb

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

    testCrawData: ->
        _Shell.crawl_data (err, stdout, stderr)->
            data = err or stderr or stdout
            console.log(data)

    testSpwanCrawlData: ->
        #http://stackoverflow.com/questions/6463052/how-to-pass-two-anonymous-functions-as-arguments-in-coffescript
        _Shell.spawn_crawl_data \
            (data)->
                console.log(data)
            ,(code)->
                console.log("process exit code is: #{code}")

module.exports =
    Pagination: Pagination
    request: _request
    scripts: scripts
    Shell: _Shell
