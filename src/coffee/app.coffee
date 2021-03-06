###
@author miujing
@date 2014.11.4
###

# node dependencies
http = require 'http'
path = require 'path'

#express dependencies
express = require 'express'
cookieParser = require 'cookie-parser'
bodyParser = require 'body-parser'
session = require 'express-session'


# my dependencies
log = require './logger/logger'
CODES = require('./constant/constant').CODES

ROOT_PATH = path.normalize(__dirname + '/../../')

# -------- START: express setting up
app = express()
#WARNING: IN EXPRESS 4.XX, THE ONLY BUILDED-IN MIDDLE-WARE IS STATIC MIDDLEWARE, OTHERS ARE
#ALL REMOVED FROM EXPRESS 4.XX, THEY ALL INCLUDED IN
#CONNECT(https://github.com/senchalabs/connect) PACKAGE

# set up static middleware
static_middleware_options =
    dotafiles: 'ignore'
STATIC_FILE_PATH = path.join(ROOT_PATH, 'public')
log.info("use path : #{STATIC_FILE_PATH} as static files")
app.use(express.static(STATIC_FILE_PATH, static_middleware_options))

#set view path
VIEW_PATH = path.join(ROOT_PATH, 'views')
app.set('views', VIEW_PATH)
log.info "use path: #{VIEW_PATH} as views path"

#set the view engine to ejg
app.set('view engine', 'ejs')

#enable trust proxy for  X-Forwarded-* to work, 这个头信息记录的是ip地址, 如果proxy不被信任,这个节点的值就不可靠
app.enable('trust proxy')

# ------ START: SET UP MIDDLEWARES

## set up body-parser middleware
app.use bodyParser.urlencoded({ extended: false })  #parse application/x-www-form-urlencoded
app.use bodyParser.json()    # parse application/json
#app.use bodyParser.multipart()

## set up cookieParser middleware
app.use cookieParser()

## setting up session
sessionOption =
    secret: 'secret_key'
    resave: false
    saveUninitialized: true
    cookie:
        maxAge: 1800000 #session duration, half hour

app.use session(sessionOption)

app.use (req, res, next)->
    console.log("[LOGIN INTERCEPTOR] --> #{req.method.toLowerCase()}, #{req.path}, #{JSON.stringify(req.session.user)}")
    if req.method.toLowerCase() == 'post' and req.path.indexOf('login') == -1 and not req.session.user
        res.status(401).end()
    else
        next()

_exports = module.exports = {}
_exports.server = http.createServer(app)
routes = require './routes/routes'

# set up routes
app.use('/', routes)

# catch 404 error
app.use (req, res, next)->
    error = new Error('Not Found')
    error.status = 404
    next(error)


# setting up error handling stack
env = process.env.NODE_ENV || 'development'
if env is 'development'
    app.use (error, req, res, next)->
        res.status(error.status || 500)
        res.render 'error', {
            message: error.message,
            error: error
        }

#production error handler
#no stacktraces leaked to user
app.use (error, req, res, next)->
    res.status(error.status || 500)
    res.render 'error', {
        message: error.message,
        error: {}
    }


# -------- ENDS: express setting up

PORT = 3000
#app.listen PORT
_exports.server.listen(PORT)

console.log "app started at port: #{PORT} with env: #{env}"
