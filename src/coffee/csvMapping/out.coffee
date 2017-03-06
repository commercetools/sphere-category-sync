_ = require 'underscore'
Header = require './header'
objDot = require '../helper/dotNotation'
CONS = require '../constants'

class ExportMapping extends Header
  constructor: (rawHeader, options = {}) ->
    super rawHeader
    @language = options.language
    @parentBy = options.parentBy || 'id'

  map: (category) ->
    row = _.map @rawHeader, (name) =>
      if @_isParentIdHeader(name)
        @_mapParent category
      else
        @_mapField category, name
    row

  _mapParent: (category) ->
    value = ''

    # if there is parent, return localized slug or requested key
    if category.parent?.obj?
      value = category.parent.obj[@parentBy]
      if @parentBy is CONS.HEADER_SLUG
        value = value[@language]

    else if category.parent?.id
      # fallback - use category.id as a default parent
      value = category.parent.id

    value

  _mapField: (category, name) ->
    if @_isLocalizedHeader(name)
      category[name]?[@language] || ''
    else
      objDot.get(category, name, undefined)

module.exports = ExportMapping
