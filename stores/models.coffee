Schema = require('jugglingdb').Schema
db = new Schema 'cozy-adapter', url: 'http://localhost:9101/'

RemoteStoragePermission = db.define 'RemoteStoragePermission',
    id            : String
    client_id     : String
    token         : String
    scope         : Object

File = db.define 'File',
    id            : String
    timestamp     : Number
    name          : String
    slug          : String
    _attachments  : Object

allMap     = (doc) -> emit doc.id, doc
bypathMap  = (doc) -> emit doc.slug.split('/'), doc
bytokenMap = (doc) -> emit doc.token, doc
checkError = (err) -> console.log 'ERROR CREATING REQUESTS', err if err

File.defineRequest 'bypath', bypathMap, checkError
File.defineRequest 'all',    allMap,    checkError

RemoteStoragePermission.defineRequest 'bytoken', bytokenMap, checkError
RemoteStoragePermission.defineRequest 'all',     allMap,     checkError

module.exports =
    'RemoteStoragePermission': RemoteStoragePermission
    'File'  : File