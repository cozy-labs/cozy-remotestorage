americano = require('americano')
path = require('path')

module.exports = config =
  common: [
    americano.methodOverride()
    americano.errorHandler(dumpExceptions: true, showStack: true),
     americano.static path.resolve(__dirname, './assets'),
         maxAge: 86400000
  ],
  development: [
    americano.logger('dev')
  ],
  production: [
    americano.logger('short')
  ],
  plugins: [
    'americano-cozy'
  ]
