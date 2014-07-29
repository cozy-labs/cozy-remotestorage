url = require 'url'
RemoteStoragePerm = require '../models/permissions'

HUMANPERMISSIONS =
    'r': 'Read'
    'rw': 'Read & Write'


module.exports =

    form: (req, res) ->
        # display form
        urlObj = url.parse(req.url, true)
        scopes = decodeURIComponent(urlObj.query['scope']).split(' ')
        clientId = decodeURIComponent(urlObj.query['client_id'])
        redirectUri = decodeURIComponent(urlObj.query['redirect_uri'])
        state = if urlObj.query['state'] then decodeURIComponent(urlObj.query['state']) else undefined
        remotestorageServer = require('./storage').getRemoteStorageServer()
        scopePaths = remotestorageServer.makeScopePaths(scopes)

        details = {redirectUri, clientId}


        RemoteStoragePerm.createToken scopePaths, details, (token, needallow) ->
        # do (token= 'test', needallow = true) ->

            state = if state then '&state=' + state  else ''
            perms = scopes.map (scope) ->
                [path, right] = scope.split ':'
                return "<li>#{HUMANPERMISSIONS[right]} #{path} </li>"


            if needallow
                res.end """
                    <html>
                        <head>
                            <style>
                                #container{
                                    position: absolute;
                                    margin auto;
                                    width: 500px;
                                    border: 2px solid #54a6ff;
                                    padding: 50px;
                                }
                                a{
                                    display: block;
                                    width: 80%;
                                    background-color: #54a6ff;
                                    color: white;
                                    text-decoration: none;
                                    text-align: center;
                                    padding: 10px;
                                }
                                a:hover{
                                    background-color: orange;
                                }


                            </style>

                        </head>
                        <body>
                            <div id="container">
                                <p>Allow Application <strong>#{clientId}</strong> at #{redirectUri} the following permissions</p>
                                <ul> #{perms} </ul>
                                <a target="_top" href="#{redirectUri}#access_token=#{token}#{state}">Allow</a>
                            </div>
                        </body>
                    </html>
                """
            else
                res.redirect "#{redirectUri}#access_token=#{token}#{state}"




