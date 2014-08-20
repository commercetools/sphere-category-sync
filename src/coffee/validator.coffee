_ = require('underscore')._
_s = require 'underscore.string'
Csv = require 'csv'
CONS = require '../lib/constants'
GLOBALS = require '../lib/globals'
Header = require '../lib/header'
Q = require 'q'
SphereClient = require 'sphere-node-client'

class Validator
  constructor: (options = {}) ->
    @errors = []
    @csvOptions =
      delimiter: options.csvDelimiter or ','
      quote: options.csvQuote or '"'

  parse: (csvString) ->
    deferred = Q.defer()

    Csv().from.string(csvString, @csvOptions)
    .on 'error', (error) ->
      deferred.reject error

    .to.array (data) ->
      header = new Header data[0]
      errors = header.validate()
      if _.size(errors) is 0
        deferred.resolve [ header, _.rest data ]
      else
        deferred.reject errors

    deferred.promise


module.exports = Validator