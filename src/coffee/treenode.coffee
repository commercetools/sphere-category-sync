_ = require('underscore')._
_s = require 'underscore.string'

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

module.exports = TreeNode