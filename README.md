[![Build Status](https://secure.travis-ci.org/wdavidw/node-buffered-stream.png)](http://travis-ci.org/wdavidw/node-buffered-stream)

This module create a Stream which implement both the writer and reader API.

Quick example
-------------

The example below will buffer the data from i readable stream and send them to a writeable stream as 16 Mo chunks.

```javascript
BufferedStream = require('buffered-stream');

reader = createStreamReader();
buffer = new BufferedStream(16*1024*1024);
writer = createStreamWriter();

reader.pipe(buffer).pipe(writer);
```

Contributors
------------

*	  David Worms: <https://github.com/wdavidw>

[travis]: https://travis-ci.org/#!/wdavidw/node-buffered-stream

