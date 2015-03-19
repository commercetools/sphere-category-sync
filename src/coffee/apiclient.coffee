debug = require('debug')('sphere-category-sync')
_ = require 'underscore'
_.mixin require 'underscore-mixins'
Promise = require 'bluebird'
{SphereClient, CategorySync} = require 'sphere-node-sdk'

class ApiClient

  constructor: (@logger, options) ->
    @sync = new CategorySync options # TODO: enable as soon as new sdk released
    @client = new SphereClient options

    @continueOnProblems = false
    @updatesOnly = false
    @dryRun = false

  update: (category, existingCategory, context) ->
    new Promise (resolve, reject) =>
      actionsToSync = @sync.buildActions(category, existingCategory)
      # console.log "Actions to Sync", actionsToSync.getUpdateActions()

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
        .done()

  create: (category, context) ->
    new Promise (resolve, reject) =>
      if @dryRun
        resolve "[#{context.sourceInfo}] DRY-RUN - create new category."
      else if @updatesOnly
        resolve "[#{context.sourceInfo}] UPDATES ONLY - nothing done."
      else
        @client.categories.create(category)
        .then (result) ->
          resolve "[#{context.sourceInfo}] New category created."
        .catch (err) =>
          if err.statusCode is 400
            msg = "[#{context.sourceInfo}] Problem on creating new category:\n#{_.prettify err}"
            if @continueOnProblems
              resolve "#{msg} - ignored!"
            else
              reject msg
          else
            reject "[#{context.sourceInfo}] Error on creating new category:\n#{_.prettify err}"
        .done()

  delete: (category, context) ->
    new Promise (resolve, reject) =>
      @client.categories.byId(category.id).delete(category.version)
      .then ->
        resolve "[#{context.sourceInfo}] Category deleted."
      .catch (err) ->
        reject "[#{context.sourceInfo}] Error on deleting category:\n#{_.prettify err}"
      .done()


module.exports = ApiClient
