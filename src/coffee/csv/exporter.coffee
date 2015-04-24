_ = require 'underscore'
__ = require 'highland'
fs = require 'fs'
csv = require 'csv'
stringify = require 'csv-stringify'
transform = require 'stream-transform'
ExportMapping = require './exportmapping'
Streaming = require '../streaming'
{SphereClient} = require 'sphere-node-sdk'
Promise = require 'bluebird'

class Exporter

  constructor: (@logger, options = {}) ->
    @client = new SphereClient options

  loadTemplate: (fileName) ->
    new Promise (resolve, reject) =>
      parser = csv.parse
        delimiter: ','
        columns: (rawHeader) =>
          @mapping = new ExportMapping rawHeader
          errors = @mapping.validate()
          throw { errors } if _.size errors
          @write [rawHeader] # pass array of array to ensure newline in CSV
          rawHeader
      parser.on 'error', (error) =>
        reject error
      parser.on 'finish', =>
        resolve 'Header loaded.'

      stream = fs.createReadStream(fileName)
      stream.on 'error', (error) =>
        reject error

      stream.pipe(parser)

  export: (templateFileName, outPutFileName) ->
    new Promise (resolve, reject) =>
      @stream = fs.createWriteStream outPutFileName
      @stream.on 'error', (error) =>
        reject error

      @loadTemplate templateFileName
      .catch (error) =>
        reject error
      .then () =>

        processChunk = (payload) =>
          new Promise (resolve, reject) =>
            rows = _.map payload.body.results, (category) =>
              row = @mapping.toCSV category
            @write rows

        @client.categories.process(processChunk)
        .then (result) ->
          @stream.end()
          resolve result

  write: (output) ->
    stringify output, (err, out) =>
      @stream.write out

module.exports = Exporter