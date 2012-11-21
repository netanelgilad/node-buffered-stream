
should = require 'should'
fs = require 'fs'
BufferedStream = if process.env.BF_COV then require '../lib-cov/buffered-stream' else require '../lib/buffered-stream'

file = '/tmp/node-buffered-stream'

go = (data, callback) ->
  buffer = new BufferedStream 1024
  out = fs.createWriteStream file
  out.on 'error', (err) ->
    console.log 'error', err
  out.on 'close', ->
    fs.readFile file, 'utf8', (err, content) ->
      should.not.exist err
      # console.log 'oka', content
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

describe 'buffered stream', ->

  it 'should write ascii each 100 chars as 1 Ko chuncks', (next) ->
    data = ''
    for i in [0...1000000] then data += "fjieorjf#{i}\n"
    go data, next

  it 'should write utf8 each 100 chars as 1 Ko chuncks', (next) ->
    data = ''
    for i in [0...1000000] then data += "àèêûîô#{i}\n"
    go data, next




