_ = require('underscore')._
_s = require 'underscore.string'
CONS = require '../lib/constants'
GLOBALS = require '../lib/globals'

class ExportMapping

  class TreeNode
    constructor: (@category) ->
      @subCategories = []

    addSubCategory: (node) ->
      @subCategories.push node

    getSubCategory: (id) ->
      _.find @subCategories, (sub) ->
        sub.category.id is id

    # TODO: Fix and use
    getSortedSubCategories: ->
      _.sortBy @subCategories, (sub) ->
        sub.category.orderHint or 0

    # we start at -1 as there is a dummy tree node to contain all root nodes
    toCsv: (header, csv, level = -1) ->
      if @category?
        csv.push header.toRow @category, level
      _.each @subCategories, (sub) ->
        sub.toCsv header, csv, level + 1


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
      # TODO: check order of ancestors!
        _.each category.ancestors, (ancestor) ->
          current = current.getSubCategory ancestor.id
        current.addSubCategory(new TreeNode(category))

    root


module.exports = ExportMapping
