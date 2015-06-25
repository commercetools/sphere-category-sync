_ = require 'underscore'
Promise = require 'bluebird'
CONS = require './csv/constants'

class Matcher

  constructor: (@logger, @apiClient, options = {}) ->
    @parentBy = options.parentBy
    @language = options.language
    @slug2IdMap = {}
    @externalId2IdMap = {}
    @currentCandidates = []

  addMapping: (category) ->
    @logger.info "Add mapping for exernalId: '#{category.externalId}' -> id: '#{category.id}'"
    @externalId2IdMap[category.externalId] = category.id
    if category.slug
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
      _resolve = (cat, parentId) ->
        cat.parent.id = parentId
        cat.parent.typeId = 'category'
        delete cat.parent._rawParentId
        resolve cat
      if category.parent
        parentId = @getIdFromCache category.parent
        msgAppendix = "parent for '#{category.parent.id}' using #{@parentBy} (language: #{@language})."
        if parentId
          @logger.info "Found #{msgAppendix}"
          _resolve category, parentId
        else
          @fetchRef(category.parent)
          .then (result) ->
            if result.body.count is 1
              _resolve category, result.body.results[0].id
            else
              reject "Could not resolve #{msgAppendix}"
          .catch (err) ->
            reject "Problem in resolving #{msgAppendix}: #{err}"

      resolve category

  getIdFromCache: (parent) ->
    if @parentBy is CONS.HEADER_SLUG
      @slug2IdMap[parent.id]
    else
      @externalId2IdMap[parent.id]

  fetchRef: (parent) ->
    if @parentBy is CONS.HEADER_SLUG
      @apiClient.getBySlugs [parent.id], @language
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