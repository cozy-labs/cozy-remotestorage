americano = require 'americano'

module.exports =
  permissions:
    byKey: (doc) -> emit doc.key, doc
    bySame: (doc) ->
        emit doc.details.redirectUri + doc.details.clientId + doc.value.join(' '), doc

  documents:
    byKey: (doc) -> emit doc.key, doc