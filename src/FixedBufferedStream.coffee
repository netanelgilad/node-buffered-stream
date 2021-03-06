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

Writting 100000 lines of 100 bytes (about 9.5 Mo)

```
0 b     : 2 s 54 ms 
64 b    : 1 s 927 ms 
128 b   : 1 s 798 ms 
256 b   : 1 s 283 ms 
512 b   : 817 ms 
1 Kb    : 576 ms 
1 Mb    : 293 ms 
4 Mb    : 283 ms 
16 Mb   : 273 ms 
64 Mb   : 273 ms 
128 Mb  : 274 ms
```

Writting 1000000 lines of 100 bytes (about 95 Mo)

```
0 b     : 20 s 454 ms 
64 b    : 20 s 548 ms 
128 b   : 15 s 754 ms 
256 b   : 12 s 803 ms 
512 b   : 7 s 626 ms 
1 Kb    : 5 s 189 ms 
1 Mb    : 2 s 514 ms 
4 Mb    : 2 s 610 ms 
16 Mb   : 2 s 771 ms 
64 Mb   : 2 s 758 ms 
128 Mb  : 2 s 750 ms
```

In this test, we are reading from a custom generator 
Readable Stream and writing to the file system. Since we 
are writing 100 bytes lines, a buffer of 0 byte or 64 byte
lead to the same internal behavior while a buffer of 128 bytes
use the internal buffer but lead to similar performances. Increasing
the buffer size increase performance until the buffer reach 1 Mo. After
that, performance stale. Notice that in our tests, a file Readable Stream write data 
as 1 Mo chunks as well.

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

module.exports = BufferedStream


