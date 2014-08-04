_ = require 'underscore'
CONS = require '../lib/constants'
GLOBALS = require '../lib/globals'

class Header
  constructor: (@rawHeader) ->

  validate: ->
    errors = []
    if @rawHeader.length isnt _.unique(@rawHeader).length
      errors.push "There are duplicate header entries!"

    regex = new RegExp "^#{CONS.HEADER_ROOT}.*"
    rootHeader = _.find @rawHeader, (head) -> regex.exec head
    if rootHeader?
      @rootIndex = _.indexOf @rawHeader, rootHeader

      parts = rootHeader.split GLOBALS.DELIM_HEADER_LANGUAGE
      if _.size(parts) is 1
        @rootLanguages = [ GLOBALS.DEFAULT_LANGUAGE ]
      else if _.size(parts) is 2
        if parts[1].indexOf(GLOBALS.DELIM_MULTI_VALUE) is -1
          @rootLanguages = [ parts[1] ]
        else
          @rootLanguages = parts[1].split GLOBALS.DELIM_MULTI_VALUE
      # TODO: check rootLanguages
      else
        errors.push "Can't parse root header '#{rootHeader}'."
    else
      errors.push "Can't find necessary base header '#{CONS.HEADER_ROOT}'!"

    @toIndex()
    @toLanguageIndex()
    
    errors

  # "x,y,z"
  # toIndex:
  #   x: 0
  #   y: 1
  #   z: 2
  toIndex: (name) ->
    @h2i = _.object _.map @rawHeader, (head, index) -> [head, index] unless @h2i?
    if name?
      @h2i[name]
    else
      @h2i

  has: (name) ->
    @toIndex() unless @h2i?
    _.has @h2i, name

  toLanguageIndex: (name) ->
    @langH2i = @_createLanguageIndex CONS.LOCALIZED_HEADERS unless @langH2i?
    if name?
      @langH2i[name]
    else
      @langH2i

  hasLanguageFor: (name) ->
    @toLanguageIndex() unless @langH2i?
    _.has @langH2i, name

  toRow: (category, level = 0) ->
    row = []

    _.each CONS.BASE_HEADERS, (head) =>
      if @has head
        row[@toIndex head] = category[head]

    langIndex = @toLanguageIndex()
    _.each langIndex, (langs, attrib) ->
      _.each langs, (index, lang) ->
        row[index] = category[attrib][lang]

    row[@rootIndex + level] = _.reduce @rootLanguages,
      (cell, lang, index) -> "#{cell}#{if index is 0 then '' else ';'}#{category.name[lang]}",
      ''

    row

  # "x,slug.de,foo,slug.it"
  # _languageToIndex =
  #   slug:
  #     de: 1
  #     it: 3
  _createLanguageIndex: (localizedAttributes) ->
    langH2i = {}
    _.each localizedAttributes, (langAttribName) =>
      _.each @rawHeader, (head, index) ->
        parts = head.split GLOBALS.DELIM_HEADER_LANGUAGE
        if _.size(parts) is 2
          if parts[0] is langAttribName and parts[0] isnt CONS.HEADER_ROOT
            lang = parts[1]
            if CONS.REGEX_LANGUAGE.test lang
              langH2i[langAttribName] or= {}
              langH2i[langAttribName][lang] = index

          # TODO: better error handling
            else
              console.error "Unknown language '#{lang}' in header '#{head}'."

    langH2i


module.exports = Header