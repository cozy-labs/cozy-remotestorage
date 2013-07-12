module.exports = class OAuthCtl

    # This is served behind the proxy
    # if the user made it here, he is already logged in
    # so we only show a 'click here to validate'

    # public method
    constructor: (@store) ->

    form: (req, res) =>

        req.query.response_type ?= 'token'

        for p in ['client_id', 'response_type', 'scope', 'redirect_uri']
            return res.error 'invalid_request' if not p in req.query

        if req.query.response_type isnt 'token'
            return res.error 'unsupported_response_type'

        req.query.permissions = @parsePermissions req.query.scope

        res.render 'form', req.query

    confirm: (req, res) =>

        return res.error 'access_denied' unless req.body.allow

        client_id = req.body.client_id
        permissions = @parsePermissions req.body.scope

        @store.authorize client_id, permissions, (err, token) ->
            return res.error 'internal_error', err if err
            hash = "access_token=#{token}&token_type=bearer"
            res.redirect req.body.redirect_uri + '#' + hash

    # transform a remotestorage scope
    # into usable permissions
    # [{path, rights}, {path, rights}]
    parsePermissions: (scope) ->
        scope.split(/[\s,]+/).map (part) ->
            s = part.split ':'
            return path: s[0], rights: s[1]
