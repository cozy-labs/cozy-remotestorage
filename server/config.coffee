americano = require('americano')

module.exports = config =
  common: [
    americano.methodOverride()
    americano.errorHandler( dumpExceptions: true, showStack: true),
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