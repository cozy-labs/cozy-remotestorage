module.exports = (req, res, next) ->

    # @TODO : do this properly (content-length)
    body = new Buffer 0

    req.on 'data', (chunk) ->
      buffer = new Buffer body.length + chunk.length
      body.copy buffer
      chunk.copy buffer, body.length
      body = buffer

    req.on 'end', ->
      req.buffer = body
      next()