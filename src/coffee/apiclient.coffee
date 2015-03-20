debug = require('debug')('sphere-category-sync')
_ = require 'underscore'
_.mixin require 'underscore-mixins'
Promise = require 'bluebird'
{SphereClient, CategorySync} = require 'sphere-node-sdk'

class ApiClient

  constructor: (@logger, options) ->
    @sync = new CategorySync options
    @client = new SphereClient options

    @continueOnProblems = false
    @updatesOnly = false
    @dryRun = false

  getByExternalIds: (externalIds) ->
    get = @client.categories.all().whereOperator('or')
    _.each externalIds, (eId) ->
      get.where("externalId = \"#{eId}\"")
    get.fetch()

  update: (category, existingCategory, context = {}) ->
    new Promise (resolve, reject) =>
      actionsToSync = @sync.buildActions(category, existingCategory)
      debug "Actions to sync: ", actionsToSync.getUpdateActions()

      if !actionsToSync.shouldUpdate()
        resolve "[#{context.sourceInfo}] nothing to update."
      else if @dryRun
        resolve "[#{context.sourceInfo}] DRY-RUN - updates for category with id '#{actionsToSync.getUpdateId()}':\n#{_.prettify actionsToSync.getUpdateActions()}"
      else
        @client.categories
        .byId(actionsToSync.getUpdateId())
        .update(actionsToSync.getUpdatePayload())
        .then (result) ->
          resolve "[#{context.sourceInfo}] Category updated."
        .catch (err) =>
          if err.statusCode is 400
            msg = "[#{context.sourceInfo}] Problem on updating category:\n#{_.prettify err}"
            if @continueOnProblems
              resolve "#{msg} - ignored!"
            else
              reject msg
          else
            reject "[#{context.sourceInfo}] Error on updating category:\n#{_.prettify err}"

  create: (category, context = {}) ->
    new Promise (resolve, reject) =>
      if @dryRun
        resolve "[#{context.sourceInfo}] DRY-RUN - create new category."
      else if @updatesOnly
        resolve "[#{context.sourceInfo}] UPDATES ONLY - nothing done."
      else
        @client.categories.create(category)
        .then (result) ->
          resolve result
        .catch (err) =>
          if err.statusCode is 400
            msg = "[#{context.sourceInfo}] Problem on creating new category:\n#{_.prettify err}"
            if @continueOnProblems
              resolve "#{msg} - ignored!"
            else
              reject msg
          else
            reject "[#{context.sourceInfo}] Error on creating new category:\n#{_.prettify err}"

  delete: (category, context = {}) ->
    new Promise (resolve, reject) =>
      @client.categories.byId(category.id).delete(category.version)
      .then ->
        resolve "[#{context.sourceInfo}] Category deleted."
      .catch (err) ->
        reject "[#{context.sourceInfo}] Error on deleting category:\n#{_.prettify err}"

module.exports = ApiClient