
stream = require 'stream'
util = require 'util'

BufferedStream = (size = 1024 * 1024)->
  @writable = true
  @readable = true
  @size = size
  @buffer = new Buffer size
  @bufferPos = 0
  @

BufferedStream.prototype.__proto__ = stream.prototype

BufferedStream.prototype.write = (data) ->
  data = data.toString() if Buffer.isBuffer data
  dataLength = Buffer.byteLength(data, 'utf8')
  dataWritten = @buffer.write data, @bufferPos
  @bufferPos += dataWritten
  if dataWritten != dataLength
    @emit 'data', @buffer.slice(0, @bufferPos).toString()
    (new Buffer data).copy @buffer, 0, dataWritten, dataLength
    @bufferPos = dataLength - dataWritten
  @paused

BufferedStream.prototype.pause = (data) ->
  @paused = true

BufferedStream.prototype.resume = (data) ->
  @paused = false
  @emit 'drain'

BufferedStream.prototype.end = ->
  @emit 'data', @buffer.slice 0, @bufferPos
  @writable = false
  @readable = false
  @emit 'end'

module.exports = BufferedStream
