_ = require 'underscore'
fs = require 'fs'
csv = require 'csv'
CONS = require '../constants'

class CsvTemplate
  constructor: (@logger, @client) ->

  _loadFromFile: (fileName) ->
    new Promise (resolve, reject) =>
      stream = fs.createReadStream fileName
      header = null
      parser = csv.parse
        delimiter: CONS.CSV_DELIMITER
        columns: (row) ->
          if not header
            header = row
      parser.on 'finish', =>
        @logger.info('Template loaded')
        resolve header
      parser.on 'error', reject
      stream.pipe(parser)

  _loadFromDefault: ->
    header = CONS.BASE_HEADERS
    @client.project.fetch()
    .then (res) =>
      _.each res.body.languages, (l) ->
        header = header.concat _.map CONS.LOCALIZED_HEADERS, (h) ->
          "#{h}.#{l}"
      @logger.info('Default template created')
      header

  loadTemplate: (file) ->
    if file
      @_loadFromFile file
    else
      @_loadFromDefault()

module.exports = CsvTemplate
