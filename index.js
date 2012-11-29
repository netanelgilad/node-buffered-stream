
var FixedBufferedStream = require('./lib/FixedBufferedStream')

module.exports = function(size){
  return new FixedBufferedStream(size);
}
