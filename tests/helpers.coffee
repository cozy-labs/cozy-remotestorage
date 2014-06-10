Client = require('request-json').JsonClient

TESTPORT = 8888

module.exports =

    init: (done) ->
        @app = require('../server')
        @server = @app.listen TESTPORT, '0.0.0.0', done

    killServer: ->
        @server.close()

    destroyAll: (model) -> (done) ->
        model.requestDestroy 'all', done


    createTestPermission: (RemoteStoragePermission) ->(done) ->
        data =
            client_id     : 'test'
            token         : 'token'
            scope         : [{path:'test', rights:'rw'}]

        RemoteStoragePermission.create data, done

    makeTestClient: (done) ->
      old = new Client "http://localhost:#{TESTPORT}/"

      old.auth = "Bearer token"

      store = this # this will be the common scope of tests

      callbackFactory = (done) -> (error, response, body) =>
          throw error if(error)
          store.response = response
          store.body = body
          done()

      clean = ->
          store.response = null
          store.body = null

      store.client =
          get: (url, done) ->
              clean()
              old.get url, callbackFactory(done)
          post: (url, data, done) ->
              clean()
              old.post url, data, callbackFactory(done)
          put: (url, data, done) ->
              clean()
              old.put url, data, callbackFactory(done)
          del: (url, done) ->
              clean()
              old.del url, callbackFactory(done)
          sendFile: (url, path, done) ->
              old.sendFile url, path, callbackFactory(done)
          saveFile: (url, path, done) ->
              old.saveFile url, path, callbackFactory(done)

      done()
