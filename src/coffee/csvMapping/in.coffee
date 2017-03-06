_ = require 'underscore'
Header = require './header'
objDot = require '../helper/dotNotation'

class ImportMapping extends Header

  constructor: (@rawHeader) ->
    super @rawHeader

  map: (row) ->
    json = {}
    _.forEach row, (value, name) =>
      if @_isParentIdHeader(name)
        @_mapParent value, json
      else
        @_mapField name, value, @language, json
    json

  _mapParent: (value, json) ->
    if value
      json['parent'] =
        id: value

  _mapField: (name, value, language, json) ->
    if @_isLocalizedHeader(name)
      json[name] or= {}
      json[name][language] = value
    else
      objDot.set(json, name, value)

module.exports = ImportMapping