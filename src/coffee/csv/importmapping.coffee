_ = require 'underscore'
Header = require './header'
CONS = require './constants'

class ImportMapping extends Header

  constructor: (@rawHeader) ->
    super @rawHeader
    @index2JsonFn = []

  toJSON: (row) ->
    json = {}
    _.each @index2JsonFn, (fn) ->
      fn row, json
    json

  handleLanguageHeader: (header, attribName, language, index) ->
    @index2JsonFn[index] = (row, json) ->
      json[attribName] or= {}
      json[attribName][language] = row[header]

  handleHeader: (header, index) ->
    if _.isUndefined @index2JsonFn[index]
      @index2JsonFn[index] = if header is CONS.HEADER_PARENT_ID
        (row, json) ->
          if row[header]
            json['parent'] =
              type: 'category'
              id: row[header]
      else
        (row, json) ->
          json[header] = row[header]

module.exports = ImportMapping