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
        parentByValue = category.parent.id
        msgAppendix = "parent for '#{parentByValue}' using #{@parentBy} (language: #{@language})."
        parentId = @getIdFromCache parentByValue
        if parentId
          @logger.info "Found #{msgAppendix} - in cache"
          _resolve category, parentId
        else
          @fetchRef(parentByValue)
          .then (result) =>
            if result.body.total is 1
              @logger.info "Found #{msgAppendix} - by fetching"
              _resolve category, result.body.results[0].id
            else
              msg = "Could not resolve #{msgAppendix}"
              @logger.warn msg
              reject msg
          .catch (err) =>
            msg = "Problem on resolving #{msgAppendix}: #{err}"
            @logger.warn msg
            reject msg
      else
        resolve category

  getIdFromCache: (parentByValue) ->
    if @parentBy is CONS.HEADER_SLUG
      @slug2IdMap[parentByValue]
    else if @parentBy is CONS.HEADER_EXTERNAL_ID
      @externalId2IdMap[parentByValue]
    else
      parentByValue

  fetchRef: (parentByValue) ->
    if @parentBy is CONS.HEADER_SLUG
      @apiClient.getBySlugs [parentByValue], @language
    else if @parentBy is CONS.HEADER_EXTERNAL_ID
      @apiClient.getByExternalIds [parentByValue]
    else
      @apiClient.byId parentByValue

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