

fs = require 'fs'
{exec} = require 'child_process'
stream = require 'stream'
should = require 'should'
each = require 'each'
pad = require 'pad'

sizes = [
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
]
times = 3

Generator = (@lines) ->
  @count = 0
  @readable = true
  process.nextTick @resume.bind @
  @
Generator.prototype.__proto__ = stream.prototype

Generator.prototype.resume = ->
  @paused = false
  while not @paused and @readable
    return @destroy() if @count++ is @lines
    @emit 'data', '♥✈☺♬☑♠☎☻♫☒♤☤☹♪♀✩✉☠✔♂★✇♺♨❦☁✌❁☂♝❀☭☃\n'

Generator.prototype.pause = ->
  @paused = true

Generator.prototype.destroy = ->
  @readable = false
  @emit 'end'
  @emit 'close'

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

each([
  require '../src/FixedBufferedStream'
  require '../src/StackBufferedStream'
])
.on 'item', (next, BufferedStream) ->
  each([
    {lines: 100000, md5: '9229fad768f525f6cac64bd158f6e022'}
    {lines: 1000000, md5: 'e837b60bbab8cb38259ff7b135a98aba'}
  ])
  .on 'item', (next, item) ->
    {lines, md5} = item
    each(sizes)
    .on 'item', (next, size) ->
      time = Date.now()
      each()
      .times(times)
      .on 'item', (next) ->
        # Prepare the pipe
        input = new Generator lines
        buffer = new BufferedStream size
        output = fs.createWriteStream "#{__dirname}/speed.#{pretty.bytes size}.out"
        # Call the pipe
        input.pipe(buffer).pipe(output)
        # See how that worked
        output.on 'error', (err)->
          console.log err
        output.on 'close', ->
          # Validate file md5
          exec "md5 #{__dirname}/speed.#{pretty.bytes(size).replace(' ','\\ ')}.out", (err, stdout, stderr) ->
            /\ (\w*)$/.exec(stdout.trim())[1].should.eql md5
            next()
      .on 'error', ->
        next()
      .on 'end', ->
        console.log pad(pretty.bytes(size), 7), ':', pretty.time((Date.now()-time)/times)
        next()
    .on 'both', next
  .on 'both', next
.on 'error', (err) ->
  console.error err
.on 'end', (err) ->
  console.log 'done'
