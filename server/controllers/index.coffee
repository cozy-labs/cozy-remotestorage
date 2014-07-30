RemoteStoragePerm = require '../models/permissions'
url = require 'url'

HUMANPERMISSIONS =
    'r': 'Read'
    'rw': 'Read & Write'


module.exports =

    index: (req, res, next) ->

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
                    <td>#{perm.details.redirectUri}</td>
                    <td><ul>#{rights.join('')}</ul></td>
                    <td>
                        <a class="use" target="_top" href="#{perm.details.redirectUri}">Run</a>

                    </td><td>
                        <a class="delete" href="revoke?id=#{perm._id}">&times;</a>
                    </td></tr>
                    """

            html = """
                <html>
                    <head>
                        <script>
                            if(~window.location.hash.indexOf('oauth'))
                                window.location = window.location.toString().replace('#oauth', 'oauth')
                        </script>
                        <style>
                                @font-face {
                                    font-family: main;
                                    src: url(/fonts/maven-pro-light-200.otf);
                                }
                                body {
                                    font-family: main;
                                }
                                thead {
                                    background-color: #54a6ff;
                                    color: white;
                                }
                                table, table td {
                                    border: 1px solid #54a6ff;
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
                    <table>
                    <thead>
                    <tr>
                        <th>Client ID</th>
                        <th>Url</th>
                        <th>Permissions</th>
                        <th>Use It</th>
                        <th>Revoke</th>
                    </tr>
                    </thead>
                    #{perms}
                    </table>
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
