_ = require 'underscore'
CONS = require './constants'

class Header
  constructor: (@rawHeader) ->

  validate: ->
    errors = []
    if @rawHeader.length isnt _.unique(@rawHeader).length
      errors.push "There are duplicate header entries!"

    _.each @rawHeader, (header, index) ->
      if header.trim() != header
        errors.push "Header '#{header}' contains a padding whitespace!"

    @_toLanguageIndex()
    @_toIndex()

    errors

  _toIndex: ->
    _.each @rawHeader, (header, index) =>
      @handleHeader header, index

  handleHeader: ->

  _toLanguageIndex: ->
    @_createLanguageIndex CONS.LOCALIZED_HEADERS

  _createLanguageIndex: (localizedAttributes) ->
    _.each localizedAttributes, (attribName) =>
      _.each @rawHeader, (header, index) =>
        parts = header.match CONS.REGEX_LANGUAGE
        if _.size(parts) is 3 and parts[1] is attribName
          @handleLanguageHeader header, attribName, parts[2], index

  handleLanguageHeader: ->

module.exports = Header