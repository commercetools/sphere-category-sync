_ = require 'underscore'
_.mixin require 'underscore-mixins'
Promise = require 'bluebird'
ApiClient = require './apiclient'
Matcher = require './matcher'

class Streaming

  constructor: (@logger, options) ->
    @apiClient = new ApiClient @logger, options
    @matcher = new Matcher @logger, @apiClient, options
    @actionsToIgnore = options.actionsToIgnore
    @_resetSummary()

  _resetSummary: =>
    @_summary =
      updated: 0
      created: 0

  summaryReport: =>
    if @_summary.created is 0 and @_summary.updated is 0
      message = 'Summary: nothing to do, everything is fine'
    else
      message = "Summary: there were #{@_summary.created + @_summary.updated} imported categories " +
        "(#{@_summary.created} were new and #{@_summary.updated} were updates)"
    message

  processStream: (chunk, cb) ->
    @_processBatches(chunk)
    .then =>
      @logger.info 'Chunk of stream processed'
      cb()
    .catch (err) =>
      @logger.error err

  _processBatches: (categories) =>
    @logger.info "Processing '#{_.size categories}' categor#{if _.size(categories) is 1 then 'y' else 'ies'}"
    @matcher.initialize(categories)
    .return categories
    .map (category) =>
      @matcher.resolveParent(category)
      .then (cat) =>
        if cat
          @matcher.match(cat)
          .then (existingCategory) =>
            console.log(existingCategory)
            if existingCategory
              @apiClient.update(cat, existingCategory, @actionsToIgnore)
            else
              @apiClient.create(cat)
              .then (result) =>
                # remember id of created category for faster parent match
                if result.body
                  @matcher.addMapping result.body
                  switch result.statusCode
                    when 200 then @_summary.updated++
                    when 201 then @_summary.created++
                else
                  @logger.warn result
                Promise.resolve result
    , {concurrency: 1} # 1 category at a time


module.exports = Streaming