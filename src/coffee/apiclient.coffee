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
    @client.categories
    .all()
    .where("externalId in (#{quotedIds.join(', ')})")
    .fetch()

  getBySlugs: (slugs, language) ->
    quotedSlugs = _.map slugs, (slug) -> "\"#{slug}\""
    @client.categories
    .all()
    .where("slug(#{language} in (#{quotedSlugs.join(', ')}))")
    .fetch()

  update: (category, existingCategory, actionsToIgnore = [], context = {}) ->
    @logger.debug "performing update"
    new Promise (resolve, reject) =>
      actionsToSync = @sync
      .buildActions(category, existingCategory)
      .filterActions (action) ->
        not _.contains(actionsToIgnore, action.action)

      @logger.debug "Actions to sync: ", actionsToSync.getUpdateActions()

      if !actionsToSync.shouldUpdate()
        resolve "[#{context.sourceInfo}] nothing to update."
      else if @dryRun
        resolve "[#{context.sourceInfo}] DRY-RUN - updates for category with id '#{actionsToSync.getUpdateId()}':\n#{_.prettify actionsToSync.getUpdateActions()}"
      else
        @client.categories
        .byId(actionsToSync.getUpdateId())
        .update(actionsToSync.getUpdatePayload())
        .then (result) ->
          if result.body.externalId
            console.log "Category with externalId " + result.body.externalId + " updated."
          else
            console.log "Category updated."
          resolve "[#{context.sourceInfo}] Category updated."
        .catch (err) =>
          if err.code is 400
            msg = "[#{context.sourceInfo}] Problem on updating category:\n#{_.prettify err.body} - payload: #{_.prettify actionsToSync.getUpdatePayload()}"
            if @continueOnProblems
              resolve "#{msg} - ignored!"
            else
              reject msg
          else
            msg = "[#{context.sourceInfo}] Error on updating category:\n#{_.prettify err.body} - payload: #{_.prettify actionsToSync.getUpdatePayload()}"
            @logger.error msg
            reject msg

  create: (category, context = {}) ->
    @logger.debug "performing create"
    new Promise (resolve, reject) =>
      if @dryRun
        resolve "[#{context.sourceInfo}] DRY-RUN - create new category."
      else if @updatesOnly
        resolve "[#{context.sourceInfo}] UPDATES ONLY - nothing done."
      else
        @client.categories.create(category)
        .then (result) ->
          if result.body.externalId
            console.log "Category with externalId " + result.body.externalId + " created."
          else
            console.log "Category created."
          resolve result
        .catch (err) =>
          if err.code is 400
            msg = "[#{context.sourceInfo}] Problem on creating new category:\n#{_.prettify err.body} - payload: #{_.prettify category}"
            if @continueOnProblems
              resolve "#{msg} - ignored!"
            else
              reject msg
          else
            msg = "[#{context.sourceInfo}] Error on creating new category:\n#{_.prettify err.body} - payload: #{_.prettify category}"
            @logger.error msg
            reject msg

  delete: (category, context = {}) ->
    new Promise (resolve, reject) =>
      @client.categories.byId(category.id).delete(category.version)
      .then ->
        if result.body.externalId
          console.log "Category with externalId " + result.body.externalId + " deleted."
        else
          console.log "Category deleted."
        resolve "[#{context.sourceInfo}] Category deleted."
      .catch (err) ->
        reject "[#{context.sourceInfo}] Error on deleting category:\n#{_.prettify err.body}"

module.exports = ApiClient