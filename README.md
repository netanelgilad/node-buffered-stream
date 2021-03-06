[![Build Status](https://secure.travis-ci.org/wdavidw/node-buffered-stream.png)](http://travis-ci.org/wdavidw/node-buffered-stream)

This module create a Stream which implement both the writer and reader API. The content written to the stream is buffered at a defined size and later flushed into the final destination stream. Use the buffered stream to increase writing speed.

Quick example
-------------

The example below will buffer the data from i readable stream and send them to a writeable stream as 16 Mo chunks.

```javascript
buffered = require('buffered-stream');

reader = createStreamReader();
buffer = buffered(4*1024*1024);
writer = createStreamWriter();

reader.pipe(buffer).pipe(writer);
```

Contributors
------------

*	  David Worms: <https://github.com/wdavidw>

[travis]: https://travis-ci.org/#!/wdavidw/node-buffered-stream

