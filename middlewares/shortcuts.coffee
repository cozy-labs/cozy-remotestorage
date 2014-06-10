
module.exports = (req, res, next) ->

    res.error = (error, errobject) ->

        console.log 'ERROR ', error
        console.log(errobject.stack or errobject) if errobject

        switch error
            when 'invalid_request'
                status = 400
                description = 'Required parameter missing'

            when 'unsupported_response_type'
                status = 400
                description = 'Response type unsupported'

            when 'access_denied'
                status = 403
                description = 'The user did not grant permissions'

            when 'invalid_token'
                status = 401
                description = 'The token is invalid'

            when 'not_enough_permission'
                status = 403
                description = 'This token cannot access requested path'

            else
                status = 500
                description = 'Something broke'

        res.send
            error: error
            error_description: description
        , status

    next()