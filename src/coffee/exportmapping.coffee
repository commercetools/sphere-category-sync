_ = require('underscore')._
_s = require 'underscore.string'
CONS = require '../lib/constants'
GLOBALS = require '../lib/globals'
TreeNode = require '../lib/treenode'

class ExportMapping

  constructor: (@header) ->

  mapCategories: (categories) ->
    tree = @_createTree categories
    csv = []
    tree.toCsv @header, csv
    csv

  _createTree: (categories) ->
    sortedByNumberOfAncestors = _.sortBy categories, (category) -> _.size category.ancestors
    root = new TreeNode()
    _.each sortedByNumberOfAncestors, (category) ->
      if _.size(category.ancestors) is 0
        root.addSubCategory(new TreeNode(category))
      else
        current = root
        _.each category.ancestors, (ancestor) ->
          current = current.getSubCategory ancestor.id
        current.addSubCategory(new TreeNode(category))

    root


module.exports = ExportMapping
