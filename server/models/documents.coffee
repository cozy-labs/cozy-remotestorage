americano = require 'americano'

module.exports = RemoteStorageDoc = americano.getModel 'RemoteStorageDoc',
    key: String
    value: String


RemoteStorageDoc.byKey = (key, callback) ->
    RemoteStorageDoc.request 'byKey', {key}, (err, docs) ->
        callback err, docs?[0]


RemoteStorageDoc.asStore =
    get: (u, key, cb) ->
        console.log "GET CALLED"
        RemoteStorageDoc.byKey key, (err, doc) ->
            console.log "GET", doc
            value = if doc then new Buffer(doc.value.trim(), 'utf8') else undefined
            cb err, value
    set: (u, key, buf, cb) ->
        console.log "SET CALLED", u, key, buf
        RemoteStorageDoc.byKey key, (err, doc) ->
            return cb err if err

            # SET undefined === DELETE
            if not buf?
                if not doc?
                    console.error 'Document to delete not found!'
                    cb 'Document not found'
                else
                    doc.destroy cb
            else
                value = buf.toString('utf8')
                console.log "SET", key, value
                if doc
                    doc.updateAttributes {value}, cb
                else
                    RemoteStorageDoc.create {key, value}, cb
