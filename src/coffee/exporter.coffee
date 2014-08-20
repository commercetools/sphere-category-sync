_ = require 'underscore'
fs = require 'fs'
Csv = require 'csv'
Validator = require '../lib/validator'
ExportMapping = require '../lib/exportmapping'
Q = require 'q'
prompt = require 'prompt'
SphereClient = require 'sphere-node-client'

class Exporter

  constructor: (options = {}) ->
    @queryString = options.queryString
    @client = new SphereClient options if options.config

  export: (templateContent, outputFile) ->
    deferred = Q.defer()
    validator = new Validator()
    validator.parse(templateContent)
    .then ([header]) =>
      exportMapping = new ExportMapping header
      @client.categories.all().fetch()
      .then (result) =>
        if result.body.total is 0
          deferred.resolve 'No categories found.'
        else
          console.log "Number of categories: #{result.body.total}."
          csv = [ header.rawHeader ].concat exportMapping.mapCategories(result.body.results)
          @_saveCSV(outputFile, csv)
    .then ->
      deferred.resolve 'Export done.'
    .fail (err) ->
      deferred.reject err
    .done()

    deferred.promise

  exportAsJson: (outputFile) ->
    deferred = Q.defer()
    @client.categories.all().fetch()
    .then (result) =>
      if result.body.total is 0
        deferred.resolve 'No categories found.'
      else
        console.log "Number of categories: #{result.body.total}."
        @_saveJSON(outputFile, result.body.results)
        .then ->
          deferred.resolve 'Export done.'
    .fail (err) ->
      deferred.reject err
    .done()

    deferred.promise

  _saveCSV: (file, content) ->
    deferred = Q.defer()
    Csv().from(content).to.path(file, encoding: 'utf8')
    .on 'error', (err) ->
      deferred.reject err
    .on 'close', (count) ->
      deferred.resolve count
    deferred.promise

  _saveJSON: (file, content) ->
    deferred = Q.defer()
    fs.writeFile file, JSON.stringify(content, null, 2), {encoding: 'utf8'}, (err) ->
      deferred.reject err if err
      deferred.resolve true
    deferred.promise


module.exports = Exporter
