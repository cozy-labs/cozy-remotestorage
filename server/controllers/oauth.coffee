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
                                body {
                                    font-family: "Helvetica Neue", Helvetica;
                                    background: #FAFAFA;
                                    padding: 0 0 20px 0;
                                    margin: 0;
                                    color: #42403D;
                                }
                                #container {
                                    margin: auto;
                                    margin-top: 20px;
                                    max-width: 500px;
                                    border: 2px solid #42403D;
                                    padding: 50px;
                                }
                                a {
                                    background-color: #c4baab;
                                    color: #42403D;
                                    display: block;
                                    width: 80%;
                                    margin: auto;
                                    margin-top: 30px;
                                    color: white;
                                    text-decoration: none;
                                    text-align: center;
                                    padding: 10px;
                                }
                                a:hover {
                                    background-color: #F84A04;
                                }

                                img {
                                    float: left;
                                    margin-right: 20px;
                                }

                                p {
                                    margin-top: 0;
                                }

                            </style>

                        </head>
                        <body>
                            <div id="container">
                                <img src="../icon.png" alt="Remote Storage Logo" />
                                <p>Do you want to allow to the application <strong>#{clientId}</strong> at #{redirectUri} the following permissions on your Cozy Remote Storage?</p>
                                <ul> #{perms} </ul>
                                <a target="_top" href="#{redirectUri}#access_token=#{token}#{state}">Allow</a>
                            </div>
                        </body>
                    </html>
                """
            else
                res.redirect "#{redirectUri}#access_token=#{token}#{state}"




