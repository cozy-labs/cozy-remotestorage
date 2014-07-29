RemoteStorageServer = require 'remotestorage-server'


store = null
getRemoteStorageServer = () ->
    return store if store
    tokenStore = require('../models/permissions').asStore
    dataStore = require('../models/documents').asStore
    specVersion = 'draft-dejong-remotestorage-01'
    return store = new RemoteStorageServer specVersion, tokenStore, dataStore


module.exports =

    getRemoteStorageServer: getRemoteStorageServer
    handler: (req, res) ->
        req.url = req.url.replace '/public/storage/', '/storage/me/'
        console.log "AFTER rewrite=", req.url, req.method
        getRemoteStorageServer().storage req, res