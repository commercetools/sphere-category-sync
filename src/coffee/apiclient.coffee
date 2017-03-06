_ = require 'underscore'
_.mixin require 'underscore-mixins'
Promise = require 'bluebird'
{SphereClient, CategorySync} = require 'sphere-node-sdk'

class ApiClient
  constructor: (@logger, options) ->
    @sync = new CategorySync options
    @client = new SphereClient options
    @continueOnProblems = options.continueOnProblems

    @updatesOnly = false
    @dryRun = false

  getByExternalIds: (externalIds) ->
    quotedIds = _.map externalIds, (id) -> "\"#{id}\""
    cond = "externalId in (#{quotedIds.join(', ')})"

    if externalIds.indexOf('') >= 0
      cond += ' or externalId is not defined'

    @client.categories
    .all()
    .where(cond)
    .fetch()

  getBySlugs: (slugs, language) ->
    quotedSlugs = _.map slugs, (slug) -> "\"#{slug}\""
    @client.categories
    .all()
    .where("slug(#{language} in (#{quotedSlugs.join(', ')}))")
    .fetch()

  update: (category, existingCategory, actionsToIgnore = [], context = {}) ->
    @logger.debug "performing update"
    actionsToSync = @sync
    .buildActions(category, existingCategory)
    .filterActions (action) ->
      not _.contains(actionsToIgnore, action.action)

    @logger.debug "Actions to sync: ", actionsToSync.getUpdateActions()

    if !actionsToSync.shouldUpdate()
      Promise.resolve "[#{context.sourceInfo}] nothing to update."
    else if @dryRun
      Promise.resolve "[#{context.sourceInfo}] DRY-RUN - updates for category with id '#{actionsToSync.getUpdateId()}':\n#{_.prettify actionsToSync.getUpdateActions()}"
    else
      @client.categories
      .byId(actionsToSync.getUpdateId())
      .update(actionsToSync.getUpdatePayload())
      .then (result) ->
        if result.body?.externalId
          console.log "Category with externalId " + result.body.externalId + " updated."
        else
          console.log "Category updated."
        "[#{context.sourceInfo}] Category updated."

      .catch (err) =>
        if err.code isnt 400
          msg = "[#{context.sourceInfo}] Error on updating category:\n#{_.prettify err.body} - payload: #{_.prettify actionsToSync.getUpdatePayload()}"
          @logger.error msg
          return Promise.reject msg

        msg = "[#{context.sourceInfo}] Problem on updating category:\n#{_.prettify err.body} - payload: #{_.prettify actionsToSync.getUpdatePayload()}"
        if @continueOnProblems
          Promise.resolve "#{msg} - ignored!"
        else
          Promise.reject msg

  create: (category, context = {}) ->
    @logger.debug "Performing create"
    if @dryRun
      Promise.resolve "[#{context.sourceInfo}] DRY-RUN - create new category."
    else if @updatesOnly
      Promise.resolve "[#{context.sourceInfo}] UPDATES ONLY - nothing done."
    else
      @client.categories.create(category)
      .then (result) ->
        if category.externalId
          console.log "Category with externalId " + category.externalId + " created."
        else
          console.log "Category created."
        result

      .catch (err) =>
        if err.code isnt 400
          msg = "[#{context.sourceInfo}] Error on creating new category:\n#{_.prettify err.body} - payload: #{_.prettify category}"
          @logger.error msg
          return Promise.reject msg

        msg = "[#{context.sourceInfo}] Problem on creating new category:\n#{_.prettify err.body} - payload: #{_.prettify category}"
        if @continueOnProblems
          Promise.resolve "#{msg} - ignored!"
        else
          Promise.reject msg

  delete: (category, context = {}) ->
    @client.categories.byId(category.id).delete(category.version)
    .then ->
      if category.externalId
        console.log "Category with externalId " + category.externalId + " deleted."
      else
        console.log "Category deleted."
      "[#{context.sourceInfo}] Category deleted."

    .catch (err) ->
      Promise.reject "[#{context.sourceInfo}] Error on deleting category:\n#{_.prettify err.body}"

module.exports = ApiClient