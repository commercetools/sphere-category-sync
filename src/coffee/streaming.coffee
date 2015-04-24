_ = require 'underscore'
_.mixin require 'underscore-mixins'
Promise = require 'bluebird'
ApiClient = require './apiclient'
Matcher = require './matcher'

class Streaming

  constructor: (@logger, options) ->
    @apiClient = new ApiClient @logger, options
    @matcher = new Matcher @logger, @apiClient

  processStream: (chunk, cb) ->
    @_processBatches(chunk)
    .then =>
      @logger.info 'Chunk of stream processed'
      cb()
    .catch (err) =>
      @logger.error err

  _processBatches: (categories) ->
    @logger.info "Processing '#{_.size categories}' categor#{if _.size(categories) is 1 then 'y' else 'ies'}"
    batchedList = _.batchList categories, 100
    Promise.map batchedList, (categoryList) =>
      @matcher.initialize(categoryList)
      .then =>
        posts = _.map categoryList, (category) =>
          @matcher.resolveParent(category)
          .then (cat) =>
            @matcher.match(cat)
            .then (existingCategory) =>
              @apiClient.update(cat, existingCategory)
            , =>
              @apiClient.create(cat)
              .then (result) =>
                # remember id of created category for faster parent match
                @matcher.addMapping result.body
                Promise.resolve result
        Promise.all posts

    , {concurrency: 1} # run 1 batch at a time

module.exports = Streaming