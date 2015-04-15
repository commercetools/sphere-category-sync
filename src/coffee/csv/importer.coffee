_ = require 'underscore'
__ = require 'highland'
fs = require 'fs'
csv = require 'csv'
transform = require 'stream-transform'
ImportMapping = require './importmapping'
Streaming = require '../streaming'

class Importer

  constructor: (@logger, options = {}) ->
    @streaming = new Streaming @logger, options

  import: (fileName) ->
    parser = csv.parse
      delimiter: ','
      columns: (rawHeader) =>
        @mapping = new ImportMapping rawHeader
        @mapping.validate() # TODO: handle errors
        rawHeader
    parser.on 'error', (error) =>
      @logger.error error
    parser.on 'finish', =>
      @logger.info "Import done."

    transformer = transform (row, callback) =>
      category = @createCategory row
      callback null, category
    , {parallel: 10}

    input = fs.createReadStream fileName
    __(input).pipe(parser).pipe(transformer).pipe(
      transform (chunk, cb) =>
        @logger.debug 'chunk: ', chunk, {}
        @streaming.processStream [ chunk ], cb # TODO: better passing of chunk
      , {parallel: 1})

  createCategory: (row) ->
    @logger.debug 'create JSON category for row: ', row
    json = @mapping.toJSON row
    @logger.debug 'generated JSON categor: ', json
    json

module.exports = Importer