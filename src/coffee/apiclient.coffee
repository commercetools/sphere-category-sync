debug = require('debug')('sphere-category-sync')
_ = require 'underscore'
_.mixin require 'underscore-mixins'
Promise = require 'bluebird'
{SphereClient, CategorySync} = require 'sphere-node-sdk'

class ApiClient

  constructor: (@logger, options = {}) ->
    if options.config # for unit testing
      # @sync = new CategorySync # TODO: enable as soon as new sdk released
      @client = new SphereClient options

    @continueOnProblems = false
    @updatesOnly = false
    @dryRun = false

  processTree: (tree) ->
    if _.size(tree.isEmpty()) is 0
      Promise.resolve 'Nothing to do.'
    else
      posts = []
      tree.traverse (category, context, index) =>
        existingCategory = @matcher.match(category, context)
        posts.push if existingCategory?
          @update(category, existingCategory, context)
        else
          @create(category, context)

      Promise.all posts

  processStream: (chunk, cb) ->
    @_processBatches(chunk).then -> cb()

  _processBatches: (categories) ->
    batchedList = _.batchList(categories, 10) # max
    Promise.map batchedList, (catsToProcess) =>
      @matcher.initialize catsToProcess, =>
        Promise.all _.map catsToProcess, (category) =>
          existingCategory = @matcher.match(category, context)
          if existingCategory?
            @update(category, existingCategory, context)
          else
            @create(category, context)

    , {concurrency: 1} # run 1 batch at a time

  update: (category, existingCategory, context) ->
    new Promise (resolve, reject) =>
      diff = @sync.buildActions(category, existingCategory)
      #console.log "DIFF %j", diff.get()

      if @dryRun
        updates = diff.get()
        if updates?
          resolve "[#{context.sourceInfo}] DRY-RUN - updates for #{category.id}:\n#{_.prettify updates}"
        else
          resolve "[#{context.sourceInfo}] DRY-RUN - nothing to update."
      else
        diff.update()
        .then (result) ->
          if result.statusCode is 304
            resolve "[#{context.sourceInfo}] Category update not necessary."
          else
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

  deleteCategory: (category, context) ->
    new Promise (resolve, reject) =>
      @client.categories.byId(category.id).delete(category.version)
      .then ->
        resolve "[#{context.sourceInfo}] Category deleted."
      .catch (err) ->
        reject "[#{context.sourceInfo}] Error on deleting category:\n#{_.prettify err}"
      .done()


module.exports = ApiClient
