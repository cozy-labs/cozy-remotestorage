module.exports = class StorageCtl

    BASEURL = ////public/storage//?///

    constructor: (@store) ->

    allowCors: (req, res, next) =>

        req.token = req.get('Authorization')?.replace 'Bearer ', ''

        res.set
            'Access-Control-Allow-Credentials': true
            'Access-Control-Allow-Origin' : req.headers.origin or '*'
            'Access-Control-Allow-Methods': 'GET, PUT, DELETE'
            'Access-Control-Allow-Headers': 'Content-Type, Authorization, If-None-Match, ETag'

        next()

    options: (req, res) =>
        res.send 200

    get: (req, res) =>

        path = req.url.replace BASEURL, ''

        @checkPermissions path, req.token, 'r', (err, ok) =>
            console.log err if err
            return res.error 'invalid_token' unless ok

            @store.get path, (err, result) ->
                try
                    return res.send 500 if err
                    return res.send 404 unless result

                    if result._isDir
                        delete result._isDir
                        res.send result
                    else
                        result.pipe res
                catch error
                    console.log error

    put: (req, res) =>

        path = req.url.replace BASEURL, ''

        @checkPermissions path, req.token, 'rw', (err, ok) =>
            console.log err if err
            return res.error 'invalid_token' unless ok

            @store.put path, req.get('Content-Type'), req.buffer,
            (err, result) ->
                console.log err if err
                return res.send 500 if err

                res.send result


    del: (req, res) =>

        path = req.url.replace BASEURL, ''

        @checkPermissions path, req.token, 'rw', (err, ok) =>
            console.log err if err
            return res.error 'invalid_token' unless ok

            @store.del path, (err, result) ->
                console.log err if err
                return res.send 500 if err

                res.send 204


    checkPermissions: (path, token, rights, callback) =>

        if /^public/.test(path) and rights is 'r'
            return callback null, true

        @store.getTokenPermissions token, (err, permission) =>

            return callback err, false if err

            for allowed in permission

                pathTester = new RegExp('^(?:public/)?' + allowed.path)

                if (allowed.rights is 'rw' or rights is 'r') \
                and (allowed.path is 'root' or pathTester.test path)
                    return callback null, true

            return callback null, false

