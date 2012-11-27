
should = require 'should'
fs = require 'fs'
BufferedStream = if process.env.BF_COV then require '../lib-cov/FixedBufferedStream' else require '../lib/FixedBufferedStream'

file = "/tmp/buffered-stream"

go = (data, callback) ->
  buffer = new BufferedStream 3*1024*1024
  out = fs.createWriteStream file
  buffer.on 'error', (err) ->
    next err
  out.on 'error', (err) ->
    next err
  out.on 'close', ->
    fs.readFile file, 'utf8', (err, content) ->
      should.not.exist err
      content.should.eql data
      fs.unlink file, (err) ->
        should.not.exist err
        callback()
  buffer.pipe out
  offset = 0
  length = 100
  while offset + length < data.length
    buffer.write data.substr offset, length
    offset += length
  buffer.write data.substr offset
  buffer.end()

describe 'fixed buffered stream', ->

  it 'should write ascii each 100 chars as 1 Ko chuncks', (next) ->
    data = ''
    for i in [0...1000000] then data += "fjieorjf#{i}\n"
    go data, next

  it 'should write utf8 each 100 chars as 1 Ko chuncks', (next) ->
    data = ''
    for i in [0...1000000] then data += "☃♥✈☺♬☑♠☎☻♫☒♤☤☹♪♀✩✉☠✔♂★✇♺✖♨❦☁✌♛❁☪☂✏♝❀☭☃☛♞✿☮☼☚♘✾☯☾☝♖✽✝☄☟♟✺☥✂✍♕✵#{i}\n"
    go data, next

  it 'should pipe', (next) ->
    @timeout 5000
    data = ''
    for i in [0...1000000] then data += "àèêûîô#{i}\n"
    fs.writeFile "#{file}-input", data, 'utf8', (err) ->
      input = fs.createReadStream "#{file}-input", flags: 'r'
      buffer = new BufferedStream 3*1024*1024
      output = fs.createWriteStream file
      input.pipe(buffer).pipe(output)
      output.on 'close', ->
        fs.readFile file, 'utf8', (err, content) ->
          should.not.exist err
          content.should.eql data
          fs.unlink file, (err) ->
            should.not.exist err
            next()



