_ = require 'underscore'
CONS = require '../lib/constants'
GLOBALS = require '../lib/globals'
Validator = require '../lib/validator'
TreeNode = require '../lib/treenode'
CetegorySync = require('sphere-node-sync').CategorySync
Q = require 'q'
SphereClient = require 'sphere-node-client'

class Importer

  constructor: (options = {}) ->
    if options.config # for easier unit testing
      @sync = new CategorySync options
      @client = new SphereClient options

    @validator = new Validator options
    @continueOnProblems = false
    @updatesOnly = false
    @dryRun = false
    @blackListedCustomAttributesForUpdate = []

  import: (fileContent) ->
    deferred = Q.defer()
    validator = new Validator()
    validator.parse(fileContent)
    .then ([header, content]) =>
      console.log 'content', content
      t = @_createTree header, content
      console.log "tree %j", t
      deferred.resolve 'OK'
    .fail (err) ->
      deferred.reject err
    .done()

    deferred.promise


  _createTree: (header, content) ->
    root = new TreeNode()
    columnIndex = header.rootIndex
    lastNodes = []
    lastNodes[-1] = root
    lastCellIndex = 0
    _.each content, (row) =>
      treePart = _.rest row, header.rootIndex
      console.log 'treePart', treePart
      _.each treePart, (cell, cellIndex) =>
        if cell? and cell isnt ''
          
          category = @_createCategory header, row, cell
          
          treeNode = new TreeNode category
          lastNodes[cellIndex - 1].addSubCategory treeNode
          lastNodes[cellIndex] = treeNode
          lastCellIndex = cellIndex
        else
          if cellIndex > lastCellIndex
            console.log 'There is a GAP'

    root

  _createCategory: (header, row, cell) ->
    # TODO: names in different languages
    # TODO: slugs in different languages
    # TODO: generate slug when not present
    # TODO: description in different languages
    # TODO: id for mapping
    # TODO: externalId
    # TODO: orderHint
    category =
      name: cell
      slug: cell


module.exports = Importer
