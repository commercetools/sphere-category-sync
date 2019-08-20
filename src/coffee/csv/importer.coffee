_ = require 'lodash'
__ = require 'highland'
fs = require 'fs'
csv = require 'csv'
transform = require 'stream-transform'
ImportMapping = require './importmapping'
ApiClient = require '../apiclient'
CategorySort = require './categorysort'
Streaming = require '../streaming'
Promise = require 'bluebird'

class Importer

  constructor: (@logger, @options = {}) ->
    @apiClient = new ApiClient @logger, @options
    @streaming = new Streaming @logger, @options, @apiClient
    @rowCount = 1

  sortCategories: (fileName) ->
    sortedFileName = fileName + '-sorted'
    categorySort = new CategorySort(@logger, @options)
    categorySort.sort fileName, sortedFileName
    sortedFileName

  run: (fileName) ->
    if @options.sort
      fileName = @sortCategories(fileName)

    parser = @_parseCsvStreamer()

    readStream = fs.createReadStream(fileName)

    new Promise (resolve, reject) =>
      __(readStream)
        .through(parser)
        .map (category) =>
          __(@_importCategory(category))
        .parallel(1) # import in series so it can create parents before its children
        .stopOnError(reject)
        .done ->
          resolve('Import done.')

  _parseCsvStreamer: () ->
    csv.parse
      delimiter: ','
      relax_column_count: true
      columns: (rawHeader) =>
        @mapping = new ImportMapping rawHeader
        errors = @mapping.validate()
        throw { errors } if _.size errors
        rawHeader


  _importCategory: (categoryRow) ->
    categoryRow = _.pickBy categoryRow, (val) -> val isnt ''
    @createCategory categoryRow
      .then (category) =>
        @streaming.processStream [ category ], _.noop
      .catch (err) =>
        if @options.continueOnProblems
          @logger.warn err
        else
          throw err

  createCategory: (row) ->
    @logger.debug 'create JSON category for row: ', row
    @resolveReferences(row)
      .then (row) =>
        json = @mapping.toJSON row
        @logger.debug 'generated JSON category: ', json
        json

  # Method will resolve references (eg customType by key) and mutates original csv row object
  resolveReferences: (row) ->
    if not row.customType
      return Promise.resolve(row)
    else
      @resolveCustomType(row.customType)
        .then (type) =>
          if not type
            Promise.reject("Type with key \"#{row.customType}\" was not found")
          else
            row.customType = type
            row

  resolveCustomType: (typeKey) ->
    @apiClient.getCustomTypeByKey(typeKey)

module.exports = Importer