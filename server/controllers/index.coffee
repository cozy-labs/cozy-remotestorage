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

                if perms.length > 0
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
                            <td class="revoke">
                                <a class="delete" href="revoke?id=#{perm._id}">revoke</a>
                            </td></tr>
                            """
                else
                    perms = "<tr><td><em>No application connected yet.</em></td></tr>"

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
                                        background: #FAFAFA;
                                        padding: 0;
                                        margin: 0;
                                    }
                                    header {
                                        padding: 10px 0;
                                        width: 100%;
                                        background-color: #42403D;
                                        height: 60px;
                                    }
                                    h2:first-child {
                                        margin-top: 0;
                                    }
                                    .explaination {
                                        width: 100%;
                                        background: #E9E9E9;
                                        padding-top: 20px;
                                        padding-bottom: 20px;
                                        margin-bottom: 20px;
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
                                        font-weight: light;
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
                                        background-color: #c4baab;
                                        color: #42403D;
                                        text-decoration: none;
                                        display: inline-block;
                                        padding: 0.5em 0.5em;
                                        border-radius: 2px;
                                    }
                                    a {
                                        color: #42403D;
                                    }
                                    td.revoke {
                                        text-align: center;
                                    }
                                    a.use:hover {
                                        background-color: #E94809;
                                    }
                                    a.delete:hover {
                                        color: #E94809;
                                    }
                                    ul {
                                        list-style-type:
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
                        <div class="explaination">
                        <div class="content">
                        <h2>What is Remote Storage</h2>
                        <p>
                        Remote Storage is a technology that allows web
applications to let the user chose the location of their storage.
That way, users can keep their data in a place of their own. To use that kind of
web apps it requires you have a storage somewhere that respects the Remote
Storage standard. Good news, this is what the current application does: it
turns your Cozy into a Remote Storage!
</p>
<p>
Here is
<a href="https://unhosted.org/apps/">a list of compatible applications</a>.
</p>
<h2>How to use</h2>
<p>
Go on a website of a compatible application. Once there start using the service.
Then paste your remote storage id in the box
floating on one corner of the application. The box looks like this:<br>
<img src="remote.png" alt="Remote Storage stickers" />
</p>
<p>
Then the application will require for an authorization. Once you will accept,
you will be able to use the application and persist data in your Cozy.
</p>
<h2>Application list</h2>
<p>
Below you will find the list of applications that you authorize to connect to
your remote storage.
</p>
                        </div>
                        </div>
                        <div class="content">
                        <table>
                        <thead>
                        <tr>
                            <th>Client ID</th>
                            <th>Application</th>
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
