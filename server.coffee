OAuthCtl     = require './controllers/oauth'
StorageCtl   = require './controllers/storage'
CozyStore    = require './stores/datasystem'
shortcuts    = require './middlewares/shortcuts'
rawbuffer    = require './middlewares/rawbuffer'
models       = require './stores/models'
express      = require 'express'

module.exports = app = express()

app.use '/oauth', express.bodyParser()
app.use '/public/storage', rawbuffer

app.use express.logger 'dev'
app.use shortcuts

app.set 'view',        __dirname + '/views'
app.set 'view engine', 'jade'

store    = new CozyStore models


noclientmsg = (req, res) -> res.send 'This app has no client.'
app.get    '/'                 , noclientmsg


oauth    = new OAuthCtl     store
app.get     '/oauth'           , oauth.form
app.post    '/oauth'           , oauth.confirm


storage  = new StorageCtl   store
app.all     '/public/storage/*'  , storage.allowCors
app.options '/public/storage/*'  , storage.options
app.get     '/public/storage/*'  , storage.get
app.put     '/public/storage/*'  , storage.put
app.del     '/public/storage/*'  , storage.del


if not module.parent
    port = process.env.PORT or 9115
    host = process.env.HOST or "127.0.0.1"

    app.listen port, host, ->
        console.log "Server listening on %s:%d within %s environment",
            host, port, app.get('env')
