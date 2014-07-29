oauth = require './oauth'
index = require './index'
storage = require './storage'

module.exports =
  '': get: index.index
  'revoke': get: index.revoke
  'oauth':
    get: oauth.form
  'public/storage*': all: storage.handler