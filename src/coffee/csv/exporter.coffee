_ = require 'underscore'
__ = require 'highland'
fs = require 'fs'
csv = require 'csv'
stringify = require 'csv-stringify'
transform = require 'stream-transform'
CONS = require './constants'
ExportMapping = require './exportmapping'
{SphereClient} = require 'sphere-node-sdk'
Promise = require 'bluebird'

class Exporter

  constructor: (@logger, @options = {}) ->
    @client = new SphereClient @options

  loadTemplate: (fileName) ->
    new Promise (resolve, reject) =>
      parser = csv.parse
        delimiter: ','
        columns: (rawHeader) =>
          @_initMapping rawHeader
          rawHeader
      parser.on 'error', (error) ->
        reject error
      parser.on 'finish', ->
        resolve 'Header loaded.'

      stream = fs.createReadStream fileName
      stream.on 'error', (error) ->
        reject error

      stream.pipe(parser)

  _initMapping: (rawHeader) ->
    @mapping = new ExportMapping rawHeader, @options
    errors = @mapping.validate()
    throw { errors } if _.size errors
    @write [rawHeader] # pass array of array to ensure newline in CSV

  defaultTemplate: ->
    new Promise (resolve) =>
      header = CONS.BASE_HEADERS
      @client.project.fetch()
      .then (prj) =>
        _.each prj.body.languages, (l) ->
          header = header.concat _.map CONS.LOCALIZED_HEADERS, (h) ->
            "#{h}.#{l}"

        @_initMapping header
        resolve 'Default header created'

  run: (templateFileName, outPutFileName) ->
    new Promise (resolve, reject) =>
      @stream = fs.createWriteStream outPutFileName
      @stream.on 'finish', ->
        resolve 'Export done.'
      @stream.on 'error', (error) ->
        reject error

      promise = if templateFileName
        @loadTemplate templateFileName
      else
        @defaultTemplate()

      promise.catch (error) ->
        reject error
      .then =>

        processChunk = (payload) =>
          @logger.info "Processing #{_.size payload.body.results} categories"
          new Promise (resolve) =>
            rows = _.map payload.body.results, (category) =>
              @mapping.toCSV category
            @write rows
            .then (result) ->
              resolve result

        @client.categories
        .expand('parent')
        .expand('custom.type')
        .process(processChunk, {accumulate: false})
        .then =>
          @stream.end()

  write: (output) ->
    new Promise (resolve) =>
      stringify output, (err, out) =>
        @stream.write out
        resolve 'OK'

module.exports = Exporter
