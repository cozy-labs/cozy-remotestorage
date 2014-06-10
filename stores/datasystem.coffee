fs = require 'fs'

module.exports = class DataSystemStore

    RemoteStoragePermission = null
    File = null

    constructor: (models) ->

        {RemoteStoragePermission, File} = models

    # permissions management

    authorize: (client_id, permissions, callback) =>

        data =
            client_id: client_id
            scope:     permissions
            token:     @_makeToken()

        RemoteStoragePermission.create data, (err, permission) ->
            callback err, data.token

    # storage


    # GET raw document(s) for a given path
    # callback will be called with one of
    # A - A File Instance (1 document)
    # B - An array [] (this is a folder)

    getDoc: (path, callback) =>
        # path = 'a/b/c/'
        path = path.replace(/\/$/, '')
        aPath = if path is '' then [] else path.split '/' # path = [a,b,c]
        endkey = aPath.slice(0) # copy
        endkey.push {}
        query =
            startkey: aPath # [a,b,c]
            endkey: endkey # [a,b,c,{}]

        File.request 'bypath', query, (err, docs) ->
            if not docs
                return callback err, []
            else if docs.length is 1 and docs[0].slug is aPath.join('/')
                return callback null, docs[0]
            else
                return callback null, docs

    # GET document(s) for a given path
    # callback will be called with one of
    # A - null (no document under that path)
    # B - A stream (1 document)
    # C - An remotestorage-style folder object {_isDir: true, ...}
    get: (path, callback) =>

        @getDoc path, (err, result) ->
            console.log err if err

            path = path.replace(/\/$/, '')
            aPath = if path is '' then [] else path.split '/'

            if result instanceof File
                filename = aPath[aPath.length - 1]
                return callback null, result.getFile filename, (err) ->
                    console.log err if err

            # nothing here
            return callback null, null if result.length is 0

            # this is a folder, build remotestorage-style list
            out = _isDir: true
            for doc in result
                # get relative path
                p = doc.slug.split('/').slice(aPath.length)
                if p.length is 1 # doc inside this folder
                    out[p[0]] = doc.timestamp
                else # subfolder, find newest timestamp
                    key = p[0] + '/'
                    out[key] = doc.timestamp if doc.timestamp > (out[key] or 0)

            callback null, out


    put: (path, type, buffer, callback) =>

        data =
            timestamp: new Date().valueOf()
            slug: path

        path = path.replace(/\/$/, '')
        aPath = if path is '' then [] else path.split '/'
        filename = aPath[aPath.length - 1]

        @getDoc path, (err, doc) ->

            if doc instanceof File
                doc.updateAttributes data, (err, result) ->
                    return callback err if err
                    doc.removeFile filename, (err) ->
                        return callback err if err
                        tmpfile = '/tmp/' + filename
                        fs.writeFile tmpfile, buffer, (err) ->
                            return callback err if err
                            data = name: filename, type: type
                            doc.attachFile tmpfile, data, (err) ->
                                fs.unlink tmpfile, (err) ->
                                    callback err, doc

            else if doc.length # there is already a folder here
                callback 'this_is_a_folder', null

            else
                File.create data, (err, doc) ->
                    return callback err if err
                    tmpfile = '/tmp/' + filename
                    fs.writeFile tmpfile, buffer, (err) ->
                        return callback err if err
                        data = name: filename, type: type
                        doc.attachFile tmpfile, data, (err) ->
                            fs.unlink tmpfile, (err) ->
                                callback err, doc


    delete: (path, callback) =>
        @getDoc path, (err, doc) ->
            if doc instanceof File
                doc.destroy callback

            else if doc.length # can't delete a folder
                callback 'this_is_a_folder', null

            else
                callback()

    getTokenPermissions: (token, callback) ->
        RemoteStoragePermission.request 'bytoken', key:token,
        (err, permissions) ->
            console.log err if err
            return callback err, (permissions?[0].scope or [])

    _makeToken:  (length=32) ->
        string = ""
        while string.length < length
            string += Math.random().toString(36).substr(2)
        string.substr 0, length