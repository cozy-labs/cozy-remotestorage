americano = require 'americano'

module.exports = RemoteStoragePerm = americano.getModel 'RemoteStoragePerm',
    _id: String
    key: String
    value: (x) -> x # array
    details: (x) -> x #object

RemoteStoragePerm.all = (callback) ->
    RemoteStoragePerm.request 'byKey', {}, (err, docs) ->
        callback err, docs


RemoteStoragePerm.byKey = (key, callback) ->
    RemoteStoragePerm.request 'byKey', {key}, (err, docs) ->
        callback err, docs?[0]


RemoteStoragePerm.bySame = (scopePaths, details, callback) ->
    params = key: (details.redirectUri + details.clientId + scopePaths.join(' '))
    RemoteStoragePerm.request 'bySame', params, (err, docs) ->
        callback err, docs?[0]


RemoteStoragePerm.asStore =
    get: (u, key, cb) ->
        console.log "KEY = ", key
        RemoteStoragePerm.byKey key, (err, doc) ->
            console.log "PERM RESULT = ", doc?.value
            cb err, doc?.value

RemoteStoragePerm.createToken = (scopePaths, details, callback) ->
    RemoteStoragePerm.bySame scopePaths, details, (err, doc) ->
        return callback err if err
        if doc
            console.log doc
            # because we create the token immediately, we have to confirm every time
            callback doc.key, true
        else
            require('crypto').randomBytes 48, (ex, buf) ->
                token = buf.toString('hex')
                RemoteStoragePerm.create {key: token, value: scopePaths, details}, (err) ->
                    callback token, true