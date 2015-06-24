_ = require 'underscore'
Promise = require 'bluebird'
CONS = require './csv/constants'

class Matcher

  constructor: (@logger, @apiClient) ->
    @parentBy = CONS.HEADER_EXTERNAL_ID
    @language = 'en'
    @slug2IdMap = {}
    @externalId2IdMap = {}
    @currentCandidates = []

  addMapping: (category) ->
    @logger.info "Add mapping for exernalId: '#{category.externalId}' -> id: '#{category.id}'"
    @externalId2IdMap[category.externalId] = category.id
    @slug2IdMap[category.slug[@language]] = category.id

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
        category.parent.typeId = 'category'
        parentId = refFromCache category.parent
        if parentId
          @logger.info "Found parent for id '#{category.parent.id}'."
          category.parent.id = parentId
        else
          fetchRef(category.parent)
          .then (result) ->
            if result.body.count is 1
              category.parent.id = result.body.results[0].id
              resolve category
            else
              reject "Could not resolve parent with id '#{category.parent.id}'"
          .catch (err) ->
            reject "Problem in resolving parent with id '#{category.parent.id}': #{err}"

      resolve category

  refFromCache: (parent) ->
    if @parentBy is CONS.HEADER_SLUG
      @slug2IdMap[parent.slug[@language]]
    else
      @externalId2IdMap[parent.id]

  fetchRef: (parent) ->
    if @parentBy is CONS.HEADER_SLUG
      @apiClient.getBySlugs [parent.slug], @language
    else
      @apiClient.getByExternalIds [parent.id]

  match: (category) ->
    new Promise (resolve, reject) =>
      cat = _.find @currentCandidates, (candidate) ->
        candidate.externalId is category.externalId
      if cat
        @logger.info "Found match for externalId '#{cat.externalId}' with id '#{cat.id}'."
        @addMapping cat
      else
        msg = "No match found for category with external id '#{category.externalId}'"
        @logger.info msg
      resolve cat

module.exports = Matcher