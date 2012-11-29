stream = require 'stream'
util = require 'util'

###
`BufferedStream([size])`
========================

This class implement both the Readable and Writable Stream 
API. Data written to it are stored inside a buffer. The buffer 
is emited though a "data" event when it is about to 
get larger than a defined "size".

The buffer is defined with a fixed size. As a consequence, 
this implentation present the advantage of consuming a 
constant amount of memory over time.

In the event that the data written is larger than the 
defined size, the buffer mechanism is bypassed and the data 
is directly emited with the "data" event. 

Setting the "size" parameter to 0 will simply bypassed the bufferisation.

Performances
------------

The results presented below are obtained by running `coffee samples/speed.coffee`.

Writting 100000 lines of 100 bytes (about 95 Mo)
```
# 0 b     : 2 s 57 ms 
# 64 b    : 2 s 17 ms 
# 128 b   : 2 s 32 ms 
# 256 b   : 1 s 755 ms 
# 512 b   : 1 s 200 ms 
# 1 Kb    : 728 ms 
# 1 Mb    : 266 ms 
# 4 Mb    : 271 ms 
# 16 Mb   : 282 ms 
# 64 Mb   : 276 ms 
# 128 Mb  : 279 ms
```

Writting 1000000 lines of 100 bytes (about 95 Mo)
```
0 b     : 19 s 937 ms 
64 b    : 17 s 717 ms 
128 b   : 16 s 743 ms 
256 b   : 10 s 580 ms 
512 b   : 7 s 463 ms 
1 Kb    : 5 s 59 ms 
1 Mb    : 2 s 470 ms 
4 Mb    : 2 s 518 ms 
16 Mb   : 2 s 750 ms 
64 Mb   : 2 s 784 ms 
128 Mb  : 2 s 637 ms
```

###
BufferedStream = (size = 1024) ->
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
  if data.length > @size
    @emit 'data', data
    return not @paused
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
  return true

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


