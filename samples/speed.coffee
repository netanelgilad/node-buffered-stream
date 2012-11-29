

fs = require 'fs'
stream = require 'stream'
each = require 'each'
pad = require 'pad'
buffered = require '..'

###########################################################################################

Generator = ->
  @count = 0
  @readable = true
  process.nextTick @resume.bind @
  @
Generator.prototype.__proto__ = stream.prototype

Generator.prototype.resume = ->
  @paused = false
  while not @paused and @readable
    return @destroy() if @count++ is 100000
    @emit 'data', '♥✈☺♬☑♠☎☻♫☒♤☤☹♪♀✩✉☠✔♂★✇♺✖♨❦☁✌♛❁☪☂✏♝❀☭☃☛♞✿☮☼☚♘✾☯☾☝♖✽✝☄☟♟✺☥✂✍♕✵\n'

Generator.prototype.pause = ->
  @paused = true

Generator.prototype.destroy = ->
  @readable = false
  @emit 'end'
  @emit 'close'

###########################################################################################

pretty = 
  bytes: (value) ->
    for name, power in ['b', 'Kb', 'Mb', 'Gb', 'Tb', 'Pb', 'Eb', 'Zb', 'Yb']
      ref = Math.pow 1024, power + 1
      return "#{Math.round((value/Math.pow(1024,power))*2)/2} #{name}" if value < ref
  time: (time) ->
    print = ''
    for name, div of { ms:1000, s:60, m:60, h:24 }
      # print = "#{name} #{suffix}"
      print = "#{Math.floor(time % div)} #{name} #{print}"
      if time < div
        return print
      time = time / div
    print

###########################################################################################

run = (size, callback) ->
  # Prepare the pipe
  input = new Generator
  buffer = buffered size
  output = fs.createWriteStream "#{__dirname}/speed.#{pretty.bytes size}.out"
  # Call the pipe
  input.pipe(buffer).pipe(output)
  # See how that worked
  output.on 'error', (err)->
    console.log err
  output.on 'close', ->
    callback()

each([
  0
  64
  128
  256
  512
  1024
  1024*1024
  1024*1024*4
  1024*1024*16
  1024*1024*64
  1024*1024*128
])
.on 'item', (next, size) ->
  # Timer
  time = Date.now()
  each()
  .times(3)
  .on 'item', (next) ->
    run size, next
  .on 'error', ->
    next()
  .on 'end', ->
    console.log pad(pretty.bytes(size), 7), ':', pretty.time((Date.now()-time)/3)
    next()
.on 'error', (e) ->
  console.log e
.on 'end', ->
  console.log 'done'
