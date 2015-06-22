_ = require 'underscore'
Header = require './header'
CONS = require './constants'

class ExportMapping extends Header

  constructor: (@rawHeader, options = {}) ->
    super @rawHeader
    @parentBy = options.parentBy
    @index2CsvFn = []

  toCSV: (category) ->
    row = []
    _.each @index2CsvFn, (fn) ->
      fn category, row
    row

  handleLanguageHeader: (header, attribName, language, index) ->
    @index2CsvFn[index] = (json, row) ->
      val = json[attribName]?[language]
      row[index] = if val then val else ''

  handleHeader: (header, index) ->
    if _.isUndefined @index2CsvFn[index]
      @index2CsvFn[index] = if header is CONS.HEADER_PARENT_ID
        (json, row) =>
          row[index] = if json['parent']
            if json['parent']['obj'] and @parentBy
              json['parent']['obj'][@parentBy]
            else
              json['parent']['id']
          else
            ''
      else
        (json, row) ->
          row[index] = json[header]

module.exports = ExportMapping