RemoteStoragePerm = require '../models/permissions'
CozyInstance = require '../models/cozyinstance'
url = require 'url'

HUMANPERMISSIONS =
    'r': 'Read'
    'rw': 'Read & Write'


module.exports =

    index: (req, res, next) ->

        CozyInstance.first (err, instance) ->
            instance ?= domain: "not.set"
            RemoteStoragePerm.all (err, perms) ->
                return next err if err

                perms = perms.map (perm) ->

                    rights = perm.value.filter (scope) ->
                        scope.indexOf('public') isnt 1
                    .map (scope) ->
                        [path, right] = scope.split ':'
                        path = path.replace(/^\//, '').replace(/\/$/, '')
                        return "<li>#{HUMANPERMISSIONS[right]} #{path} </li>"


                    redirectURI =
                        """<tr>
                        <td>#{perm.details.clientId}</td>
                        <td>
                            <a class="use" target="_top" href="#{perm.details.redirectUri}">
                            #{perm.details.redirectUri}
                            </a>
                        </td>
                        <td><ul>#{rights.join('')}</ul></td>

                        </td><td>
                            <a class="delete" href="revoke?id=#{perm._id}">&times;</a>
                        </td></tr>
                        """

                html = """
                    <html>
                        <head>
                            <link rel="shortcut icon" href="favicon.png">
                            <script>
                                if(~window.location.hash.indexOf('oauth'))
                                    window.location = window.location.toString().replace('#oauth', 'oauth')
                            </script>
                            <style>
                                    body {
                                        font-family: "Helvetica Neue", Helvetica;
                                        background: #E9E9E9;
                                        padding: 0;
                                        margin: 0;
                                    }
                                    header {
                                        padding: 10px;
                                        width: 100%;
                                        background-color: #42403D;
                                        height: 60px;
                                    }
                                    .content {
                                        max-width: 960px;
                                        margin: auto;
                                    }
                                    .header-content {
                                        color: white;
                                    }
                                    .header-content img {
                                        width: 50px;
                                        float: left;
                                        margin-right: 20px;
                                    }
                                    .header-content p {
                                        margin: 0;
                                    }
                                    thead {
                                        background-color: #42403D;
                                        font-weight: normal;
                                        color: white;
                                    }
                                    table {
                                        margin-top: 10px;
                                        width: 100%;
                                    }
                                    table, table td {
                                        border: 1px solid #42403D;
                                        border-collapse: collapse;
                                    }
                                    td, th {
                                        padding: 15px;
                                    }
                                    a.use {
                                        background-color: #54a6ff;
                                        color: white;
                                        text-decoration: none;
                                        display: inline-block;
                                        padding: 0.5em 0.5em;
                                    }
                                    a.delete {
                                        background-color: red;
                                        color: white;
                                        text-decoration: none;
                                        display: inline-block;
                                        border-radius: 0.5em;
                                        padding: 0em 0.5em;
                                    }
                                    a:hover {
                                        background-color: orange;
                                    }

                                </style>
                        </head>
                        <body>
                        <header>
                        <div class="header-content content">
                            <img src="icon.png" alt="Remote Storage Logo" />
                            <p>
                            Your Remote Storage id is me@#{instance.domain}
                            </p>
                        </div>
                        </p>
                        </header>
                        <div class="content">
                        <table>
                        <thead>
                        <tr>
                            <th>Client ID</th>
                            <th>Location</th>
                            <th>Permissions</th>
                            <th>Revoke</th>
                        </tr>
                        </thead>
                        #{perms}
                        </table>
                        </div>
                        </body>
                    </html>
                """
                res.send html

    revoke: (req, res, next) ->

        urlObj = url.parse(req.url, true)
        RemoteStoragePerm.find urlObj.query['id'], (err, perm) ->
            return next err if err
            perm.destroy (err) ->
                return next err if err
                res.redirect '/apps/remotestorage/'
