_ = require 'underscore'
CONS = require '../constants'

class Header
  constructor: (@rawHeader) ->
    @customTypes = []

  getTemplate: ->
    @rawHeader

  validate: ->
    errors = []
    if @rawHeader.length isnt _.unique(@rawHeader).length
      errors.push "There are duplicate header entries!"

    _.each @rawHeader, (header) ->
      if header.trim() != header
        errors.push "Header '#{header}' contains a padding whitespace!"
    errors

  _isParentIdHeader: (name) ->
    name is CONS.HEADER_PARENT_ID

  _isLocalizedHeader: (name) ->
    CONS.LOCALIZED_HEADERS.indexOf(name) >= 0


module.exports = Header
