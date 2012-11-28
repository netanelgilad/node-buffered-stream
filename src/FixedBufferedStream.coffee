stream = require 'stream'
util = require 'util'

BufferedStream = (size = 1024 * 1024)->
  @writable = true
  @readable = true
  @size = size
  @buffer = new Buffer size
  @bufferPos = 0
  stream.call(this);

BufferedStream.prototype.__proto__ = stream.prototype

BufferedStream.prototype.write = (data) ->
  # Data is expected to be a string
  unless Buffer.isBuffer data
    # Convert it to a buffer
    data = new Buffer data
  dataWritten = Math.min @size - @bufferPos, data.length
  data.copy @buffer, @bufferPos, 0, dataWritten unless dataWritten is 0
  @bufferPos += dataWritten
  if dataWritten != data.length
    # Create a new buffer to be emitted
    buffer = new Buffer @bufferPos
    @buffer.copy buffer, 0, 0, @bufferPos
    @emit 'data', buffer
    # Copy the rest of the data into the internal buffer
    data.copy @buffer, 0, dataWritten, data.length
    @bufferPos = data.length - dataWritten
  return not @paused

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

# BufferedStream.prototype.pipe = (dest) ->
#   @dest = dest
#   dest.on 'error', (err) ->
#     console.log err
#   stream.prototype.pipe.apply @, arguments

module.exports = BufferedStream


