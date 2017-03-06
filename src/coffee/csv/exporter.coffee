_ = require 'underscore'
__ = require 'highland'
fs = require 'fs'
csv = require 'csv'
stringify = require 'csv-stringify'
transform = require 'stream-transform'
CsvTemplate = require './template'
ExportMapping = require '../csvMapping/out'
{SphereClient} = require 'sphere-node-sdk'
Promise = require 'bluebird'

class Exporter

  constructor: (@logger, @options = {}) ->
    @client = new SphereClient @options
    @csvTemplate = new CsvTemplate @logger, @client
    @mapping = null
    @stream = null

  _processChunk: (chunk) ->
    categories = chunk.body.results
    @logger.info "Processing #{_.size categories} categories"

    rows = _.map categories, (category) =>
      @mapping.map category
    @_write rows

  _exportCategories: (outPutFileName) ->
    new Promise (resolve, reject) =>
      @stream = fs.createWriteStream outPutFileName
      @stream.on 'error', reject
      @stream.on 'finish', ->
        resolve 'Export done.'

      @_write [@mapping.getTemplate()]

      @client.categories
        .expand('parent')
        .process(
          (res) => @_processChunk(res)
        , {accumulate: false}
        )
        .then =>
          @stream.end()

  _initMapping: (template) ->
    @mapping = new ExportMapping template, @options
    errors = @mapping.validate()
    throw { errors } if _.size errors

  run: (templateFileName, outPutFileName) ->
    @csvTemplate.loadTemplate templateFileName
    .then (template) =>
      @_initMapping(template)
    .then =>
      @_exportCategories outPutFileName

  _write: (output) ->
    new Promise (resolve, reject) =>
      stringify output, (err, out) =>
        if err
          return reject err
        @stream.write out
        resolve()

module.exports = Exporter
