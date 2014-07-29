americano = require 'americano'

application = module.exports = (callback) ->
    options =
        name: 'cozy-remotestorage'
        root: __dirname
        port: process.env.PORT || 8000
        host: process.env.HOST || '127.0.0.1'

    americano.start options, (app, server) ->
        app.server = server

if not module.parent
    application()
