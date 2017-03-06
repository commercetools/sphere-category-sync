_ = require 'underscore'
__ = require 'highland'
fs = require 'fs'
csv = require 'csv'
transform = require 'stream-transform'
ImportMapping = require '../csvMapping/in'
CategorySort = require './categorysort'
Streaming = require '../streaming'
CONS = require '../constants'
Promise = require 'bluebird'

class Importer

  constructor: (@logger, @options = {}) ->
    @streaming = new Streaming @logger, @options

  sortCategories: (fileName) ->
    sortedFileName = fileName + '-sorted'
    categorySort = new CategorySort(@logger, @options)
    categorySort.sort fileName, sortedFileName
    sortedFileName

  run: (fileName) ->

    if @options.sort
      fileName = @sortCategories(fileName)

    rowCount = 2
    new Promise (resolve, reject) =>
      input = fs.createReadStream fileName
      input.on 'error', (error) ->
        reject error

      parser = csv.parse
        delimiter: CONS.CSV_DELIMITER
        columns: (rawHeader) =>
          @mapping = new ImportMapping rawHeader
          errors = @mapping.validate()
          throw { errors } if _.size errors
          rawHeader
      parser.on 'error', (error) ->
        reject error
      parser.on 'finish', ->
        resolve 'Import done.'

      transformer = transform (row, callback) =>
        category = @createCategory row
        callback null, category
      , {parallel: 10}

      chunkSize = 1
      __(input).pipe(parser).pipe(transformer).pipe(
        transform (chunk, cb) =>
          @logger.info "Process row: " + rowCount
          @logger.debug 'chunk: ', chunk, {}
          @streaming.processStream [ chunk ], cb # TODO: better passing of chunk
          rowCount = rowCount + chunkSize
        , {parallel: chunkSize})

  createCategory: (row) ->
    @logger.debug 'Create JSON category for row: ', row
    json = @mapping.map row
    @logger.debug 'Generated JSON category: ', json
    json

module.exports = Importer