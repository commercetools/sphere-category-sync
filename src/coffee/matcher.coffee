debug = require('debug')('sphere-category-sync')
_ = require 'underscore'
Promise = require 'bluebird'

class Matcher

  constructor: (@logger, @apiClient) ->
    @externalId2IdMap = {}
    @currentCandidates = []

  addMapping: (category) ->
    @externalId2IdMap[category.externalId] = category.id

  initialize: (categories) ->
    @logger.info "Getting candidates: #{_.size categories}"
    new Promise (resolve, reject) =>
      externalIds = _.map categories, (category) ->
        category.externalId
      @apiClient.getByExternalIds(externalIds)
      .then (result) =>
        @currentCandidates = result.body.results
        @logger.info "Found candidates: #{_.size @currentCandidates}"
        resolve()
      .catch (err) -> reject err

  resolveParent: (category) ->
    new Promise (resolve, reject) =>
      if category.parent
        parentId = @externalId2IdMap[category.parent.id]
        if parentId
          @logger.info "Found parent for id '#{category.parent.id}'."
          category.parent.id = parentId
          category.parent.typeId = 'category'
          resolve category
        else
          # we can try once again to resolve it remote here
          reject "Could not resolve parent with id '#{category.parent.id}'"
      else
        resolve category

  match: (category) ->
    new Promise (resolve, reject) =>
      cat = _.find @currentCandidates, (candidate) ->
        candidate.externalId is category.externalId
      if cat
        @logger.info "Found match with externalId '#{cat.externalId}'."
        @addMapping category
        resolve cat
      else
        msg = "No match found for category with external id '#{category.externalId}'"
        @logger.info msg
        reject msg

module.exports = Matcher